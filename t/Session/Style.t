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
use HTML::TokeParser;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI;

use Test::More tests => 44; # increment this value for each test you create
use Test::Deep;
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $style = $session->style;

isa_ok($style, 'WebGUI::Session::Style', 'session has correct object type');

####################################################
#
# sent
#
####################################################

is($style->sent, undef, 'sent should start off being undefined at session creation');
is($style->sent(1), '1', 'sent: set to true (1)');
##This is checked indirectly by calling sent with no arguments
is($session->stow->get('styleHeadSent'), 1, 'sent: stow variable set for style header sent');
is($style->sent(), '1', 'sent: return true (1)');
is($style->sent('gone'), 'gone', 'sent: set to true ("gone")');
is($style->sent(), 'gone', 'sent: return true ("gone")');

$style->sent(0); ##Set to unsent to we don't trigger any other code, yet

####################################################
#
# setLink and generateAdditionalHeadTags
#
####################################################

my ($url, $params);

is($style->setLink(), 0, 'setLink returns the result of the conditional check for already sent');
($url) = simpleLinkParser('link', $style->generateAdditionalHeadTags);
is($url, '-', 'setLink: called with no params or link url');

is($style->generateAdditionalHeadTags(), '', 'generateAdditionalHeadTags: returns empty string since nothing has been set');

$style->setLink('http://www.plainblack.com');
($url) = simpleLinkParser('link', $style->generateAdditionalHeadTags);
is($url, 'http://www.plainblack.com', 'setLink: called with link url');

my $setParams = {rating => 5, affiliateId => '007', CAPS => 'CapitalS'};
$style->setLink('http://www.webguidev.org', $setParams);
is($style->setLink('http://www.webguidev.org'), undef, 'setLink: returns undef if URL is passed again');

my $linkOutput = $style->generateAdditionalHeadTags;
like($linkOutput, qr/affiliateId=/, 'setLink: param affiliateId present');
like($linkOutput, qr/rating=/, 'setLink: param rating present');
like($linkOutput, qr/CAPS=/, 'setLink: param rating present');
($url, $params) = simpleLinkParser('link', $linkOutput);
is($url, 'http://www.webguidev.org', 'setLink: called with link url and params');

##TokeParse automatically lowercases all param names but not values
my %setParams = map { lc($_) => $setParams->{$_} } keys %{ $setParams };
cmp_deeply(\%setParams, $params, 'setLink: all params set correctly');

TODO: {
	local $TODO = "more setLink tests";
	ok(0, 'check that more than one link tag can be set if they are unique URLs');
	ok(0, 'check for immediate send if sent returns true');
}

####################################################
#
# setMeta and generateAdditionalHeadTags
#
####################################################

is($style->setMeta(), 0, 'setMeta returns the result of the conditional check for already sent');
($url, $params) = simpleLinkParser('meta', $style->generateAdditionalHeadTags);
cmp_deeply($params, {}, 'setMeta: called with no params');

$setParams = {'author' => 'JT Smith', 'generator' => 'WebGUI'};
$style->setMeta($setParams);
($url, $params) = simpleLinkParser('meta', $style->generateAdditionalHeadTags);
cmp_deeply($params, $setParams, 'setMeta: called with params');
($url, $params) = simpleLinkParser('meta', $style->generateAdditionalHeadTags);
cmp_deeply($params, {}, 'setMeta: clears all content in generateAdditionalHeadTags');

TODO: {
	local $TODO = "more setMeta tests";
	ok(0, 'meta: check that more than one tag can be set');
	ok(0, 'meta: check for immediate send if sent returns true');
}

####################################################
#
# setScript and generateAdditionalHeadTags
#
####################################################

is($style->setScript(), 0, 'setScript returns the result of the conditional check for already sent');
($url) = simpleLinkParser('script', $style->generateAdditionalHeadTags);
is($url, '-', 'setScript: called with no params or script url');

$style->setScript('http://www.plainblack.com/stuff.js');
is($style->setScript('http://www.plainblack.com/stuff.js'), undef, 'setScript: called with duplicate url returns undef');
my $scriptOutput = $style->generateAdditionalHeadTags;
($url) = simpleLinkParser('script', $scriptOutput);
is($url, 'http://www.plainblack.com/stuff.js', 'setScript: called with script url');

my $setParams = { type => 'text/javascript' };
my $setUrl = 'http://www.webguidev.org/sorting.js';
$style->setScript($setUrl, $setParams);
my $scriptOutput = $style->generateAdditionalHeadTags;
($url, $params) = simpleLinkParser('script', $scriptOutput);
is($url, $setUrl, 'setScript: called with new script url');
is_deeply($params, $setParams, 'setScript: params set properly');

TODO: {
	local $TODO = "more setScript tests";
	ok(0, 'check that more than one script tag can be set if they are unique URLs');
	ok(0, 'check for immediate send if sent returns true');
}

####################################################
#
# generateAdditionalHeadTags
#
####################################################

$session->user({userId => 1});
$style->setRawHeadTags("^#;");
my $macroOutput = $style->generateAdditionalHeadTags();
is($macroOutput, 1, 'generateAdditionalHeadTags: process a macro');

####################################################
#
# process 
# useEmptyStyle
#
####################################################

$style->sent(0);
is($style->sent, 0, 'process: setup sent to 0');

is($style->process('body.content', 'notATemplateId'),
"WebGUI was unable to instantiate your style template.body.content",
'process:  invalid templateId returns error message to client');

is($style->sent, 1, 'process: sets sent to 1');

$style->useEmptyStyle(1);

is($style->process('body.content'), "body.content", 'process, useEmptyStyle:  valid data returned');

my ($versionTag, $personalTemplate) = setup_assets($session);

$session->scratch->set('personalStyleId', $personalTemplate->getId);

my $styled = $style->process('body.content', 'notATemplateId');
like($styled,
qr/PERSONAL STYLE TEMPLATE/,
'process:  personalStyleTemplate overrides submitted template');

my $head = $styled;
$head =~ s/(^HEAD=.+$)/$1/s;

my @metas = fetchMultipleMetas($head);
my $expectedMetas = [
           {
             'content' => 'WebGUI '.$WebGUI::VERSION,
             'name' => 'generator'
           },
           {
             'http-equiv' => 'Content-Type',
             'content' => 'text/html; charset=UTF-8'
           },
           {
             'http-equiv' => 'Content-Script-Type',
             'content' => 'text/javascript'
           },
           {
             'http-equiv' => 'Content-Style-Type',
             'content' => 'text/css'
           }
];
cmp_bag(\@metas, $expectedMetas, 'process:default meta tags');
is($session->http->{_http}{cacheControl}, undef, 'process: HTTP cacheControl undefined');

$session->user({userId=>3});
$styled = $style->process('body.content');
$head = $styled;
$head =~ s/(^HEAD=.+$)/$1/s;
@metas = fetchMultipleMetas($head);
push @{ $expectedMetas }, (
           {
             'http-equiv' => 'Pragma',
             'content' => 'no-cache',
           },
           {
             'http-equiv' => 'Cache-Control',
             'content' => 'no-cache, must-revalidate, max-age=0, private',
           },
           {
             'http-equiv' => 'Expires',
             'content' => '0',
           },
);
cmp_bag(\@metas, $expectedMetas, 'process:default meta tags with no caching head tags, group 2 user');

$session->user({userId=>1});
my $origPreventProxyCache = $session->setting->get('preventProxyCache');
$session->setting->set('preventProxyCache', 1);
$styled = $style->process('body.content');
$head = $styled;
$head =~ s/(^HEAD=.+$)/$1/s;
@metas = fetchMultipleMetas($head);
cmp_bag(\@metas, $expectedMetas, 'process:default meta tags with no caching head tags, preventProxyCache setting');
$session->setting->set('preventProxyCache', $origPreventProxyCache);

##No accessor
is($session->http->{_http}{cacheControl}, 'none', 'process: HTTP cacheControl set to none to prevent proxying');

sub simpleLinkParser {
	my ($tokenName, $text) = @_;
	my $p = HTML::TokeParser->new(\$text);

	my $token = $p->get_tag($tokenName);
	my $tokenParam;
	if ($tokenName eq 'script') {
		$tokenParam = 'src';
	}
	else {
		$tokenParam = 'href';
	}
	my $url = $token->[1]{$tokenParam} || "-";
	my $params = $token->[1];
	delete $params->{$tokenParam};
	delete $params->{'/'};  ##delete unary slash from XHTML output

	return ($url, $params);
}

sub fetchMultipleMetas {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);
	my @metas = ();

	while (my $token = $p->get_tag('meta')) {
		my $params = $token->[1];
		delete $params->{'/'};  ##delete unary slash from XHTML output
		push @metas, $params;
	}

	return @metas;
}

sub setup_assets {
	my $session = shift;
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Session Style test"});
	my $properties = {
		title => 'personal style test template',
		className => 'WebGUI::Asset::Template',
		url => 'personal_style',
		namespace => 'Style',
		template => "PERSONAL STYLE TEMPLATE\n\nBODY=<tmpl_var body.content>\n\nHEAD=<tmpl_var head.tags>",
		id => 'testTemplate_personal1',
		#     '1234567890123456789012'
	};
	my $template = $importNode->addChild($properties, $properties->{id});
	$versionTag->commit;
	return ($versionTag, $template);
}

END {
	$session->setting->set('preventProxyCache', $origPreventProxyCache);
	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
		$versionTag->rollback;
	}
}
