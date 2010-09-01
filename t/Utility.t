#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use strict;
use Tie::IxHash;

use WebGUI::Test;
use WebGUI::Session;

use Test::More tests => 2; # increment this value for each test you create
use Test::Deep;

my $session = WebGUI::Test->session;

# isIn
ok(WebGUI::Utility::isIn("webgui", qw(cars trucks webgui trains)), 'isIn()');

{
	# Just some basic tests for now.

	my (%hash1, %hash2, %hash3);
	my %hash1 = ('a' => 5, 'b' => 3, 'c' => 2, 'd' => 4, 'e' => 1);
	tie my %hash2, 'Tie::IxHash';
	tie my %hash3, 'Tie::IxHash';
	%hash2 = WebGUI::Utility::sortHash(%hash1);
	is_deeply([keys %hash2], [qw/e c b d a/], 'sortHash');
}

# Local variables:
# mode: cperl
# End:
