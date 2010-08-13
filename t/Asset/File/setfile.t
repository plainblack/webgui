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
use lib "$FindBin::Bin/../../lib";

## The goal of this test is to test the creation and deletion of photo assets

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::File;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"File Test"});
WebGUI::Test->addToCleanup($versionTag);
my $file
    = $node->addChild({
        className           => "WebGUI::Asset::File",
    });
$versionTag->commit;
WebGUI::Test->addToCleanup($versionTag);

#----------------------------------------------------------------------------
# Tests
plan tests => 2;

#----------------------------------------------------------------------------
# setFile allows file path argument and fails if can't find file
# plan tests => 1
ok(
    !eval { $file->setFile( WebGUI::Test->getTestCollateralPath("DOES_NOT_EXIST.NO") ); 1},
    "setFile allows file path argument and croaks if can't find file"
);

#----------------------------------------------------------------------------
# setFile allows file path argument and adds the file
# plan tests => 1
$file->setFile( WebGUI::Test->getTestCollateralPath("International/lib/WebGUI/i18n/PigLatin/WebGUI.pm") );
my $storage = $file->getStorageLocation;

is_deeply(
    $storage->getFiles, ['WebGUI_pm.txt'],
    "Storage location contains only the file we added, name was changed to prevent uploading of code",
);

#vim:ft=perl
