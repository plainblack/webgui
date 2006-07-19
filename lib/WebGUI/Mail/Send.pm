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

use strict;
use Net::SMTP;
use MIME::Entity;
use MIME::Parser;
use LWP::MediaTypes qw(guess_media_type);
use WebGUI::Group;
use WebGUI::Macro;
use WebGUI::User;

=head1 NAME

Package WebGUI::Mail::Send

=head1 DESCRIPTION

This package is used for sending emails via SMTP.

=head1 SYNOPSIS

use WebGUI::Mail::Send;

my $mail = WebGUI::Mail::Send->create($session, { to=>$to, from=>$from, subject=>$subject});
my $mail = WebGUI::Mail::Send->retrieve($session, $messageId);

$mail->addText($text);
$mail->addHtml($html);
$mail->addAttachment($pathToFile);

$mail->send;
$mail->queue;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addAttachment ( pathToFile [ , mimetype ] )

Adds an attachment to the message.

=head3 pathToFile

The filesystem path to the file you wish to attach.

=head3 mimetype

Optionally specify a mime type for this attachment. If one is not specified it will be guessed based upon the file extension.

=cut

sub addAttachment {
	my $self = shift;
	my $path = shift;
	my $mimetype = shift || guess_media_type($path);
	$self->{_message}->attach(
		Path=>$path,
		Encoding=>'-SUGGEST',
		Type=>$mimetype
		);
}

#-------------------------------------------------------------------

=head2 addFooter ( )

Adds the mail footer as set by the site admin to the end of this message.

=cut

sub addFooter {
	my $self = shift;
	my $text = "\n\n".$self->session->setting->get("mailFooter");
	WebGUI::Macro::process($self->session, \$text);
	$self->addText($text);
}

#-------------------------------------------------------------------

=head2 addHeaderField ( name, value ) 

Adds a header field to the mail message. See also replaceHeaderField().

=head3 name

The name of the field to add.

=head3 value

The value of the field to add.

=cut

sub addHeaderField {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	$self->{_message}->head->add($name, $value);
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

=head2 create ( session, headers )

Creates a new message and returns a WebGUI::Mail::Send object. This is a class method.

=head3 session

A reference to the current session.

=head3 headers

A hash reference containing addressing and other header level options.

=head4 to

A string containing a comma seperated list of email addresses to send to.

=head4 toUser

A WebGUI userId of a user you'd like to send this message to.

=head4 toGroup

A WebGUI groupId. The email address of the users in this group will be looked up and will each be sent a copy of this message.

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

=head4 contentType

A mime type for the message. Defaults to "multipart/mixed".

=head4 messageId

A unique id for this message, in case you want to see what replies come in for it later. One will be automatically generated if you don't specify this.

=head4 inReplyTo

If this is a reply to a previous message, then you should specify the messageId of the previous message here.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $headers = shift;
	if ($headers->{toUser}) {
		my $user = WebGUI::User->new($session, $headers->{toUser});
		if (defined $user) {
			my $email = $user->profileField("email");
			if ($email) {
				if ($headers->{to}) {
					$headers->{to} .= ','.$email;
				} else {
					$headers->{to} = $email;
				}
			}	
		}
	}
	my $from = $headers->{from} || $session->setting->get("companyEmail");
	my $type = $headers->{contentType} || "multipart/mixed";
	my $domain = $from;
	$domain =~ s/.*\@(.*)/$1/;
	my $id = $headers->{messageId} ||  "WebGUI-".$session->id->generate;
	unless ($id =~ m/\@/) {
		$id .= '@'.$domain;
	}
	my $message = MIME::Entity->build(
		Type=>$type,
		From=>$from,
		To=>$headers->{to},
		Cc=>$headers->{cc},
		Bcc=>$headers->{bcc},
		"Reply-To"=>$headers->{replyTo},
		"In-Reply-To"=>$headers->{inReplyTo},
		Subject=>$headers->{subject},
		"Message-Id"=>$id,
		Date=>$session->datetime->epochToMail,
		"X-Mailer"=>"WebGUI"
		);
	$message->head->delete("Return-Path");
	$message->head->add("Return-Path",  "<". ($session->setting->get("mailReturnPath") || $from) . ">");
	$type = $headers->{contentType};
	if ($session->config->get("emailOverride")) {
		my $to = $headers->{to};
		$to = "WebGUI Group ".$headers->{toGroup} if ($headers->{toGroup});
		$message->head->replace("to", $session->config->get("emailOverride"));
		$message->head->replace("cc",undef);
		$message->head->replace("bcc",undef);
		delete $headers->{toGroup};
		$message->attach(Data=>"This message was intended for ".$to." but was overridden in the config file.\n\n");
	}
	bless {_message=>$message,  _session=>$session, _toGroup=>$headers->{toGroup} }, $class;
}

#-------------------------------------------------------------------

=head2 getMessageIdsInQueue ( session ) 

Returns an array reference of the message IDs in the mail queue. Use with the retrieve() method. This is a class method.

=head3 session

A reference to the current session.

=cut

sub getMessageIdsInQueue {
	my $class = shift;
	my $session = shift;
	return $session->db->buildArrayRef("select messageId from mailQueue");
}


#-------------------------------------------------------------------

=head2 queue ( )

Puts this message in the mail queue so it can be sent out later by the workflow system. Returns a messageId so that the message can be retrieved later if necessary. Note that this is the preferred method of sending messages because it keeps WebGUI running faster.

=cut

sub queue {
	my $self = shift;
	return $self->session->db->setRow("mailQueue", "messageId", { messageId=>"new", message=>$self->{_message}->stringify, toGroup=>$self->{_toGroup} });
}


#-------------------------------------------------------------------

=head2 replaceHeaderField ( name, value ) 

Replaces an existing header field in the mail message, or creates it if it doesn't exist. See also addHeaderField().

=head3 name

The name of the field to replace.

=head3 value

The value of the field to replace.

=cut

sub replaceHeaderField {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	$self->{_message}->head->replace($name, $value);
}


#-------------------------------------------------------------------

=head2 retrieve ( session, messageId ) 

Retrieves a message from the mail queue, which thusly deletes it from the queue. This is a class method.

=head3 session

A reference to the current session.

=head3 messageId

The unique id for a message in the queue.

=cut

sub retrieve {
	my $class = shift;
	my $session = shift;
	my $messageId = shift;
	return undef unless $messageId;
	my $data = $session->db->getRow("mailQueue","messageId", $messageId);
	return undef unless $data->{messageId};
	$session->db->deleteRow("mailQueue","messageId", $messageId);
	my $parser = MIME::Parser->new;
	$parser->output_to_core(1);
	bless {_session=>$session, _message=>$parser->parse_data($data->{message}), _toGroup=>$data->{toGroup}}, $class;
}


#-------------------------------------------------------------------

=head2 send ( )

Sends the message via SMTP. Returns 1 if successful.

=cut

sub send {
	my $self = shift;
	my $status = 1;
	if ($self->{_message}->head->get("To")) {
		if ($self->session->setting->get("smtpServer") =~ /\/sendmail/) {
			if (open(MAIL,"| ".$self->session->setting->get("smtpServer")." -t -oi -oem")) {
				$self->{_message}->print(\*MAIL);
				close(MAIL) or $self->session->errorHandler->error("Couldn't close connection to mail server: ".$self->session->setting->get("smtpServer"));
			} else {
				$self->session->errorHandler->error("Couldn't connect to mail server: ".$self->session->setting->get("smtpServer"));
				$status = 0;
			}
		} else {
			my $smtp = Net::SMTP->new($self->session->setting->get("smtpServer")); # connect to an SMTP server
			if (defined $smtp) {
				$smtp->mail($self->{_message}->head->get("from"));     # use the sender's address here
				$smtp->to(split(",",$self->{_message}->head->get("to")));             # recipient's address
				$smtp->cc(split(",",$self->{_message}->head->get("cc")));
				$smtp->bcc(split(",",$self->{_message}->head->get("bcc")));
				$smtp->data();              # Start the mail
				$smtp->datasend($self->{_message}->stringify);
				$smtp->dataend();           # Finish sending the mail
				$smtp->quit;                # Close the SMTP connection
			} else {
				$self->session->errorHandler->error("Couldn't connect to mail server: ".$self->session->setting->get("smtpServer"));
				$status = 0;
			}
		}
	}
	my $group = $self->{_toGroup};
	delete $self->{_toGroup};
	if ($group) {
		my $group = WebGUI::Group->new($self->session, $group);
		$self->{_message}->head->replace("bcc", undef);
		$self->{_message}->head->replace("cc", undef);
		foreach my $userId (@{$group->getAllUsers(1)}) {
			my $user = WebGUI::User->new($self->session, $userId);
			if ($user->profileField("email")) {
				$self->{_message}->head->replace("To",$user->profileField("email"));
				unless ($self->send) {
					$status = 0;
				}	
			}
		}
	}
	return $status;
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
