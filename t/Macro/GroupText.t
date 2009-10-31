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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Group;
use WebGUI::User;
use WebGUI::Macro::GroupText;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $numTests;
$numTests  = 3; #Direct Macro tests
$numTests += 4; #Bug tests

plan tests => $numTests;

my @mob;
my ($ms_users, $ms_distributors, $ms_int_distributors);
my ($disti, $int_disti);

my $output;

$session->user({userId => 1});
$output = WebGUI::Macro::GroupText::process($session, "Admins", "admin", "visitor");
is($output, 'visitor', 'user is not admin');

$session->user({userId => 3});
$output = WebGUI::Macro::GroupText::process($session, "Admins", "admin", "visitor");
is($output, 'admin', 'user is admin');

$output = WebGUI::Macro::GroupText::process($session, "Not a Group","in group","outside group");
is($output, 'Group Not a Group was not found', 'Non-existant group returns an error message');

##Bug test setup

##Create a small database
$session->db->dbh->do('DROP TABLE IF EXISTS myUserTable');
$session->db->dbh->do(q!CREATE TABLE myUserTable (userId CHAR(22) binary NOT NULL default '', PRIMARY KEY(userId)) TYPE=InnoDB!);

##Create a bunch of users and put them in the table.

@mob = map { WebGUI::User->new($session, "new") } 0..3;
my $sth = $session->db->prepare('INSERT INTO myUserTable VALUES(?)');
foreach my $mob (@mob) {
	$sth->execute([ $mob->userId ]);
}
addToCleanup(@mob);

##Create the 3 groups

$ms_users = WebGUI::Group->new($session, "new");
$ms_distributors = WebGUI::Group->new($session, "new");
$ms_int_distributors = WebGUI::Group->new($session, "new");
addToCleanup($ms_users, $ms_distributors, $ms_int_distributors);

$ms_users->name('MS Users');
$ms_distributors->name('MS Distributors');
$ms_int_distributors->name('MS International Distributors');

##MS Users has an SQL query
$ms_users->dbQuery(q!select userId from myUserTable!);

ok($mob[0]->isInGroup($ms_users->getId), 'mob[0] is in $ms_users');

##Establish group hierarchy
##MS International Distributors is a member of MS Distributors
##MS Distributors is a member of MS Users

$ms_users->addGroups([$ms_distributors->getId]);
$ms_distributors->addGroups([$ms_int_distributors->getId]);

##Add two users for testing the two groups

$disti = WebGUI::User->new($session, 'new');
$int_disti = WebGUI::User->new($session, 'new');
addToCleanup($disti, $int_disti);

$ms_distributors->addUsers([$disti->userId]);
$ms_int_distributors->addUsers([$int_disti->userId]);

$session->user({userId => $mob[0]->userId});
$output = join ',',
		WebGUI::Macro::GroupText::process($session, "MS Users","user","not"),
		WebGUI::Macro::GroupText::process($session, "MS Distributors","disti","not"),
		WebGUI::Macro::GroupText::process($session, "MS International Distributors","int_disti","not"),
	;
is($output, 'user,not,not', 'user is ms user');

$session->user({userId => $disti->userId});
$output = join ',',
		WebGUI::Macro::GroupText::process($session, "MS Users","user","not"),
		WebGUI::Macro::GroupText::process($session, "MS Distributors","disti","not"),
		WebGUI::Macro::GroupText::process($session, "MS International Distributors","int_disti","not"),
	;
is($output, 'user,disti,not', 'user is ms user and distributor');

$session->user({userId => $int_disti->userId});
$output = join ',',
		WebGUI::Macro::GroupText::process($session, "MS Users","user","not"),
		WebGUI::Macro::GroupText::process($session, "MS Distributors","disti","not"),
		WebGUI::Macro::GroupText::process($session, "MS International Distributors","int_disti","not"),
	;
is($output, 'user,disti,int_disti', 'user is in all three groups');

##clean up everything
END {
	$session->db->dbh->do('DROP TABLE IF EXISTS myUserTable');
}
