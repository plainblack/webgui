#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

use LWP::MediaTypes;

my $recentModule = $LWP::MediaTypes::VERSION > 5.800;

my @testSets = (
	{
		input  => 'webgui.txt',
		newput => 'text/plain',
		oldput => 'text/plain',
		comment => q|text|,
	},
	{
		input  => 'plainblack.gif',
		newput => 'image/gif',
		oldput => 'image/gif',
		comment => q|gif|,
	},
	{
		input  => 'background.jpg',
		newput => 'image/jpeg',
		oldput => 'image/jpeg',
		comment => q|jpeg|,
	},
	{
		input  => 'colorPicker.js',
		newput => 'application/x-javascript',
		oldput => 'application/octet-stream',
		comment => q|javascript|,
	},
	{
		input  => 'favIcon.ico',
		newput => 'image/vnd.microsoft.icon',
		oldput => 'application/octet-stream',
		comment => q|octet-stream for unknown type|,
	},
	{
		input  => '',
		newput => 'application/octet-stream',
		oldput => 'application/octet-stream',
		comment => q|Null path returns application/octet-stream|,
	},
	{
		input  => undef,
		newput => undef,
		oldput => undef,
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
    my $expected = $recentModule ? $testSet->{newput} : $testSet->{oldput};
	is($output, $expected, $testSet->{comment} );
}

}
