use WebGUI::Upgrade::Script;

start_step "Removing show performance setting";

session->setting->remove('showPerformanceIndicators');

done;
