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
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'H_homeLink'}) {
	Macro_Config::insert_macro($session, 'H', 'H_homeLink');
}

my $homeAsset = WebGUI::Asset->getDefault($session);

my $i18n = WebGUI::International->new($session,'Macro_H_homeLink');

my @testSets = (
	{
	macroText => q!^H("%s");!,
	label => q!linkonly!,
	format => q!!,
	output => $homeAsset->getUrl(),
	comment => 'linkonly argument',
	},
	{
	macroText => q!^H();!,
	label => q!!,
	format => q!!,
	output => sprintf(q!<a class="homeLink" href="%s">%s</a>!, $homeAsset->getUrl(), $i18n->get(47)),
	comment => 'default macro call',
	},
	{
	macroText => q!^H("%s");!,
	label => q!Hi, want to go home?!,
	format => q!!,
	output => sprintf(q!<a class="homeLink" href="%s">%s</a>!, $homeAsset->getUrl(), 'Hi, want to go home?'),
	comment => 'default macro call',
	},
);

my $numTests = scalar @testSets + 1;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = sprintf $testSet->{macroText}, $testSet->{label}, $testSet->{format};
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, $testSet->{comment});
}

TODO: {
	local $TODO = "Tests to make later";
	ok(0, 'Check label override');
}
