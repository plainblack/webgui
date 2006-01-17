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

use Test::More tests => 2; # increment this value for each test you create
use WebGUI::Utility;

my $session = WebGUI::Test->session;

# generate
my $generateId = $session->id->generate();
is(length($generateId), 22, "generate() - length of 22 characters");
my @uniqueIds;
my $isUnique = 1;
for (1..2000) {
	last unless $isUnique;
	my $id = $session->id->generate();
	$isUnique = !isIn($id,@uniqueIds);
	push(@uniqueIds,$id);
}
ok($isUnique, "generate() - unique");
