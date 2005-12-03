package WebGUI::ErrorHandler;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use FileHandle;
use Log::Log4perl;
use strict;
use WebGUI::Session;
use Apache2::RequestUtil;

$Log::Log4perl::caller_depth++;

=head1 NAME 

Package WebGUI::ErrorHandler

=head1 DESCRIPTION

This package provides simple but effective error handling, debugging,  and logging for WebGUI.

=head1 SYNOPSIS

 use WebGUI::ErrorHandler;

 WebGUI::ErrorHandler::audit(message);
 WebGUI::ErrorHandler::fatalError();
 WebGUI::ErrorHandler::security(message);
 WebGUI::ErrorHandler::warn(message);

 WebGUI::ErrorHandler::getSecurity();
 WebGUI::ErrorHandler::getSessionVars();
 WebGUI::ErrorHandler::getStackTrace();

 WebGUI::ErrorHandler::showDebug();
 WebGUI::ErrorHandler::showStackTrace();
 WebGUI::ErrorHandler::showWarnings();

 WebGUI::ErrorHandler::stamp($type);
 WebGUI::ErrorHandler::writeLog($message);

=head1 METHODS

These functions are available from this package:

=cut



#-------------------------------------------------------------------

=head2 audit ( message )

A convenience function that wraps info() and includes the current username and user ID in addition to the message being logged.

=head3 message

Whatever message you wish to insert into the log.

=cut

sub audit {
	my $message = shift;
	$Log::Log4perl::caller_depth++;
        info($WebGUI::Session::session{user}{username}." (".$WebGUI::Session::session{user}{userId}.") ".$message);
	$Log::Log4perl::caller_depth--;
}


#-------------------------------------------------------------------

=head2 canShowDebug ( )

Returns true if the user meets the condition to see debugging information and debug mode is enabled.

=cut

sub canShowDebug {
       		return (
				(
					$WebGUI::Session::session{setting}{showDebug}
				) && (
					$WebGUI::Session::session{env}{REMOTE_ADDR} =~ /^$WebGUI::Session::session{setting}{debugIp}/ || 
					$WebGUI::Session::session{setting}{debugIp} eq ""
				)
			);
}

#-------------------------------------------------------------------

=head2 canShowPerformanceIndicators ()

Returns true if the user meets the conditions to see performance indicators and performance indicators are enabled.

=cut

sub canShowPerformanceIndicators {
		my $mask = $WebGUI::Session::session{setting}{debugIp};
		my $ip = $WebGUI::Session::session{env}{REMOTE_ADDR};
       		return (
				(
					$WebGUI::Session::session{setting}{showPerformanceIndicators} 
				) && (
					$ip =~ /^$mask/ || 
					$WebGUI::Session::session{setting}{debugIp} eq ""
				)
			);
}


#-------------------------------------------------------------------

=head2 debug ( message )

Adds a DEBUG type message to the log. These events should be things that are only used for diagnostic purposes.

=head3 message

The message you wish to add to the log.

=cut

sub debug {
	my $message = shift;
	my $logger = getLogger();
	$logger->debug($message);
        $WebGUI::Session::session{debug}{'debug'} .= $message."\n";
}


#-------------------------------------------------------------------

=head2 error ( message )

Adds a ERROR type message to the log. These events should be things that are errors that are not fatal. For instance, a non-compiling plug-in or erroneous user input.

=head3 message

The message you wish to add to the log.

=cut

sub error {
	my $message = shift;
	my $logger = getLogger();
	$logger->error($message);
	$logger->debug("Stack trace for ERROR ".$message."\n".getStackTrace());
        $WebGUI::Session::session{debug}{'error'} .= $message."\n";
}


#-------------------------------------------------------------------

=head2 fatal ( )

Adds a FATAL type message to the log, outputs an error message to the user, and forces a close on the session. This should only be called if the system cannot recover from an error, or it would be unsafe to recover from an error like database connectivity problems.

=cut

sub fatal {
	my $message = shift;
	my $logger = getLogger();
	Apache2::RequestUtil->request->content_type('text/html') if ($WebGUI::Session::session{req});
	$logger->fatal($message);
	$logger->debug("Stack trace for FATAL ".$message."\n".getStackTrace());
        unless ($WebGUI::Session::session{setting}{showDebug}) {
		#NOTE: You can't internationalize this because with some types of errors that would cause an infinite loop.                
		print "<h1>Problem With Request</h1>                        
			We have encountered a problem with your request. Please use your back button and try again.                         
			If this problem persists, please contact us with what you were trying to do and the time and date of the problem.";
                print '<br />'.$WebGUI::Session::session{setting}{companyName};
                print '<br />'.$WebGUI::Session::session{setting}{companyEmail};
                print '<br />'.$WebGUI::Session::session{setting}{companyURL};
        } else {
	        print "<h1>WebGUI Fatal Error</h1><p>Something unexpected happened that caused this system to fault.</p>\n"; 
		print "<p>".$message."</p>\n";
		print showDebug();
	}
	WebGUI::Session::close();
        exit;
}


#-------------------------------------------------------------------

=head2 getLogger ( )

Returns a reference to the logger.

=cut

sub getLogger {
	Log::Log4perl::init_once($WebGUI::Session::session{config}{webguiRoot}."/etc/log.conf");
	return Log::Log4perl->get_logger($WebGUI::Session::session{config}{configFile});
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

=head2 info ( message )

Adds an INFO  type message to the log. This should be used for informational or status types of messages, such as audit information and FYIs.

=head3 message

The message you wish to add to the log.

=cut

sub info {
	my $message = shift;
	my $logger = getLogger();
	$logger->info($message);
	$WebGUI::Session::session{debug}{'info'} .= $message."\n";
}


#-------------------------------------------------------------------

=head2 security ( message )

A convenience function that wraps warn() and includes the current username, user ID, and IP address in addition to the message being logged.

=head3 message

The message you wish to add to the log.

=cut

sub security {
	my $message = shift;
	$Log::Log4perl::caller_depth++;
        WebGUI::ErrorHandler::warn($WebGUI::Session::session{user}{username}." (".$WebGUI::Session::session{user}{userId}.") connecting from "
		.$WebGUI::Session::session{env}{REMOTE_ADDR}." attempted to ".$message);
	$Log::Log4perl::caller_depth--;
}


#-------------------------------------------------------------------

=head2 showDebug ( )

Creates an HTML formatted string 

=cut

sub showDebug {
	my $text = $WebGUI::Session::session{debug}{'error'};
	$text =~  s/\n/\<br \/\>\n/g;
	my $output = 'beginDebug<br /><div style="background-color: #800000;color: #ffffff;">'.$text."</div>\n";
	$text = $WebGUI::Session::session{debug}{'warn'};
	$text =~  s/\n/\<br \/\>\n/g;
	$output .= '<div style="background-color: #ffdddd;color: #000000;">'.$text."</div>\n";
	$text = $WebGUI::Session::session{debug}{'info'};
	$text =~  s/\n/\<br \/\>\n/g;
	$output .= '<div style="background-color: #ffffdd;color: #000000;">'.$text."</div>\n";
	$text = $WebGUI::Session::session{debug}{'debug'};
	$text =~  s/\n/\<br \/\>\n/g;
	$output .= '<div style="background-color: #dddddd;color: #000000;">'.$text."</div>\n";
	$text = getSessionVars();
	$text =~  s/\n/\<br \/\>\n/g;
	$output .= '<div style="background-color: #ffffff;color: #000000;">'.$text."</div>\n";
	return $output;
}



#-------------------------------------------------------------------

=head2 warn ( message )

Adds a WARN type message to the log. These events should be things that are potentially severe, but not errors, such as security attempts or ineffiency problems.

=head3 message

The message you wish to add to the log.

=cut

sub warn {
	my $message = shift;
	my $logger = getLogger();
	$logger->warn($message);
	$WebGUI::Session::session{debug}{'warn'} .= $message."\n";
}


1;

