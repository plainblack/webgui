use 5.010;
use strict;
use warnings;

use Test::More tests => 2;                      # last test to print
use WebGUI::Paths;

can_ok 'WebGUI::Paths', qw(CONFIG_BASE LOG_CONFIG SPECTRE_CONFIG UPGRADES_PATH PRELOAD_CUSTOM PRELOAD_EXCLUSIONS EXTRAS DEFAULT_UPLOADS DEFAULT_SQL);
ok !(grep { WebGUI::Paths->can($_) }
    qw(croak realpath catdir splitpath catpath splitpath updir catfile try catch _readTextLines)),
    'Internal functions cleaned up';

my @configs = WebGUI::Paths->siteConfigs;
ok !(\@configs ~~ WebGUI::Paths->SPECTRE_CONFIG), 'Spectre config not listed in configs';

