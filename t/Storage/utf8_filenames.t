#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

#The goal of this test is to checkout uft8 handling in filenames.

use FindBin;
use strict;
use lib "$FindBin::Bin/..//lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;

use Test::More;
use Test::Deep;
use Encode;
use Cwd ();

my $session = WebGUI::Test->session;

plan tests => 4;

my $storage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($storage);

my $filename = "Viel_Spa\x{00DF}.txt";
utf8::upgrade($filename);
$storage->addFileFromScalar($filename, 'some content');
ok -e $storage->getPath($filename), 'addFileFromScalar: wrote filename with UTF-8 name';

my $filesystem_storage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($filesystem_storage);

$filesystem_storage->addFileFromFilesystem($storage->getPath($filename));
ok -e $filesystem_storage->getPath($filename), 'addFileFromFilesystem: brought file over with UTF-8 name';

cmp_deeply(
    $filesystem_storage->getFiles(),
    [ $filename ],
    'getFiles: returns names in UTF-8'
);

my $copy_name = "Ca\x{00F1}on.txt";
utf8::upgrade($copy_name);
$filesystem_storage->copyFile($filename, $copy_name);

cmp_bag(
    $filesystem_storage->getFiles(),
    [ $filename, $copy_name ],
    'copyFile: copies files handling UTF-8 correctly'
);
