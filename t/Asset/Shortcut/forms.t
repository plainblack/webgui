# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test the getUserPrefsForm, editOverrides form and 
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
$session->user({ userId => 3 });

my $tag = WebGUI::VersionTag->getWorking($session);
my $page = WebGUI::Test->asset( className => 'WebGUI::Asset::Wobject::Dashboard' );
my $asset = WebGUI::Test->asset(
    className       => 'WebGUI::Asset::Wobject::Article',
    description     => 'Description',
);
my $shortcut = $page->addChild( {
    className       => 'WebGUI::Asset::Shortcut',
    shortcutToAssetId => $asset->getId,
    prefFieldsToShow => 'alias',
} );
WebGUI::Test->addToCleanup($tag);
$tag->commit;
foreach my $object ($page, $asset, $shortcut) {
    $object = $object->cloneFromDb;
}
#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# getUserPrefsForm
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });

$mech->get_ok( $shortcut->getUrl( 'func=getUserPrefsForm' ) );
$mech->submit_form_ok( {
    fields => { alias => "myself" },
} );
$mech->session->user->uncache;
my $user = WebGUI::User->new( $session, $mech->session->user->getId );
is( $user->get('alias'), "myself", "alias gets set" );

# Admin is allowed to edit visitor's prefs
$mech->get_ok( $shortcut->getUrl( 'func=getUserPrefsForm;visitor=1' ) );
$mech->submit_form_ok( {
    fields => { alias => "visitor" },
} );
isnt( $mech->session->user->get('alias'), "visitor", "admin alias doesn't get set" );
is( WebGUI::User->new( $mech->session, '1' )->get('alias'), 'visitor', 'visitors alias set' );

#----------------------------------------------------------------------------
# editOverrides

# form field
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

# Make sure edit form has a link to edit the override
$mech->get_ok( $shortcut->getUrl( 'func=edit' ) );
$mech->follow_link_ok( 
    { url_regex => qr/func=editOverride;fieldName=title/ },
    "Follow the link to edit the override",
);
$mech->submit_form_ok( {
    fields => { title => "New Title" },
} );
$shortcut = WebGUI::Asset->newById( $mech->session, $shortcut->getId );
my %overrides = $shortcut->getOverrides;
is( $overrides{overrides}{title}{newValue}, "New Title" );

# textarea
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok('/');
$mech->session->user({ userId => 3 });

$mech->get_ok( $shortcut->getUrl( 'func=editOverride;fieldName=description' ) );
$mech->submit_form_ok( {
    fields => { newOverrideValueText => "New" },
} );
$shortcut = WebGUI::Asset->newById( $mech->session, $shortcut->getId );
my %overrides = $shortcut->getOverrides;
is( $overrides{overrides}{description}{newValue}, "New" );


done_testing;
#vim:ft=perl
