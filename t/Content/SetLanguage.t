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
use WebGUI::Session;
use WebGUI::Content::SetLanguage;

# load your modules here

use Test::More tests => 5; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here
my $formvariables = {
	'op' =>'setLanguage',
	'language' => 'English'
};
#test 1
$session->request->setup_body($formvariables);
WebGUI::Content::SetLanguage::handler($session);
is($session->scratch->getLanguageOverride, 'English', 'the language was not set');
#test2
$formvariables->{'language'} = 'delete';
$session->request->setup_body($formvariables);
WebGUI::Content::SetLanguage::handler($session);
is($session->scratch->getLanguageOverride, undef, 'language delete should remove the scratch variable');
#test3
$formvariables->{'op'} = 'SetLanguage';
$formvariables->{'language'} = 'English';
$session->request->setup_body($formvariables);
WebGUI::Content::SetLanguage::handler($session);
is($session->scratch->getLanguageOverride, undef, 'Naming the method wrongly should not change anything');
#test4
$formvariables->{'op'} = 'setLanguage';
$formvariables->{'language'} = 'MyImaginaryLanguageThatIsNotInstalled';
$session->request->setup_body($formvariables);
WebGUI::Content::SetLanguage::handler($session);
is($session->scratch->getLanguageOverride, undef, 'Giving a non installed language should not change anything');
#test5
$formvariables->{'language'} = undef;
$session->request->setup_body($formvariables);
WebGUI::Content::SetLanguage::handler($session);
is($session->scratch->getLanguageOverride, undef, 'Passing an empty language variable should return undef');

