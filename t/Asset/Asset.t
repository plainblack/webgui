#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

my @fixIdTests    = getFixIdTests($session);
my @fixTitleTests = getFixTitleTests($session);
my @getTitleTests = getTitleTests($session);

my $rootAsset = WebGUI::Asset->getRoot($session);

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
addToCleanup($testGroups{'canEdit asset'});

##A group and user for groupIdEdit
$testGroups{'canAdd asset'}     = WebGUI::Group->new($session, 'new');
$testUsers{'canAdd group user'} = WebGUI::User->new($session, 'new');
$testUsers{'canAdd group user'}->addToGroups([$testGroups{'canAdd asset'}->getId]);
$testUsers{'canEdit group user'}->username('Can Add Group User');
addToCleanup($testGroups{'canAdd asset'}, values %testUsers);

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

my $versionTag2 = WebGUI::VersionTag->getWorking($session);
addToCleanup($versionTag2);

my $canEditAsset = $rootAsset->addChild($properties, $properties->{id});

$versionTag2->commit;
$properties = {};  ##Clear out the hash so that it doesn't leak later by accident.

my $canEditMaker = WebGUI::Test::Maker::Permission->new();
$canEditMaker->prepare({
    'object' => $canEditAsset,
    'method' => 'canEdit',
    'pass'   => [3, $testUsers{'owner'},        $testUsers{'canEdit group user'}, ],
    'fail'   => [1, $testUsers{'regular user'},                                   ],
});

my $versionTag3 = WebGUI::VersionTag->getWorking($session);
addToCleanup($versionTag3);
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

$versionTag3->commit;
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

plan tests => 127
            + scalar(@fixIdTests)
            + scalar(@fixTitleTests)
            + 2*scalar(@getTitleTests) #same tests used for getTitle and getMenuTitle
            + $canAddMaker->plan
            + $canAddMaker2->plan
            + $canEditMaker->plan
            + $canViewMaker->plan
            ;

# Test the default constructor
my $defaultAsset = WebGUI::Asset->getDefault($session);
is(ref $defaultAsset, 'WebGUI::Asset::Wobject::Layout','default constructor');

# Test the new constructor
my $assetId = "PBnav00000000000000001"; # one of the default nav assets

# - explicit class
my $asset = WebGUI::Asset->new($session, $assetId, 'WebGUI::Asset::Wobject::Navigation');
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation','new constructor explicit - ref check');
is ($asset->getId, $assetId, 'new constructor explicit - returns correct asset');

# - new by hashref properties
$asset = undef;
$asset = WebGUI::Asset->newByPropertyHashRef($session, {
                                                          className=>"WebGUI::Asset::Wobject::Navigation",
		                                                  assetId=>$assetId
													    });
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation', 'new constructor newByHashref - ref check');
is ($asset->getId, $assetId, 'new constructor newByHashref - returns correct asset');

# - implicit class
$asset = undef;
$asset = WebGUI::Asset::Wobject::Navigation->new($session, $assetId);
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation', 'new constructor implicit - ref check');
is ($asset->getId, $assetId, 'new constructor implicit - returns correct asset');

# - die gracefully
my $deadAsset = 1;

# -- no asset id
$deadAsset = WebGUI::Asset->new($session, '', 'WebGUI::Asset::Wobject::Navigation');
is ($deadAsset, undef,'new constructor with no assetId returns undef');

# -- no class
my $primevalAsset = WebGUI::Asset->new($session, $assetId);
isa_ok ($primevalAsset, 'WebGUI::Asset');

# Test the newByDynamicClass Constructor
$asset = undef;

$asset = WebGUI::Asset->newByDynamicClass($session, $assetId);
is (ref $asset, 'WebGUI::Asset::Wobject::Navigation', 'newByDynamicClass constructor - ref check');
is ($asset->getId, $assetId, 'newByDynamicClass constructor - returns correct asset');

# - die gracefully
$deadAsset = 1;

# -- invalid asset id
$deadAsset = WebGUI::Asset->newByDynamicClass($session, 'RoysNonExistantAssetId');
is ($deadAsset, undef,'newByDynamicClass constructor with invalid assetId returns undef');

# -- no assetId
is(
    WebGUI::Asset->newByDynamicClass( $session ),
    undef,
    "newByDynamicClass constructor returns 'undef' with no assetId",
);

# -- no session
is(
    WebGUI::Asset->newByDynamicClass( ),
    undef,
    "newByDynamicClass constructor returns 'undef' with no valid WebGUI::Session",
);
is(
    WebGUI::Asset->newByDynamicClass( "nothing" ),
    undef,
    "newByDynamicClass constructor returns 'undef' with no valid WebGUI::Session",
);

# Root Asset
isa_ok($rootAsset, 'WebGUI::Asset');
is($rootAsset->getId, 'PBasset000000000000001', 'Root Asset ID check');

# getMedia Constructor

my $mediaFolder = WebGUI::Asset->getMedia($session);
isa_ok($mediaFolder, 'WebGUI::Asset::Wobject::Folder');
is($mediaFolder->getId, 'PBasset000000000000003', 'Media Folder Asset ID check');

# getImportNode Constructor

my $importNode = WebGUI::Asset->getImportNode($session);
isa_ok($importNode, 'WebGUI::Asset::Wobject::Folder');
is($importNode->getId, 'PBasset000000000000002', 'Import Node Asset ID check');
is($importNode->getParent->getId, $rootAsset->getId, 'Import Nodes parent is Root Asset');

# tempspace Constructor

my $tempNode = WebGUI::Asset->getTempspace($session);
isa_ok($tempNode, 'WebGUI::Asset::Wobject::Folder');
is($tempNode->getId, 'tempspace0000000000000', 'Tempspace Asset ID check');
is($tempNode->getParent->getId, $rootAsset->getId, 'Tempspace parent is Root Asset');

################################################################
#
# urlExists
#
################################################################

##We need an asset with a URL for this one.

my $importUrl = $importNode->get('url');
my $importId  = $importNode->getId;

ok(  WebGUI::Asset->urlExists($session, $importUrl),      'url for import node exists');
ok(  WebGUI::Asset->urlExists($session, uc($importUrl)),  'url for import node exists, case insensitive');
ok( !WebGUI::Asset->urlExists($session, '/foo/bar/baz'),  'made up url does not exist');

ok( !WebGUI::Asset->urlExists($session, $importUrl,     {assetId => $importId}),       'url for import node only exists at specific id');
ok( !WebGUI::Asset->urlExists($session, '/foo/bar/baz', {assetId => $importId}),       'imaginary url does not exist at specific id');
ok(  WebGUI::Asset->urlExists($session, $importUrl,     {assetId => 'notAnWebGUIId'}), 'imaginary url does not exist at wrong id');

################################################################
#
# addEditLabel
#
################################################################

my $i18n = WebGUI::International->new($session, 'Asset_Wobject');
is($importNode->addEditLabel, $i18n->get('edit').' '.$importNode->getName, 'addEditLabel, default mode is edit mode');

my $origRequest = $session->{_request};
my $newRequest = Test::MockObject->new();
my $func;
$newRequest->set_bound('body', \$func);
$newRequest->set_bound('param', \$func);
$session->{_request} = $newRequest;
$func = 'add';
is($importNode->addEditLabel, $i18n->get('add').' '.$importNode->getName, 'addEditLabel, use add mode');
$session->{_request} = $origRequest;

################################################################
#
# fixUrl
#
################################################################

my $versionTag = WebGUI::VersionTag->getWorking($session);
addToCleanup($versionTag);
$versionTag->set({name=>"Asset tests"});

$properties = {
	#            '1234567890123456789012'
	id        => 'fixUrlAsset00000000012',
	title     => 'fixUrl Asset Test',
	className => 'WebGUI::Asset::Wobject::Folder',
	url       => 'fixUrlFolderURL2',
};

my $fixUrlAsset = $defaultAsset->addChild($properties, $properties->{id});

#                    '1234567890123456789012'
$properties->{id}  = 'fixUrlAsset00000000013';
$properties->{url} = 'fixUrlFolderURL9';

my $fixUrlAsset2 = $defaultAsset->addChild($properties, $properties->{id});

#                    '1234567890123456789012'
$properties->{id}  = 'fixUrlAsset00000000014';
$properties->{url} = 'fixUrlFolderURL00';

my $fixUrlAsset3 = $defaultAsset->addChild($properties, $properties->{id});

#                    '1234567890123456789012'
$properties->{id}  = 'fixUrlAsset00000000015';
$properties->{url} = 'fixUrlFolderURL100';

my $fixUrlAsset4 = $defaultAsset->addChild($properties, $properties->{id});
is($fixUrlAsset4->get('url'), 'fixurlfolderurl100', 'asset setup correctly for 100->101 test');

delete $properties->{url};
#                          '1234567890123456789012'
$properties->{id}        = 'fixUrlAsset00000000016';
$properties->{menuTitle} = 'fix url folder url autogenerated';

my $fixUrlAsset5 = $defaultAsset->addChild($properties, $properties->{id});

my $properties2 = {
	#            '1234567890123456789012'
	id        => 'fixTitleAsset000000010',
	title     => '',
	className => 'WebGUI::Asset::Snippet',
	url       => 'fixTitleAsset1',
};

my $fixTitleAsset = $defaultAsset->addChild($properties2, $properties2->{id});
##Commit this asset right away
$fixTitleAsset->commit;

$properties2 = {
	#            '1234567890123456789012'
	id        => 'getTitleAsset000000010',
	title     => '',
	className => 'WebGUI::Asset::Snippet',
	url       => 'getTitleAsset1',
};

my $getTitleAsset = $defaultAsset->addChild($properties2, $properties2->{id});
$getTitleAsset->commit;

$versionTag->commit;

$session->setting->set('urlExtension', undef);

is($importNode->fixUrl('1234'.'_'x235 . 'abcdefghij'), '1234'.'_'x235 . 'abcdefghij', 'fixUrl leaves long URLs under 250 characters alone');
is($importNode->fixUrl('1234'.'_'x250 . 'abcdefghij'), '1234'.'_'x216, 'fixUrl truncates long URLs over 250 characters to 220 characters');
is $importNode->fixUrl('---'), '---', '... 3 dashes are legal';

WebGUI::Test->originalConfig('extrasURL');
WebGUI::Test->originalConfig('uploadsURL');
WebGUI::Test->originalConfig('assets');

$session->config->set('extrasURL',    '/extras');
$session->config->set('uploadsURL',   '/uploads');

is($importNode->fixUrl('/extras'),  '_extras',  'underscore prepended to URLs that match the extrasURL');
is($importNode->fixUrl('/uploads'), '_uploads', 'underscore prepended to URLs that match the uploadsURL');

#Now that we have verified that extrasURL and uploadsURL both work, just test one.
$session->config->set('extrasURL',  '/extras1/');
is($importNode->fixUrl('/extras1'), '_extras1', 'trailing underscore in extrasURL does not defeat the check');

$session->config->set('extrasURL',  'http://mysite.com/extras2');
is($importNode->fixUrl('/extras2'), '_extras2', 'underscore prepended to URLs that match the extrasURL, even with http://');

##Now, check extension removal

is($importNode->fixUrl('one.html/two.html'), 'one/two.html', 'extensions are not allowed higher up in the path');
is($importNode->fixUrl('one.html/two.html/three.html'), 'one/two/three.html', 'extensions are not allowed anywhere in the path');
is($importNode->fixUrl('one.one.html/two.html/three.html'), 'one/two/three.html', 'multiple dot extensions are removed in any path element');
is($importNode->fixUrl('.startsWithDot'), '.startswithdot', 'leading dots are okay');

##Now, check duplicate URLs

is($importNode->fixUrl('/rootyRootRoot'), 'rootyrootroot', 'URLs are lowercased');
is($importNode->fixUrl('/root'), 'root2', 'If a node exists, appends a "2" to it');
my $importNodeURL = $importNode->getUrl;
$importNodeURL =~ s{ ^ / }{}x;
is($importNode->fixUrl($importNodeURL), $importNodeURL, q{fixing an asset's own URL returns it unchanged});

is($importNode->fixUrl('fixUrlFolderURL2'),   'fixurlfolderurl3',   'if a URL exists, fix it by incrementing any ending digits 2 -> 3');
is($importNode->fixUrl('fixUrlFolderURL9'),   'fixurlfolderurl10',  'increments past single digits 9 -> 10');
is($importNode->fixUrl('fixUrlFolderURL00'),  'fixurlfolderurl1',   'initial zeroes are not preserved 00 -> 1');
is($importNode->fixUrl('fixUrlFolderURL100'), 'fixurlfolderurl101', '100->101');

is($fixUrlAsset5->fixUrl(), 'home/fix-url-folder-url-autogenerated', 'fixUrl will autogenerate a url if not provided one');

# Automatic extension adding
$session->setting->set('urlExtension', 'html');
is($importNode->fixUrl('fixurl'), 'fixurl.html', 'Automatic adding of extensions works');
is($importNode->fixUrl('fixurl.css'), 'fixurl.css', 'extensions aren\'t automatically added if there is already and extension');
$session->setting->set('urlExtension', undef);

################################################################
#
# fixId
#
################################################################

my $ownerUserId = $importNode->getValue('ownerUserId');

foreach my $test (@fixIdTests) {
    my $fixedId    = $importNode->fixId($test->{id}, 'ownerUserId');
    my $expectedId = $test->{pass} ? $test->{id} : $ownerUserId;
    is($fixedId, $expectedId, $test->{comment});
}

################################################################
#
# fixTitle
#
################################################################

my $importNodeTitle = $importNode->getTitle();

foreach my $test (@fixTitleTests) {
    my $fixedTitle    = $importNode->fixTitle($test->{title}, 'ownerUserId');
    my $expectedTitle = defined $test->{fixed} ? $test->{fixed} : $importNodeTitle;
    is($fixedTitle, $expectedTitle, $test->{comment});
}

$fixTitleAsset->update({'title' => 0});

is($fixTitleAsset->fixTitle(''), 'Untitled', q{fixTitle: title is false, fixTitle returns 'Untitled'});

################################################################
#
# getTitle
# getMenuTitle
#
################################################################

my $getTitleAssetName = $getTitleAsset->getName();

foreach my $test (@getTitleTests) {
    my $expectedTitle = $test->{assetName} ? $getTitleAssetName : $test->{title};
    $getTitleAsset->update({
                            title     => $test->{title},
                            menuTitle => $test->{title},
                           });
    is($getTitleAsset->getTitle,     $expectedTitle, $test->{comment});
    is($getTitleAsset->getMenuTitle, $expectedTitle, $test->{comment});
}

################################################################
#
# getIcon
#
################################################################

like($importNode->getIcon,    qr{folder.gif$},       'getIcon gets correct icon for importNode');
like($importNode->getIcon(1), qr{small/folder.gif$}, 'getIcon gets small icon for importNode');

my $extras = $session->config->get('extrasURL');

like($importNode->getIcon(),  qr{$extras}, 'getIcon returns an icon from the extras URL');

like($defaultAsset->getIcon,  qr{layout.gif$},       'getIcon gets icon for a layout');
like($fixTitleAsset->getIcon, qr{snippet.gif$},      'getIcon gets icon for a snippet');


TODO: {
    local $TODO = "Coverage test";
    ok(0, "Test the default name for the icon, if not given in the definition sub");
}

################################################################
#
# canAdd
#
################################################################

$session->config->set('assets/WebGUI::Asset/addGroup', $testGroups{'canAdd asset'}->getId );

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

################################################################
#
# addMissing
#
################################################################

$session->user({ userId => 3 });
$session->var->switchAdminOff;
is($canEditAsset->addMissing('/nowhereMan'), undef, q{addMissing doesn't return anything unless use is in Admin Mode});

$session->var->switchAdminOn;
my $addMissing = $canEditAsset->addMissing('/nowhereMan');
ok($addMissing, 'addMissing returns some output when in Admin Mode');

{

    my $parser = HTML::TokeParser->new(\$addMissing);
    my $link = $parser->get_tag('a');
    my $url = $link->[1]{'href'} || '-';
    like($url, qr{func=add;class=WebGUI::Asset::Wobject::Layout;url=/nowhereMan$}, 'addMissing: Link will add a new page asset with correct URL');

}

################################################################
#
# getContainer
#
################################################################

is($rootAsset->getContainer->getId, $rootAsset->getId, 'getContainer: A folder is a container, its container is itself');
is($fixTitleAsset->getContainer->getId, $defaultAsset->getId, 'getContainer: A snippet is not a container, its container is its parent');

################################################################
#
# getName
#
################################################################

is($fixTitleAsset->getName, $i18n->get('assetName', 'Asset_Snippet'), 'getName: Returns the internationalized name of the Asset, Snippet');
is($importNode->getName,    $i18n->get('assetName', 'Asset_Folder'),  'getName: Returns the internationalized name of the Asset, Folder');
is($canEditAsset->getName,  $i18n->get('asset', 'Asset'),             'getName: Returns the internationalized name of the Asset, core Asset');

################################################################
#
# getToolbarState
# toggleToolbar
#
################################################################

is($getTitleAsset->getToolbarState, undef, 'getToolbarState: default toolbar state is undef');
$getTitleAsset->toggleToolbar();
is($getTitleAsset->getToolbarState, 1, 'getToolbarState: toggleToolbarState toggled the state to 1');
$getTitleAsset->toggleToolbar();
is($getTitleAsset->getToolbarState, 0, 'getToolbarState: toggleToolbarState toggled the state to 0');

################################################################
#
# getUiLevel
#
################################################################

is($canEditAsset->getUiLevel,  1, 'getUiLevel: WebGUI::Asset uses the default uiLevel of 1');
is($fixTitleAsset->getUiLevel, 5, 'getUiLevel: Snippet has an uiLevel of 5');

my $origAssetUiLevel = $session->config->get('assetUiLevel');
$session->config->set('assets/WebGUI::Asset/uiLevel', 8);
$session->config->set('assets/WebGUI::Asset::Snippet/uiLevel', 8);

is($canEditAsset->getUiLevel,  8, 'getUiLevel: WebGUI::Asset has a configured uiLevel of 8');
is($fixTitleAsset->getUiLevel, 8, 'getUiLevel: Snippet has a configured uiLevel of 8');


################################################################
#
# assetExists
#
################################################################

{

    my $id    = $canViewAsset->getId;
    my $class = 'WebGUI::Asset';
    my $date  = $canViewAsset->get('revisionDate');

    ok ( WebGUI::Asset->assetExists($session, $id, $class, $date), 'assetExists with proper class, id and revisionDate');
    ok (!WebGUI::Asset->assetExists($session, $id, 'WebGUI::Asset::Snippet', $date), 'assetExists with wrong class does not exist');
    my $id2 = $id;
    ++$id2;
    ok (!WebGUI::Asset->assetExists($session, $id2, $class, $date), 'assetExists with wrong id does not exist');
    ok (!WebGUI::Asset->assetExists($session, $id,  $class, $date+1), 'assetExists with wrong revisionDate does not exist');

}

################################################################
#
# getEditTabs
#
################################################################

my @tabs = $canViewAsset->getEditTabs;
is(scalar(@tabs), 4, 'getEditTabs: 4 tabs by default');

################################################################
#
# getEditForm
#
################################################################

$session->style->sent(0); ##Prevent extra output from being generated by session->style
                          ##At some point, a test will need to tie STDOUT and make sure
                          ##that the output is correct.
isa_ok($canViewAsset->getEditForm, 'WebGUI::TabForm', 'getEditForm: Returns a tabForm');

TODO: {
    local $TODO = 'More getEditForm tests';
    ok(0, 'Validate form output');
}

################################################################
#
# newByDynamicClass
#
################################################################

my $newFixTitleAsset = WebGUI::Asset->newByDynamicClass($session, $fixTitleAsset->getId);
isnt($newFixTitleAsset, undef, 'newByDynamicClass did not fail');
isa_ok($newFixTitleAsset, 'WebGUI::Asset', 'newByDynamicClass: able to look up an existing asset by id');
cmp_deeply($newFixTitleAsset->{_properties}, $fixTitleAsset->{_properties}, 'newByDynamicClass created a duplicate asset');

################################################################
#
# getNotFound
#
################################################################

my $origNotFoundPage =  $session->setting->get('notFoundPage');

$session->setting->set('notFoundPage', WebGUI::Asset->getDefault($session)->getId);

isa_ok(WebGUI::Asset->getNotFound($session), 'WebGUI::Asset', 'getNotFound: Returns an asset');
is(WebGUI::Asset->getNotFound($session)->getId, WebGUI::Asset->getDefault($session)->getId, 'getNotFound: Returns the correct asset');

$session->setting->set('notFoundPage', $fixTitleAsset->getId);
is(WebGUI::Asset->getNotFound($session)->getId, $fixTitleAsset->getId, 'getNotFound: Returns the correct asset on a different asset');

$session->setting->set('notFoundPage', $origNotFoundPage);

################################################################
#
# isExportable
#
################################################################
is($rootAsset->get('isExportable'), 1, 'isExportable exists, defaults to 1');

################################################################
#
# getSeparator
#
################################################################
is($rootAsset->getSeparator,      '~~~PBasset000000000000001~~~', 'getSeparator, known assetId');
is($rootAsset->getSeparator('!'), '!!!PBasset000000000000001!!!', 'getSeparator, given pad character');
isnt($rootAsset->getSeparator, $mediaFolder->getSeparator, 'getSeparator: unique string');

################################################################
#
# get
#
################################################################
my $assetProps = $rootAsset->get();
my $funkyTitle = q{Miss Annie's Whoopie Emporium and Sasparilla Shop};
$assetProps->{title} = $funkyTitle;

isnt( $rootAsset->get('title'), $funkyTitle, 'get returns a safe copy of the Asset properties');

################################################################
#
# getIsa
#
################################################################
my $node = WebGUI::Asset->getRoot($session);
my $product1 = $node->addChild({ className => 'WebGUI::Asset::Sku::Product'}, undef, undef, { skipAutoCommitWorkflows => 1});
my $product2 = $node->addChild({ className => 'WebGUI::Asset::Sku::Product'}, undef, undef, { skipAutoCommitWorkflows => 1});
my $product3 = $node->addChild({ className => 'WebGUI::Asset::Sku::Product'}, undef, undef, { skipAutoCommitWorkflows => 1});
my $pTag = WebGUI::VersionTag->getWorking($session);
$pTag->commit;
addToCleanup($pTag);
my $product4 = $node->addChild({ className => 'WebGUI::Asset::Sku::Product'}, undef, undef, { skipAutoCommitWorkflows => 1});
addToCleanup($product4);

my $getAProduct = WebGUI::Asset::Sku::Product->getIsa($session);
isa_ok($getAProduct, 'CODE', 'getIsa returns a sub ref');
my $counter = 0;
my $productIds = [];
while( my $product = $getAProduct->()) {
    ++$counter;
    push @{ $productIds }, $product->getId;
}
is($counter, 3, 'getIsa: returned only 3 Products');
cmp_bag($productIds, [$product1->getId, $product2->getId, $product3->getId], 'getIsa returned the correct 3 products');

my $getASku = WebGUI::Asset::Sku->getIsa($session);
$counter = 0;
my $skuIds = [];
while( my $sku = $getASku->()) {
    ++$counter;
    push @{ $skuIds }, $sku->getId;
}
is($counter, 3, 'getIsa: returned only 3 Products for a parent class');
cmp_bag($skuIds, [$product1->getId, $product2->getId, $product3->getId], 'getIsa returned the correct 3 products for a parent class');

my $getAnotherSku = WebGUI::Asset::Sku->getIsa($session, 0, { returnAll => 1, });
$counter = 0;
while( my $sku = $getAnotherSku->()) {
    ++$counter;
}
is($counter, 4, 'getIsa: returned all 4 skus with returnAll => 1');

$product1->purge;
$product2->purge;
$product3->purge;
$product4->purge;

################################################################
#
# inheritUrlFromParent
#
################################################################

my $versionTag4 = WebGUI::VersionTag->getWorking($session);
addToCleanup($versionTag4);
$versionTag4->set( { name => 'inheritUrlFromParent tests' } );

$properties = {
    #              '1234567890123456789012'
    id          => 'inheritUrlFromParent01',
    title       => 'inheritUrlFromParent01',
    className   => 'WebGUI::Asset::Wobject::Layout',
    url         => 'inheriturlfromparent01',
};

my $iufpAsset = $defaultAsset->addChild($properties, $properties->{id});
$iufpAsset->commit;

$properties2 = {
    #              '1234567890123456789012'
    id          => 'inheritUrlFromParent02',
    title       => 'inheritUrlFromParent02',
    className   => 'WebGUI::Asset::Wobject::Layout',
    url         => 'inheriturlfromparent02',
};

my $iufpAsset2 = $iufpAsset->addChild($properties2, $properties2->{id});
$iufpAsset2->update( { inheritUrlFromParent => 1 } );
$iufpAsset2->commit;
is($iufpAsset2->get('url'), 'inheriturlfromparent01/inheriturlfromparent02', 'inheritUrlFromParent works');

my $properties2a = {
    #                       '1234567890123456789012'
    id                   => 'inheritUrlFromParent2a',
    title                => 'inheritUrlFromParent2a',
    className            => 'WebGUI::Asset::Wobject::Layout',
    url                  => 'inheriturlfromparent2a',
    inheritUrlFromParent => 1,
};

my $iufpAsset2a = $iufpAsset->addChild($properties2a, $properties2a->{id});
$iufpAsset2a->commit;
is($iufpAsset2a->get('url'), 'inheriturlfromparent01/inheriturlfromparent2a', '... works when created with the property');

# works for setting, now try disabling. Should not change the URL.
$iufpAsset2->update( { inheritUrlFromParent => 0 } );
$iufpAsset2->commit;
is($iufpAsset2->get('url'), 'inheriturlfromparent01/inheriturlfromparent02', '... setting inheritUrlFromParent to 0 works');

# also make sure that it is actually disabled
is($iufpAsset2->get('inheritUrlFromParent'), 0, "... disabling inheritUrlFromParent actually works");

# works for setting and disabling, now ensure it recurses

my $properties3 = {
    #              '1234567890123456789012'
    id          => 'inheritUrlFromParent03',
    title       => 'inheritUrlFromParent03',
    className   => 'WebGUI::Asset::Wobject::Layout',
    url         => 'inheriturlfromparent03',
};
my $iufpAsset3 = $iufpAsset2->addChild($properties3, $properties3->{id});
$iufpAsset3->commit;
$iufpAsset2->update( { inheritUrlFromParent => 1 } );
$iufpAsset2->commit;
$iufpAsset3->update( { inheritUrlFromParent => 1 } );
$iufpAsset3->commit;
is($iufpAsset3->get('url'), 'inheriturlfromparent01/inheriturlfromparent02/inheriturlfromparent03', '... recurses properly');

$iufpAsset2->update({url => 'iufp2'});
is($iufpAsset2->get('url'), 'inheriturlfromparent01/iufp2', '... update works propertly when iUFP is not passed');


################################################################
#
# addRevision to uncommitted child of uncommitted parent
#
################################################################

my $versionTag5 = WebGUI::VersionTag->getWorking($session);
$versionTag5->set( { name => 'move revision of uncommitted child to uncommitted parent tests vt1' } );

$properties = {

    #              '1234567890123456789012'
    id        => 'moveVersionToParent_01',
    title     => 'moveVersionToParent_01',
    className => 'WebGUI::Asset::Wobject::Layout',
    url       => 'moveVersionToParent_01',
};

my $parentAsset = $defaultAsset->addChild( $properties, $properties->{id}, undef, { skipAutoCommitWorkflows => 1 } );
my $parentVersionTag = WebGUI::VersionTag->new( $session, $parentAsset->get('tagId') );
is( $parentVersionTag->get('isCommitted'), 0, 'built non-committed parent asset' );

my $versionTag6 = WebGUI::VersionTag->create( $session, {} );
$versionTag6->set( { name => 'move revision of uncommitted child to uncommitted parent tests vt2' } );
$versionTag6->setWorking;

$properties2 = {

    #              '1234567890123456789012'
    id        => 'moveVersionToParent_03',
    title     => 'moveVersionToParent_03',
    className => 'WebGUI::Asset::Wobject::Layout',
    url       => 'moveVersionToParent_03',
};

my $childAsset = $parentAsset->addChild(
    $properties2, $properties2->{id},
    time(),
    { skipAutoCommitWorkflows => 1 }
);
my $testAsset      = WebGUI::Asset->newPending( $session, $childAsset->get('parentId') );
my $testVersionTag = WebGUI::VersionTag->new( $session,   $testAsset->get('tagId') );

my $childVersionTag;
$childVersionTag = WebGUI::VersionTag->new( $session, $childAsset->get('tagId') );
is( $childVersionTag->get('isCommitted'), 0, 'built non-committed child asset' );

is( $testAsset->get('tagId'),
    $childAsset->get('tagId'),
    'uncommitted parent asset and uncommitted child asset have same version tag at addChild'
);

$properties2 = {

    #              '1234567890123456789012'
    id        => 'moveVersionToParent_03',
    title     => 'moveVersionToParent_03a',
    className => 'WebGUI::Asset::Wobject::Layout',
    url       => 'moveVersionToParent_03a',
};
sleep 2;
$childAsset->addRevision( $properties2, time(), { skipAutoCommitWorkflows => 1 } );

is( $parentVersionTag->get('isCommitted'), 0, 'confimr non-committed parent asset after revision' );
is( $childVersionTag->get('isCommitted'),  0, 'confirm non-committed child asset after revision' );

is( $testAsset->get('tagId'),
    $childAsset->get('tagId'),
    'uncommitted parent asset and uncommitted child asset have same version tag after addRevision'
);

eval { $testVersionTag->commit; };

$session->log->warn('parent asset is now committed');
is( $testVersionTag->get('isCommitted'), 1, 'parent asset is now committed' );

$childVersionTag = WebGUI::VersionTag->new( $session, $childAsset->get('tagId') );
is( $childVersionTag->get('isCommitted'), 1, 'child asset is now committed' );

################################################################
#
# cloneFromDb
#
################################################################

my $assetToCommit = $defaultAsset->addChild({ className => 'WebGUI::Asset::Snippet', title => 'Snippet to commit and clone from db', });
my $cloneTag = WebGUI::VersionTag->getWorking($session);
addToCleanup($cloneTag);
$cloneTag->commit;
is($assetToCommit->get('status'), 'pending', 'cloneFromDb: local asset is still pending');
$assetToCommit = $assetToCommit->cloneFromDb;
is($assetToCommit->get('status'), 'approved', '... returns fresh, commited asset from the db');

################################################################
#
# checkView
#
################################################################

my $trashedAsset = $defaultAsset->addChild({
    className => 'WebGUI::Asset::Snippet', title     => 'Trashy',
});

my $clippedAsset = $defaultAsset->addChild({
    className => 'WebGUI::Asset::Snippet', title     => 'Clippy',
});

my $checkTag = WebGUI::VersionTag->getWorking($session);
$checkTag->commit;
addToCleanup($checkTag);
$trashedAsset = $trashedAsset->cloneFromDb;
$clippedAsset = $clippedAsset->cloneFromDb;
$trashedAsset->trash;
$clippedAsset->cut;
is $trashedAsset->get('state'), 'trash',     'checkView setup: trashed an asset';
is $clippedAsset->get('state'), 'clipboard', '... clipped an asset';

$session->var->switchAdminOff;
$session->http->setRedirectLocation('');
$session->http->setStatus(200, 'OK');

$trashedAsset->checkView();
is $session->http->getStatus, 410, '... status set to 410 for trashed asset';
is $session->http->getRedirectLocation, '', '... no redirect set';

$session->http->setStatus(200, 'OK');
$clippedAsset->checkView();
is $session->http->getStatus, 410, '... status set to 410 for cut asset';
is $session->http->getRedirectLocation, '', '... no redirect set';

$session->var->switchAdminOn;
$session->http->setStatus(200, 'OK');
is $trashedAsset->checkView(), 'chunked', '... returns "chunked" when admin is on for trashed asset';
is $session->http->getRedirectLocation, $trashedAsset->getUrl('func=manageTrash'), '... trashed asset sets redirect to manageTrash';

$session->http->setRedirectLocation('');
is $clippedAsset->checkView(), 'chunked', 'checkView: returns "chunked" when admin is on for cut asset';
is $session->http->getRedirectLocation, $clippedAsset->getUrl('func=manageClipboard'), '... cut asset sets redirect to manageClipboard';

##Return an array of hashrefs.  Each hashref describes a test
##for the fixId method.

sub getFixIdTests {
    my $session = shift;
    return (
    {
        id      => '0',
        pass    => 1,
        comment => 'digit zero',
    },
    {
        id      => '1',
        pass    => 1,
        comment => 'digit one',
    },
    {
        id      => '123',
        pass    => 1,
        comment => '3 digit integer',
    },
    {
        id      => '12345678901'x2,
        pass    => 1,
        comment => '22 digit integer',
    },
    {
        id      => '12345678901'x4,
        pass    => 0,
        comment => '44 digit integer',
    },
    {
        id      => '',
        pass    => 0,
        comment => 'null string is rejected',
    },
    {
        id      => 'a',
        pass    => 0,
        comment => 'single lower case character rejected',
    },
    {
	  #            '1234567890123456789012'
        id      => 'abc123ZYX098deadbeef()',
        pass    => 0,
        comment => 'illegal characters in length 22 string rejected',
    },
    {
        id      => $session->id->generate,
        pass    => 1,
        comment => 'valid id accepted',
    },
    );
}

##Return an array of hashrefs.  Each hashref describes a test
##for the fixTitle method.  If "fixed" != undef, it should
##contain what the fixTitle method will return.

sub getFixTitleTests {
    my $session = shift;
    return ({
        title   => undef,
        fixed   => undef,
        comment => "undef returns the Asset's title",
    },
    {
        title   => '',
        fixed   => undef,
        comment => "null string returns the Asset's title",
    },
    {
        title   => 'untitled',
        fixed   => undef,
        comment => "'untitled' returns the Asset's title",
    },
    {
        title   => 'UnTiTlEd',
        fixed   => undef,
        comment => "'untitled' in any case returns the Asset's title",
    },
    {
        title   => 'Username: ^@;',
        fixed   => 'Username: &#94;@;',
        comment => "Macros are negated",
    },
    {
        title   => '<b>A bold title</b>',
        fixed   => 'A bold title',
        comment => "Markup is stripped out",
    },
    {
        title   => 'Javascript: <script>Evil code goes in here</script>',
        fixed   => 'Javascript: ',
        comment => "javascript removed",
    },
    {
        title   => 'This is a good Title',
        fixed   => 'This is a good Title',
        comment => "Good titles are passed",
    },
    {
        title   => '<b></b>',
        fixed   => '',
        comment => "If there is no title left after processing, then it is set to untitled.",
    },
    {
        title   => q|Quotes '"|,
        fixed   => q|Quotes '"|,
        comment => "Quotes are not processed.",
    },
    );
}

##Return an array of hashrefs.  Each hashref describes a test
##for the getTitle and getMenuTitle tests.  If "assetName"  != 0, they
##will return the Asset's internationalized name.

sub getTitleTests {
    my $session = shift;
    return ({
        title     => undef,
        assetName => 1,
        comment   => "getTitle: undef returns the Asset's name",
    },
    {
        title     => '',
        assetName => 1,
        comment   => "getTitle: null string returns the Asset's name",
    },
    {
        title     => 'untitled',
        assetName => 1,
        comment   => "getTitle: 'untitled' returns the Asset's name",
    },
    {
        title     => 'UnTiTlEd',
        assetName => 1,
        comment   => "getTitle: 'untitled' in any case returns the Asset's title",
    },
    {
        title     => 'This is a good Title',
        assetName => 0,
        comment   => "getTitle: Good titles are passed",
    },
    );
}
