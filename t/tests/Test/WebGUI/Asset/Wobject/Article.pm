package Test::WebGUI::Asset::Wobject::Article;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset::Wobject/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData wobject Article/];
}

sub getStorageLocation : Test(2) {
    my $test    = shift;
    my $session = $test->session;
    my $asset   = $test->class->new({session => $session});
    my $storage = $asset->getStorageLocation();
    isa_ok $storage, 'WebGUI::Storage';
    is $asset->storageId, $storage->getId, 'asset updated with storageId';
    WebGUI::Test->addToCleanup($storage);
}

1;
