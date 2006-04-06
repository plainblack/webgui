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

use WebGUI::User;

use Test::More;

plan tests => 1; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $user = WebGUI::User->new($session, "new");

$session->user({user => $user});

my ($userId) = $session->db->quickArray("select userId from userSession where sessionId=?",[$session->getId]);

is($userId, $user->userId, 'changing session user changes sessionId inside userSession table');

END {
	foreach my $dude ($user) {
		$dude->delete if (defined $dude and ref $dude eq 'WebGUI::User');
	}
}
