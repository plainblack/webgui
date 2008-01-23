package WebGUI::Session::ErrorHandler;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Log::Log4perl;
use Apache2::RequestUtil;
use JSON;
use HTML::Entities;

=head1 NAME 

Package WebGUI::Session::ErrorHandler

=head1 DESCRIPTION

This package provides simple but effective error handling, debugging,  and logging for WebGUI.

=head1 SYNOPSIS

 use WebGUI::Session::ErrorHandler;

 my $errorHandler = WebGUI::Session::ErrorHandler->new($session);

 $errorHandler->audit($message);
 $errorHandler->debug($message);
 $errorHandler->error($message);
 $errorHandler->fatal($message);
 $errorHandler->info($message);
 $errorHandler->security($message);
 $errorHandler->warn($message);

 $logger = $errorHandler->getLogger;

 $text = $errorHandler->getStackTrace;
 $html = $errorHandler->showDebug;

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 audit ( message )

A convenience function that wraps info() and includes the current username and user ID in addition to the message being logged.

=head3 message

Whatever message you wish to insert into the log.

=cut

sub audit {
	my $self = shift;
	my $message = shift;
        $self->info($self->session->user->username." (".$self->session->user->userId.") ".$message);
}


#-------------------------------------------------------------------

=head2 canShowBasedOnIP ( $ipSetting )

Returns true if the the user's IP address matches the requested IP setting.

=head3 ipSetting

The setting to pull from the database.  It should containt a CSV list of IP
addresses in CIDR format.

=cut

sub canShowBasedOnIP {
	my $self = shift;
	my $ipSetting = shift;
	return 0 unless $ipSetting;
	return 1 if ($self->session->setting->get($ipSetting) eq "");
	my $ips = $self->session->setting->get($ipSetting);
	$ips =~ s/\s+//g;
	my @ips = split(",", $ips);
	my $ok = WebGUI::Utility::isInSubnet($self->session->env->getIp, [ @ips] );
	return $ok;
}

#-------------------------------------------------------------------

=head2 canShowDebug ( )

Returns true if the user meets the condition to see debugging information and debug mode is enabled.

=cut

sub canShowDebug {
	my $self = shift;
	return 0 unless ($self->session->setting->get("showDebug"));
	return 0 unless (substr($self->session->http->getMimeType(),0,9) eq "text/html");
	return $self->canShowBasedOnIP('debugIp');
}

#-------------------------------------------------------------------

=head2 canShowPerformanceIndicators ( )

Returns true if the user meets the conditions to see performance indicators and performance indicators are enabled.

=cut

sub canShowPerformanceIndicators {
	my $self = shift;
	return 0 unless $self->session->setting->get("showPerformanceIndicators");
	return $self->canShowBasedOnIP('debugIp');
}


#-------------------------------------------------------------------

=head2 debug ( message )

Adds a DEBUG type message to the log. These events should be things that are only used for diagnostic purposes.

=head3 message

The message you wish to add to the log.

=cut

sub debug {
	my $self = shift;
	my $message = shift;
	$self->getLogger->debug($message);
        $self->{_debug_debug} .= $message."\n";
}


#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut
	
sub DESTROY {
	my $self = shift;
	$Log::Log4perl::caller_depth--;
	undef $self;
}



#-------------------------------------------------------------------

=head2 error ( message )

Adds a ERROR type message to the log. These events should be things that are errors that are not fatal. For instance, a non-compiling plug-in or erroneous user input.

=head3 message

The message you wish to add to the log.

=cut

sub error {
	my $self = shift;
	my $message = shift;
	$self->getLogger->error($message);
	$self->getLogger->debug("Stack trace for ERROR ".$message."\n".$self->getStackTrace());
        $self->{_debug_error} .= $message."\n";
}


#-------------------------------------------------------------------

=head2 fatal ( message [, flags] )

Adds a FATAL type message to the log, outputs an error message to the user, and forces a close on the session. This should only be called if the system cannot recover from an error, or it would be unsafe to recover from an error like database connectivity problems.

=head3 message

The message to use.

=cut

sub fatal {
	my $self = shift;
	my $message = shift;

	$self->session->http->setStatus("500","Server Error");
	Apache2::RequestUtil->request->content_type('text/html') if ($self->session->request);
	$self->getLogger->fatal($message);
	$self->getLogger->debug("Stack trace for FATAL ".$message."\n".$self->getStackTrace());
	$self->session->http->sendHeader if ($self->session->request);

	if (! defined $self->session->db(1)) {
		# We can't even _determine_ whether we can show the debug text.  Punt.
		$self->session->output->print("<h1>Fatal Internal Error</h1>");
	} 
	elsif ($self->canShowDebug()) {
		$self->session->output->print("<h1>WebGUI Fatal Error</h1><p>Something unexpected happened that caused this system to fault.</p>\n",1);
		$self->session->output->print("<p>".$message."</p>\n",1);
		$self->session->output->print("<pre>" . encode_entities($self->getStackTrace) . "</pre>", 1);
		$self->session->output->print($self->showDebug(),1);
	} 
	else {
		# NOTE: You can't internationalize this because with some types of errors that would cause an infinite loop.
		$self->session->output->print("<h1>Problem With Request</h1>
		We have encountered a problem with your request. Please use your back button and try again.
		If this problem persists, please contact us with what you were trying to do and the time and date of the problem.<br />",1);
		$self->session->output->print('<br />'.$self->session->setting->get("companyName"),1);
		$self->session->output->print('<br />'.$self->session->setting->get("companyEmail"),1);
		$self->session->output->print('<br />'.$self->session->setting->get("companyURL"),1);
	}
	$self->session->close();
	die "fatal: " . $message;
}


#-------------------------------------------------------------------

=head2 getLogger ( )

Returns a reference to the logger.

=cut

sub getLogger {
	my $self = shift;
	return $self->{_logger};
}


#-------------------------------------------------------------------

=head2 getStackTrace ( )

Returns a text formatted message containing the current stack trace.

=cut

sub getStackTrace {
	my $self = shift;
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
	my $self = shift;
	my $message = shift;
	$self->getLogger->info($message);
        $self->{_debug_info} .= $message."\n";
}

#-------------------------------------------------------------------

=head2 new ( session ) 

Constructor. Instanciates a new error handler instance.

=head3 session

An active WebGUI::Session object.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	unless (Log::Log4perl->initialized()) {
		$Log::Log4perl::caller_depth++;
 		Log::Log4perl->init( $session->config->getWebguiRoot."/etc/log.conf" );   
	}
	my $logger = Log::Log4perl->get_logger($session->config->getFilename);
	bless {_queryCount=>0, _logger=>$logger, _session=>$session}, $class;
}

#-------------------------------------------------------------------

=head2 query ( sql ) 

Logs a sql statement for the debugger output.  Keeps track of the #.

=head3 sql

A sql statement string.

=cut

sub query {
	my $self = shift;
	my $query = shift;
	my $placeholders = shift;
	$self->{_queryCount}++;
	my $plac;
	if (defined $placeholders and ref $placeholders eq "ARRAY" && scalar(@{$placeholders})) {
		$plac = "\n&nbsp;&nbsp;with placeholders:&nbsp;&nbsp;['".join("', '",@{$placeholders})."']";
	}
	else {
		$plac = '';
	}
	$self->debug("query  ".$self->{_queryCount}.':  '.$query.$plac);
}



#-------------------------------------------------------------------

=head2 security ( message )

A convenience function that wraps warn() and includes the current username, user ID, and IP address in addition to the message being logged.

=head3 message

The message you wish to add to the log.

=cut

sub security {
	my $self = shift;
	my $message = shift;
	$self->warn($self->session->user->username." (".$self->session->user->userId.") connecting from "
	.$self->session->env->getIp." attempted to ".$message);
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 showDebug ( )

Creates an HTML formatted string of all internally stored debug information, warns,
errors, sql queries and form data.

=cut

sub showDebug {
	my $self = shift;
	my $text = $self->{_debug_error};
	$text =~  s/\n/\<br \/\>\n/g;
	my $output = '<div style="text-align: left;background-color: #800000;color: #ffffff;">'.$text."</div>\n";
	$text = $self->{_debug_warn}; 
	$text =~  s/\n/\<br \/\>\n/g;
	$output .= '<div style="text-align: left;background-color: #ffbdbd;color: #000000;">'.$text."</div>\n";
	$text = $self->{_debug_info}; 
	$text =~  s/\n/\<br \/\>\n/g;
	$output .= '<div style="text-align: left;background-color: #bdffbd;color: #000000;">'.$text."</div>\n";
	my $form = $self->session->form->paramsHashRef();
	foreach my $key (keys %{$form}) {
		if ($key eq "password" || $key eq "identifier") {
			$form->{$key} = "********";
		}
	}
	$text = JSON::objToJson($form, {pretty => 1, indent => 4, autoconv=>0, skipinvalid=>1});
	$text =~ s/&/&amp;/sg;
	$text =~ s/>/&gt;/sg;
	$text =~ s/</&lt;/sg;
	$text =~  s/\n/\<br \/\>\n/g;
	$text =~  s/    /&nbsp; &nbsp; /g;
	$output .= '<div style="text-align: left;background-color: #aaaaee;color: #000000;">'.$text."</div>\n";
	$text = $self->{_debug_debug}; 
	$text =~  s/\n/\<br \/\>\n/g;
	$output .= '<div style="text-align: left;background-color: #cccc55;color: #000000;">'.$text."</div>\n";
	return $output;
}



#-------------------------------------------------------------------

=head2 warn ( message )

Adds a WARN type message to the log. These events should be things that are potentially severe, but not errors, such as security attempts or ineffiency problems.

=head3 message

The message you wish to add to the log.

=cut

sub warn {
	my $self = shift;
	my $message = shift;
	$self->getLogger->warn($message);
        $self->{_debug_warn} .= $message."\n";
}


1;

