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

#  These tests are for the shiny rewritten export functionality. it tries
#  really hard to test every permutation of the code.

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::PseudoRequest;

use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Exception;

use Cwd;
use Exception::Class;
use File::Path;
use File::Temp qw/tempfile tempdir/;
use Path::Class;
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session             = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

WebGUI::Test->originalConfig('exportPath');

my $testRan = 1;

plan tests => 126;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# exportCheckPath()


my $e;

# ensure exportCheckPath barfs if not given a session as its first argument.
eval { WebGUI::Asset->exportCheckPath() };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidObject', 'exportCheckPath tests that its argument is a WebGUI::Session');
cmp_deeply(
    $e,
    methods(
        error       => 'first param to exportCheckPath as a class method must be a WebGUI::Session',
    ),
    "exportCheckPath tests that its argument is a WebGUI::Session"
);

# need to test that exportCheckPath() barfs on an undefined exportPath. To do
# this, we need to make sure that exportPath is undefined. However, completely
# wiping out someone's exportPath setting isn't precisely the paragon of
# politeness. Take a backup of the current exportPath before undefining it.

my $config = $session->config;
$config->delete('exportPath');

eval { WebGUI::Asset->exportCheckPath($session) };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error', "exportCheckPath throws if exportPath isn't defined");
cmp_deeply(
    $e,
    methods(
        error       => 'exportPath must be defined and not ""',
    ),
    "exportCheckPath throws if exportPath isn't defined"
);

# set the exportPath to a non-directory file and make sure that it explodes.
my $exportPathFile;
(undef, $exportPathFile)          = tempfile('webguiXXXXX', UNLINK => 1, TMPDIR => 1);
$config->set('exportPath', $exportPathFile); 

eval { WebGUI::Asset->exportCheckPath($session) };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error', "exportCheckPath throws if exportPath is a file rather than a directory");
cmp_deeply(
    $e,
    methods(
        error       => "$exportPathFile isn't a directory",
    ),
    "exportCheckPath throws if exportPath is a file rather than a directory"
);

# next, let's find a directory to which we can write, but change it so that we
# *can't* write to it. exportCheckPath will try to create the exportPath if it's
# a subdirectory of a path that exists, so let's make sure this exception works.

my $tempDirectory           = tempdir('webguiXXXXX', CLEANUP => 1, TMPDIR => 1);
my $inaccessibleDirectory   = Path::Class::Dir->new($tempDirectory, 'unwritable');

SKIP: {
    skip 'Root will cause this test to fail since it does not obey file permissions', 4
        if $< == 0;
    chmod 0000, $tempDirectory; 
    $config->set('exportPath', $inaccessibleDirectory->stringify); 

    eval { WebGUI::Asset->exportCheckPath($session) };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error', "exportCheckPath throws if it can't create the directory it needs");
    cmp_deeply(
        $e,
        methods(
            error       => "can't create exportPath $inaccessibleDirectory",
        ),
        "exportCheckPath throws if it can't create the directory it needs"
    );

    chmod 0444, $tempDirectory; 
    $config->set('exportPath', $tempDirectory); 
    eval { WebGUI::Asset->exportCheckPath($session) };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error', "exportCheckPath throws if it can't access the exportPath for writing");
    cmp_deeply(
        $e,
        methods(
            error       => "can't access $tempDirectory",
        ),
        "exportCheckPath throws if we can't access the exportPath"
    );
}

# we're finished making sure that the code explodes on bad stuff, so let's make
# sure that it really works when it's really supposed to.
my $returnCode;

# first, let's try the simplest route: a directory that we know exists, that we
# know we can write to. we already have a directory we know we can write to
# (created above as a temporary directory), so let's change its permissions back
# to something sane and then test to make sure it works.

chmod 0755, $tempDirectory; # $inaccessibleDirectory is now accessible
my $accessibleDirectory = $inaccessibleDirectory;
$config->set('exportPath', $tempDirectory); 


eval { $returnCode = WebGUI::Asset->exportCheckPath($session) };
is($@, '', "exportCheckPath with valid path lives");
ok($returnCode, "exportCheckPath returns true value");

# now, let's try a directory to which we know we have access, but a path within
# it that doesn't exist.

$config->set('exportPath', $accessibleDirectory->stringify); # now accessible!

eval { $returnCode = WebGUI::Asset->exportCheckPath($session) };
is($@, '', "exportCheckPath creating subdirectory lives");
ok($returnCode, "exportCheckPath creating subdirectory returns true value");
is(-d $accessibleDirectory, 1, "exportCheckPath creating subdirectory actually creates said subdirectory");

#----------------------------------------------------------------------------
# exportCheckExportable()

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Asset Export Test"});
addToCleanup($versionTag);

my $importNode = WebGUI::Asset->getImportNode($session);

my $parent = $importNode->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    styleTemplateId => 'PBtmpl0000000000000132',
    url => 'parent',
});
my $firstChild = $parent->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    styleTemplateId => 'PBtmpl0000000000000132',
    url => 'first_child',
});
my $grandChild = $firstChild->addChild({
    className => 'WebGUI::Asset::Wobject::Article',
    styleTemplateId => 'PBtmpl0000000000000132',
    url => 'first_child/grand_child',
});
$versionTag->commit;

foreach my $asset ($parent, $firstChild, $grandChild) {
    $asset = $asset->cloneFromDb;
}


my $isExportable;
# simple test first. the asset we're checking isn't exportable. should of course return 0.
$parent->update({ isExportable => 0 });
$isExportable = $parent->exportCheckExportable;
is($isExportable, 0, "exportCheckExportable simple check without lineage for non-exportable asset returns 0");

# next, make the parent exportable, but the child not exportable. test that this returns 0 as well.
$parent->update({ isExportable => 1 });
$firstChild->update({ isExportable => 0 });
$isExportable = $firstChild->exportCheckExportable;
is($isExportable, 0, "exportCheckExportable nonexportable asset, exportable parent returns 0");

# next, make both non-exportable. test that this returns 0.
$parent->update({ isExportable => 0 });
$isExportable = $firstChild->exportCheckExportable;
is($isExportable, 0, "exportCheckExportable nonexportable asset, nonexportable parent returns 0");

# go another level deeper. asset, parent, grandparent.
# make it not exportable, but both parents are. still returning 0.
$grandChild->update({ isExportable => 0 });
$parent->update({ isExportable => 1 });
$firstChild->update({ isExportable => 1 });
$isExportable = $grandChild->exportCheckExportable;
is($isExportable, 0, "exportCheckExportable nonexportable asset, exportable parent and grandparent returns 0");

# make parent not exportable. still returning 0.
$firstChild->update({ isExportable => 0 });
$isExportable = $grandChild->exportCheckExportable;
is($isExportable, 0, "exportCheckExportable nonexportable asset, parent, exportable grandparent returns 0");

# switch: exportable parent, nonexportable grandparent. still 0.
$firstChild->update({ isExportable => 1 });
$parent->update({ isExportable => 0 });
$isExportable = $grandChild->exportCheckExportable;
is($isExportable, 0, "exportCheckExportable nonexportable asset, grandparent, exportable parent returns 0");

# none of asset, parent, grandparent are exportable. still 0.
$parent->update({ isExportable => 0 });
$firstChild->update({ isExportable => 0 });
$isExportable = $grandChild->exportCheckExportable;
is($isExportable, 0, "exportCheckExportable nonexportable asset, grandparent, parent returns 0");

# finally, make everything exportable. make sure each one returns 1.
$parent->update({ isExportable => 1 });
$firstChild->update({ isExportable => 1 });
$grandChild->update({ isExportable => 1 });

$isExportable = $parent->exportCheckExportable;
is($isExportable, 1, "exportCheckExportable simple check without lineage for exportable asset returns 1");

$isExportable = $firstChild->exportCheckExportable;
is($isExportable, 1, "exportCheckExportable exportable asset, parent returns 1");

$isExportable = $grandChild->exportCheckExportable;
is($isExportable, 1, "exportCheckExportable exportable asset, parent, grandparent returns 1");

#----------------------------------------------------------------------------
# exportGetUrlAsPath()

# store the exportPath for future reference
my $exportPath = $config->get('exportPath');

my $litmus;
# start with something simple: export the root URL.
my $parentAsPath = $parent->exportGetUrlAsPath('index.html');
$litmus = Path::Class::File->new($exportPath, $parent->getUrl, 'index.html');
isa_ok($parentAsPath, 'Path::Class::File', 'exportGetUrlAsPath returns a Path::Class::File object');
is($parentAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, "exportGetUrlAsPath works for root directory");

# make sure that 'index.html' is the default file name if none given.
$parentAsPath = $parent->exportGetUrlAsPath();
$litmus = Path::Class::File->new($exportPath, $parent->getUrl, 'index.html');
isa_ok($parentAsPath, 'Path::Class::File', 'exportGetUrlAsPath without index file returns a Path::Class::File object');
is($parentAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, "exportGetUrlAsPath without index file works for root directory");

# let's go down a level. add a directory.
my $fcAsPath = $firstChild->exportGetUrlAsPath('index.html');
$litmus = Path::Class::File->new($exportPath, $firstChild->getUrl, 'index.html');
isa_ok($fcAsPath, 'Path::Class::File', 'exportGetUrlAsPath for first_child returns a Path::Class::File object');
is($fcAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, "exportGetUrlAsPath for first_child works for root directory");

# ensure 'index.html' works for a single directory.
$fcAsPath = $firstChild->exportGetUrlAsPath();
isa_ok($fcAsPath, 'Path::Class::File', 'exportGetUrlAsPath for first_child without index file returns a Path::Class::File object');
is($fcAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, "exportGetUrlAsPath for first_child without index file works for root directory");

# down another level.
my $gcAsPath = $grandChild->exportGetUrlAsPath('index.html');
$litmus = Path::Class::File->new($exportPath, $grandChild->getUrl, 'index.html');
isa_ok($gcAsPath, 'Path::Class::File', 'exportGetUrlAsPath for grandchild returns a Path::Class::File object');
is($gcAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, "exportGetUrlAsPath for grandchild works for root directory");

# without index.html
$gcAsPath = $grandChild->exportGetUrlAsPath();
$litmus = Path::Class::File->new($exportPath, $grandChild->getUrl, 'index.html');
isa_ok($gcAsPath, 'Path::Class::File', 'exportGetUrlAsPath for grandchild without index file returns a Path::Class::File object');
is($gcAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, "exportGetUrlAsPath for grandchild without index file works for root directory");

# now let's get tricky and test different file extensions
my $storage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($storage->getId);
my $filename = 'somePerlFile_pl.txt';
$storage->addFileFromScalar($filename, $filename);
$session->user({userId=>3});
my $properties = {
    #     '1234567890123456789012'
    id          => 'ExportTest000000000001',
    title       => 'Export Test',
    className   => 'WebGUI::Asset::File',
    url         => 'export-test.pl',
    storageId   => $storage->getId,
    filename    => 'somePerlFile_pl.txt',
};

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Asset Export Test"});
addToCleanup($versionTag);

my $asset = $importNode->addChild($properties, $properties->{id});
$asset->update({
        storageId => $storage->getId,
        filename => $filename,
});

my $fileAsPath = $asset->exportGetUrlAsPath('index.html');

# .pl files are recognised by apache, so are passed through as-is
$litmus = Path::Class::File->new($exportPath, $asset->getUrl);
isa_ok($fileAsPath, 'Path::Class::File', 'exportGetUrlAsPath for perl file returns a Path::Class::File object');
is($fileAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, 'exportGetUrlAsPath for perl file works');

# test a different extension, the .foobar extension
$storage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($storage->getId);
$filename = 'someFoobarFile.foobar';
$storage->addFileFromScalar($filename, $filename);
$properties = {
    id          => 'ExportTest000000000002',
    title       => 'Export Test',
    className   => 'WebGUI::Asset::File',
    url         => 'export-test.foobar',
};
$asset = $importNode->addChild($properties, $properties->{id});
$asset->update({
        storageId   => $storage->getId,
        filename    => $filename,
});
$versionTag->commit;

$fileAsPath = $asset->exportGetUrlAsPath('index.html');
# not recognised by apache, so it'll add an index.html, make sure it does so
$litmus = Path::Class::File->new($exportPath, $asset->getUrl, 'index.html');
isa_ok($fileAsPath, 'Path::Class::File', 'exportGetUrlAsPath for plain file returns a Path::Class::File object');
is($fileAsPath->absolute($exportPath)->stringify, $litmus->absolute($exportPath)->stringify, 'exportGetUrlAsPath for plain file works');

#----------------------------------------------------------------------------
# exportWriteFile()

# we'll be writing real on-disk files and directories for these tests. do our
# level best at cleaning up after ourselves. this is taken care of in the END
# block via rmtree().
# ideally, exportCheckPath will have been called before exportWriteFile(), but
# we can't be certain of that. this means that we may not have permission to
# write to the exportPath, or the exportPath may not even exist. there's also a
# race condition that exists between the time exportCheckPath() ran and the
# time exportWriteFile() attempts to write files to disk. it's pathological,
# yes, but I'm really not interested in tracking down the kinds of bugs that
# these race conditions can create. so exportWriteFile() will check for the
# actual ability to make all of the paths it requires and for the ability to
# write the files it needs.
# so, let's get started with a bad export path. set it to something that
# shouldn't exist first. this should try to create it. rather than testing two
# parts of the code (the nonexistent directory check and the creation success
# check) at once, let's make it something that we *can* create. probably the
# best way to generate something that we can guarantee doesn't exist is to use
# a GUID.

# we need to be tricky here and call code in wG proper which calls www_ methods
# even though we don't have access to modperl. the following hack lets us do
# that.
#$session->http->setNoHeader(1);

$session->user( { userId => 1 } );
my $content;
my $guid = $session->id->generate;
my $guidPath = Path::Class::Dir->new($config->get('uploadsPath'), 'temp', $guid);
$config->set('exportPath', $guidPath->absolute->stringify);
eval { $parent->exportWriteFile() };
is($@, '', "exportWriteFile works when creating exportPath");

# ensure that the file was actually written
ok(-e $parent->exportGetUrlAsPath->absolute->stringify, "exportWriteFile actually writes the file when creating exportPath");

# now make sure that it contains the correct content
eval { $content = WebGUI::Test->getPage($parent, 'exportHtml_view', { user => WebGUI::User->new($session, 1) } ) };
is(scalar $parent->exportGetUrlAsPath->slurp, $content, "exportWriteFile puts the correct contents in exported parent");


# now that we know that creating the export directory works, let's make sure
# that creating it, when we have no permission to do so, throws an exception.

# first, set the exportPath to a *sub*directory of $guid to ensure that it
# doesn't already exist, and then deny ourselves permissions to it.
my $unwritablePath = Path::Class::Dir->new($config->get('uploadsPath'), 'temp', $guid, $guid);
chmod 0000, $guidPath->stringify;
$config->set('exportPath', $unwritablePath->absolute->stringify);

$session->http->setNoHeader(1);
SKIP: {
    skip 'Root will cause this test to fail since it does not obey file permissions', 2
        if $< == 0;
    eval { $parent->exportWriteFile() };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error', "exportWriteFile throws if it can't create the export path");
    cmp_deeply(
        $e,
        methods(
            error       => "can't create exportPath $unwritablePath",
        ),
        "exportWriteFile throws if it can't create the export path"
    );
}

# the exception was thrown, but make sure that the file also wasn't written
# can't call exportGetUrlAsPath on $parent right now, since the path is
# inaccessible and exportGetUrlAsPath calls exportCheckPath which throws an
# exception. therefore, specify this single specific case specifically for the
# sake of the test.
ok(!-e Path::Class::File->new($unwritablePath, 'parent', 'index.html')->absolute->stringify, "exportWriteFile does not write the file when it can't create the exportPath");

# let's go a level deeper
# but reset the exportPath first
$config->set('exportPath', $guidPath->absolute->stringify);

# and clean up the temp directory
chmod 0755, $guidPath->stringify;
$unwritablePath->remove;

$session->http->setNoHeader(1);
eval { $firstChild->exportWriteFile() };
is($@, '', "exportWriteFile works for first_child");

# ensure that the file was actually written
ok(-e $firstChild->exportGetUrlAsPath->absolute->stringify, "exportWriteFile actually writes the first_child file");

# verify it has the correct contents
eval { $content = WebGUI::Test->getPage($firstChild, 'exportHtml_view') };
is(scalar $firstChild->exportGetUrlAsPath->absolute->slurp, $content, "exportWriteFile puts the correct contents in exported first_child");

# and one more level. remove the export path to ensure directory creation keeps
# working.
$guidPath->rmtree;

$session->http->setNoHeader(1);
$session->user( { userId => 1 } );
eval { $grandChild->exportWriteFile() };
is($@, '', "exportWriteFile works for grandchild");

# ensure that the file was written
ok(-e $grandChild->exportGetUrlAsPath->absolute->stringify, "exportWriteFile actually writes the grandchild file");

# finally, check its contents
$session->style->sent(0);
eval { $content = WebGUI::Test->getPage($grandChild, 'exportHtml_view') };
is(scalar $grandChild->exportGetUrlAsPath->absolute->slurp, $content, "exportWriteFile puts correct content in exported grandchild");

# test different extensions
$guidPath->rmtree;
$asset = WebGUI::Asset->new($session, 'ExportTest000000000001');
$session->http->setNoHeader(1);
eval { $asset->exportWriteFile() };
is($@, '', 'exportWriteFile for perl file works');

ok(-e $asset->exportGetUrlAsPath->absolute->stringify, "exportWriteFile actually writes the perl file");

$guidPath->rmtree;
$asset = WebGUI::Asset->new($session, 'ExportTest000000000002');
eval { $asset->exportWriteFile() };
is($@, '', 'exportWriteFile for plain file works');

ok(-e $asset->exportGetUrlAsPath->absolute->stringify, "exportWriteFile actuall writes the plain file");

$guidPath->rmtree;

# next, make sure an exception is thrown if the user we're exporting as doesn't
# have permission to view the page that we want to export. by default, there's
# nothing actually in a stock WebGUI installation that any particular user
# isn't allowed to see. this means that we'll need to temporarily change the
# permissions on something.
$parent->update( { groupIdView => 3 } ); # admins
$session->http->setNoHeader(1);
eval { $parent->exportWriteFile() }; 
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error', "exportWriteFile throws when user can't view asset");
cmp_deeply(
    $e,
    methods(
        error       => "user can't view asset at " . $parent->getUrl . " to export it",
    ),
    "exportWriteFile throws when user can't view asset"
);

# now that we're sure that it throws the correct exception, make sure there's
# no directory or file written
ok(!-e $parent->exportGetUrlAsPath->absolute->stringify, "exportWriteFile doesn't write file when user can't view asset");
ok(!-e $parent->exportGetUrlAsPath->absolute->parent, "exportWriteFile doesn't write directory when user can't view asset");

# undo our viewing changes
$parent->update( { groupIdView => 7 } ); # everyone
$guidPath->rmtree;

#----------------------------------------------------------------------------
# exportSymlinkExtrasUploads()

# another class method. need to make sure it knows to check its first parameter
# for whether it's actually a WebGUI::Session. we don't need to fiddle with
# different paths or the permissions on them because if those paths are broken,
# other parts of the site will be utterly b0rked.

# ensure it checks whether its first argument is a session object

eval { WebGUI::Asset->exportSymlinkExtrasUploads };
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error::InvalidObject', 'exportSymlinkExtrasUploads without session object throws');
cmp_deeply(
    $e,
    methods(
        error       => 'first param to exportSymlinkExtrasUploads as a class method must be a WebGUI::Session',
    ),
    'exportSymlinkExtrasUploads without session object throws',
);

# call it with something that isn't a session
eval { WebGUI::Asset->exportSymlinkExtrasUploads('srsly? no wai!') };
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error::InvalidObject', 'exportSymlinkExtrasUploads called with memetic parameter throws');
cmp_deeply(
    $e,
    methods(
        error       => 'first param to exportSymlinkExtrasUploads as a class method must be a WebGUI::Session',
    ),
    'exportSymlinkExtrasUploads called with memetic parameter throws',
);


# now test that it works as it should, when it should
$exportPath             = $config->get('exportPath');
my $extrasPath          = $config->get('extrasPath');
my $extrasUrl           = $config->get('extrasURL');
my $uploadsPath         = $config->get('uploadsPath');
my $uploadsUrl          = $config->get('uploadsURL');

eval { WebGUI::Asset->exportSymlinkExtrasUploads($session) };

# make sure it doesn't throw any exceptions
is($@, '', 'exportSymlinkExtrasUploads works when it should');
my $extrasSymlink       = Path::Class::File->new($exportPath, $extrasUrl);
my $uploadsSymlink      = Path::Class::File->new($exportPath, $uploadsUrl);
ok(-e $extrasSymlink->absolute->stringify, "exportSymlinkExtrasUploads writes extras symlink");
is($extrasPath, readlink $extrasSymlink->absolute->stringify, "exportSymlinkExtrasUploads extras symlink points to right place");
ok(-e $uploadsSymlink->absolute->stringify, "exportSymlinkExtrasUploads writes uploads symlink");
is($uploadsPath, readlink $uploadsSymlink->absolute->stringify, "exportSymlinkExtrasUploads uploads symlink points to right place");

#----------------------------------------------------------------------------
# exportSymlinkRoot

# This class method functions almost exactly the same as
# exportSymlinkExtrasUploads except that it puts a symlink in a diferent place.
# test that it verifies its parameter is a session object and that it does what
# it's supposed to do.

eval { WebGUI::Asset->exportSymlinkRoot };
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error::InvalidObject', 'exportSymlinkRoot without session object throws');
cmp_deeply($e,
    methods(
        error       => 'first param to exportSymlinkRoot as a class method must be a WebGUI::Session'
    ),
    'exportSymlinkRoot without session object throws',
);

# okay, so calling it without any parameters breaks. let's call it with
# something nonsensical
eval { WebGUI::Asset->exportSymlinkRoot('srsly! wai!') };
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error::InvalidObject', 'exportSymlinkRoot called with memetic parameter throws');
cmp_deeply($e,
    methods(
        error       => 'first param to exportSymlinkRoot as a class method must be a WebGUI::Session'
    ),
    'exportSymlinkRoot called with memetic parameter throws',
);

# we need to make sure the code validates other parameters as well
eval { WebGUI::Asset->exportSymlinkRoot($session) };
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error::InvalidParam', 'exportSymlinkRoot called without a default asset throws');
cmp_deeply(
    $e,
    methods(
        error       => 'second param to exportSymlinkRoot must be the default asset',
        param       => undef,
    ),
    'exportSymlinkRoot called without a default asset throws',
);

# give it something not a default asset
eval { WebGUI::Asset->exportSymlinkRoot($session, "wai. can't be!") };
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error::InvalidParam', 'exportSymlinkRoot called with memetic default asset throws');
cmp_deeply(
    $e,
    methods(
        error       => 'second param to exportSymlinkRoot must be the default asset',
        param       => "wai. can't be!",
    ),
    'exportSymlinkRoot called with memetic default asset throws',
);

# it breaks when it's supposed to, so let's make sure it works when it's
# supposed to. first, leave out the index parameter to ensure it sets up the
# default correctly.
$parent->exportWriteFile;
my $symlinkedRoot   = Path::Class::File->new($exportPath, 'index.html');
my $parentPath        = $parent->exportGetUrlAsPath;
eval { WebGUI::Asset->exportSymlinkRoot($session, $parent, '') };
is($@, '', 'exportSymlinkRoot works when it should');
ok(-e $symlinkedRoot->stringify, 'exportSymlinkRoot sets up link correctly and supplies default index');
is(readlink $symlinkedRoot->stringify, $parentPath, 'exportSymlinkRoot sets up link correctly and supplies default index');
unlink $symlinkedRoot->stringify;


# give it an index and ensure it works
eval { WebGUI::Asset->exportSymlinkRoot($session, $parent, 'index.html') };
is($@, '', 'exportSymlinkRoot works when it should');
ok(-e $symlinkedRoot->stringify, 'exportSymlinkRoot sets up link correctly and supplies default index');
is(readlink $symlinkedRoot->stringify, $parentPath, 'exportSymlinkRoot sets up link correctly and supplies default index');
unlink $symlinkedRoot->stringify;


#----------------------------------------------------------------------------
# exportGetDescendants()

# clear these out now so that they don't interfere with the lineage tests
$asset = WebGUI::Asset->new($session, 'ExportTest000000000001');
$asset->purge;
$asset = WebGUI::Asset->new($session, 'ExportTest000000000002');
$asset->purge;

$session->user( { userId => 1 } );
my $descendants;
# next, make sure that we get the right list of assets to export.
my $parentDescendants = $parent->getLineage( ['self', 'descendants'], {
        endingLineageLength => $parent->getLineageLength + 99,
        orderByClause       => 'assetData.url DESC',
    }
);
$descendants = $parent->exportGetDescendants( WebGUI::User->new($session, 1), 99 );

cmp_deeply($descendants, $parentDescendants, "exportGetDescendants returns correct data for parent");

my $fcDescendants = $firstChild->getLineage( ['self', 'descendants'], {
        endingLineageLength => $firstChild->getLineageLength + 99,
        orderByClause       => 'assetData.url DESC',
    }
);
$descendants = $firstChild->exportGetDescendants( WebGUI::User->new($session, 1), 99 );

cmp_deeply($descendants, $fcDescendants, "exportGetDescendants returns correct data for first_child");

my $gcDescendants = $grandChild->getLineage( ['self', 'descendants'], {
        endingLineageLength => $grandChild->getLineageLength + 99,
        orderByClause       => 'assetData.url DESC',
    }
);
$descendants = $grandChild->exportGetDescendants( WebGUI::User->new($session, 1), 99 );

cmp_deeply($descendants, $gcDescendants, "exportGetDescendants returns correct data for grand_child");

eval { $parent->exportGetDescendants };
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error::InvalidParam', 'exportGetDescendants called without a depth throws');
cmp_deeply(
    $e,
    methods(
        error       => 'Need a depth',
        param       => undef,
    ),
    "exportGetDescendants called without a depth throws",
);

$session->user( { userId => 3 } );

#----------------------------------------------------------------------------
# exportAsHtml

# the big one. exportAsHtml is the central logic hub for all of the methods
# tested above. we don't need to test that the other methods work; that's what
# the other 70 tests above do. what we need to do is ensure that exportAsHtml:
#   * processes its arguments correctly
#   * calls the right methods in the right order
#   * handles any exceptions
#   * produces correct output
#   * fails if it needs to fail
# in other words, we need to test that the ultimate results of calling
# exportAsHtml are what they should be, given the inputs we provide.
my (@createdFiles, @shouldExist, $success, $message);
$exportPath = Path::Class::Dir->new($session->config->get('exportPath'));

# first things first. let's make sure the code checks for the proper arguments.
# quiet is optional, so don't test that. userId is a bit smart and will take
# either a numeric userId or a real WebGUI::User object. everything else has a
# default. exportAsHtml is supposed to catch exceptions, not throw them, so
# we'll be testing the return values rather than for an exception.

eval { $message = $parent->exportAsHtml };
is($@, "need a userId parameter", "exportAsHtml returns correct error when not given a userId");

# omitting the userId works, so let's give it a bogus userId
eval { $message = $parent->exportAsHtml( { userId => '<rizen> perlDreamer is a 500 lb test mandating gorilla' } ) };
is($@, "'<rizen> perlDreamer is a 500 lb test mandating gorilla' is not a valid userId", "exportAsHtml throws correct error when given a bogus (but nonetheless funny) userId");

# checking an autogenerated userId
my $randomUser = WebGUI::User->new($session, 'new');
eval { $message = $parent->exportAsHtml( { userId => $randomUser->userId, depth => 99} ) };
is($@, '', "exportAsHtml doesn't throw error when given a valid userId");
$randomUser->delete;
undef $randomUser;

# checking userId works, so check extrasUploadAction next.
eval { $message = $parent->exportAsHtml( { userId => 3, depth => 99, extrasUploadAction => 'o hai' } ) };
is($@, "'o hai' is not a valid extrasUploadAction", "exportAsHtml throws correct error when given bogus, memetic extrasUploadAction parameter");

# rootUrlAction
eval { $message = $parent->exportAsHtml( { userId => 3, depth => 99, rootUrlAction => 'NO U' } ) };
is($@, "'NO U' is not a valid rootUrlAction", "exportAsHtml throws correct error when given bogus, memetic extrasUploadAction parameter");

# finally, depth
eval { $message = $parent->exportAsHtml( { userId => 3 } ) };
is($@, "need a depth", "exportAsHtml throws correct error when not given a depth");

eval { $message = $parent->exportAsHtml( { userId => 3, depth => 'orly? yarly!' } ) };
is($@, "orly? yarly! is not a valid depth", "exportAsHtml throws correct error when given bogus, memetic depth");

# next, let's make sure some simple exports work. export 'parent', but clean up
# the exportPath first to make sure there are no residuals from the tests
# above.
$exportPath->rmtree;
eval { $message = $parent->exportAsHtml( { userId => 3, depth => 99, quiet => 1 } ) };
is($@, '', "exportAsHtml on parent does not throw an error"); ##Note, string comparison

# list of files that should exist. obtained by running previous known working
# export function on a full stock asset tree
@createdFiles = (
    [ qw/ first_child     grand_child              index.html /],
    [ qw/ first_child                              index.html /],
    [ qw/ parent                                   index.html /],
);

# turn them into Path::Class::File objects
@shouldExist = map { Path::Class::File->new($exportPath, @{$_})->absolute->stringify } @createdFiles;

my $numberCreatedAll = scalar @createdFiles;
like($message, qr/Exported $numberCreatedAll pages/, "exportAsHtml on parent returns correct message");

# ensure that the files that should exist do exist
my @doExist;
$exportPath->recurse( callback => sub { my $o = shift; $o->is_dir ? return : push @doExist, $o->absolute->stringify } );
cmp_bag(\@doExist, \@shouldExist, "exportAsHtml on parent writes correct files");

$exportPath->rmtree;
@doExist = ();

# previous tests ensure that the contents of the exported files are right. so
# let's go a level deeper and ensure that the right files are present.
eval { ($message) = $firstChild->exportAsHtml( { userId => 3, depth => 99, quiet => 1 } ) };
@createdFiles = (
    [ qw/ first_child grand_child index.html /],
    [ qw/ first_child index.html /],
);
@shouldExist = map { Path::Class::File->new($exportPath, @{$_})->absolute->stringify } @createdFiles;

$exportPath->recurse( callback => sub { my $o = shift; $o->is_dir ? return : push @doExist, $o->absolute->stringify } );
is($@, '', 'exportAsHtml on first_child page does not throw an exception');
cmp_bag(\@doExist, \@shouldExist, "... writes correct files");
like($message, qr/Exported 2 pages/, "... returns correct message");

$exportPath->rmtree;
@doExist = ();

# test the grandchild.
eval { ($message) = $grandChild->exportAsHtml( { userId => 3, depth => 99, quiet => 1 } ) };
@createdFiles = (
    [ qw/ first_child grand_child index.html /],
);

@shouldExist = map { Path::Class::File->new($exportPath, @{$_})->absolute->stringify } @createdFiles;

$exportPath->recurse( callback => sub { my $o = shift; $o->is_dir ? return : push @doExist, $o->absolute->stringify } );
is($@, '', 'exportAsHtml on grandchild does not throw an exception');
cmp_bag(\@shouldExist, \@doExist, "... writes correct files");
like($message, qr/Exported 1 pages/, "... returns correct message");

$exportPath->rmtree;
@doExist = ();

# fiddle with the isExportable setting and make sure appropriate files are
# written 
$parent->update({ isExportable => 0 });
eval { ($message) = $parent->exportAsHtml( { userId => 3, depth => 99, quiet => 1 } ) };

@shouldExist = ();
is($@, '', 'exportAsHtml on nonexportable parent does not throw an exception');
is(@shouldExist, @doExist, "... doesn't write anything");
like($message, qr/Exported 0 pages/, "... returns correct message");

# restore the original setting
$parent->update({ isExportable => 1 });

# go a level deeper

# shouldn't be necessary if the tests pass, but be nice and clean up after ourselves
$exportPath->rmtree; 

@doExist = ();
$firstChild->update({ isExportable => 0 });

eval { ($message) = $parent->exportAsHtml( { userId => 3, depth => 99, quiet => 1 } ) };

# since first_child isn't exportable, it shouldn't be written. remove it
# and its descendants from the list.
@createdFiles = (
    [ qw/ parent index.html /],
);
my $numberCreated = scalar @createdFiles;

@shouldExist = map { Path::Class::File->new($exportPath, @{$_})->absolute->stringify } @createdFiles;

$exportPath->recurse( callback => sub { my $o = shift; $o->is_dir ? return : push @doExist, $o->absolute->stringify } );
is($@, '', 'exportAsHtml on parent with non-exportable first_child writes correct files');
cmp_bag(\@doExist, \@shouldExist, "... writes correct files");
like($message, qr/Exported $numberCreated pages/, "... returns correct message");

# restore the original setting
$firstChild->update({ isExportable => 1 });

$exportPath->rmtree;
@doExist = ();

# now that we're sure that it works when everything is set up properly, let's
# test the code under inclement circumstances. let's cover each method that
# exportAsHtml calls in turn. we'll make sure it catches each exception that we
# can generate here. exceptions shouldn't propagate to the www_ methods. they
# should be caught before that point and a message returned to the user. the
# best way to do these is to mimic the order that they're tested above. we
# can't test the invalid argument exceptions, though, because the environment
# for those tests is the actual code of the exportAsHtml method. however,
# everything that's external to the code of the method itself we can test, like
# an unset exportPath. we'll test a couple of things. note that these
# exceptions should be *caught* by exportAsHtml, so the code needs to live.
# also, we need to test that appropriate status messages based on those
# exceptions are returned to the calling method. given the above, we'll test
# the following situations and verify that the following things occur properly:
#  checkExportPath:
#   1. lack of defined exportPath
#   2. inaccessible exportPath
#   3. exportPath is a file, not a directory
#   4. can't create path for whatever reason
#  exportCheckExportable:
#   doesn't throw exceptions
#  exportWriteFile:
#   1. user can't view asset
#  exportGetDescendants:
#   doesn't throw exceptions we can test (they're all method usage-related)

# let's start with an invalid exportPath
$config->delete('exportPath');

# undefined exportPath
eval { ($message) = $parent->exportAsHtml( { userId => 3, depth => 99 } ) };
is($@,       'exportPath must be defined and not ""', "exportAsHtml catches undefined exportPath exception");

SKIP: {
    skip 'Root will cause this test to fail since it does not obey file permissions', 1
        if $< == 0;

    # inaccessible exportPath
    chmod 0000, $tempDirectory; 
    $config->set('exportPath', $inaccessibleDirectory->stringify); 

    eval { ($message) = $parent->exportAsHtml( { userId => 3, depth => 99 } ) };
    is($@,       "can't create exportPath " . $inaccessibleDirectory->stringify, "exportAsHtml catches inaccessible exportPath ");
}

# exportPath is a file, not a directory
$config->set('exportPath', $exportPathFile);

eval { ($message) = $parent->exportAsHtml( { userId => 3, depth => 99 } ) };
is($@,       "$exportPathFile isn't a directory", "exportAsHtml catches exportPath is file exception");

$config->set('exportPath', $inaccessibleDirectory->stringify);
SKIP: {
    skip 'Root will cause this test to fail since it does not obey file permissions', 1
        if $< == 0;

    # can't create export path
    chmod 0000, $tempDirectory;

    eval { ($message) = $parent->exportAsHtml( { userId => 3, depth => 99 } ) };
    is($@, "can't create exportPath $inaccessibleDirectory", "exportAsHtml catches uncreatable exportPath exception");
}

# user can't view asset
$parent->update( { groupIdView => 3 } );
$session->http->setNoHeader(1);

chmod 0755, $tempDirectory;
eval { ($message) = $parent->exportAsHtml( { userId => 1, depth => 99 } ) };
is($@, "can't view asset at URL /parent", "exportAsHtml catches unviewable asset exception");

# fix viewing the asset
$parent->update( { groupIdView => 7 } );

# the "can't write file" exceptions for exportWriteFile are largely related to
# the exportPath being broken somehow. That's already been tested. next, let's
# make sure symlinking works. start with extrasUploadAction. no use checking
# for valid paths and URLs for these values in the config file. the site would
# be horridly, totally broken if they were incorrect. assume that they're
# valid.
$config->set('exportPath', $tempDirectory);
$exportPath         = Path::Class::Dir->new($tempDirectory);
$extrasPath         = $config->get('extrasPath');
$extrasUrl          = $config->get('extrasURL');
$uploadsPath        = $config->get('uploadsPath');
$uploadsUrl         = $config->get('uploadsURL');

$exportPath->rmtree;

eval { ($message)    = $parent->exportAsHtml( { userId => 3, depth => 99, extrasUploadAction => 'symlink', quiet => 1 } ) };

is($@, '', "exportAsHtml when linking extras and uploads does not throw an exception");
like($message, qr/Exported $numberCreatedAll pages/, "... returns correct message");

$extrasSymlink          = Path::Class::File->new($exportPath, $extrasUrl);
$uploadsSymlink         = Path::Class::File->new($exportPath, $uploadsUrl);

ok(-e $extrasSymlink->absolute->stringify,                    "exportAsHtml writes extras symlink")
    or diag "link not found at " . $extrasSymlink->absolute;
is(readlink $extrasSymlink->absolute->stringify, $extrasPath, "exportAsHtml extras symlink points to right place");

ok(-e $uploadsSymlink->absolute->stringify,                     "exportAsHtml writes uploads symlink")
    or diag "link not found at " . $uploadsSymlink->absolute;
is(readlink $uploadsSymlink->absolute->stringify, $uploadsPath, "exportAsHtml uploads symlink points to right place");

# next, make sure the root URL symlinking works.
eval { ($message)    = $parent->exportAsHtml( { userId => 3, depth => 99, rootUrlAction => 'symlink', quiet => 1 } ) };
my $rootUrlSymlink      = Path::Class::File->new($exportPath, 'index.html');
is($@, '', 'exportAsHtml does not throw an error when linking root URL');
like($message, qr/Exported $numberCreatedAll pages/, "... returns correct message");
ok(-l $rootUrlSymlink->absolute->stringify, "... writes root URL symlink")
    or diag "link not found at " . $rootUrlSymlink->absolute;
is(readlink $rootUrlSymlink->absolute->stringify, WebGUI::Asset->getDefault($session)->exportGetUrlAsPath->absolute->stringify, "... root URL symlink points to right place");

