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
use Test::More tests => 6; # increment this value for each test you create

my $config     = WebGUI::Test->config;
my $configFile = WebGUI::Test->file;
my $webguiRoot = WebGUI::Test->root;

ok( defined $config, "load config" );
ok( $config->get("dsn") ne "", "get()" );
is( $config->getFilename,$configFile,"getFilename()" );
is( $config->getWebguiRoot, $webguiRoot, "getWebguiRoot()" );
ok( exists $WebGUI::Config::config{$configFile}, "loadAllConfigs" );
ok( defined WebGUI::Config->readAllConfigs($webguiRoot), "readAllConfigs" );
