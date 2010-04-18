use strict;
use Plack::Builder;
use WebGUI::Paths -preload;
use WebGUI::Config;

builder {
    my $first_app;
    for my $config_file (WebGUI::Paths->siteConfigs) {
        my $config = WebGUI::Config->new($config_file);
        my $psgi = $config->get('psgiFile') || WebGUI::Paths->defaultPSGI;
        my $app = do {
            $ENV{WEBGUI_CONFIG} = $config_file;
            Plack::Util::load_psgi($psgi);
        };
        $first_app ||= $app;
        for my $sitename ( @{ $config->get('sitename') } ) {
            mount "http://$sitename/" => $app;
        }
    }
    mount '/' => $first_app;
};

