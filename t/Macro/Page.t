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

unless ($session->config->get('macros')->{'Page'}) {
	Macro_Config::insert_macro($session, 'Page', 'Page');
}

my @testSets = (
	{
		className => 'WebGUI::Asset::Wobject::Layout',
		#          '1234567890123456789012'
		assetId => 'LayoutTestAsset0011001',
		title => 'Layout Test Asset',
		url => 'pagetest-layout',
		description => 'Test Layout Asset for the Page macro test',
	},
	{
		className => 'WebGUI::Asset::Snippet',
		#          '1234567890123456789012'
		assetId => 'SnippetTestAsset001001',
		title => 'Snippet Test Asset',
		url => 'pagetest-snippet',
		snippet => 'Hello, this is a Snippet',
	},
);


my $numTests = 0;
foreach my $testSet (@testSets) {
	$numTests += scalar keys %{ $testSet };
}

plan tests => $numTests;

my $macroText = '^Page("%s");';
my $output = $macroText;

my $homeAsset = WebGUI::Asset->getDefault($session);
my $versionTag;

($versionTag, @testSets) = setupTest($session, $homeAsset, @testSets);

foreach my $testSet (@testSets) {
	$session->asset($testSet->{asset});
	my $class = $testSet->{className};
	foreach my $field (keys %{ $testSet }) {
		next if $field eq 'asset';
		my $output = sprintf $macroText, $field;
		WebGUI::Macro::process($session, \$output);
		my $comment = sprintf "Checking asset: %s, field: %s", $class, $field;
		is($output, $testSet->{$field}, $comment);
	}
}

sub setupTest {
	my ($session, $homeAsset, @testSets) = @_;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Page macro test"});
	foreach my $testSet (@testSets) {
		my %properties = %{ $testSet };
		my $asset = $homeAsset->addChild(\%properties, $properties{assetId});
		$testSet->{asset} = $asset;
	}
	$versionTag->commit;
	return $versionTag, @testSets;
}

END { ##Clean-up after yourself, always
	$versionTag->rollback;
}
