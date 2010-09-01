#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

##The goal of this test is to test the creation of a WikiPage Asset.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 18; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::WikiMaster;
use WebGUI::Asset::WikiPage;


my $session = WebGUI::Test->session;
my $node = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Wiki Test"});
WebGUI::Test->addToCleanup($versionTag);

my $wiki = $node->addChild({className=>'WebGUI::Asset::Wobject::WikiMaster', title => 'Wiki Test', url => 'wikitest'});
my @autoCommitCoda = (undef, undef, {skipAutoCommitWorkflows => 1, skipNotification => 1});
$versionTag->commit;
my $wiki = $wiki->cloneFromDb;
my $wikipage = $wiki->addChild(
    {className=>'WebGUI::Asset::WikiPage',
     title    =>'wikipage'},
    @autoCommitCoda,
);

# Wikis create and autocommit a version tag when a child is added.  Lets get the name so we can roll it back.
my $secondVersionTag = WebGUI::VersionTag->new($session,$wikipage->get("tagId"));
$secondVersionTag->commit;
WebGUI::Test->addToCleanup($secondVersionTag );
my $wikipage = $wikipage->cloneFromDb;

# Test for sane object types
isa_ok($wiki, 'WebGUI::Asset::Wobject::WikiMaster');
isa_ok($wikipage, 'WebGUI::Asset::WikiPage');

# Try to add content under a wiki page
my $article = $wikipage->addChild({className=>'WebGUI::Asset::Wobject::Article'});
is($article, undef, "Can't add an Article wobject as a child to a Wiki Page.");

# See if the duplicate method works
my $wikiPageCopy = $wikipage->duplicate();
$wikiPageCopy    = $wikiPageCopy->cloneFromDb;
$wikiPageCopy->update({ title => 'wikipage copy', });
isa_ok($wikiPageCopy, 'WebGUI::Asset::WikiPage');
my $thirdVersionTag = WebGUI::VersionTag->new($session,$wikiPageCopy->get("tagId"));
WebGUI::Test->addToCleanup($thirdVersionTag);

## isProtected

$wikiPageCopy->update({isProtected => 1});
ok($wikiPageCopy->isProtected, 'isProtected: copied page returns true');
ok(! $wikipage->isProtected,   '... original page is not');

## wiki page template variables

ok( ! $wikipage->getTemplateVars->{isProtected}, 'view template variables: isProtected is false on wiki page 1');

ok( $wikiPageCopy->getTemplateVars->{isProtected}, '... isProtected is true on wiki page 2');

##################
# This section tests the Comments aspect
##################

is(ref $wikipage->get('comments'), "ARRAY", "Comments Aspect property returns an array ref");

my $firstComment = 'what say you fuzzy britches';
$wikipage->addComment($firstComment,5);
my $secondComment = "i don't have her stuffed down my pants right now, sorry to say";
$wikipage->addComment($secondComment, 1);

my $comments = $wikipage->get('comments');
is(scalar(@{$comments}), 2, "2 comments have been added");
is($wikipage->get('averageCommentRating'), 3, 'average rating works');
is($comments->[0]{comment}, $firstComment, "adding initial comment checks out");
is($comments->[0]{rating}, 5, "adding initial comment rating checks out");
is($comments->[1]{comment}, $secondComment, "adding additional comments checks out");
is($comments->[1]{rating}, 1, "adding additional comment rating checks out");

$wikipage->deleteComment($comments->[0]{id});
$comments = $wikipage->get('comments');
is($comments->[0]{comment}, $secondComment, "you can delete a comment");
is($wikipage->get('averageCommentRating'), 1, 'average rating is adjusted after deleting a comment');

can_ok($wikipage, 'getSynopsisAndContent');
