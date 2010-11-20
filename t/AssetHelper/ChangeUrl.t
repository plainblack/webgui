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

# Test the ChangeUrl asset helper
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::AssetHelper::ChangeUrl;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $asset           = WebGUI::Test->asset->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    url             => 'example',
    groupIdEdit     => 3,       # Admins
} );

#----------------------------------------------------------------------------
# Check permissions

$session->user({ userId => 1 });
my $output  = WebGUI::AssetHelper::ChangeUrl->process( $asset );
ok( $output->{error}, "Errors on bad permissions" );


#----------------------------------------------------------------------------
# Change URL!

$session->user({ userId => 3 }); # By the power of grayskull!
my $output  = WebGUI::AssetHelper::ChangeUrl->process( $asset );
cmp_deeply( $output, {
    openDialog  => all(
        re( 'method=changeUrl' ),
        re( 'assetId=' . $asset->getId ),
    ),
}, "Opens a dialog" );

my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get( "/" );
$mech->session->user({ userId => 3 }); # I have the powerrrrrr!
$mech->get_ok( $output->{openDialog} );
$mech->submit_form_ok( { 
    fields => { url => 'example123123', confirm => 1 }
}, "Go through the form" );

$asset  = $asset->cloneFromDb;
is( $asset->url, 'example123123', 'URL got changed' );

done_testing();

#vim:ft=perl
