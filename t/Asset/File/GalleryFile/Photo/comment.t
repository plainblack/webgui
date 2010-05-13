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
use lib "$FindBin::Bin/../../../../lib";

## The goal of this test is to test the adding, deleting, editing, and 
# getting comments for photos

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use Scalar::Util;
use WebGUI::Asset::File::GalleryFile::Photo;
use WebGUI::International;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);

my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});
WebGUI::Test->addToCleanup($versionTags[-1]);

my @addArguments    = ( undef, undef, { skipAutoCommitWorkflows => 1 } );
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        groupIdAddComment   => "2", # "Registered Users"
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    }, @addArguments );
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    }, @addArguments );

$versionTags[-1]->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 32;

#----------------------------------------------------------------------------
# Test with no comments
is(
    Scalar::Util::blessed($photo->getCommentPaginator), "WebGUI::Paginator",
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
    !eval{ $photo->setComment("lulz"); 1 },
    "Photo->setComment fails when first argument is not a hashref",
);

ok(
    !eval{ $photo->setComment({ lulz => "ohai" }); 1 },
    "Photo->setComment fails when hashref does not contain a bodyText key",
);

#----------------------------------------------------------------------------
# Test adding a comment
#   - bodyText is defined
#   - All else is defaults
my $commentId;
ok(
    eval{ $commentId = $photo->setComment({ commentId => "new", userId => 1, bodyText => "bodyText", }); 1 },
    "Photo->setComment succeeds",
);
if ( $@ ) { diag $@; }

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

like(
    $comment->{creationDate}, qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/,
    "creationDate is defined and is a MySQL-formatted date",
);

#----------------------------------------------------------------------------
# Test adding a comment
#   - bodyText is defined
#   - userId is visitor
#   - all else is defaults
ok(
    eval{ $commentId = $photo->setComment({ commentId => "new", userId => 1, bodyText => "bodyText", }); 1 },
    "Photo->setComment succeeds",
);
if ( $@ ) { diag $@; }

cmp_deeply(
    $photo->getCommentIds, superbagof( $commentId ),
    "Photo->getCommentIds returns newly added comment's ID",
);

my $comment;
ok(
    eval{ $comment = $photo->getComment($commentId); 1},
    "Photo->getComment does not croak.",
);
if ( $@ ) { diag $@; }

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

like(
    $comment->{creationDate}, qr/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/,
    "creationDate is defined and is a MySQL-formatted date",
);

#----------------------------------------------------------------------------
# Test deleting comment
$photo->deleteComment($commentId);
ok(
    !grep({ $_ eq $commentId } @{ $photo->getCommentIds }),
    "Photo->getCommentIds no longer contains deleted comment",
);

#----------------------------------------------------------------------------
# Test deleting asset deletes comments
my $assetId = $photo->getId;
$photo->purge;
ok(
    !$session->db->quickScalar("SELECT commentId FROM GalleryFile_comment WHERE assetId=?",[$assetId]),
    "Comments are purged along with asset",
);

#----------------------------------------------------------------------------
# Test appendTemplateVarsForCommentForm for a new comment
my $var     = {};
my $newVar  = $photo->appendTemplateVarsCommentForm( $var );

is ( $var, $newVar, "appendTemplateVarsCommentForm returns the same hashref it's given" );
cmp_deeply( 
    $var,
    superhashof( {
        commentForm_start => all(
            re( qr/<input[^>]+name="func"[^>]+value="editCommentSave"[^>]+>/ ),
            re( qr/<input[^>]+name="commentId"[^>]+value="new"[^>]+>/ ),
        ),
        commentForm_end => all(
            re( qr{</form>} ),
        ),
        commentForm_bodyText => all(
            re( qr{<textarea[^>]+>} ),
            re( qr{TinyMCE}i ),
        ),
        commentForm_submit => all(
            re( qr/<input[^>]+type="submit"[^>]+name="submit"[^>]+value="Save Comment."[^>]+>/ ),
        ),
    } ),
    "appendTemplateVarsCommentForm returns the correct structure",
);

#----------------------------------------------------------------------------
# Test appendTemplateVarsForCommentForm for an existing comment
$var            = {};
my $comment     = {
    commentId       => "new",
    bodyText        => "New comment",
    creationDate    => WebGUI::DateTime->new( $session, time )->toDatabase,
    userId          => "3",
};

my $commentId   = $photo->setComment( $comment );

$newVar         = $photo->appendTemplateVarsCommentForm( $var, $photo->getComment( $commentId ) );

is ( $var, $newVar, "appendTemplateVarsCommentForm returns the same hashref it's given" );
cmp_deeply( 
    $var,
    superhashof( {
        commentForm_start => all(
            re( qr/<input[^>]+name="func"[^>]+value="editCommentSave"[^>]+>/ ),
            re( qr/<input[^>]+name="commentId"[^>]+value="$commentId"[^>]+>/ ),
            re( qr/<input[^>]+name="creationDate"[^>]+value="$comment->{creationDate}"[^>]+>/ ),
            re( qr/<input[^>]+name="userId"[^>]+value="$comment->{userId}"[^>]+>/ ),
        ),
        commentForm_end => all(
            re( qr{</form>} ),
        ),
        commentForm_bodyText => all(
            re( qr{<textarea[^>]+>} ),
            re( qr{TinyMCE}i ),
            re( qr{$comment->{bodyText}} ),
        ),
        commentForm_submit => all(
            re( qr/<input[^>]+type="submit"[^>]+name="submit"[^>]+value="Save Comment."[^>]+>/ ),
        ),
    } ),
    "appendTemplateVarsCommentForm returns the correct structure",
);

#----------------------------------------------------------------------------
# Test www_editCommentSave page sanity checks
my $html;
$photo 
    = $album->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
    }, @addArguments );

# Permissions
$html   = WebGUI::Test->getPage($photo, "www_editCommentSave", {
            userId      => 1,
            formParams  => { bodyText => "yes?" },
        });

like(
    $html, qr/permission denied/i,
    "www_editCommentSave -- Permission denied if not Gallery->canAddComment",
);

my $i18n    = WebGUI::International->new($session, 'Asset_Photo');
my $errorMessage;

# Required: commentId
$html   = WebGUI::Test->getPage($photo, "www_editCommentSave", {
            userId      => 3,
            formParams  => { bodyText => "bodyText" },
        });

$errorMessage    = $i18n->get("commentForm error no commentId");
like(
    $html, qr/$errorMessage/,
    "www_editCommentSave -- Must have commentId defined",
);

# Required: bodyText
$html   = WebGUI::Test->getPage($photo, "www_editCommentSave", {
            userId      => 3,
            formParams  => { commentId => "new" },
        });

$errorMessage    = $i18n->get("commentForm error no bodyText");
like(
    $html, qr/$errorMessage/,
    "www_editCommentSave -- Must have bodyText defined",
);

#----------------------------------------------------------------------------
# Test www_editCommentSave functionality
$html   = WebGUI::Test->getPage($photo, "www_editCommentSave", {
            userId      => 3,
            formParams  => { commentId => "new", bodyText => "YES!", },
        });
my $successMessage = sprintf($i18n->get("comment message"), $photo->getUrl);
like(
    $html, qr/$successMessage/,
    "www_editCommentSave -- page shows success message",
);

my $ids = $photo->getCommentIds;
is(
    scalar @$ids, 1, 
    "www_editCommentSave -- Comment was added",
);


is( 
    $photo->getComment( $ids->[0] )->{visitorIp}, undef, 
    "Non-visitor does not have their IP logged"
);

TODO: {
    local $TODO = "Not programmed yet";
    
    # TODO
    ok( 0, "Visitor has their IP logged in visitorIp field" );
}
