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

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Macro::FetchMimeType;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
	{
		input  => 'webgui.txt',
		output => 'text/plain',
		comment => q|text|,
	},
	{
		input  => 'plainblack.gif',
		output => 'image/gif',
		comment => q|gif|,
	},
	{
		input  => 'background.jpg',
		output => 'image/jpeg',
		comment => q|jpeg|,
	},
	{
		input  => '',
		output => 'application/octet-stream',
		comment => q|Null path returns application/octet-stream|,
	},
	{
		input  => 'foo.rtf',
		output => 'application/rtf',
		comment => q|RTF file|, ##Added test due to a bug on some operating systems.
	},
	{
		input  => undef,
		output => undef,
		comment => q|Undef path returns undef|,
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $file = $testSet->{input}
		 ? join '/', WebGUI::Paths->extras, $testSet->{input}
		 : $testSet->{input};
	my $output = WebGUI::Macro::FetchMimeType::process($session, $file);
	is($output, $testSet->{output}, $testSet->{comment} );
}
