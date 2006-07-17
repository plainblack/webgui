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
use HTML::TokeParser;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'Spacer'}) {
	Macro_Config::insert_macro($session, 'Spacer', 'Spacer');
}

my @testSets = (
	{
		comment => '5x5',
		macroText => q!^Spacer("%s","%s");!,
		width => 5,
		height => 5,
	},
	{
		comment => '10x3',
		macroText => q!^Spacer("%s","%s");!,
		width => 10,
		height => 3,
	},
	{
		comment => 'width only',
		macroText => q!^Spacer("%s");!,
		width => 11,
		height => '',
	},
	{
		comment => 'height only',
		macroText => q!^Spacer("%s","%s");!,
		width => '',
		height => 7,
	},
);

plan tests => 5 + 2 * scalar @testSets;

foreach my $testSet (@testSets) {
	my $output = sprintf $testSet->{macroText}, $testSet->{width}, $testSet->{height};
	WebGUI::Macro::process($session, \$output);
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
