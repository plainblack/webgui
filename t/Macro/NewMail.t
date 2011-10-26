#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Macro::NewMail;
use WebGUI::Inbox;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $numTests = 3;

plan tests => $numTests;

my $inboxUser = WebGUI::User->create($session);
$session->user({userId => $inboxUser->getId});
WebGUI::Test->addToCleanup($inboxUser);

my $inbox = WebGUI::Inbox->new($session);

is(WebGUI::Macro::NewMail::process($session), '', 'NewMail macro returns "" if user has no messages');

$inbox->addMessage(
    {
        userId  => $inboxUser->getId,
        subject => 'test message 1',
        message => 'test message 1',
    },
    {
        no_email => 1,
    },
);
$inbox->addMessage(
    {
        userId  => $inboxUser->getId,
        subject => 'test message 2',
        message => 'test message 2',
    },
    {
        no_email => 1,
    },
);

like(
    WebGUI::Macro::NewMail::process($session),
    qr{<a href=".+?op=account;module=inbox">.+?</a>},
    q{... returns URL to view user's inbox}
);

like(
    WebGUI::Macro::NewMail::process($session, "cssClass"),
    qr{<a href=".+?op=account;module=inbox"\s+class="cssClass">.+?</a>},
    q{... returns URL to view user's inbox}
);
