
use WebGUI::Upgrade::Script;

start_step "Adding International macro alias: ^i18n(...);";

config->addToHash( 'macros', 'i18n' => 'International' );

done;

