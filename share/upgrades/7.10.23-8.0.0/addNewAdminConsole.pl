
use WebGUI::Upgrade::Script;
use List::MoreUtils qw( any );

start_step "Adding new Admin Console";

session->config->addToArrayAfter(
    'contentHandlers', 'WebGUI::Content::Referral', 'WebGUI::Content::Admin'
);

# Remove irrelevant Admin Console items
session->config->deleteFromHash( 'adminConsole', 'adminConsoleOff' );
session->config->deleteFromHash( 'adminConsole', 'assets' );

# Remove old admin handlers
session->config->deleteFromArray( 'contentHandlers', 'WebGUI::Content::AssetManager' );

# Add template setting
session->setting->set( 'templateIdAdmin' => 'p8g7xlQaTeKSRRDo-_ejSQ' );

done;
