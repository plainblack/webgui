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
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::PseudoRequest;

use File::Spec;
use File::Temp qw/tempdir/;
use Image::Magick;
use Test::More;
use Test::Deep;
use Test::MockObject;
use Cwd;
use Path::Class::Dir;

my $session = WebGUI::Test->session;

my $cwd = Cwd::cwd();

my ($extensionTests, $fileIconTests) = setupDataDrivenTests($session);

my $numTests = 140; # increment this value for each test you create
plan tests => $numTests + scalar @{ $extensionTests } + scalar @{ $fileIconTests };

my $uploadDir = $session->config->get('uploadsPath');
ok ($uploadDir, "uploadDir defined in config");

my $uploadUrl = $session->config->get('uploadsURL');
ok ($uploadUrl, "uploadDir defined in config");

####################################################
#
# get, getId
#
####################################################

ok ((-e $uploadDir and -d $uploadDir), "uploadDir exists and is a directory");

my $storage1 = WebGUI::Storage->get($session);

is( $storage1, undef, "get requires id to be passed");

$storage1 = WebGUI::Storage->get($session, 'foobar');
addToCleanup($storage1);

isa_ok( $storage1, "WebGUI::Storage", "storage will accept non GUID arguments");
is ( $storage1->getId, 'foobar', 'getId returns the requested GUID');

is( $storage1->getErrorCount, 0, "No errors during path creation");

is( $storage1->getLastError, undef, "No errors during path creation");

####################################################
#
# getPathFrag, getDirectoryId, get
#
####################################################

is( $storage1->getPathFrag,    '7e/8a/7e8a1b6a', 'pathFrag returns correct value');
is( $storage1->getDirectoryId, '7e8a1b6a',       'getDirectoryId returns the last path element');

##Build an old-style GUID storage location
my $uploadsBase = Path::Class::Dir->new($uploadDir);
my $newGuid = $session->id->generate();
my @guidPathParts = (substr($newGuid, 0, 2), substr($newGuid, 2, 2), $newGuid);
my $guidDir = $uploadsBase->subdir(@guidPathParts);
$guidDir->mkpath();
ok(-e $guidDir->stringify, 'created GUID storage location for backwards compatibility testing');

my $guidStorage = WebGUI::Storage->get($session, $newGuid);
addToCleanup($guidStorage);
isa_ok($guidStorage, 'WebGUI::Storage');
is($guidStorage->getId, $newGuid, 'GUID storage has correct id');
is($guidStorage->getDirectoryId, $newGuid, '... getDirectoryId');

####################################################
#
# getPath, getUrl
#
####################################################

WebGUI::Test->originalConfig('cdn');
$session->config->delete('cdn');
# Note: the CDN configuration will be reverted after CDN tests below

my $storageDir1 = join '/', $uploadDir, '7e', '8a', '7e8a1b6a';
is ($storage1->getPath, $storageDir1, 'getPath: path calculated correctly for directory');
my $storageFile1 = join '/', $storageDir1, 'baz';
is ($storage1->getPath('baz'), $storageFile1, 'getPath: path calculated correctly for file');

my $storageUrl1 = join '/', $uploadUrl, '7e', '8a', '7e8a1b6a';
is ($storage1->getUrl, $storageUrl1, 'getUrl: url calculated correctly for directory');
my $storageUrl2 = join '/', $storageUrl1, 'bar';
is ($storage1->getUrl('bar'), $storageUrl2, 'getUrl: url calculated correctly for file');

ok( (-e $storageDir1 and -d $storageDir1), "Storage location created and is a directory");

$storage1->delete;

ok( !(-e $storageDir1), "Storage location deleted");

undef $storage1;

$storage1 = WebGUI::Storage->get($session, 'notAGUID');
my $storage2 = WebGUI::Storage->get($session, 'notAGoodId');
addToCleanup($storage2);

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
addToCleanup($storage3);

is( $storage3->getErrorCount, 1, 'Error during creation of object due to short GUID');

SKIP: {
	skip 'All directory names already exist', 1 unless $dirOpt;
	ok(!(-e $dir3 and -d $dir3), 'No directories created for short guid');
}

undef $storage3;

####################################################
#
# create, getHexId
#
####################################################

$storage1 = WebGUI::Storage->create($session);

isa_ok( $storage1, "WebGUI::Storage");
ok($session->id->valid($storage1->getId), 'create returns valid sessionIds');
ok($storage1->getHexId, 'getHexId returns something');
is($storage1->getHexId, $session->id->toHex($storage1->getId), '... returns the hexadecimal value of the GUID');

{
    my $otherStorage = WebGUI::Storage->get($session, $storage1->getId);
    is($otherStorage->getHexId, $storage1->getHexId, '... works with get');
}

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
	local $/;
	$fileContents = <$fcon>;
}
close $fcon;

is ($fileContents, $content, 'file contents match');

is ($storage1->getFileContentsAsScalar($filename), $content, 'getFileContentsAsScalar matches');

isnt($/, undef, 'getFileContentsAsScalar did not change $/');

foreach my $extTest (@{ $extensionTests }) {
	is( $storage1->getFileExtension($extTest->{filename}), $extTest->{extension}, $extTest->{comment} );
}

####################################################
#
# getFiles
#
####################################################

my $fileStore = WebGUI::Storage->create($session);
addToCleanup($fileStore);
cmp_bag($fileStore->getFiles(1), ['.'], 'Starting with an empty storage object, no files in here except for . ');
$fileStore->addFileFromScalar('.dotfile', 'dot file');
cmp_bag($fileStore->getFiles(),  [                     ], 'getFiles() by default does not return dot files');
cmp_bag($fileStore->getFiles(1), ['.', '.dotfile'], 'getFiles(1) returns all files, including dot files');
$fileStore->addFileFromScalar('dot.file', 'dot.file');
cmp_bag($fileStore->getFiles(),  ['dot.file'],            'getFiles() returns normal files');
cmp_bag($fileStore->getFiles(1), ['.', '.dotfile', 'dot.file'], 'getFiles(1) returns all files, including dot files');

####################################################
#
# getPathClassDir
#
####################################################

my $obj = $storage1->getPathClassDir;
isa_ok($obj, 'Path::Class::Dir');
is($obj->stringify, $storage1->getPath, '... Path::Class::Dir object has correct path');

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
    WebGUI::Test->getTestCollateralPath('WebGUI.pm'),
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
addToCleanup($copiedStorage);
cmp_bag($copiedStorage->getFiles(), $storage1->getFiles(), 'copy: both storage objects have the same files');

my $secondCopy = WebGUI::Storage->create($session);
addToCleanup($secondCopy);
$storage1->copy($secondCopy);
cmp_bag($secondCopy->getFiles(), $storage1->getFiles(), 'copy: passing explicit variable');

my $s3copy = WebGUI::Storage->create($session);
addToCleanup($s3copy);
my @filesToCopy = qw/WebGUI.pm testfile-hash-renamed.file/;
$storage1->copy($s3copy, [@filesToCopy]);
cmp_bag($s3copy->getFiles(), [ @filesToCopy ], 'copy: passing explicit variable and files to copy');
{
    my $deepStorage = WebGUI::Storage->create($session);
    addToCleanup($deepStorage);
    my $deepDir     = $deepStorage->getPathClassDir();
    my $deepDeepDir = $deepDir->subdir('deep');
    my $errorStr;
    my @foo = $deepDeepDir->mkpath({ error => \$errorStr } );
    $deepStorage->addFileFromScalar('deep/file', 'deep file');
    cmp_bag(
        $deepStorage->getFiles('all'),
        [ '.', 'deep', 'deep/file' ],
        '... storage setup for deep clear test'
    );
    my $deepCopy = $deepStorage->copy();
    addToCleanup($deepCopy);
    cmp_bag(
        $deepCopy->getFiles('all'),
        [ '.', 'deep', 'deep/file' ],
        '... all files copied, deeply'
    );
}


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
addToCleanup($hackedStore);
$hackedStore->addFileFromScalar('fileToHack', 'Can this file be deleted from another object?');
ok(-e $hackedStore->getPath('fileToHack'), 'set up a file for deleteFile to try and delete illegally');
my $hackedPath = '../../../'.$hackedStore->getPathFrag().'/fileToHack';
is($storage1->deleteFile($hackedPath), undef, 'deleteFile into another storage returns undef');
ok(-e $hackedStore->getPath('fileToHack'), 'deleteFile did not delete the file in another storage object');

####################################################
#
# createTemp, getHexId
#
####################################################

my $tempStor = WebGUI::Storage->createTemp($session);
addToCleanup($tempStor);

isa_ok( $tempStor, "WebGUI::Storage", "createTemp creates WebGUI::Storage object");
is (substr($tempStor->getPathFrag, 0, 5), 'temp/', '... puts stuff in the temp directory');
ok (-e $tempStor->getPath(), '... directory was created');
ok($tempStor->getHexId, '... getHexId returns something');
is($tempStor->getHexId, $session->id->toHex($tempStor->getId), '... returns the hexadecimal value of the GUID');

####################################################
#
# tar
#
####################################################

my $tarStorage = $copiedStorage->tar('tar.tar');
addToCleanup($tarStorage);
isa_ok( $tarStorage, "WebGUI::Storage", "tar: returns a WebGUI::Storage object");
is (substr($tarStorage->getPathFrag, 0, 5), 'temp/', 'tar: puts stuff in the temp directory');
cmp_bag($tarStorage->getFiles(), [ 'tar.tar' ], 'tar: storage contains only the tar file');
isnt($tarStorage->getPath, $copiedStorage->getPath, 'tar did not reuse the same path as the source storage object');

####################################################
#
# untar
#
####################################################

my $untarStorage = $tarStorage->untar('tar.tar');
addToCleanup($untarStorage);
isa_ok( $untarStorage, "WebGUI::Storage", "untar: returns a WebGUI::Storage object");
is (substr($untarStorage->getPathFrag, 0, 5), 'temp/', 'untar: puts stuff in the temp directory');
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
cmp_bag(
    $copiedStorage->getFiles('all'),
    [ '.' ],
    'clear removed all files from copiedStorage'
);
cmp_bag(
    $copiedStorage->getFiles('all'),
    [ '.' ],
    '... removed _all_ files from copiedStorage, except for . and ..'
);

$copiedStorage->setPrivileges(3,3,3);
cmp_bag(
    $copiedStorage->getFiles('all'),
    [ '.', '.wgaccess' ],
    '... removed _all_ files from copiedStorage, except for . and ..'
);
$copiedStorage->clear;
cmp_bag(
    $copiedStorage->getFiles('all'),
    [ '.' ],
    '... removed .wgaccess file'
);

{
    my $deepStorage = WebGUI::Storage->create($session);
    addToCleanup($deepStorage);
    my $deepDir     = $deepStorage->getPathClassDir();
    my $deepDeepDir = $deepDir->subdir('deep');
    my $errorStr;
    $deepDeepDir->mkpath({ error => \$errorStr } );
    $deepStorage->addFileFromScalar('deep/file', 'deep file');
    cmp_bag(
        $deepStorage->getFiles('all'),
        [ '.', 'deep', 'deep/file' ],
        '... storage setup for deep clear test'
    );
    $deepStorage->clear();
    cmp_bag(
        $deepStorage->getFiles('all'),
        [ '.', ],
        '... clear removes directories'
    );
}

####################################################
#
# addFileFromFormPost
#
####################################################

$session->http->setStatus(413);
is($fileStore->addFileFromFormPost(), '', 'addFileFromFormPost returns empty string when HTTP status is 413');

$session->http->setStatus(200);
$session->request->upload('files', []);
my $formStore = WebGUI::Storage->create($session);
addToCleanup($formStore);
is($formStore->addFileFromFormPost('files'), undef, 'addFileFromFormPost returns empty string when asking for a form variable with no files attached');

$session->request->uploadFiles(
    'oneFile',
    [ WebGUI::Test->getTestCollateralPath('WebGUI.pm') ],
);
is($formStore->addFileFromFormPost('oneFile'), 'WebGUI.pm', '... returns the name of the uploaded file');
cmp_bag($formStore->getFiles, [ qw/WebGUI.pm/ ], '... adds the file to the storage location');

$session->request->uploadFiles(
    'thumbFile',
    [ WebGUI::Test->getTestCollateralPath('thumb-thumb.gif') ],
);
is($formStore->addFileFromFormPost('thumbFile'), 'thumb.gif', '... strips thumb- prefix from files');
cmp_bag($formStore->getFiles, [ qw/WebGUI.pm thumb.gif/ ], '... adds the file to the storage location');

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
# setPrivileges
#
####################################################

my $shallowStorage = WebGUI::Storage->create($session);
addToCleanup($shallowStorage);
$shallowStorage->setPrivileges(3,3,3);
my $shallowDir = $shallowStorage->getPathClassDir();
ok(-e $shallowDir->file('.wgaccess')->stringify, 'setPrivilege: .wgaccess file created in shallow storage');
my $privs;
$privs = $shallowStorage->getFileContentsAsScalar('.wgaccess');
is ($privs, '{"assets":[],"groups":["3","3"],"users":["3"]}', '... correct group contents');
$shallowStorage->deleteFile('.wgaccess');

my $deepStorage = WebGUI::Storage->create($session);
addToCleanup($deepStorage);
my $deepDir     = $deepStorage->getPathClassDir();
my $deepDeepDir = $deepDir->subdir('deep');
my $errorStr;
$deepDeepDir->mkpath({ error => \$errorStr } );
ok(-e $deepDeepDir->stringify, 'created storage directory with a subdirectory for testing');

$deepStorage->setPrivileges(3,3,3);
ok(-e $deepDir->file('.wgaccess')->stringify,     '.wgaccess file created in deep storage');
ok(-e $deepDeepDir->file('.wgaccess')->stringify, '.wgaccess file created in deep storage subdir');

$privs = $deepStorage->getFileContentsAsScalar('.wgaccess');
is ($privs, '{"assets":[],"groups":["3","3"],"users":["3"]}', '... correct group contents, deep storage');
$privs = $deepStorage->getFileContentsAsScalar('deep/.wgaccess');
is ($privs, '{"assets":[],"groups":["3","3"],"users":["3"]}', '... correct group contents, deep storage subdir');

{
    my $storage = WebGUI::Storage->create($session);
    addToCleanup($storage);
    my $asset = WebGUI::Asset->getRoot($session);
    $storage->setPrivileges( $asset );
    my $accessFile = $storage->getPathClassDir->file('.wgaccess');
    ok(-e $accessFile, 'setPrivilege: .wgaccess file created for asset permissions');
    my $privs = $accessFile->slurp;
    is ($privs, '{"assets":["' . $asset->getId . '"],"groups":[],"users":[]}', '... correct asset contents');
}

####################################################
#
# rotate
#
####################################################

# Create new storage for test of 'rotate' method
my $rotateTestStorage = WebGUI::Storage->create($session);
addToCleanup($rotateTestStorage);

# Add test image from file system
my $file = "rotation_test.png";
$rotateTestStorage->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath($file) );

# Rotate image by 90° CW
$rotateTestStorage->rotate( $file, 90 );

# Test based on dimensions
cmp_deeply( [ $rotateTestStorage->getSizeInPixels($file) ], [ 3, 2 ], "rotate: check if image was rotated by 90° CW (based on dimensions)" );
# Test based on single pixel
my $image = new Image::Magick;
$image->Read( $rotateTestStorage->getPath( $file ) );
is( $image->GetPixel( x=>3, y=>1 ), 1, "rotate: check if image was rotated by 90° CW (based on pixels)");

# Rotate image by 90° CCW
$rotateTestStorage->rotate( $file, -90 );

# Test based on dimensions
cmp_deeply( [ $rotateTestStorage->getSizeInPixels($file) ], [ 2, 3 ], "rotate: check if image was rotated by 90° CCW (based on dimensions)" );
# Test based on single pixel
my $image = new Image::Magick;
$image->Read( $rotateTestStorage->getPath( $file ) );
is( $image->GetPixel( x=>1, y=>1 ), 1, "rotate: check if image was rotated by 90° CCW (based on pixels)");

####################################################
#
# CDN (Content Delivery Network)
#
####################################################

my $cdnTestPath      = tempdir();
my $cdnQueueTestPath = tempdir();

my $cdnCfg = {
    "enabled"       => 1,
    "url"           => "file://$cdnTestPath",
    "queuePath"     => $cdnQueueTestPath,
    "syncProgram"   => "cp -r -- '%s' $cdnTestPath/",
    "deleteProgram" => "rm -r -- '$cdnTestPath/%s' > /dev/null 2>&1"
};
my $dest = substr($cdnCfg->{'url'}, 7);
$session->config->set('cdn', $cdnCfg);
my $cdnUrl = $cdnCfg->{'url'};
my $cdnUlen = length $cdnUrl;
my $cdnStorage = WebGUI::Storage->create($session);
addToCleanup($cdnStorage);
# Functional URL before sync done
my $hexId = $session->id->toHex($cdnStorage->getId);
my $initUrl = join '/', $uploadUrl, $cdnStorage->getPathFrag;
is ($cdnStorage->getUrl, $initUrl, 'CDN: getUrl: URL before sync');
$filename = $cdnStorage->addFileFromScalar('cdnfile1', $content);
is ($filename, 'cdnfile1', 'CDN: filename returned by addFileFromScalar');
my $qFile = $cdnCfg->{'queuePath'} . '/' . $session->id->toHex($cdnStorage->getId);
my $dotCdn = $cdnStorage->getPath . '/.cdn';
ok (-e $qFile, 'CDN: queue file created when file added to storage');

### getCdnFileIterator
my $found = 0;
my $sobj = undef;
my $flist;
my $cdnPath = substr($cdnUrl, 7) . '/' . $hexId;
my $cdnFn = $cdnPath . '/' . $filename;
my $locIter = WebGUI::Storage->getCdnFileIterator($session);
my $already;  # test the object type only once
if (is(ref($locIter), 'CODE', 'CDN: getCdnFileIterator to return sub ref')) {
   while (my $sobj = $locIter->()) {
      unless ($already) {
         ok($sobj->isa('WebGUI::Storage'), 'CDN: iterator produces Storage objects');
         $already = 1;
      }
      if ($sobj->getId eq $cdnStorage->getId) {  # the one we want to test with
         ++$found;
         $flist = $sobj->getFiles;
         if (is(scalar @$flist, 1, 'CDN: there is one file in the storage')) {
            my $file1 = $flist->[0];
            is ($file1, $filename, 'CDN: correct filename in the storage');
         }
      }
   }
}
is ($found, 1, 'CDN: getCdnFileIterator found storage');
### syncToCdn
$cdnStorage->syncToCdn;
ok( (-e $cdnPath and -d $cdnPath), 'CDN: target directory created');
ok( (-e $cdnFn and -T $cdnFn), 'CDN: target text file created');
is (-s $cdnFn, length $content, 'CDN: file is the right size');
ok (!(-e $qFile), 'CDN: queue file removed after sync');
ok (-e $dotCdn, 'CDN: dot-cdn flag file present after sync');
### getUrl with CDN
my $locUrl = $cdnUrl . '/' . $session->id->toHex($cdnStorage->getId);
is ($cdnStorage->getUrl, $locUrl, 'CDN: getUrl: URL for directory');
my $fileUrl = $locUrl . '/' . 'cdn-file';
is ($cdnStorage->getUrl('cdn-file'), $fileUrl, 'CDN: getUrl: URL for file');
# SSL
my %mockEnv = %ENV;
my $env = Test::MockObject::Extends->new($session->env);
$env->mock('get', sub { return $mockEnv{$_[1]} } );
$mockEnv{HTTPS} = 'on';
$cdnCfg->{'sslAlt'} = 1;
$session->config->set('cdn', $cdnCfg);
is ($cdnStorage->getUrl, $initUrl, 'CDN: getUrl: URL with sslAlt flag');
$cdnCfg->{'sslUrl'} = 'https://ssl.example.com';
$session->config->set('cdn', $cdnCfg);
my $sslUrl = $cdnCfg->{'sslUrl'} . '/' . $session->id->toHex($cdnStorage->getId);
is ($cdnStorage->getUrl, $sslUrl, 'CDN: getUrl: sslUrl');
$mockEnv{HTTPS} = undef;
is ($cdnStorage->getUrl, $locUrl, 'CDN: getUrl: cleartext request to not use sslUrl');
# Copy
my $cdnCopy = $cdnStorage->copy;
addToCleanup($cdnCopy);
my $qcp = $cdnCfg->{'queuePath'} . '/' . $session->id->toHex($cdnCopy->getId);
ok (-e $qcp, 'CDN: queue file created when storage location copied');
my $dotcp = $cdnCopy->getPath . '/.cdn';
ok (!(-e $dotcp), 'CDN: dot-cdn flag file absent after copy');
# On clear, need to see the entry in cdnQueue
$qFile = $cdnCfg->{'queuePath'} . '/' . $session->id->toHex($cdnStorage->getId);
$cdnStorage->clear;
ok (-e $qFile, 'CDN: queue file created when storage cleared');
ok (-s $qFile >= 7 && -s $qFile <= 9, 'CDN: queue file has right size for deleted (clear)');
ok (!(-e $dotCdn), 'CDN: dot-cdn flag file absent after clear');
### deleteFromCdn
$cdnStorage->deleteFromCdn;
ok(! (-e $cdnPath), 'CDN: target directory removed');
ok(! (-e $qFile), 'CDN: queue file removed');
# Idea: add a file back before testing delete
# Note: expect it is necessary to be able to delete after clear.
# On delete, need to see the entry in cdnQueue
$cdnStorage->delete;
ok (-e $qFile, 'CDN: queue file created when storage deleted');
ok (-s $qFile >= 7 && -s $qFile <= 9, 'CDN: queue file has right size for deleted');
$cdnStorage->deleteFromCdn;
ok(! (-e $qFile), 'CDN: queue file removed');

# partial cleanup here; complete cleanup in END block
undef $cdnStorage;
$session->config->delete('cdn');


####################################################
#
# Test what happens when the directory for a
# storage object does not exist.
#
####################################################

my $zombieStorage = WebGUI::Storage->create($session);
addToCleanup($zombieStorage);
my $zombieDir = $zombieStorage->getPathClassDir;
$zombieDir->remove;

is( $zombieStorage->getPathClassDir,       undef, 'bad storage: getPathClassDir returns undef');
cmp_deeply( $zombieStorage->getFiles,         [], '... getFiles returns an empty array ref');
cmp_deeply( $zombieStorage->setPrivileges, undef, '... setPrivileges returns undef');
cmp_deeply( $zombieStorage->clear,         undef, '... setPrivileges returns undef');

####################################################
#
# Make sure after all this that our CWD is still the same
#
####################################################

is($cwd, Cwd::cwd(), 'CWD must remain the same after addFileFromFilesystem, tar, untar, etc...');

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
