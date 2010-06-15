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

# This script tests the creation, sending, and queuing of mail messages
# TODO: There is plenty left to do in this script.
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use JSON qw( from_json to_json );
use Test::More;
use Test::Deep;
use Data::Dumper;
use MIME::Parser;
use Encode qw/decode encode/;

use WebGUI::Test;

use WebGUI::Mail::Send;

$| = 1;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $mail;       # The WebGUI::Mail::Send object
my $mime;       # for getMimeEntity

# See if we have an SMTP server to use
my $hasServer   = 0;
eval { WebGUI::Test->prepareMailServer; $hasServer = 1 };
if ( $@ ) { diag( "Can't prepare mail server: $@" ) }

#----------------------------------------------------------------------------
# Tests

plan tests => 33;        # Increment this number for each test you create

WebGUI::Test->addToCleanup(SQL => 'delete from mailQueue');

#----------------------------------------------------------------------------
# Test create
$mail   = WebGUI::Mail::Send->create( $session );
isa_ok( $mail, 'WebGUI::Mail::Send',
    "WebGUI::Mail::Send->create returns a WebGUI::Mail::Send object",
);

# Test that getMimeEntity works
$mime    = $mail->getMimeEntity;
isa_ok( $mime, 'MIME::Entity',
    "getMimeEntity",
);

# Test that create gets the appropriate defaults
# TODO

#----------------------------------------------------------------------------
# Test addText
$mail   = WebGUI::Mail::Send->create( $session );
my $text = <<'EOF';
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Suspendisse eu lacus ut ligula fringilla elementum. Cras condimentum, velit commodo pretium semper, odio ante accumsan orci, a ultrices risus justo a nulla. Aliquam erat volutpat. 
EOF

$mail->addText($text);
$mime   = $mail->getMimeEntity;

# addText should add newlines after 78 characters
my $newlines    = length $text / 78;
is( $mime->parts(0)->as_string =~ m/\n/, $newlines,
    "addText should add newlines after 78 characters",
);

is ( $mime->parts(0)->effective_type, 'text/plain', '... sets the correct MIME type' );

#----------------------------------------------------------------------------
# Test addHtml
$mail   = WebGUI::Mail::Send->create( $session );
$text = <<'EOF';
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Suspendisse eu lacus ut ligula fringilla elementum. Cras condimentum, velit commodo pretium semper, odio ante accumsan orci, a ultrices risus justo a nulla. Aliquam erat volutpat. 
EOF

$mail->addHtml($text);
$mime   = $mail->getMimeEntity;

# TODO: Test that addHtml creates an HTML wrapper if no html or body tag exists

# addHtml should add newlines after 78 characters
$newlines    = length $text / 78;
is( $mime->parts(0)->as_string =~ m/\n/, $newlines,
    "addHtml should add newlines after 78 characters",
);
is ( $mime->parts(0)->effective_type, 'text/html', '... sets the correct MIME type' );

# TODO: Test that addHtml does not create an HTML wrapper if html or body tag exist

#----------------------------------------------------------------------------
# Test addHtmlRaw
$mail   = WebGUI::Mail::Send->create( $session );
$text = <<'EOF';
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Suspendisse eu lacus ut ligula fringilla elementum. Cras condimentum, velit commodo pretium semper, odio ante accumsan orci, a ultrices risus justo a nulla. Aliquam erat volutpat. 
EOF

$mail->addHtmlRaw($text);
$mime   = $mail->getMimeEntity;

# TODO: Test that addHtmlRaw doesn't add an HTML wrapper

# addHtmlRaw should add newlines after 78 characters
$newlines    = length $text / 78;
is( $mime->parts(0)->as_string =~ m/\n/, $newlines,
    "addHtmlRaw should add newlines after 78 characters",
);

use utf8;
$mail = WebGUI::Mail::Send->create( $session, {
    to      => 'norton@localhost',
    subject => "H\x{00C4}ufige Fragen",
});
$mail->addHeaderField('List-ID', "H\x{00C4}ufige Fragen");
my $messageId = $mail->queue;
my $dbMail = WebGUI::Mail::Send->retrieve($session, $messageId);
is($dbMail->getMimeEntity->head->get('List-ID'), "=?UTF-8?Q?H=C3=84ufige=20Fragen?=\n", 'addHeaderField: handles utf-8 correctly');

{
    my $mail = WebGUI::Mail::Send->create( $session );
    ok ! $mail->{_footerAdded}, 'footerAdded flag set to false by default';
    $mail->addFooter;
    ok   $mail->{_footerAdded}, '... flag set after calling addFooter';
    my $number_of_parts;
    $number_of_parts = $mail->getMimeEntity->parts;
    is $number_of_parts, 1, '... added 1 part for a footer';
    $mail->addFooter;
    ok   $mail->{_footerAdded}, '... flag still set after calling addFooter again';
    $number_of_parts = $mail->getMimeEntity->parts;
    is $number_of_parts, 1, '... 2nd footer not added';

}

{
    my $mail = WebGUI::Mail::Send->create( $session );
    $mail->addText('some text');
    $mail->addFooter;
    my $number_of_parts;
    $number_of_parts = $mail->getMimeEntity->parts;
    is $number_of_parts, 1, 'addFooter did not add any other parts';
    my $body = $mail->getMimeEntity->parts(0)->as_string;
    $body =~ s/\A.+?(?=some text)//s;
    is $body, "some text\n\nMy Company\ninfo\@mycompany.com\nhttp://www.mycompany.com\n", '... footer appended to the first part as text';
}

{
    my $mail = WebGUI::Mail::Send->create( $session );
    $mail->addHtml('some <b>markup</b>');
    $mail->addFooter;
    my $number_of_parts;
    $number_of_parts = $mail->getMimeEntity->parts;
    is $number_of_parts, 1, 'addFooter did not add any other parts';
    my $body = $mail->getMimeEntity->parts(0)->as_string;
    $body =~ s/\A.+?<body>\n//sm;
    $body =~ s!</body>.+\Z!!sm;
    is $body, "some <b>markup</b>\n<br />\n<br />\nMy Company<br />\ninfo\@mycompany.com<br />\nhttp://www.mycompany.com<br />\n", '... footer appended to the first part as text';
}

{
    my $mail = WebGUI::Mail::Send->create( $session );
    $mail->addText('This is a textual email');
    my $result = $mail->getMimeEntity->is_multipart;
    ok(defined $result &&   $result, 'by default, we make multipart messages');
}

my $smtpServerOk = 0;

#----------------------------------------------------------------------------
# Test emailOverride
SKIP: {
    my $numtests        = 2; # Number of tests in this block

    # Must be able to write the config, or we'll die
    if ( !-w File::Spec->catfile( WebGUI::Test::root, 'etc', WebGUI::Test::file() ) ) {
        skip "Cannot test emailOverride: Can't write new configuration value", $numtests;
    }

    # Must have an SMTP server, or it's pointless
    if ( !$hasServer ) {
        skip "Cannot test emailOverride: Module Net::SMTP::Server not loaded!", $numtests;
    }

    sleep 1;
    $smtpServerOk = 1;

    # Override the emailOverride
    my $oldEmailOverride   = $session->config->get('emailOverride');
    $session->config->set( 'emailOverride', 'dufresne@localhost' );

    # Send the mail
    my $mail
        = WebGUI::Mail::Send->create( $session, { 
            to      => 'norton@localhost',
        } );
    $mail->addText( 'His judgement cometh and that right soon.' );

    $mail->send;
    my $received = WebGUI::Test->getMail;

    if (!$received) {
        skip "Cannot test emailOverride: No response received from smtpd", $numtests;
    }

    # Test the mail
    like( $received->{to}->[0], qr/dufresne\@localhost/,
        "Email TO: address is overridden",
    );

    my $parser         = MIME::Parser->new();
    $parser->output_to_core(1);
    my $parsed_message = $parser->parse_data($received->{contents});
    my $head           = $parsed_message->head;
    my $messageId      = decode('MIME-Header', $head->get('Message-Id'));
    like ($messageId, qr/^<WebGUI-([a-zA-Z0-9\-_]){22}@\w+\.\w{2,4}>$/, 'Message-Id is valid');

    # Restore the emailOverride
    $session->config->set( 'emailOverride', $oldEmailOverride );
}

SKIP: {
    my $numtests        = 4; # Number of tests in this block

    skip "Cannot test message ids", $numtests unless $smtpServerOk;

    # Send the mail
    my $mail
        = WebGUI::Mail::Send->create( $session, { 
            to        => 'norton@localhost',
        } );
    $mail->addText( "I understand you're a man who knows how to get things." );

    $mail->send;
    my $received = WebGUI::Test->getMail;

    if (!$received) {
        skip "Cannot test messageIds: No response received from smtpd", $numtests;
    }

    # Test the mail
    my $parser         = MIME::Parser->new();
    $parser->output_to_core(1);
    my $parsed_message = $parser->parse_data($received->{contents});
    my $head           = $parsed_message->head;
    my $messageId      = decode('MIME-Header', $head->get('Message-Id'));
    chomp $messageId;
    like ($messageId, qr/^<WebGUI-([a-zA-Z0-9\-_]){22}@\w+\.\w{2,4}>$/, 'generated Message-Id is valid');

    # Send the mail
    $mail
        = WebGUI::Mail::Send->create( $session, { 
            to        => 'norton@localhost',
            messageId => '<leadingAngleOnly@localhost.localdomain',
        } );
    $mail->addText( "What say you there, fuzzy-britches? Feel like talking?" );

    $mail->send;
    $received = WebGUI::Test->getMail;

    $parsed_message = $parser->parse_data($received->{contents});
    $head           = $parsed_message->head;
    $messageId      = decode('MIME-Header', $head->get('Message-Id'));
    chomp $messageId;
    is($messageId, '<leadingAngleOnly@localhost.localdomain>', 'bad messageId corrected (added ending angle)');

    # Send the mail
    $mail
        = WebGUI::Mail::Send->create( $session, { 
            to        => 'norton@localhost',
            messageId => 'endingAngleOnly@localhost.localdomain>',
        } );
    $mail->addText( "Dear Warden, You were right. Salvation lies within." );

    $mail->send;
    $received = WebGUI::Test->getMail;

    $parsed_message = $parser->parse_data($received->{contents});
    $head           = $parsed_message->head;
    $messageId      = decode('MIME-Header', $head->get('Message-Id'));
    chomp $messageId;
    is($messageId, '<endingAngleOnly@localhost.localdomain>', 'bad messageId corrected (added starting angle)');

    # Send the mail
    $mail
        = WebGUI::Mail::Send->create( $session, { 
            to        => 'red@localhost',
            messageId => 'noAngles@localhost.localdomain',
        } );
    $mail->addText( "Neither are they. You have to be human first. They don't qualify." );

    $mail->send;
    $received = WebGUI::Test->getMail;

    $parsed_message = $parser->parse_data($received->{contents});
    $head           = $parsed_message->head;
    $messageId      = decode('MIME-Header', $head->get('Message-Id'));
    chomp $messageId;
    is($messageId, '<noAngles@localhost.localdomain>', 'bad messageId corrected (added both angles)');

}

#----------------------------------------------------------------------------
#
# Test sending an Inbox message to a user who has various notifications configured
#
#----------------------------------------------------------------------------

my $inboxUser = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($inboxUser);
$inboxUser->username('red');
$inboxUser->profileField('receiveInboxEmailNotifications', 1);
$inboxUser->profileField('receiveInboxSmsNotifications',   0);
$inboxUser->profileField('email',     'ellis_boyd_redding@shawshank.gov');
$inboxUser->profileField('cellPhone', '55555');
$session->setting->set('smsGateway', 'textme.com');

my $emailUser = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($emailUser);
$emailUser->username('heywood');
$emailUser->profileField('email', 'heywood@shawshank.gov');

my $lonelyUser = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($lonelyUser);
$lonelyUser->profileField('receiveInboxEmailNotifications', 0);
$lonelyUser->profileField('email',   'jake@shawshank.gov');

my $inboxGroup = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($inboxGroup);
$inboxGroup->addUsers([$emailUser->userId, $inboxUser->userId, $lonelyUser->userId]);

SKIP: {
    my $numtests        = 1; # Number of tests in this block

    # Must be able to write the config, or we'll die
    skip "Cannot test email notifications", $numtests unless $smtpServerOk;

    # Send the mail
    $mail = WebGUI::Mail::Send->create( $session, { 
            toUser  => $inboxUser->userId,
            },
            'fromInbox',
    );
    $mail->addText( 'sent via email' );

    $mail->send;
    my $received = WebGUI::Test->getMail;

    # Test the mail
    is($received->{to}->[0], '<ellis_boyd_redding@shawshank.gov>', 'send, toUser with email address');
}

#----------------------------------------------------------------------------
#
# Test sending an Inbox message to a group with various user profile settings
#
#----------------------------------------------------------------------------

my @mailIds;
@mailIds = $session->db->buildArray('select messageId from mailQueue');
my $startingMessages = scalar @mailIds;

$mail = WebGUI::Mail::Send->create( $session, { 
        toGroup  => $inboxGroup->getId,
        },
        'fromInbox',
);
$mail->addText('Mail::Send test message');
@mailIds = $session->db->buildArray('select messageId from mailQueue');
is(scalar @mailIds, $startingMessages, 'creating a message does not queue a message');

$mail->send;
@mailIds = $session->db->buildArray('select messageId from mailQueue');
is(scalar @mailIds, $startingMessages+2, 'sending a message with a group added two messages');

@mailIds = $session->db->buildArray("select messageId from mailQueue where message like ?",['%Mail::Send test message%']);
is(scalar @mailIds, 2, 'sending a message with a group added the right two messages');

my @emailAddresses = ();
foreach my $mailId (@mailIds) {
    my $mail = WebGUI::Mail::Send->retrieve($session, $mailId);
    push @emailAddresses, $mail->getMimeEntity->head->get('to');
}

cmp_bag(
    \@emailAddresses,
    [
        'heywood@shawshank.gov'."\n",
        'ellis_boyd_redding@shawshank.gov'."\n",
    ],
    'send: when the original is sent, new messages are created for each user in the group, following their user profile settings'
);

SKIP: {
    my $numtests = 2; # Number of tests in this block

    skip "Cannot test making emails single part", $numtests unless $smtpServerOk;

    # Send the mail
    my $mail
        = WebGUI::Mail::Send->create( $session, { 
            to        => 'norton@localhost',
        } );
    $mail->addText("They say it has no memory. That's where I want to live the rest of my life. A warm place with no memory.");

    ok ($mail->getMimeEntity->is_multipart, 'starting with a multipart message');
    $mail->send;
    my $received = WebGUI::Test->getMail;

    if (!$received) {
        skip "Cannot making single part: No response received from smtpd", $numtests;
    }

    # Test the mail
    my $parser         = MIME::Parser->new();
    $parser->output_to_core(1);
    my $parsed_message = $parser->parse_data($received->{contents});
    ok (!$parsed_message->is_multipart, 'converted to singlepart since it only has 1 part.');
}

SKIP: {
    my $numtests = 2; # Number of tests in this block

    skip "Cannot test making emails single part", $numtests unless $smtpServerOk;

    # Send the mail
    my $mail
        = WebGUI::Mail::Send->create( $session, { 
            to        => 'norton@localhost',
        } );
    $mail->addText("You know what the Mexicans say about the Pacific?");
    $mail->addText("They say it has no memory. That's where I want to live the rest of my life. A warm place with no memory.");

    ok ($mail->getMimeEntity->is_multipart, 'starting with a multipart message');
    $mail->send;
    my $received = WebGUI::Test->getMail;

    if (!$received) {
        skip "Cannot making single part: No response received from smtpd", $numtests;
    }

    # Test the mail
    my $parser         = MIME::Parser->new();
    $parser->output_to_core(1);
    my $parsed_message = $parser->parse_data($received->{contents});
    ok ( $parsed_message->is_multipart, 'left as multipart since it has more than 1 part');
}
# TODO: Test the emailToLog config setting
