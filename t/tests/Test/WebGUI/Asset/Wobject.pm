package Test::WebGUI::Asset::Wobject;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData wobject/];
}

sub t_15_getStyleTemplateId : Test(2) {
    note "getStyleTemplateId";
    my ( $test ) = @_;
    my $session  = $test->session;
    $session->style->setMobileStyle(0);
    $session->setting->set('useMobileStyle', 1);
    my ( $tag, $asset, @parents ) = $test->getAnchoredAsset();
    $asset->styleTemplateId('Style');
    $asset->mobileStyleTemplateId('Mobile');
    is $asset->getStyleTemplateId, 'Style', 'returns Style since mobile was not requested';
    $session->style->setMobileStyle(1);
    is $asset->getStyleTemplateId, 'Mobile', 'returns Mobile since mobile was set';
    $session->style->setMobileStyle(0);
    $session->setting->set('useMobileStyle', 0);
}

1;
