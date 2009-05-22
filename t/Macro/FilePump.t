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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my  $tests =  6;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $macro = 'WebGUI::Macro::FilePump';
my $loaded = use_ok($macro);

my $bundle = WebGUI::FilePump::Bundle->create($session, { bundleName => 'test bundle'});

SKIP: {

skip "Unable to load $macro", $tests unless $loaded;

my $root = WebGUI::Asset->getRoot($session);

my $snippet =  $root->addChild({
    className => 'WebGUI::Asset::Snippet',
    url       => 'filePumpSnippet',
    snippet   => qq|\n\nfunction      doNothing()\n{ var foo = 'bar';} |,
});

my $fileAsset = $root->addChild({
    className => 'WebGUI::Asset::File',
    url       => 'filePumpFileAsset',
    filename  => 'pumpfile',
}); 

$fileAsset->getStorageLocation->addFileFromScalar('pumpfile.css', qq|   body {\npadding:   0px;}\n\n|);

my $snippetTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($snippetTag);
$snippetTag->commit;

$bundle->addFile('JS',  'asset://filePumpSnippet');
$bundle->addFile('CSS', 'asset://filePumpFileAsset');

my $storedFile = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($storedFile);
$storedFile->addFileFromScalar('storedJS.js', qq|function helloWorld() { alert("Hellow world");}|, );
$bundle->addFile('JS', 'file:'. $storedFile->getPath('storedJS.js'));

my $uploadsURL = $session->config->get('uploadsURL');

$bundle->build();
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'JS'),
    sprintf(qq|<script type="text/javascript" src="%s">\n|,
        join('/', $uploadsURL, 'filepump', $bundle->bundleUrl . '.'. $bundle->get('lastBuild'), $bundle->bundleUrl.'.js'),
    ),
    '... check JS file, normal mode'
);
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'CSS'),
    sprintf(qq|<link rel="stylesheet" type="text/css" href="%s">\n|,
        join('/', $uploadsURL, 'filepump', $bundle->bundleUrl . '.'. $bundle->get('lastBuild'), $bundle->bundleUrl.'.css'),
    ),
    '... check CSS file, normal mode'
);
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'OTHER'),
    '',
    '... check illegal file type access returns empty string'
);

$session->var->switchAdminOn();
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'JS'),
    sprintf(qq|<script type="text/javascript" src="%s">\n<script type="text/javascript" src="%s">\n|,
        '/filePumpSnippet', $storedFile->getUrl('storedJS.js')
    ),
    '... check JS file, normal mode'
);
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'CSS'),
    sprintf(qq|<link rel="stylesheet" type="text/css" href="/filePumpFileAsset">\n|, $fileAsset->getUrl),
    '... check CSS file, normal mode'
);
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'OTHER'),
    '',
    '... check illegal file type access returns empty string'
);


}


#----------------------------------------------------------------------------
# Cleanup
END {

$bundle->delete;

}
#vim:ft=perl
