#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use Test::More;
use WebGUI::Macro::DeactivateAccount;

my $session = WebGUI::Test->session;

plan tests => 7;

my $defaultText = 'Please deactivate my account permanently.';
my $testText = 'Deactivate account';

# Test 1: User is admin: return nothing
$session->user({userId => 3});
my $out1 = WebGUI::Macro::DeactivateAccount::process($session);
is( $out1, '', "User is admin: return nothing" );

# Test 2: User is not admin, but can't self-deactivate: return nothing
$session->user({userId => 1});
$session->setting->set("selfDeactivation", 0);
my $out2 = WebGUI::Macro::DeactivateAccount::process($session);
is( $out2, '', "User can't self-deactivate: return nothing" );

# Test 3: linkonly
$session->setting->set("selfDeactivation", 1);
my $out3 = WebGUI::Macro::DeactivateAccount::process($session, $testText, 1);
#  my ($url3, $text3) = simpleHTMLParser($out3);
is( $out3, '/?op=auth;method=deactivateAccount', 'Link only - URL check');

# Test 4: full deactivation link with default text
my $out4 = WebGUI::Macro::DeactivateAccount::process($session);
my ($url4, $text4) = simpleHTMLParser($out4);
is( $url4, '/?op=auth;method=deactivateAccount', 'Full test - URL check');
is( $text4, $defaultText, 'Full test - text check');

# Test 5: full deactivation link with custom text
my $out5 = WebGUI::Macro::DeactivateAccount::process($session, $testText);
my ($url5, $text5) = simpleHTMLParser($out5);
is( $url5, '/?op=auth;method=deactivateAccount', 'Full test with custom text - URL check');
is( $text5, $testText, 'Full test with custom text - text check');

sub simpleHTMLParser {
  my ($text) = @_;
  my $p = HTML::TokeParser->new(\$text);

  my $token = $p->get_tag("a");
  my $url = $token->[1]{href} || "-";
  my $label = $p->get_trimmed_text("/a");

  return ($url, $label);
}

