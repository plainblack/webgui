package WebGUI;


our $VERSION = '7.6.1';
our $STATUS = "beta";


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use MIME::Base64;
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

=head2 basicAuth ( requestObject, user, pass )

HTTP Basic auth for WebGUI.

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=cut


sub basicAuth {
    my ($request, $username, $password) = @_;
    my $server = Apache2::ServerUtil->server; 

	my $config = WebGUI::Config->new($server->dir_config('WebguiRoot'),$request->dir_config('WebguiConfig'));
	my $cookies = APR::Request::Apache2->handle($request)->jar();
   
	# determine session id
	my $sessionId = $cookies->{$config->getCookieName};
	my $session = WebGUI::Session->open($server->dir_config('WebguiRoot'),$request->dir_config('WebguiConfig'), $request, $server, $sessionId);
	my $log = $session->log;
	$request->pnotes(wgSession => $session);

	if (defined $sessionId && $session->user->isRegistered) { # got a session id passed in or from a cookie
		$log->info("BASIC AUTH: using cookie");
		return;
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
					return;
				}
				elsif ($auth->authenticate($username, $password)) { # lets try to authenticate
					$sessionId = $session->db->quickScalar("select sessionId from userSession where userId=?",[$user->userId]);
					unless (defined $sessionId) { # no existing session found
						$sessionId = $session->id->generate;
						$auth->_logLogin($user->userId, "success (HTTP Basic)");
					}
					$session->{_var} = WebGUI::Session::Var->new($session, $sessionId);
					$session->user({user=>$user});
					return;
				}
			}
		}
		$log->security($username." failed to login using HTTP Basic Authentication");
		$request->note_basic_auth_failure;
		return;
	}
	$log->info("BASIC AUTH: skipping");
	return;
}

#-------------------------------------------------------------------

=head2 handler ( requestObject )

Primary http init/response handler for WebGUI.  This method decides whether to hand off the request to contentHandler() or uploadsHandler()

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=cut

sub handler {
	my $request = shift;	#start with apache request object
    $request = Apache2::Request->new($request);
	my $configFile = shift || $request->dir_config('WebguiConfig'); #either we got a config file, or we'll build it from the request object's settings
	my $server = Apache2::ServerUtil->server;	#instantiate the server api
	my $config = WebGUI::Config->new($server->dir_config('WebguiRoot'), $configFile); #instantiate the config object
    my $error = "";
    my $matchUri = $request->uri;
    my $gateway = $config->get("gateway");
    $matchUri =~ s{^$gateway}{/};
	my $gotMatch = 0;

	# handle basic auth
	my $auth = $request->headers_in->{'Authorization'};
    if ($auth) {
		$auth =~ s/Basic //;
		basicAuth($request, split(":",MIME::Base64::decode_base64($auth)));
    }

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




1;

