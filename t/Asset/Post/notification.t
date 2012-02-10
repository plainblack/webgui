#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use Test::More tests => 12; # increment this value for each test you create
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Post;
use WebGUI::Asset::Post::Thread;
use Mail::Send;
use Data::Dumper;
use Encode;

my $session = WebGUI::Test->session;

# Grab a named version tag
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Collab setup"});
WebGUI::Test->addToCleanup($versionTag);

# Need to create a Collaboration system in which the post lives.
my @addArgs = ( undef, undef, { skipAutoCommitWorkflows => 1, skipNotification => 1 } );

my $notification_template = WebGUI::Test->asset(
    className => 'WebGUI::Asset::Template',
    template  => "<body>!!!url:<tmpl_var url>!!!content:<tmpl_var content>!!!</body>",
    parser    => 'WebGUI::Asset::Template::HTMLTemplate',
);

my $collab = WebGUI::Test->asset(
    className => 'WebGUI::Asset::Wobject::Collaboration',
    notificationTemplateId => $notification_template->getId,
);

# finally, add posts and threads to the collaboration system

my $first_thread = $collab->addChild( { className   => 'WebGUI::Asset::Post::Thread', }, @addArgs);
$first_thread->setSkipNotification;

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

my $before_copy = $session->db->quickScalar('select count(*) from mailQueue');

{

    ##Disable sending email
    my $sendmock = Test::MockObject->new( {} );
    $sendmock->set_isa('WebGUI::Mail::Send');
    $sendmock->set_true('addText', 'send', 'addHeaderField', 'addHtml', 'queue', 'addFooter');
    my $was_sent   = 0;
    my $was_queued = 0;
    $sendmock->set_bound('send',  $was_sent);
    $sendmock->set_bound('queue', $was_queued);
    local *WebGUI::Mail::Send::create;
    $sendmock->fake_module('WebGUI::Mail::Send',
        create => sub { return $sendmock },
    );

    my $t1p1_copy = $t1p1->duplicate();
    WebGUI::Test->addToCleanup($t1p1_copy);
    is $was_sent,   0, 'email not sent when Post is duplicated';
    is $was_queued, 0, '... nor queued';
    my $after_copy = $session->db->quickScalar('select count(*) from mailQueue');
    is $after_copy, $before_copy, '... and no additional mails in the queue';
}

#vim:ft=perl

