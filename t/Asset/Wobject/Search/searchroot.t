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

##The goal of this test is to test the creation of Search Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 2; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::Search;

my $session = WebGUI::Test->session;
$session->user({userId => 3});

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);


my $default = WebGUI::Asset->getDefault($session);
my $importArticle = $node->addChild({
    className     => 'WebGUI::Asset::Wobject::Article',
    description   => 'rockhound',
});
my $defaultArticle = $default->addChild({
    className     => 'WebGUI::Asset::Wobject::Article',
    description   => 'rockhound',
});
my $template = $node->addChild({
    className  => 'WebGUI::Asset::Template',
    parser    => 'WebGUI::Asset::Template::HTMLTemplate',
    template   => qq{[<tmpl_loop result_set>"<tmpl_var assetId>"<tmpl_unless __LAST__>,</tmpl_unless></tmpl_loop>]},
});
my $search = $default->addChild({
    className  => 'WebGUI::Asset::Wobject::Search',
    searchRoot => $default->getId,
    templateId => $template->getId,
});
my $tag2 = WebGUI::VersionTag->getWorking($session);
$tag2->commit;

$search->prepareView();
$session->request->setup_body({doit => 1, keywords => 'rockhound'});
my $json = $search->view();
my $assetIds = from_json($json);
cmp_deeply(
    $assetIds,
    [ $defaultArticle->getId ],
    'search with no override returns asset from default asset'
);

$session->request->setup_body({doit => 1, keywords => 'rockhound', searchroot => $node->getId,});
$json = $search->view();
$assetIds = from_json($json);
cmp_deeply(
    $assetIds,
    [ $importArticle->getId ],
    'search with override returns asset from import node'
);


$session->request->setup_body({});
$tag2->rollback;

