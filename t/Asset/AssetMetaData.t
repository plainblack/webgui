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

##The goal of this test is to check the creation and purging of
##versions.

use WebGUI::Test;
use WebGUI::Test::Metadata;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Asset;
use WebGUI::VersionTag;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 17;

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $root = WebGUI::Asset->getRoot($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Asset Package test"});
WebGUI::Test->addToCleanup($versionTag);

####################################################
#
# Setup Assets for testing
#
####################################################

my $folder = $root->addChild({
    url   => 'testFolder',
    title => 'folder',
    menuTitle => 'folderMenuTitle',
    className => 'WebGUI::Asset::Wobject::Folder',
    isPackage => 1,
});

my $snippet = $folder->addChild({
    url => 'testSnippet',
    title => 'snippet',
    menuTitle => 'snippetMenuTitle',
    className => 'WebGUI::Asset::Snippet',
    snippet   => 'A snippet of text',
});

$versionTag->commit;

WebGUI::Test->addToCleanup(sub {
    foreach my $metaDataFieldId (keys %{ $snippet->getMetaDataFields }) {
        $snippet->deleteMetaDataField($metaDataFieldId);
    }
});

##Note that there is no MetaData field master class.  New fields can be added
##from _ANY_ asset, and be available to all assets.

####################################################
#
# getMetaDataFields
#
####################################################

cmp_deeply({}, $snippet->getMetaDataFields, 'snippet has no metadata fields');
cmp_deeply({}, $folder->getMetaDataFields,  'folder has no metadata fields');

subtest 'Field with class data' => sub {
    my $meta = WebGUI::Test::Metadata->new(
        $folder, {
            classes => ['WebGUI::Asset::Wobject::Folder']
        }
    );
    my $id = $meta->fieldId;
    my $snips = $snippet->getMetaDataFields;
    my $folds = $folder->getMetaDataFields;
    ok !exists $snips->{$id}, 'snippet does not have field';
    ok exists $folds->{$id}, 'but folder does';
    $snips = $snippet->getAllMetaDataFields;
    ok exists $snips->{$id}, 'snips returns data with getAll';
};

$snippet->addMetaDataField('new', 'searchEngine', '', 'Search Engine preference', 'text');

my @snipKeys;
my @foldKeys;

@snipKeys = keys %{ $snippet->getMetaDataFields };
@foldKeys = keys %{ $folder->getMetaDataFields };
is(scalar @snipKeys, 1, 'Only 1 meta data field available');
cmp_deeply( \@snipKeys, \@foldKeys, 'Snippet and Folder have access to the same meta data');

my $seMetaData = $snippet->getMetaDataFields()->{$snipKeys[0]};

cmp_deeply(
    $seMetaData,
    {
        fieldName      => 'searchEngine',
        fieldType      => 'text',
        description    => 'Search Engine preference',
        fieldId        => $snipKeys[0],
        defaultValue   => ignore(),
        possibleValues => ignore(),
        value          => ignore(),
    },
    'Meta data field, searchEngine, set correctly'
);

##Add a second field, this time to the folder.
$folder->addMetaDataField('new', 'color', '', 'Favorite Color', 'radioList', "Blue\nRed\nWhite\nYellow\nGreen");

@snipKeys = keys %{ $snippet->getMetaDataFields };
@foldKeys = keys %{ $folder->getMetaDataFields };
is(scalar @foldKeys, 2, 'Two meta data fields available');
cmp_deeply( \@snipKeys, \@foldKeys, 'Snippet and Folder have access to the same meta data fields');

my $foMetaData;
my $byName;
$foMetaData = $folder->getMetaDataFields;
$byName = buildNameIndex($foMetaData);

cmp_deeply(
    $foMetaData->{ $byName->{'color'} },
    {
        fieldName      => 'color',
        fieldType      => 'radioList',
        description    => 'Favorite Color',
        fieldId        => $byName->{'color'},
        defaultValue   => ignore(),
        possibleValues => "Blue\nRed\nWhite\nYellow\nGreen",
        value          => ignore(),
    },
    'Meta data field, color, set correctly'
);

##Add a third field
$folder->addMetaDataField('new', 'sport', '', 'Favorite Sport', 'radioList', "Running\nBiking\nHacking\nWriting Tests");

$foMetaData = $folder->getMetaDataFields;
$byName = buildNameIndex($foMetaData);

my $sportField = $folder->getMetaDataFields($byName->{'sport'});

cmp_deeply(
    $sportField,
    {
        fieldName      => 'sport',
        fieldType      => 'radioList',
        description    => 'Favorite Sport',
        fieldId        => $byName->{'sport'},
        defaultValue   => ignore(),
        possibleValues => "Running\nBiking\nHacking\nWriting Tests",
        value          => ignore(),
    },
    'Fetching just one metadata field, by fieldId, works'
);

####################################################
#
# deleteMetaDataField
#
####################################################

$folder->deleteMetaDataField($byName->{'color'});
$foMetaData = $folder->getMetaDataFields;
$byName = buildNameIndex($foMetaData);
cmp_bag( [keys %{ $byName}], ['sport', 'searchEngine'], 'color meta data field removed');

####################################################
#
# updateMetaData
#
####################################################

$folder->updateMetaData( $byName->{'sport'}, 'underwaterHockey');

cmp_deeply(
    $folder->getMetaDataFields( $byName->{'sport'} ),
    {
        fieldName      => 'sport',
        fieldType      => 'radioList',
        description    => 'Favorite Sport',
        fieldId        => $byName->{'sport'},
        defaultValue   => ignore(),
        possibleValues => "Running\nBiking\nHacking\nWriting Tests",
        value          => 'underwaterHockey',
    },
    'Folder has a value field for sports'
);

cmp_deeply(
    $snippet->getMetaDataFields( $byName->{'sport'} ),
    {
        fieldName      => 'sport',
        fieldType      => 'radioList',
        description    => 'Favorite Sport',
        fieldId        => $byName->{'sport'},
        defaultValue   => ignore(),
        possibleValues => "Running\nBiking\nHacking\nWriting Tests",
        value          => ignore(),
    },
    'Snippet does not have a value, yet'
);

####################################################
#
# getMetaDataAsTemplateVariables
#
####################################################

$session->setting->set("metaDataEnabled", 1);

# add another field for comparison
$folder->addMetaDataField('new', 'book', '', 'Favorite book', 'radioList', "1984\nDune\nLord of the Rings\nFoundation Trilogy");

# set it; need to update $foMetaData and $byName.
$foMetaData = $folder->getMetaDataFields;
$byName = buildNameIndex($foMetaData);
$folder->updateMetaData( $byName->{'book'}, '1984' );

# check that they're equal
cmp_deeply(
    $folder->getMetaDataAsTemplateVariables,
    {
        'book'              => '1984',
        'sport'             => 'underwaterHockey',
        'searchEngine'      => undef,
    },
    'getMetaDataAsTemplateVariables returns proper values for folder'
);

{
    my $asset = $root->addChild(
        {
            className => 'WebGUI::Asset::Snippet',
        }
    );
    WebGUI::Test->addToCleanup($asset);
    my $meta = WebGUI::Test::Metadata->new($asset);
    my $ff = $asset->getMetaDataAsFormFields;
    like $ff->{$meta->fieldName}, qr/input/, 'getMetaDataAsFormFields';
}

# check that asset metadata versioning works properly
subtest 'asset metadata versioning' => sub {
    my $asset = WebGUI::Asset->getImportNode($session)->addChild(
        {
            className => 'WebGUI::Asset::Snippet',
        }
    );
    WebGUI::Test->addToCleanup($asset);
    my $meta = WebGUI::Test::Metadata->new($asset);
    $meta->update('version one');
    sleep 1;
    my $rev2 = $asset->addRevision();
    is $meta->get(), 'version one', 'v1 for 1';
    is $meta->get($rev2), 'version one', 'v1 for 2';
    $meta->update('version two', $rev2);
    is $meta->get($rev2), 'version two', 'v2 has been set';
    is $meta->get(), 'version one', 'v1 has not been changed';

    my $dup = $asset->duplicate;
    WebGUI::Test->addToCleanup($dup);

    my $db    = $session->db;
    my $count_rev = sub {
        my $a = shift;
        my $sql = q{
            select count(*)
            from metaData_values
            where assetId = ? and revisionDate = ?
        };
        $db->quickScalar( $sql, [ $a->getId, $a->get('revisionDate') ] );
    };
    my $count_all = sub {
        my $a = shift;
        my $sql = 'select count(*) from metaData_values where assetId = ?';
        $db->quickScalar( $sql, [ $a->getId ] );
    };

    is $count_all->($asset), 2, 'two values for original';
    is $count_all->($dup), 1, 'one value for dup';

    is $count_rev->($asset), 1, 'one value for v1';
    is $count_rev->($rev2), 1, 'one value for v2';

    $rev2->purgeRevision;

    note 'after purge';

    is $count_rev->($asset), 1, 'one value for v1';
    is $count_rev->($rev2), 0, 'no value for v2';

    is $count_all->($asset), 1, 'one value for original';
    is $count_all->($dup), 1, 'one value for dup';
};

# Check that www_editMetaDataField doesn't return assets that are not configured
# for this site and that sub definition is not executed if the asset is not 
# configured in the config, which may cause a fatal error. 

# Temporarily remove asset Article from config
$session->config->deleteFromHash( 'assets', 'WebGUI::Asset::Wobject::Article' );
unlike( 
    my  $got = $root->www_editMetaDataField(),
    qr/WebGUI::Asset::Wobject::Article/,
    'article was (temporarily) not in config and should not appear in form'
);
# Restore config:
$session->config->addToHash( 'assets', 'WebGUI::Asset::Wobject::Article' );


sub buildNameIndex {
    my ($fidStruct) = @_;
    my $nameStruct;
    foreach my $field ( values %{ $fidStruct } ) {
        $nameStruct->{ $field->{fieldName} } = $field->{fieldId};
    }
    return $nameStruct;
}

#vim:ft=perl
