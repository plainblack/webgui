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

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
	{
		input => 'plainblack.gif',
		output => 'image/gif',
		comment => q|gif|,
	},
	{
		input => 'background.jpg',
		output => 'image/jpeg',
		comment => q|jpeg|,
	},
	{
		input => 'colorPicker.js',
		output => 'text/plain',
		comment => q|plain text|,
	},
	{
		input => 'favIcon.ico',
		output => 'application/octet-stream',
		comment => q|octet-stream for unknown type|,
	},
	{
		input => '',
		output => 'application/octet-stream',
		comment => q|Null path returns application/octet-stream|,
	},
	{
		input => undef,
		output => undef,
		comment => q|Undef path returns undef|,
	},
);

my $numTests = scalar @testSets;

$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::FetchMimeType';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

foreach my $testSet (@testSets) {
	my $file = $testSet->{input}
		 ? join '/', WebGUI::Test->root, 'www/extras', $testSet->{input}
		 : $testSet->{input};
	my $output = WebGUI::Macro::FetchMimeType::process($session, $file);
	is($output, $testSet->{output}, $testSet->{comment} );
}

}
