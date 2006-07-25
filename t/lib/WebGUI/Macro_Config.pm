package WebGUI::Macro_Config;

sub enable_macro {
	my ($session, $nickname, $macroName) = @_;
	my %macros = %{ $session->config->get('macros') };
	return '' if $macros{$nickname};
	$session->config->addToHash("macros", $nickname, $macroName);
	return $nickname;
}

1;
