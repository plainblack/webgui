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
use File::Spec;

##The goal of this test is to test the creation of UserList Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 5; # increment this value for each test you create
use WebGUI::Asset::Wobject::UserList;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"UserList Test"});
WebGUI::Test->addToCleanup($versionTag);
my $userList = $node->addChild({className=>'WebGUI::Asset::Wobject::UserList'});

# Test for a sane object type
isa_ok($userList, 'WebGUI::Asset::Wobject::UserList');

# Test to see if we can set new values
my $newUserListSettings = {
	usersPerPage => 124,
	showGroupId      => 7,
	hideGroupId    => 3,
	alphabet    => 'a,b,c',
};
$userList->update($newUserListSettings);

foreach my $newSetting (keys %{$newUserListSettings}) {
	is ($userList->get($newSetting), $newUserListSettings->{$newSetting}, "updated $newSetting is ".$newUserListSettings->{$newSetting});
}

#vim:ft=perl
