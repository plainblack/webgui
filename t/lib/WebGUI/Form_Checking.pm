package WebGUI::Form_Checking;

use Test::MockObject;
use Test::More;
use Test::Deep;

sub auto_check {
	my ($session, $formType, $testBlock) = @_;
	my $origSessionRequest = $session->{_request};

	##Create a by-name interface to the test to simplify the
	##mocked request.
	my %tests = map { $_->{key} => $_ } @{ $testBlock };
	is(scalar keys %tests, scalar @{ $testBlock }, 'no collisions in testBlock');

	my $request = Test::MockObject->new;
	$request->mock('body',
		sub {
			my ($self, $value) = @_;
			return unless exists $tests{$value};
			if (ref $tests{$value}->{testValue} eq "ARRAY") {
				return @{ $tests{$value}->{testValue} } ;
			}
			else {
				return $tests{$value}->{testValue};
			}
		}
	);
    $request->mock('param', sub {shift->body(@_)});

	$session->{_request} = $request;

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

	$session->{_request} = $origSessionRequest;
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
