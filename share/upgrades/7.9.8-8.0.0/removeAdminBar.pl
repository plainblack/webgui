
use WebGUI::Upgrade::Script;


report "\tRemoving Admin Bar... ";

$session->config->delete( 'macros/AdminBar' );


done;
