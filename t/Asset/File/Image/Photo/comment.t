#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

## The goal of this test is to test the adding, deleting, editing, and 
# getting comments for photos

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::File::Image::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoGallery",
        groupIdAddComment   => "2",
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoAlbum",
    });
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}

#----------------------------------------------------------------------------
# Tests
plan tests => 0;

#----------------------------------------------------------------------------
# Test with no comments
is(
    blessed $photo->getCommentPaginator, "WebGUI::Paginator",
    "Photo with no comments still provides comments paginator",
);

is_deeply(
    $photo->getCommentIds, [],
    "Photo->getCommentIds returns an empty arrayref when no comments",
);

#----------------------------------------------------------------------------
# Test the setComment requires two arguments
ok(
    !eval{ $photo->setComment(); 1 },
    "Photo->setComment fails when no arguments given",
);

ok(
    !eval{ $photo->setComment("new"); 1 },
    "Photo->setComment fails when no second argument given",
);

ok(
    !eval{ $photo->setComment("new", "lulz"); 1 },
    "Photo->setComment fails when second argument is not a hashref",
);

ok(
    !eval{ $photo->setComment("new", { lulz => "ohai" }); 1 },
    "Photo->setComment fails when hashref does not contain a bodyText key",
);

#----------------------------------------------------------------------------
# Test adding a comment
#   - bodyText is defined
#   - All else is defaults
my $commentId;
ok(
    eval{ $commentId = $photo->setComment("new", { bodyText => "bodyText", }); 1 },
    "Photo->setComment succeeds",
);

is_deeply(
    $photo->getCommentIds, [$commentId],
    "Photo->getCommentIds returns newly added comment's ID",
);

my $comment;
ok(
    eval{ $comment = $photo->getComment($commentId); 1},
    "Photo->getComment does not croak.",
);

is(
    ref $comment, "HASH",
    "Photo->getComment returns a hash reference",
);

is(
    $comment->{assetId}, $photo->getId,
    "Comment has correct assetId",
);

is(
    $comment->{userId}, $session->user->userId,
    "Comment has correct userId",
);

is(
    $comment->{visitorIp}, undef,
    "visitorIp is not defined if the user is not a visitor",
);

like(
    $comment->{creationDate}, /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/,
    "creationDate is defined and is a MySQL-formatted date",
);

#----------------------------------------------------------------------------
# Test adding a comment
#   - bodyText is defined
#   - userId is visitor
#   - all else is defaults
ok(
    eval{ $commentId = $photo->setComment("new", { userId => 1, bodyText => "bodyText", }); 1 },
    "Photo->setComment succeeds",
);

ok(
    grep { $_ eq $commentId } @{ $photo->getCommentIds }, 
    "Photo->getCommentIds returns newly added comment's ID",
);

my $comment;
ok(
    eval{ $comment = $photo->getComment($commentId); 1},
    "Photo->getComment does not croak.",
);

is(
    ref $comment, "HASH",
    "Photo->getComment returns a hash reference",
);

is(
    $comment->{assetId}, $photo->getId,
    "Comment has correct assetId",
);

is(
    $comment->{userId}, 1,
    "Comment has correct userId",
);

ok(
    $comment->{visitorIp},
    "visitorIp is defined since user is visitor",
);

like(
    $comment->{creationDate}, /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/,
    "creationDate is defined and is a MySQL-formatted date",
);

#----------------------------------------------------------------------------
# Test deleting comment
$photo->deleteComment($commentId);
ok(
    !grep { $_ eq $commentId } @{ $photo->getCommentIds },
    "Photo->getCommentIds no longer contains deleted comment",
);

#----------------------------------------------------------------------------
# Test deleting asset deletes comments
my $assetId = $photo->getId;
$photo->purge;
ok(
    !$session->db->quickScalar("SELECT commentId FROM Photo_comment WHERE assetId=?",[$assetId]),
    "Comments are purged along with asset",
);

#----------------------------------------------------------------------------
# Test appendTemplateVarsForCommentForm
TODO: {
    local $TODO = "Test appendTemplateVarsForCommentForm";
}

#----------------------------------------------------------------------------
# Test www_addCommentSave page sanity checks
my $html;
$photo 
    = $album->addChild({
        className       => "WebGUI::Asset::File::Image::Photo",
    });

# Permissions
$html   = WebGUI::Test->getPage($photo, "www_addCommentSave", {
            userId      => 1,
            formParams  => { bodyText => "yes?" },
        });

like(
    $html, qr/permission denied/i,
    "www_addCommentSave -- Permission denied if not Gallery->canAddComment",
);

# Required fields
$html   = WebGUI::Test->getPage($photo, "www_addCommentSave", {
            userId      => 2,
            formParams  => { },
        });

like(
    $html, WebGUI::International->get($session, "Asset_Photo", "www_addCommentSave error missing required"),
    "www_addCommentSave -- Must have bodyText defined",
);


#----------------------------------------------------------------------------
# Test www_addCommentSave functionality
$html   = WebGUI::Test->getPage($photo, "www_addCommentSave", {
            userId      => 2,
            formParams  => { bodyText => "YES!", },
        });

like(
    $html, WebGUI::International->get($session, "Asset_Photo", "www_addCommentSave success"),
    "www_addCommentSave -- page shows success message",
);

my $ids = $photo->getCommentIds;
is(
    scalar @$ids, 1, 
    "www_addCommentSave -- Comment was added",
);
