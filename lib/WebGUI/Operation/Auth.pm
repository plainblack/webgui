package WebGUI::Operation::Auth;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------
# The Operation WebGUI::Operation::Auth is responsible for instansiating
# and calling methods in the Auth Module.  This method also has some core
# logic that defines how Authentication should happen

use strict qw(vars subs);
use URI;
use WebGUI::Operation::Shared;
use WebGUI::Pluggable;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;


#-------------------------------------------------------------------

=head2 getInstance ( )

Get the instance of this object or create a new instance if none exists

=cut

sub getInstance {
	my $session = shift;
	#Get Auth Settings
	my $authMethod = $session->user->authMethod || $session->setting->get("authMethod");
	$authMethod = $session->setting->get("authMethod") if($session->user->isVisitor);
	$authMethod = $_[0] if($_[0] && isIn($_[0], @{$session->config->get("authMethods")}));
	my $userId = $_[1];
	#Create Auth Object
    my $auth = eval { WebGUI::Pluggable::instanciate("WebGUI::Auth::".$authMethod, "new", [ $session, $authMethod, $userId ] ) };
    if ($@) {
        $session->errorHandler->fatal($@);
    }
    else {
        return $auth;
    };
}



#-------------------------------------------------------------------

=head2 www_auth ( )

This subroutine does authentication dispatch.  It looks up the authentication method for
the current user, makes sure that it supports the operation that has been requested,
and then executes it.  If an illegal method was requested, then an error message
is returned.

=cut

sub www_auth {
	my $session = shift;
	$session->http->setCacheControl("none");
	my $auth;
	($auth) = $session->db->quickArray("select authMethod from users where username=".$session->db->quote($session->form->process("username"))) if($session->form->process("username"));
	my $authMethod = getInstance($session,$auth);
	my $methodCall = shift || $session->form->process("method") || "init";
	if(!$authMethod->isCallable($methodCall)){
		$session->errorHandler->security("access uncallable auth method");
		my $i18n = WebGUI::International->new($session);
		return $i18n->get(1077);
	}
    my $out = $authMethod->$methodCall;
    if (substr($session->http->getMimeType(),0,9) eq "text/html") {
	    return $session->style->userStyle($out);
    }
    else {
        return $out;
    }
}


 
1;
