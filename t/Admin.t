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
use lib "$FindBin::Bin/lib";
use JSON;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init

# Create a new admin plugin
package WebGUI::Admin::Plugin::Test;

use Moose;
use base 'WebGUI::Admin::Plugin';

has '+title' => ( default => "title" );
has '+icon' => ( default => "icon" );
has '+iconSmall' => ( default => "iconSmall" );
has 'test_config' => ( is => 'rw', default => 'default' );

sub canView { return 1; }
sub process { return { message => 'success' } }
sub www_view { return "view" }
sub www_test { return "test" }
sub www_config { return $_[0]->test_config }

package main;
BEGIN { $INC{'WebGUI/Admin/Plugin/Test.pm'} = __FILE__; }

my $session         = WebGUI::Test->session;
$session->user({ userId => 3 });

my $import          = WebGUI::Asset->getImportNode( $session );
# Add a couple admin plugins to the config file
WebGUI::Test->originalConfig( "adminConsole" );
$session->config->addToHash('adminConsole', 'test', {
    className       => 'WebGUI::Admin::Plugin::Test',
} );
$session->config->addToHash('adminConsole', 'test2', {
    url             => '?op=admin;plugin=test;method=config',
} );

# Add some assets
my $snip = $import->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    title           => 'test',
    groupIdEdit     => '3',
    synopsis        => "aReallyLongWordToGetIndexed",
    keywords        => "AKeywordToGetIndexed",
} );
$snip->commit;
addToCleanup( $snip );

#----------------------------------------------------------------------------
# Tests

my $output;

# Test www_ methods
my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get('/'); # Start a session
$mech->session->user({ userId => '3' });

# www_processAssetHelper
$mech->get_ok( '/?op=admin;method=processAssetHelper;className=WebGUI::AssetHelper::Cut;assetId=' . $snip->getId );
cmp_deeply( 
    JSON->new->decode( $mech->content ), 
    WebGUI::AssetHelper::Cut->process( $snip ),
    'www_processAssetHelper',
);

# www_processPlugin
$mech->get_ok( '/?op=admin;method=processPlugin;id=test' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    WebGUI::Admin::Plugin::Test->process( $session ),
    'Test plugin process()',
) || diag( $output );

# www_findUser
$mech->get_ok( '/?op=admin;method=findUser;query=Adm' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    { results => superbagof( superhashof( {
        userId      => 3,
    } ) ) },
    'found the Admin user',
) || diag( $output );

# www_getClipboard
$snip->cut;
$mech->get_ok( '/?op=admin;method=getClipboard' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    superbagof({
        assetId         => $snip->getId,
        url             => $snip->getUrl,
        title           => $snip->menuTitle,
        revisionDate    => $snip->revisionDate,
        icon            => $snip->getIcon("small"),
    }),
    'getClipboard found our snippet',
);

# www_getCurrentVersionTag
# no current tag
$mech->get_ok( '/?op=admin;method=getCurrentVersionTag' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    { },
    'www_getCurrentVersionTag no current version tag',
);
ok( !WebGUI::VersionTag->getWorking( $mech->session, "nocreate" ), "doesn't create a tag" );

# current tag
my $newtag = WebGUI::VersionTag->getWorking( $mech->session );
addToCleanup( $newtag );
$mech->get_ok( '/?op=admin;method=getCurrentVersionTag' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    {
        tagId       => $newtag->getId,
        name        => $newtag->get('name'),
        editUrl     => $newtag->getEditUrl,
        commitUrl   => $newtag->getCommitUrl,
        leaveUrl    => '?op=leaveVersionTag',
    },
    'www_getCurrentVersionTag',
);

# www_getVersionTags
$mech->get_ok( '/?op=admin;method=getVersionTags' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    superbagof( {
        tagId       => $newtag->getId,
        name        => $newtag->get("name"),
        isCurrent   => 1,
        joinUrl     => $newtag->getJoinUrl,
        editUrl     => $newtag->getEditUrl,
        icon        => $session->url->extras( 'icon/tag_green.png' ),
    } ),
    'www_getVersionTags',
);

# www_getTreeData
$mech->get_ok( '/?op=admin;method=getTreeData;assetUrl=' . $import->url );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    {
        totalAssets     => $import->getChildCount,
        sort            => ignore(),
        dir             => ignore(),
        assets          => [
            map { {
                assetId         => $_->getId,
                url             => $_->getUrl,
                lineage         => $_->lineage,
                title           => $_->menuTitle,
                revisionDate    => $_->revisionDate,
                childCount      => $_->getChildCount,
                assetSize       => $_->assetSize,
                lockedBy        => ($_->isLockedBy ? $_->lockedBy->username : ''),
                canEdit         => $_->canEdit && $_->canEditIfLocked,
                helpers         => $_->getHelpers,
                icon            => $_->getIcon("small"),
                className       => $_->getName,
            } } @{ $import->getLineage( ['children'], { returnObjects => 1, maxAssets => 25 } ) }
        ],
        currentAsset    => {
            assetId => $import->getId,
            url     => $import->getUrl,
            title   => $import->getTitle,
            icon    => $import->getIcon("small"),
            helpers => $import->getHelpers,
        },
        crumbtrail      => [
            map { { title => $_->getTitle, url => $_->getUrl } } 
                @{ $import->getLineage( ['ancestors'], { returnObjects => 1 } ) }
        ],
    },
    'www_getTreeData',
);

# www_searchAssets
$mech->get_ok( '/?op=admin;method=searchAssets;query=aReallyLongWordToGetIndexed' );
$output = $mech->content;
cmp_deeply(
    JSON->new->decode( $output ),
    {
        totalAssets     => 1,
        sort            => undef,
        dir             => "",
        assets          => [
            {
                assetId         => $snip->getId,
                url             => $snip->getUrl,
                lineage         => $snip->lineage,
                title           => $snip->menuTitle,
                revisionDate    => $snip->revisionDate,
                childCount      => $snip->getChildCount,
                assetSize       => $snip->assetSize,
                lockedBy        => ($snip->isLockedBy ? $snip->lockedBy->username : ''),
                canEdit         => $snip->canEdit && $snip->canEditIfLocked,
                helpers         => $snip->getHelpers,
                icon            => $snip->getIcon('small'),
                className       => $snip->getName,
            }
        ],
    },
    'www_searchAssets',
);


done_testing;

#vim:ft=perl
