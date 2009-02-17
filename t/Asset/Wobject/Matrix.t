#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use File::Spec;
use lib "$FindBin::Bin/../../lib";

##The goal of this test is to test the creation of UserList Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 12; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Matrix;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Matrix Test"});
my $matrix = $node->addChild({className=>'WebGUI::Asset::Wobject::Matrix'});

# Test for a sane object type
isa_ok($matrix, 'WebGUI::Asset::Wobject::Matrix');

# Test to see if we can set new values
my $newMatrixSettings = {
	maxComparisons                  => 20,
	defaultSort                     => 'assetRank',
	compareColorNo                  => '#aaffaa',
	submissionApprovalWorkflowId    => 'pbworkflow000000000005',
    categories                      => "category1\ncategory2",
};
$matrix->update($newMatrixSettings);

foreach my $newSetting (keys %{$newMatrixSettings}) {
    unless ($newSetting eq 'categories'){
    	is ($matrix->get($newSetting), $newMatrixSettings->{$newSetting}, "updated $newSetting is ".$newMatrixSettings->{$newSetting});
    }
}

cmp_deeply (
    $matrix->getCategories,
    {
        category1=>'category1',
        category2=>'category2'
    },
    'getCategories method returned correct hashref'
    );


# add a new attribute

$session->user({userId => 3});

my $attributeProperties = {
    name        =>'test attribute',
    description =>'description of the test attribute',
    category    =>'category1',
    };

my $newAttributeId = $matrix->editAttributeSave($attributeProperties);

my $newAttribute = $matrix->getAttribute($newAttributeId);

my $isValidId = $session->id->valid($newAttributeId);

is($isValidId,1,"editAttributeSave returnes a valid guid");

is($newAttribute->{name},'test attribute',"Adding a new attribute, attribute name was set correctly");
is($newAttribute->{fieldType},'MatrixCompare',"Adding a new attribute, undefined fieldType was set correctly to
default value");

# delete new attribute

$matrix->deleteAttribute($newAttributeId);

my $newAttribute = $matrix->getAttribute($newAttributeId);

is($newAttribute->{attributeId},undef,"The new attribute was successfully deleted.");

# TODO: test deleting of listing data for attribute

# add a listing

my $matrixListing = $matrix->addChild({className=>'WebGUI::Asset::MatrixListing'});

my $secondVersionTag = WebGUI::VersionTag->new($session,$matrixListing->get("tagId"));
$secondVersionTag->commit;

# Test for sane object type
isa_ok($matrixListing, 'WebGUI::Asset::MatrixListing');

# Test getting compareFormData including the newly added listing

$session->user({userId => 3});
my $json = $matrix->www_getCompareFormData('score');

my $compareFormData = JSON->new->decode($json);

my $expectedAssetId = $matrixListing->getId;
$expectedAssetId =~ s/-/_____/g;

cmp_deeply(
        $compareFormData,
        {ResultSet=>{
            Result=>[{
                    views=>"0",
                    lastUpdated=>$matrixListing->get('revisionDate'),
                    clicks=>"0",
                    compares=>"0",
                    assetId=>$matrixListing->getId,
                    url=>'/'.$matrixListing->get('url'),
                    title=>$matrixListing->get('title')
                    }]
            }
        },
        'Getting compareFormData as JSON: www_getCompareFormData returns correct data as JSON.'
    );        

END {
	# Clean up after thy self
	$versionTag->rollback();
    $secondVersionTag->rollback();
}

