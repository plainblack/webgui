#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
# ---- END DO NOT EDIT ----

use WebGUI::Config;
use Test::More tests => 6; # increment this value for each test you create

$|=1;
my $configFile;
GetOptions(
      'configFile=s'=>\$configFile
);
exit 1 unless ($configFile);

my $config = WebGUI::Config->new("..", $configFile);

ok(defined $config, "load config");
ok($config->get("dsn") ne "", "get()");
is($config->getFilename,$configFile,"getFilename()");
is($config->getWebguiRoot, "..", "getWebguiRoot()");
WebGUI::Config->loadAllConfigs("..");
ok(exists $WebGUI::Config::config{$configFile}, "loadAllConfigs");
ok(defined WebGUI::Config->readAllConfigs(".."), "readAllConfigs");



