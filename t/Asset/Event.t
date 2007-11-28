#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset::Event;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 2;

my $session = WebGUI::Test->session;

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Adding Calendar for Event Asset Test"});
my $defaultAsset = WebGUI::Asset->getDefault($session);
my $cal = $defaultAsset->addChild({className=>'WebGUI::Asset::Wobject::Calendar'});
$versionTag->commit;

my $properties = {
	#     '1234567890123456789012'
	id        => 'EventAssetTest00000012',
	title     => 'Birthday of WebGUI',
	className => 'WebGUI::Asset::Event',
	url       => 'event-asset-test',
    startDate => '2000-08-16', ##Times and dates have to be entered in UTC
    startTime => '23:00:00',
    endDate   => '2000-08-17',
    endTime   => '03:00:00',
    timeZone  => 'America/Chicago',
    location  => 'Madison, Wisconsin',
};

my $event = $cal->addChild($properties, $properties->{id});

my $secondVersionTag = WebGUI::VersionTag->new($session, $event->get("tagId"));

is($event->isAllDay, 0, 'isAllDay is zero since it has a start and end time');

my %templateVars = $event->getTemplateVars();
is($templateVars{dateSpan}, 'Wednesday, August 16 6:00 PM &dash;  10:00 PM', 'getTemplateVars: dateSpan bridges times on a single day');

END {
	# Clean up after thy self
    $versionTag->rollback;
	$secondVersionTag->rollback();
}
