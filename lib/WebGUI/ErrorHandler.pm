package WebGUI::ErrorHandler;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use FileHandle;
use strict;
use WebGUI::Session;


=head1 NAME 

Package WebGUI::ErrorHandler

=head1 DESCRIPTION

This package provides simple but effective error handling and logging for WebGUI.

=head1 SYNOPSIS

 use WebGUI::ErrorHandler;

 WebGUI::ErrorHandler::audit(message);
 WebGUI::ErrorHandler::fatalError();
 WebGUI::ErrorHandler::security(message);
 WebGUI::ErrorHandler::warn(message);

 WebGUI::ErrorHandler::getAudit();
 WebGUI::ErrorHandler::getSecurity();
 WebGUI::ErrorHandler::getSessionVars();
 WebGUI::ErrorHandler::getStackTrace();
 WebGUI::ErrorHandler::getWarnings();

 WebGUI::ErrorHandler::showAudit();
 WebGUI::ErrorHandler::showDebug();
 WebGUI::ErrorHandler::showSecurity();
 WebGUI::ErrorHandler::showSessionVars();
 WebGUI::ErrorHandler::showStackTrace();
 WebGUI::ErrorHandler::showWarnings();

 WebGUI::ErrorHandler::stamp($type);
 WebGUI::ErrorHandler::writeLog($message);

=head1 METHODS

These functions are available from this package:

=cut



#-------------------------------------------------------------------

=head2 audit ( message )

Inserts an AUDIT type message into the WebGUI log.

=over

=item message

Whatever message you wish to insert into the log.

=back

=cut

sub audit {
        my $data = stamp("AUDIT").$WebGUI::Session::session{user}{username}
		." (".$WebGUI::Session::session{user}{userId}.") ".$_[0]."\n";
        writeLog($data);
        $WebGUI::Session::session{debug}{audit} .= $data;
}


#-------------------------------------------------------------------

=head2 fatalError ( )

Outputs an error message to the user and logs an error. Should only be called if the system cannot recover from an error, or if it would be unsafe to attempt to recover from an error (like compile errors or database errors).

=cut

sub fatalError {
        my $cgi;
	if (exists $WebGUI::Session::session{cgi}) {
		$cgi = $WebGUI::Session::session{cgi};
	} else {
		use CGI;
		$cgi = CGI->new;
	}
	print $cgi->header;
	my $toLog = stamp("FATAL").$_[0]."\n";
	$toLog .= getStackTrace();
	$toLog .= getSessionVars();
        writeLog($toLog);
        unless ($WebGUI::Session::session{setting}{showDebug}) {
		#NOTE: You can't internationalize this because with some types of errors that would cause an infinite loop.                
		print "<h1>Problem With Request</h1>                        
			We have encountered a problem with your request. Please use your back button and try again.                         
			If this problem persists, please contact us with what you were trying to do and the time and date of the problem.";
                print '<br>'.$WebGUI::Session::session{setting}{companyName};
                print '<br>'.$WebGUI::Session::session{setting}{companyEmail};
                print '<br>'.$WebGUI::Session::session{setting}{companyURL};
        } else {
	        print "<h1>WebGUI Fatal Error</h1>Something unexpected happened that caused this system to fault.<p>"; 
		print $_[0]."<p>";
		print showStackTrace();
		print showDebug();
	}
	WebGUI::Session::close();
        exit;
}


#-------------------------------------------------------------------

=head2 getAudit ( )

Returns a text formatted message containing the audit messages.

=cut

sub getAudit {
        return $WebGUI::Session::session{debug}{audit};
}


#-------------------------------------------------------------------

=head2 getSecurity ( )

Returns a text formatted message containing the security messages.

=cut

sub getSecurity {
        return $WebGUI::Session::session{debug}{security};
}


#-------------------------------------------------------------------

=head2 getSessionVars ( )

Returns a text message containing all of the session variables.

=cut

sub getSessionVars {
	my $data;
       	while (my ($section, $hash) = each %WebGUI::Session::session) {
		if ($section eq "debug") {
			next;
		} elsif (ref $hash eq 'HASH') {
                        while (my ($key, $value) = each %$hash) {
                               if (ref $value eq 'ARRAY') {
                                        $value = '['.join(', ',@$value).']';
                                } elsif (ref $value eq 'HASH') {
                                        $value = '{'.join(', ',map {"$_ => $value->{$_}"} keys %$value).'}';
                                }
                                unless (lc($key) eq "password" || lc($key) eq "identifier") {
                                        $data .= "\t".$section.'.'.$key.' = '.$value."\n";
                                }
                        }
                } elsif (ref $hash eq 'ARRAY') {
                        my $i = 1;
                        foreach (@$hash) {
                                $data .= "\t".$section.'.'.$i.' = '.$_."\n";
                                $i++;
                        }
                }
       	}
	return $data;
}


#-------------------------------------------------------------------

=head2 getStackTrace ( )

Returns a text formatted message containing the current stack trace.

=cut

sub getStackTrace {
	my $i = 2;
	my $output;
	while (my @data = caller($i)) {
		$output .= "\t".join(",",@data)."\n";
		$i++;
	}
	return $output;
}


#-------------------------------------------------------------------

=head2 getWarnings ( )

Returns a text formatted message containing the warnings.

=cut

sub getWarnings {
        return $WebGUI::Session::session{debug}{warning};
}


#-------------------------------------------------------------------

=head2 security ( message )

Adds a SECURITY type message to the log.

=over

=item message

The message you wish to add to the log.

=back

=cut

sub security {
        my $data = stamp("SECURITY").$WebGUI::Session::session{user}{username}
		." (".$WebGUI::Session::session{user}{userId}
		.") connecting from ".$WebGUI::Session::session{env}{REMOTE_ADDR}." attempted to ".$_[0]."\n";
        writeLog($data);
        $WebGUI::Session::session{debug}{security} .= $data;
}


#-------------------------------------------------------------------

=head2 showAudit ( )

Returns an HTML formatted message with the audit messages for display during debug operations.

=cut

sub showAudit {
	my $audit = getAudit();
	$audit =~  s/\n/\<br\>\n/g;
	return '<div style="background-color: #ffffdd;color: #000000;">'.$audit.'</div>';
}


#-------------------------------------------------------------------

=head2 showDebug ( )

Creates an HTML formatted string containing the most common debug information.

=cut

sub showDebug {
        return showWarnings()
		.showSecurity()
		.showAudit()
		.showSessionVars();
}


#-------------------------------------------------------------------

=head2 showSecurity ( )

Returns an HTML formatted message with the security messages for display during debug operations.

=cut

sub showSecurity {
	my $security = getSecurity();
	$security =~  s/\n/\<br\>\n/g;
	return '<div style="background-color: #800000;color: #ffffff;">'.$security.'</div>';
}


#-------------------------------------------------------------------

=head2 showSessionVars ( )

Returns an HTML formatted list of the session variables for display during debug operations.

=cut

sub showSessionVars {
	my $data = getSessionVars();
	$data =~ s/\n/\<br\>\n/g;
	return '<div style="background-color: #ffffff; color: #000000; font-size: 10pt; font-family: helvetica;">'.$data.'</div>';
}


#-------------------------------------------------------------------

=head2 showStackTrace ( )

Returns an HTML formatted message for displaying the stack trace during debug operations.

=cut

sub showStackTrace {
	my $st = getStackTrace();
	$st =~ s/\n/\<br\>\n/g;
	return $st;
}


#-------------------------------------------------------------------

=head2 showWarnings ( )

Returns HTML formatted warnings for display during debug operations.

=cut

sub showWarnings {
	my $warning = getWarnings();
	$warning =~  s/\n/\<br\>\n/g;
	return '<div style="background-color: #ffdddd;color: #000000;">'.$warning.'</div>';
}


#-------------------------------------------------------------------

=head2 stamp ( type )

Generates a stamp to be added to the log file. Use this in conjunction with your message for writeLog().

=over

=item type

The type of message this is. You may use whatever type you wish. WebGUI currently uses AUDIT, WARNING, FATAL, and SECURITY.

=back

=cut

sub stamp {
        return localtime(time)." ".$0." ".$_[0].": ";
}


#-------------------------------------------------------------------

=head2 warn ( message )

Adds a WARNING type message to the log.

=over

=item message

The message you wish to add to the log.

=back

=cut

sub warn {
        my $data = stamp("WARNING").$_[0]."\n";
	writeLog($data);	
        $WebGUI::Session::session{debug}{warning} .= $data;
}

#-------------------------------------------------------------------

=head2 writeLog ( message )

Writes a message to the log.

=over 

=item message

The message you wish to write to the log.

=back

=cut

sub writeLog {
        if (my $log = FileHandle->new(">>".$WebGUI::Session::session{config}{logfile})) {
		print $log $_[0];
		$log->close;
	} else {
		use CGI;
                my $cgi = CGI->new;
		print STDOUT $cgi->header(). "Can't open log file: ".$WebGUI::Session::session{config}{logfile}." Check your WebGUI configuration file to set the path of the log file, and check to be sure the web server has the privileges to write to the log file.";;
		WebGUI::Session::close();
		exit;
	}
}


1;

