use WebGUI::Upgrade::Script;

start_step "Removing mobile agent list";

config->delete('mobileUserAgents');

done;
