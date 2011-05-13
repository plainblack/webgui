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
use JSON qw/from_json/;
use lib "$FindBin::Bin/../../../lib";

##The goal of this test is to test the searching for and returning data about
##records created with WebGUI::Search::Index::addRecord;

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 6; # increment this value for each test you create
use Test::Deep;
use WebGUI::Test::MockAsset;
use WebGUI::Asset::Wobject::Search;

my $session = WebGUI::Test->session;
$session->user({userId => 3});

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);


my $default = WebGUI::Test->asset;
my $importArticle = WebGUI::Test->asset->addChild({
    className     => 'WebGUI::Asset::Wobject::Article',
    description   => 'rockhound',
});

my $templateId = 'SEARCH_ASSET_TEMPLATE_';
my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
$templateMock->set_always('prepare', 1);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

my $defaultArticle = $default->addChild({
    className     => 'WebGUI::Asset::Wobject::Article',
    description   => 'shawshank prison',
    url           => 'introduction'
});
$defaultArticle->indexContent;
my $search = $default->addChild({
    className  => 'WebGUI::Asset::Wobject::Search',
    searchRoot => $default->getId,
    templateId => $templateId,
});
$search->indexContent;
my $indexer = WebGUI::Search::Index->new($defaultArticle);
$indexer->addRecord(url => 'brochure', keywords => 'roomy spacious prison');

{
    WebGUI::Test::MockAsset->mock_id($templateId, $templateMock);
    $search->prepareView();
    $session->request->setup_body({doit => 1, keywords => 'shawshank'});
    $search->view();
    WebGUI::Test::MockAsset->unmock_id($templateId);
}

is scalar @{ $templateVars->{result_set} }, 1, 'search for shawshank, returns 1 record';
is $templateVars->{result_set}->[0]->{url}, 'introduction', '... url is correct';

{
    WebGUI::Test::MockAsset->mock_id($templateId, $templateMock);
    $search->prepareView();
    $session->request->setup_body({doit => 1, keywords => 'prison'});
    $search->view();
    WebGUI::Test::MockAsset->unmock_id($templateId);
}

is scalar @{ $templateVars->{result_set} }, 2, 'search for prison, returns 2 records';
cmp_bag(
    [ map { $_->{url} } @{ $templateVars->{result_set} } ],
    [qw/ introduction brochure/ ],
    '... urls are correct'
);
cmp_bag(
    [ map { $_->{groupIdView} } @{ $templateVars->{result_set} } ],
    [ 7, 7 ],
    ' groupIdViews are correct (2nd record inherits from the parent)'
);
cmp_bag(
    [ map { $_->{title_nohighlight} } @{ $templateVars->{result_set} } ],
    [ ($defaultArticle->get('title'))x2 ],
    ' titles are correct (2nd record inherits from the parent)'
);

