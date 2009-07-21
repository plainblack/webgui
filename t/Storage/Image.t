#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Storage;

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

plan tests => 49 + scalar @{ $extensionTests }; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $uploadDir = $session->config->get('uploadsPath');
ok ($uploadDir, "uploadDir defined in config");

my $uploadUrl = $session->config->get('uploadsURL');
ok ($uploadUrl, "uploadDir defined in config");

####################################################
#
# getFile
#
####################################################

my $imageStore = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($imageStore);
my $expectedFiles = ['.', ];
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
push @{ $expectedFiles}, 'thumb-file.png';
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

WebGUI::Test->interceptLogging();

my $thumbStore = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($thumbStore);
my $square = WebGUI::Image->new($session, 500, 500);
$square->setBackgroundColor('#FF0000');
$square->saveToStorageLocation($thumbStore, 'square.png');
is($thumbStore->generateThumbnail(), 0, 'generateThumbnail returns 0 if no filename is supplied');
is($WebGUI::Test::logger_error, q/Can't generate a thumbnail when you haven't specified a file./, 'generateThumbnail logs an error message for not sending a filename');
is($thumbStore->generateThumbnail('file.txt'), 0, 'generateThumbnail returns 0 if you try to thumbnail a non-image file');
is($WebGUI::Test::logger_warns, q/Can't generate a thumbnail for something that's not an image./, 'generateThumbnail logs a warning message for thumbnailing a non-image file.');
chmod 0, $thumbStore->getPath('square.png');

SKIP: {
	skip "Root will cause this test to fail since it does not obey file permissions", 3
		if $< == 0;
    ok(! -r $thumbStore->getPath('square.png'), 'Made square.png not readable');
    is($thumbStore->generateThumbnail('square.png'), 0,
       'generateThumbnail returns 0 if there are errors reading the file');
    like($WebGUI::Test::logger_error, qr/^Couldn't read image for thumbnail creation: (.+)$/,
         'generateThumbnail when it cannot read the file for thumbnailing');
    chmod oct(644), $thumbStore->getPath('square.png');
}

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
WebGUI::Test->storagesToDelete($imageCopy);
isa_ok($imageCopy, 'WebGUI::Storage', 'copy returns an object');
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

is($imageCopy->deleteFile('square.png'), 1, 'deleteFile only reports 1 file deleted');

cmp_bag(
    $imageCopy->getFiles(),
    [qw()],
    'delete deleted the file',
);
ok(!-e $imageCopy->getPath('thumb-square.png'), 'deleteFile also deleted the thumbnail');

is($imageCopy->deleteFile('../../'), undef, 'deleteFile in Storage::Image also returns undef if you try to delete a file outside of this storage object');

####################################################
#
# getThumbnailUrl
#
####################################################

is($thumbStore->getThumbnailUrl(), '', 'getThumbnailUrl returns undef if no file is sent');
is($WebGUI::Test::logger_error, q/Can't make a thumbnail url without a filename./, 'getThumbnailUrl logs an error message for not sending a filename');

is($thumbStore->getThumbnailUrl('round.png'), '', 'getThumbnailUrl returns undef if the requested file is not in the storage location');
is($WebGUI::Test::logger_error, q/Can't make a thumbnail for a file named 'round.png' that is not in my storage location./, 'getThumbnailUrl logs an error message for not sending a filename');

is($thumbStore->getThumbnailUrl('square.png'), $thumbStore->getUrl('thumb-square.png'), 'getThumbnailUrl returns the correct url');

####################################################
#
# adjustMaxImageSize
#
####################################################

my $origMaxImageSize = $session->setting->get('maxImageSize');

my $sizeTest = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($sizeTest);

my $resizeTarget = 80;
$session->setting->set('maxImageSize', 200 );
my @testImages = (
    {
        filename   => 'tooWide.gif',
        origWidth  => 100,
        origHeight => 50,
        newWidth   => 80,
        newHeight  => 40,
    },
    {
        filename   => 'tooTall.gif',
        origWidth  => 50,
        origHeight => 100,
        newWidth   => 40,
        newHeight  => 80,
    }
);

foreach my $testImage (@testImages) {
    $sizeTest->addFileFromFilesystem(
        WebGUI::Test->getTestCollateralPath($testImage->{filename})
    );
}

cmp_bag(
    $sizeTest->getFiles(),
    [ map { $_->{filename} } @testImages ],
    'all files added to storage object for testing adjustMaxImageSize'
);


foreach my $testImage (@testImages) {
    my $filename = $testImage->{ filename };
    is($sizeTest->adjustMaxImageSize($filename), 0, "$filename does not need to be resized");
    cmp_bag(
        [ $sizeTest->getSizeInPixels($filename)     ],
        [ @{ $testImage }{qw/origHeight origWidth/} ],
        "$filename was not resized"
    );
}

$session->setting->set('maxImageSize', $resizeTarget );
foreach my $testImage (@testImages) {
    my $filename = $testImage->{ filename };
    is($sizeTest->adjustMaxImageSize($filename), 1, "$filename needs to be resized");
    my @newSize = $sizeTest->getSizeInPixels($filename);
    cmp_bag(
        [ $sizeTest->getSizeInPixels($filename)   ],
        [ @{ $testImage }{qw/newHeight newWidth/} ],
        "$filename was resized properly"
    );
}

$session->setting->set('maxImageSize', $origMaxImageSize );

TODO: {
	local $TODO = "Methods that need to be tested";
	ok(0, 'resize');
}

END {
}
