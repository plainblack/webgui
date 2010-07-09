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

# This tests the operation of saving the AdSpaces
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::AdSpace;
use WebGUI::Operation::AdSpace;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $adSpace;

#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test that AdSpace name can't have ']' characters in them

# Create an AdSpace to verify the saving
$adSpace = WebGUI::AdSpace->create( $session, { name => 'oldname', } );

my $output
    = WebGUI::Test->getPage(
        'WebGUI::Operation::AdSpace::www_editAdSpaceSave',
        undef,
        {
            args        => [ $session ],
            formParams  => {
                adSpaceId       => $adSpace->getId,
                name            => 'This should ] fail',
            },
            userId      => 3,
        },
    );

like(
    $output,
    qr/error/,
    "Notifies user that an error occurred",
);

like(
    $output,
    qr/invalid/,
    "Notifies user what the error is",
);

ok( $adSpace->get('name') eq 'oldname', 'AdSpace does not get saved.' );

$adSpace->delete;
