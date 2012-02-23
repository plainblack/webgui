package WebGUI::Mail::Send;

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

=cut

use strict;
use LWP::MediaTypes qw(guess_media_type);
use MIME::Entity;
use MIME::Parser;
use Net::SMTP;
use WebGUI::Group;
use WebGUI::Macro;
use WebGUI::User;
use WebGUI::HTML;
use Encode qw(encode);

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
	$self->getMimeEntity->attach(
		Path=>$path,
		Encoding=>'-SUGGEST',
		Type=>$mimetype
		);
}

#-------------------------------------------------------------------

=head2 addFooter ( )

Adds the mail footer as set by the site admin to the end of the first
part of this message.  If the first part of the message has an HTML MIME-type,
then it will translate the footer to HTML.

If the message is empty, it will create a MIME entity part to hold it.

Macros in the footer will be evaluated.

=cut

sub addFooter {
	my $self = shift;
    return if $self->{_footerAdded};
	my $footer = "\n\n".$self->session->setting->get("mailFooter");
	WebGUI::Macro::process($self->session, \$footer);
    my $text = encode("utf8", $footer);
    $self->{_footerAdded} = 1;
    my @parts = $self->getMimeEntity->parts();
    ##No parts yet, add one with the footer content.
    if (! $parts[0]) {
        $self->addText($text);
        return;
    }
    ##Get the content of the first part, drop it from the set of parts
    my $mime_body    = $parts[0]->bodyhandle;
    my $body_content = join '', $mime_body->as_lines;
    my $mime_type;
    if ($parts[0]->effective_type eq 'text/plain') {
        $body_content .= $text;
        my $new_part = MIME::Entity->build(
            Charset     => "UTF-8",
            Encoding    => "quoted-printable",
            Type        => 'text/plain',
            Data        => $body_content,
        );
        shift @parts;
        unshift @parts, $new_part;
        $self->getMimeEntity->parts(\@parts);
    }
    elsif ($parts[0]->effective_type eq 'text/html') {
        $text = WebGUI::HTML::format($text, 'mixed');
        $body_content =~ s{(?=</body>)}{$text};
        my $new_part = MIME::Entity->build(
            Charset     => "UTF-8",
            Encoding    => "quoted-printable",
            Type        => 'text/html',
            Data        => $body_content,
        );
        shift @parts;
        unshift @parts, $new_part;
        $self->getMimeEntity->parts(\@parts);
    }
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
	#$self->getMimeEntity->head->add($name, $value);
	$self->getMimeEntity->head->add($name, encode('MIME-Q', $value));
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
	if ($text !~ /<(?:html|body)/) {
	    my $site = $self->session->url->getSiteURL;
	    $text = <<END_HTML;
<html>
<head>
<base href="$site">
</head>
<body>
$text
</body>
</html>
END_HTML
	}
	$self->addHtmlRaw($text);
}


#-------------------------------------------------------------------

=head2 addHtmlRaw ( html ) 

Appends an HTML block to the message without wrapping in a document.

=head3 html

A string of HTML.

=cut

sub addHtmlRaw {
    my $self        = shift;
    my $text        = shift;

    $self->getMimeEntity->attach(
        Charset     => "UTF-8",
        Encoding    => "quoted-printable",
        Data        => encode('utf8', $text ),
        Type        => "text/html",
    );

    return undef;
}


#-------------------------------------------------------------------

=head2 addText ( text ) 

Adds a text message to the email.

=head3 text

A string of text.

=cut

sub addText {
    my $self    = shift;
    my $text    = shift;

    $self->getMimeEntity->attach(
        Charset     => "UTF-8",
        Encoding    => "quoted-printable",
        Data        => encode('utf8', $text ),
        Type        => 'text/plain',
    );

    return undef;
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

=head4 returnPath

The email address to send bounces to.

=head4 contentType

A mime type for the message. Defaults to "multipart/mixed".

=head4 messageId

A unique id for this message, in case you want to see what replies come in for it later. One will be automatically generated if you don't specify this.

=head4 inReplyTo

If this is a reply to a previous message, then you should specify the messageId of the previous message here.

=head3 isInbox

A flag indicating that this email message is from the Inbox, and should follow per user settings
for delivery.

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $headers = shift;
    my $isInbox = shift;
	if ($headers->{toUser}) {
		my $user = WebGUI::User->new($session, $headers->{toUser});
		if (defined $user) {
            my $email;
            if ($isInbox) {
                $email = $user->getInboxNotificationAddresses;
            }
            else {
                $email = $user->profileField("email");
            }
			if ($email) {
				if ($headers->{to}) {
					$headers->{to} .= ','.$email;
				} else {
					$headers->{to} = $email;
				}
			}	
		}
	}
    my $from    = $headers->{from};
    $from ||= do {
        my $CoNa = $session->setting->get('companyName');
        my $CoEm = $session->setting->get("companyEmail");
        $CoNa =~ s/"//g;
        qq{"$CoNa" <$CoEm>}
    };

	my $type    = $headers->{contentType} || "multipart/mixed";
    my $replyTo = $headers->{replyTo}     || $session->setting->get("mailReturnPath");

    # format of Message-Id should be '<unique-id@domain>'
    my $id = $headers->{messageId} || "WebGUI-" . $session->id->generate;
    if ($id !~ m/\@/) {
        my $domain = $from;
        $domain =~ s/^.*\@//msx;
        $domain =~ s/>$//msx;
        $id .= '@' . $domain;
    }
    if ($id !~ m/^<.+?>$/msx) {
        $id =~ s/(^<)|(>$)//msxg;
        $id = "<".$id.">";
    }
	my $message = MIME::Entity->build(
		Type=>$type,
		From=> encode('MIME-Q', $from),
		To=> encode('MIME-Q', $headers->{to}),
		Cc=> encode('MIME-Q', $headers->{cc}),
		Bcc=> encode('MIME-Q', $headers->{bcc}),
		"Reply-To"=> encode('MIME-Q', $replyTo),
		"In-Reply-To"=> encode('MIME-Q', $headers->{inReplyTo}),
		Subject=> encode('MIME-Q', $headers->{subject}),
		"Message-Id"=>$id,
		Date=>$session->datetime->epochToMail,
		"X-Mailer"=>"WebGUI"
		);
	$message->head->add("X-Return-Path", $headers->{returnPath} || $session->setting->get("mailReturnPath") || $from);
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
    return bless {
        _message     => $message,
        _session     => $session,
        _toGroup     => $headers->{toGroup},
        _isInbox     => $isInbox,
        _footerAdded => 0,
    }, $class;
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

#----------------------------------------------------------------------------

=head2 getMimeEntity ( )

Returns the MIME::Entity object associated with this mail message.

=cut

sub getMimeEntity {
    my $self        = shift;
    return $self->{_message};
}

#-------------------------------------------------------------------

=head2 queue ( )

Puts this message in the mail queue so it can be sent out later by the workflow system. Returns a messageId so that the message can be retrieved later if necessary. Note that this is the preferred method of sending messages because it keeps WebGUI running faster.

=cut

sub queue {
	my $self = shift;
	return $self->session->db->setRow("mailQueue", "messageId", { messageId=>"new", message=>$self->getMimeEntity->stringify, toGroup=>$self->{_toGroup} });
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
	$self->getMimeEntity->head->replace($name, $value);
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

Sends the message via the SMTP server defined in the settings.  If the config file setting
emailToLog is set to a true value, then the message is sent to the WebGUI log file with
priority WARN.

Returns 1 if successful.

=cut

sub send {
    my $self       = shift;
    my $session    = $self->session;
    my $log        = $session->log;
    
    my $mail       = $self->getMimeEntity;
    my $smtpServer = $session->setting->get("smtpServer"); 
    my $status     = 1;
    
    if ($mail->parts <= 1) {
        $mail->make_singlepart;
    }
    if ($mail->head->get("To")) {
        if ($session->config->get("emailToLog")){
            my $message = $mail->stringify;
            $log->warn(qq{$message
            \nTHIS MESSAGE WAS NOT SENT THROUGH THE MAIL SERVER.  TO RE-ENABLE MAIL, DISABLE THE emailToLog SETTING IN THE CONFIG FILE.
            });
        }
        elsif ($smtpServer =~ /\/sendmail/) {
            if (open(MAIL,"| ".$smtpServer." -t -oi -oem")) {
                $mail->print(\*MAIL);
                close(MAIL) or $log->error("Couldn't close connection to mail server: ".$smtpServer);
            } 
            else {
                $log->error("Couldn't connect to mail server: ".$smtpServer);
                $status = 0;
            }
        } 
        else {
            my $smtp = Net::SMTP->new($smtpServer); # connect to an SMTP server
            if (defined $smtp) {
                $smtp->mail($mail->head->get('X-Return-Path')); 
                $smtp->to(  split(',', $mail->head->get('to')  )); 
                $smtp->cc(  split(',', $mail->head->get('cc')  ));
                $smtp->bcc( split(',', $mail->head->get('bcc') ));
                $smtp->data();              # Start the mail
                $smtp->datasend($mail->stringify);
                $smtp->dataend();           # Finish sending the mail
                $smtp->quit;                # Close the SMTP connection
            } 
            else {
                $log->error("Couldn't connect to mail server: ".$smtpServer);
                $status = 0;
            }
        }
    }

    # due to the large number of emails that may be generated by sending emails to a group,
    # emails to members of a group are queued rather than sent directly
    my $group = $self->{_toGroup};
    delete $self->{_toGroup};
    if ($group) {
        my $group = WebGUI::Group->new($self->session, $group);
        return $status if !defined $group;
        $mail->head->replace('bcc', undef);
        $mail->head->replace('cc',  undef);
        USER: foreach my $userId (@{$group->getAllUsers(1)}) {
            my $user = WebGUI::User->new($self->session, $userId);
            next USER unless $user->status eq 'Active';    ##Don't send this to invalid user accounts
            my $emailAddress;
            if ($self->{_isInbox}) {
                $emailAddress = $user->getInboxNotificationAddresses;
            }
            else {
                $emailAddress = $user->profileField('email');
            }
            next USER unless $emailAddress;
            $mail->head->replace('To', $emailAddress);
            $self->queue;
        }
        #Delete the group if it is flagged as an AdHocMailGroup
        $group->delete if ($group->isAdHocMailGroup);
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

