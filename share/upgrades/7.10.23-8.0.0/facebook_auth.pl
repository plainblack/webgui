use WebGUI::Upgrade::Script;
start_step "Add Facebook auto to the config file";
config->addToArray('authMethods', 'Facebook');
done;
