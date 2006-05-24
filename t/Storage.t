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

use Test::More;

plan tests => 26; # increment this value for each test you create

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

is ($storageDir1, $storage1->getPath, 'path calculated correctly');

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

is( ref $storage1, "WebGUI::Storage", "create returns a WebGUI Storage object");

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

TODO: {
	local $TODO = "Tests to make later";
	ok(0, 'Add a file to the storage location via addFileFromFilesystem');
	ok(0, 'Add a file to the storage location via addFileFromHashref');
	ok(0, 'Test renaming of files inside of a storage location');
}

END {
	foreach my $stor ($storage1, $storage2, $storage3) {
		ref $stor eq "WebGUI::Storage" and $stor->delete;
	}
}
