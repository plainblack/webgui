use 5.010;
use strict;
use warnings;

use Test::More;
use WebGUI::Paths;

my @pathMethods = qw(
    configBase
    logConfig
    spectreConfig
    preloadCustom
    preloadExclusions
    upgrades
    extras
    defaultUploads
    defaultCreateSQL
    share
);
can_ok 'WebGUI::Paths', @pathMethods;

ok !(grep { WebGUI::Paths->can($_) } qw(
    croak
    realpath
    catdir
    splitpath
    catpath
    splitpath
    updir
    catfile
    try
    catch
    _readTextLines
    subname
)), 'Internal functions cleaned up';

my @configs = WebGUI::Paths->siteConfigs;
ok !(\@configs ~~ WebGUI::Paths->spectreConfig), 'Spectre config not listed in configs';

for my $method (@pathMethods) {
    my $return = WebGUI::Paths->$method;
    ok $return, "$method returns a path";
}

done_testing;

