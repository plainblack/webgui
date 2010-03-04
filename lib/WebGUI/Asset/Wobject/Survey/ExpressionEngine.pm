package WebGUI::Asset::Wobject::Survey::ExpressionEngine;

=head1 NAME

Package WebGUI::Asset::Wobject::Survey::ExpressionEngine

=head1 DESCRIPTION

This class is used to process Survey gotoExpressions.

If you want to allow the expression engine to run you need to turn on the enableSurveyExpressionEngine flag
in your site config file. This is because no matter how 'Safe' the Safe.pm compartment is, it still has
caveats. For example, it doesn't protect you from infinite loops.  

See L<run> for more details.

=cut

use strict;
use Params::Validate qw(:all);
use Safe;
use List::Util qw/sum/;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Survey;
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

# We need these as semi-globals so that utility subs (which are shared with the safe compartment)
# can access them.
my $session;
my $values;
my $scores;
my $jumpCount;
my $validate;
my $validTargets;
my $otherInstances;
my $tags;

=head2 value

Utility sub that gives expressions access to recorded response values

Returns the recorded response value for the answer to question_variable

=cut

sub value {
    my $key   = shift;
    
    # Verbatim values are valid variable + _verbatim
    if (my ($verbatimKey) = $key =~ m/(.+)_verbatim/) {
        _validateVariable($verbatimKey, 'value');
    } else {
        _validateVariable($key, 'value');
    }
    my $value = $tags->{$key} || $values->{$key};
    if (ref $value eq 'ARRAY') {
        my $joined = join ', ', @$value;
        if (wantarray) {
            $session->log->debug("value($key) in list context resolves to ($joined)");
            return @$value;
        } else {
            $session->log->debug("value($key) in scalar|void context resolves to \"$joined\"");
            return $joined;
        }
    } else {
        $session->log->debug("value($key) resolves to [$value]");
        return $value;
    }
}

=head2 valueX

Same as L<value>, except that first argument is an asset spec (assetId or url), which must resolve
to a valid survey instance. The sub is applied to the most recent completed response for the user 
on the survey instance given by asset_spec.

=cut

sub valueX {
    my ( $asset_spec, $key ) = @_;
    
    # See if $otherInstances already contains the external survey
    if (my $otherInstance = $otherInstances->{$asset_spec}) {
        my $values = $otherInstance->{values};
        my $value  = $values->{$key};
        if (ref $value eq 'ARRAY') {
            my $joined = join ', ', @$value;
            if (wantarray) {
                $session->log->debug("valueX($asset_spec, $key) in list context resolves to ($joined)");
                return @$value;
            } else {
                $session->log->debug("valueX($asset_spec, $key) in scalar|void context resolves to \"$joined\"");
                return $joined;
            }
        } else {
            $session->log->debug("valueX($asset_spec, $key) resolves to [$value]");
            return $value;
        }
    } else {
        # Throw an exception, triggering run() to resolve the external reference and re-run
        die( { otherInstance => $asset_spec } );
    }
}

=head2 score

Utility sub that gives expressions access to recorded response scores.

If the argument is a question variable, returns the score for the answer selected for question_variable.

If the argument is a section variable, returns the summed score for the answers to all the questions in section_variable

If two arguments are provided, the first argument is assumed to be an asset spec (assetId or url). In this
case the sub is applied to the most recent completed response for the user on the survey instance given by asset_spec.

=cut

sub score {
    my $key = shift;
    _validateVariable($key, 'score');
    my $score = $scores->{$key};
    $session->log->debug("score($key) resolves to [$score]");
    return $score;
}

=head2 scoreX

Same as L<score>, except that first argument is an asset spec (assetId or url), which must resolve
to a valid survey instance. The sub is applied to the most recent completed response for the user 
on the survey instance given by asset_spec.

=cut

sub scoreX {
    my ( $asset_spec, $key ) = @_;
    
    # See if $otherInstances already contains the external survey
    if (my $otherInstance = $otherInstances->{$asset_spec}) {
        my $scores = $otherInstance->{scores};
        my $score  = $scores->{$key};
        $session->log->debug("scoreX($asset_spec, $key) resolves to [$score]");
        return $score;
    } else {
        # Throw an exception, triggering run() to resolve the external reference and re-run
        die( { otherInstance => $asset_spec } );
    }
}

=head2 _validateVariable ($key, $fn)

Convenience sub to do optional validation of variable names

=head3 key

Variable name to validate

=head3 fn

Function name of caller (for diagnostic output)

=cut

sub _validateVariable {
    my $key = shift;
    my $fn = shift || 'unspecified function';
    if ( $validTargets && !exists $validTargets->{$key} ) {
        my $error = "Param [$key] to $fn is not a valid variable name";
        $session->log->debug($error);
        die($error) if $validate;
        return;
    }
    return 1;
}

=head2 answered

Returns true/false depending on whether use has actually reached and responded to the given question

If two arguments are provided, the first argument is assumed to be an asset spec (assetId or url). In this
case the sub is applied to the most recent completed response for the user on the survey instance given by asset_spec.

=cut

sub answered {
    my $key   = shift;
    
    _validateVariable($key, 'answered');
    my $answered = exists $values->{$key};
    $session->log->debug("answered($key) returns [$answered]");
    return $answered;
}

=head2 answeredX

Same as L<answered>, except that first argument is an asset spec (assetId or url), which must resolve
to a valid survey instance. The sub is applied to the most recent completed response for the user 
on the survey instance given by asset_spec.

=cut

sub answeredX {
    my ( $asset_spec, $key ) = @_;
    
    # See if $otherInstances already contains the external survey
    if (my $otherInstance = $otherInstances->{$asset_spec}) {
        my $values = $otherInstance->{values};
        my $answered  = exists $values->{$key};
        $session->log->debug("answeredX($asset_spec, $key) returns [$answered]");
        return $answered;
    } else {
        # Throw an exception, triggering run() to resolve the external reference and re-run
        die( { otherInstance => $asset_spec } );
    }
}

=head2 tag ($name, [$value])

Utility sub that allows expressions to tag data

=head3 $name

Name of tag to set

=head3 $value (optional)

Value of tag to set. Defaults to 1 (boolean true flag).

=cut

sub tag {
    my ($name, $value) = @_;
    $value = 1 if !defined $value;
    $session->log->debug("Setting tag [$name] to [$value]");
    $tags->{$name} = $value;
}

=head2 tagged ($name)

Utility sub that gives expressions access to tagged data

=head3 $name

Name of tag whose value is returned.

=cut

sub tagged {
    my ($name) = @_;
    if (@_ == 2) {
        my $args = join ',', @_;
        $session->log->warn("Two arguments passed to tagged($args). Did you mean tag($args)?");
    }
    my $value = $tags->{$name};
    $session->log->debug("tagged($name) resolves to [$value]");
    return $value;
}

=head2 taggedX

Same as L<tagged>, except that first argument is an asset spec (assetId or url), which must resolve
to a valid survey instance. The sub is applied to the most recent completed response for the user 
on the survey instance given by asset_spec.

=cut

sub taggedX {
    my ( $asset_spec, $name ) = @_;
    
    if (@_ == 3) {
        my $args = join ',', @_;
        $session->log->warn("Three arguments passed to taggedX($args). Did you mean tag($args)?");
    }
    # See if $otherInstances already contains the external survey
    if (my $otherInstance = $otherInstances->{$asset_spec}) {
        my $tags = $otherInstance->{tags};
        
        my $value = $tags->{$name};
        $session->log->debug("taggedX($asset_spec, $name) returns [$value]");
        return $value;
    } else {
        # Throw an exception, triggering run() to resolve the external reference and re-run
        die( { otherInstance => $asset_spec } );
    }
}

=head2 jump

Utility sub shared with Safe compartment so that expressions can call individual jump tests.

Throws an exception containing the jump target when a jump matches, thus allowing L<run> to
catch the first successful jump.

=cut

sub jump(&$) {
    my ( $sub, $target ) = @_;
    $jumpCount++;

    # If $validTargets known, make sure target is valid
    if (!_validateVariable($target, 'jump')) {
        return; # skip jump but continue with expression
    }

    if ( $sub->() ) {
        $session->log->debug("jump call #$jumpCount is truthy");
        die( { jump => $target } );
    }
    else {
        $session->log->debug("jump call #$jumpCount is falsey");
    }
}

=head2 exitUrl ( [$url] )

Same as L<jump> except that instead of a jump, triggers survey exit

=head3 url (optional)

Url to exit to. If not given, the Survey instance's exitUrl property will be used.

=cut

sub exitUrl {
    my ( $url ) = @_;

    $session->log->debug("exitUrl($url)");
    die( { exitUrl => $url } );
}


=head2 restart ( $sub )

Same as L<jump> except that instead of a jump, triggers the Survey to restart

=cut

sub restart {
    $session->log->debug("restart()");
    die( { restart => 1 } );
}

=head2 avg

Utility sub shared with Safe compartment to allows expressions to easily compute the average of a list

=cut

sub avg {
    my @vals = @_;
    return sum(@vals) / @vals;
}

=head2 round

Utility sub shared with Safe compartment to allows expressions to easily round numbers

=cut

sub round {
    my ($number, $precision) = @_;
    $precision ||= 0;
    return sprintf("%.${precision}f", $number);
}

=head2 run ( $session, $expression, $opts )

Class method.

Evaluates the given expression in a Safe compartment.

=head3 session

A WebGUI::Session

=head3 expression

The expression to run. 

A gotoExpression is essentially a perl expression that gets evaluated in a Safe compartment.

To access Section/Question recorded response values, the expression calls L<value>.
To access Section/Question recorded response scores, the expression calls L<score>.
To determine if a user reached and answered a question, the expression calls L<answered>.

All of these subs allow you to resolve values and scores from other completed survey
instances.

To trigger a jump, the expression calls L<jump>. The first truthy jump succeeds.

Expressions also have access to some useful utility subs such as avg(), and all of the 
handy subs from List::Util (min, max, sum, etc..).

A very simple expression that checks if the response to s1q1 is 0 might look like:
 
 jump { value(s1q1) == 0 } target

A more complicated gotoExpression with two possible jumps might look like:

 jump { value(q1) > 5 and value(s2q1) =~ m/textmatch/ } target1;
 jump { avg(value(q1), value(q2), value(home/anotherSurvey, q3)) > 10 } target2;

=head3 opts (optional)

Supported options are:

=over 3

=item * values

Hashref of values to make available to the expression via the L<value> utility sub

=item * scores

Hashref of scores to make available to the expression via the L<score> utility sub

=item * validTargets

A hashref of valid jump targets. If this is provided, all L<jump> calls will fail unless
the specified target is a key in the hashref.

=item * validate

Return errors rather than just logging them (useful for displaying survey validation errors to users)  

=back

=cut

sub run {
    my $class = shift;
    my ( $s, $expression, $opts )
        = validate_pos( @_, { isa => 'WebGUI::Session' }, { type => SCALAR }, { type => HASHREF, default => {} } );

    # Init package globals
    $session = $s;
    $values = $opts->{values} || {};
    $scores = $opts->{scores} || {};
    $jumpCount = 0;
    $validate = $opts->{validate};
    $validTargets = $opts->{validTargets};
    $tags = $opts->{tags} || {};

    if ( !$session->config->get('enableSurveyExpressionEngine') ) {
        $session->log->debug('enableSurveyExpressionEngine config option disabled, skipping');
        return;
    }

    REVAL: {

        # Create the Safe compartment
        my $compartment = Safe->new();
        $compartment->permit(qw(sort));

        # Share our utility subs with the compartment
        $compartment->share('&value');
        $compartment->share('&valueX');
        $compartment->share('&score');
        $compartment->share('&scoreX');
        $compartment->share('&answered');
        $compartment->share('&answeredX');
        $compartment->share('&tag');
        $compartment->share('&tagged');
        $compartment->share('&taggedX');
        $compartment->share('&jump');
        $compartment->share('&exitUrl');
        $compartment->share('&restart');
        $compartment->share('&avg');
        $compartment->share('&round');

        # Give them all of List::Util too
        $compartment->share_from( 'List::Util',
            [ '&first', '&max', '&maxstr', '&min', '&minstr', '&reduce', '&shuffle', '&sum', ] );

#        $session->log->debug("Expression is: \"$expression\"");

        $compartment->reval($expression);

        # See if we ran the engine just to check for errors
        if ( $opts->{validate} ) {
            if ( $@ && ref $@ ne 'HASH' ) {
                my $error = $@;
                $error =~ s/(.*?) at .*/$1/s;    # don't reveal too much
                return $error;
            }
            return;                              # no validation errors
        }

        # A successful jump triggers a hashref containing the jump target to be thrown
        if ( ref $@ && ref $@ eq 'HASH') {
            if (my $target = $@->{jump}) {
                return { jump => $target, tags => $tags };
            }
            if (exists $@->{exitUrl}) { # url might be undefined
                return { exitUrl => $@->{exitUrl}, tags => $tags };
            }
            if (my $restart = $@->{restart}) {
                return { restart => $restart, tags => $tags };
            }
        }

        # See if an unresolved external reference was encountered
        if ( ref $@ && ref $@ eq 'HASH' && $@->{otherInstance} ) {
            my $asset_spec = $@->{otherInstance};
            $session->log->debug("Resolving external reference: $asset_spec");
            my $asset;

            # Instantiate the asset to check it is a Survey instance, and to grab its assetId
            if ( $session->id->valid($asset_spec) ) {
                $asset = WebGUI::Asset->newById( $session, $asset_spec );
            }
            if ( !$asset ) {
                $asset = WebGUI::Asset->newByUrl( $session, $asset_spec );
            }
            if ( ref $asset ne 'WebGUI::Asset::Wobject::Survey' ) {
                $session->log->warn("Not a survey instance: $asset_spec");
                return;
            }
            if ( !$asset ) {
                $session->log->warn("Unable to find asset: $asset_spec");
                return;
            }
            my $assetId = $asset->getId;

            # Get the responseId of the most recently completed survey response for the user
            my $userId = $opts->{userId} || $session->user->userId;
            my $mostRecentlyCompletedResponseId = $session->db->quickScalar(
                "select Survey_responseId from Survey_response where userId = ? and assetId = ? and isComplete = 1 order by endDate desc limit 1",
                [ $userId, $assetId ]
            );

            if ( !$mostRecentlyCompletedResponseId ) {
                $session->log->debug("User $userId has not completed Survey");
                return;
            }
            $session->log->debug("Using responseId: $mostRecentlyCompletedResponseId");

            # (re)Instantiate the survey instance using the responseId
            $asset = WebGUI::Asset::Wobject::Survey->newByResponseId( $session, $mostRecentlyCompletedResponseId );
            if ( !$asset ) {
                $session->log->warn("Unable to instantiate asset by responseId: $mostRecentlyCompletedResponseId");
                return;
            }

            my $rJSON = $asset->responseJSON( undef, $mostRecentlyCompletedResponseId );
            $otherInstances->{$asset_spec} = {
                values => $rJSON->responseValues( indexBy => 'variable' ),
                scores => $rJSON->responseScores( indexBy => 'variable' ),
                tags => $rJSON->tags,
            };
            $session->log->debug("Successfully looked up asset: $assetId. Repeating reval.");
            redo REVAL;
        }

        # Log all other errors (for example compile errors from bad expressions)
        if ($@) {
            $session->log->error($@);
            return; # Return undef on failure
        }

        # If we reach here, no jump was issued, meaning that we probably just processed an expression that did some tagging
        return { jump => undef, tags => $tags };
    }
}

1;
