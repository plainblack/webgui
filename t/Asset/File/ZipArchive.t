#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;

use WebGUI::Storage;
use WebGUI::Asset;
use WebGUI::Asset::File::ZipArchive;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 3;

my $session = WebGUI::Test->session;

my $node = WebGUI::Asset->getImportNode($session);

my $arch = $node->addChild({
    className => 'WebGUI::Asset::File::ZipArchive',
});

WebGUI::Test->addToCleanup($arch);

my $storage = $arch->getStorageLocation;
$storage->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('extensions.tar'));
ok($arch->unzip($storage, 'extensions.tar'), 'unzip returns true when it successfully unpacked');

$arch->fixFilenames();

cmp_bag(
    $storage->getFiles, 
    [ qw{ extensions.tar extension_pm.txt extension_perl.txt extension.html extensions extensions/extension.html }], 
    'files after fixFilenames, html files left alone'
);

$storage->addFileFromScalar('file.pm.pm','content');
$arch->fixFilenames();

cmp_bag(
    $storage->getFiles, 
    [ qw{ extensions.tar extension_pm.txt extension_perl.txt extension.html extensions extensions/extension.html file_pm.pm.txt}], 
    'fixFilenames: anchors replacements to the end of the string'
);
