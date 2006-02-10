#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Utility;
# ---- END DO NOT EDIT ----

use WebGUI::Group;
use WebGUI::Grouping;
#use WebGUI::SQL;
use Test::More tests => 8; # increment this value for each test you create

initialize();  # this line is required

# put your tests here

my $cm = WebGUI::Group->new(4); ##Fetch content managers

$session{env}{REMOTE_ADDR} = '192.168.0.101';

is( $cm->name, "Content Managers", "content manager name check");
is( $cm->groupId, 4, "content manager groupId check");

ok (!WebGUI::Grouping::isInGroup(4,1), "Visitor is not member of group");
ok (WebGUI::Grouping::isInGroup(4,3), "Admin is member of group");

ok( !$cm->ipFilter, "Default IP filter is blank" );

$cm->ipFilter('192.168.0.');

is( $cm->ipFilter, "192.168.0.", "ipFilter assignment to local net, 192.168.0.");

ok (WebGUI::Grouping::isInGroup(4,1), "Visitor is allowed in via IP");

$cm->ipFilter('');

ok( !$cm->ipFilter, "Restore original IP filter" );

cleanup(); # this line is required

# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
	$|=1; # disable output buffering
	my $configFile;
	GetOptions(
        	'configFile=s'=>\$configFile
	);
	exit 1 unless ($configFile);
	WebGUI::Session::open("..",$configFile);
}

sub cleanup {
	WebGUI::Session::close();
}

