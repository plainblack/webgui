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
use WebGUI::Image;
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

plan tests => 36 + scalar @{ $extensionTests }; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $uploadDir = $session->config->get('uploadsPath');
ok ($uploadDir, "uploadDir defined in config");

my $uploadUrl = $session->config->get('uploadsURL');
ok ($uploadUrl, "uploadDir defined in config");

my $originalCaseInsensitiveOS = $session->config->get('caseInsensitiveOS');
$session->config->set('caseInsensitiveOS', 0);

####################################################
#
# getFile
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

####################################################
#
# generateThumbnail
#
####################################################
my $thumbStore = WebGUI::Storage::Image->create($session);
my $square = WebGUI::Image->new($session, 500, 500);
$square->setBackgroundColor('#FF0000');
$square->saveToStorageLocation($thumbStore, 'square.png');
is($thumbStore->generateThumbnail(), 0, 'generateThumbnail returns 0 if no filename is supplied');
is($WebGUI::Test::logger_error, q/Can't generate a thumbnail when you haven't specified a file./, 'generateThumbnail logs an error message for not sending a filename');
is($thumbStore->generateThumbnail('file.txt'), 0, 'generateThumbnail returns 0 if you try to thumbnail a non-image file');
is($WebGUI::Test::logger_warns, q/Can't generate a thumbnail for something that's not an image./, 'generateThumbnail logs a warning message for thumbnailing a non-image file.');
chmod 0, $thumbStore->getPath('square.png');
ok(! -r $thumbStore->getPath('square.png'), 'Made square.png not readable');
is($thumbStore->generateThumbnail('square.png'), 0, 'generateThumbnail returns 0 if there are errors reading the file');
like($WebGUI::Test::logger_error, qr/^Couldn't read image for thumbnail creation: (.+)$/, 'generateThumbnail when it cannot read the file for thumbnailing');
chmod 0644, $thumbStore->getPath('square.png');
ok(-r $thumbStore->getPath('square.png'), 'Made square.png readable again');
ok($thumbStore->generateThumbnail('square.png', 50), 'generateThumbnail returns true when there are no problems');
ok(-e $thumbStore->getPath('thumb-square.png'), 'thumbnail exists in right place with correct name');


####################################################
#
# getSizeInPixels
#
####################################################

cmp_bag([$thumbStore->getSizeInPixels('square.png')],       [500,500], 'getSizeInPixels on original file');
cmp_bag([$thumbStore->getSizeInPixels('thumb-square.png')], [50,50],   'getSizeInPixels on thumb');

is($thumbStore->getSizeInPixels(), 0, 'getSizeInPixels returns only a zero if no file is sent');
is($WebGUI::Test::logger_error, q/Can't check the size when you haven't specified a file./, 'getSizeInPixels logs an error message for not sending a filename');

is($thumbStore->getSizeInPixels('noImage.txt'), 0, 'getSizeInPixels returns only a zero if sent a non-image file');
is($WebGUI::Test::logger_error, q/Can't check the size of something that's not an image./, 'getSizeInPixels logs an error message for sending a non-image filename');

is($thumbStore->getSizeInPixels('noImage.gif'), 0, 'getSizeInPixels returns only a zero if sent a file that does not exist');
like($WebGUI::Test::logger_error, qr/^Couldn't read image to check the size of it./, 'getSizeInPixels logs an error message for reading a file that does not exist');

####################################################
#
# copy
#
####################################################

my $imageCopy = $thumbStore->copy();
isa_ok($imageCopy, 'WebGUI::Storage::Image', 'copy returns an object');
cmp_bag(
    $imageCopy->getFiles(),
    ['square.png'],
    'copy copied the original file',
);
ok(-e $imageCopy->getPath('thumb-square.png'), 'copy also copied the thumbnail');

####################################################
#
# deleteFiles
#
####################################################

$imageCopy->deleteFile('square.png');

cmp_bag(
    $imageCopy->getFiles(), #Must call SUPER because getFiles ignores thumb files.
    [qw()],
    'delete deleted the file',
);
ok(!-e $imageCopy->getPath('thumb-square.png'), 'deleteFile also deleted the thumbnail');

TODO: {
	local $TODO = "Methods that need to be tested";
	ok(0, 'copy also copies thumbnails');
	ok(0, 'deleteFile also deletes thumbnails');
	ok(0, 'getThumbnailUrl');
	ok(0, 'resize');
}

END {
	foreach my $stor (
        $imageStore, $thumbStore, $imageCopy,
    ) {
		ref $stor eq "WebGUI::Storage::Image" and $stor->delete;
	}
}
