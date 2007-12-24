#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use WebGUI::AssetVersioning;
use WebGUI::VersionTag;

use Test::More;
use Test::MockObject;

my $session = WebGUI::Test->session;

my @fixIdTests    = getFixIdTests($session);
my @fixTitleTests = getFixTitleTests($session);

my $rootAsset = WebGUI::Asset->getRoot($session);

my %testUsers = ();
##Just a regular user
$testUsers{'regular user'} = WebGUI::User->new($session, 'new');
##Users in group 12 can add Assets
$testUsers{'canAdd turnOnAdmin'} = WebGUI::User->new($session, 'new');
$testUsers{'canAdd turnOnAdmin'}->addToGroups(['12']);

my $canAddMaker = WebGUI::Test::Maker::Permission->new();
$canAddMaker->prepare({
    'className' => 'WebGUI::Asset',
    'session'   => $session,
    'method'    => 'canAdd',
    'pass'      => [3, $testUsers{'canAdd turnOnAdmin'}, ],
    'fail'      => [1, $testUsers{'regular user'}, ],
});

my $properties;
$properties = {
	#            '1234567890123456789012'
	id        => 'canEditAsset0000000010',
	title     => 'canEdit Asset Test',
	url       => 'canEditAsset1',
	className => 'WebGUI::Asset',
};

my $versionTag2 = WebGUI::VersionTag->getWorking($session);

my $canEditAsset = $rootAsset->addChild($properties, $properties->{id});

$versionTag2->commit;
$properties = {};  ##Clear out the hash so that it doesn't leak later by accident.

my $canEditMaker = WebGUI::Test::Maker::Permission->new();
$canEditMaker->prepare({
    'object' => $canEditAsset,
    'method' => 'canEdit',
    'pass'   => [3, ],
    'fail'   => [1, $testUsers{'regular user'}, ],
});

plan tests => 56
            + scalar(@fixIdTests)
            + scalar(@fixTitleTests)
            + $canAddMaker->plan
            + $canEditMaker->plan
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
{
    my $confession = '';
    local $SIG{__DIE__} = sub { $confession = $_[0]; };
    eval { WebGUI::Asset->newByDynamicClass($session); };
    like($confession, qr/newByDynamicClass requires assetId/, 'newByDynamicClass constructor with no assetId confesses and dies');
}

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

$versionTag->commit;


my $origUrlExtension = $session->setting->get('urlExtension');
$session->setting->set('urlExtension', undef);

is($importNode->fixUrl('1234'.'-'x235 . 'abcdefghij'), '1234'.'-'x235 . 'abcdefghij', 'fixUrl leaves long URLs under 250 characters alone');
is($importNode->fixUrl('1234'.'-'x250 . 'abcdefghij'), '1234'.'-'x216, 'fixUrl truncates long URLs over 250 characters to 220 characters');

my $origExtras   = $session->config->get('extrasURL');
my $origUploads  = $session->config->get('uploadsURL');
my $origPassthru = $session->config->get('passthruUrls');

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

##Now, check duplicate URLs

is($importNode->fixUrl('/rootyRootRoot'), 'rootyrootroot', 'URLs are lowercased');
is($importNode->fixUrl('/root'), 'root2', 'If a node exists, appends a "2" to it');
my $importNodeURL = $importNode->getUrl;
$importNodeURL =~ s{ ^ / }{}x;
is($importNode->fixUrl($importNodeURL), $importNodeURL, q{fixing an asset's own URL returns it unchanged});

is($importNode->fixUrl('fixUrlFolderURL2'),   'fixurlfolderurl3',   'if a URL exists, fix it by incrementing any ending digits 2 -> 3');
is($importNode->fixUrl('fixUrlFolderURL9'),   'fixurlfolderurl10',  'increments past single digits 9 -> 10');
is($importNode->fixUrl('fixUrlFolderURL00'),  'fixurlfolderurl01',  'initial zeroes preserved 00 -> 01');
is($importNode->fixUrl('fixUrlFolderURL100'), 'fixurlfolderurl101', '100->101');

is($fixUrlAsset5->fixUrl(), 'home/fix-url-folder-url-autogenerated', 'fixUrl will autogenerate a url if not provided one');

TODO: {
    local $TODO = "Test the automatic adding of extensions to URLs";
    $session->setting->set('urlExtension', 'html');
    ok(0, "Setup test for adding URL extensions");

    $session->setting->set('urlExtension', $origUrlExtension);
}

$session->config->set('extrasURL', $origExtras);

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
    my $expectedTitle = $test->{fixed} || $importNodeTitle;
    is($fixedTitle, $expectedTitle, $test->{comment});
}

$fixTitleAsset->update({'title' => 0});

is($fixTitleAsset->fixTitle(''), 'Untitled', q{fixTitle: title is false, fixTitle returns 'Untitled'});

################################################################
#
# getIcon
#
################################################################

like($importNode->getIcon,    qr{folder.gif$},       'getIcon gets correct icon for importNode');
like($importNode->getIcon(1), qr{small/folder.gif$}, 'getIcon gets small icon for importNode');

like($importNode->getIcon(),  qr{$origExtras}, 'getIcon returns an icon from the extras URL');

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

$canAddMaker->run;

################################################################
#
# canEdit
#
################################################################

$canEditMaker->run;

END: {
    $session->config->set('extrasURL',    $origExtras);
    $session->config->set('uploadsURL',   $origUploads);
    $session->setting->set('urlExtension', $origUrlExtension);
    foreach my $vTag ($versionTag, $versionTag2) {
        $vTag->rollback;
    }
    foreach my $user (values %testUsers) {
        $user->delete;
    }
}

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
##for the fixTitle method.  If "fixed" != 0, it should
##contain what the fixTitle method will return.

sub getFixTitleTests {
    my $session = shift;
    return ({
        title   => undef,
        fixed   => 0,
        comment => "undef returns the Asset's title",
    },
    {
        title   => '',
        fixed    => 0,
        comment => "null string returns the Asset's title",
    },
    {
        title   => 'untitled',
        fixed    => 0,
        comment => "'untitled' returns the Asset's title",
    },
    {
        title   => 'UnTiTlEd',
        fixed    => 0,
        comment => "'untitled' in any case returns the Asset's title",
    },
    {
        title   => 'Username: ^@;',
        fixed    => 'Username: &#94;@;',
        comment => "Macros are negated",
    },
    {
        title   => '<b>A bold title</b>',
        fixed    => 'A bold title',
        comment => "Markup is stripped out",
    },
    {
        title   => 'Javascript: <script>Evil code goes in here</script>',
        fixed    => 'Javascript: ',
        comment => "javascript removed",
    },
    {
        title   => 'This is a good Title',
        fixed    => 'This is a good Title',
        comment => "Good titles are passed",
    },
    );
}
