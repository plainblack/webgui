package WebGUI;


our $VERSION = '7.10.23';
our $STATUS = 'stable';


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
use Scalar::Util qw/blessed/;
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

=head2 authen ( requestObject, user || undef, pass || undef, session ])

HTTP Basic auth for WebGUI.
Either called from L<WebGUI::Content::URL> directly or indirectly when pushed back on the L<mod_perl> handler stack.
HTTP Basic auth is an alternative authentication mechanism for WebGUI for robots such as RSS feed readers.
L<WebGUI::Content::URL> does nothing with the return codes from here, but L<mod_perl> uses them if this routine
gets pushed as a handler.

=head3 requestObject

The Apache2::RequestRec object passed in by Apache's mod_perl.

=head3 user

The username to authenticate with. Will pull from the request object if not specified.

=head3 pass

The password to authenticate with. Will pull from the request object if not specified.

=head3 session

A reference to a WebGUI::Session object.

=cut


sub authen {
    my ($request, $username, $password, $session) = @_;
    $request = Apache2::Request->new($request);
	my $log = $session->log;
    my $server = Apache2::ServerUtil->server;
	my $status = Apache2::Const::OK;

	# set username and password if it's an auth handler
	if ($username eq "") {
		if ($request->auth_type eq "Basic") {
			($status, $password) = $request->get_basic_auth_pw;
			$username = $request->user;
			$username or return Apache2::Const::HTTP_UNAUTHORIZED;
		}
		else {
            # per http://www.webgui.org/use/bugs/tracker/12198, failures result in the user remaining visitor, not them
            # being denied access entirely.
            # $status = Apache2::Const::HTTP_UNAUTHORIZED; # no
			return $status;
		}
	}

    my $user = WebGUI::User->newByUsername($session, $username);
    if ( ! defined $user ) {
        # $status = Apache2::Const::HTTP_UNAUTHORIZED; # no
        return $status;
    }

    my $authMethod = $user->authMethod;
    if ($authMethod) { # we have an auth method, let's try to instantiate
        my $auth = eval { WebGUI::Pluggable::instanciate("WebGUI::Auth::".$authMethod, "new", [ $session, $authMethod ] ) };
        if ($@) { # got an error
            $log->error($@);
            return Apache2::Const::SERVER_ERROR;
        }
        elsif ($auth->authenticate($username, $password)) { # lets try to authenticate
            $log->info("BASIC AUTH: authenticated successfully");
            my $sessionId = $session->db->quickScalar("select sessionId from userSession where userId=?",[$user->userId]);
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

    $log->security($username." failed to login using HTTP Basic Authentication");
    # $status = Apache2::Const::HTTP_UNAUTHORIZED; # no
    return $status;
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

