
use WebGUI::Upgrade::Script;

report "\tAdding International macro alias: ^i18n(...);";

session->config->addToHash( 'macros', 'i18n' => 'International' );

done;

