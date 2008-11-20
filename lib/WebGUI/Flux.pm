package WebGUI::Flux;

use strict;
use GraphViz;
use JSON;
use Readonly;
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

=head1 NAME

Package WebGUI::Flux

=head1 DESCRIPTION

Flux Rule-based authorisation layer for WebGUI

Flux adds a dynamic behavioral layer on top of wG, giving content managers a simple and
yet immensely powerful way to add rule-based authorisation to their websites. The design
aims for a system that is flexible and extensible to developers but simple and intuitive to
content managers.

=head1 SYNOPSIS

 use WebGUI::Flux;
 
 my @allRules = WebGUI::Flux->getRules($session);
 my $singleRule = WebGUI::Flux->getRule($session, $id);

=head1 METHODS

These methods are available from this class:

=cut

my %ruleCache;    # (hash) cache of WebGUI::Flux::Rule objects

#-------------------------------------------------------------------

=head2 getRule ( session, id )

Returns a Rule. Underlying call to WebGUI::Flux::Rule->new() will throw exception if Rule not found
N.B. A simple Rule cache is used. It WILL become stale if you delete a Rule (whereas C<getRules> 
consults the db first)/

=head3 session

A reference to the current session.

=head3 id

An existing Rule's unique id.

=cut

sub getRule {
    my $class = shift;
    my ( $session, $fluxRuleId ) = validate_pos( @_, { isa => 'WebGUI::Session' }, 1 );

    # Retreive Rule from cache or db..
    if ( !exists $ruleCache{$fluxRuleId} ) {
        $ruleCache{$fluxRuleId} = WebGUI::Flux::Rule->new( $session, $fluxRuleId );
    }

    return $ruleCache{$fluxRuleId};
}

#-------------------------------------------------------------------

=head2 getRules ( )

Returns an array reference of Rules

=cut

sub getRules {
    my $class = shift;
    my ($session) = validate_pos( @_, { isa => 'WebGUI::Session' } );

    # Collect an array of Rules
    my @ruleObjects = ();
    my $rules       = $session->db->read('select fluxRuleId from fluxRule order by sequenceNumber');
    while ( my ($fluxRuleId) = $rules->array ) {
        push @ruleObjects, $class->getRule( $session, $fluxRuleId );
    }

    return \@ruleObjects;
}

#-------------------------------------------------------------------

=head2 generateGraph ( )

Generates the Flux Graph using GraphViz. This is currently just a proof-of-concept.
The image is stored at /uploads/FluxGraph.png and overwritten every time this method is called.

Currently only simple GraphViz features are used to generate the graph. Later we will
probably take advantage of html-like processing capabilities to improve the output.

GraphViz must be installed for this to work.

=cut

sub generateGraph {
    my $class = shift;
    my ($session) = validate_pos( @_, { isa => 'WebGUI::Session' } );

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }

    # Create the GraphViz object used to generate the image
    my $g = GraphViz->new( bgcolor => 'white', fontsize => 10 );
    Readonly my $PATH => $session->config->get("uploadsPath") . '/FluxGraph.png';

    # Generate the image by iterating over all defined Rules..
    my @edges;    # collection of vertices to add at the end after nodes have been added
    Readonly my $INDENT => '  ';

    # GraphViz can print html entities
    Readonly my $BULLET => '&bull;';
    Readonly my $RARR   => '&rarr;';
    Readonly my $LDQUOT => '&ldquo;';
    Readonly my $RDQUOT => '&rdquo;';

    Readonly my $FONTSIZE => 11;

    foreach my $rule ( @{ $class->getRules($session) } ) {

        # Start building up a descriptive label for the node..
        my $label = $LDQUOT . $rule->get('name') . $RDQUOT . "\n";
        $label .= $rule->get('sticky') ? "(sticky)\n" : "\n";

        my $count = $rule->getExpressionCount();
        if ( $count == 0 ) {
            $label .= 'This Rule has no Expressions';
        }
        else {
            $label .= 'Expression:\l';

            # Add information about all the Expressions associated with this Rule..
            foreach my $e ( @{ $rule->getExpressions() } ) {
                $label .= "$INDENT e" . $e->get('sequenceNumber') . " $RARR " . $e->get('name') . '\l';

                # Check both operands for Rule dependencies..
                foreach my $operand qw(operand1 operand2) {
                    if ( $e->get($operand) eq 'FluxRule' ) {

                        my $args = from_json( $e->get( $operand . 'Args' ) );    # deserialise JSON-encoded args
                        my $dependendRuleId = $args->{fluxRuleId};

                        # Add this dependency to the list of vertices to add at the end
                        push @edges,
                            [
                            $rule->getId() => $dependendRuleId,
                            taillabel      => 'e' . $e->get('sequenceNumber') . '    ',
                            labelfontcolor => 'CornflowerBlue',
                            labelfontsize  => $FONTSIZE,
                            color          => 'CornflowerBlue'
                            ];
                    }
                }

            }

            # Add the Combined Expresssion to the output if defined
            if ( defined $rule->get('combinedExpression') ) {
                $label .= 'Combined: \l';
                $label .= $LDQUOT;
                $label .= $rule->get('combinedExpression');
                $label .= $RDQUOT;
            }
        }
        $g->add_node(
            $rule->getId(),
            label     => $label,
            fontsize  => $FONTSIZE,
            shape     => 'ellipse',
            style     => 'filled',
            color     => 'CornflowerBlue',
            fillcolor => 'LightBlue',
        );

    }

    # Now add the vertices..
    foreach my $edge (@edges) {
        $g->add_edge( @{$edge} );
    }

    # Render the image to a file
    $g->as_png($PATH);

    return $PATH;
}

#-------------------------------------------------------------------

=head2 evaluateFor ( arg_ref )

Convenience method. Instantiates a Flux Rule and evaluates it against a given user and assetId.
Currently, if anything goes wrong we return 0 (deny access).

=head3 arg_ref

Hash ref of properties:

=head4 user

The WebGUI::User for whom the Flux Rule should be evaluated against

=head4 fluxRuleId

The fluxRuleId of the Flux Rule

=head4 assetId

The assetId of the asset/wobject being evaluated against (optional) 

=cut

sub evaluateFor {
    my $class = shift;
    my %args = validate( @_, { user => { isa => 'WebGUI::User' }, fluxRuleId => 1, assetId => 0 } );

    my $user = $args{user};
    my $assetId = $args{assetId};
    my $session = $user->session();

    # Instantiate the Flux Rule..
    my $fluxRule = eval { WebGUI::Flux->getRule( $session, $args{fluxRuleId} ) };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( $e->error );
        return 0;
    }
    if ( !$fluxRule ) {
        $session->log->warn('Unable to instantiate Flux Rule');
        return 0;
    }

    # Evaluate the Flux Rule..
    my $result = eval { $fluxRule->evaluateFor( { user => $user, assetId => $assetId } ) };
    if ( my $e = Exception::Class->caught() ) {
        $session->log->warn( 'Flux caught an exception, returning 0 - ' . $e->error );
        return 0;
    }

    return $result;
}

#-------------------------------------------------------------------

=head2 getStickies ( arg_ref )

Returns a list of fluxRuleIds that have been true for the given user at least 
once (e.g. dateRuleFirstTrue is not null).
If users progress linearly through a sequence of rules (think sticky), then 
this method can be used to determine in a single sql query how far they have
progressed along the linear sequence. See also getLinearProgression.

=cut

sub getStickies {
    my $class = shift;

    my %args = validate( @_, { fluxRuleIds => { type => ARRAYREF }, user => { isa => 'WebGUI::User' } } );

    my $user        = $args{user};
    my @fluxRuleIds = @{ $args{fluxRuleIds} };

    return unless @fluxRuleIds;

    my $session = $user->session;

    my $ruleList = join( q{,}, map { $session->db->quote($_) } @fluxRuleIds );
    my $sql = <<"END_SQL";
select fluxRuleId 
from fluxRuleUserData natural join fluxRule 
where sticky 
    and fluxRuleId in ( $ruleList ) 
    and userId = ? 
    and dateRuleFirstTrue is not null
END_SQL

    return $session->db->buildArray( $sql, [ $user->userId ] );
}

#-------------------------------------------------------------------

=head2 getLinearProgression ( arg_ref )

Walk through fluxRuleIds in a linear sequence. Stop as soon as a rule is false, unless
the rule has been flagged as skippable.

Excluding situations where you allow multipel rules to be skipped, this sub will only
wastefully evaluate one Rule (the first rule that fails). If most of your rules are sticky
then this sub doesn't need to do much work at all.

Returns an array of result hashes, with the result undefined for rules that we didn't reach.

=cut

sub getLinearProgression {
    my $class = shift;

    my %args = validate(
        @_,
        {   fluxRuleIds          => { type => ARRAYREF },
            user                 => { isa  => 'WebGUI::User' },
            skippableFluxRuleIds => { type => ARRAYREF, optional => 1 },
            adminAlwaysTrue => 0,
        }
    );

    # Build a hash of rules that Flux already knows are true
    my %stickies = map { $_ => 1 } $class->getStickies( fluxRuleIds => $args{fluxRuleIds}, user => $args{user} );
    my %skippable = map { $_ => 1 } ( @{ $args{skippableFluxRuleIds} } );

    my $user    = $args{user};
    my $session = $user->session;
    
    my $force_true = $args{adminAlwaysTrue} && $user->isInGroup(3);

    my @results;

    # Find the last fluxRuleId that evaluates to true
    foreach my $fluxRuleId ( @{ $args{fluxRuleIds} } ) {

        if ( $force_true ) {
            $session->log->debug("Admin user, so $fluxRuleId forced to be true");
            push @results, { id => $fluxRuleId, success => 1 };
            next;
        }

        if ( $stickies{$fluxRuleId} ) {
            $session->log->debug("$fluxRuleId is a known sticky, no need to eval");
            push @results, { id => $fluxRuleId, success => 1 };
            next;
        }

        $session->log->debug("Evaluating $fluxRuleId due to getLinearProgression search");

        my $result = $class->evaluateFor( { user => $user, fluxRuleId => $fluxRuleId } );
        push @results, { id => $fluxRuleId, success => $result };

        if ($result) {
            $session->log->debug("$fluxRuleId evaluated true, continuing search..");
            next;
        }

        if ( $skippable{$fluxRuleId} ) {
            $session->log->debug("$fluxRuleId evaluated false, but in skippable so continuing search..");
            next;
        }

        $session->log->debug("$fluxRuleId evaluated false, search ends here");
        last;
    }

    return @results;
}

1;
