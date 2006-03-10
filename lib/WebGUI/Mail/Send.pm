package WebGUI::Mail::Send;

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

use Net::SMTP;
use MIME::Entity;
use LWP::MediaTypes qw(guess_media_type);
use strict;

=head1 NAME

Package WebGUI::Mail::Send

=head1 DESCRIPTION

This package is used for sending emails via SMTP.

=head1 SYNOPSIS

use WebGUI::Mail::Send;

my $mail = WebGUI::Mail::Send->new($session, { to=>$to, from=>$from, subject=>$subject});
$mail->addText($text);
$mail->addHtml($html);
$mail->addAttachment($pathToFile);
$mail->send;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addAttachment ( pathToFile )

Adds an attachment to the message.

=head3 pathToFile

The filesystem path to the file you wish to attach.

=cut

sub addAttachment {
	my $self = shift;
	my $path = shift;
	$self->{_message}->attach(
		Path=>$path,
		Encoding=>'-SUGGEST',
		Type=>guess_media_type($path)
		);
}


#-------------------------------------------------------------------

=head2 addHtml ( html ) 

Appends an HTML block to the message.

=head3 html

A string of HTML.

=cut

sub addHtml {
	my $self = shift;
	my $text = shift;
	$self->{_message}->attach(
		Charset=>"UTF-8",
		Data=>$text,
		Type=>"text/html"
		);
}


#-------------------------------------------------------------------

=head2 addText ( text ) 

Adds a text message to the email.

=head3 text

A string of text.

=cut

sub addText {
	my $self = shift;
	my $text = shift;
	$self->{_message}->attach(
		Charset=>"UTF-8",
		Data=>$text
		);
}


#-------------------------------------------------------------------

=head2 new ( session, headers )

Constructor.

=head3 session

A reference to the current session.

=head3 headers

A hash reference containing addressing and other header level options.

=head4 to

A string containing a comma seperated list of email addresses to send to.

=head4 subject

A short string of text to be placed in the subject line.

=head4 cc

A string containing a comma seperated list of email addresses to carbon copy on this message.

=head4 bcc

A string containing a comma seperated list of email addresses to blind carbon copy on this message.

=head4 from

A single email address that this message will originate from. Defaults to the company email address stored in the settings.

=head4 replyTo

A single email address that responses to this message will be sent to.

=head contentType

A mime type for the message. Defaults to "multipart/mixed".

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $headers = shift;
	$headers->{from} ||= $session->setting->get("companyEmail");
	$headers->{contentType} ||= "multipart/mixed";
	my $override = "";
	if ($session->config->get("emailOverride")) {
		$override = $headers->{to};
		$headers->{to} = $session->config->get("emailOverride");
		delete $headers->{bcc};
		delete $headers->{cc};
	}
	my $message = MIME::Entity->build(
		Type=>$headers->{contentType},
		From=>$headers->{from},
		To=>$headers->{to},
		Cc=>$headers->{cc},
		Bcc=>$headers->{bcc},
		"Reply-To"=>$headers->{replyTo},
		Subject=>$headers->{subject},
		Date=>$session->datetime->epochToHuman("","%W, %d %C %y %j:%n:%s %O"),
		"X-Mailer"=>"WebGUI"
		);
	if ($override) {
		$message->attach(Data=>"This message was intended for ".$override." but was overridden in the config file.\n\n");
	}
	bless {_message=>$message,  _session=>$session, _headers=>$headers}, $class;
}

#-------------------------------------------------------------------

=head2 send ( )

Sends the message via SMTP. Returns 1 if successful.

=cut

sub send {
	my $self = shift;
	if ($self->session->setting->get("smtpServer") =~ /\/sendmail/) {
		if (open(MAIL,"| ".$self->session->setting->get("smtpServer")." -t -oi -oem")) {
			$self->{_message}->print(\*MAIL);
			close(MAIL) or $self->session->errorHandler->error("Couldn't close connection to mail server: ".$self->session->setting->get("smtpServer"));
		} else {
			$self->session->errorHandler->error("Couldn't connect to mail server: ".$self->session->setting->get("smtpServer"));
			return 0;
		}
	} else {
		my $smtp = Net::SMTP->new($self->session->setting->get("smtpServer")); # connect to an SMTP server
		if (defined $smtp) {
			$smtp->mail($self->{_headers}{from});     # use the sender's address here
			$smtp->to(split(",",$self->{_headers}{to}));             # recipient's address
			$smtp->cc(split(",",$self->{_headers}{cc}));
			$smtp->bcc(split(",",$self->{_headers}{bcc}));
			$smtp->data();              # Start the mail
			$smtp->datasend($self->{_message}->stringify);
			$smtp->dataend();           # Finish sending the mail
			$smtp->quit;                # Close the SMTP connection
		} else {
			$self->session->errorHandler->error("Couldn't connect to mail server: ".$self->session->setting->get("smtpServer"));
			return 0;
		}
	}
	return 1;
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
