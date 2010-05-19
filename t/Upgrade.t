use strict;
use warnings;
no warnings 'redefine';

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test import => [qw(collateral addToCleanup)];
use Test::More;

use Test::MockObject;
use Test::MockObject::Extends;
use File::Temp;
use File::Path qw(make_path);

use WebGUI::Paths;
use WebGUI::Upgrade;
use WebGUI::Session::Id;
use WebGUI::VersionTag;
use Try::Tiny;
use Capture::Tiny qw(capture);

local *WebGUI::Paths::siteConfigs;
local *WebGUI::Paths::upgrades;

our $configFile = WebGUI::Test->config->getFilename;
{
    no warnings 'redefine';
    *WebGUI::Paths::siteConfigs = sub { $configFile };
}

my $upgrade = Test::MockObject::Extends->new(
    WebGUI::Upgrade->new(
        createBackups => 0,
        useMaintenanceMode => 0,
    ),
);
$upgrade->set_always('getCurrentVersion', '8.0.0');
$upgrade->set_always('getCodeVersion', '8.4.3');
$upgrade->set_true('markVersionUpgrade');

{
    no warnings 'redefine';
    *WebGUI::Paths::upgrades = sub { collateral('Upgrade', 'non-existant') } ;
}
ok ! try { $upgrade->calcUpgradePath('8.0.0', '8.4.3'); 1 }, "calcUpgradePath dies when upgrades path doesn't exist";

{
    no warnings 'redefine';
    *WebGUI::Paths::upgrades = sub { collateral('Upgrade', 'impossible') } ;
}
ok ! try { $upgrade->calcUpgradePath('8.0.0', '8.4.3'); 1 }, 'calcUpgradePath dies when unable to find a path';

{
    no warnings 'redefine';
    *WebGUI::Paths::upgrades = sub { collateral('Upgrade', 'backtrack') } ;
}
is_deeply
    [ $upgrade->calcUpgradePath('8.0.0', '8.4.3') ],
    [qw( 8.0.0-8.1.0 8.1.0-8.2.0 8.2.0-8.3.0 8.3.0-8.4.3 )],
    'calcUpgradePath finds correct path with backtracking';

{
    no warnings 'redefine';
    *WebGUI::Paths::upgrades = sub { collateral('Upgrade', 'valid') } ;
}
$upgrade->set_true('runUpgradeFile');

capture {
    my $res = $upgrade->upgradeSites;
    ok $res, 'upgradeSites runs';
};

$upgrade->called_pos_ok(1, 'getCurrentVersion');
$upgrade->called_pos_ok(2, 'getCodeVersion');
SKIP: {
    $upgrade->called_pos_ok(4, 'runUpgradeFile') || skip 'upgrade not run', 1;
    my $upgradeFile = $upgrade->call_args_pos(4, 4);
    ok $upgradeFile =~ /\b00_simple\.pl$/, 'correct upgrade file run';
}

$upgrade->clear;
$upgrade->unmock('runUpgradeFile');

$upgrade->mock(testUpgrade => sub {
    my $self = shift;
    my $file = shift;
    $self->runUpgradeFile($configFile, '8.3.0', collateral('Upgrade', $file), @_);
});

{
    my $stdout = capture { eval {
        $upgrade->testUpgrade('output.pl');
    } };
    ok $stdout =~ 'Simple Output', 'report command functions correctly';
    ok $stdout =~ 'Done', 'done command functions correctly';
}

{
    $upgrade->quiet(1);
    my $stdout = capture { eval { $upgrade->testUpgrade('output.pl') } };
    ok $stdout !~ 'Simple Output', 'quiet flag silences report command';
    ok $stdout !~ 'Done', 'quiet flag silences done command';
}

ok !try { $upgrade->testUpgrade('die.pl'); 1 }, 'Error on failing upgrade';
ok !try { $upgrade->testUpgrade('strict-failure.pl'); 1 }, 'strict enabled in upgrades';

my $session = WebGUI::Test->session;

my $dbh = $upgrade->dbhForConfig(WebGUI::Test->config);
our $totalAssets = $dbh->selectrow_array('SELECT COUNT(*) FROM asset');

$upgrade->testUpgrade('dbh.pl');

$upgrade->testUpgrade('config.pl');

{
    my $sId = $upgrade->testUpgrade('session.pl');

    ok +WebGUI::Session::Id->valid($sId), 'valid session id generated';
    my $hasSession = $dbh->selectrow_array('SELECT COUNT(*) FROM userSession WHERE sessionId = ?', {}, $sId);
    ok !$hasSession, 'session properly closed';
}

{
    my $vt = $upgrade->testUpgrade('versiontag-implicit.pl');
    ok $vt->get('isCommitted'), 'implicit version tag committed';
    is $vt->get('name'), 'Upgrade to 8.3.0 - versiontag-implicit', 'implicit version tag named correctly';
}

$upgrade->testUpgrade('versiontag.pl');
$upgrade->testUpgrade('collateral.pl');
$upgrade->testUpgrade('package.pl');

{
    my $temp = File::Temp->newdir;
    local @INC = @INC;
    my @modules;
    for (1..2) {
        my $lib_dir = File::Spec->catdir($temp, 'lib' . $_);
        unshift @INC, $lib_dir;
        my $mod_dir = File::Spec->catdir($lib_dir, 'WebGUI', 'Upgrade', 'Test');
        my $module = File::Spec->catfile($mod_dir, 'Module.pm');
        push @modules, $module;
        make_path($mod_dir);
        open my $fh, '>', $module;
        print {$fh} <<'END_PM';
package WebGUI::Upgrade::Test::Module;

1;
END_PM
        close $fh;
    }

    $upgrade->testUpgrade('rmlib.pl');

    ok !(grep { -e } @modules), 'all libraries removed correctly';
}

{
    my $package = $upgrade->testUpgrade('test-template.wgpkg');
    isa_ok $package, 'WebGUI::Asset::Template';
    my $vtId = $package->get('tagId');
    my $vt = WebGUI::VersionTag->new($session, $vtId);
    addToCleanup($vt);
    is $vt->get('name'), 'Upgrade to 8.3.0 - test-template', 'package import names version tag correctly';
}

{
    my $stdout = capture { eval {
        $upgrade->testUpgrade('select.sql');
    } };
    my @lines = split /[\r\n]+/, $stdout;
    my $dateApplied = $lines[1];

    my $dbdateApplied = $dbh->selectrow_array('SELECT dateApplied FROM webguiVersion ORDER BY dateApplied DESC LIMIT 1');
    is $dateApplied, $dbdateApplied, 'SQL script run against database properly';
}

done_testing;

