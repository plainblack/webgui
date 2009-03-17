# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This script tests the creation, sending, and queuing of mail messages
# TODO: There is plenty left to do in this script.
$|=1;
use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use JSON qw( from_json to_json );
use Test::More;
use Test::Deep;
use File::Spec;
use Data::Dumper;
use WebGUI::Test;

use WebGUI::Mail::Send;
use WebGUI::User;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $mail;       # The WebGUI::Mail::Send object
my $mime;       # for getMimeEntity

# Load Net::SMTP::Server
my $hasServer; # This is true if we have a Net::SMTP::Server module
BEGIN { 
    eval { require Net::SMTP::Server; require Net::SMTP::Server::Client; };
    $hasServer = 1 unless $@;
}

# See if we have an SMTP server to use
my ( $smtpd, %oldSettings );
my $SMTP_HOST        = 'localhost';
my $SMTP_PORT        = '54921';
if ($hasServer) {
    $oldSettings{ smtpServer } = $session->setting->get('smtpServer');
    $session->setting->set( 'smtpServer', $SMTP_HOST . ':' . $SMTP_PORT );

    my $smtpd       = File::Spec->catfile( WebGUI::Test->root, 't', 'smtpd.pl' );
    open MAIL, "perl $smtpd $SMTP_HOST $SMTP_PORT 4 |"
        or die "Could not open pipe to SMTPD: $!";
    sleep 1; # Give the smtpd time to establish itself
}

#----------------------------------------------------------------------------
# Tests

plan tests => 13;        # Increment this number for each test you create

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

#----------------------------------------------------------------------------
# Test addHtml
$mail   = WebGUI::Mail::Send->create( $session );
$text = <<'EOF';
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Suspendisse eu lacus ut ligula fringilla elementum. Cras condimentum, velit commodo pretium semper, odio ante accumsan orci, a ultrices risus justo a nulla. Aliquam erat volutpat. 
EOF

$mail->addHtml($text);
$mime   = $mail->getMimeEntity;

# TODO: Test that addHtml creates an HTML wrapper if no html or body tag exists
# TODO: Test that addHtml creates a body with the right content type

# addHtml should add newlines after 78 characters
$newlines    = length $text / 78;
is( $mime->parts(0)->as_string =~ m/\n/, $newlines,
    "addHtml should add newlines after 78 characters",
);

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

# TODO: Test that addHtml creates a body with the right content type

my $smtpServerOk = 0;

#----------------------------------------------------------------------------
# Test emailOverride
SKIP: {
    my $numtests        = 1; # Number of tests in this block

    # Must be able to write the config, or we'll die
    if ( !-w File::Spec->catfile( WebGUI::Test::root, 'etc', WebGUI::Test::file() ) ) {
        skip "Cannot test emailOverride: Can't write new configuration value", $numtests;
    }

    # Must have an SMTP server, or it's pointless
    if ( !$hasServer ) {
        skip "Cannot test emailOverride: Module Net::SMTP::Server not loaded!", $numtests;
    }

    $smtpServerOk = 1;

    # Override the emailOverride
    my $oldEmailOverride   = $session->config->get('emailOverride');
    $session->config->set( 'emailOverride', 'dufresne@localhost' );
    my $oldEmailToLog      = $session->config->get('emailToLog');
    $session->config->set( 'emailToLog', 0 );

    # Send the mail
    my $mail
        = WebGUI::Mail::Send->create( $session, { 
            to      => 'norton@localhost',
        } );
    $mail->addText( 'His judgement cometh and that right soon.' );

    my $received = sendToServer( $mail );

    if ($received->{error}) {
        skip "Cannot test emailOverride: No response received from smtpd", $numtests;
    }

    # Test the mail
    like( $received->{to}->[0], qr/dufresne\@localhost/,
        "Email TO: address is overridden",
    );

    # Restore the emailOverride
    $session->config->set( 'emailOverride', $oldEmailOverride );
    $session->config->set( 'emailToLog', $oldEmailToLog );
}

#----------------------------------------------------------------------------
#
# Test sending an Inbox message to a user who has various notifications configured
#
#----------------------------------------------------------------------------

my $inboxUser = WebGUI::User->create($session);
$inboxUser->username('red');
$inboxUser->profileField('receiveInboxEmailNotifications', 1);
$inboxUser->profileField('receiveInboxSmsNotifications',   0);
$inboxUser->profileField('email',     'ellis_boyd_redding@shawshank.gov');
$inboxUser->profileField('cellPhone', '55555');
$oldSettings{smsGateway} = $session->setting->get('smsGateway');
$session->setting->set('smsGateway', 'textme.com');

my $emailUser = WebGUI::User->create($session);
$emailUser->username('heywood');
$emailUser->profileField('email', 'heywood@shawshank.gov');

my $lonelyUser = WebGUI::User->create($session);
$lonelyUser->profileField('receiveInboxEmailNotifications', 0);
$lonelyUser->profileField('receiveInboxSmsNotifications',   0);
$lonelyUser->profileField('email',   'jake@shawshank.gov');

my $inboxGroup = WebGUI::Group->new($session, 'new');
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

    my $received = sendToServer( $mail ) ;

    # Test the mail
    is($received->{to}->[0], '<ellis_boyd_redding@shawshank.gov>', 'send, toUser with email address');

    $inboxUser->profileField('receiveInboxEmailNotifications', 0);
    $inboxUser->profileField('receiveInboxSmsNotifications',   1);

    # Send the mail
    $mail = WebGUI::Mail::Send->create( $session, { 
            toUser  => $inboxUser->userId,
            },
            'fromInbox',
    );
    $mail->addText( 'sent via SMS' );

    my $received = sendToServer( $mail ) ;

    # Test the mail
    is($received->{to}->[0], '<55555@textme.com>', 'send, toUser with SMS address');

    $inboxUser->profileField('receiveInboxEmailNotifications', 1);
    $inboxUser->profileField('receiveInboxSmsNotifications',   1);

    # Send the mail
    $mail = WebGUI::Mail::Send->create( $session, { 
            toUser  => $inboxUser->userId,
            },
            'fromInbox',
    );
    $mail->addText( 'sent via SMS' );

    my $received = sendToServer( $mail ) ;

    # Test the mail
    cmp_bag(
        $received->{to},
        ['<55555@textme.com>', '<ellis_boyd_redding@shawshank.gov>',],
        'send, toUser with SMS and email addresses'
    );

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
is(scalar @mailIds, $startingMessages+2, 'sending a message with a group added the right two messages');

my @emailAddresses = ();
foreach my $mailId (@mailIds) {
    my $mail = WebGUI::Mail::Send->retrieve($session, $mailId);
    push @emailAddresses, $mail->getMimeEntity->head->get('to');
}

cmp_bag(
    \@emailAddresses,
    [
        'heywood@shawshank.gov'."\n",
        'ellis_boyd_redding@shawshank.gov,55555@textme.com'."\n",
    ],
    'send: when the original is sent, new messages are created for each user in the group, following their user profile settings'
);

# TODO: Test the emailToLog config setting


#----------------------------------------------------------------------------
# Cleanup
END {
    for my $name ( keys %oldSettings ) {
        $session->setting->set( $name, $oldSettings{ $name } );
    }

    $inboxUser->delete   if $inboxUser;
    $emailUser->delete   if $emailUser;
    $lonelyUser->delete  if $lonelyUser;
    $inboxGroup->delete  if $inboxGroup;

    close MAIL 
        or die "Could not close pipe to SMTPD: $!";
    sleep 1;

    $session->db->write('delete from mailQueue');
}

#----------------------------------------------------------------------------
# sendToServer ( mail )
# Spawns a server (using t/smtpd.pl), sends the mail, and grabs it from the 
# child
# The child process builds a Net::SMTP::Server and listens for the parent to
# send the mail. The entire result is returned as a hash reference with the 
# following keys:
#
# to            - who the mail was to
# from          - who the mail was from
# contents      - The complete contents of the message, suitable to be parsed
#                 by a MIME::Entity parser
sub sendToServer {
    my $mail        = shift;
    my $status = $mail->send;
    my $json;
    if ($status) {
        $json = <MAIL>;
    }
    else {
        $json = ' { "error": "mail not sent" } ';
    }
    if (!$json) {
        $json = ' { "error": "error in getting mail" } ';
    }
    return from_json( $json );
}

