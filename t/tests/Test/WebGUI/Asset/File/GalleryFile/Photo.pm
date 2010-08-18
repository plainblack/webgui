package Test::WebGUI::Asset::File::GalleryFile::Photo;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset::File::GalleryFile/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData FileAsset GalleryFile Photo/];
}

sub dynamic_form_labels { return 'New file to upload' };

sub constructorExtras {
    my $test = shift;
    my $session = shift or die;
    my $storage = WebGUI::Storage->create($session);
    WebGUI::Test->addToCleanup($storage);
    my $filename = $storage->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('gooey.jpg'));
    # return storageId => $storage->getId;
    warn "XXX filename: $filename";
    # return filename => $filename;
    return filename => $filename, storageId => $storage->getId;
}

1;
