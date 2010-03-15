package WebGUI::Session::Output;

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
use WebGUI::Macro;

=head1 NAME

Package WebGUI::Session::Output

=head1 DESCRIPTION

This class provides a handler for returning output. Through this we can apply filters (like macros), and simple page caching mechanisms.

=head1 SYNOPSIS

 $session->output->print($content);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 new ( session )

Constructor. 

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class;
}

#-------------------------------------------------------------------

=head2 print ( content, skipMacros ) 

Outputs content to either the web server or standard out, depending on which is available.

=head3 content

The content to output.

=head3 skipMacros

A boolean indicating whether to skip macro processing on this content.  If the mime type
has been set to a non-text type, macros will automatically be skipped.

=cut

sub print {
    my $self       = shift;
    my $content    = shift;
    my $skipMacros = shift || !($self->session->http->getMimeType =~ /^text/);
    WebGUI::Macro::process($self->session, \$content) unless $skipMacros;
    my $handle = $self->{_handle};
    if (defined $handle) {
        print $handle $content;
    }
    elsif ($self->session->request) {
        # TODO - put in IO bound delayed response
        $self->session->response->body( $self->session->response->body() . $content );
#        if (ref $self->session->request->body eq 'ARRAY') {
#            push @{$self->session->request->body}, $content;
#        } else {
#            if ($self->session->request->logger) {
#                $self->session->request->logger->({ level => 'warn', message => "dropping content: $content" });
#            } else {
#                warn "dropping content";#: $content";
#            }
#        }
#        $self->session->request->print($content);
    }
    else {
        print $content;
    }
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

=head2 setHandle ( handle ) 

Sets a handle to print the content to. If we're running in command line mode, WebGUI assumes we're printing to standard out, and if we were called through mod_perl it assumes we're printing to that. 

=head3 handle

An open FILE handle that WebGUI can print to.

=cut

sub setHandle {
	my $self = shift;
	my $handle = shift;
	$self->{_handle} = $handle;
}


1;
