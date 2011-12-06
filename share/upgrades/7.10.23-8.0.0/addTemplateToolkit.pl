
use WebGUI::Upgrade::Script;

start_step "Adding Template Toolkit template parser";

my $class = 'WebGUI::Asset::Template::TemplateToolkit';
unless ( grep { $_ eq $class } @{ session->config->get('templateParsers') } ) {
    config->addToArray( 'templateParsers' => $class );
}

done;

