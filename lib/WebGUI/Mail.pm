package WebGUI::Mail;

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
use strict;
use WebGUI::Macro;

=head1 NAME

Package WebGUI::Mail

=head1 DESCRIPTION

This package provides access to use SMTP based email services.

=head1 SYNOPSIS

use WebGUI::Mail;
WebGUI::Mail::send($to,$subject,$message);

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 send ( to, subject, message [ , cc, from, bcc ] )

Sends an SMTP email message to the specified user.

=head3 to

An email address for the TO line.

=head3 subject

The subject line for the email.

=head3 message

The message body for the email.

=head3 cc

The email address for the CC line.

=head3 from

The email address for the FROM line. Defaults to the email address specified in the Company Settings.

=head3 bcc

The email address for the BCC line.

=cut

sub send {
#	my ($smtp, $message, $from);
#	foreach my $option (\$_[0], \$_[1], \$_[3], \$_[4], \$_[5]) {
#		if(${$option}) {
#			if (${$option} =~ /(?:From|To|Date|X-Mailer|Subject|Received|Message-Id)\s*:/is) {
#				use WebGUI::ErrorHandler;
#				return $self->session->errorHandler->security("pass a malicious value to the mail header.");
#			}
#		}
#	}
#	$from = $_[4] || $self->session->setting->get("companyEmail");
#	#header
#	my $to = $self->session->config->get("emailOverride") || $_[0];
#	$message = "To: $to\n";
#	$message .= "From: $from\n";
#	$message .= "CC: $_[3]\n" if ($_[3] && !$self->session->config->get("emailOverride"));
#	$message .= "BCC: $_[5]\n" if ($_[5] && !$self->session->config->get("emailOverride"));
#	$message .= "Subject: ".$_[1]."\n";
#	$message .= "Date: ".$self->session->datetime->epochToHuman("","%W, %d %C %y %j:%n:%s %O")."\n";
#	if (($_[2] =~ m/<html>/i) || ($_[2] =~ m/<a\sname=/i)) {
#		$message .= "Content-Type: text/html; charset=UTF-8\n";
#	} else {
#		$message .= "Content-Type: text/plain; charset=UTF-8\n";
#	}
#	$message .= "\n";
#	WebGUI::Macro::process($self->session,\$message);
	#body
#	$message .= $_[2]."\n";
	#footer
#	my $footer = "\n".$self->session->setting->get("mailFooter");
#	WebGUI::Macro::process($self->session,\$footer);
#	$message .= $footer;
#	$message .= "\n\n\nThis message was intended for ".$_[0].", but was overridden in the config file.\n\n\n" if ($self->session->config->get("emailOverride"));
#	if ($self->session->setting->get("smtpServer") =~ /\/sendmail/) {
#		if (open(MAIL,"| $self->session->setting->get("smtpServer") -t -oi")) {
#			print MAIL $message;
#			close(MAIL) or $self->session->errorHandler->warn("Couldn't close connection to mail server: ".$self->session->setting->get("smtpServer"));
#		} else {
#			$self->session->errorHandler->warn("Couldn't connect to mail server: ".$self->session->setting->get("smtpServer"));
#		}
#	} else {
#		$smtp = Net::SMTP->new($self->session->setting->get("smtpServer")); # connect to an SMTP server
#		if (defined $smtp) {
#			$smtp->mail($from);     # use the sender's address here
#			$smtp->to($to);             # recipient's address
#			$smtp->cc($_[3]) if ($_[3] && !$self->session->config->get("emailOverride"));
#			$smtp->bcc($_[5]) if ($_[5] && !$self->session->config->get("emailOverride"));
#			$smtp->data();              # Start the mail
#			$smtp->datasend($message);
#			$smtp->dataend();           # Finish sending the mail
#			$smtp->quit;                # Close the SMTP connection
#		} else {
#			$self->session->errorHandler->warn("Couldn't connect to mail server: ".$self->session->setting->get("smtpServer"));
#		}
#	}
}

1;
