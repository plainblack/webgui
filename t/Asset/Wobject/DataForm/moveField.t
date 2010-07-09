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

# This tests the moveField functions of the DataForm
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::Asset::Wobject::DataForm;
use WebGUI::VersionTag;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Create a DataForm
my $df  = WebGUI::Asset->getImportNode( $session )
        ->addChild( {
            className           => "WebGUI::Asset::Wobject::DataForm",
            mailData            => 0,
            fieldConfiguration  => '[]',
        } );
WebGUI::Test->addToCleanup($df);

# Add three fields to the DataForm
$df->createField( "one", { label => "One" } );
$df->createField( "two", { label => "Two" } );
$df->createField( "three", { label => "Three" } );

#----------------------------------------------------------------------------
# Tests

plan tests => 5;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Move Field Up

# Test the current positions of the fields
cmp_deeply( 
    $df->getFieldOrder, 
    [ 'one', 'two', 'three' ], 
    "Fields start in order they're added", 
);

# Move the field
$df->moveFieldUp( 'three' );

# Test the new positions of the fields
cmp_deeply(
    $df->getFieldOrder,
    [ 'one', 'three', 'two' ],
    "Field 'three' is moved up",
);

$df->moveFieldUp( 'one' );

cmp_deeply(
    $df->getFieldOrder,
    [ 'one', 'three', 'two' ],
    "Field 'one' can't be moved up any more",
);

#----------------------------------------------------------------------------
# Move Field Down

# Move the field
$df->moveFieldDown( 'three' );

# Test the new positions of the fields
cmp_deeply(
    $df->getFieldOrder,
    [ 'one', 'two', 'three' ],
    "Field 'three' is moved down",
);

# Move the field
$df->moveFieldDown( 'three' );

# Test the new positions of the fields
cmp_deeply(
    $df->getFieldOrder,
    [ 'one', 'two', 'three' ],
    "Field 'three' can't be moved down any more ",
);


#vim:ft=perl
