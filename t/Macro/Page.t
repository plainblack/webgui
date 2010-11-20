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
use WebGUI::Macro::Page;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

##Add more Asset configurations here.
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

$numTests += 1; #For macro call with undefined session asset

plan tests => $numTests;

my $homeAsset = WebGUI::Test->asset;

@testSets = setupTest($session, $homeAsset, @testSets);

is(
	WebGUI::Macro::Page::process($session,'url'),
	'',
	q!Call with no default session asset returns ''!,
);

foreach my $testSet (@testSets) {
	$session->asset($testSet->{asset});
	my $class = $testSet->{className};
	foreach my $field (keys %{ $testSet }) {
		next if $field eq 'asset';
		my $output = WebGUI::Macro::Page::process($session, $field);
		my $comment = sprintf "Checking asset: %s, field: %s", $class, $field;
		is($output, $testSet->{$field}, $comment);
	}
}

sub setupTest {
	my ($session, $homeAsset, @testSets) = @_;
	foreach my $testSet (@testSets) {
		my %properties = %{ $testSet };
		my $asset = $homeAsset->addChild(\%properties, $properties{assetId});
		$testSet->{asset} = $asset;
	}
	return @testSets;
}
