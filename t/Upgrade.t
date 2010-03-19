use strict;
use warnings;
no warnings 'redefine';

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test import => [qw(collateral)];
use Test::More;

use Test::MockObject;
use Test::MockObject::Extends;

BEGIN {
    $INC{'WebGUI.pm'} = 1;
    $WebGUI::VERSION = '8.4.3';
}

use WebGUI::Paths;
use WebGUI::Upgrade;
use Try::Tiny;
use Capture::Tiny qw(capture);
use mro;

my $configFile = WebGUI::Test->config->getFilename;
local *WebGUI::Paths::siteConfigs = sub { $configFile };

my $upgrade = Test::MockObject::Extends->new('WebGUI::Upgrade');
$upgrade->set_always('getCurrentVersion', '8.0.0');

local *WebGUI::Paths::upgrades = sub { collateral('upgrades', 'impossible') } ;

ok ! try { $upgrade->calcUpgradePath('8.0.0', '8.4.3'); 1 }, 'calcUpgradePath dies when unable to find a path';

*WebGUI::Paths::upgrades = sub { collateral('upgrades', 'backtrack') } ;

is_deeply [$upgrade->calcUpgradePath('8.0.0', '8.4.3')], [qw(8.0.0-8.1.0 8.1.0-8.2.0 8.2.0-8.3.0 8.3.0-8.4.3)], 'calcUpgradePath finds correct path with backtracking';

*WebGUI::Paths::upgrades = sub { collateral('upgrades', 'valid') } ;

$upgrade->set_true('runUpgradeFile');

my $res;
my ($stdout, $stderr) = capture {
    $res = $upgrade->upgradeSites;
};

ok $res, 'upgradeSites runs';

$upgrade->called_pos_ok(1, 'getCurrentVersion');
$upgrade->called_pos_ok(2, 'runUpgradeFile');
my $upgradeFile = $upgrade->call_args_pos(2, 4);
ok $upgradeFile =~ /\b00_simple\.pl$/, 'correct upgrade file run';
$upgrade->clear;

$upgrade->unmock('runUpgradeFile');

($stdout, $stderr) = capture {
    $upgrade->runUpgradeFile($configFile, '8.3.0', collateral('upgrades', 'output.pl'));
};

ok $stdout =~ 'Simple Output', 'report command functions correctly';
ok $stdout =~ 'Done', 'done command functions correctly';

($stdout, $stderr) = capture {
    $upgrade->runUpgradeFile($configFile, '8.3.0', collateral('upgrades', 'output.pl'), 1);
};

ok $stdout !~ 'Simple Output', 'quiet flag silences report command';
ok $stdout !~ 'Done', 'quiet flag silences done command';

capture {
    try {
        $upgrade->runUpgradeFile($configFile, '8.3.0', collateral('upgrades', 'die.pl'), 1);
        fail 'Error on failing upgrade';
    }
    catch {
        pass 'Error on failing upgrade';
    };
};

capture {
    try {
        $upgrade->runUpgradeFile($configFile, '8.3.0', collateral('upgrades', 'strict-failure.pl'), 1);
        fail 'strict enabled in upgrades';
    }
    catch {
        pass 'strict enabled in upgrades';
    };
};

done_testing;

