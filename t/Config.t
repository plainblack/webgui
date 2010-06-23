#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use Test::More tests => 15; # increment this value for each test you create
use Test::Deep;
use File::Basename qw(basename);
use Cwd;

my $config     = WebGUI::Test->config;
my $configFile = WebGUI::Test->file;
my $webguiRoot = WebGUI::Test->root;

ok( defined $config, "load config" );
ok( $config->get("dsn") ne "", "get()" );
is( ref $config->get("macros"), "HASH", "get() macros hash" );
is( ref $config->get("assets"), "HASH", "get() assets hash" );
is( ref $config->get("shippingDrivers"), "ARRAY", "get() shippingDrivers array" );
is( $config->getFilename, basename($configFile), "getFilename()" );
is( $config->getWebguiRoot, Cwd::realpath($webguiRoot), "getWebguiRoot()" );
ok( defined WebGUI::Config->readAllConfigs($webguiRoot), "readAllConfigs" );
$config->addToArray("shippingDrivers","TEST");
my $found = 0;
foreach my $driver ( @{$config->get("shippingDrivers")}) {
	$found = 1 if ($driver eq "TEST");
}
ok($found, "addToArray()");
$config->deleteFromArray("shippingDrivers","TEST");
my $found = 0;
foreach my $driver ( @{$config->get("shippingDrivers")}) {
	$found = 1 if ($driver eq "TEST");
}
ok(!$found, "deleteFromArray()");
$config->addToHash("macros","TEST","VALUE");
my $found = 0;
foreach my $macro (keys %{$config->get("macros")}) {
	$found = 1 if ($macro eq "TEST" && $config->get("macros")->{$macro} eq "VALUE");
}
ok($found, "addToHash()");
$config->deleteFromHash("macros","TEST");
my $found = 0;
foreach my $macro (keys %{$config->get("macros")}) {
	$found = 1 if ($macro eq "TEST");
}
ok(!$found, "deleteFromHash()");
my $cookieName = $config->get("cookieName");
if ($cookieName eq "") {
	is($config->getCookieName,"wgSession", "getCookieName()");
} else {
	is($config->getCookieName,$cookieName, "getCookieName()");
}

{
	my $ok = 1;

	foreach my $assetClass (keys %{$config->get('assets')}) {
		unless ($assetClass =~ /\A(?:[A-Za-z0-9_]+::)*[A-Za-z0-9_]+\z/) {
			diag "$assetClass is not a valid class name";
			$ok = 0; next;
		}

		eval "require $assetClass";
		if ($@) {
			diag "$assetClass could not be loaded: $@";
			$ok = 0; next;
		}
		
		unless ($assetClass->isa('WebGUI::Asset')) {
			diag "$assetClass is not a subclass of WebGUI::Asset";
			$ok = 0; next;
		}
	}

	ok($ok, "asset classes are all valid asset classes");
}

$config->set('privateArray', ['a', 'b', 'c']);
cmp_bag($config->get('privateArray'), ['a', 'b', 'c'], 'set: array, not scalar');

END {
    $config->delete('privateArray');
}
