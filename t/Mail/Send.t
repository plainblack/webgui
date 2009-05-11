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
use File::Spec;
use Data::Dumper;
use MIME::Parser;
use IO::Select;
use Encode qw/decode/;

use WebGUI::Test;

use WebGUI::Mail::Send;

# Load Net::SMTP::Server
my $hasServer; # This is true if we have a Net::SMTP::Server module
BEGIN {
    eval {
        require Net::SMTP::Server;
        require Net::SMTP::Server::Client;
    };
    $hasServer = 1 unless $@;
}

$| = 1;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $mail;       # The WebGUI::Mail::Send object
my $mime;       # for getMimeEntity

# See if we have an SMTP server to use
my $smtpdPid;
my $smtpdStream;
my $smtpdSelect;

my $SMTP_HOST        = 'localhost';
my $SMTP_PORT        = '54921';
if ($hasServer) {
    my $smtpd    = File::Spec->catfile( WebGUI::Test->root, 't', 'smtpd.pl' );
    $smtpdPid = open $smtpdStream, '-|', $^X, $smtpd, $SMTP_HOST, $SMTP_PORT
        or die "Could not open pipe to SMTPD: $!";

    $smtpdSelect = IO::Select->new;
    $smtpdSelect->add($smtpdStream);

    $session->setting->set( 'smtpServer', $SMTP_HOST . ':' . $SMTP_PORT );

    WebGUI::Test->originalConfig('emailToLog');
    $session->config->set( 'emailToLog', 0 );
}

#----------------------------------------------------------------------------
# Tests

plan tests => 11;        # Increment this number for each test you create

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

    # Send the mail
    my $mail
        = WebGUI::Mail::Send->create( $session, { 
            to      => 'norton@localhost',
        } );
    $mail->addText( 'His judgement cometh and that right soon.' );

    my $received = sendToServer( $mail );

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

    my $received = sendToServer( $mail );

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

    $received = sendToServer( $mail );

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

    $received = sendToServer( $mail );

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

    $received = sendToServer( $mail );

    $parsed_message = $parser->parse_data($received->{contents});
    $head           = $parsed_message->head;
    $messageId      = decode('MIME-Header', $head->get('Message-Id'));
    chomp $messageId;
    is($messageId, '<noAngles@localhost.localdomain>', 'bad messageId corrected (added both angles)');

}

# TODO: Test the emailToLog config setting
#----------------------------------------------------------------------------
# Cleanup
END {
    if ($smtpdPid) {
        kill INT => $smtpdPid;
    }
    if ($smtpdStream) {
        close $smtpdStream;
        # we killed it, so there will be an error.  Prevent that from setting the exit value.
        $? = 0;
    }
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
    if ($status && $smtpdSelect->can_read(5)) {
        $json = <$smtpdStream>;
    }
    elsif ($status) {
        $json = ' { "error" : "unable to read from smptd.pl" } ';
    }
    else {
        $json = ' { "error": "mail not sent" } ';
    }
    if (!$json) {
        $json = ' { "error": "error in getting mail" } ';
    }
    return from_json( $json );
}

