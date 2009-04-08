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
my $vars;
my $jump_count;
my $validate;
my $validTargets;
 
=head2 var

Utility sub shared with Safe compartment so that expressions can access allowed vars.

=cut

sub var($) {
    my $key   = shift;
    my $value = $vars->{$key};
    $session->log->debug("[$key] resolves to [$value]");
    return $value; # scalar variable, so no need to clone
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

Utility sub shared with Safe compartment to allows expressions to easily compute the average
of a number of values

=cut

sub avg {
    my @vals = @_;
    return sum(@vals) / @vals;
}

=head2 run ( $session, $expression, $opts )

Class method.

Evaluates the given expression in a Safe compartment, giving the expression access to vars.

=head3 session

A WebGUI::Session

=head3 expression

The expression to run. 

A gotoExpression is essentially a perl expression that gets evaluated in a Safe compartment.

To access Section/Question response values, the expression calls L<var>.
To trigger a jump, the expression calls L<jump>. The first truthy jump succeeds.
We also give expressions access to some useful utility subs such as avg(), and all of the 
handy subs from List::Util (min, max, sum, etc..).

A very simple expression that checks if the response to s1q1 is 0 might look like:
 
 jump { var(s1q1) == 0 } target

A more complicated gotoExpression with two possible jumps might look like:

 jump { var('my_var') > 5 and var('my_var2') =~ m/textmatch/ } target1;
 jump { $avg = (var(q1) + var(q2) + var(q3)) / 3; return $avg > 10 } target2;

=head3 opts (optional)

Supported options are:

=over 3

=item * vars

Hashref of vars to make available to the expression via the L<var> utility sub

=item * validate

Return errors rather than just logging them (useful for displaying survey validation errors to users)  

=back

=cut

sub run {
    my $class = shift;
    my ( $s, $expression, $opts )
        = validate_pos( @_, { isa => 'WebGUI::Session' }, { type => SCALAR }, { type => HASHREF, default => {} } );

    # Init package globals
    ( $session, $vars, $jump_count, $validate, $validTargets ) = ( $s, $opts->{vars}, 0, $opts->{validate}, $opts->{validTargets} );

    # Create the Safe compartment
    my $compartment = Safe->new();

    # Share our utility subs with the compartment
    $compartment->share('&var');
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
