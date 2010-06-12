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
use WebGUI::Exception;
use Sub::Uplevel;
use Scalar::Util qw(weaken);

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
    @_ = ($self, $self->session->user->username." (".$self->session->user->userId.") ".$message);
    goto $self->can('info');
}

#-------------------------------------------------------------------

=head2 canShowPerformanceIndicators ( )

Returns true if the user meets the conditions to see performance indicators and performance indicators are enabled.

=cut

sub performanceLogger {
    my $self = shift;
    my $request = $self->session->request;
    return
        unless $request;
    my $logger = $request->env->{'webgui.perf.logger'};
    return $logger;
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
    $_[0]->{_logger};
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

    my $self = bless { _session => $session }, $class;
    weaken $self->{_session};
    my $logger = $session->request && $session->request->logger;
    if ( !$logger ) {

        # Thanks to Plack, wG has been decoupled from Log4Perl
        # However when called outside a web context, we currently still fall back to Log4perl
        # (pending a better idea)
        require Log::Log4perl;
        Log::Log4perl->init_once( WebGUI::Paths->logConfig );
        my $log4perl = Log::Log4perl->get_logger( $session->config->getFilename );
        $logger = sub {
            my $args  = shift;
            my $level = $args->{level};
            local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1;
            $log4perl->$level( $args->{message} );
        };
    }
    $self->{_logger} = $logger;
    return $self;
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
    @_ = ($self, $self->session->user->username." (".$self->session->user->userId.") connecting from "
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

