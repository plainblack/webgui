package WebGUI::Form_Checking;

use Test::MockObject;
use Test::More;
use Test::Deep;

sub auto_check {
	my ($session, $formType, %testBlock) = @_;
	my $origSessionRequest = $session->{_request};

	my $request = Test::MockObject->new;
	$request->mock('body',
		sub {
			my ($self, $value) = @_;
			return unless exists $testBlock{$value};
			if (ref $testBlock{$value}->[0] eq "ARRAY") {
				return @{ $testBlock{$value}->[0] };
			}
			else {
				return $testBlock{$value}->[0];
			}
		}
	);

	$session->{_request} = $request;

	foreach my $key (keys %testBlock) {
		my ($testValue, $expected, $comment, $dataType) = @{ $testBlock{$key} };
		$dataType ||= 'SCALAR';
		if ($dataType eq 'SCALAR') {
			my $value = $session->form->get($key, $formType);
			is($value, ($expected eq 'EQUAL' ? $testValue : $expected), $comment);
		}
		elsif ($dataType eq 'ARRAY') {
			my @value = $session->form->get($key, $formType);
			cmp_bag(\@value, ($expected eq 'EQUAL' ? $testValue : $expected), $comment);
		}
	}

	$session->{_request} = $origSessionRequest;
}

1;
