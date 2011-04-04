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
use HTML::TokeParser;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI;

use Test::More tests => 58; # increment this value for each test you create
use Test::Deep;
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $style = $session->style;

my $crappyPerl = $^V lt v5.8;

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

($url) = simpleLinkParser('link', $style->generateAdditionalHeadTags);
is($url, '-', 'setLink: called with no params or link url');

is($style->generateAdditionalHeadTags(), undef, 'generateAdditionalHeadTags: returns undef since nothing has been set');

$style->setLink('http://www.plainblack.com');
($url) = simpleLinkParser('link', $style->generateAdditionalHeadTags);
is($url, 'http://www.plainblack.com', 'setLink: called with link url');

$style->setLink('http://dev.plainblack.com', '');
($url,$params) = simpleLinkParser('link', $style->generateAdditionalHeadTags);
is($url, 'http://dev.plainblack.com', 'setLink: called with bad params');
cmp_deeply({}, $params, 'setLink: bad params sent return no params in tag');

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

sendImmediate($style, 'setLink', 'http://dev.setlink.com',
	'setLink, sent: data automatically sent out via Session->Output');

TODO: {
	local $TODO = "more setLink tests";
	ok(0, 'check that more than one link tag can be set if they are unique URLs');
}

####################################################
#
# setMeta and generateAdditionalHeadTags
#
####################################################

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
}

####################################################
#
# setRawHeadTags
#
# Note, this gets tested via setMeta above.  However,
# it is easier to test the sending of data immediately
# this way.
#
####################################################

sendImmediate($style, 'setRawHeadTags', 'this is really a tag',
	'setRawHeadTags, sent: data automatically sent out via Session->Output');

####################################################
#
# setScript and generateAdditionalHeadTags
#
####################################################

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

sendImmediate($style, 'setScript', 'http://dev.setscript.com/script.js',
	'setScript, sent: data automatically sent out via Session->Output');

TODO: {
	local $TODO = "more setScript tests";
	ok(0, 'check that more than one script tag can be set if they are unique URLs');
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
#
####################################################

my ($versionTag, $templates, $article, $snippet) = setup_assets($session);
WebGUI::Test->addToCleanup($versionTag);

$style->sent(0);
is($style->sent, 0, 'process: setup sent to 0');

is($style->process('body.content', 'notATemplateId'),
"WebGUI was unable to instantiate your style template with the id: notATemplateId.body.content",
'process:  invalid templateId returns error message to client');

is($style->sent, 1, 'process: sets sent to 1');

####################################################
#
# userStyle
#
####################################################

my $origUserStyle = $session->setting->get('userFunctionStyleId');
$session->setting->set('userFunctionStyleId', $templates->{user}->getId);

is($style->userStyle('userStyle'), 'USER PRINTABLE STYLE TEMPLATE:userStyle',
'userStyle returns templated output according to userFunctionStyleId in settings');
is($session->http->{_http}{cacheControl}, 'none', 'userStyle(via process): HTTP cacheControl set to none to prevent proxying');

is($style->userStyle('userStyle'), 'USER PRINTABLE STYLE TEMPLATE:userStyle',
'userStyle returns templated output according to userFunctionStyleId in settings');

is($style->userStyle(0), 'USER PRINTABLE STYLE TEMPLATE:0',
'userStyle returns templated output even 0 which is false');

is($style->userStyle(undef), undef,
'userStyle returns undef if no output is sent');

$session->setting->set('userFunctionStyleId', $origUserStyle);
$session->http->setCacheControl(undef); ##return to default setting for downstream testing
####################################################
#
# process 
# useEmptyStyle
#
####################################################

$style->useEmptyStyle(1);

is($style->process('body.content'), "body.content", 'process, useEmptyStyle:  valid data returned');

$session->scratch->set('personalStyleId', $templates->{personal}->getId);

my $styled = $style->process('body.content', 'notATemplateId');
like($styled,
qr/PERSONAL STYLE TEMPLATE/,
'process:  personalStyleTemplate overrides submitted template');

unlike($styled,
qr{(?i)</?(html|head|body)>},
'useEmptyStyle does not have html, head or body tags');

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
           },
           {
             'http-equiv' => 'Cache-Control',
             'content' => 'must-revalidate'
           },
];
cmp_bag(\@metas, $expectedMetas, 'process:default meta tags');
is($session->http->{_http}{cacheControl}, undef, 'process: HTTP cacheControl undefined');

$session->user({userId=>3});
$styled = $style->process('body.content');
$head = $styled;
$head =~ s/(^HEAD=.+$)/$1/s;
@metas = fetchMultipleMetas($head);
$expectedMetas = [
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
           },
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
];
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

####################################################
#
# process 
# Style Template meta data
#
####################################################


TODO: {
	local $TODO = "needed process tests";
	ok(0, 'check that meta data in the style template is placed in the style when session->setting->get(metaDataEnabled) is set');
}


####################################################
#
# process 
# no duped extraHeadTagsContent
#
####################################################

$style->useEmptyStyle(1);
$style->sent(0);

$session->scratch->set('personalStyleId', $templates->{extraHeadTags}->getId);

$styled = $style->process('body.content', 'notATemplateId');

$head = $styled;
$head =~ s/(^HEAD=.+$)/$1/s;

@metas = fetchMultipleMetas($head);
$expectedMetas = [
           {
             'name' => 'keywords',
             'content' => 'keyword1,keyword2'
           },
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
           },
           {
             'http-equiv' => 'Cache-Control',
             'content' => 'must-revalidate'
           },
];
cmp_bag(\@metas, $expectedMetas, 'process, extraHeadTags:no duped extraHeadTags from style template');

####################################################
#
# process 
# makePrintable
# printableStyleId
#
# From this point on, we don't need to do a ton of parsing since we've fully
# verified that template processing works okay
#
####################################################

##Put original template back in place.
$session->scratch->set('personalStyleId', $templates->{personal}->getId);
$style->setPrintableStyleId($templates->{printable}->getId);
is($style->{_printableStyleId}, $templates->{printable}->getId, 'printableStyleId: set');

like($style->process, qr/PERSONAL STYLE TEMPLATE/,
	'process: setting printStyleId does not change template selection');

$style->makePrintable(1);
is($style->{_makePrintable}, 1, 'makePrintable: set');

like($style->process, qr/PERSONAL STYLE TEMPLATE/,
	'process: setting printStyleId and makePrintable does not change template');
$session->asset($article);
like($style->process, qr/PRINTABLE STYLE TEMPLATE/,
	'process: setting printStyleId and makePrintable and default session asset causes printable template to use');

$style->setPrintableStyleId(0);
like($style->process, qr/ASSET PRINTABLE STYLE TEMPLATE/,
	'process: uses styleTemplateId from current asset if not set in $style->setPrintableStyleId');

$session->asset($snippet);
is($style->process('test output'), 
	"WebGUI was unable to instantiate your style template with the id: .test output",
	'process:  no valid printableStyleTemplateFound in asset branch returns error');

####################################################
#
# Utility routines for printing
#
####################################################

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

sub sendImmediate {
	my ($style, $action, $output, $comment) = @_;

	SKIP: {
		skip "You have an old perl", 1 if $crappyPerl;
        my $request = $style->session->request;
        $request->clear_output;
		$style->sent(1);
		$style->$action($output);
		like($request->get_output, qr/$output/, $comment);
		$style->sent(0);
	}

}

#like($buffer, qr/$output/, );
sub setup_assets {
	my $session = shift;
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Session Style test"});
	my $templates = {};
	my $properties = {
		title => 'personal style test template',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'personal_style',
		namespace => 'Style',
		template => "PERSONAL STYLE TEMPLATE\n\nBODY=<tmpl_var body.content>\n\nHEAD=<tmpl_var head.tags>",
		id => 'testTemplate_personal1',
		#     '1234567890123456789012'
	};
	$templates->{personal} = $importNode->addChild($properties, $properties->{id});
	$properties = {
		title => 'personal style test template with extraHeadTags',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'headblock_style',
		namespace => 'Style',
		template => 'HEADBLOCK STYLE TEMPLATE\n\nBODY=<tmpl_var body.content>\n\nHEAD=<tmpl_var head.tags>',
		extraHeadTags => q|<meta name="keywords" content="keyword1,keyword2" />|,
		id => 'testTemplate_headblock',
		#     '1234567890123456789012'
	};
	$templates->{extraHeadTags} = $importNode->addChild($properties, $properties->{id});
	$properties = {
		title => 'personal style test template for printing',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'personal_style_printable',
		namespace => 'Style',
		##Note, at this point 
		template => "PRINTABLE STYLE TEMPLATE",
		id => 'testTemplate_printable',
		#     '1234567890123456789012'
	};
	$templates->{printable} = $importNode->addChild($properties, $properties->{id});
	$properties = {
		title => 'asset template for printing',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'asset_style_printable',
		namespace => 'Style',
		##Note, at this point 
		template => "ASSET PRINTABLE STYLE TEMPLATE",
		id => 'printableAssetTemplate',
		#     '1234567890123456789012'
	};
	$templates->{asset} = $importNode->addChild($properties, $properties->{id});
	$properties = {
		title => 'user template for printing',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'user_style_printable',
		namespace => 'Style',
		##Note, at this point 
		template => "USER PRINTABLE STYLE TEMPLATE:<tmpl_var body.content>",
		id => 'printableUser0Template',
		#     '1234567890123456789012'
	};
	$templates->{user} = $importNode->addChild($properties, $properties->{id});
	$properties = {
		title => 'asset for printing',
		className => 'WebGUI::Asset::Wobject::Article',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'printable_article',
		id => 'printableAsset00000000',
		printableStyleTemplateId => $templates->{asset}->getId,
		description => 'This is a printable asset',
		#     '1234567890123456789012'
	};
	my $asset = $importNode->addChild($properties, $properties->{id});
	##We have to have nested assets without printable style ids
	##for code coverage
	$properties = {
		title => 'Daddy Snippet',
		className => 'WebGUI::Asset::Snippet',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'daddy_snippet',
		id => 'printableSnippet0Daddy',
		#     '1234567890123456789012'
		snippet => 'I am a snippet',
	};
	my $daddySnippet = WebGUI::Asset->getRoot($session)->addChild($properties, $properties->{id});
	$properties = {
		title => 'My Snippet',
		className => 'WebGUI::Asset::Snippet',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'printable_snippet',
		id => 'printableSnippet123456',
		#     '1234567890123456789012'
		snippet => 'I am a snippet',
	};
	my $snippet = $daddySnippet->addChild($properties, $properties->{id});
	$versionTag->commit;
	return ($versionTag, $templates, $asset, $snippet);
}
