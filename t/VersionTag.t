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
use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::VersionTag;
use Test::More tests => 68; # increment this value for each test you create

my $session = WebGUI::Test->session;

sub ok_open {
	my $tagId = shift;
	my $open = shift;
	my $name = shift;
	my @results = grep{$_->getId eq $tagId} @{WebGUI::VersionTag->getOpenTags($session)};
	ok(($open xor not @results),
	   "$name is ".($open? "":"not ")."in open tag list");
}

sub getWorking { WebGUI::VersionTag->getWorking($session, @_) }
sub getWorkingId { my $w = getWorking(@_); defined($w)? $w->getId : undef }

# versionTagMode support. Test that setting version tag mode works. Also, make
# sure that the versionTagMode is in multiPerUser before running the test below.

sub setSiteVersionTagMode {
    my ($session, $newMode) = @_;

    $session->setting()->set(q{versionTagMode}, $newMode);

    return;
} #setSiteVersionTagMode

sub setUserVersionTagMode {
    my ($user, $newMode) = @_;

    $user->profileField(q{versionTagMode}, $newMode);

    return;
} #setUserVersionTagMode

can_ok(
    q{WebGUI::VersionTag},
    q{getVersionTagMode},
);

my $user = $session->user();

setSiteVersionTagMode($session, q{multiPerUser});
setUserVersionTagMode($user, q{inherited});

is (
    WebGUI::VersionTag->getVersionTagMode($session),
    q{multiPerUser},
    q{versionTagMode: both site and user setting multiPerUser},
);

setUserVersionTagMode($user, q{singlePerUser});

is (
    WebGUI::VersionTag->getVersionTagMode($session),
    q{singlePerUser},
    q{versionTagMode: user setting singlePerUser overrides site setting},
);

setSiteVersionTagMode($session, q{autoCommit});

is (
    WebGUI::VersionTag->getVersionTagMode($session),
    q{singlePerUser},
    q{versionTagMode: update site setting doesn't update user setting},
);

setUserVersionTagMode($user, q{multiPerUser});

is (
    WebGUI::VersionTag->getVersionTagMode($session),
    q{multiPerUser},
    q{versionTagMode: update user setting to multiPerUser},
);

my $tag = WebGUI::VersionTag->create($session, {});
isa_ok($tag, 'WebGUI::VersionTag', 'empty tag');
ok(defined $tag->getId, 'empty tag has an ID');
is($tag->getAssetCount, 0, 'empty tag has zero assets');
is($tag->getRevisionCount, 0, 'empty tag has zero revisions');
isa_ok($tag->getAssets, 'ARRAY', 'empty tag asset list');
is_deeply($tag->getAssets, [], 'empty tag asset list is empty');
ok_open($tag->getId, 1, 'empty tag');

ok(!defined getWorking(1), 'no working tag initially present');
$tag->setWorking;
is(getWorkingId(1), $tag->getId, 'working tag set');
$tag->clearWorking;
ok(!defined getWorking(1), 'working tag unset');

ok(!scalar $tag->get('isLocked'), 'tag is initially unlocked');
$tag->lock;
ok(scalar $tag->get('isLocked'), 'tag is locked');
ok_open($tag->getId, 0, 'locked tag');
$tag->unlock;
ok(!scalar $tag->get('isLocked'), 'tag is again unlocked');
ok_open($tag->getId, 1, 'unlocked tag');

# TODO: test interaction between lock/unlock and working tags

my $tagAgain1 = WebGUI::VersionTag->new($session, $tag->getId);
isa_ok($tagAgain1, 'WebGUI::VersionTag', 'tag retrieved again while valid');
is($tagAgain1->getId, $tag->getId, 'tag retrieved again has same ID');

my $tag2 = WebGUI::VersionTag->create($session, {});
isa_ok($tag2, 'WebGUI::VersionTag', 'second tag can be created');
isnt($tag2->getId, $tag->getId, 'second tag has different ID');
$tag->setWorking;
is(getWorkingId(1), $tag->getId, 'working tag set to first');
$tag2->setWorking;
is(getWorkingId(1), $tag2->getId, 'working tag set to second');
$tag->clearWorking;
is(getWorkingId(1), $tag2->getId, 'working tag still set to second');
$tag2->clearWorking;
ok(!defined getWorking(1), 'working tag now unset from second');

my $savedTagId = $tag->getId;
$tag->rollback;
ok_open($savedTagId, 0, 'nonexistent tag');
my $tagAgain2 = WebGUI::VersionTag->new($session, $savedTagId);
ok(!defined $tagAgain2, 'nonexistent tag cannot be instantiated');
$tag2->rollback;
($tag, $tagAgain1, $tag2, $tagAgain2) = ();

my $tag3 = WebGUI::VersionTag->create($session, {});
$tag3->setWorking;
my $asset1 = WebGUI::Asset->getRoot($session)->addChild({ className => 'WebGUI::Asset::Snippet' });
my $asset2 = WebGUI::Asset->getRoot($session)->addChild({ className => 'WebGUI::Asset::Snippet' });
is($tag3->getAssetCount, 2, 'tag with two assets');
is($tag3->getRevisionCount, 2, 'tag with two revisions');
$asset1 = $asset1->addRevision({ title => 'revised once' }, time+10);
$asset1 = $asset1->addRevision({ title => 'revised twice' }, time+20);
$asset2 = $asset2->addRevision({ title => 'other revised once' }, time+30);
is($tag3->getRevisionCount, 5, 'tag with five revisions');

my $tag4 = WebGUI::VersionTag->create($session, {});
$tag4->setWorking;
my $asset3 = WebGUI::Asset->getRoot($session)->addChild({ className => 'WebGUI::Asset::Snippet' });
is($tag4->getAssetCount, 1, 'other tag with one asset');
is($tag4->getRevisionCount, 1, 'other tag with one revision');
$asset3->addRevision({ title => 'again revised once' }, time+40);
is($tag4->getRevisionCount, 2, 'other tag still with one asset');
is($tag4->getRevisionCount, 2, 'other tag with two revisions');
is($tag3->getAssetCount, 2, 'original tag still with two assets');
is($tag3->getRevisionCount, 5, 'original tag still with five revisions');
$tag4->clearWorking;
$tag3->rollback;
$tag4->rollback;
($asset1, $asset2, $asset3, $tag3, $tag4) = ();

#additional tests for versionTagMode
# 

setSiteVersionTagMode($session, q{singlePerUser});
setUserVersionTagMode($user, q{inherited});

ok(!defined getWorking(1), 'versionTagMode singlePerUser: no working tag initially present');

$tag = WebGUI::VersionTag->create($session, {});
isa_ok($tag, 'WebGUI::VersionTag', 'versionTagMode singlePerUser: empty tag');
ok(defined $tag->getId, 'versionTagMode singlePerUser: empty tag has an ID');
ok(!$tag->get(q{isSiteWide}), 'versionTagMode singlePerUser: empty is not site wide');

my $userTagId = $tag->getId();
my $userTag; # user tag in singlePerUser;
my $siteWideTagId;
my $siteWideTag;

$tag->clearWorking();

ok(defined ($userTag = getWorking(1)), 'versionTagMode singlePerUser: reclaim version tag after clearWorking');
is ($userTag->getId(), $userTagId, q{versionTagMode singlePerUser:  reclaimed version tag has same id});


#switch to sitewide mode

$userTag->clearWorking();

setSiteVersionTagMode($session, q{siteWide});

ok(!defined ($siteWideTag = getWorking(1)), 'versionTagMode siteWide: no working tag initially present');

$siteWideTag = getWorking(); #force create
isa_ok($siteWideTag, 'WebGUI::VersionTag', 'versionTagMode siteWide: empty tag');
ok($siteWideTag->get(q{isSiteWide}), 'versionTagMode ssiteWide: empty is site wide');

ok(defined ($siteWideTagId = $siteWideTag->getId()), 'versionTagMode siteWide: empty tag has an ID');

ok($siteWideTag->getId() ne $userTagId, 'versionTagMode siteWide: siteWide tag has different version tag id');

$siteWideTag->clearWorking();

my $asset4 = WebGUI::Asset->getRoot($session)->addChild({ className => 'WebGUI::Asset::Snippet' });

ok(defined ($siteWideTag = getWorking(1)), 'versionTagMode siteWide: reclaim version tag after clearWorking and addding new asset');

is($siteWideTag->getId(), $siteWideTagId, 'versionTagMode siteWide: reclaim site wide version tag has correct id');


## Through in a new session as different user
my $admin_session = WebGUI::Session->open($WebGUI::Test::WEBGUI_ROOT, $WebGUI::Test::CONFIG_FILE);
$admin_session->user({'userId' => 3});
WebGUI::Test->sessionsToDelete($admin_session);

setUserVersionTagMode($admin_session->user(), q{singlePerUser});

my $adminUserTag = WebGUI::VersionTag->getWorking($admin_session, 0);
isa_ok($adminUserTag, 'WebGUI::VersionTag', 'versionTagMode siteWide + admin singlePerUser: empty tag');
ok(defined $adminUserTag->getId(), 'versionTagMode siteWide + admin singlePerUser: empty tag has an ID');
ok(!$adminUserTag->get(q{isSiteWide}), 'versionTagMode siteWide + admin singlePerUser: empty is not site wide');
ok($adminUserTag->getId() ne $userTagId, 'versionTagMode siteWide + admin singlePerUser: empty has different ID');
ok($adminUserTag->getId() ne $siteWideTagId, 'versionTagMode siteWide + admin singlePerUser: empty has different ID than site wide');

# Now switch to site wide

$adminUserTag->clearWorking();

setUserVersionTagMode($admin_session->user(), q{inherited});

my $adminSiteWideTag = WebGUI::VersionTag->getWorking($admin_session, 0);

isa_ok($adminSiteWideTag, 'WebGUI::VersionTag', 'versionTagMode siteWide + admin inherited: reclaimed empty tag');
ok($adminSiteWideTag->get(q{isSiteWide}), 'versionTagMode siteWide + admin inherited: empty is site wide');
ok($adminSiteWideTag->getId() eq $siteWideTagId, 'versionTagMode siteWide + admin inherited: empty has same ID as site wide');


$admin_session->var()->end();
$admin_session->close();

# Check if get returns a safe copy

my $name        = $userTag->get( 'name' );
my $safeCopy    = $userTag->get;
$safeCopy->{ name   } = 'NotSoSafeAfterAll!';

is(
    $userTag->get( 'name' ),
    $name,
    'get returns a safe copy of the internal data hash'
);

my $otherSafeCopy = $userTag->get;

isnt(
    $safeCopy,
    $otherSafeCopy,
    'get returns unique safe copies on each invocation'
);

$userTag->rollback();
$siteWideTag->rollback();
$adminUserTag->rollback();

## Additional VersionTagMode to make sure that auto commit happens only when user is tag creator and tag is not site wide.
## See bug #10689 (Version Tag Modes)
{
    my $test_prefix = q{versionTagMode B10689>};

    setUserVersionTagMode($user, q{singlePerUser});
    my $tag = WebGUI::VersionTag->create($session, {});
    $tag->setWorking;
    my $asset = WebGUI::Asset->getRoot($session)->addChild({ className => 'WebGUI::Asset::Snippet' });
    is($tag->getAssetCount, 1, qq{$test_prefix [singlePerUser] tag with 1 asset});

    # create admin session
    my $admin_session = WebGUI::Session->open($WebGUI::Test::WEBGUI_ROOT, $WebGUI::Test::CONFIG_FILE);
    WebGUI::Test->sessionsToDelete($admin_session);
    $admin_session->user({'userId' => 3});

    setUserVersionTagMode($admin_session->user(), q{autoCommit});

    # Take over version tag
    my $adminUserTag = WebGUI::VersionTag->new($admin_session, $tag->getId());

    $adminUserTag->setWorking();

    my $adminCommitStatus = WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        override        => 0,
        allowComments   => 0,
        returnUrl       => q{},
    });

    is(
        $adminCommitStatus,
        undef,
        qq{$test_prefix [singlePerUser] Admin cannot auto commit working tag of other user},
    );

    $adminUserTag->rollback();

    # Change user mode to autoCommit
    setUserVersionTagMode($user, q{autoCommit});

    my $userCommitStatus = WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        override        => 0,
        allowComments   => 0,
        returnUrl       => q{},
    });

    is(
        $userCommitStatus,
        q{commit},
        qq{$test_prefix [singlePerUser] User can auto commit},
    );

    $tag->rollback();


    # Now test site wide tag

    setUserVersionTagMode($user, q{siteWide});
    $tag = WebGUI::VersionTag->create($session, {});
    $tag->setWorking;
    $asset = WebGUI::Asset->getRoot($session)->addChild({ className => 'WebGUI::Asset::Snippet' });
    is($tag->getAssetCount, 1, qq{$test_prefix [siteWide] tag with 1 asset});

    # create admin session
    $admin_session = WebGUI::Session->open($WebGUI::Test::WEBGUI_ROOT, $WebGUI::Test::CONFIG_FILE);
    WebGUI::Test->sessionsToDelete($admin_session);
    $admin_session->user({'userId' => 3});

    setUserVersionTagMode($admin_session->user(), q{autoCommit});

    # Take over version tag
    $adminUserTag = WebGUI::VersionTag->new($admin_session, $tag->getId());

    $adminUserTag->setWorking();

    $adminCommitStatus = WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        override        => 0,
        allowComments   => 0,
        returnUrl       => q{},
    });

    is(
        $adminCommitStatus,
        undef,
        qq{$test_prefix [siteWide] Admin cannot auto commit sitewide working tag},
    );

    $adminUserTag->rollback();

    # Change user mode to autoCommit
    setUserVersionTagMode($user, q{autoCommit});

    $userCommitStatus = WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        override        => 0,
        allowComments   => 0,
        returnUrl       => q{},
    });

    is(
        $userCommitStatus,
        q{commit},
        qq{$test_prefix [siteWide] User CANNOT auto commit sitewide working tag},
    );

    $tag->rollback();

}

#reset (just in case other tests depends on this setting)
setSiteVersionTagMode($session, q{multiPerUser});
setUserVersionTagMode($user, q{inherited});


# Local variables:
# mode: cperl
# End:
