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

# Test the EMSRibbon asset
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize;
use WebGUI::Shop::Cart;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
my $tag = WebGUI::VersionTag->getWorking($session);
my $ems = WebGUI::Test->asset( className => 'WebGUI::Asset::Wobject::EventManagementSystem' );
my $badge = $ems->addChild({
    className       => 'WebGUI::Asset::Sku::EMSBadge',
});
my $ribbon = $ems->addChild({
    className       => 'WebGUI::Asset::Sku::EMSRibbon',
});
$tag->commit;
WebGUI::Test->addToCleanup($tag);

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Test the addToCart form
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });
$mech->get_ok( $ribbon->getUrl( 'badgeId=' . $badge->getId ) );
$mech->submit_form_ok({
    fields      => { },
});

my $cart = WebGUI::Shop::Cart->newBySession( $mech->session );
WebGUI::Test->addToCleanup($cart);
ok( $cart->getItemsByAssetId([ $ribbon->getId ])->[0]->getId, $ribbon->getId );


done_testing;
#vim:ft=perl
