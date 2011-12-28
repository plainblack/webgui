package Test::WebGUI::Asset::Event;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
     return [qw/assetData Event/];
}

sub parent_list {
    return ['WebGUI::Asset::Wobject::Calendar'];
}

sub postProcessMergedProperties {
    my ( $test, $props ) = @_;
    $props->{startDate} = "2010-01-01";
    $props->{endDate} = "2010-01-02";
}

1;
