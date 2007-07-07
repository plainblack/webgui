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

my $extensionTests = [
	{
		filename => 'filename',
        isImage  => 0,
		comment  => 'no extension',
	},
	{
		filename => 'filename.JPG',
        isImage  => 1,
		comment => 'JPG caps',
	},
	{
		filename => 'filename.jpg',
        isImage  => 1,
		comment => 'JPG lower case',
	},
	{
		filename => 'filename.jpeg',
        isImage  => 1,
		comment => 'jpeg file',
	},
	{
		filename => 'filename.gif',
        isImage  => 1,
		comment => 'gif file',
	},
	{
		filename => 'filename.png',
        isImage  => 1,
		comment => 'png file',
	},
	{
		filename => 'filename.bmp',
        isImage  => 0,
		comment => 'bmp file is not an image',
	},
	{
		filename => 'filename.tiff',
        isImage  => 0,
		comment => 'tiff file is not an image',
	},
];

plan tests => 9 + scalar @{ $extensionTests }; # increment this value for each test you create

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
my $expectedFiles = ['.', '..'];
cmp_bag($imageStore->getFiles(1), $expectedFiles, 'Starting with an empty storage object, no files in here except for . and ..');
$imageStore->addFileFromScalar('.dotfile', 'dot file');
push @{ $expectedFiles }, '.dotfile';
cmp_bag($imageStore->getFiles(),  [            ], 'getFiles() by default does not return dot files');
cmp_bag($imageStore->getFiles(1), $expectedFiles, 'getFiles(1) returns all files, including dot files');

$imageStore->addFileFromScalar('dot.file', 'dot.file');
push @{ $expectedFiles }, 'dot.file';
cmp_bag($imageStore->getFiles(),  ['dot.file'],   'getFiles() returns normal files');
cmp_bag($imageStore->getFiles(1), $expectedFiles, 'getFiles(1) returns all files, including dot files');

$imageStore->addFileFromScalar('thumb-file.png', 'thumbnail file');
cmp_bag($imageStore->getFiles(),  ['dot.file', ],   'getFiles() ignores thumb- file');
cmp_bag($imageStore->getFiles(1), $expectedFiles, '... even when the allFiles switch is passed');

####################################################
#
# isImage
#
####################################################

foreach my $extTest ( @{ $extensionTests } ) {
	is( $imageStore->isImage($extTest->{filename}), $extTest->{isImage}, $extTest->{comment} );
}

END {
	foreach my $stor (
        $imageStore,
    ) {
		ref $stor eq "WebGUI::Storage::Image" and $stor->delete;
	}
}
