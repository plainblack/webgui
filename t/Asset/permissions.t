#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Test::Maker::Permission;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::User;
use WebGUI::Asset::Wobject::Navigation;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Asset::Sku;
use WebGUI::Asset::Sku::Product;
use WebGUI::AssetVersioning;
use WebGUI::VersionTag;

use Test::More;
use Test::Deep;
use Test::MockObject;
use HTML::TokeParser;
use Data::Dumper;
use Storable qw/dclone/;

my $session = WebGUI::Test->session;

my $rootAsset = WebGUI::Test->asset;

##Test users.
##All users in here will be deleted at the end of the test.  DO NOT PUT
##Visitor or Admin in here!
my %testUsers = ();
##Just a regular user
$testUsers{'regular user'} = WebGUI::User->new($session, 'new');
$testUsers{'regular user'}->username('regular user');
##Users in group 12 can add Assets
$testUsers{'canAdd turnOnAdmin'} = WebGUI::User->new($session, 'new');
$testUsers{'canAdd turnOnAdmin'}->addToGroups(['12']);
$testUsers{'canAdd turnOnAdmin'}->username('Turn On Admin user');

##Just a user for owning assets
$testUsers{'owner'} = WebGUI::User->new($session, 'new');
$testUsers{'owner'}->username('Asset Owner');

##Test Groups
##All groups in here will be deleted at the end of the test
my %testGroups = ();
##A group and user for groupIdEdit
$testGroups{'canEdit asset'}     = WebGUI::Group->new($session, 'new');
$testUsers{'canEdit group user'} = WebGUI::User->new($session, 'new');
$testUsers{'canEdit group user'}->addToGroups([$testGroups{'canEdit asset'}->getId]);
$testUsers{'canEdit group user'}->username('Edit Group User');
WebGUI::Test->addToCleanup($testGroups{'canEdit asset'});

##A group and user for groupIdEdit
$testGroups{'canAdd asset'}     = WebGUI::Group->new($session, 'new');
$testUsers{'canAdd group user'} = WebGUI::User->new($session, 'new');
$testUsers{'canAdd group user'}->addToGroups([$testGroups{'canAdd asset'}->getId]);
$testUsers{'canEdit group user'}->username('Can Add Group User');
WebGUI::Test->addToCleanup($testGroups{'canAdd asset'});
WebGUI::Test->addToCleanup(values %testUsers);

my $canAddMaker = WebGUI::Test::Maker::Permission->new();
$canAddMaker->prepare({
    'className' => 'WebGUI::Asset',
    'session'   => $session,
    'method'    => 'canAdd',
    #'pass'      => [3, $testUsers{'canAdd turnOnAdmin'}, $testUsers{'canAdd group user'} ],
    'pass'      => [3, $testUsers{'canAdd group user'} ],
    'fail'      => [1, $testUsers{'regular user'},                                       ],
});

my $canAddMaker2 = WebGUI::Test::Maker::Permission->new();
$canAddMaker2->prepare({
    'className' => 'WebGUI::Asset',
    'session'   => $session,
    'method'    => 'canAdd',
    'fail'      => [$testUsers{'canAdd turnOnAdmin'},],
});

my $properties;
$properties = {
	#            '1234567890123456789012'
	id          => 'canEditAsset0000000010',
	title       => 'canEdit Asset Test',
	url         => 'canEditAsset1',
	className   => 'WebGUI::Asset',
    ownerUserId => $testUsers{'owner'}->userId,
    groupIdEdit => $testGroups{'canEdit asset'}->getId,
    groupIdView => 7,
};

my $canEditAsset = $rootAsset->addChild($properties, $properties->{id});

$properties = {};  ##Clear out the hash so that it doesn't leak later by accident.

my $canEditMaker = WebGUI::Test::Maker::Permission->new();
$canEditMaker->prepare({
    'object' => $canEditAsset,
    'method' => 'canEdit',
    'pass'   => [3, $testUsers{'owner'},        $testUsers{'canEdit group user'}, ],
    'fail'   => [1, $testUsers{'regular user'},                                   ],
});

$properties = {
	#            '1234567890123456789012'
	id          => 'canViewAsset0000000010',
	title       => 'canView Asset Test',
	url         => 'canViewAsset1',
	className   => 'WebGUI::Asset',
    ownerUserId => $testUsers{'owner'}->userId,
    groupIdEdit => $testGroups{'canEdit asset'}->getId,
    groupIdView => $testGroups{'canEdit asset'}->getId,
};


my $canViewAsset = $rootAsset->addChild($properties, $properties->{id});

$properties = {};  ##Clear out the hash so that it doesn't leak later by accident.

my $canViewMaker = WebGUI::Test::Maker::Permission->new();
$canViewMaker->prepare(
    {
        'object' => $canEditAsset,
        'method' => 'canView',
        'pass'   => [1, 3, $testUsers{'owner'}, $testUsers{'canEdit group user'}, $testUsers{'regular user'},],
    },
    {
        'object' => $canViewAsset,
        'method' => 'canView',
        'pass'   => [3, $testUsers{'owner'},        $testUsers{'canEdit group user'}, ],
        'fail'   => [1, $testUsers{'regular user'},                                   ],
    },
);

plan tests => $canAddMaker->plan
            + $canAddMaker2->plan
            + $canEditMaker->plan
            + $canViewMaker->plan
            ;

################################################################
#
# canAdd
#
################################################################

$session->config->set('assets/WebGUI::Asset/addGroup', $testGroups{'canAdd asset'}->getId );

$session->asset(WebGUI::Test->asset);
$canAddMaker->run;

#Without proper group setup, Turn On Admin is excluded from adding assets via assetAddPrivilege

$canAddMaker2->run;

################################################################
#
# canEdit
#
################################################################

$canEditMaker->run;

################################################################
#
# canView
#
################################################################

$canViewMaker->run;


