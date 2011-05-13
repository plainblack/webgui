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
use WebGUI::Macro::L_loginBox;
use HTML::TokeParser;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $homeAsset = WebGUI::Test->asset;
$session->asset($homeAsset);
my $template = setupTest($session, $homeAsset);
$session->user({userId=>1});

##Replace the original ENV hash with one that will return a
##known user agent.  Since it usually contains a reference to %ENV,
##you can't just modify that hash since it's protected
my $env = $session->request->env;
$session->request->headers->user_agent('mozilla');
$env->{'QUERY_STRING'}    = 'func=search';

my $i18n = WebGUI::International->new($session,'Macro_L_loginBox');

plan tests => 30;

my $output = WebGUI::Macro::L_loginBox::process($session,'','',$template->getId);
my %vars = simpleTextParser($output);

is($vars{'account.create.label'}, $i18n->get(407, 'WebGUI'), 'account.create.label');
is($vars{'password.label'}, $i18n->get(51, 'WebGUI'), 'password.label');
is($vars{'username.label'}, $i18n->get(50, 'WebGUI'), 'username.label');
is($vars{'hello.label'}, $i18n->get(48), 'hello.label');
is($vars{'logout.label'}, $i18n->get(49), 'logout.label');
is($vars{'user.isVisitor'}, 1, 'user.isVisitor when user is visitor');
is($vars{'customText'}, '', 'no custom text sent');
is($vars{'logout.url'}, $session->url->page('op=auth;method=logout'), 'logout.url');
is($vars{'account.display.url'}, $session->url->page('op=auth;method=displayAccount'), 'account.display.url');
is($vars{'account.create.url'}, $session->url->page('op=auth;method=createAccount'), 'account.create.url');

##The purpose of the test is to make sure that the variables are what they say
##they are.  So we will duplicate a bunch of Form code here.

is(
	$vars{'password.form'},
	WebGUI::Form::password($session,{
		name=>"identifier",
		size=>12,
		extras=>'class="loginBoxField"'
		}),
	'password.form'
);

is(
	$vars{'username.form'},
	WebGUI::Form::text($session,{
		name=>"username",
		size=>12,
		extras=>'class="loginBoxField"'
	}),
	'username.form'
);

is(
	$vars{'form.login'},
	WebGUI::Form::submit($session,{
		value=>$i18n->get(52, 'WebGUI'),
		extras=>'class="loginBoxButton"'
	}),
	'form.login'
);

is(
	$vars{'form.header'},
	WebGUI::Form::formHeader($session,{action=>''})
	.WebGUI::Form::hidden($session,{
		name=>"op",
		value=>"auth"
		})
	.WebGUI::Form::hidden($session,{
		name=>"method",
		value=>"login"
		}),
	'form.login'
);

is($vars{'form.footer'}, WebGUI::Form::formFooter($session), 'form.footer');

is( $vars{'form.returnUrl'}, 
    WebGUI::Form::hidden( $session, {
        name    => 'returnUrl',
        value   => $session->url->page($session->request->env->{"QUERY_STRING"}), 
    }),
    'form.returnUrl' 
);

##Now, test variations on user input, browser type and config settings

##Set non-default boxSize

$output = WebGUI::Macro::L_loginBox::process($session,24,'Log In',$template->getId);
%vars = simpleTextParser($output);

is($vars{'customText'}, 'Log In', 'custom text sent');
like($vars{'username.form'}, qr/size="24"/, 'boxSize set in username.form');
like($vars{'password.form'}, qr/size="24"/, 'boxSize set in password.form');

##Change browser to be MSIE like and watch boxSize change
$session->request->headers->user_agent('msie');

$output = WebGUI::Macro::L_loginBox::process($session,24,'Log In',$template->getId);
%vars = simpleTextParser($output);
like($vars{'username.form'}, qr/size="24"/, 'boxSize set in username.form with MSIE browser');
like($vars{'password.form'}, qr/size="24"/, 'boxSize set in password.form with MSIE browser');

##Templated customText tests

$output = WebGUI::Macro::L_loginBox::process($session,'','%Log Out%',$template->getId);
%vars = simpleTextParser($output);
isnt($vars{'customText'}, '%Log Out%', 'custom text templated via % is processed');
my ($url, $label) = simpleHTMLParser($vars{'customText'});
is($label, "Log Out", "templated custom text, href label");
is($url, $session->url->page("op=auth;method=logout"), "templated custom text, href url");

##Templated customText tests, 2 templates to process

$output = WebGUI::Macro::L_loginBox::process($session,'','%Get Out% %Scoot%',$template->getId);
%vars = simpleTextParser($output);
my ($url1, $label1, $url2, $label2) = twoLinkParser($vars{'customText'});
is($label1, "Get Out", "templated custom text, href label, 1 of 2 labels");
is($url1, $session->url->page("op=auth;method=logout"), "templated custom text, href url, 1 of 2 links");
is($label2, "Scoot", "templated custom text, href label, 2 links, 2 of 2 labels");
is($url2, $session->url->page("op=auth;method=logout"), "templated custom text, href url, 2 of 2 links");

##Change settings to use encrypt login and verify which links use https.
$session->setting->set("encryptLogin", 1);

$output = WebGUI::Macro::L_loginBox::process($session,'','',$template->getId);
%vars = simpleTextParser($output);
like($vars{'form.header'}, qr{https://}, 'form.header action set to use SSL by encryptLogin');

##Finally, a test that the default Template exists

$output = WebGUI::Macro::L_loginBox::process($session,'','','');
my $passwordLabel = $i18n->get(51, 'WebGUI');
like($output, qr/$passwordLabel/, 'default template works');

sub simpleTextParser {
	my ($text) = @_;

	my %pairedData = ();
	while($text =~ m/\s*(\S+)\s*=\s*(.*?)-\+-/smgc) {
		$pairedData{$1} = $2;
	}
	return %pairedData;
}

sub simpleHTMLParser {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);

	my $token = $p->get_tag("a");
	my $url = $token->[1]{href} || "-";
	my $label = $p->get_trimmed_text("/a");

	return ($url, $label);
}

sub twoLinkParser {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);

	my $token1 = $p->get_tag("a");
	my $url1 = $token1->[1]{href} || "-";
	my $label1 = $p->get_trimmed_text("/a");

	my $token2 = $p->get_tag("a");
	my $url2 = $token2->[1]{href} || "-";
	my $label2 = $p->get_trimmed_text("/a");

	return ($url1, $label1, $url2, $label2);
}


sub setupTest {
	my ($session, $defaultNode) = @_;
	$session->user({userId=>3});
	##Create an asset with specific editing privileges
	my $properties = {
		title => 'L_loginBox test template',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
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
		account.create.label form.footer form.returnUrl/;
	#$properties->{template} .= "\n";
	my $template = $defaultNode->addChild($properties, $properties->{id});
	return $template;
}
