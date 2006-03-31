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

1;
