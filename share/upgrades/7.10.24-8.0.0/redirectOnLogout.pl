use WebGUI::Upgrade::Script;
start_step "Adding Redirect After Logout setting";
session->setting->add('redirectAfterLogoutUrl');
done;
