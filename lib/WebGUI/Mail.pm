package WebGUI::Mail;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Macro;
use WebGUI::Session;

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

=over

=item to 

An email address for the TO line.

=item subject

The subject line for the email.

=item message

The message body for the email.

=item cc

The email address for the CC line.

=item from

The email address for the FROM line. Defaults to the email address specified in the Company Settings.

=item bcc

The email address for the BCC line.

=back

=cut

sub send {
        my ($smtp, $message, $from, $footer);
	$from = $_[4] || $session{setting}{companyEmail};
	#header
	$message = "To: $_[0]\n";
        $message .= "From: $from\n";
        $message .= "CC: $_[3]\n" if ($_[3]);
        $message .= "BCC: $_[5]\n" if ($_[5]);
        $message .= "Subject: ".$_[1]."\n";
	$message .= "Date: ".WebGUI::DateTime::epochToHuman("","%W, %d %C %y %j:%n:%s %O")."\n";
        $message .= "\n";
	$message = WebGUI::Macro::process($message);
        #body
        $message .= $_[2]."\n";
	#footer
	$message .= WebGUI::Macro::process("\n".$session{setting}{mailFooter});
	if ($session{setting}{smtpServer} =~ /\/sendmail/) {
		if (open(MAIL,"| $session{setting}{smtpServer} -t -oi")) {
			print MAIL $message;
			close(MAIL) or WebGUI::ErrorHandler::warn("Couldn't close connection to mail server: ".$session{setting}{smtpServer});
		} else {
			WebGUI::ErrorHandler::warn("Couldn't connect to mail server: ".$session{setting}{smtpServer});
		}
	} else {
        	$smtp = Net::SMTP->new($session{setting}{smtpServer}); # connect to an SMTP server
        	if (defined $smtp) {
        		$smtp->mail($from);     # use the sender's address here
        		$smtp->to($_[0]);             # recipient's address
        		$smtp->cc($_[3]) if ($_[3]);          
        		$smtp->bcc($_[5]) if ($_[5]);         
        		$smtp->data();              # Start the mail
        		$smtp->datasend($message);
        		$smtp->dataend();           # Finish sending the mail
        		$smtp->quit;                # Close the SMTP connection
        	} else {
                	WebGUI::ErrorHandler::warn("Couldn't connect to mail server: ".$session{setting}{smtpServer});
        	}
	}
}




1;
