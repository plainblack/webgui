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
use WebGUI::Content::Setup;

# load your modules here

use Test::More tests => 10; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

$session->setting->set("specialState", "init");
isnt(WebGUI::Content::Setup::handler($session), undef, "Setup should return some output when in init special state");
$session->setting->remove("specialState");
is(WebGUI::Content::Setup::handler($session), undef, "Setup shouldn't return anything when no special state is present");

$session->request->setup_body({ 
    wizard_class => 'WebGUI::Wizard::Setup',
    wizard_step  => 'adminAccount',
    timeZone     => 'America/New_York',
    language     => 'Spanish',
});

$session->setting->set("specialState", "init");
WebGUI::Content::Setup::handler($session);

my $admin = WebGUI::User->new($session, '3');
is($admin->get('language'), 'Spanish',          'Admin language set to Spanish');
is($admin->get('timeZone'), 'America/New_York', 'Admin timezone set to America/New_York');

my $visitor = WebGUI::User->new($session, '1');
is($visitor->get('language'), 'Spanish',          'Visitor language set to Spanish');
is($visitor->get('timeZone'), 'America/New_York', 'Visitor timezone set to America/New_York');

my $zoneField     = WebGUI::ProfileField->new($session, 'timeZone');
is $zoneField->get('dataDefault'), 'America/New_York', 'timezone profile field default set to America/New_York';

my $languageField = WebGUI::ProfileField->new($session, 'language');
is $languageField->get('dataDefault'), 'Spanish', 'timezone profile field default set to Spanish';

$admin->update(  { language => 'English' } );
$visitor->update({ language => 'English' } );

$admin->update(  { timeZone => 'America/Chicago' } );
$visitor->update({ timeZone => 'America/Chicago' } );

my $properties;
$properties       = $zoneField->get();
$properties->{dataDefault} = 'America/Chicago';
$zoneField->set($properties);

$properties       = $languageField->get();
$properties->{dataDefault} = 'English';
$languageField->set($properties);

$session->setting->remove("specialState");

my $u1 = WebGUI::User->new($session, '1');
is $u1->get('language'), 'English', 'returned Visitor to English';

my $u3 = WebGUI::User->new($session, '3');
is $u3->get('language'), 'English', 'returned Admin to English';
