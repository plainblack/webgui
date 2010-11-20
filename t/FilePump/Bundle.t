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
use Test::Exception;
use Data::Dumper;
use URI;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

my $startTime = time();
my $wgBday = WebGUI::Test->webguiBirthday;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 65;

#----------------------------------------------------------------------------
# put your tests here

use WebGUI::FilePump::Bundle;

my $bundle = WebGUI::FilePump::Bundle->new($session);
isa_ok($bundle, 'WebGUI::FilePump::Bundle');
isa_ok($bundle, 'WebGUI::Crud');
can_ok($bundle, qw/update write getJSONCollateralDataIndex/);

is($bundle->get('lastModified'), 0, 'by default, lastModified is 0');

###################################################################
#
# addFile
#
###################################################################

cmp_deeply(
    [ $bundle->addFile() ],
    [ 0, 'Illegal type' ],
    'addFile, checking error for no type'
);

cmp_deeply(
    [ $bundle->addFile('BAD_TYPE', ) ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type of file to add'
);

cmp_deeply(
    [ $bundle->addFile('JS', ) ],
    [ 0, 'No URI' ],
    '... checking error for no uri'
);

is(
    $bundle->addFile('JS', 'http://mysite.com/script.js'),
    1,
    '... adding a JS file'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

is(
    $bundle->addFile('CSS', 'http://mysite.com/script.js'),
    1,
    '... okay to add a duplicate to another type'
);

ok($bundle->addFile('JS', 'http://mysite.com/helloworld.js'), 'added a second http uri');

cmp_deeply(
    [ $bundle->addFile('JS', 'http://mysite.com/script.js') ],
    [ 0, 'Duplicate URI' ],
    '... checking error message for duplicate URI'
);

cmp_deeply(
    [ $bundle->addFile('JS', 'file:/data/domains/mysite.com/www/uploads/XX/YY/XXYYZZ/graviticEnergyDrive.js') ],
    [ 0, q{File uri must begin with file:uploads/.. or file:extras/..} ],
    '... checking error message for file outside of uploads'
);

cmp_deeply(
    [ $bundle->addFile('JS', 'file:extras/graviticEnergyDrive.js') ],
    [ 0, q{File not found} ],
    '... checking error message for missing file'
);

cmp_deeply(
    [ $bundle->addFile('JS', 'file:extras/../../etc/log.conf') ],
    [ 0, q{Directory traversal not permitted} ],
    '... checking error message for directory traversal'
);

cmp_deeply(
    $bundle->addFile('JS', 'file:extras/hoverhelp.js'),
    1,
    'added a valid file uri'
);

my @fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/script.js
        http://mysite.com/helloworld.js
        file:extras/hoverhelp.js
    }],
    '... checking actual jsFiles data structure contents'
);

cmp_deeply(
    $bundle->addFile('OTHER', 'file:extras/adminConsole'),
    1,
    'added a valid file folder'
);

my @fileUris = map { $_->{uri} } @{ $bundle->get('otherFiles') };
cmp_deeply(
    [ @fileUris ],
    [ 'file:extras/adminConsole' ],
    '... checking actual otherFiles data structure contents'
);

###################################################################
#
# moveFile{Up,Down}
#
###################################################################

cmp_deeply(
    [ $bundle->moveFileUp() ],
    [ 0, 'Illegal type' ],
    'moveFileUp: checking error for no type'
);

cmp_deeply(
    [ $bundle->moveFileUp('BEER') ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type'
);

cmp_deeply(
    [ $bundle->moveFileUp('JS', ) ],
    [ 0, 'No fileId' ],
    '... checking error for no fileId'
);

cmp_deeply(
    [ $bundle->moveFileDown() ],
    [ 0, 'Illegal type' ],
    'moveFileDown: checking error for no type'
);

cmp_deeply(
    [ $bundle->moveFileDown('BEER') ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type'
);

cmp_deeply(
    [ $bundle->moveFileDown('JS', ) ],
    [ 0, 'No fileId' ],
    '... checking error for no fileId'
);

my @fileIds = map { $_->{fileId} } @{ $bundle->get('jsFiles') };

$bundle->update({lastModified => 0});
ok($bundle->moveFileDown('JS', $fileIds[0]), 'moveFileDown returns 1 for a successful move');
@fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/helloworld.js
        http://mysite.com/script.js
        file:extras/hoverhelp.js
    }],
    '... checking the actual order of js files'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

$bundle->update({lastModified => 0});
ok($bundle->moveFileUp('JS', $fileIds[2]), 'moveFileUp returns 1 for a successful move');
@fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/helloworld.js
        file:extras/hoverhelp.js
        http://mysite.com/script.js
    }],
    '... checking the actual order of js files'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

###################################################################
#
# deleteFile
#
###################################################################

cmp_deeply(
    [ $bundle->deleteFile() ],
    [ 0, 'Illegal type' ],
    'deleteFile: checking error for no type'
);

cmp_deeply(
    [ $bundle->deleteFile('BEER') ],
    [ 0, 'Illegal type' ],
    '... checking error for bad type'
);

cmp_deeply(
    [ $bundle->deleteFile('JS', ) ],
    [ 0, 'No fileId' ],
    '... checking error for no fileId'
);

@fileIds = map { $_->{fileId} } @{ $bundle->get('jsFiles') };
$bundle->update({lastModified => 0});
$bundle->deleteFile('JS', $fileIds[1]);
@fileUris = map { $_->{uri} } @{ $bundle->get('jsFiles') };
cmp_deeply(
    [ @fileUris ],
    [qw{
        http://mysite.com/helloworld.js
        http://mysite.com/script.js
    }],
    '... checking the actual deletion of js files'
);
cmp_ok($bundle->get('lastModified'), '>=', $startTime, '... updates lastModified');

###################################################################
#
# fetch
#
###################################################################

my $root = WebGUI::Test->asset;

my $snippet =  $root->addChild({
    className => 'WebGUI::Asset::Snippet',
    url       => 'filePumpSnippet',
    snippet   => 'Pump a Snippet',
});

my $fileAsset = $root->addChild({
    className => 'WebGUI::Asset::File',
    url       => 'filePumpFileAsset',
    filename  => 'pumpfile',
}); 

$fileAsset->getStorageLocation->addFileFromScalar('pumpfile', 'Pump up the jam');

my $storage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($storage);
$storage->addFileFromScalar('addendum', 'Red was too');
$storage->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('ShawshankRedemptionMoviePoster.jpg'));

my $guts;
$guts = $bundle->fetchAsset(URI->new('asset://filePumpSnippet'));
cmp_deeply(
    $guts,
    {
        content      => 'Pump a Snippet',
        lastModified => re('^\d+$'),
    },
    'fetchAsset: retrieved a snippet'
);

$guts = $bundle->fetchAsset(URI->new('asset://filePumpFileAsset'));
cmp_deeply(
    $guts,
    {
        content      => 'Pump up the jam',
        lastModified => re('^\d+$'),
    },
    'fetchAsset: retrieved a file asset'
);

# Turn fileAsset into file:uploads/path/to/fileAsset (bc file uris must begin with either file:uploads/ or file:extras/)
my $path = Path::Class::File->new($fileAsset->getStorageLocation->getPath($fileAsset->get('filename')));
my $uploadsDir = Path::Class::Dir->new($session->config->get('uploadsPath'));
$path = $path->relative($uploadsDir);
my $urilet = URI->new('file:uploads/'.$path);
$guts = $bundle->fetchFile($urilet);
cmp_deeply(
    $guts,
    {
        content      => 'Pump up the jam',
        lastModified => re('^\d+$'),
        type         => 'file',
    },
    'fetchFile: retrieved a file from the filesystem'
);

my $storageRelPath = 'uploads/' . Path::Class::Dir->new($storage->getPath)->relative($uploadsDir);

my $uriDir = URI->new("file:$storageRelPath");
$guts = $bundle->fetchDir($uriDir);
cmp_deeply(
    $guts,
    {
        lastModified => re('^\d+$'),
        content      => [
            isa('Path::Class::File'),
            isa('Path::Class::File'),
        ],
        type         => 'directory',
    },
    'fetchDir: retrieved information about a directory and its subfiles from the filesystem'
);

###################################################################
#
# getPathClassDir
#
###################################################################

my $dir = $bundle->getPathClassDir();
isa_ok($dir, 'Path::Class::Dir');
my $timestampDir = $dir->dir_list(-1, 1);
cmp_deeply(
    [ split /\./, $timestampDir ],
    [ 'new-bundle', 0 ],
    '... directory has correct name and timestamp'
);

$dir = $bundle->getPathClassDir($wgBday);
isa_ok($dir, 'Path::Class::Dir');
$timestampDir = $dir->dir_list(-1, 1);
cmp_deeply(
    [ split /\./, $timestampDir ],
    [ 'new-bundle', $wgBday ],
    '... directory has correct name and timestamp when timestamp is specified'
);

###################################################################
#
# deleteFiles
#
###################################################################

$bundle->deleteFiles('JS');
$bundle->deleteFiles('CSS');
$bundle->deleteFiles('OTHER');

cmp_deeply($bundle->get('jsFiles'),  [], ' deleteFiles deleted all JS URIs');
cmp_deeply($bundle->get('cssFiles'), [], ' ... deleted all CSS URIs');
cmp_deeply($bundle->get('otherFiles'), [], ' ... deleted all OTHER URIs');

###################################################################
#
# build
#
###################################################################

my $oldBuildDir = $bundle->getPathClassDir($wgBday);
$oldBuildDir->mkpath;

ok(-e $oldBuildDir->stringify && -d _, 'No problems creating old build directory');
$bundle->update({lastBuild => $wgBday});

$snippet->update({snippet => qq|\n\nfunction      doNothing()\n{ var foo = 'bar';} |});

$fileAsset->getStorageLocation->deleteFile('pumpfile');
$fileAsset->getStorageLocation->addFileFromScalar('pumpfile.css', qq|   body {\npadding:   0px;}\n\n|);
$fileAsset->update({filename => 'pumpfile.css'});

$bundle->addFile('JS',  'asset://filePumpSnippet');
$bundle->addFile('CSS', 'asset://filePumpFileAsset');
$bundle->addFile('OTHER', 'file:extras/plainblack.gif');
$bundle->addFile('OTHER', "file:$storageRelPath");
my ($buildFlag, $error) = $bundle->build();
ok($buildFlag, 'build returns true when there are no errors');
diag $error unless $buildFlag;
isnt($bundle->get('lastBuild'), $wgBday, '... lastBuild time updated');

my $buildDir = $bundle->getPathClassDir();
isnt($buildDir->stringify, $oldBuildDir->stringify, '... build directory did actually change');
ok(-e $buildDir->stringify     &&  -d _, '... new build directory created');
ok(!-e $oldBuildDir->stringify && !-d _, '... old build directory deleted');
my $jsFile    = $buildDir->file($bundle->bundleUrl . '.js');
my $cssFile   = $buildDir->file($bundle->bundleUrl . '.css');
my $otherFile = $buildDir->file('plainblack.gif');
my $otherDir  = $buildDir->subdir($storage->getHexId);
ok(-e $jsFile->stringify    && -f _ && -s _, '... minified JS file built, not empty');
ok(-e $cssFile->stringify   && -f _ && -s _, '... minified CSS file built, not empty');
ok(-e $otherFile->stringify && -f _ && -s _, '... other file copied over, not empty');
ok(-e $otherDir->stringify  && -d _ ,        '... other directory copied over');

my @sortedChildren = sort { lc $a cmp lc $b } map { $_->basename } $otherDir->children;
cmp_deeply(
    \@sortedChildren,
    [ qw/addendum ShawshankRedemptionMoviePoster.jpg/ ],
    '... File copied over to new directory'
);

ok($bundle->get('jsFiles')->[0]->{lastModified},    '... updated JS file lastModified');
ok($bundle->get('cssFiles')->[0]->{lastModified},   '... updated CSS file lastModified');
ok($bundle->get('otherFiles')->[0]->{lastModified}, '... updated OTHER file lastModified');
ok($bundle->get('otherFiles')->[1]->{lastModified}, '... updated OTHER directory lastModified');

###################################################################
#
# delete
#
###################################################################

$bundle->delete;
ok(!-e $buildDir->stringify, 'delete deletes the current build directory');

###################################################################
#
# File checks
#
###################################################################

##Test a number of files that live in WebGUI to make sure the minifiers do
##the right job.  All paths are relative to the extras directory.

my @jsFiles = qw/hoverhelp.js inputcheck.js/;

foreach my $jsFile (@jsFiles) {
    my $bundle = WebGUI::FilePump::Bundle->new($session);
    $bundle->addFile('JS', 'file:extras/'.$jsFile);
    lives_ok { $bundle->build } "built file $jsFile";
    $bundle->delete;
}
