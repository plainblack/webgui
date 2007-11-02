#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Workflow::Activity::DeleteExpiredSessions;

use Test::More;

plan tests => 1; # increment this value for each test you create

my $session = WebGUI::Test->session;

TODO: {
	local $TODO = "Tests that need to be written";
    ok(0, 'Test allowPrivateMessages=friends, with various userIds');
}
