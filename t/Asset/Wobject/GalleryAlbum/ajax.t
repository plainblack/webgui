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
use lib "$FindBin::Bin/../../../lib";

## The goal of this test is to test the creation and deletion of album assets

use JSON;
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);

my %user;
$user{'1'} = WebGUI::User->new( $session, "new" );
$user{'1'}->addToGroups( ['3'] ); # Admins
WebGUI::Test->usersToDelete($user{'1'});
$user{'2'} = WebGUI::User->new( $session, "new" );
WebGUI::Test->usersToDelete($user{'2'});

# Create everything as user no. 1
$session->user({ user => $user{'1'} });

$versionTag->set({name=>"Album Test"});

# Create gallery and a single album
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        groupIdEdit         => 3,   # Admins
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
    
# Create 5 photos inside the gallery
my @photoId;

for (my $i = 0; $i < 5; $i++)
{
    my $photo
        = $album->addChild({
            className           => "WebGUI::Asset::File::GalleryFile::Photo",
        },
        undef,
        undef,
        {
            skipAutoCommitWorkflows => 1,
        });
    $photoId[$i] = $photo->getId;
}

# Commit all changes
$versionTag->commit;

# Make album default asset
$session->asset( $album );

# Define some general variables
my $result;

#----------------------------------------------------------------------------
# Tests
plan tests => 19;

#----------------------------------------------------------------------------
# Test module compiles okay
use_ok("WebGUI::Asset::Wobject::GalleryAlbum");

#----------------------------------------------------------------------------
# Test calling without arguments

diag("general testing");

# Provide no arguments at all
$result = callAjaxService({ });

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after call without arguments." );

#----------------------------------------------------------------------------
# Test moveFile action with incomplete of invalid arguments

diag("moveFile action");

# Omit target
$result = callAjaxService({
    action => 'moveFile',
    after => $photoId[4],
    });

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action without 'target' specified." );


# Omit before/after
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
});

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action without 'before/after' specified." );

# Specify invalid target ID
$result = callAjaxService({
    action => 'moveFile',
    target => '123456',
    after => $photoId[4],
});

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action with invalid 'target' ID." );

# Specify invalid ID in after argument
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    after => '123456',
});

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action with invalid ID in 'after' argument." );

# Specify invalid ID in before argument
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    before => '123456',
});

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action with invalid ID in 'before' argument." );

# Specify non-child target ID
$result = callAjaxService({
    action => 'moveFile',
    target => $album->getId,
    after => $photoId[4],
});

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action with non-child 'target' ID." );

# Specify non-child ID in after argument
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    after => $album->getId,
});

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action with non-child  ID in 'after' argument." );

# Specify non-child ID in before argument
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    before => $album->getId,
});

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action with non-child  ID in 'before' argument." );

#----------------------------------------------------------------------------
# Test moving photos

# Move photo no. 0 after photo no. 4
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    after => $photoId[4],
});

is($result->{ err }, 0, 'Moving of photo no. 0 after photo no. 4 successful.');
is($album->getPreviousFileId($photoId[0]), $photoId[4], 'Photo no. 0 is after photo no. 4.');

# Move photo no. 0 before photo no. 1 (restore initial order)
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    before => $photoId[1],
    });

# Delete all stow variables. This is necessary or the list of file IDs will
# not get updated.
$session->stow->deleteAll;

is($result->{ err }, 0, 'Moving of photo no. 0 before photo no. 1 successful.');
is($album->getNextFileId($photoId[0]), $photoId[1], 'Photo no. 0 is before photo no. 1.');

# Move photo no. 0 before photo no. 0
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    before => $photoId[0],
    });

$session->stow->deleteAll;

is($result->{ err }, 0, 'Moving of photo no. 0 before photo no. 0 successful.');
is($album->getNextFileId($photoId[0]), $photoId[1], 'Photo no. 0 is still before photo no. 1.');

# Move photo no. 0 after photo no. 0
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    after => $photoId[0],
    });

$session->stow->deleteAll;

is($result->{ err }, 0, 'Moving of photo no. 0 after photo no. 0 successful.');
is($album->getNextFileId($photoId[0]), $photoId[1], 'Photo no. 0 is still before photo no. 1.');

# Try to move photo with insufficient permissions
$session->user({ user => $user{'2'} });
$result = callAjaxService({
    action => 'moveFile',
    target => $photoId[0],
    after => $photoId[4],
});
$session->user({ user => $user{'1'} });

ok( $result->{ err } != 0 && $result->{ errMessage }, "Error after request of moveFile action with insufficient permissions." );

#----------------------------------------------------------------------------
# callAjaxService( args )
# Makes a call to the www_ajax method of $album and returns the reply. The 
# only argument is a hash ref pointing to arguments for the ajax service.
# The sub uses the global $session and $album variables.

sub callAjaxService {
    my $args = shift;

    # Setup the mock request object
    $session->request->method('POST');
    $session->request->setup_body({ args => encode_json($args) });
    
    # Call ajax service function and decode reply
    return decode_json( $album->www_ajax() );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}
