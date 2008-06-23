package WebGUI::Flux;

use strict;
use warnings;

use GraphViz;
use JSON;
use Readonly;

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
    my ( $class, $session, $fluxRuleId ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }
    if ( !defined $fluxRuleId ) {
        WebGUI::Error::InvalidParam->throw(
            param => $fluxRuleId,
            error => 'Need a fluxRuleId.'
        );
    }

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
    my ( $class, $session ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }

    # Collect an array of Rules
    my @ruleObjects = ();
    my $rules       = $session->db->read('select fluxRuleId from fluxRule');
    while ( my ($fluxRuleId) = $rules->array ) {
        push @ruleObjects, $class->getRule( $session, $fluxRuleId );
    }

    return \@ruleObjects;
}

#-------------------------------------------------------------------

=head2 getGraph ( )

Generates the Flux Graph using GraphViz. This is currently just a proof-of-concept.
The image is stored at /uploads/FluxGraph.png and overwritten every time this method is called.

Currently only simple GraphViz features are used to generate the graph. Later we will
probably take advantage of html-like processing capabilities to improve the output.

GraphViz must be installed for this to work.

=cut

sub generateGraph {
    my ( $class, $session ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }

    # Create the GraphViz object used to generate the image
    my $g = GraphViz->new( bgcolor => 'beige', fontsize => 10 );
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
                            labelfontcolor => 'brown',
                            labelfontsize  => $FONTSIZE,
                            color          => 'brown'
                            ];
                    }
                }

            }

            # Add the Combined Expresssion to the output (generating the default if necessary)
            $label .= 'Combined: \l';
            $label .= $LDQUOT;
            if ( defined $rule->get('combinedExpression') ) {
                $label .= $rule->get('combinedExpression');
            }
            else {
                $label .= join ' and ', map {"e$_"} ( 1 .. $count );
            }
            $label .= $RDQUOT;

        }
        $g->add_node(
            $rule->getId(),
            label     => $label,
            fontsize  => $FONTSIZE,
            shape     => 'ellipse',
            style     => 'filled',
            color     => 'chocolate',
            fillcolor => 'burlywood',
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

1;
