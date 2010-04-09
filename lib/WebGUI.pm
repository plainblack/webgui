package WebGUI;


our $VERSION = '7.8.1';
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
use MIME::Base64 ();
use WebGUI::Config;
use WebGUI::Pluggable;
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Session::Request;
use Moose;
use Try::Tiny;

has root => ( is => 'ro', isa => 'Str', default => '/data/WebGUI' );
has site => ( is => 'ro', isa => 'Str', default => 'dev.localhost.localdomain.conf' );
has config  => ( is => 'rw', isa => 'WebGUI::Config' );

use overload q(&{}) => sub { shift->psgi_app }, fallback => 1;

=head1 NAME

Package WebGUI

=head1 DESCRIPTION

PSGI handler for WebGUI.

=head1 SYNOPSIS

 use WebGUI;

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    
    # Make constructor work as:
    #   WebGUI->new( $site )
    # In addition to the more verbose:
    #   WebGUI->new( root => $root, site => $site )
    if (@_ eq 1) {
        return $class->$orig(site => $_[0] );
    } else {
        return $class->$orig(@_);
    }
};

sub BUILD {
    my $self = shift;

    # Instantiate the WebGUI::Config object
    my $config = WebGUI::Config->new( $self->root, $self->site );
    $self->config($config);
} 

sub psgi_app {
    my $self = shift;
    return $self->{psgi_app} ||= $self->compile_psgi_app;
}

sub compile_psgi_app {
    my $self = shift;
    
    my $catch = [ 500, [ 'Content-Type' => 'text/plain' ], [ "Internal Server Error\n" ] ];
    
    # WebGUI is a PSGI app is a Perl code reference. Let's create one.
    # Each web request results in a call to this sub
    my $app = sub {
        my $env = shift;
        
        # Use the PSGI callback style response, which allows for nice things like 
        # delayed response/streaming body (server push). For now we just use this for 
        # unbuffered response writing
        return sub {
            my $responder = shift;
            
            # Open the WebGUI Session
            # my $session = WebGUI::Session->open($self->root, $self->config, $env, $env->{'psgix.session'}->id);
            my $session = WebGUI::Session->open($self->root, $self->config, $env);
            
            # Handle the request
            $self->handle($session);
            
            # Uncomment to catch errors (currently I prefer letting StackTrace do its thing)
            # try {
                # $self->handle($session);
            # } catch {
                # $session->request->log( "Error handling request: $_" );
                # $responder->( $catch );
                # return;
            # };
            
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
                    
                } catch {
                    if ($response->writer) {
                        # Response has already been started, so log error and close writer
                        $session->request->TRACE("Error detected after streaming response started");
                        $response->writer->close;
                    } else {
                        $responder->( $catch );
                    }
                    
                } finally {
                    $session->close;
                    
                };
            } else {
                
                # Not streaming, so immediately tell the callback to return 
                # the response. In the future we could use an Event framework here 
                # to make this a non-blocking delayed response.
                $session->close;
                $responder->($psgi_response);
            }
        }
    };
    
    my $config = $self->config;

    # Extras
    use Plack::Middleware::Static;
    my $extrasURL = $config->get('extrasURL');
    my $extrasPath = $config->get('extrasPath');
    $app = Plack::Middleware::Static->wrap($app, 
        path => sub { s{^$extrasURL/}{} },
        root => "$extrasPath/",
    );
    
    # Uploads
    my $uploadsURL = $config->get('uploadsURL');
    my $uploadsPath = $config->get('uploadsPath');
    $app = Plack::Middleware::Static->wrap($app, 
        path => sub { s{^$uploadsURL/}{} }, 
        root => "$uploadsPath/", 
    );
    
    # Session - TODO: make this user configurable
    # use Plack::Middleware::Session;
    # $app = Plack::Middleware::Session->wrap($app);

    return $app;
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
#    $session->response->stream(sub {
#        my $session = shift;
#        $session->output->print("WebGUI PSGI with contentHandlers short-circuited for benchmarking (streaming)\n");
#        sleep 1;
#        $session->output->print("...see?\n");
#    });
#   return;
    
    # TODO: refactor the following loop, find all instances of "chunked" and "empty" in codebase, etc..
    for my $handler (@{$self->config->get("contentHandlers")}) {
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
                if ($session->errorHandler->canShowDebug()) {
                    $session->output->print($session->errorHandler->showDebug(),1);
                }
                return;
            }
            # non-empty output should be used as the response body
            elsif (defined $output && $output ne "") {
                # Auto-set the headers
                $session->http->sendHeader; # TODO: should be renamed setHeader
                
                # Use contentHandler's return value as the output
                $session->output->print($output);
                if ($session->errorHandler->canShowDebug()) {
                    $session->output->print($session->errorHandler->showDebug(),1);
                }
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