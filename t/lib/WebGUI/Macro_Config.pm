package Macro_Config;

sub insert_macro {
	my ($session, $nickname, $macroName) = @_;
	my %macros = $session->config->get('macros');
	$macros{$nickname} = $macroName;
	$session->config->{_config}->set(macros => \%macros);
}

1;
