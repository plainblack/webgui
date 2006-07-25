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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @added_macros = ();
push @added_macros, WebGUI::Macro_Config::enable_macro($session, 'FetchMimeType', 'FetchMimeType');

my $macroText = '^FetchMimeType("%s");';
my $output;

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
);

my $numTests = scalar @testSets;

plan tests => $numTests;


foreach my $testSet (@testSets) {
	my $file = join '/', WebGUI::Test->root, 'www/extras', $testSet->{input};
	$output = sprintf $macroText, $file;
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, $testSet->{comment} );
}

END {
	foreach my $macro (@added_macros) {
		next unless $macro;
		$session->config->deleteFromHash("macros", $macro);
	}
}
