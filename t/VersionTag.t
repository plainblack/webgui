#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use Test::More tests => 25; # increment this value for each test you create

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

# TODO: actually test interactions between tags and assets/revisions

# Local variables:
# mode: cperl
# End:
