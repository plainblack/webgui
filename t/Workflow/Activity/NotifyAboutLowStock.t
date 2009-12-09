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
use URI;

plan tests => 15; # increment this value for each test you create

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $admin = $session->user;
my $inbox = WebGUI::Inbox->new($session);

my $import = WebGUI::Asset->getImportNode($session);

my $posters = $import->addChild({
    className => 'WebGUI::Asset::Sku::Product',
    url       => 'cell_posters',
    title     => "Red's Posters",
}, undef, undef, { skipAutoCommitWorkflows => 1, });

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
        quantity  => 5,
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
$threshold->set('subject'      , 'Threshold=10');
$threshold->set('warningLimit' , 10);

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
is($message->get('subject'), 'Threshold=10', 'Message has the right subject');
my @urls = split /\n/, $body;
is (scalar @urls, 1, 'Only one variant is below the threshold');
my $url = pop @urls;
my $uri = URI->new($url);
is($uri->path,  $posters->getUrl, 'Link in message has correct URL path');
is($uri->query, 'func=editVariant;vid='.$marilynVarId, 'Link in message has function and variant id');

wipeMessages($inbox, $admin);
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

END {
    $workflow->delete;
    $posters->purge;
    my $i = 0;
    wipeMessages($inbox, $admin);
    $messages = $inbox->getMessagesForUser($admin);
    is(scalar @{$messages}, 0, 'Inbox cleaned up');
    $session->db->write("delete from mailQueue where message like '%Threshold=10%'");
}

sub wipeMessages {
    my ($inbox, $user) = @_;
    foreach my $message (@{ $inbox->getMessagesForUser($user) }) {
        $message->delete;
    }

}
