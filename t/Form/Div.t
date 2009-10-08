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

use WebGUI::Test;
use WebGUI::Form;
use WebGUI::Form::Div;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Div form elements work

use Test::More;

my $session = WebGUI::Test->session;

# put your tests here

plan tests => 3;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $textTag = 'hi this is a piece of text that will get placed in a div';

sub myContent {
    my $id = shift;
    return 'ID = ' . $id . $textTag ;
}

my $html = join "\n",
	$header, 
	WebGUI::Form::Div->new($session, {
		name => 'TestDiv',
		contentCallback => sub { myContent(shift); },
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 1, 'The form has 1 inputs');

# this is not an input control, we just want to see that we are getting
# the desired output

ok( $html =~ /$textTag/, 'the tag is in the html, so the div was succeccfully implanted' );

# TODO write code to parse the html sing xml or some such

__END__

