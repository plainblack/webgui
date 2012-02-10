package Test::WebGUI::Asset::Post;
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
     return [qw/assetData Post/];
}

sub parent_list {
    return [ map { "WebGUI::Asset::$_"} qw/Wobject::Collaboration Post::Thread/ ];
}

sub postProcessMergedProperties {
    my ( $test, $props ) = @_;
    $props->{func} = "editSave"; # func defaults to preview mode
}

1;
