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
use lib "$FindBin::Bin/../../lib";

##The goal of this test is to test the creation of Search Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 11; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::Search;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getDefault($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Search Test"});
addToCleanup($versionTag);
my $search = $node->addChild({className=>'WebGUI::Asset::Wobject::Search'});

# Test for a sane object type
isa_ok($search, 'WebGUI::Asset::Wobject::Search');

# Test to see if we can set new values
my $newSearchSettings = {
	templateId=>'testingtestingtesting1',
	searchRoot=>'testingtestingtesting2',
	classLimiter=>'WebGUI::Asset::Wobject::Article',
};
$search->update($newSearchSettings);

foreach my $newSetting (keys %{$newSearchSettings}) {
	is ($search->get($newSetting), $newSearchSettings->{$newSetting}, "updated $newSetting is ".$newSearchSettings->{$newSetting});
}

                 #1234567890123456789012#
my $templateId = '_FAUX_SEARCH_TEMPLATE_';

my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
$templateMock->set_true('prepare');
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

$search->update({
    searchRoot   => WebGUI::Asset->getDefault($session)->getId,
    classLimiter => '',
    templateId   => $templateId,
});

{

    $session->request->setup_body({
        doit     => 1,
        keywords => 'building + applications',
    });
    WebGUI::Test->mockAssetId($templateId, $templateMock);
    $search->prepareView;
    eval { $search->view; };
    ok(! $@, 'view did now error out on standalone regexp wildcard')
        or diag $@;
    $session->request->setup_body({
        keywords => 'building +applications',
    });
    eval { $search->view; };
    ok(! $@, 'view did now error out on prefix regexp wildcard')
        or diag $@;
    $session->request->setup_body({
        keywords => 'building applications*',
    });
    eval { $search->view; };
    ok(! $@, 'view did now error out on prefix regexp wildcard')
        or diag $@;
    WebGUI::Test->unmockAssetId($templateId);
    $session->request->setup_body({});

}

{
    my $versionTag2 = WebGUI::VersionTag->getWorking($session);
    $versionTag2->set({name=>"Collab setup"});
    my @addArgs = ( undef, undef, { skipAutoCommitWorkflows => 1, skipNotification => 1 } );
    my $collab = $node->addChild({
            className      => 'WebGUI::Asset::Wobject::Collaboration',
            editTimeout    => '1',
            threadsPerPage => 3,
        },
        @addArgs);
    # finally, add the post to the collaboration system
    my $props = {
        className   => 'WebGUI::Asset::Post::Thread',
        content     => 'verbosity shale anything',
        ownerUserId => 1,
    };

    my $thread = $collab->addChild($props, @addArgs);
    $versionTag2->commit();
    addToCleanup($versionTag2);

    $session->request->setup_body({
        doit     => 1,
        keywords => 'shale',
    });
    WebGUI::Test->mockAssetId($templateId, $templateMock);
    $search->prepareView;
    $search->view;
    $search->update({useContainers => 0});
    unlike $templateVars->{result_set}->[0]->{url}, qr{\?pn=\d}, 'search returns regular URL for a Thread';
    $search->update({useContainers => 1});
    $search->view;
    like $templateVars->{result_set}->[0]->{url}, qr{\?pn=\d}, 'search returns paginated URL for a Thread when useContainers=1';
    note Dumper $templateVars;

    WebGUI::Test->unmockAssetId($templateId);
    $session->request->setup_body({});
    $search->update({useContainers => 0});
}


TODO: {
        local $TODO = "Tests to make later";
        ok(0, 'Test prepareView method');
	ok(0, 'Test view method');
}
