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

# Test the featured page of the Wiki
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::MockAsset;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $import          = WebGUI::Asset->getImportNode( $session );

my $templateId = 'WIKIMASTER_TEMPLATE___';

my $templateMock = WebGUI::Test::MockAsset->new('WebGUI::Asset::Template');
$templateMock->mock_id($templateId);
$templateMock->set_true('prepare');
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

my $wiki
    = $import->addChild( {
        className        => 'WebGUI::Asset::Wobject::WikiMaster',
        searchTemplateId => $templateId,
        groupIdView      => '2',
    } );

WebGUI::Test->addToCleanup($wiki);

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

$session->request->setup_body({
    query => 'Red&Andy',
});

$session->user({userId => 3});

{
    $wiki->www_search();
}

is $templateVars->{addPageUrl},
    $wiki->getUrl('func=add;className=WebGUI::Asset::WikiPage;title=Red%26Andy'),
    'search encodes unsafe characters in addPageUrl';

$session->user({userId => 1});
ok !$wiki->canView(), 'checking permission handling in www_search: visitor cannot view the wiki';

$templateVars = {};

$wiki->www_search;
is_deeply $templateVars, {}, '... no template variables set';
is $session->response->status, 401, '... HTTP status set to 401, no access';

#----------------------------------------------------------------------------
# 

#vim:ft=perl
