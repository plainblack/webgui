package WebGUI::Mail;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
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
#eg: send("jt@jt.com","hi, how are you","this is my message","bob@bob.com");
#eg: send(to,subject,message,cc);
sub send {
        my ($smtp);
        $smtp = Net::SMTP->new($session{setting}{smtpServer}); # connect to an SMTP server
        if (defined $smtp) {
        	$smtp->mail($session{setting}{companyEmail});     # use the sender's address here
        	$smtp->to($_[0]);             # recipient's address
        	$smtp->data();              # Start the mail
        	# Send the header.
        	$smtp->datasend("To: ".$_[0]."\n");
        	$smtp->datasend("From: $session{setting}{companyName} <$session{setting}{companyEmail}>\n");
        	$smtp->datasend("CC: $_[3]\n") if ($_[3]);
        	$smtp->datasend("Subject: ".$_[1]."\n");
        	$smtp->datasend("\n");
        	# Send the body.
        	$smtp->datasend($_[2]);
        	$smtp->datasend("\n\n $session{setting}{companyName}\n $session{setting}{companyEmail}\n $session{setting}{companyURL}\n");
        	$smtp->dataend();           # Finish sending the mail
        	$smtp->quit;                # Close the SMTP connection
        } else {
                WebGUI::ErrorHandler::warn("Couldn't connect to mail server: ".$session{setting}{smtpServer});
        }
}




1;
