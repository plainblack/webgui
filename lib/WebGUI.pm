package WebGUI;


our $VERSION = '8.0.0';
our $STATUS = 'beta';


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
use Moose;
use MooseX::NonMoose;
use WebGUI::Config;
use WebGUI::Pluggable;
use WebGUI::Paths;
use WebGUI::Types;
use Try::Tiny;

extends 'Plack::Component';

=head1 NAME

Package WebGUI

=head1 DESCRIPTION

PSGI handler for WebGUI.

=head1 SYNOPSIS

 use WebGUI;

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

has config  => (
    is => 'ro',
    required => 1,
    isa => 'WebGUI::Type::Config',
    coerce => 1,
);

=head2 call( $env )

Every web requests results in a call to this subroutine.

=head3 $env

=cut

sub call {
    my $self = shift;
    my $env = shift;

    # Use the PSGI callback style response, which allows for nice things like 
    # delayed response/streaming body (server push). For now we just use this for 
    # unbuffered response writing
    return sub {
        my $responder = shift;
        my $session = $env->{'webgui.session'}
            or die 'Missing WebGUI Session - check WebGUI::Middleware::Session';

        # Handle the request
        $self->handle($session);

        # Construct the PSGI response
        my $response = $session->response;
        my $psgi_response = $response->finalize;

        # See if the content handler is doing unbuffered response writing
        if ( $response->streaming ) {
            try {
                # Ask PSGI server for a streaming writer object by returning only the first
                # two elements of the array reference
                my $writer = $responder->( [ $psgi_response->[0], $psgi_response->[1] ] );

                # Store the writer object in the WebGUI::Session::Response object
                $response->writer($writer);

                # Now call the callback that does the streaming
                $response->streamer->($session);

                # And finally, clean up
                $writer->close;
            }
            catch {
                if ($response->writer) {
                    # Response has already been started, so log error and close writer
                    $session->request->TRACE("Error detected after streaming response started");
                    $response->writer->close;
                }
                else {
                    $responder->( [ 500, [ 'Content-Type' => 'text/plain' ], [ "Internal Server Error" ] ] );
                }
            };
        }
        else {
            # Not streaming, so immediately tell the callback to return 
            # the response. In the future we could use an Event framework here 
            # to make this a non-blocking delayed response.
            $responder->($psgi_response);
        }
    };
}

sub handle {
    my ( $self, $session ) = @_;
    
    # uncomment the following to short-circuit contentHandlers (for benchmarking PSGI scaffolding vs. modperl)
    # $session->output->print("WebGUI PSGI with contentHandlers short-circuited for benchmarking\n");
    # return;

    # contentHandlers that return text will have that content returned as the response
    # Alternatively, contentHandlers can stream the response body by calling:
    #  $session->response->stream_write()
    # inside of a callback registered via:
    #  $session->response->stream( sub {  } )
    # This is generally a good thing to do, unless you want to send a file.

    # uncomment the following to short-circuit contentHandlers with a streaming response:
    # $session->response->stream(
        # sub {
            # my $session = shift;
            # $session->output->print("WebGUI PSGI with contentHandlers short-circuited for benchmarking (streaming)\n");
            # #sleep 1;
            # $session->output->print("...see?\n");
        # }
    # );
    # return;
    
    # TODO: refactor the following loop, find all instances of "chunked" and "empty" in codebase, etc..
    for my $handler (@{$session->config->get("contentHandlers")}) {
        my $output = eval { WebGUI::Pluggable::run($handler, "handler", [ $session ] )};
        if ( my $e = WebGUI::Error->caught ) {
            $session->errorHandler->error($e->package.":".$e->line." - ".$e->error);
            $session->errorHandler->debug($e->package.":".$e->line." - ".$e->trace);
        }
        elsif ( $@ ) {
            $session->errorHandler->error( $@ );
        }
        else {
            
            # Stop if the contentHandler is going to stream the response body
            return if $session->response->streaming;
            
            # We decide what to do next depending on what the contentHandler returned
            
            # "chunked" or "empty" means it took care of its own output needs
            if (defined $output && ( $output eq "chunked" || $output eq "empty" )) {
                #warn "chunked and empty no longer stream, use session->response->stream() instead";
                return;
            }
            # non-empty output should be used as the response body
            elsif (defined $output && $output ne "") {
                # Auto-set the headers
                $session->http->sendHeader;
                
                # Use contentHandler's return value as the output
                $session->output->print($output);
                return;
            }
            # Keep processing for success codes
            elsif ($session->http->getStatus < 200 || $session->http->getStatus > 299) {
                $session->http->sendHeader;
                return;
            }
        }
    }
    return;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
