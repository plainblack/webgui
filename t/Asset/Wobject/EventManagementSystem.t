# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use Data::Dumper;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Do our work in the import node (root/import)
my $node = WebGUI::Asset->getImportNode($session);

# Create a version tag to work in
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"EventManagementSystem Test"});

# Setup Mech
my ($mech, $redirect, $response);

# Get the site's base URL
my $baseUrl         = 'http://' . $session->config->get('sitename')->[0];
my $identifier = '123qwe';

if ( !eval { require Test::WWW::Mechanize; 1; } ) {
    plan skip_all => 'Cannot load Test::WWW::Mechanize. Will not test.';
}
$mech    = Test::WWW::Mechanize->new;
$mech->get( $baseUrl );
if ( !$mech->success ) {
    plan skip_all => "Cannot load URL '$baseUrl'. Will not test.";
}

my $i18n        = WebGUI::International->new( $session, 'Asset_EventManagementSystem' );
my $user = WebGUI::User->new($session, 3);


#----------------------------------------------------------------------------
# Tests

plan tests => 8;        # Increment this number for each test you create

#----------------------------------------------------------------------------

use_ok('WebGUI::Asset::Wobject::EventManagementSystem');
use_ok('WebGUI::Asset::Sku::EMSBadge');

# login
$mech       = getMechLogin( $baseUrl, $user, $identifier );
$mech->content_contains( 
    'Hello',
    'Welcome message shown on login',
);

# Add an EMS asset
my $ems = $node->addChild({
	className=>'WebGUI::Asset::Wobject::EventManagementSystem', 
	title => 'Test EMS', 
	description => 'This is a test ems', 
	url => '/test-ems',
	workflowIdCommit    => 'pbworkflow000000000003', # Commit Content Immediately
});
$versionTag->commit;

my $emsUrl = $baseUrl . $ems->getUrl();
$mech->get_ok( $emsUrl, "Get EMS url, $emsUrl");

# Add badge
$mech->get_ok( $emsUrl . '?func=add;class=WebGUI::Asset::Sku::EMSBadge' );

# Complete the badge form
my $properties  = {
    title           => 'Conference',
    description     => 'This just for the conference',
    price => 100,
};

$mech->submit_form_ok( {
    with_fields     => $properties,
}, 'Sent Badge creation form' );

# Shows the buy badge page
$mech->content_contains( 
    $i18n->get( 'buy' ),
    'Buy button is displayed',
);

# Shows the Badge instructions
$mech->content_contains( 
    $ems->get('badgeInstructions'),
    'Badge instructions are displayed',
);

# Add badge
$mech->get_ok( $emsUrl . '?func=add;class=WebGUI::Asset::Sku::EMSBadge' );

# Complete the badge form
my $properties  = {
    title           => 'Conference + Workshops',
    description     => 'This for the conference and workshops',
    price => 200,
};

$mech->submit_form_ok( {
    with_fields     => $properties,
}, 'Sent Badge creation form' );


my $badges = $ems->getBadges;
ok(scalar(@{$badges}) == 2, 'Two badges added');
ok($badges->[0]->getPrice == 100, 'Price of first badge');
ok($badges->[1]->getPrice == 200, 'Price of second badge');



#----------------------------------------------------------------------------
# getMechLogin( baseUrl, WebGUI::User, "identifier" )
# Returns a Test::WWW::Mechanize session after logging in the given user using
# the given identifier (password)
# baseUrl is a fully-qualified URL to the site to login to
sub getMechLogin {
    my $baseUrl     = shift;
    my $user        = shift;
    my $identifier  = shift;
    
    my $mech    = Test::WWW::Mechanize->new;
    $mech->get( $baseUrl . '?op=auth;method=displayLogin' );
    
    $mech->submit_form( 
    	form_number => 1,
        fields => {
            username        => $user->username,
            identifier      => $identifier,
        },
    ); 

    return $mech;
}

#----------------------------------------------------------------------------
# Cleanup
END {
		$ems->purge;

        # Clean up after thy self
        #$versionTag->rollback();
}
