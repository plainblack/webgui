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
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::HTML;
use WebGUI::Session;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @filterSets = (
	{
		inputText => q#<table border="0" cellpadding="0" cellspacing="0"><tbody><tr><td><img src="/uploads/abc.jpg" align="bottom" border="0" />&nbsp;</td><td style="padding-left: 10px">&nbsp;<!--StartFragment --> <center><b>ABC DEF</b></center><br />To provide cost<b> </b>efficient products that put you in c<b>ontrol</b> of your own future. <br /><br /><center><b>Our Company</b></center><ul class="BodyText"><li><a href="http://www.abc.com" target="_blank">ABC Company</a></li></ul><div align="center">Welcome to our Intranet! </div></td></tr></tbody></table>#,
		output => q#    ABC DEF To provide cost efficient products that put you in control of your own future. Our Company ABC Company Welcome to our Intranet! #,
		type => 'all',
		comment => 'all filter complex HTML',
	},
	{
		inputText => q!<tr style="height: 14px"><td style="border: medium none #d4d0c8; height: 14px; background-color: transparent" class="xl28"><b><font face="Arial" size="2">ABC</font></b></td><td style="border: medium none #d4d0c8; background-color: transparent" class="xl25"><b><font face="Arial" size="2"></font></b><br /></td><td style="border: medium none #d4d0c8; background-color: transparent" class="xl24"><font face="Arial" size="2">DEF</font></td><td style="border: medium none #d4d0c8; background-color: transparent" class="xl25"><font face="Arial" size="2"></font><br /></td><td style="border: medium none #d4d0c8; background-color: transparent" class="xl26"><b><font face="Arial" size="2">123</font></b></td></tr>!,
		output => q!ABC DEF 123 !,
		type => 'all',
		comment => 'all filter complex HTML',
	},
	{
		inputText => q!<div>Some text in a sentence.</div><div>Some more text in a sentence.</div>!,
		output => q!Some text in a sentence. Some more text in a sentence. !,
		type => 'all',
		comment => 'all filter JT',
	},
	{
		inputText => q!<p>Paragraph</p>^H();,^SQL("select * from users","^0;,^1;")!,
		output => q!<p>Paragraph</p>&#94;H();,&#94;SQL("select * from users","&#94;0;,&#94;1;")!,
		type => 'macros',
		comment => 'filter macros, valid or not',
	},
	{
		inputText => q!<p>Paragraph</p>^H();!,
		output => q!<p>Paragraph</p>&#94;H();!,
		type => 'macros',
		comment => 'filter macros leaves HTML alone',
	},
	{
		inputText => q!<p>Paragraph</p>!,
		output => q!Paragraph !,
		type => 'all',
		comment => 'all filter HTML',
	},
	{
		inputText => q!<div class="something"><div style="float: left;">This <span>is some</span> <i>text</i> here. Let's&nbsp;see what we get when we add a table.<table><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table></div><div>Here's a little more text with <b>bold</b>, <strong>strong</strong>, and <strong><b>bold strong</b></strong>.</div>!,
		output => q!This is some text here. Let's see what we get when we add a table. a b c d Here's a little more text with bold, strong, and bold strong. !,
		type => 'all',
		comment => 'all filter complex HTML',
	},
	{
		inputText => q!<p>Paragraph</p>^H();!,
		output => q!Paragraph &#94;H();!,
		type => 'all',
		comment => 'all filters macros and HTML',
	},
	{
		inputText => q!<iframe>!,
		output => q!!,
		type => 'all',
		comment => 'all with bare iframe',
	},
	{
		inputText => q!<iframe> height attribute!,
		output => q! height attribute!,
		type => 'all',
		comment => 'all, specific iframe test case',
	},
	{
		inputText => q!&nbsp;!,
		output => q!&#x26;nbsp;!,
		type => 'xml',
		comment => 'xml, &nbsp;',
	},
	{
		inputText => q!> < "!,
		output => q!&#x3E; &#x3C; &#x22;!,
		type => 'xml',
		comment => 'xml, other characters',
	},
);

my @macroParamSets = (
	{
		inputText => q|,|,
		output => q|&#44;|,
		comment => 'single comma',
	},
	{
		inputText => q|'|,
		output => q|&#39;|,
		comment => 'single quote',
	},
);

my @htmlTextSets = (
	{
		inputText => q|I wish I could tell you that Andy fought the good fight.|,
		output => q|I wish I could tell you that Andy fought the good fight.|,
		comment => 'bare text',
	},
	{
		inputText => q|The man likes to play chess; let's get him some rocks. |,
		output => q|The man likes to play chess; let's get him some rocks.|,
		comment => 'bare text with ending space has that space removed',
	},
	{
		inputText => q|<p>Do you enjoy working in the laundry?</p>|,
		output => qq|\nDo you enjoy working in the laundry?\n|,
		comment => 'text in paragraph tag nested inside newlines',
	},
);

my $numTests = scalar @filterSets
             + scalar @macroParamSets
             + scalar @htmlTextSets
             + 3
             ;

plan tests => $numTests;

foreach my $testSet (@filterSets) {
	my $output = WebGUI::HTML::filter($testSet->{inputText}, $testSet->{type});
	is($output, $testSet->{output}, $testSet->{comment});
}

foreach my $testSet (@macroParamSets) {
	WebGUI::HTML::makeParameterSafe(\$testSet->{inputText});
	is($testSet->{inputText}, $testSet->{output}, $testSet->{comment});
}

foreach my $testSet (@htmlTextSets) {
	my $text = WebGUI::HTML::html2text($testSet->{inputText});
	is($text, $testSet->{output}, $testSet->{comment});
}

is(WebGUI::HTML::processReplacements($session, 'grass'), 'grass', 'processReplacements: grass is not replaced');
is(WebGUI::HTML::processReplacements($session, 'shitake'), 'shitake', '... shitake is not replaced');
is(WebGUI::HTML::processReplacements($session, 'This is shit.'), 'This is crap.', '... shit is replaced');
