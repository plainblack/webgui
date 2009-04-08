package WebGUI::Asset::Wobject::Survey::ExpressionEngine;

=head1 NAME

Package WebGUI::Asset::Wobject::Survey::ExpressionEngine

=head1 DESCRIPTION

This class is used to process Survey gotoExpressions.

See L<run> for more details.

=cut

use strict;
use Params::Validate qw(:all);
use Safe;
use Data::Dumper;
use List::Util qw/sum/;
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

# We need these as semi-globals so that utility subs (which are shared with the safe compartment)
# can access them.
my $session;
my $values;
my $scores;
my $jump_count;
my $validate;
my $validTargets;
 
=head2 value

Utility sub that gives expressions access to recorded response values

value(question_variable) returns the recorded response value for the answer to question_variable

=cut

sub value($) {
    my $key   = shift;
    my $value = $values->{$key};
    $session->log->debug("[$key] resolves to [$value]");
    return $value; # scalar variable, so no need to clone
}

=head2 score

Utility sub that gives expressions access to recorded response scores.

score(question_variable) returns the score for the answer selected for question_variable
score(section_variable) returns the summed score for the answers to all the questions in section_variable

=cut

sub score($) {
    my $key   = shift;
    my $score = $scores->{$key};
    $session->log->debug("[$key] resolves to [$score]");
    return $score; # scalar variable, so no need to clone
}

=head2 jump

Utility sub shared with Safe compartment so that expressions can call individual jump tests.

Throws an exception containing the jump target when a jump matches, thus allowing L<run> to
catch the first successful jump.

=cut

sub jump(&$) {
    my ( $sub, $target ) = @_;
    $jump_count++;
    
    # If $validTargets known, make sure target is valid
    if ($validTargets && !exists $validTargets->{$target}) {
        $session->log->debug("Invalid target [$target]");
        if ($validate) {
            die("Invalid jump target \"$target\""); # bail and report error
        } else {
            return; # skip jump but continue with expression
        }
    }
        
    if ( $sub->() ) {
        $session->log->debug("jump call #$jump_count is truthy");
        die( { jump => $target } );
    }
    else {
        $session->log->debug("jump call #$jump_count is falsey");
    }
}

=head2 avg

Utility sub shared with Safe compartment to allows expressions to easily compute the average of a list

=cut

sub avg {
    my @vals = @_;
    return sum(@vals) / @vals;
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
To trigger a jump, the expression calls L<jump>. The first truthy jump succeeds.
We also give expressions access to some useful utility subs such as avg(), and all of the 
handy subs from List::Util (min, max, sum, etc..).

A very simple expression that checks if the response to s1q1 is 0 might look like:
 
 jump { value(s1q1) == 0 } target

A more complicated gotoExpression with two possible jumps might look like:

 jump { value(q1) > 5 and value(s2q1) =~ m/textmatch/ } target1;
 jump { avg(value(q1), value(q2), value(q3)) > 10 } target2;

=head3 opts (optional)

Supported options are:

=over 3

=item * values

Hashref of values to make available to the expression via the L<value> utility sub

=item * scores

Hashref of scores to make available to the expression via the L<score> utility sub

=item* validTargets

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
    ( $session, $values, $scores, $jump_count, $validate, $validTargets ) = ( $s, $opts->{values}, $opts->{scores}, 0, $opts->{validate}, $opts->{validTargets} );
    
    if (!$session->config->get('enableSurveyExpressionEngine')) {
        $session->log->debug('enableSurveyExpressionEngine config option disabled, skipping');
        return;
    }

    # Create the Safe compartment
    my $compartment = Safe->new();

    # Share our utility subs with the compartment
    $compartment->share('&value');
    $compartment->share('&score');
    $compartment->share('&jump');
    $compartment->share('&avg');
    
    # Give them all of List::Util too
    $compartment->share_from('List::Util', ['&first', '&max', '&maxstr', '&min', '&minstr', '&reduce', '&shuffle', '&sum',]);

    $session->log->debug("Expression is: \"$expression\"");
    $compartment->reval($expression);
    
    # See if we ran the engine just to check for errors
    if ($opts->{validate}) {
        if ($@ && ref $@ ne 'HASH') {
            my $error = $@;
            $error =~ s/(.*?) at .*/$1/s; # don't reveal too much
            return $error;
        }
        return; # no validation errors
    }

    # A successful jump triggers a hashref containing the jump target to be thrown
    if ( ref $@ && ref $@ eq 'HASH' && $@->{jump} ) {
        my $jump = $@->{jump};
        $session->log->debug("Returning [$jump]");
        return $jump;
    }

    # Log all other errors (for example compile errors from bad expressions)
    if ($@) {
        $session->log->error($@);
    }

    # Return undef on failure
    return;
}

1;
