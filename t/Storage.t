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
our $todo;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;

use File::Spec;
use Test::More;
use Test::Deep;

my $extensionTests = [
	{
		filename => 'filename',
		extension => undef,
		comment => 'no extension',
	},
	{
		filename => 'filename.',
		extension => '',
		comment => 'dot, but no extension',
	},
	{
		filename => 'filename.txt',
		extension => 'txt',
		comment => 'simple extension',
	},
	{
		filename => 'filename.TXT',
		extension => 'txt',
		comment => 'extensions are all lowercase',
	},
	{
		filename => 'filename.FOO.BAR',
		extension => 'bar',
		comment => 'multiple extensions return last extension',
	},
];

plan tests => 44 + scalar @{ $extensionTests }; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $uploadDir = $session->config->get('uploadsPath');
ok ($uploadDir, "uploadDir defined in config");

my $uploadUrl = $session->config->get('uploadsURL');
ok ($uploadUrl, "uploadDir defined in config");

####################################################
#
# get
#
####################################################

ok ((-e $uploadDir and -d $uploadDir), "uploadDir exists and is a directory");

my $storage1 = WebGUI::Storage->get($session);

is( $storage1, undef, "get requires id to be passed");

$storage1 = WebGUI::Storage->get($session, 'foobar');

isa_ok( $storage1, "WebGUI::Storage", "storage will accept non GUID arguments");

is( $storage1->getErrorCount, 0, "No errors during path creation");

is( $storage1->getLastError, undef, "No errors during path creation");

####################################################
#
# getPath, getUrl
#
####################################################

my $storageDir1 = join '/', $uploadDir, 'fo', 'ob', 'foobar';
is ($storageDir1, $storage1->getPath, 'getPath: path calculated correctly for directory');
my $storageFile1 = join '/', $storageDir1, 'baz';
is ($storageFile1, $storage1->getPath('baz'), 'getPath: path calculated correctly for file');

my $storageUrl1 = join '/', $uploadUrl, 'fo', 'ob', 'foobar';
is ($storageUrl1, $storage1->getUrl, 'getUrl: url calculated correctly for directory');
my $storageUrl2 = join '/', $storageUrl1, 'bar';
is ($storageUrl2, $storage1->getUrl('bar'), 'getUrl: url calculated correctly for file');

ok( (-e $storageDir1 and -d $storageDir1), "Storage location created and is a directory");

$storage1->delete;

ok( !(-e $storageDir1), "Storage location deleted");

undef $storage1;

$storage1 = WebGUI::Storage->get($session, 'notAGUID');
my $storage2 = WebGUI::Storage->get($session, 'notAGoodId');

ok(! $storage2->getErrorCount, 'No errors due to a shared common root');

ok( (-e $storage1->getPath and -d $storage1->getPath), "Storage location 1 created and is a directory");
ok( (-e $storage2->getPath and -d $storage2->getPath), "Storage location 2 created and is a directory");

$storage1->delete;
undef $storage1;

ok( (-e $storage2->getPath and -d $storage2->getPath), "Storage location 2 not touched");

$storage2->delete;

my $storageDir2 = join '/', $uploadDir, 'no';

ok (!(-e $storageDir2), "Storage2 cleaned up properly");

undef $storage2;

my @dirOptions = qw/bad bAd Bad BAd/;
my $skipDirCheck = 0;

my ($dir3, $dirOpt);

CHECKDIR: while ($dirOpt = pop @dirOptions) {
	$dir3 = join '/', $uploadDir, substr $dirOpt,0,2;
	last CHECKDIR if !-e $dir3;
}

my $storage3 = WebGUI::Storage->get($session, $dirOpt);

is( $storage3->getErrorCount, 1, 'Error during creation of object due to short GUID');

SKIP: {
	skip 'All directory names already exist', 1 unless $dirOpt;
	ok(!(-e $dir3 and -d $dir3), 'No directories created for short guid');
}

undef $storage3;

$storage1 = WebGUI::Storage->create($session);

isa_ok( $storage1, "WebGUI::Storage");

is( $storage1->getErrorCount, 0, "No errors during object creation");

ok ((-e $storage1->getPath and -d $storage1->getPath), 'directory created correctly');

my $content = <<EOCON;
Hi, I'm a file.
I have two lines.
EOCON

my $filename = $storage1->addFileFromScalar('content', $content);

is ($filename, 'content', 'processed filename returned by addFileFromScalar');

my $filePath = $storage1->getPath($filename);

ok ((-e $filePath and -T $filePath), 'file was created as a text file');

is (-s $filePath, length $content, 'file is the right size');

is ($storage1->getFileSize($filename), length $content, 'getFileSize returns correct size');

open my $fcon, "< ".$filePath or
	die "Unable to open $filePath for reading: $!\n";
my $fileContents;
{
	local undef $/;
	$fileContents = <$fcon>;
}
close $fcon;

is ($fileContents, $content, 'file contents match');

is ($storage1->getFileContentsAsScalar($filename), $content, 'getFileContentsAsScalar matches');

foreach my $extTest (@{ $extensionTests }) {
	is( $storage1->getFileExtension($extTest->{filename}), $extTest->{extension}, $extTest->{comment} );
}

####################################################
#
# addFileFromHashref
#
####################################################

my $storageHash = {'blah'=>"blah",'foo'=>"foo"};
$storage1->addFileFromHashref("testfile-hash.file", $storageHash);
ok (-e $storage1->getPath("testfile-hash.file"), 'addFileFromHashRef creates file');

####################################################
#
# getFileContentsAsHashref
#
####################################################

my $thawedHash = $storage1->getFileContentsAsHashref('testfile-hash.file');
cmp_deeply($storageHash, $thawedHash, 'getFileContentsAsHashref: thawed hash correctly');

####################################################
#
# renameFile
#
####################################################

$storage1->renameFile("testfile-hash.file", "testfile-hash-renamed.file");
ok (-e $storage1->getPath("testfile-hash-renamed.file"),'renameFile created file with new name');
ok (!(-e $storage1->getPath("testfile-hash.file")), "rename file original file is gone");

####################################################
#
# addFileFromFilesystem
#
####################################################

$storage1->addFileFromFilesystem(
    File::Spec->catfile(WebGUI::Test->getTestCollateralPath, 'WebGUI.pm'),
);

ok(
    grep(/WebGUI\.pm/, @{ $storage1->getFiles }),
    'addFileFromFilesystem: file added from test collateral area'
);

####################################################
#
# copy
#
####################################################

my $copiedStorage = $storage1->copy();
cmp_bag($copiedStorage->getFiles(), $storage1->getFiles(), 'copy: both storage objects have the same files');

my $secondCopy = WebGUI::Storage->create($session);
$storage1->copy($secondCopy);
cmp_bag($secondCopy->getFiles(), $storage1->getFiles(), 'copy: passing explicit variable');

my $s3copy = WebGUI::Storage->create($session);
my @filesToCopy = qw/WebGUI.pm testfile-hash-renamed.file/;
$storage1->copy($s3copy, [@filesToCopy]);
cmp_bag($s3copy->getFiles(), [ @filesToCopy ], 'copy: passing explicit variable and files to copy');

####################################################
#
# deleteFile
#
####################################################

is(scalar @{ $storage1->getFiles}, 3, 'storage1 has 2 files');
is($storage1->deleteFile("testfile-hash-renamed.file"), 1, 'deleteFile: deleted 1 file');
is($storage1->deleteFile("WebGUI.pm"), 1, 'deleteFile: deleted another file');
cmp_bag($storage1->getFiles, [$filename], 'deleteFile: storage1 has only 1 file');

####################################################
#
# createTemp
#
####################################################

my $tempStor = WebGUI::Storage->createTemp($session);

isa_ok( $tempStor, "WebGUI::Storage", "createTemp creates WebGUI::Storage object");
is ($tempStor->{_part1}, 'temp', 'createTemp puts stuff in the temp directory');
ok (-e $tempStor->getPath(), 'createTemp: directory was created');

END {
	foreach my $stor ($storage1, $storage2, $storage3, $copiedStorage, $secondCopy, $s3copy, $tempStor) {
		ref $stor eq "WebGUI::Storage" and $stor->delete;
	}
}
