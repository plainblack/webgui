package WebGUI::Mail;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Net::SMTP;
use strict;
use WebGUI::ErrorHandler;
use WebGUI::Session;

#-------------------------------------------------------------------
#eg: send("jt@jt.com","hi, how are you","this is my message","bob@bob.com","you@ther.com");
#eg: send(to,subject,message,cc,from,bcc);
sub send {
        my ($smtp, $message, $from);
	$from = $_[4] || ($session{setting}{companyName}.' <'.$session{setting}{companyEmail}.'>');
	#header
	$message = "To: $_[0]\n";
        $message .= "From: $from\n";
        $message .= "CC: $_[3]\n" if ($_[3]);
        $message .= "BCC: $_[5]\n" if ($_[5]);
        $message .= "Subject: ".$_[1]."\n";
        $message .= "\n";
        #body
        $message .= $_[2]."\n";
	#footer
        $message .= "\n $session{setting}{companyName}\n $session{setting}{companyEmail}\n $session{setting}{companyURL}\n";
	if ($session{setting}{smtpServer} =~ /\/sendmail/) {
		open(MAIL,'| '.$session{setting}{smtpServer}.' -t -oi') or WebGUI::ErrorHandler::warn("Couldn't connect to mail server: ".$session{setting}{smtpServer});
		print MAIL $message;
		close(MAIL);
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
