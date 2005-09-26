package WebGUI::Operation::Auth;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::ErrorHandler;
use WebGUI::Operation::Shared;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;


#-------------------------------------------------------------------

=head2 getInstance ( )

Get the instance of this object or create a new instance if none exists

=cut

sub getInstance {   
   	#Get Auth Settings
	my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
	$authMethod = $session{setting}{authMethod} if($session{user}{userId} eq '1');
	$authMethod = $_[0] if($_[0] && isIn($_[0], @{$session{config}{authMethods}}));
	my $userId = $_[1];
	#Create Auth Object
	my $cmd = "WebGUI::Auth::".$authMethod;
	my $load = "use ".$cmd;
	eval($load);
	WebGUI::ErrorHandler::fatal("Authentication module failed to compile: $cmd.".$@) if($@);
    my $auth = eval{$cmd->new($authMethod,$userId)};
    WebGUI::ErrorHandler::fatal("Couldn't instantiate authentication module: $authMethod. Root cause: ".$@) if($@);
	return $auth;
}

#-------------------------------------------------------------------
sub www_auth {
   my $auth;
   ($auth) = WebGUI::SQL->quickArray("select authMethod from users where username=".quote($session{form}{username})) if($session{form}{username});
   my $authMethod = getInstance($auth);
   my $methodCall = shift || $session{form}{method} || "init";
   if(!$authMethod->isCallable($methodCall)){
      WebGUI::ErrorHandler::security("access uncallable auth method on page '".$session{page}{title}."' [".$session{page}{pageId}."].");
	  return WebGUI::International::get(1077);
   }
   return WebGUI::Operation::Shared::userStyle($authMethod->$methodCall);   
}


 
1;
