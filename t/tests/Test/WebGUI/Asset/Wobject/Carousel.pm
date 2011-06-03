package Test::WebGUI::Asset::Wobject::Carousel;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
     return [qw/assetData wobject Carousel/];
}

sub postProcessMergedProperties {
    my ( $test, $props ) = @_;
    $props->{something} = JSON->new->encode({
        items   => [
            {
                sequenceNumber => 1,
                text => "Item 1",
            },
        ],
    });
    return $props;
}

1;
