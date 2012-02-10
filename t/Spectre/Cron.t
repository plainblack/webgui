# vim: syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use warnings;

use Test::More;

use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use Spectre::Cron;

plan tests => 11;

my $session             = WebGUI::Test->session;

##The goal of this test is to make sure that checkSegment works correctly

ok !Spectre::Cron::checkSegment(undef, 4, 3.5, [0..59]), 'checkSegment: fractional number is false, low';
ok !Spectre::Cron::checkSegment(undef, 4, 4.5, [0..59]), '... fractional number is false, high';

ok  Spectre::Cron::checkSegment(undef, 4, 4, [0..59]), 'exact match';
ok !Spectre::Cron::checkSegment(undef, 4, 3, [0..59]), 'exact miss';
ok !Spectre::Cron::checkSegment(undef, 4, '!4', [0..59]), 'negation, miss';
ok  Spectre::Cron::checkSegment(undef, 5, '!4', [0..59]), 'negation, match';

ok  Spectre::Cron::checkSegment(undef, 4, '*/2', [0..59]), '*/, multiple';
ok !Spectre::Cron::checkSegment(undef, 4, '*/3', [0..59]), '*/, not a multiple';

ok !Spectre::Cron::checkSegment(undef, 4, '1-3', [0..59]), 'out of range, low';
ok !Spectre::Cron::checkSegment(undef, 4, '5-9', [0..59]), 'out of range, high';
ok  Spectre::Cron::checkSegment(undef, 4, '1-9', [0..59]), 'range match';
