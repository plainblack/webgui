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
use Apache2::Access (); 
use Apache2::Const -compile => qw(OK DECLINED HTTP_UNAUTHORIZED SERVER_ERROR);
use Apache2::Request;
use Apache2::RequestIO;
use Apache2::RequestUtil ();
use Apache2::ServerUtil ();
use APR::Request::Apache2;
use MIME::Base64 ();
use WebGUI::Config;
use WebGUI::Pluggable;
use WebGUI::Session;
use WebGUI::User;

=head1 NAME

Package WebGUI

=head1 DESCRIPTION

An Apache mod_perl handler for WebGUI.

=head1 SYNOPSIS

 use WebGUI;

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 authen ( requestObject, [ user, pass, config ])

HTTP Basic auth for WebGUI.

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=head3 user

The username to authenticate with. Will pull from the request object if not specified.

=head3 pass

The password to authenticate with. Will pull from the request object if not specified.

=head3 config

A reference to a WebGUI::Config object. One will be created if it isn't specified.

=cut


sub authen {
    my ($request, $username, $password, $config) = @_;
    $request = Apache2::Request->new($request);
    my $server = Apache2::ServerUtil->server;
	my $status = Apache2::Const::OK;

	# set username and password if it's an auth handler
	if ($username eq "") {
		if ($request->auth_type eq "Basic") {
			($status, $password) = $request->get_basic_auth_pw;
			$username = $request->user;
		}
		else {
			return Apache2::Const::HTTP_UNAUTHORIZED;
		}
	}

	$config ||= WebGUI::Config->new($server->dir_config('WebguiRoot'),$request->dir_config('WebguiConfig'));
	my $cookies = APR::Request::Apache2->handle($request)->jar();
   
	# determine session id
	my $sessionId = $cookies->{$config->getCookieName};
	my $session = WebGUI::Session->open($server->dir_config('WebguiRoot'),$config->getFilename, $request, $server, $sessionId);
	my $log = $session->log;
	$request->pnotes(wgSession => $session);

	if (defined $sessionId && $session->user->isRegistered) { # got a session id passed in or from a cookie
		$log->info("BASIC AUTH: using cookie");
		return Apache2::Const::OK;
	}
	elsif ($status != Apache2::Const::OK) { # prompt the user for their username and password
		$log->info("BASIC AUTH: prompt for user/pass");
		return $status; 
	}
	elsif (defined $username && $username ne "") { # no session cookie, let's try to do basic auth
		$log->info("BASIC AUTH: using user/pass");
		my $user = WebGUI::User->newByUsername($session, $username);
		if (defined $user) {
			my $authMethod = $user->authMethod;
			if ($authMethod) { # we have an auth method, let's try to instantiate
				my $auth = eval { WebGUI::Pluggable::instanciate("WebGUI::Auth::".$authMethod, "new", [ $session, $authMethod ] ) };
				if ($@) { # got an error
					$log->error($@);
					return Apache2::Const::SERVER_ERROR;
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
					return Apache2::Const::OK;
				}
			}
		}
		$log->security($username." failed to login using HTTP Basic Authentication");
		$request->note_basic_auth_failure;
		return Apache2::Const::HTTP_UNAUTHORIZED;
	}
	$log->info("BASIC AUTH: skipping");
	return Apache2::Const::HTTP_UNAUTHORIZED;
}

#-------------------------------------------------------------------

=head2 handler ( requestObject )

Primary http init/response handler for WebGUI.  This method decides whether to hand off the request to contentHandler() or uploadsHandler()

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=cut

sub handler {
    my $request = shift; # either apache request object or PSGI env hash
    my $server;
    if ($request->isa('WebGUI::Session::Plack')) {
        $server  = $request->server;
    } else {
        $request = Apache2::Request->new($request);
        $server  = Apache2::ServerUtil->server;	#instantiate the server api
    }
	my $configFile = shift || $request->dir_config('WebguiConfig'); #either we got a config file, or we'll build it from the request object's settings
	my $config = WebGUI::Config->new($server->dir_config('WebguiRoot'), $configFile); #instantiate the config object
    my $error = "";
    my $matchUri = $request->uri;
    my $gateway = $config->get("gateway");
    $matchUri =~ s{^$gateway}{/};
	my $gotMatch = 0;

    # handle basic auth
#    my $auth = $request->headers_in->{'Authorization'};
#    if ($auth =~ m/^Basic/) { # machine oriented
#	    # Get username and password from Apache and hand over to authen
#        $auth =~ s/Basic //;
#        authen($request, split(":", MIME::Base64::decode_base64($auth), 2), $config); 
#    }
#    else { # realm oriented
#	    $request->push_handlers(PerlAuthenHandler => sub { return WebGUI::authen($request, undef, undef, $config)});
#    }

	
	# url handlers
    WEBGUI_FATAL: foreach my $handler (@{$config->get("urlHandlers")}) {
        my ($regex) = keys %{$handler};
        if ($matchUri =~ m{$regex}i) {
            my $output = eval { WebGUI::Pluggable::run($handler->{$regex}, "handler", [$request, $server, $config]) };
            if ($@) {
				$error = $@;
                last;
            }
            else {
				$gotMatch = 1;
				if ($output ne Apache2::Const::DECLINED) {
					return $output;
				}
            }
        }
	}
	return Apache2::Const::DECLINED if ($gotMatch);
	
	# can't handle the url due to error or misconfiguration
    $request->push_handlers(PerlResponseHandler => sub { 
        print "This server is unable to handle the url '".$request->uri."' that you requested. ".$error;
        return Apache2::Const::OK;
    } );
	$request->push_handlers(PerlTransHandler => sub { return Apache2::Const::OK });
	return Apache2::Const::DECLINED; 
}

sub handle_psgi {
    my $env = shift;
    require WebGUI::Session::Plack;
    my $plack = WebGUI::Session::Plack->new( env => $env );
    
    # returns something like Apache2::Const::OK, which we ignore
    my $ret = handler($plack);
    
    # let Plack::Response do its thing
    return $plack->finalize;
}

1;

