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

# Test how the Collaboration system gets Threads
# 
#

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $collab          = WebGUI::Test->asset->addChild({
    className       => 'WebGUI::Asset::Wobject::Collaboration',
    threadsPerPage  => 20,
});

my @threads = (
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "X - Foo",
        isSticky        => 0,
        threadRating    => 4,
    }, undef, 1, ),
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "W - Bar",
        isSticky        => 0,
        threadRating    => 2,
    }, undef, 2, ),
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "Z - Baz",
        isSticky        => 1,
        threadRating    => 6,
    }, undef, 3, ),
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "Y - Shank",
        isSticky        => 1,
        threadRating    => 5,
    }, undef, 4, ),
);

$_->setSkipNotification for @threads; # 100+ messages later...

#----------------------------------------------------------------------------
# Tests
use Data::Dumper;
plan tests => 16;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test getThreadsPaginator
#   sticky threads always come first
my ( $p, $page, $expect );

# sortBy default if nothing set in asset
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $b->get('revisionDate') <=> $a->get('revisionDate') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by asset default' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

# sortBy default if no default value in asset properties
# ( assetData.revisionDate DESC )
$session->db->write(
    'UPDATE Collaboration SET sortBy=NULL,sortOrder=NULL WHERE assetId=?',
    [$collab->getId]
);
my $collab2 = WebGUI::Asset::Wobject::Collaboration->newById( $session, $collab->getId );
$p      = $collab2->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $b->get('revisionDate') <=> $a->get('revisionDate') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by no default' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
undef $collab2;
# sortBy default from asset
$collab->update({ 
    sortBy      => 'assetData.revisionDate',
    sortOrder   => 'asc',
});
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $a->get('revisionDate') <=> $b->get('revisionDate') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by asset settings' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');
# Reset to defaults
$collab->update({ 
    sortBy      => 'assetData.revisionDate',
    sortOrder   => 'desc',
});

# sortBy set directly from scratch
$session->scratch->set($collab->getId.'_sortBy','title');
$session->scratch->set($collab->getId.'_sortDir','desc');
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $b->get('title') cmp $a->get('title') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by set directly from scratch' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

# if sortby = "rating", sort is really by "threadRating" column
$collab->update({ sortBy => "rating" });
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $b->get('threadRating') <=> $a->get('threadRating') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by rating is actually threadRating' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

# sortBy from form
$session->request->setup_param( { 'sortBy' => 'title' } );
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
### Sort order is still descending...
$expect = sortThreads( sub { $b->get('title') cmp $a->get('title') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by form sortBy' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# sortBy scratch gets set by getThreadsPaginator
is( $session->scratch->get($collab->getId.'_sortBy'), 'title', "sortBy  scratch set after form submit 1" );
is( $session->scratch->get($collab->getId.'_sortDir'), 'desc', "sortDir scratch set after form submit 1" );
# DONT RESET SORT HERE

# second sortBy from Form reverses sort
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $a->get('title') cmp $b->get('title') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by form sortBy second time reverses' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# sortBy scratch gets set by getThreadsPaginator
is( $session->scratch->get($collab->getId.'_sortBy'), 'title', "sortBy scratch set after form submit 2" );
is( $session->scratch->get($collab->getId.'_sortDir'), 'asc', "sortBy scratch set after form submit 2" );
# DONT RESET SORT HERE

# third sortBy from Form reverses sort again
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $b->get('title') cmp $a->get('title') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sort by form sortBy third time back to normal' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# sortBy scratch gets set by getThreadsPaginator
is( $session->scratch->get($collab->getId.'_sortBy'), 'title', "sortBy scratch set after form submit 3" );
is( $session->scratch->get($collab->getId.'_sortDir'), 'desc', "sortBy scratch set after form submit 3" );
# clear scratch and form to reset sorting
$session->request->setup_param({});
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

# sortBy form param doesn't change sort order when func=editSave
$session->request->setup_param({
    func        => 'editSave',
    sortBy      => 'title',
});
# Reset to defaults
$collab->update({ 
    sortBy      => 'title',
    sortOrder   => 'asc',
});
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $a->get('title') cmp $b->get('title') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sortBy form doesnt change sort order when func=editSave' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# DONT RESET SCRATCH SORTBY
$session->request->setup_param({
    func        => 'editSave',
});

# sortBy scratch gets reset when func=editSave
$p      = $collab->getThreadsPaginator;
$page   = $p->getPageData;
$expect = sortThreads( sub { $a->get('title') cmp $b->get('title') }, @threads );
cmp_deeply( $page, $expect, 'getThreadsPaginator sortBy scratch gets reset when func=editSave' )
or diag( "GOT: " . Dumper $page ), diag( "EXPECTED: " . Dumper $expect );
# clear scratch and form to reset sorting
$session->request->setup_param({});
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

#----------------------------------------------------------------------------
# sortThreads( \&sortSub, @threads )
# Sort threads according to the given subref. Return an arrayref of hashrefs
sub sortThreads { 
    my ( $sortSub, @threads ) = @_;
    return [ 
            map { # Get required info
                { 
                    assetId         => $_->getId, 
                    revisionDate    => $_->get('revisionDate'), 
                    className       => $_->get('className') 
                } 
            } 
            # Do sticky
            sort { $b->get('isSticky') cmp $a->get('isSticky') } 
            # Do requested sort
            sort $sortSub
            @threads 
          ];
}

#vim:ft=perl
