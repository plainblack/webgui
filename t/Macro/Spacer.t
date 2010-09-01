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
use WebGUI::Macro::Spacer;
use WebGUI::Session;
use HTML::TokeParser;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @testSets = (
	{
		comment => '5x5',
		width => 5,
		height => 5,
	},
	{
		comment => '10x3',
		width => 10,
		height => 3,
	},
	{
		comment => 'width only',
		width => 11,
		height => '',
	},
	{
		comment => 'height only',
		width => '',
		height => 7,
	},
	{
		comment => 'width only, undef',
		width => 9,
		height => undef,
	},
	{
		comment => 'height only, undef',
		width => undef,
		height => 17,
	},
);

plan tests => 5 + 2 * scalar @testSets;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::Spacer::process($session, $testSet->{width}, $testSet->{height});
	$testSet->{width} = '' unless defined $testSet->{width};
	$testSet->{height} = '' unless defined $testSet->{height};
	my ($width, $height) = simpleHTMLParser($output);
	is($width,  $testSet->{width},  $testSet->{comment}.", width");
	is($height, $testSet->{height}, $testSet->{comment}.", height");
}

my $output = q!^Spacer(5,7);!;
WebGUI::Macro::process($session, \$output);
my ($width, $height, $src, $alt, $style) = simpleHTMLParser($output);
is($width,  5, "all fields, width");
is($height, 7, "all fields, height");
is($src,    '/extras/spacer.gif', "all fields, src");
is($alt,    '[]', "all fields, alt");
is($style,  'border-style:none;', "all fields, style");

sub simpleHTMLParser {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);

	my $token = $p->get_tag("img");
	my $width  = $token->[1]{width} || "";
	my $height = $token->[1]{height} || "";
	my $src    = $token->[1]{src} || "";
	my $alt    = $token->[1]{alt} || "";
	my $style  = $token->[1]{style} || "";

	return ($width, $height, $src, $alt, $style);
}
