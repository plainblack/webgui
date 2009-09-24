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
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Path::Class;
use File::Path;
use File::Basename qw(basename);

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Cache;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $tests  = 14;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $origCacheType = $session->config->get('cacheType');
$session->config->set('cacheType', 'WebGUI::Cache::FileCache');

my $origCacheRoot = $session->config->get('fileCacheRoot');
$session->config->delete('fileCacheRoot');

my $loaded = use_ok('WebGUI::Cache::FileCache');

SKIP: {

    skip 'Unable to load module WebGUI::Cache::FileCache', $tests unless $loaded;

    my $cacher = WebGUI::Cache->new($session, 'ReservedForTests');

    isa_ok($cacher, 'WebGUI::Cache::FileCache', 'WebGUI::Cache creates the correct object type');
    isa_ok($cacher->session, 'WebGUI::Session', 'session method returns a session object');

    cmp_deeply(
        $cacher,
        noclass({
            _session   => ignore(),
            _namespace => basename(WebGUI::Test->file),
            _key       => re('[a-zA-Z0-9+\-]{22}'),
        }),
        'New FileCache object has correct defaults',
    );

    $cacher = WebGUI::Cache->new($session, 'ReservedForTests', 'ReservedForTests');

    cmp_deeply(
        $cacher,
        noclass({
            _session   => ignore(),
            _namespace => 'ReservedForTests',
            _key       => re('[a-zA-Z0-9+\-]{22}'),
        }),
        'Second fileCache object was recreated with custom namespace',
    );

    my $root = '/tmp'; ##Default for Unix testing.  Need to extend this for Windows someday...
    my $namespace = Path::Class::Dir->new($root, qw/WebGUICache ReservedForTests/);
    is($cacher->getNamespaceRoot, $namespace->stringify, 'getNamespaceRoot returns the correct path');

    ok(! -e $cacher->getNamespaceRoot, 'The namespace does not exist in the filesystem');

    my $folder = $namespace->subdir($cacher->{_key});
    is($cacher->getFolder, $folder->stringify, 'getFolder returns the correct path, which is the namespace with a key subdirectory');
    ok(! -e $cacher->getFolder, 'The folder does not exist in the filesystem');

    $cacher->set('Some value');
    ok( -e $namespace->stringify,               'setting data into the cache creates the namespace dir');
    ok( -e $folder->stringify,                  'setting data into the cache creates the folder dir');
    ok( -e $folder->file('expires')->stringify, 'expiry file was created');
    ok( -e $folder->file('cache')->stringify,   'cache file was created');

    $cacher->delete();
    ok(! -e $cacher->getFolder, 'delete removes the cache folder');

    $cacher->flush();
    ok(! -e $cacher->getNamespaceRoot, 'purge removes the namespace folder');

    undef $cacher;

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->config->set('cacheType', $origCacheType);
    if ($origCacheRoot) {
        $session->config->get('fileCacheRoot', $origCacheRoot);
    }
}
