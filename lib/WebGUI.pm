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
use Any::Moose;
use Plack::Request;

has root    => ( is => 'ro', required => 1 ); # WEBGUI_ROOT
has config  => ( is => 'ro', required => 1 ); # WEBGUI_CONFIG
has session => ( is => 'rw', isa => 'WebGUI::Session' );

=head1 NAME

Package WebGUI

=head1 DESCRIPTION

PSGI handler for WebGUI.

=head1 SYNOPSIS

 use WebGUI;

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 authen ( requestObject, [ user, pass, config ])

HTTP Basic auth for WebGUI.

=head3 requestObject

The Plack::Request object instantiated from the PSGI env hash

=head3 user

The username to authenticate with. Will pull from the request object if not specified.

=head3 pass

The password to authenticate with. Will pull from the request object if not specified.

=head3 config

A reference to a WebGUI::Config object. One will be created if it isn't specified.

=cut

sub authen {
    my ($self, $request, $username, $password, $config) = @_;
    
    my $response = $request->new_response( 200 );
    
#	# set username and password if it's an auth handler
#	if ($username eq "") {
#		if ($request->auth_type eq "Basic") {
##			($status, $password) = $request->get_basic_auth_pw; # TODO - don't think this is supported by Plack::Request
#			$username = $request->user;
#		}
#		else {
#		    $response->status( 401 ); # HTTP_UNAUTHORIZED;
#		    return;
#		}
#	}

	$config ||= WebGUI::Config->new( $self->root, $self->config );
   
	# determine session id
	my $sessionId = $request->cookies->{$config->getCookieName};

    # Instantiate the session object
    my $session = $self->session( WebGUI::Session->open($self->root, $self->config, $request, $sessionId) );
    my $log = $session->log;
#	$request->pnotes(wgSession => $session); # TODO - no more pnotes

	if (defined $sessionId && $session->user->isRegistered) { # got a session id passed in or from a cookie
		$log->info("BASIC AUTH: using cookie");
		$response->status( 200 ); # OK;
		return;
	}
	# TODO - put this back in once we figure out get_basic_auth_pw
#	elsif ($status != 200) { # prompt the user for their username and password
#		$log->info("BASIC AUTH: prompt for user/pass");
#		return $status; 
#	}
	elsif (defined $username && $username ne "") { # no session cookie, let's try to do basic auth
		$log->info("BASIC AUTH: using user/pass");
		my $user = WebGUI::User->newByUsername($session, $username);
		if (defined $user) {
			my $authMethod = $user->authMethod;
			if ($authMethod) { # we have an auth method, let's try to instantiate
				my $auth = eval { WebGUI::Pluggable::instanciate("WebGUI::Auth::".$authMethod, "new", [ $session, $authMethod ] ) };
				if ($@) { # got an error
					$log->error($@);
					$response->status( 500 ); # SERVER_ERROR
					return;
				}
				elsif ($auth->authenticate($username, $password)) { # lets try to authenticate
					$log->info("BASIC AUTH: authenticated successfully");
					$sessionId = $session->db->quickScalar("select sessionId from userSession where userId=?",[$user->userId]);
					unless (defined $sessionId) { # no existing session found
						$log->info("BASIC AUTH: creating new session");
						$sessionId = $session->id->generate;
						$auth->_logLogin($user->userId, "success (HTTP Basic)");
					}
					$session->{_var} = WebGUI::Session::Var->new($session, $sessionId);
					$session->user({user=>$user});
					$response->status( 200 ); # OK
					return;
				}
			}
		}
		$log->security($username." failed to login using HTTP Basic Authentication");
		$request->note_basic_auth_failure;
		$response->status( 401 ); # HTTP_UNAUTHORIZED;
        return;
	}
	$log->info("BASIC AUTH: skipping");
	$response->status( 401 ); # HTTP_UNAUTHORIZED;
    return;
}

#-------------------------------------------------------------------

=head2 run ( env )

Primary http init/response handler for WebGUI.  This method decides whether to hand off the request to contentHandler() or uploadsHandler()

=head3 env

The PSGI environment hash

=cut

sub run {
    my ($self, $env) = @_;
    
    my $request = Plack::Request->new( $env );
    my $response = $request->new_response( 200 );
    my $config  = WebGUI::Config->new( $self->root, $self->config );
    
    my $matchUri = $request->uri;
    my $gateway = $config->get("gateway");
    $matchUri =~ s{^$gateway}{/};

    # handle basic auth
    my $auth = $request->header('Authorization');
    if ($auth && $auth =~ m/^Basic/) { # machine oriented
	    # Get username and password and hand over to authen
        $auth =~ s/Basic //;
        $self->authen($request, split(":", MIME::Base64::decode_base64($auth), 2), $config); 
    }
    else { # realm oriented
        # TODO - what to do here? Should we check response status after call to authen?
#	    $request->push_handlers(PerlAuthenHandler => sub { return WebGUI::authen($request, undef, undef, $config)});
        $self->authen($request, undef, undef, $config);
    }
	
	# url handlers
	# TODO - rip out urlHandler API - convert all to middleware
	# all remaining url handlers (probably just Asset which might get converted to something else) should
	# set $repsonse->body (e.g. so they can set it to IO) -- they no longer return $output
	my $error = "";
	my $gotMatch = 0;
	
	# TODO - would now be a time to fix the WEBGUI_FATAL label black magic?
    WEBGUI_FATAL: foreach my $handler (@{$config->get("urlHandlers")}) {
        my ($regex) = keys %{$handler};
        if ($matchUri =~ m{$regex}i) {
            eval { WebGUI::Pluggable::run($handler->{$regex}, "handler", [$request, $self->session]) };
            if ($@) {
				$error = $@;
                last;
            }
            else {
                # Record that at least one url handler ran successfully
				$gotMatch = 1;
				
				# But only return response if body was set
				if (defined $response->body ) { # or maybe get a smarter way for url handlers to flag success - b/c this may break delayed IO
				    return $response->finalize;
				}
            }
        }
	}
	
	if ( !$gotMatch ) {
        # can't handle the url due to error or misconfiguration
        $response->body( "This server is unable to handle the url '".$request->uri."' that you requested. ".$error );
    }
	return $response->finalize;
}

1;
