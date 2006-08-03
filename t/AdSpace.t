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
use WebGUI::AdSpace;
use Test::More tests => 3; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $adSpace = WebGUI::AdSpace->create($session, {name=>"Alfred"});

my $data = $session->db->quickHashRef("select adSpaceId, name from adSpace where adSpaceId=?",[$adSpace->getId]);

ok(exists $data->{adSpaceId}, "create()");
is($data->{name}, $adSpace->get("name"), "get()");
is($data->{adSpaceId}, $adSpace->getId, "getId()");



