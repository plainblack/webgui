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

my $rootAsset = WebGUI::Asset->getRoot($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
my $snippet = $rootAsset->addChild({keywords => 'one,two,three,four', className=>'WebGUI::Asset::Snippet'});
$versionTag->commit;
$snippet = $snippet->cloneFromDb;

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
    $snippet->processTemplate({}, $templateId);
    use WebGUI::Keyword;
    my $keywords = WebGUI::Keyword::string2list($templateVars->{keywords});
    cmp_bag($keywords, [qw/one two three four/],  'Keywords are available when running processTemplate');
}


