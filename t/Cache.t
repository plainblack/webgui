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

plan tests => 11;        # Increment this number for each test you create

#----------------------------------------------------------------------------

my $cache = WebGUI::Cache->new($session, 1);
isa_ok($cache, 'WebGUI::Cache');
is($cache->parseKey("andy"), $session->config->getFilename.":andy", "parseKey single key");
is($cache->parseKey(["andy","red"]), $session->config->getFilename.":andy:red", "parseKey composite key");
$cache->set("Shawshank","Prison");
is($cache->get("Shawshank"), "Prison", "set/get");
$cache->set(["andy", "dufresne"], "Prisoner");
is($cache->get(["andy", "dufresne"]), "Prisoner", "set/get composite");
my ($a, $b) = @{$cache->mget(["Shawshank",["andy", "dufresne"]])};
is($a, "Prison", "mget first value");
is($b, "Prisoner", "mget second value");
$cache->delete("Shawshank");
is(eval{$cache->get("Shawshank")}, undef, 'delete');
$cache->flush;
is(eval{$cache->get(["andy", "dufresne"])}, undef, 'flush');
$cache->setByHttp("http://www.google.com/");
cmp_ok($cache->get("http://www.google.com/"), 'ne', '', 'setByHttp');
my $longValue ='abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%^&*(
    ';
$cache->set("really-long-value",$longValue);
is($cache->get("really-long-value"), $longValue, "set/get really long value");


#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
