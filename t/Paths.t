use 5.010;
use strict;
use warnings;

use Test::More tests => 2;                      # last test to print
use WebGUI::Paths;

can_ok 'WebGUI::Paths', qw(configBase logConfig spectreConfig upgradesPath preloadCustom preloadExclusions extras defaultUploads defaultCreateSQL);
ok !(grep { WebGUI::Paths->can($_) }
    qw(croak realpath catdir splitpath catpath splitpath updir catfile try catch _readTextLines subname)),
    'Internal functions cleaned up';

my @configs = WebGUI::Paths->siteConfigs;
ok !(\@configs ~~ WebGUI::Paths->spectreConfig), 'Spectre config not listed in configs';

