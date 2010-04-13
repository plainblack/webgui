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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Macro::Extras;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
	{
		comment => 'Just get the extras path',
		path => q!!,
		output => $session->url->extras(),
	},
	{
		comment => 'Note that trailing slash is appended',
		path => q!!,
		output => $session->config->get("extrasURL").'/',
	},
	{
		comment => 'undef vs empty string',
		path => undef,
		output => $session->config->get("extrasURL").'/',
	},
	{
		comment => 'append a path, example from docs',
		path => q!path/to/something/in/extras/folder!,
		output => $session->url->extras('path/to/something/in/extras/folder'),
	},
	{
		comment => 'double slashes are removed',
		path => q!/path/to/something/in/extras/folder!,
		output => $session->url->extras('path/to/something/in/extras/folder'),
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

my $macro = 'WebGUI::Macro::Extras';

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::Extras::process($session, $testSet->{path});
	is($output, $testSet->{output}, $testSet->{comment});
}
