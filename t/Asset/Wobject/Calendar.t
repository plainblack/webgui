#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

##The goal of this test is to test the creation of Calendar Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 5; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::Calendar;
use WebGUI::Asset::Event;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Calendar Test"});

my $cal = $node->addChild({className=>'WebGUI::Asset::Wobject::Calendar'});
$versionTag->commit();

# Test for a sane object type
isa_ok($cal, 'WebGUI::Asset::Wobject::Calendar');

# Test addChild to make sure we can only add Event assets as children to the calendar
my $event = $cal->addChild({className=>'WebGUI::Asset::Event'});
isa_ok($event, 'WebGUI::Asset::Event','Can add Events as a child to the calendar.');

# Calendars create and autocommit a version tag when a child is added.  Lets get the name so we can roll it back.
my $secondVersionTag = WebGUI::VersionTag->new($session, $event->get("tagId"));

my $article = $cal->addChild({className=>"WebGUI::Asset::Wobject::Article"});
isnt(ref $article, 'WebGUI::Asset::Wobject::Article', "Can't add an article as a child to the calendar.");

my $dt = WebGUI::DateTime->new($session, mysql => '2001-08-16 8:00:00', time_zone => 'America/Chicago');

my $vars = {};
$cal->appendTemplateVarsDateTime($vars, $dt, "start");
cmp_deeply(
    $vars,
    {
        startMinute     => '00',
        startDayOfMonth => 16,
        startMonthName  => 'August',
        startMonthAbbr  => 'Aug',
        startEpoch      => 997966800,
        startHms        => '08:00:00',
        startM          => 'AM',
        startMeridiem   => 'AM',
        startDayName    => 'Thursday',
        startMdy        => '08-16-2001',
        startYmd        => '2001-08-16',
        startDmy        => '16-08-2001',
        startDayAbbr    => 'Thu',
        startDayOfWeek  => 4,
        startHour       => 8,
        startHour24     => 8,
        startMonth      => 8,
        startSecond     => '00',
        startYear       => 2001,
    },
    'Variables returned by appendTemplateVarsDateTime'
);

TODO: {
        local $TODO = "Tests to make later";
        ok(0, 'Lots more to test');
}

END {
	# Clean up after thy self
	$versionTag->rollback();
	$secondVersionTag->rollback();
}

