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
use WebGUI::Storage;

use Test::More;

plan tests => 7; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $uploadDir = $session->config->get('uploadsPath');

ok ($uploadDir, "uploadDir defined in config");

ok ((-e $uploadDir and -d $uploadDir), "uploadDir exists and is a directory");

my $storage1 = WebGUI::Storage->get($session);

is( $storage1, undef, "get requires id to be passed");

$storage1 = WebGUI::Storage->get($session, 'foobar');

is( ref $storage1, "WebGUI::Storage", "storage will accept non GUID arguments");

is( $storage1->getErrorCount, 0, "No errors during path creation");

is( $storage1->getLastError, undef, "No errors during path creation");

my $storageDir1 = join '/', $uploadDir, 'fo', 'ob', 'foobar';

ok( (-e $storageDir1 and -d $storageDir1), "Storage location created and is a directory");

$storage1->delete;

END {
	ref $storage1 eq "WebGUI::Storage" and $storage1->delete;
}
