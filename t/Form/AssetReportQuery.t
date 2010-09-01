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

use WebGUI::Test;
use WebGUI::Form;
use WebGUI::Form::AssetReportQuery;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that Radio form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;
my $node    = WebGUI::Asset->getImportNode( $session );
my $nodeId  = $node->getId;

#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
$session->request->setup_body({
    className           => "WebGUI::Asset",
    propCount           => 2,
    orderCount          => 2,
    startNode           => $nodeId,
    startNode_display   => "Import Node",
    anySelect           => "or",
    propSelect_1        => "asset.createdBy",
    opSelect_1          => "=",
    valText_1           => "3",
    orderSelect_1       => "assetData.title",
    dirSelect_1         => "desc",
    limit               => "25",    
});

my $arq   = WebGUI::Form::AssetReportQuery->new($session);

my $expected = qq|{"anySelect":"or","className":"WebGUI::Asset","isNew":"false","limit":"25","order":{"1":{"dirSelect":"desc","orderSelect":"assetData.title"}},"orderCount":2,"startNode":"$nodeId","where":{"1":{"opSelect":"=","propSelect":"asset.createdBy","valText":"3"}},"whereCount":2}|;

is($arq->getValue, $expected, 'getValue');


#my $value = $session->form->process("settings","AssetReportQuery");
