#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

## Test that trashing a post works, and checking side effects like updating
## lastPost information in the Thread, and CS.

use strict;
use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 9; # increment this value for each test you create
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Post;
use WebGUI::Asset::Post::Thread;
use Mail::Send;
use Data::Dumper;
use Encode;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

# Grab a named version tag
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Collab setup"});

# Need to create a Collaboration system in which the post lives.
my @addArgs = ( undef, undef, { skipAutoCommitWorkflows => 1, skipNotification => 1 } );

my $notification_template = $node->addChild({
    className => 'WebGUI::Asset::Template',
    template  => "<body>!!!url:<tmpl_var url>!!!content:<tmpl_var content>!!!</body>",
}, @addArgs);

my $collab = $node->addChild({
    className => 'WebGUI::Asset::Wobject::Collaboration',
    notificationTemplateId => $notification_template->getId,
}, @addArgs);

# finally, add posts and threads to the collaboration system

my $first_thread = $collab->addChild( { className   => 'WebGUI::Asset::Post::Thread', }, @addArgs);

##Thread 1, Post 1 => t1p1
my $title = "H\x{00E4}ufige Fragen";
utf8::upgrade($title);
my $content = "Ba\x{00DF}";
utf8::upgrade($content);
my $t1p1 = $first_thread->addChild(
    {
        className   => 'WebGUI::Asset::Post',
        title       => $title,
        url         => lc $title,
        content     => $content,
    },
    @addArgs
);
$t1p1->setSkipNotification;

$versionTag->commit();
WebGUI::Test->addToCleanup($versionTag);

is $t1p1->get('title'), "H\x{00E4}ufige Fragen", "utf8 in title set correctly";
is $t1p1->get('url'),   "h\x{00E4}ufige-fragen", "... in url";
is $t1p1->get('content'), "Ba\x{00DF}", "... in content";

foreach my $asset ($collab, $first_thread, $t1p1, ) {
    $asset = $asset->cloneFromDb;
}

is $t1p1->get('title'), "H\x{00E4}ufige Fragen", "utf8 title pulled correctly from db";
is $t1p1->get('url'),   "h\x{00E4}ufige-fragen", "... and url";
is $t1p1->get('content'), "Ba\x{00DF}", "... and content";

$t1p1->notifySubscribers();

my $messageIds = $session->db->buildArrayRef("select messageId from mailQueue where message like '%cs-".$t1p1->getId."%'");

is @{ $messageIds }, 2, 'two email messages sent, one for cs, one for thread';

WebGUI::Test->addToCleanup(SQL => 'delete from mailQueue where messageId IN ('. $session->db->quoteAndJoin($messageIds).')');

my $message1 = WebGUI::Mail::Send->retrieve($session, $messageIds->[0]);
my $subject = $message1->getMimeEntity->head->get('Subject');
$subject = decode('MIME-Q', $subject);
chomp $subject;
is $subject, "H\x{00E4}ufige Fragen", 'subject has correct UTF8 phrase';
my $body = $message1->getMimeEntity->parts(0)->bodyhandle->as_string;  ##comes out decoded for us
my ($url, $content) = $body =~ /!!!url:([^!]+)!!!content:([^!]+)!!!/;
my $expected_url = $session->url->getSiteURL . "/h\x{00E4}ufige-fragen";
utf8::encode($expected_url);
is $url,
    $expected_url,
    'url UTF8 checks out';

#vim:ft=perl

