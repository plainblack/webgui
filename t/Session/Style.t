#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

use Test::More tests => 7; # increment this value for each test you create
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $style = $session->style;

isa_ok($style, 'WebGUI::Session::Style', 'session has correct object type');

####################################################
#
# sent
#
####################################################

is($style->sent, undef, 'sent should start off being undefined at session creation');
is($style->sent(1), '1', 'sent: set to true (1)');
is($style->sent(), '1', 'sent: return true (1)');
is($style->sent('gone'), 'gone', 'sent: set to true ("gone")');
is($style->sent(), 'gone', 'sent: return true ("gone")');

$style->sent(0); ##Set to unsent to we don't trigger any other code, yet

####################################################
#
# setLink
#
####################################################

is($style->setLink(), 0, 'setLink returns the result of the conditional check for already sent');
 
END {
}
