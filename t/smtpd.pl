use strict;
use warnings;

use JSON qw( to_json );
use Net::SMTP::Server;
use Net::SMTP::Server::Client;

my ($HOST, $PORT) = @ARGV;

die "HOST must be first argument"
    unless $HOST;
die "PORT must be second argument"
    unless $PORT;

my $server  = Net::SMTP::Server->new( $HOST, $PORT );

$| = 1;

CONNECTION: while ( my $conn = $server->accept ) {
    my $client  = Net::SMTP::Server::Client->new( $conn );
    $client->process;
    print to_json({
        to          => $client->{TO},
        from        => $client->{FROM},
        contents    => $client->{MSG},
    });
    print "\n";
}

=head1 NAME

t/smtpd.pl - A dumb SMTP server.

=head1 USAGE

 perl smtpd.pl <hostname> <port>

=head1 DESCRIPTION

This program listens on the given hostname and port, then processes the 
incoming SMTP client request. 

Then it prints a JSON object of the data recieved and exits.

This program will only handle one request before exiting.

=head1 CAVEATS

You MUST C<sleep 1> after opening a pipe to this so that it can establish the
listening on the port.
