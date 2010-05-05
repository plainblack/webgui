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

# Test the featured page of the Wiki
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Differences;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $import          = WebGUI::Asset->getImportNode( $session );

my @childCoda = (undef, undef, { skipAutoCommitWorkflows => 1, skipNotification => 1, } );
my @revCoda   = (undef,        { skipAutoCommitWorkflows => 1, skipNotification => 1, } );

my $wiki
    = $import->addChild( {
        className        => 'WebGUI::Asset::Wobject::WikiMaster',
        topLevelKeywords => 'criminals,inmates,staff',
        url              => 'testwiki',
        title            => 'testwiki',
    }, @childCoda );

my $wikitag = WebGUI::VersionTag->getWorking( $session );
$wikitag->commit;
WebGUI::Test->addToCleanup($wikitag);
$wiki = $wiki->cloneFromDb;

my %page_set = ();

foreach my $keywords (qw/staff inmates criminals/) {
    $page_set{$keywords} = $wiki->addChild({
        className => 'WebGUI::Asset::WikiPage',
        title     => $keywords,
    }, @childCoda);
}

my $tag_set1 = WebGUI::VersionTag->getWorking($session);
$tag_set1->commit;
WebGUI::Test->addToCleanup($tag_set1);


#----------------------------------------------------------------------------
# Tests

plan tests => 11;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# 

is $wiki->get('topLevelKeywords'), 'criminals,inmates,staff', 'checking wiki setup';
cmp_deeply($wiki->getTopLevelKeywordsList, [qw/criminals inmates staff/], 'getTopLevelKeywordList returns keywords');

cmp_deeply(
    $wiki->getKeywordHierarchy(),
    [
        superhashof({ title => 'criminals', }),
        superhashof({ title => 'inmates', }),
        superhashof({ title => 'staff', }),
    ],
    "getKeywordHierarchy, simple setup",
);

my $hierarchy = $wiki->getKeywordHierarchy();
my $variables = $wiki->getKeywordVariables($hierarchy);

cmp_deeply(
    $hierarchy->[0],
    {
        title       => 'criminals',
        url         => '/testwiki?func=byKeyword;keyword=criminals',
        descendants => 0,
    },
    "getKeywordVariables, does not alter the original hierarchy passed in",
);

cmp_deeply(
    $variables,
    [
        {
            title => 'criminals',
            url   => '/testwiki?func=byKeyword;keyword=criminals',
            level => 0,
            indent_loop => [],
            descendants => 0,
            isTopLevel  => 1,
        },
        {
            title => 'inmates',
            url   => '/testwiki?func=byKeyword;keyword=inmates',
            level => 0,
            indent_loop => [],
            descendants => 0,
            isTopLevel  => 1,
        },
        {
            title => 'staff',
            url   => '/testwiki?func=byKeyword;keyword=staff',
            level => 0,
            indent_loop => [],
            descendants => 0,
            isTopLevel  => 1,
        },
    ],
    "... variables",
);

$wiki->update({topLevelKeywords => 'criminals,criminals,inmates,staff'});

is $wiki->get('topLevelKeywords'), 'criminals,criminals,inmates,staff', 'checking wiki setup 2';
cmp_deeply($wiki->getTopLevelKeywordsList, [qw/criminals criminals inmates staff/], 'getTopLevelKeywordList returns keywords, even with duplicates');

cmp_deeply(
    $wiki->getKeywordHierarchy(),
    [
        superhashof({ title => 'criminals', }),
        superhashof({ title => 'criminals', }),
        superhashof({ title => 'inmates', }),
        superhashof({ title => 'staff', }),
    ],
    "getKeywordHierarchy, simple setup, duplicates listed",
);

$wiki->update({topLevelKeywords => 'criminals,inmates,staff'});
$wiki->setSubKeywords('criminals', 'red', 'andy');
$wiki->setSubKeywords('inmates', 'brooks', 'heywood');
$wiki->setSubKeywords('staff', 'norton', 'hadley');

foreach my $title (qw/red andy brooks heywood norton hadley/) {
    $page_set{$title} = $wiki->addChild({
        className => 'WebGUI::Asset::WikiPage',
        title     => $title,
    }, @childCoda);
}

my $tag_set2 = WebGUI::VersionTag->getWorking($session);
$tag_set2->commit;
WebGUI::Test->addToCleanup($tag_set2);

cmp_bag(
    $wiki->getKeywordHierarchy(),
    [
        {
            title => 'criminals', url   => '/testwiki?func=byKeyword;keyword=criminals',
            children => bag(
                superhashof({ title => 'red', }),
                superhashof({ title => 'andy', }),
            ),
            descendants => 0,
        },
        {
            title => 'inmates', url   => '/testwiki?func=byKeyword;keyword=inmates',
            children => bag(
                superhashof({ title => 'heywood', }),
                superhashof({ title => 'brooks', }),
            ),
            descendants => 0,
        },
        {
            title => 'staff', url   => '/testwiki?func=byKeyword;keyword=staff',
            children => bag(
                superhashof({ title => 'norton', }),
                superhashof({ title => 'hadley', }),
            ),
            descendants => 0,
        },
    ],
    "getKeywordHierarchy: simple hierarchy",
);

##Check depth-first display, and try to make a keyword loop
$wiki->setSubKeywords('andy', 'criminals', 'inmates');
$wiki->setSubKeywords('brooks', 'criminals');

my $tag_set3 = WebGUI::VersionTag->getWorking($session);
$tag_set3->commit;
WebGUI::Test->addToCleanup($tag_set3);

cmp_bag(
    $wiki->getKeywordHierarchy(),
    [
        superhashof({
            title    => 'criminals',
            children => bag(
                superhashof({
                    title    => 'andy',
                    children => bag(
                        superhashof({
                            title => 'inmates',
                            children => bag(
                                superhashof({ title => 'heywood', }),
                                superhashof({
                                    title    => 'brooks',
                                    children => bag(
                                        superhashof({ title => 'criminals', }),
                                    ),
                                }),
                            ),
                        }),
                        superhashof({ title => 'criminals', }),
                    ),
                }),
                superhashof({ title => 'red', }),
            ),
        }),
        superhashof({
            title    => 'inmates',
        }),
        superhashof({
            title    => 'staff',
            children => bag(
                superhashof({ title => 'norton', }),
                superhashof({ title => 'hadley', }),
            ),
        }),
    ],
    "getKeywordHierarchy: complex hierarcy, depth-first display and loop handling",
);

cmp_deeply(
    $wiki->getKeywordVariables([
        {
            title => 'title 0', url   => 'url 0',
            children => [ {
                    title => 'title 1', url   => 'url 1',
                    children => [ {
                            title => 'title 2', url   => 'url 2',
                    }, ],
            }, ],
        },
    ]),
    [
        {   title => 'title 0', url   => 'url 0', level => 0, isTopLevel => 1,  indent_loop => [], },
        {   title => 'title 1', url   => 'url 1', level => 1, isTopLevel => '', indent_loop => [{indent => 1}], },
        {   title => 'title 2', url   => 'url 2', level => 2, isTopLevel => '', indent_loop => [{indent => 1,}, {indent => 2,},], },
    ],
    'getKeywordVariables: checking deeply'
);

$page_set{criminals}->update({keywords => 'red,andy,tommy'});

#vim:ft=perl
