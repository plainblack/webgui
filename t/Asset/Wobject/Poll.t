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

# Write a little about what this script tests.
# 
#

use strict;
use Test::More;
use Test::Deep;
use Data::Dumper;
use JSON;
use Path::Class;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Image::Graph;

################################################################
#
#  setup session, users and groups for this test
#
################################################################

my $session         = WebGUI::Test->session;

my $tests = 3
          ;
plan tests => 1
            + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $class  = 'WebGUI::Asset::Wobject::Poll';
my $loaded = use_ok($class);

SKIP: {

skip "Unable to load module $class", $tests unless $loaded;


my $defaultNode = WebGUI::Asset->getDefault($session);
my $template = $defaultNode->addChild({
    className => 'WebGUI::Asset::Template',
    title     => 'test poll template',
    template  => q|
{
"responses.total" : "<tmpl_var responses.total>",
"hasImageGraph"   : "<tmpl_var hasImageGraph>",
"graphUrl"        : "<tmpl_var graphUrl>"
}
|,
});

my $poll = $defaultNode->addChild({
    className     => $class,
    active        => 1,
    title         => 'test poll',
    generateGraph => 1,
    question      => "How often do you look at a man's shoes?",
    a1            => 'daily',
    a2            => 'hourly',
    a3            => 'never',
    templateId    => $template->getId,
    graphConfiguration => '{"graph_labelFontSize":"20","xyGraph_chartWidth":"200","xyGraph_drawRulers":"1","graph_labelColor":"#333333","xyGraph_drawAxis":"1","graph_formNamespace":"Graph_XYGraph_Bar","graph_backgroundColor":"#ffffff","xyGraph_bar_barSpacing":0,"graph_labelFontId":"defaultFont","graph_labelOffset":"10","xyGraph_drawMode":"sideBySide","xyGraph_yGranularity":"10","xyGraph_chartHeight":"200","graph_imageHeight":"300","graph_imageWidth":"300","xyGraph_drawLabels":"1","xyGraph_bar_groupSpacing":0,"graph_paletteId":"defaultPalette"}',
});

my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
$versionTag->commit;

isa_ok($poll, 'WebGUI::Asset::Wobject::Poll');

$poll->setVote('daily', 1, '127.0.0.1');
$poll->setVote('hourly', 1, '127.0.0.1');
$poll->setVote('never', 1, '127.0.0.1');
$poll->setVote('never', 1, '127.0.0.1');

$poll->prepareView();
my $json = $poll->view();
my $output = JSON::from_json($json);

cmp_deeply(
    $output,
    {
        'responses.total' => 4,
        hasImageGraph     => 1,
        graphUrl          => re('^\S+$'),
    },
    'poll has correct number of responses, a graph and a path to the generated file'
);

my $graphUrl = Path::Class::File->new($output->{graphUrl});
my $uploadsPath = Path::Class::Dir->new($session->config->get('uploadsPath'));
my $uploadsUrl  = Path::Class::Dir->new($session->config->get('uploadsURL'));
my $graphRelative = $graphUrl->relative($uploadsUrl);
my $graphFile     = $uploadsPath->file($graphRelative);

ok(-e $graphFile->stringify, 'graph exists');

}
