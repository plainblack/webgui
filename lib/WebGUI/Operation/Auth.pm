package WebGUI::Operation::Auth;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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

use Exporter;
use strict qw(vars subs);
use URI;
use WebGUI::ErrorHandler;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_auth &www_displayLogin &www_login &www_displayAccount &www_createAccount &www_deactivateAccount &www_logout &www_recoverPassword &www_init);
#-------------------------------------------------------------------

=head2 getInstance ( )

Get the instance of this object or create a new instance if none exists

=cut

sub getInstance {   
   	#Get Auth Settings
	my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
	$authMethod = $session{setting}{authMethod} if($session{user}{userId} == 1);
	$authMethod = $_[0] if($_[0] && isIn($_[0], @{$session{config}{authMethods}}));
	my $userId = $_[1];
	#Create Auth Object
	my $cmd = "WebGUI::Auth::".$authMethod;
	my $load = "use ".$cmd;
	WebGUI::ErrorHandler::fatalError("Authentication module failed to compile: $cmd.".$@) if($@);
	eval($load);
    my $auth = eval{$cmd->new($authMethod,$userId)};
    WebGUI::ErrorHandler::fatalError("Couldn't instanciate authentication module: $authMethod. Root cause: ".$@) if($@);
	return $auth;
}

#-------------------------------------------------------------------
sub www_auth {
   my $auth;
   ($auth) = WebGUI::SQL->quickArray("select authMethod from users where username=".quote($session{form}{username})) if($session{form}{username});
   my $authMethod = getInstance($auth);
   my $methodCall = $session{form}{method} || $_[0];
   if(!$authMethod->isCallable($methodCall)){
      WebGUI::ErrorHandler::security("access uncallable auth method on page '".$session{page}{title}."' [".$session{page}{pageId}."].");
	  return WebGUI::International::get(1077);
   }
   return $authMethod->$methodCall;   
}

#-------------------------------------------------------------------
sub www_createAccount {
   return www_auth("createAccount");
}

#-------------------------------------------------------------------
sub www_deactivateAccount {
   return www_auth("deactivateAccount");
}

#-------------------------------------------------------------------
sub www_displayAccount {
   return www_auth("displayAccount");
}

#-------------------------------------------------------------------
sub www_displayLogin {
   return www_auth("displayLogin");
}

#-------------------------------------------------------------------
sub www_init {
   return www_auth("init");
}

#Deprecated.  Kept for backwards compatibility.  Use op=auth&method=login
#-------------------------------------------------------------------
sub www_login {
   return www_auth("login");
}

#-------------------------------------------------------------------
sub www_logout {
   return www_auth("logout");
}

#-------------------------------------------------------------------
sub www_recoverPassword {
   return www_auth("recoverPassword");
}
 
1;
