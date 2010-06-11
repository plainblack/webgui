package WebGUI::Test::MailServer;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::Test::MailServer

=head1 DESCRIPTION

Routines for testing mail sending in WebGUI

=head1 SUBROUTINES

=head2 test_smtp ( $session, $testSub )

Sets up a SMTP server and runs a test sub against it.  The test sub will be called with a callback sub as a parameter.  Calling that callback will return a hash ref with four keys.

=over 8

=item to

Contains an array of addresses the message was sent to.

=item from

Contains the address the message was sent from.

=item contents

Contains the raw contents of the mail message.

=item parsed

Contains the mail message as a L<MIME::Entity> object.

=back

=cut

use strict;
use warnings;

use JSON ();
use File::Spec::Functions qw(catdir updir);
use File::Basename qw(dirname);
use IO::Select;
use Net::SMTP::Server;
use Net::SMTP::Server::Client;
use MIME::Parser;
use Scope::Guard;
use MIME::Parser;

my $smtpdPid;
my $smtpdStream;
my $smtpdSelect;


sub test_smtp {
    my $session = shift;
    my $testSub = shift;
    my $guard = Scope::Guard->new(sub { _shutdown_server() } );
    _setup_server($session);
    sleep 1;
    my $parser = MIME::Parser->new;
    $parser->output_to_core(1);
    my $cb = sub {
        die "mail not sent\n"
            unless $smtpdSelect->can_read(5);
        my $json = <$smtpdStream>;
        my $data = JSON->new->utf8->decode($json);
        my $parsed = $parser->parse_data($data->{contents});
        $data->{parsed} = $parsed;
        return $data;
    };
    $testSub->($cb);
}

sub _setup_server {
    my $session = shift;
    return
        if $smtpdPid;

    my $host = 'localhost';
    my $port = 54921;

    # make sure the lib path for this file is available
    my $lib_path = catdir( dirname(__FILE__), (updir) x 2 );
    my @command_line = (
        $^X, "-I$lib_path", '-M' . __PACKAGE__,
        '-e' . __PACKAGE__ . '::_run_server(@ARGV)', $host, $port,
    );

    $smtpdPid = open $smtpdStream, '-|', @command_line
        or die "Could not open pipe to SMTPD: $!";
    die "Could not open pipe to SMTPD: $!"
        unless $smtpdStream;

    $smtpdSelect = IO::Select->new;
    $smtpdSelect->add($smtpdStream);

    $session->setting->set( 'smtpServer', $host . ':' . $port );
    $session->config->set( 'emailToLog', 0 );
}

sub _shutdown_server {
    undef $smtpdSelect;

    # Close SMTPD
    if ($smtpdPid) {
        kill INT => $smtpdPid;
        undef $smtpdPid;
    }
    if ($smtpdStream) {
        # we killed it, so there will be an error.  Prevent that from setting the exit value.
        local $?;
        close $smtpdStream;
        undef $smtpdStream;
    }
}

sub _run_server {
    my ($host, $port) = @_;
    my $server  = Net::SMTP::Server->new( $host, $port );
    local $| = 1;
    CONNECTION: while ( my $conn = $server->accept ) {
        my $client  = Net::SMTP::Server::Client->new( $conn );
        $client->process;
        print JSON->new->utf8->encode({
            to          => $client->{TO},
            from        => $client->{FROM},
            contents    => $client->{MSG},
        });
        print "\n";
    }
}

1;

