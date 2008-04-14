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
use HTML::TokeParser;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;



my @testSets = (
	{
		comment => 'default',
		label => q!!,
		output => '<a href="'.$session->url->page('shop=cart').'"><img src="/extras/macro/ViewCart/cart.gif" alt="View Cart" style="border: 0px;vertical-align: middle;" /></a> <a href="'.$session->url->page('shop=cart').'">View Cart</a>',
	},
	{
		comment => 'custom text',
		label => q!A Rock Hammer!,
		output => '<a href="'.$session->url->page('shop=cart').'"><img src="/extras/macro/ViewCart/cart.gif" alt="A Rock Hammer" style="border: 0px;vertical-align: middle;" /></a> <a href="'.$session->url->page('shop=cart').'">A Rock Hammer</a>',
	},
);

my $numTests = 0;
foreach my $testSet (@testSets) {
	$numTests += 1 + (ref $testSet->{output} eq 'CODE');
}

$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::ViewCart';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::ViewCart::process( $session, $testSet->{label});
	if (ref $testSet->{output} eq 'CODE') {
		my ($url, $label) = $testSet->{output}->($output);
		is($label, $testSet->{label}, $testSet->{comment}.", label");
		is($url,   $testSet->{url},   $testSet->{comment}.", url");
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
}

}


sub simpleHTMLParser {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);

	my $token = $p->get_tag("a");
	my $url = $token->[1]{href} || "-";
	my $label = $p->get_trimmed_text("/a");

	return ($url, $label);
}

sub simpleTextParser {
	my ($text) = @_;

	my ($url)   = $text =~ /^HREF=(.+)$/m;
	my ($label) = $text =~ /^LABEL=(.+)$/m;

	return ($url, $label);
}

END {
}
