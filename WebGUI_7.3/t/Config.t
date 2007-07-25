#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

my $config     = WebGUI::Test->config;
my $configFile = WebGUI::Test->file;
my $webguiRoot = WebGUI::Test->root;

ok( defined $config, "load config" );
ok( $config->get("dsn") ne "", "get()" );
is( ref $config->get("macros"), "HASH", "get() hash" );
is( ref $config->get("assets"), "ARRAY", "get() array" );
is( $config->getFilename,$configFile,"getFilename()" );
is( $config->getWebguiRoot, $webguiRoot, "getWebguiRoot()" );
ok( exists $WebGUI::Config::config{$configFile}, "loadAllConfigs" );
ok( defined WebGUI::Config->readAllConfigs($webguiRoot), "readAllConfigs" );
$config->addToArray("assets","TEST");
my $found = 0;
foreach my $asset ( @{$config->get("assets")}) {
	$found = 1 if ($asset eq "TEST");
}
ok($found, "addToArray()");
$config->deleteFromArray("assets","TEST");
my $found = 0;
foreach my $asset ( @{$config->get("assets")}) {
	$found = 1 if ($asset eq "TEST");
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

	foreach my $assetClass (@{$config->get('assets')}, @{$config->get('assetContainers')},
				@{$config->get('utilityAssets')}) {
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

END: {
    $config->delete('privateArray');
}
