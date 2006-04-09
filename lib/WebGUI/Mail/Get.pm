package WebGUI::Mail::Get;

=head1 LEGAL

-------------------------------------------------------------------
WebGUI is Copyright 2001-2006 Plain Black Corporation.
-------------------------------------------------------------------
Please read the legal notices (docs/legal.txt) and the license
(docs/license.txt) that came with this distribution before using
this software.
-------------------------------------------------------------------
http://www.plainblack.com                     info@plainblack.com
-------------------------------------------------------------------

=cut

use strict;
use Net::POP3;
use MIME::Entity;
use MIME::Parser;
use LWP::MediaTypes qw(guess_media_type);
use WebGUI::Group;
use WebGUI::User;

=head1 NAME

Package WebGUI::Mail::Get

=head1 DESCRIPTION

This package is used for retrieving emails via POP3.

=head1 SYNOPSIS

use WebGUI::Mail::Get;


=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 connect ( sessionh, params )

Constructor. Opens a connection to a POP3 server.

=head3 session

A reference to the current session.

=head3 params

A hash reference containing POP3 connection properties.

=head4 server

A scalar containing an IP address or host name of the server to connect to.

=head4 account

The account name to use to connect to this POP3 server.

=head4 password

The password to use to connect to this POP3 server.

=cut

sub connect {
	my $class = shift;
	my $session = shift;
	my $params = shift;
	my $pop = Net::POP3->new($params->{server}, Timeout => 60);
	unless (defined $pop) {
		$session->errorHandler->error("Couldn't connect to POP3 server ". $params->{server});
		return undef;
	}
	unless ($pop->login($params->{account}, $params->{password})) {
		$session->errorHandler->error("Couldn't log in to POP3 server ".$params->{server}." as ".$params->{account});
		return undef;
	}
	my $messageNumbers = $pop->list;
	my @ids = ();
	foreach my $key (keys %{$messageNumbers}) {
		push(@ids, $key);
	}
	bless {_pop=>$pop,  _session=>$session, _ids=>\@ids }, $class;
}

#-------------------------------------------------------------------

=head2 disconnect ( )

Disconnects from the POP3 server.

=cut

sub disconnect {
	my $self = shift;
	$self->{_pop}->quit;
}

#-------------------------------------------------------------------

=head2 getNextMessage ( )

Retrieves the next available message from the server. Returns undef if there are no more messages. Returns a hash reference containing the properties of the message. Here's an example:

 {
	to => 'John Doe <jon@example.com>, jane@example.com',
	from => 'sam@example.com',
	cc => 'joe@example.com',
	subject => 'This is my message subject',
	inReplyTo => 'some-message-id',
	date => 1144536119,
	parts => [
		{
			type=>'text/plain',
			content=>'Some body text goes here',
			filename => undef
		}, {
			type=>'image/png',
			content=>' ---- binary content here ---- ',
			filename => 'image.png'
		}, {
			type=>'application/msword',
			content=>' ---- binary content here ---- ',
			filename => undef
		}
	]
}

=cut

sub getNextMessage {
	my $self = shift;
	my $id = pop(@{$self->{_ids}});
	return undef unless $id;
	my $rawMessage = $self->{_pop}->get($id);
	my $parser = MIME::Parser->new;
	$parser->output_to_core(1);
	my $parsedMessage = $parser->parse_data($rawMessage);
	if (defined $parsedMessage) {
		$self->{_pop}->delete($id);
	} else {
		$self->session->errorHandler->error("Could not parse POP3 message $id");
		return undef;
	}
	my $head = $parsedMessage->head;
	my $to = $head->get("To") || undef;
	chomp($to);
	my $from = $head->get("From") || undef;
	chomp($from);
	my $cc = $head->get("Cc") || undef;
	chomp($cc);
	my $subject = $head->get("Subject") || undef;
	chomp($subject);
	my $inReplyTo = $head->get("In-Reply-To") || undef;
	chomp($inReplyTo);
	my %data = (
		to => $to,
		from => $from,
		cc => $cc,
		subject => $subject,
		inReplyTo => $inReplyTo,
		date => $self->session->datetime->mailToEpoch($head->get("Date")),
		);
	my @segments = ();
	my @parts = $parsedMessage->parts;
	push(@parts, $parsedMessage) unless (@parts); # deal with the fact that there might be only one part
	foreach my $part (@parts) {
		my $type = $part->mime_type;
		next if ($type eq "message/rfc822");
        	my $body = $part->bodyhandle;
		my $disposition = $part->head->get("Content-Disposition");
		$disposition =~ m/filename=\"(.*)\"/;
		my $filename = $1;
		my $content = $body->as_string if (defined $body);
		next unless ($content);
		push(@segments, {
			filename=>$filename,
			type=>$type,
			content=>$content
			});
	}
	$data{parts} = \@segments;
	return \%data;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

1;
