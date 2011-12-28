package Test::WebGUI::Asset::Template;
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
     return [qw/assetData template/];
}

sub postProcessMergedProperties {
    my $test = shift;
    my $properties = shift;
    if( exists $properties->{attachmentsJson} and ! defined $properties->{attachmentsJson} ) {
        $properties->{attachmentsJson} = '[{"url":"/webgui.css","type":"stylesheet"}]';
    }
}

sub dynamic_form_labels { return 'Template Type' };

1;
