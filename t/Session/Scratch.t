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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;

use Test::More tests => 45; # increment this value for each test you create
 
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

is($scratch->delete("Test1"), 1, 'delete returns number deleted');
is($scratch->delete(), undef, 'delete without name of variable to delete returns undef');
is($scratch->get("Test1"), undef, "delete()");

is($scratch->deleteName(), undef, 'deleteName without name of variable to delete returns undef');
is($scratch->deleteName("Test10"), 1, 'deleteName returns number of elements deleted');

TODO: {
	local $TODO = "deleteName tests to write later";
	ok(0, 'set up scratch variable across multiple sessions and make sure deleteName gets them all');
}

is($scratch->get("Test10"), undef, "deleteName()");

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

is($newSession->getId, $session->getId, "Successful session duplication");

for (my $count = 1; $count <= $maxCount; $count++){
   is($newSession->scratch->get("dBase$count"), $count, "Passed set/get $count");
}

$scratch->set("dBase5", 15);

my ($changedValue) = $session->db->quickArray("select value from userSessionScratch where sessionId=? and name=?",[$session->getId, "dBase5"]);
is($changedValue, 15, "changing stored scratch value");
is($scratch->get("dBase5"), 15, "checking cached scratch value");

$newSession->close;

is($scratch->set('retVal',2), 1, 'set returns number of rows affected');
is($scratch->set(), undef, 'set returns undef unless it gets a name');
is($scratch->set('','value'), undef, 'set returns undef unless it gets a name even if there is a value');

END {
	if (defined $newSession and ref $newSession eq 'WebGUI::Session') {
		$newSession->close;
	}
}
