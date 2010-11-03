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
use File::Copy qw/mv/;
use File::Path;
use Data::Dumper;
use Path::Class;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Maker::Permission;
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::DateTime;
use DateTime;

################################################################
#
#  setup session, users and groups for this test
#
################################################################

my $session         = WebGUI::Test->session;

my $staff = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($staff);
$staff->name('Reporting Staff');

my $reporter = WebGUI::User->new($session, 'new');
$reporter->username('reporter');
my $editor   = WebGUI::User->new($session, 'new');
$editor->username('editor');
my $reader   = WebGUI::User->new($session, 'new');
$reader->username('reader');
$staff->addUsers([$reporter->userId]);
WebGUI::Test->addToCleanup($reporter, $editor, $reader);

my $archive = 'placeholder for Test::Maker::Permission';

my $canPostMaker = WebGUI::Test::Maker::Permission->new();
$canPostMaker->prepare({
    object   => $archive,
    session  => $session,
    method   => 'canPostStories',
    pass     => [3, $editor, $reporter ],
    fail     => [1, $reader            ],
});

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Asset::Wobject::StoryArchive');

my $storage;
my $versionTag;

my $creationDateSth = $session->db->prepare('update asset set creationDate=? where assetId=?');
my @skipAutoCommit  = WebGUI::Test->getAssetSkipCoda;

my $home = WebGUI::Asset->getDefault($session);

$archive    = $home->addChild({
                className => 'WebGUI::Asset::Wobject::StoryArchive',
                title => 'My Stories',
                url => '/home/mystories',
                styleTemplateId => $home->get('styleTemplateId'),
              });
$versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->commit;
WebGUI::Test->addToCleanup($versionTag);
$archive = $archive->cloneFromDb;

isa_ok($archive, 'WebGUI::Asset::Wobject::StoryArchive', 'created StoryArchive');

################################################################
#
#  canPostStories
#
################################################################

$archive->update({
    ownerUserId => $editor->userId,
    groupToPost => $staff->getId,
});

is($archive->get('groupToPost'), $staff->getId, 'set Staff group to post to Story Archive');

$canPostMaker->{_tests}->[0]->{object} = $archive;

$canPostMaker->run();

################################################################
#
#  getFolder
#
################################################################

##Note, this is just to prevent date rollover from happening.
##We'll test implicit getFolder later on.
my $now = time();
my $todayFolder = $archive->getFolder($now);
isa_ok($todayFolder, 'WebGUI::Asset::Wobject::Folder', 'getFolder created a Folder');
is($archive->getChildCount, 1, '... created a child');
my $dt = DateTime->from_epoch(epoch => $now, time_zone => $session->datetime->getTimeZone);
my $folderName = $dt->strftime('%B_%d_%Y');
$folderName =~ s/^(\w+_)0/$1/;
is($todayFolder->getTitle, $folderName, '... folder has the right name');
my $folderUrl = $archive->getFolderUrl($folderName);
is($todayFolder->get('url'), $folderUrl, '... folder has the right URL');
is($todayFolder->getParent->getId, $archive->getId, '... created folder has the right parent');
is($todayFolder->get('state'),  'published', '... created folder is published');
is($todayFolder->get('status'), 'approved',  '... created folder is approved');
is($todayFolder->get('styleTemplateId'), $archive->get('styleTemplateId'),  '... created folder has correct styleTemplateId');

{
    my $undo = WebGUI::Test->overrideSetting(urlExtension => 'ext');
    my $arch2 = $home->addChild({
        className => 'WebGUI::Asset::Wobject::StoryArchive',
        title     => 'Extension Tester',
    });
    addToCleanup($arch2);

    is $arch2->get('url'),
        'home/extension-tester.ext',
        'ext added';

    is $arch2->getFolderUrl('blah'),
        'home/extension-tester/blah.ext',
        'folder url: strip extension from parent and add to child';

    my $folder = $arch2->getFolder($now);
    ok defined $folder, 'getFolder with url extension';

    is $folder->get('url'),
        $arch2->getFolderUrl($folder->getMenuTitle),
        'getFolderUrl and folder getUrl match';
}

my $sameFolder = $archive->getFolder($now);
is($sameFolder->getId, $todayFolder->getId, 'call with same time returns the same folder');
undef $sameFolder;

my ($startOfDay, $endOfDay) = $session->datetime->dayStartEnd($now);
$sameFolder = $archive->getFolder($startOfDay);
is($sameFolder->getId, $todayFolder->getId, 'call within same day(start) returns the same folder');
undef $sameFolder;
$sameFolder = $archive->getFolder($endOfDay);
is($sameFolder->getId, $todayFolder->getId, 'call within same day(end) returns the same folder');
undef $sameFolder;
$todayFolder->purge;
is($archive->getChildCount, 0, 'leaving with an empty archive');

{
    my $archive2    = $home->addChild({
                    className => 'WebGUI::Asset::Wobject::StoryArchive',
                    title => 'Uncommitted',
                    url => 'uncommitted_archive',
                  });
    my $guard = WebGUI::Test->cleanupGuard($archive2);
    my $new_folder = $archive2->getFolder;
    is $archive2->get('tagId'), $new_folder->get('tagId'), 'folder added to uncommitted archive uses the same version tag';
}

################################################################
#
#  addChild
#
################################################################

my $child = $archive->addChild({className => 'WebGUI::Asset::Wobject::StoryTopic'});
is($child, undef, 'addChild: Will only add Stories');

$child = $archive->addChild({className => 'WebGUI::Asset::Snippet'});
is($child, undef, '... will not add snippets');

$child = $archive->addChild({className => 'WebGUI::Asset::Wobject::Folder'});
isa_ok($child, 'WebGUI::Asset::Wobject::Folder', '... will add folders, so importing a package works');

$child->purge;

$child = $archive->addChild({className => 'WebGUI::Asset::Story', title => 'First Story'}, @skipAutoCommit);
my $tag1 = WebGUI::VersionTag->getWorking($session);
$tag1->commit;
WebGUI::Test->addToCleanup($tag1);
isa_ok($child, 'WebGUI::Asset::Story', 'addChild added and returned a Story');
is($archive->getChildCount, 1, '... added it to the archive');
my $folder = $archive->getFirstChild();
isa_ok($folder, 'WebGUI::Asset::Wobject::Folder', '... Folder was added to Archive');
is($folder->getChildCount, 1, '... The folder has 1 child...');
is($folder->getFirstChild->getTitle, 'First Story', '... and it is the correct child');

################################################################
#
#  getKeywordFilename
#
################################################################

##Note, this method depends heavily on the default installed language pack.
##Because of that, we'll only test for whether or not url->urlize is called.

is ($archive->getKeywordFilename('camelCase'), 'keyword_camelcase.html', 'getKeywordFilename returns a lower case keyword with _keyword.html appended');

################################################################
#
#  viewTemplateVariables
#
################################################################

my $wgBday    = WebGUI::Test->webguiBirthday;
my $oldFolder = $archive->getFolder($wgBday);

my $yesterday = $now-24*3600;
my $newFolder = $archive->getFolder($yesterday);

my ($wgBdayMorn,undef)    = $session->datetime->dayStartEnd($wgBday);
my ($yesterdayMorn,undef) = $session->datetime->dayStartEnd($yesterday);

my $story = $oldFolder->addChild({ className => 'WebGUI::Asset::Story', title => 'WebGUI is released', keywords => 'roger,foxtrot,echo,all'}, @skipAutoCommit);
$creationDateSth->execute([$wgBday, $story->getId]);
my $tag2 = WebGUI::VersionTag->getWorking($session);
$tag2->commit;
WebGUI::Test->addToCleanup($tag2);

{
    my $storyDB = WebGUI::Asset->newByUrl($session, $story->getUrl);
    is ($storyDB->get('status'), 'approved', 'addRevision always calls for an autocommit');
}

my $pastStory = $newFolder->addChild({ className => 'WebGUI::Asset::Story', title => "Yesterday is history" }, @skipAutoCommit);
$creationDateSth->execute([$yesterday, $pastStory->getId]);
my $tag3 = WebGUI::VersionTag->getWorking($session);
$tag3->commit;
WebGUI::Test->addToCleanup($tag3);

my $templateVars;
$templateVars = $archive->viewTemplateVariables();

cmp_deeply(
    $templateVars,
    superhashof({
        searchHeader => ignore(),
        searchForm   => ignore(),
        searchButton => ignore(),
        searchFooter => ignore(),
    }),
    'viewTemplateVars: search variables present'
);

cmp_deeply(
    $templateVars,
    superhashof({
        rssUrl  => $archive->getRssFeedUrl,
        atomUrl => $archive->getAtomFeedUrl,
    }),
    'viewTemplateVars: RSS and Atom feed template variables'
);

KEY: foreach my $key (keys %{ $templateVars }) {
    next KEY if $key ~~ [qw/canPostStories addStoryUrl date_loop mode/];
    delete $templateVars->{$key};
}

$session->user({userId => 1});
cmp_deeply(
    $templateVars,
    {
        canPostStories => bool(0),
        mode           => 'view',
        addStoryUrl    => '',
        date_loop      => [
            {
                epochDate => ignore(),
                story_loop => [ {
                    creationDate => ignore(),
                    url          => re('first-story'),
                    title        => 'First Story',
                }, ],
            },
            {
                epochDate => $yesterdayMorn,
                story_loop => [{
                    creationDate => $yesterday,
                    url          => re('yesterday-is-history'),
                    title        => "Yesterday is history",
                }, ],
            },
            {
                epochDate => $wgBdayMorn,
                story_loop => [ {
                    creationDate => $wgBday,
                    url          => '/home/mystories/august_16_2001/webgui-is-released',
                    title        => 'WebGUI is released',
                }, ],
            },
        ]
    },
    'viewTemplateVariables: returns expected template variables with 3 stories in different folders, user is cannot edit stories'
);

my $story2 = $folder->addChild({ className => 'WebGUI::Asset::Story', title => 'Story 2', keywords => "roger,foxtrot,all"}, @skipAutoCommit);
my $story3 = $folder->addChild({ className => 'WebGUI::Asset::Story', title => 'Story 3', keywords => "foxtrot,echo,all"},  @skipAutoCommit);
my $story4 = $folder->addChild({ className => 'WebGUI::Asset::Story', title => 'Story 4', keywords => "roger,echo,all"},    @skipAutoCommit);
foreach my $storilet ($story2, $story3, $story4) {
    $session->db->write("update asset set creationDate=$now where assetId=?",[$storilet->getId]);
}
$archive->update({storiesPerPage => 3});
my $tag4 = WebGUI::VersionTag->getWorking($session);
$tag4->commit;
WebGUI::Test->addToCleanup($tag4);

##Don't assume that Admin and Visitor have the same timezone.
$session->user({userId => 3});
($wgBdayMorn,undef)   = $session->datetime->dayStartEnd($wgBday);

$templateVars = $archive->viewTemplateVariables();
KEY: foreach my $key (keys %{ $templateVars }) {
    next KEY if $key ~~ [qw/canPostStories addStoryUrl date_loop/];
    delete $templateVars->{$key};
}

cmp_deeply(
    $templateVars,
    {
        canPostStories => 1,
        addStoryUrl    => '/home/mystories?func=add;class=WebGUI::Asset::Story',
        date_loop      => [
            {
                epochDate => ignore(),
                story_loop => [
                    {
                        creationDate => ignore(),
                        url          => re('first-story'),
                        title        => 'First Story',
                        editIcon     => ignore(),
                        deleteIcon   => ignore(),
                    },
                    {
                        creationDate => ignore(),
                        url          => ignore(),
                        title        => 'Story 2',
                        editIcon     => ignore(),
                        deleteIcon   => ignore(),
                    },
                    {
                        creationDate => ignore(),
                        url          => ignore(),
                        title        => 'Story 3',
                        editIcon     => ignore(),
                        deleteIcon   => ignore(),
                    },
                ],
            },
        ],
    },
    'viewTemplateVariables: returns expected template variables with several stories in 3 different folders'
);

TODO: {
    local $TODO = "viewTemplateVariables code to write";
    ok(0, 'Check that Stories from the future are not displayed unless the user canEdit this StoryArchive');
}

################################################################
#
#  viewTemplateVariables, keywords search mode
#
################################################################

$session->request->setup_body({ keyword => 'foxtrot' } );
$archive->update({storiesPerPage => 25});

$templateVars = $archive->viewTemplateVariables('keyword');
is($templateVars->{mode}, 'keyword', 'viewTemplateVariables mode == keyword');
cmp_deeply(
    $templateVars->{date_loop},
    [
        {
            epochDate => ignore(),
            story_loop => [
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 2',
                    editIcon     => ignore(),
                    deleteIcon   => ignore(),
                },
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 3',
                    editIcon     => ignore(),
                    deleteIcon   => ignore(),
                },
            ],
        },
        {
            epochDate => $wgBdayMorn,
            story_loop => [
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'WebGUI is released',
                    editIcon     => ignore(),
                    deleteIcon   => ignore(),
                },
            ],
        },
    ],
    'viewTemplateVariables: keyword mode returns the correct assets in the same form as view mode'
);

$archive->update({storiesPerPage => 3});
$session->request->setup_body({ keyword => 'all' } );
$templateVars = $archive->viewTemplateVariables('keyword');
ok($templateVars->{'pagination.pageCount.isMultiple'}, 'keyword search with multiple pages');
is($templateVars->{'pagination.lastPageUrl'}, '/home/mystories?func=view;keyword=all;pn=2', '... pagination variable has correct URL');

$session->request->setup_body({ } );

################################################################
#
#  viewTemplateVariables, search mode
#
################################################################

$session->request->setup_body({ query => 'echo' } );
$archive->update({storiesPerPage => 25});
$templateVars = $archive->viewTemplateVariables('search');
is($templateVars->{mode}, 'search', 'viewTemplateVariables mode == search');

cmp_bag(
    $templateVars->{date_loop},
    [
        {
            epochDate => ignore(),
            story_loop => bag(
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 3',
                    editIcon     => ignore(),
                    deleteIcon   => ignore(),
                },
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'Story 4',
                    editIcon     => ignore(),
                    deleteIcon   => ignore(),
                },
            ),
        },
        {
            epochDate => $wgBdayMorn,
            story_loop => [
                {
                    creationDate => ignore(),
                    url          => ignore(),
                    title        => 'WebGUI is released',
                    editIcon     => ignore(),
                    deleteIcon   => ignore(),
                },
            ],
        },
    ],
    'viewTemplateVariables: search mode returns the correct assets in the same form as view mode'
);

################################################################
#
#  viewTemplateVariables, export mode
#
################################################################


$session->scratch->set('isExporting', 1);
$archive->update({ storiesPerPage => 3, });
$templateVars = $archive->viewTemplateVariables();
ok( (  !exists $templateVars->{searchHeader}
    && !exists $templateVars->{searchForm}
    && !exists $templateVars->{searchButton}
    && !exists $templateVars->{searchForm}
    ),
    '... export mode, no search variables present'
);

cmp_deeply(
    $templateVars,
    superhashof({
        rssUrl  => $archive->getStaticRssFeedUrl,
        atomUrl => $archive->getStaticAtomFeedUrl,
    }),
    '... export mode, RSS and Atom feed template variables show the static url'
);

my $storyCount = 0;
foreach my $date_loop (@{ $templateVars->{date_loop} }) {
    $storyCount += scalar @{ $date_loop->{story_loop} };
}

cmp_ok($storyCount, '>', 3, '... export mode, pagination increased beyond storiesPerPage');

$session->scratch->delete('isExporting');

################################################################
#
#  tagCloud template variable in view
#
################################################################

$templateVars = $archive->viewTemplateVariables();
my @anchors = simpleHrefParser($templateVars->{keywordCloud});
my @expectedAnchors = ();
foreach my $keyword(qw/echo foxtrot roger all/) {
    push @expectedAnchors, [ $keyword, '/home/mystories?func=view;keyword='.$keyword ];
}
cmp_bag(
    \@anchors,
    \@expectedAnchors,
    'keywordCloud template variable has keywords and correct links',
);

################################################################
#
#  tagCloud template variable in view, exportMode
#
################################################################

$session->scratch->set('isExporting', 1);

$templateVars = $archive->viewTemplateVariables();
@anchors = simpleHrefParser($templateVars->{keywordCloud});
@expectedAnchors = ();
foreach my $keyword(qw/echo foxtrot roger all/) {
    push @expectedAnchors, [ $keyword, '/home/mystories/keyword_'.$keyword.'.html' ];
}
cmp_bag(
    \@anchors,
    \@expectedAnchors,
    '... keywordCloud template variable has keywords and correct links in export mode',
);

$session->scratch->delete('isExporting');

################################################################
#
#  RSS and Atom checks
#
################################################################

is($archive->getRssFeedUrl,  '/home/mystories?func=viewRss',  'RSS Feed Url');
is($archive->getAtomFeedUrl, '/home/mystories?func=viewAtom', 'Atom Feed Url');

$archive->update({itemsPerFeed => 3});

cmp_deeply(
    $archive->getRssFeedItems(),
    [
        {
            title => 'First Story',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            guid        => ignore(),
            pubDate     => ignore(),
            author      => ignore(),
        },
        {
            title => 'Story 2',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
            guid        => ignore(),
            pubDate     => ignore(),
        },
        {
            title => 'Story 3',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
            guid        => ignore(),
            pubDate     => ignore(),
        },
    ],
    'rssFeedItems'
);

################################################################
#
#  export Collateral tests
#
################################################################

my $exportStorage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($exportStorage);
my $basedir = Path::Class::Dir->new($exportStorage->getPath);
$exportStorage->addFileFromScalar('index', 'export story archive content');
my $assetDir  = $basedir->subdir('mystories');
my $assetFile = $assetDir->file('index.html');
mkpath($assetDir->stringify);
mv($exportStorage->getPath('index'), $assetFile->stringify);
$archive->exportAssetCollateral($assetFile, {}, $session);

my $exportedFiles = $exportStorage->getFiles();
cmp_bag(
    $exportedFiles,
    [qw{
        mystories.rss                mystories
        mystories.atom               mystories.rdf
        mystories/index.html         mystories/keyword_echo.html
        mystories/keyword_roger.html mystories/keyword_foxtrot.html
        mystories/keyword_all.html
    }],
    'exportAssetCollateral: feed files exported'
);

cmp_bag(
    [ map { $_->relative($assetDir)->stringify } $assetDir->children ],
    [qw/
        keyword_echo.html
        keyword_roger.html
        keyword_foxtrot.html
        keyword_all.html
        index.html
    /],
    'exportAssetCollateral: keyword files exported into correct dir (below the asset)'
);

my $roger = $exportStorage->getFileContentsAsScalar('mystories/keyword_roger.html');
my @rogerStories = map { $_->[0] } fetchKeywordAssetList($roger);
cmp_bag(
    \@rogerStories,
    [
        'Story 2',
        'Story 4',
        'WebGUI is released',
    ],
    '... contents of roger keyword file'
);

my $foxtrot = $exportStorage->getFileContentsAsScalar('mystories/keyword_foxtrot.html');
my @foxtrotStories = map { $_->[0] } fetchKeywordAssetList($foxtrot);
cmp_bag(
    \@foxtrotStories,
    [
        'Story 2',
        'Story 3',
        'WebGUI is released',
    ],
    '... contents of foxtrot keyword file'
);

my $echo = $exportStorage->getFileContentsAsScalar('mystories/keyword_echo.html');
my @echoStories = map { $_->[0] } fetchKeywordAssetList($echo);
cmp_bag(
    \@echoStories,
    [
        'Story 3',
        'Story 4',
        'WebGUI is released',
    ],
    '... contents of echo keyword file'
);

################################################################
#
#  getKeywordStaticURL
#
################################################################

is($archive->getKeywordStaticURL('foo'), '/home/mystories/keyword_foo.html', 'getKeywordStaticURL: returns absolute URL to keyword file');

$archive->update({ url => '/home/mystories.arch' });
is($archive->getKeywordStaticURL('bar'), '/home/mystories/keyword_bar.html', '... correct URL with file extension');

$archive->update({ url => '/home/mystories' });

################################################################
#
# sortOrder
#
################################################################

my $aaa_child = $archive->addChild({className => 'WebGUI::Asset::Story', title => 'Aaaa'}, @skipAutoCommit);
my $zzz_child = $archive->addChild({className => 'WebGUI::Asset::Story', title => 'Zzzz'}, @skipAutoCommit);
WebGUI::Test->addToCleanup($aaa_child);
WebGUI::Test->addToCleanup($zzz_child);

$archive->update({storiesPerPage => 25, storySortOrder => 'Alphabetically' });

$tag1 = WebGUI::VersionTag->getWorking($session);
$tag1->commit;
WebGUI::Test->addToCleanup($tag1);

$templateVars = $archive->viewTemplateVariables();

cmp_deeply (
    $templateVars->{date_loop},
    [
           {
             'story_loop' => [
                               {
                                 'creationDate' => ignore(),
                                 'deleteIcon' => ignore(),
                                 'editIcon' => ignore(),
                                 'url' => re('aaaa'),
                                 'title' => 'Aaaa'
                               },
                               ignore(),
                               ignore(),
                               ignore(),
                               ignore(),
                             ],
             'epochDate' => ignore(),
           },
           {
             'story_loop' => ignore(),
             'epochDate' => $wgBdayMorn,
           },
           {
             'story_loop' => ignore(),
             'epochDate' => $yesterdayMorn,
           },
          {
             'story_loop' => [
                               {
                                 'creationDate' => ignore(),
                                 'deleteIcon' => ignore(),
                                 'editIcon' => ignore(),
                                 'url' => re('zzzz'),
                                 'title' => 'Zzzz'
                               },
                             ],
             'epochDate' => ignore(),
           },
        ],
        'viewTemplateVariables: sorted by story title'
);

$creationDateSth->finish;
done_testing();

#----------------------------------------------------------------------------

sub simpleHrefParser {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);
    my @anchors = ();
    while (my $token = $p->get_tag('a')) {
        my $url = $token->[1]{href} || "-";
        my $label = $p->get_trimmed_text("/a");
        push @anchors, [ $label, $url ];
    }
    return @anchors;
}

sub fetchKeywordAssetList {
	my ($text) = @_;
    my @anchors = ();
	my $p = HTML::TokeParser->new(\$text);
    TOKEN: while (my $token = $p->get_tag('ul')) {
        next TOKEN unless $token->[1]->{class} eq 'keywordAssetList';
        while (my $token = $p->get_tag('/ul', 'a')) {
            last TOKEN if $token->[0] eq '/ul';
            my $url = $token->[1]{href} || "-";
            my $label = $p->get_trimmed_text("/a");
            push @anchors, [ $label, $url ];
        }
    }

    return @anchors;
}


