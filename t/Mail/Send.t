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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use JSON qw( from_json to_json );
use Test::More;
use File::Spec;
use WebGUI::Test;

use WebGUI::Mail::Send;

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
}

#----------------------------------------------------------------------------
# Tests

plan tests => 6;        # Increment this number for each test you create

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
my $text = <<'EOF';
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Suspendisse eu lacus ut ligula fringilla elementum. Cras condimentum, velit commodo pretium semper, odio ante accumsan orci, a ultrices risus justo a nulla. Aliquam erat volutpat. 
EOF

$mail->addHtml($text);
$mime   = $mail->getMimeEntity;

# TODO: Test that addHtml creates an HTML wrapper if no html or body tag exists
# TODO: Test that addHtml creates a body with the right content type

# addHtml should add newlines after 78 characters
my $newlines    = length $text / 78;
is( $mime->parts(0)->as_string =~ m/\n/, $newlines,
    "addHtml should add newlines after 78 characters",
);

$mail   = WebGUI::Mail::Send->create( $session );
# TODO: Test that addHtml does not create an HTML wrapper if html or body tag exist

#----------------------------------------------------------------------------
# Test addHtmlRaw
$mail   = WebGUI::Mail::Send->create( $session );
my $text = <<'EOF';
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Suspendisse eu lacus ut ligula fringilla elementum. Cras condimentum, velit commodo pretium semper, odio ante accumsan orci, a ultrices risus justo a nulla. Aliquam erat volutpat. 
EOF

$mail->addHtmlRaw($text);
$mime   = $mail->getMimeEntity;

# TODO: Test that addHtmlRaw doesn't add an HTML wrapper

# addHtmlRaw should add newlines after 78 characters
my $newlines    = length $text / 78;
is( $mime->parts(0)->as_string =~ m/\n/, $newlines,
    "addHtmlRaw should add newlines after 78 characters",
);

# TODO: Test that addHtml creates a body with the right content type

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

    # Restore the emailOverride
    $session->config->set( 'emailOverride', $oldEmailOverride );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    for my $name ( keys %oldSettings ) {
        $session->setting->set( $name, $oldSettings{ $name } );
    }
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
    
    my $smtpd       = File::Spec->catfile( WebGUI::Test->root, 't', 'smtpd.pl' );
    open MAIL, "perl $smtpd $SMTP_HOST $SMTP_PORT |"
        or die "Could not open pipe to SMTPD: $!";
    sleep 1; # Give the smtpd time to establish itself

    $mail->send;
    my $json;
    while ( my $line = <MAIL> ) {
        $json   .= $line; 
    }

    close MAIL 
        or die "Could not close pipe to SMTPD: $!";

    return from_json( $json );
}

