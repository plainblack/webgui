
use strict;
use Plack::Builder;

use FindBin;
use lib "$FindBin::Bin/lib";

use WebGUI::Paths -inc;
use WebGUI::Config;
use WebGUI::Fork;

if ($ENV{PLACK_ENV} ne 'development') {
    WebGUI::Paths->preloadAll;
}

WebGUI::Fork->init();

builder {
    my $first_app;
    WebGUI::Paths->siteConfigs or die "no configuration files found";
    for my $config_file (WebGUI::Paths->siteConfigs) {
        my $config = WebGUI::Config->new($config_file) or die "failed to log configuration file: $config_file: $!";
        my $psgi = $config->get('psgiFile') || WebGUI::Paths->defaultPSGI;
        my $app = do {
            # default psgi file uses environment variable to find config file
            local $ENV{WEBGUI_CONFIG} = $config_file;
            Plack::Util::load_psgi($psgi);
        } or die;
        $first_app ||= $app;
        my $gateway = $config->get('gateway');
        $gateway =~ s{^/?}{/};
        for my $sitename ( @{ $config->get('sitename') } ) {
            mount "http://$sitename$gateway" => $app;
        }
    }

    # use the first config found as a fallback
    mount '/' => $first_app;
};

