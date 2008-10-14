# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use lib "$FindBin::Bin/../lib";
use Storable qw(freeze thaw);
use Test::More;
use Time::HiRes;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Cache::Database;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# presupposes that there are cached items to test
my $cacheEntries = $session->db->buildArrayRefOfHashRefs("select expires,cachekey,namespace,content from cache order by rand() limit 100");

#----------------------------------------------------------------------------
# Tests

plan tests => 2 + scalar(@{$cacheEntries});        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $cache = WebGUI::Cache::Database->new($session, "this", "that");
my $testValue = "a rock that has no earthly business in that field";

$cache->set($testValue);
is($cache->get, $testValue, "set/get works");
$cache->delete;
is($cache->get, undef, "delete works");



# performance tests
my $numTests = 0;
my $totalTime = 0;
foreach my $entry (@{$cacheEntries}) {
    my $start = [Time::HiRes::gettimeofday];
    my $cache = WebGUI::Cache::Database->new($session, $entry->{cachekey}, $entry->{namespace});
    $cache->{_key} = $entry->{cachekey}; # evil: don't do this at home kids
    my $value = $cache->get; 
    if ($entry->{expires} > time()) {
        my $entryValue = $entry->{content};
        eval { $entryValue = thaw($entryValue); };
        $entryValue = ($entryValue && ref $entryValue) ? $$entryValue : undef;
        is_deeply($value, $entryValue, "cache entry is valid");
    } 
    else {
        is($value, undef, "cache entry has timed out");
    }
    $numTests++;
    $totalTime += Time::HiRes::tv_interval($start);
}
print "\nTime to run $numTests cache tests is $totalTime seconds. Average time per test is ".($totalTime/$numTests)." seconds.\n" if ($numTests > 0);
# end performance tests


#----------------------------------------------------------------------------
# Cleanup
END {

}
