
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

# Test the getAdjacentThread (getNextThread and getPreviousThread)
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my @versionTags     = ( WebGUI::VersionTag->getWorking( $session ) );
my @addChildArgs    = ( {skipAutoCommitWorkflows=>1} );
my $collab          = WebGUI::Asset->getImportNode( $session )->addChild({
    className       => 'WebGUI::Asset::Wobject::Collaboration',
    threadsPerPage  => 20,
});

my @threads = (
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "X - Foo",
        isSticky        => 0,
        threadRating    => 4,
    }, undef, 1, @addChildArgs),
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "W - Bar",
        isSticky        => 0,
        threadRating    => 2,
    }, undef, 2,  @addChildArgs),
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "Z - Baz",
        isSticky        => 1,
        threadRating    => 6,
    }, undef, 3, @addChildArgs),
    $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "Y - Shank",
        isSticky        => 1,
        threadRating    => 5,
    }, undef, 4, @addChildArgs),
);

$_->setSkipNotification for @threads; 
$versionTags[-1]->commit;
WebGUI::Test->addToCleanup($versionTags[-1]);
foreach my $asset(@threads, $collab) {
    $asset = $asset->cloneFromDb;
}

#----------------------------------------------------------------------------
# Tests

plan tests => 50;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test get adjacent threads
#   sticky threads always come first
my ( $sort );

# sortBy default if nothing set in asset
$sort = sub { $b->get('revisionDate') <=> $a->get('revisionDate') };
testGetAdjacentThread( "default sort", $sort, [ qw( 3 2 1 0 ) ], @threads );

# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

# sortBy default if no default value in asset properties
SKIP: {
    skip "This works in Collaboration->getThreadsPaginator. Old code that can be excised?", 8;
    # ( assetData.revisionDate DESC )
    $session->db->write(
        'UPDATE Collaboration SET sortBy=NULL,sortOrder=NULL WHERE assetId=?',
        [$collab->getId]
    );
    my $collab2 = WebGUI::Asset::Wobject::Collaboration->new( $session, $collab->getId );
    $sort = sub { $b->get('revisionDate') <=> $a->get('revisionDate') };
    testGetAdjacentThread( "no sort set in Collab props", $sort, [ qw( 3 2 1 0 ) ], @threads );
    undef $collab2;
}

# sortBy default from asset
$collab->update({ 
    sortBy      => 'assetData.revisionDate',
    sortOrder   => 'asc',
});
$sort = sub { $a->get('revisionDate') <=> $b->get('revisionDate') };
testGetAdjacentThread( "sort by default from asset", $sort, [ qw( 0 1 2 3 ) ], @threads );
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
$sort = sub { $b->get('title') cmp $a->get('title') };
testGetAdjacentThread( "sort by set from scratch", $sort, [ qw( 2 3 0 1 ) ], @threads );
# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

# if sortby = "rating", sort is really by "threadRating" column
$collab->update({ sortBy => "rating" });
$sort = sub { $b->get('threadRating') <=> $a->get('threadRating') };
testGetAdjacentThread( "sort by rating is threadRating", $sort, [ qw( 2 3 0 1 ) ], @threads );
# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

# getAdjacentThread checks for version tags
$collab->update({ 
    sortBy      => 'assetData.revisionDate',
    sortOrder   => 'desc',
});
push @versionTags, WebGUI::VersionTag->getWorking( $session );
WebGUI::Test->addToCleanup($versionTags[-1]);
push @threads, $collab->addChild( {
        className       => 'WebGUI::Asset::Post::Thread',
        title           => "Abababa",
        isSticky        => 0,
        threadRating    => 1_000_000,
    }, undef, 6, @addChildArgs
);
$sort = sub { $b->get('revisionDate') <=> $a->get('revisionDate') };
testGetAdjacentThread( "sort by default from asset with version tag", $sort, [ qw( 4 3 2 1 0 ) ], @threads );
# clear scratch to reset sort
$session->scratch->delete($collab->getId.'_sortBy');
$session->scratch->delete($collab->getId.'_sortDir');

#----------------------------------------------------------------------------
# testGetAdjacentThread ( label, sort, order, @threads )
# Performs two tests for each thread in [order]
# Label = a label for the test (usually the sort order)
# Sort = a subroutine to pass to sortThreads
# Order = An array ref of indexes from @threads in the correct order
# @threads = all the threads
sub testGetAdjacentThread {
    my ( $label, $sort, $order, @threads ) = @_;

    my $idxFirst    = shift @{$order};
    my $idxLast     = pop @{$order};

    # First
    is( $threads[$idxFirst]->getNextThread->getId, 
        getNextThread( $sort, $threads[$idxFirst], @threads )->getId,
        "$label: Get Next Thread (first)"
    );
    is( $threads[$idxFirst]->getPreviousThread, 
        undef,
        "$label: Get Previous Thread (first)"
    );

    # Middle
    for my $i ( 1..@{$order} ) {
        my $thread = $threads[ $order->[$i-1] ];
        is( $thread->getNextThread->getId, 
            getNextThread( $sort, $thread, @threads )->getId,
            "$label: Get Next Thread (" . ($i+1) . ")"
        );
        is( $thread->getPreviousThread->getId, 
            getPreviousThread( $sort, $thread, @threads )->getId,
            "$label: Get Previous Thread (" . ($i+1) . ")"
        );
    }

    # Last
    is( $threads[$idxLast]->getNextThread,
        undef,
        "$label: Get Next Thread (last)"
    );
    is( $threads[$idxLast]->getPreviousThread->getId, 
        getPreviousThread( $sort, $threads[$idxLast], @threads )->getId,
        "$label: Get Previous Thread (last)"
    );

    # Delete internal caches so that tests don't fail mysteriously
    for ( @threads ) { delete $_->{_next}; delete $_->{_previous}; delete $_->{_parent} }
}

#----------------------------------------------------------------------------
# sortThreads( \&sortSub, @threads )
# Sort threads according to the given subref. Return an arrayref of hashrefs
sub sortThreads { 
    my ( $sortSub, @threads ) = @_;
    my $sorted = [ 
            # Threads don't do sticky!
            #sort { $b->get('isSticky') cmp $a->get('isSticky') } 
            # Do requested sort
            sort $sortSub
            @threads 
          ];
    return $sorted;
}

sub getNextThread {
    my ( $sortSub, $thread, @threads ) = @_;
    my @sorted  = @{ sortThreads( $sortSub, @threads ) };

    for my $i ( 0..$#sorted ) {
        if ( $sorted[$i]->getId eq $thread->getId ) {
            return $sorted[$i+1];
        }
    }
}

sub getPreviousThread {
    my ( $sortSub, $thread, @threads ) = @_;
    # Use reverse so that $i-1 != -1 (which gets us the last thread)
    my @sorted  = reverse @{ sortThreads( $sortSub, @threads ) };

    for my $i ( 0..$#sorted ) {
        if ( $sorted[$i]->getId eq $thread->getId ) {
            return $sorted[$i+1];
        }
    }
}
