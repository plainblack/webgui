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

use Test::More tests => 62; # increment this value for each test you create
use Test::Deep;
 
my $session = WebGUI::Test->session;

my $scratch = $session->scratch;
my $maxCount = 10;

$scratch->deleteAll();

for (my $count = 1; $count <= $maxCount; $count++){
   $scratch->set("Test$count",$count);
}

for (my $count = 1; $count <= $maxCount; $count++){
   is($scratch->get("Test$count"), $count, "Passed set/get $count");
}

is($scratch->delete("nonExistantVariable"), undef, 'delete returns value if deleted, otherwise undef');
is($scratch->delete("Test1"), 1, 'delete returns number deleted');
is($scratch->delete(), undef, 'delete without name of variable to delete returns undef');
is($scratch->get("Test1"), undef, "delete()");

$scratch->deleteAll;
is($scratch->get("Test2"), undef, "deleteAll()");

my $testScratchSession = $scratch->session();

is($testScratchSession, $session, "session()");

##Build some variables to test database persistency

for (my $count = 1; $count <= $maxCount; $count++){
	$scratch->set("dBase$count",$count);
	my ($setValue) = $session->db->quickArray("select value from userSessionScratch where sessionId=? and name=?",[$session->getId, "dBase$count"]);
	is($setValue, $count, "database store for set on $count");
}

##Creating a new session with the previous session's Id should clone the scratch data
my $newSession = WebGUI::Session->open(WebGUI::Test->root, WebGUI::Test->file, undef, undef, $session->getId);
WebGUI::Test->addToCleanup($newSession);

is($newSession->getId, $session->getId, "Successful session duplication");

for (my $count = 1; $count <= $maxCount; $count++){
   is($newSession->scratch->get("dBase$count"), $count, "Passed set/get $count");
}

$scratch->set("dBase5", 15);

my ($changedValue) = $session->db->quickArray("select value from userSessionScratch where sessionId=? and name=?",[$session->getId, "dBase5"]);
is($changedValue, 15, "changing stored scratch value");
is($scratch->get("dBase5"), 15, "checking cached scratch value");

$newSession->scratch->deleteAll;
$newSession->close;

is($scratch->set('retVal',2), 1, 'set returns number of rows affected');
is($scratch->set(), undef, 'set returns undef unless it gets a name');
is($scratch->set('','value'), undef, 'set returns undef unless it gets a name even if there is a value');

############################################
#
# Multi-session deleting
#
############################################

my @sessionBank = map { WebGUI::Session->open(WebGUI::Test->root, WebGUI::Test->file) } 0..3;

WebGUI::Test->addToCleanup(@sessionBank);

##Set variables to be deleted by name
foreach my $i (0..3) {
	$sessionBank[$i]->scratch->set('deletableName', $i);
}
##Set variables to be deleted by name and value
$sessionBank[0]->scratch->set('deletableValue', 'a');
$sessionBank[1]->scratch->set('deletableValue', 'a');
$sessionBank[2]->scratch->set('deletableValue', 'b');
$sessionBank[2]->scratch->set('falseValue', '');
$sessionBank[3]->scratch->set('deletableValue', 'c');
$sessionBank[3]->scratch->set('falseValue', '0');

is($scratch->deleteName(), undef, 'deleteName without name of variable to delete returns undef');
is($sessionBank[2]->scratch->deleteName("deletableName"), 4, 'deleteName returns number of elements deleted');
is($sessionBank[2]->scratch->get("deletableName"), undef, 'deleteName clears session cached in the object that calls it');
is($sessionBank[1]->scratch->get('deletableName'), 1, "deleteName does not change session cached vriables");
my ($entries) = $session->db->quickArray("select count(name) from userSessionScratch where name=?",['deletableName']);
is($entries, 0, "deleteName deletes entries in the database");

is($sessionBank[1]->scratch->deleteNameByValue('deletableValue', 'a'), 2, 'deleteNameByValue deleted two rows');
($entries) = $session->db->quickArray("select count(name) from userSessionScratch where name=?",['deletableValue']);
is($entries, 2, "deleteNameByValue deleted entries in the database");
is($sessionBank[1]->scratch->get('deletableValue'), undef, 'deleteNameByValue removes session cache in object that called it...');
is($sessionBank[0]->scratch->get('deletableValue'), 'a', 'but not in any other object whose database entry was cleared');
cmp_bag($session->db->buildArrayRef('select value from userSessionScratch where name=?',['deletableValue']), ['b', 'c'], 'deleteNameByValue values that were not deleted');

is($sessionBank[2]->scratch->deleteNameByValue('deletableValue', 'c'), 1, 'deleteNameByValue deleted one row');

is($sessionBank[0]->scratch->deleteNameByValue('',35), undef, 'deleteNameByValue requires a NAME');
is($sessionBank[0]->scratch->deleteNameByValue('scratch'), undef, 'deleteNameByValue requires a value');
is($sessionBank[0]->scratch->deleteNameByValue('',''), undef, 'deleteNameByValue require a NAME and a VALUE');
is($sessionBank[3]->scratch->deleteNameByValue('falseValue','0'), 1, 'deleteNameByValue will delete values that are false (0)');
is($sessionBank[2]->scratch->deleteNameByValue('falseValue',''), 1, "deleteNameByValue will delete values that are false ('')");

$scratch->setLanguageOverride('English');
is($scratch->getLanguageOverride, 'English', 'session scratch language is not correctly set');
$scratch->removeLanguageOverride;
is($scratch->getLanguageOverride, undef, 'The session scratch variable language is not removed');
$scratch->setLanguageOverride('myimmaginarylanguagethatisnotinstalled');
is($scratch->getLanguageOverride, undef, 'A non-existing language is set');
$scratch->setLanguageOverride('English');
$scratch->setLanguageOverride();
is($scratch->getLanguageOverride, 'English', 'A empty string is falsely recognised as a language');

#vim:ft=perl
