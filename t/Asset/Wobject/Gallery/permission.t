#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

## The goal of this test is to test permissions inside Gallerys

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Test::Maker::Permission;
use Test::More; 

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Gallery Test"});
WebGUI::Test->addToCleanup($versionTag);
my $maker           = WebGUI::Test::Maker::Permission->new;
my $gallery;

my $nonAdmin    = WebGUI::User->new( $session, "new" );
WebGUI::Test->addToCleanup($nonAdmin);


#----------------------------------------------------------------------------
# Tests
# Plan is delayed until all tests are prepared

#----------------------------------------------------------------------------
my $gallery 
    = $node->addChild({
        className               => 'WebGUI::Asset::Wobject::Gallery',
        groupIdAddComment       => '7',     # Everyone
        groupIdAddFile          => '2',     # Registered Users
        groupIdEdit             => '3',     # Admins
        groupIdView             => '7',     # Everyone
        ownerUserId             => '3',     # Admin
    });

$maker->prepare(
    {
        object      => $gallery,
        method      => "canView",
        pass        => [ '1', '3', $nonAdmin->userId ],
    },
    {
        object      => $gallery,
        method      => 'canEdit',
        pass        => [ '3' ],
        fail        => [ '1', $nonAdmin->userId ],
    },
    {
        object      => $gallery,
        method      => 'canAddFile',
        pass        => [ '3', $nonAdmin->userId ],
        fail        => [ '1' ],
    },
    {
        object      => $gallery,
        method      => 'canComment',
        pass        => [ '1', '3', $nonAdmin->userId ],
    }
);

plan tests => $maker->plan;

$maker->run;
