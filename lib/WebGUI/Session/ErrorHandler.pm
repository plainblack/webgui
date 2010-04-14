package WebGUI::Session::ErrorHandler;

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
use WebGUI::Paths;
use JSON;
use HTML::Entities qw(encode_entities);
use Log::Log4perl;
use WebGUI::Exception;

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
    @_ = ($self->session->user->username." (".$self->session->user->userId.") ".$message);
    goto $self->can('info');
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
This method caches its value, so long processes may need to manually clear the cached in $self->{_canShowDebug}.

=cut

sub canShowDebug {
    my $self = shift;

    # if we have a cached false value, we can use it
    # true values need additional checks
    if (exists $self->{_canShowDebug} && !$self->{_canShowDebug}) {
        return 0;
    }

    ##This check prevents in infinite loop during startup.
    return 0 unless ($self->session->hasSettings);

    # Allow programmers to stop debugging output for certain requests
    return 0 if $self->{_preventDebugOutput};

    my $canShow = $self->session->setting->get("showDebug")
        && $self->canShowBasedOnIP('debugIp');
    $self->{_canShowDebug} = $canShow;

    return $canShow
        && substr($self->session->http->getMimeType(),0,9) eq "text/html";
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
    @_ = ({ level => 'debug', message => $message });
    goto $self->getLogger;
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
    @_ = ({ level => 'error', message => $message});
    goto $self->getLogger;
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
    Sub::Uplevel::uplevel( 1, $self->getLogger, { level => 'fatal', message => $message});
    WebGUI::Error::Fatal->throw( error => $message );
}


#-------------------------------------------------------------------

=head2 getLogger ( )

Returns a reference to the logger.

=cut

sub getLogger {
    my $self = shift;
    if (my $req = $self->session->request) {
        my $logger = $req->logger;
        return $logger
            if $logger;
    }

    # Thanks to Plack, wG has been decoupled from Log4Perl
    # However when called outside a web context, we currently still fall back to Log4perl
    # (pending a better idea)
    Log::Log4perl->init_once( $self->session->config->getWebguiRoot . "/etc/log.conf" );
    my $log4perl = Log::Log4perl->get_logger( $self->session->config->getFilename );
    sub {
        my $args  = shift;
        my $level = $args->{level};
        $log4perl->$level( $args->{message} );
    };
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
    @_ = ({ level => 'info', message => $message});
    goto $self->getLogger;
}

#-------------------------------------------------------------------

=head2 new ( session ) 

Constructor. Instanciates a new error handler instance.

=head3 session

An active WebGUI::Session object.

=cut

sub new {
    my $class   = shift;
    my $session = shift;

    my $logger = $session->request && $session->request->logger;
    bless { _session => $session, _logger => $logger }, $class;
}

#----------------------------------------------------------------------------

=head2 preventDebugOutput ( )

Prevent this session from sending debugging output even if we're supposed to.

Some times we need to use 'text/html' to send non-html content (these may be
browser limitations, but we need to work with them).

=cut

sub preventDebugOutput {
    my ( $self ) = @_;
    $self->{_preventDebugOutput} = 1;
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
    @_ = ($self->session->user->username." (".$self->session->user->userId.") connecting from "
        .$self->session->env->getIp." attempted to ".$message);
    goto $self->can('warn');
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

=head2 warn ( message )

Adds a WARN type message to the log. These events should be things that are potentially severe, but not errors, such as security attempts or ineffiency problems.

=head3 message

The message you wish to add to the log.

=cut

sub warn {
    my $self = shift;
    my $message = shift;
    @_ = ({ level => 'warn', message => $message});
    goto $self->getLogger;
}

1;

