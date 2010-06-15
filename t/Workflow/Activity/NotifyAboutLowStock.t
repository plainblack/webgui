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

use WebGUI::Test;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Product;
use WebGUI::Workflow::Activity::NotifyAboutLowStock;
use WebGUI::Inbox;

use Data::Dumper;
use Test::More;
use Test::Exception;
use URI;

plan tests => 19; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $admin = $session->user;
WebGUI::Test->addToCleanup(sub { WebGUI::Test->cleanupAdminInbox; });
WebGUI::Test->addToCleanup(SQL =>  "delete from mailQueue  where message like '%Threshold=15%'");
my $inbox = WebGUI::Inbox->new($session);

my $import = WebGUI::Asset->getImportNode($session);

my $posters = $import->addChild({
    className => 'WebGUI::Asset::Sku::Product',
    url       => 'cell_posters',
    title     => "Red's Posters",
}, undef, time()-15, { skipAutoCommitWorkflows => 1, });

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->commit();
addToCleanup($versionTag);

my $ritaVarId = $posters->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Rita Hayworth',
        varSku    => 'rita-1',
        price     => 10,
        weight    => 1,
        quantity  => 25,
    },
);

my $raquelVarId = $posters->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Raquel Welch',
        varSku    => 'fuzzy-britches',
        price     => 20,
        weight    => 1,
        quantity  => 500,
    },
);

my $marilynVarId = $posters->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Marilyn Monroe',
        varSku    => 'subway-skirt',
        price     => 50,
        weight    => 1,
        quantity  => 10,
    },
);

my $workflow  = WebGUI::Workflow->create($session,
    {
        enabled    => 1,
        objectType => 'None',
        mode       => 'realtime',
    },
);
addToCleanup($workflow);

my $threshold = $workflow->addActivity('WebGUI::Workflow::Activity::NotifyAboutLowStock');
$threshold->set('className'    , 'WebGUI::Activity::NotifyAboutLowStock');
$threshold->set('toGroup'      , 3);
$threshold->set('subject'      , 'Threshold=15');
$threshold->set('warningLimit' , 15);

my $instance1 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);

my $retVal;

$retVal = $instance1->run();
is($retVal, 'complete', 'First workflow was run');
$retVal = $instance1->run();
is($retVal, 'done', 'Workflow is done');

is($instance1->getScratch('LowStockMessage'), undef, 'No scratch data for message');
is($instance1->getScratch('LowStockLast'),    undef, 'No scratch data for last index');

my $messages = $inbox->getMessagesForUser($admin);
is(scalar @{$messages}, 1, 'Received one message');

my $message = $messages->[0];

my $body = $message->get('message');
is($message->get('subject'), 'Threshold=15', 'Message has the right subject');
my @table = split /\n/, $body;
my @urls = @table[2..$#table];
pop @urls;
is (scalar @urls, 1, 'Only one variant is below the threshold');
my $url = pop @urls;
$url =~ s/^.+?href="([^"]+)".+$/$1/;
my $uri = URI->new($url);
is($uri->path,  $posters->getUrl, 'Link in message has correct URL path');
is($uri->query, 'func=editVariant;vid='.$marilynVarId, 'Link in message has function and variant id');

WebGUI::Test->cleanupAdminInbox;
is(scalar @{$inbox->getMessagesForUser($admin)}, 0, 'All messages deleted');
$instance1->delete;

##Now, change the threshold and make sure that we get no messages
$threshold->set('warningLimit', 2);
is($threshold->get('warningLimit'), 2, 'Reset warningLimit to 2');

my $instance2 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);

$retVal = $instance2->run();
is($retVal, 'complete', 'The workflow was run the second time');
$retVal = $instance2->run();
is($retVal, 'done', 'Workflow is done the second time');
is(scalar @{$inbox->getMessagesForUser($admin)}, 0, 'No messages sent since threshold is below quantity of all products');

$message = $inbox->getMessagesForUser($admin)->[0];

note "Test that the workflow does not die when encountering bad assets";

my $otherPosters = $posters->duplicate;
WebGUI::Test->addToCleanup(sub {
    $session->db->write("delete from asset      where assetId=?",[$otherPosters->getId]);
    $session->db->write("delete from assetData  where assetId=?",[$otherPosters->getId]);
    $session->db->write("delete from sku        where assetId=?",[$otherPosters->getId]);
    $session->db->write("delete from Product    where assetId=?",[$otherPosters->getId]);
    $session->db->write("delete from assetIndex where assetId=?",[$otherPosters->getId]);
});
my $movie_posters = $import->addChild({
    className => 'WebGUI::Asset::Sku::Product',
    url       => 'movie_posters',
    title     => "Movie Posters",
}, undef, undef, { skipAutoCommitWorkflows => 1, });

my $movieVarId = $movie_posters->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Shawshank Redemption',
        varSku    => 'shawshank-1',
        price     => 10,
        weight    => 1,
        quantity  => 5,
    },
);
my $otherTag     = WebGUI::VersionTag->getWorking($session);
addToCleanup($otherTag);
$otherTag->commit;

$threshold->set('warningLimit' , 10);
my $instance3 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);

$retVal = $instance3->run();
$retVal = $instance3->run();
is($retVal, 'done', 'Workflow is done');

$messages = $inbox->getMessagesForUser($admin);
is(scalar @{$messages}, 1, 'Received one message');
WebGUI::Test->cleanupAdminInbox;

my $instance4 = WebGUI::Workflow::Instance->create($session,
    {
        workflowId              => $workflow->getId,
        skipSpectreNotification => 1,
    }
);
#break the asset
$session->db->write('delete from asset where assetId=?', [$otherPosters->getId]);
is(WebGUI::Asset->new($session, $otherPosters->getId), undef, 'middle asset broken');

$retVal = $instance4->run();
$retVal = $instance4->run();
is($retVal, 'done', 'Workflow is done');

$messages = $inbox->getMessagesForUser($admin);
is(scalar @{$messages}, 1, 'Still received one message');

#vim:ft=perl
