# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

$SIG{HUP} = sub { use Carp; confess "hup"; };

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $tag = WebGUI::VersionTag->getWorking($session);
my $asset           = WebGUI::Test->asset->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    url             => 'example',
    groupIdEdit     => 3,       # Admins
} );
$tag->commit;
$asset = $asset->cloneFromDb;

#----------------------------------------------------------------------------
# Check permissions
my $helper = WebGUI::AssetHelper::ChangeUrl->new( id => 'change_url', session => $session, asset => $asset );

$session->user({ userId => 1 });
my $output  = $helper->process( $asset );
ok( $output->{error}, "Errors on bad permissions" );


#----------------------------------------------------------------------------
# Change URL!

$session->user({ userId => 3 }); # By the power of grayskull!
my $output  = $helper->process;
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
