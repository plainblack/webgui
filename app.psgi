
=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Plack::Builder;
use Plack::Util;

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

