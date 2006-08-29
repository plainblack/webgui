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
use WebGUI::Session;
use HTML::TokeParser;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $homeAsset = WebGUI::Asset->getDefault($session);
$session->asset($homeAsset);
my ($versionTag, $template) = setupTest($session, $homeAsset);
$session->user({userId=>1});

my $i18n = WebGUI::International->new($session,'Macro_L_loginBox');

my @testSets = (
);

my $numTests = 0;
foreach my $testSet (@testSets) {  ##Count dynamic tests
	$numTests += 1 + (ref $testSet->{output} eq 'CODE');
}

$numTests += 1; #Module loading test
$numTests += 11; #Static tests

plan tests => $numTests;

my $macro = 'WebGUI::Macro::L_loginBox';
my $loaded = use_ok($macro);
use Data::Dumper;

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

my $output = WebGUI::Macro::L_loginBox::process($session,'','',$template->getId);
my %vars = simpleTextParser($output);

is($vars{'account.create.label'}, $i18n->get(407, 'WebGUI'), 'account.create.label');
is($vars{'password.label'}, $i18n->get(51, 'WebGUI'), 'password.label');
is($vars{'username.label'}, $i18n->get(50, 'WebGUI'), 'username.label');
is($vars{'hello.label'}, $i18n->get(48), 'hello.label');
is($vars{'logout.label'}, $i18n->get(49), 'logout.label');
is($vars{'user.isVisitor'}, 1, 'user.isVisitor when user is visitor');
is($vars{'customText'}, '', 'no custom test sent');
is($vars{'logout.url'}, $session->url->page('op=auth;method=logout'), 'logout.url');
is($vars{'account.display.url'}, $session->url->page('op=auth;method=displayAccount'), 'account.display.url');
is($vars{'account.create.url'}, $session->url->page('op=auth;method=createAccount'), 'account.create.url');

##The purpose of the test is to make sure that the variables are what they say
##they are.

#diag $output;
#diag Dumper \%vars;

is($vars{'form.footer'}, WebGUI::Form::formFooter($session), 'form.footer');

foreach my $testSet (@testSets) {
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

	my %pairedData = ();
	while($text =~ m/^\s*(\S+)\s*=\s*(.*?)-\+-/smgc) {
		$pairedData{$1} = $2;
	}
	return %pairedData;
}

sub setupTest {
	my ($session, $defaultNode) = @_;
	$session->user({userId=>3});
	##Create an asset with specific editing privileges
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"L_loginBox test"});
	my $properties = {
		title => 'L_loginBox test template',
		className => 'WebGUI::Asset::Template',
		url => 'L-loginbox-test',
		namespace => 'Macro/L_loginBox',
		groupIdEdit => 3,
		#     '1234567890123456789012'
		id => 'L_loginBox-_-_Template',
	};
	##Create a template that echo's back the template variables, by name
	##for easy text parsing
	$properties->{template} =
		join "\n",
		map { "$_ = <tmpl_var $_>-+-" }
		qw/user.isVisitor customText hello.label logout.url account.display.url
		logout.label form.header username.label username.form
		password.label password.form form.login account.create.url
		account.create.label form.footer/;
	#$properties->{template} .= "\n";
	my $template = $defaultNode->addChild($properties, $properties->{id});
	$versionTag->commit;
	return ($versionTag, $template);
}

END { ##Clean-up after yourself, always
	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
		$versionTag->rollback;
	}
}
