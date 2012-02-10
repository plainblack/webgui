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

##The goal of this test is to test the creation of Carousel Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 2; # increment this value for each test you create
use WebGUI::Asset::Wobject::Carousel;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Test->asset;
my $carousel = $node->addChild({className=>'WebGUI::Asset::Wobject::Carousel'});

# Test for a sane object type
isa_ok($carousel, 'WebGUI::Asset::Wobject::Carousel');

# Test to see if we can set new values
my $newSettings = {
	templateId=>'testingtestingtesting1',
};
$carousel->update($newSettings);

foreach my $newSetting (keys %{$newSettings}) {
	is ($carousel->get($newSetting), $newSettings->{$newSetting}, "updated $newSetting is ".$newSettings->{$newSetting});
}

#vim:ft=perl
