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
use WebGUI::Macro::FilePump;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 11;

#----------------------------------------------------------------------------
# put your tests here

my $bundle = WebGUI::FilePump::Bundle->create($session, { bundleName => 'test bundle'});

my $root = WebGUI::Asset->getRoot($session);

my $snippet =  $root->addChild({
    className => 'WebGUI::Asset::Snippet',
    url       => 'filePumpSnippet',
    snippet   => qq|\n\nfunction      doNothing()\n{ var foo = 'bar';} |,
});

my $fileAsset = $root->addChild({
    className => 'WebGUI::Asset::File',
    url       => 'filePumpFileAsset',
    filename  => 'pumpfile.css',
}); 

$fileAsset->getStorageLocation->addFileFromScalar('pumpfile.css', qq|   body {\npadding:   0px;}\n\n|);
is($fileAsset->getStorageLocation->getFileContentsAsScalar($fileAsset->get('filename')), qq|   body {\npadding:   0px;}\n\n|, 'Sanity check - got back expected file contents');

my $snippetTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($snippetTag);
$snippetTag->commit;

ok($bundle->addFile('JS',  'asset://filePumpSnippet'), 'Added filePumpSnippet');
ok($bundle->addFile('CSS', 'asset://filePumpFileAsset'), 'Added filePumpAsset');

my $storedFile = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($storedFile);
$storedFile->addFileFromScalar('storedJS.js', qq|function helloWorld() { alert("Hellow world");}|, );
# Turn into file:uploads/path/to/fileAsset (bc file uris must begin with either file:uploads/ or file:extras/)
my $path = Path::Class::File->new($storedFile->getPath($storedFile->get('filename')));
my $uploadsDir = Path::Class::Dir->new($session->config->get('uploadsPath'));
$path = $path->relative($uploadsDir);
ok($bundle->addFile('JS', "file:uploads/$path/storedJS.js"), 'Added storedJS.js');

my $uploadsURL = $session->config->get('uploadsURL');

my ($code, $error) = $bundle->build;
ok($code, '... bundle built ok') or diag("Failed to fetch URI: $error");

is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'JS'),
    sprintf(qq|<script type="text/javascript" src="%s" ></script>\n|,
        join('/', $uploadsURL, 'filepump', $bundle->bundleUrl . '.'. $bundle->get('lastBuild'), $bundle->bundleUrl.'.js'),
    ),
    '... check JS file, normal mode'
);
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'CSS'),
    sprintf(qq|<link rel="stylesheet" type="text/css" href="%s"  />\n|,
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
    sprintf(qq|<script type="text/javascript" src="%s" ></script>\n<script type="text/javascript" src="%s" ></script>\n|,
        '/filePumpSnippet', $storedFile->getUrl('storedJS.js')
    ),
    '... check JS file, normal mode'
);
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'CSS'),
    sprintf(qq|<link rel="stylesheet" type="text/css" href="/filePumpFileAsset"  />\n|, $fileAsset->getUrl),
    '... check CSS file, normal mode'
);
is(
    WebGUI::Macro::FilePump::process($session, 'test bundle', 'OTHER'),
    '',
    '... check illegal file type access returns empty string'
);


#vim:ft=perl
