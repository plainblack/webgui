#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use Test::More;
use DateTime;

my $session = WebGUI::Test->session;

my $numTests = 5+1;
plan tests => $numTests;

my $macro = 'WebGUI::Macro::ConvertUTCToTZ';
my $loaded = use_ok($macro);
my $formatter = '%Y-%m-%d';

SKIP: {
  skip "Unable to load $macro", $numTests-1 unless $loaded;

  my $today = DateTime->now();
  $today->set_time_zone('UTC');
  my $yesterday = $today->clone;
  $yesterday->subtract( days => 1 );

  my $out1 = WebGUI::Macro::ConvertUTCToTZ::process($session);
  like( $out1, qr/\d{2}\/\d{2}\/\d{2}\/\d{2}\/\d{2}/, 'No parameters passed, check pattern');

  my $out2 = WebGUI::Macro::ConvertUTCToTZ::process($session, 'UTC', $formatter, $today->ymd);
  is( $out2, $today->ymd, 'UTC, date only');

  my $out3 = WebGUI::Macro::ConvertUTCToTZ::process($session, 'UTC', $formatter, $today->ymd, '02:30:00');
  is( $out3, $today->ymd, 'UTC, date and time');

  my $out4 = WebGUI::Macro::ConvertUTCToTZ::process($session, 'America/Chicago', $formatter, $today->ymd, '02:30:00');
  is( $out4, $yesterday->ymd, 'Chicago, date and a.m. time');

  my $out5 = WebGUI::Macro::ConvertUTCToTZ::process($session, 'America/Chicago', $formatter, $today->ymd, '14:30:00');
  is( $out5, $today->ymd, 'Chicago, date and p.m. time');
}

