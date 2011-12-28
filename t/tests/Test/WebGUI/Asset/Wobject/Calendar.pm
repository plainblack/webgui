package Test::WebGUI::Asset::Wobject::Calendar;
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
use warnings;

use base qw/Test::WebGUI::Asset::Wobject/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData wobject Calendar/];
}

sub postProcessMergedProperties {
    my $test = shift;
    my $properties = shift;
    $properties->{icalFeeds} = q{[]};     # XXX get some real data to stick in there
}   

1;
