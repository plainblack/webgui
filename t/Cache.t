# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Cache;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------

my $cache = WebGUI::Cache->new($session);
isa_ok($cache, 'WebGUI::Cache');
is($cache->parseKey("andy"), $session->config->getFilename.":andy", "parseKey single key");
is($cache->parseKey(["andy","red"]), $session->config->getFilename.":andy:red", "parseKey composite key");




#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
