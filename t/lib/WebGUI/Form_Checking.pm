package WebGUI::Form_Checking;

use Test::More;
use Test::Deep;
use Hash::MultiValue;

sub auto_check {
	my ($session, $formType, $testBlock) = @_;

	##Create a by-name interface to the test to simplify the
	##mocked request.
	my %tests = map { $_->{key} => $_ } @{ $testBlock };
	is(scalar keys %tests, scalar @{ $testBlock }, 'no collisions in testBlock');

    my $param_hash = Hash::MultiValue->from_mixed(
        map { $_->{key} => $_->{testValue} } @{ $testBlock }
    );
    local $session->request->env->{'plack.request.query'} = $param_hash;
    local $session->request->env->{'plack.request.body'} = $param_hash;
    local $session->request->env->{'plack.request.merged'} = $param_hash;

	foreach my $test ( @{ $testBlock } ) {
		$test->{dataType} ||= 'SCALAR';
		$test->{expected} = $test->{testValue} if $test->{expected} eq 'EQUAL';
		if ($test->{dataType} eq 'SCALAR') {
			my $value = $session->form->get($test->{key}, $formType);
			is($value, $test->{expected}, $test->{comment});
		}
		elsif ($test->{dataType} eq 'ARRAY') {
			my @value = $session->form->get($test->{key}, $formType);
			cmp_bag(\@value, $test->{expected}, $test->{comment});
		}
	}
}



#######################################################################

=head2 get_request

!!! TODO !!!

Gets a Test::MockObject to be given to the session object that will allow for
processing of form parameters. 

This will be easier to manage, as you won't have
to make multiple forms for elements that can return differently formatted data
based on configuration.

Usage:

 my $old_request = $session->{_request};
 
 my $request = WebGUI::Form_Checking::get_request($session,$value);
 # $value can be either a scalar value or an array reference
 $session->{_request} = $request;
 
 # Test the value here
 # Maybe make more mock request objects and test more values
 
 # Reset the session back
 $session->{_request} = $old_session;

=cut

sub get_request
{
	warn "WebGUI::Form_Checking::get_request is still TODO!";
}



1;
