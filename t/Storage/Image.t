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
use lib "$FindBin::Bin/../lib";
our $todo;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage::Image;

use File::Spec;
use Test::More;
use Test::Deep;

plan tests => 7; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $uploadDir = $session->config->get('uploadsPath');
ok ($uploadDir, "uploadDir defined in config");

my $uploadUrl = $session->config->get('uploadsURL');
ok ($uploadUrl, "uploadDir defined in config");

my $originalCaseInsensitiveOS = $session->config->get('caseInsensitiveOS');
$session->config->set('caseInsensitiveOS', 0);

####################################################
#
# getFiles
#
####################################################

my $imageStore = WebGUI::Storage::Image->create($session);
cmp_bag($imageStore->getFiles(1), ['.', '..'], 'Starting with an empty storage object, no files in here except for . and ..');
$imageStore->addFileFromScalar('.dotfile', 'dot file');
cmp_bag($imageStore->getFiles(),  [                     ], 'getFiles() by default does not return dot files');
cmp_bag($imageStore->getFiles(1), ['.', '..', '.dotfile'], 'getFiles(1) returns all files, including dot files');
$imageStore->addFileFromScalar('dot.file', 'dot.file');
cmp_bag($imageStore->getFiles(),  ['dot.file'],            'getFiles() returns normal files');
cmp_bag($imageStore->getFiles(1), ['.', '..', '.dotfile', 'dot.file'], 'getFiles(1) returns all files, including dot files');

END {
	foreach my $stor (
        $imageStore,
    ) {
		ref $stor eq "WebGUI::Storage::Image" and $stor->delete;
	}
}
