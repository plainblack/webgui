use WebGUI::Upgrade::Script;

start_step "Removing URL Handlers from WebGUI Configuration files";

config->delete( 'urlHandlers' );

done;

