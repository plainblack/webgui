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
use WebGUI::Test::MockAsset;
use WebGUI::Session;
use WebGUI::Asset;

use Test::More;
use Test::Deep;
use Clone qw/clone/;

plan tests => 1;

my $session = WebGUI::Test->session;

##Set the maximum assets to 5
WebGUI::Test->originalConfig('maximumAssets');
$session->config->set('maximumAssets', 5);

my $rootAsset = WebGUI::Asset->getRoot($session);

##Override the user function style template so we can examine its output easily
                 #1234567890123456789012#
my $templateId = 'USER_STYLE_OVERRIDE___';
my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = clone($_[1]); } );
$session->setting->set('userFunctionStyleId', $templateId);

##Have to have a user who can add assets to the root node
$session->user({userId => 3});
$session->request->method('POST');
$session->request->setup_body({
    webguiCsrfToken => $session->scratch->get('webguiCsrfToken'),
    assetId         => 'new',
});
{
    WebGUI::Test::MockAsset->mock_id($templateId, $templateMock);
    $rootAsset->www_addSave;
    like $templateVars->{'body.content'}, qr/limited the number of assets/, 'tripped maximumAssets';
    my $count = $session->db->quickScalar('select count(*) from asset');
}


