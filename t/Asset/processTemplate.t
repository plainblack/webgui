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

my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
$rootAsset->addRevision({keywords => 'one,two,three,four'});
$versionTag->commit;
$rootAsset = $rootAsset->cloneFromDb;

##Override the user function style template so we can examine its output easily
                 #1234567890123456789012#
my $templateId = 'USER_STYLE_OVERRIDE___';
my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = clone($_[1]); } );

{
    WebGUI::Test->mockAssetId($templateId, $templateMock);
    $rootAsset->processTemplate({}, $templateId);
    use WebGUI::Keyword;
    my $keywords = WebGUI::Keyword::string2list($templateVars->{keywords});
    cmp_bag($keywords, [qw/one two three four/],  'Keywords are available when running processTemplate');
}


