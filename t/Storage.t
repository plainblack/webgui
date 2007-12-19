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
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::PseudoRequest;

use File::Spec;
use Test::More;
use Test::Deep;
use Test::MockObject;

my $session = WebGUI::Test->session;

my ($extensionTests, $fileIconTests) = setupDataDrivenTests($session);

my $numTests = 81; # increment this value for each test you create
plan tests => $numTests + scalar @{ $extensionTests } + scalar @{ $fileIconTests };

my $uploadDir = $session->config->get('uploadsPath');
ok ($uploadDir, "uploadDir defined in config");

my $uploadUrl = $session->config->get('uploadsURL');
ok ($uploadUrl, "uploadDir defined in config");

my $originalCaseInsensitiveOS = $session->config->get('caseInsensitiveOS');
$session->config->set('caseInsensitiveOS', 0);

####################################################
#
# get, getId
#
####################################################

ok ((-e $uploadDir and -d $uploadDir), "uploadDir exists and is a directory");

my $storage1 = WebGUI::Storage->get($session);

is( $storage1, undef, "get requires id to be passed");

$storage1 = WebGUI::Storage->get($session, 'foobar');

isa_ok( $storage1, "WebGUI::Storage", "storage will accept non GUID arguments");
is ( $storage1->getId, 'foobar', 'getId returns the requested GUID');

is( $storage1->getErrorCount, 0, "No errors during path creation");

is( $storage1->getLastError, undef, "No errors during path creation");

####################################################
#
# getPathFrag
#
####################################################

is( $storage1->getPathFrag, 'fo/ob/foobar');

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

## NOTE: On case insensitive file systems more matches can occur on this test
## and if all of these exist, then the next test will fail.

my @dirOptions = qw/bad bAd Bad BAd Zod God Mod Tod Rod Bod Lod/;

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

####################################################
#
# create
#
####################################################

$storage1 = WebGUI::Storage->create($session);

isa_ok( $storage1, "WebGUI::Storage");
ok($session->id->valid($storage1->getId), 'create returns valid sessionIds');
is($storage1->getId, $storage1->getFileId, 'getId and getFileId are the same when caseInsensitiveOS=0');

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
# copyFile
#
####################################################

$storage1->copyFile("testfile-hash.file", "testfile-hash-copied.file");
ok (-e $storage1->getPath("testfile-hash-copied.file"),'copyFile created file with new name');
ok (-e $storage1->getPath("testfile-hash.file"), "copyFile original file still exists");

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

is(scalar @{ $storage1->getFiles }, 4, 'storage1 has 4 files');
is($storage1->deleteFile("testfile-hash-renamed.file"), 1, 'deleteFile: deleted 1 file');
is($storage1->deleteFile("testfile-hash-copied.file"), 1, 'deleteFile: deleted 1 file');
is($storage1->deleteFile("WebGUI.pm"), 1, 'deleteFile: deleted another file');
cmp_bag($storage1->getFiles, [$filename], 'deleteFile: storage1 has only 1 file');

##Test for out of object file deletion
my $hackedStore = WebGUI::Storage->create($session);
$hackedStore->addFileFromScalar('fileToHack', 'Can this file be deleted from another object?');
ok(-e $hackedStore->getPath('fileToHack'), 'set up a file for deleteFile to try and delete illegally');
my $hackedPath = '../../../'.$hackedStore->getPathFrag().'/fileToHack';
is($storage1->deleteFile($hackedPath), undef, 'deleteFile into another storage returns undef');
ok(-e $hackedStore->getPath('fileToHack'), 'deleteFile did not delete the file in another storage object');

####################################################
#
# createTemp
#
####################################################

my $tempStor = WebGUI::Storage->createTemp($session);

isa_ok( $tempStor, "WebGUI::Storage", "createTemp creates WebGUI::Storage object");
is ($tempStor->{_part1}, 'temp', 'createTemp puts stuff in the temp directory');
use Data::Dumper;
diag Dumper $tempStor->getErrors();
ok (-e $tempStor->getPath(), 'createTemp: directory was created');

####################################################
#
# tar
#
####################################################

my $tarStorage = $copiedStorage->tar('tar.tar');
isa_ok( $tarStorage, "WebGUI::Storage", "tar: returns a WebGUI::Storage object");
is ($tarStorage->{_part1}, 'temp', 'tar: puts stuff in the temp directory');
cmp_bag($tarStorage->getFiles(), [ 'tar.tar' ], 'tar: storage contains only the tar file');
isnt($tarStorage->getPath, $copiedStorage->getPath, 'tar did not reuse the same path as the source storage object');

####################################################
#
# untar
#
####################################################

my $untarStorage = $tarStorage->untar('tar.tar');
isa_ok( $untarStorage, "WebGUI::Storage", "untar: returns a WebGUI::Storage object");
is ($untarStorage->{_part1}, 'temp', 'untar: puts stuff in the temp directory');
##Note, getFiles will NOT recurse, so do not use a deep directory structure here
cmp_bag($untarStorage->getFiles, $copiedStorage->getFiles, 'tar and untar loop preserve all files');
isnt($untarStorage->getPath, $tarStorage->getPath, 'untar did not reuse the same path as the tar storage object');

####################################################
#
# clear
#
####################################################

ok(scalar @{ $copiedStorage->getFiles } > 0, 'copiedStorage has some files');
$copiedStorage->clear;
cmp_ok(scalar @{ $copiedStorage->getFiles }, '==', 0, 'clear removed all files from copiedStorage');
cmp_ok(scalar @{ $copiedStorage->getFiles(1) }, '==', 2, 'clear removed _all_ files from copiedStorage, except for . and ..');

####################################################
#
# getFiles
#
####################################################

my $fileStore = WebGUI::Storage->create($session);
cmp_bag($fileStore->getFiles(1), ['.', '..'], 'Starting with an empty storage object, no files in here except for . and ..');
$fileStore->addFileFromScalar('.dotfile', 'dot file');
cmp_bag($fileStore->getFiles(),  [                     ], 'getFiles() by default does not return dot files');
cmp_bag($fileStore->getFiles(1), ['.', '..', '.dotfile'], 'getFiles(1) returns all files, including dot files');
$fileStore->addFileFromScalar('dot.file', 'dot.file');
cmp_bag($fileStore->getFiles(),  ['dot.file'],            'getFiles() returns normal files');
cmp_bag($fileStore->getFiles(1), ['.', '..', '.dotfile', 'dot.file'], 'getFiles(1) returns all files, including dot files');

####################################################
#
# Hexadecimal File Ids
#
####################################################

$session->config->set('caseInsensitiveOS', 1);

my $hexStorage = WebGUI::Storage->create($session);
ok($session->id->valid($hexStorage->getId), 'create returns valid sessionIds in hex mode');
isnt($hexStorage->getId, $hexStorage->getFileId, 'getId != getFileId when caseInsentiveOS=1');
is($session->id->toHex($hexStorage->getId), $hexStorage->getFileId, 'Hex value of GUID calculated correctly');
my ($hexValue) = $session->db->quickArray('select hexValue,guidValue from storageTranslation where guidValue=?',[$hexStorage->getId]);
is($hexStorage->getFileId, $hexValue, 'hexValue cached in the storageTranslation table');
my ($part1, $part2) = unpack "A2A2A*", $hexStorage->getFileId;  #fancy m/(..)(..)/;
is ($hexStorage->{_part1}, $part1, 'Storage part1 uses hexId');
is ($hexStorage->{_part2}, $part2, 'Storage part2 uses hexId, too');
like ($hexStorage->getPath, qr/$hexValue/, 'Storage path uses hexId');

$session->config->set('caseInsensitiveOS', 0);

####################################################
#
# addFileFromFormPost
#
####################################################

my $pseudoRequest = WebGUI::PseudoRequest->new();
$session->{_request} = $pseudoRequest;

$session->http->setStatus(413);
is($fileStore->addFileFromFormPost(), '', 'addFileFromFormPost returns empty string when HTTP status is 413');

$session->http->setStatus(200);
$pseudoRequest->upload('files', []);
is($fileStore->addFileFromFormPost('files'), undef, 'addFileFromFormPost returns empty string when asking for a form variable with no files attached');

$pseudoRequest->uploadFiles(
    'oneFile',
    [ File::Spec->catfile( WebGUI::Test->getTestCollateralPath, qw/WebGUI.pm/) ],
);
is($fileStore->addFileFromFormPost('oneFile'), 'WebGUI.pm', 'Return the name of the uploaded file');

####################################################
#
# getFileIconUrl
#
####################################################

foreach my $iconTest (@{ $fileIconTests }) {
	is( $storage1->getFileIconUrl($iconTest->{filename}), $iconTest->{iconUrl}, $iconTest->{comment} );
}


####################################################
#
# Make sure after all this that our CWD is still the same
#
####################################################

TODO: {
    local $TODO = 'Write a test to ensure our CWD remains the same after all these calls to storage';
    ok(0,'CWD must remain the same after addFileFromFilesystem, tar, untar, etc...');
};

####################################################
#
# Setup data driven tests here, to keep the top part of the
# test clean.
#
####################################################

sub setupDataDrivenTests {
    my $session = shift;
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

    my $fileIconTests = [
        {
            filename => 'filename',
            iconUrl  => $session->url->extras("fileIcons/unknown.gif"),
            comment  => 'no extension uses unknown icon',
        },
        {
            filename => 'filename.txt',
            iconUrl  => $session->url->extras("fileIcons/txt.gif"),
            comment  => 'valid extension, lower case works',
        },
        {
            filename => 'filename.TXT',
            iconUrl  => $session->url->extras("fileIcons/txt.gif"),
            comment  => 'valid extension, upper case works',
        },
        {
            filename => 'filename.00TXT00',
            iconUrl  => $session->url->extras("fileIcons/unknown.gif"),
            comment  => 'unknown extension',
        },
    ];

    return ($extensionTests, $fileIconTests)
}

####################################################
#
# END block, clean-up after yourself
#
####################################################

END {
	foreach my $stor (
        $storage1,   $storage2, $storage3, $copiedStorage,
        $secondCopy, $s3copy,   $tempStor, $tarStorage,
        $untarStorage, $fileStore,
        $hackedStore,
    ) {
		ref $stor eq "WebGUI::Storage" and $stor->delete;
	}
    $session->config->set('caseInsensitiveOS', $originalCaseInsensitiveOS);
}
