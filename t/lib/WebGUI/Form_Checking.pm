package WebGUI::Form_Checking;

use Test::MockObject;
use Test::More;

sub auto_check {
	my ($session, $formType, %testBlock) = @_;
	my $origSessionRequest = $session->{_request};

	my $request = Test::MockObject->new;
	$request->mock('body',
		sub {
			my ($self, $value) = @_;
			return $testBlock{$value}->[0] if (exists $testBlock{$value});
			return;
		}
	);

	$session->{_request} = $request;

	foreach my $key (keys %testBlock) {
		my ($testValue, $expected, $comment) = @{ $testBlock{$key} };
		my $value = $session->form->get($key, $formType);
		is($value, ($expected eq 'EQUAL' ? $testValue : $expected), $comment);
	}

	$session->{_request} = $origSessionRequest;
}

1;
