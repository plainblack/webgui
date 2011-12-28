#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Macro::LastUpdatedBy;
use WebGUI::VersionTag;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 1});

my $homeAsset = WebGUI::Test->asset;

my $numTests = 3;

plan tests => $numTests;

my $output = WebGUI::Macro::LastUpdatedBy::process($session);
is($output, '', "Macro returns '' if no asset is defined");

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

my $revised_user = WebGUI::User->new($session, 'new');
$revised_user->username('Andy');
WebGUI::Test->addToCleanup($revised_user);
$session->user({user => $revised_user});

my $root = WebGUI::Asset->getRoot($session);
my %properties_A = ( 
                className   => 'WebGUI::Asset',
                title       => 'Asset A', 
                url         => 'asset-a',
                ownerUserId => 3,
                groupIdView => 7,
                groupIdEdit => 3,
                id          => '1',
                #              '1234567890123456789012',
);

my $tag = WebGUI::VersionTag->getWorking($session);
my $assetA = $root->addChild(\%properties_A, $properties_A{id});

$session->asset($assetA);
$tag->commit;
WebGUI::Test->addToCleanup($tag);

$output = WebGUI::Macro::LastUpdatedBy::process($session);
is($output, 'Andy', 'Default asset last revised by andy');

$revised_user->delete;
#$revised_user->uncache;

$output = WebGUI::Macro::LastUpdatedBy::process($session);
is($output, 'Unknown', 'macro returns Unknown when the user object cannot be found');
