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

# Make sure the packed version of the default WebGUI templates works
# as it's supposed to
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use HTML::Packer;
use CSS::Packer;
use JavaScript::Packer;
use WebGUI::Asset::Template;

if ( !$ENV{CODE_COP} ) {
    plan skip_all => "Set CODE_COP to enable these tests";
}

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $templates       = WebGUI::Asset->getRoot( $session )
                    ->getLineage( ['descendants'], { 
                        includeOnlyClasses => [ 'WebGUI::Asset::Template' ],
                    } );
WebGUI::Test->addToCleanup( WebGUI::VersionTag->getWorking( $session ) );

#----------------------------------------------------------------------------
# Tests

plan tests => @$templates * 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test every template to make sure packed doesn't cause ERROR
for my $templateId ( @$templates ) {
    my $template    = WebGUI::Asset::Template->new( $session, $templateId );

    # Add a new revision to prevent changing anything
    $template       = $template->addRevision;

    # Make sure packed version is created
    $template->update({ template => $template->get('template') . " <p>HOPE  IS       THE     BEST   OF    THINGS</p>" });
    ok( $template->get('templatePacked'), "Packed template $templateId contains something" );
    like( $template->get('templatePacked'), qr{<p>HOPE IS THE BEST OF THINGS</p>$}, "Packed template $templateId actually packed" );

    # Make sure packed version is used
    $template->update({ usePacked => 1 });

    # Does it even work?
    my $content = $template->process;
    ok( $content, "Packed template $templateId gives back SOMETHING" )
        or diag( "URL: " . $template->getUrl . "\nPACKED: " . $template->get('templatePacked') );
    unlike( $content, qr/^ERROR/, "Packed template $templateId does not throw error" )
        or diag( "URL: " . $template->getUrl );

    # Cleanup
    $template->purgeRevision;
}


#vim:ft=perl
