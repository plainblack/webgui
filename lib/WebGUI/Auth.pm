package WebGUI::Auth;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use CGI::Util qw(rearrange);
use DBI;
use strict qw(subs vars);
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::FormProcessor;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Node;
use WebGUI::Page;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Operation::Shared;


=head1 NAME

Package WebGUI::Auth

=head1 DESCRIPTION

An abstract class for all authentication modules to extend.

=head1 SYNOPSIS

 use WebGUI::Auth;
 our @ISA = qw(WebGUI::Auth);

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _isDuplicateUsername {
	my $self = shift;
	my $username = shift;
	#Return false if the user is already logged in, but not changing their username.
	return 0 if($self->userId != 1 && $session{user}{username} eq $username);
	my ($otherUser) = WebGUI::SQL->quickArray("select count(*) from users where username=".quote($username));
	return 0 if !$otherUser;
	$self->error('<li>'.WebGUI::International::get(77).' "'.$username.'too", "'.$username.'2", '.'"'.$username.'_'.WebGUI::DateTime::epochToHuman(time(),"%y").'"');
	return 1;
}

#-------------------------------------------------------------------

=head2 _isValidPassword (  )

  Validates the password.

=cut

sub _isValidPassword {
   my $self = shift;
   my $password = shift;
   my $confirm = shift;
   my $error = "";
   
   if ($password ne $confirm) {
      $error .= '<li>'.WebGUI::International::get(3,'Auth/WebGUI');
   }
   if ($password eq "") {
      $error .= '<li>'.WebGUI::International::get(4,'Auth/WebGUI');
   }
   
   if ($self->getSetting("passwordLength") && length($password) < $self->getSetting("passwordLength")){
      $error .= '<li>'.WebGUI::International::get(7,'Auth/WebGUI')." ".$self->getSetting("passwordLength");
   }
   
   $self->error($error);
   return $error eq "";
}

#-------------------------------------------------------------------

=head2 _isValidUsername ( username )

  Validates the username passed in.

=cut

sub _isValidUsername {
   my $self = shift;
   my $username = shift;
   my $error = "";
   
   return 1 if($self->userId != 1 && $session{user}{username} eq $username);
   
   if ($username =~ /^\s/ || $username =~ /\s$/) {
      $error .= '<li>'.WebGUI::International::get(724);
   }
   if ($username eq "") {
      $error .= '<li>'.WebGUI::International::get(725);
   }
   unless ($username =~ /^[A-Za-z0-9\-\_\.\,\@]+$/) {
   	  $error .= '<li>'.WebGUI::International::get(747);
   }
   $self->error($error);
   return $error eq "";
}

#-------------------------------------------------------------------
sub _logLogin {
   WebGUI::SQL->write("insert into userLoginLog values ('$_[0]','$_[1]',".time().",".quote($session{env}{REMOTE_ADDR}).",".quote($session{env}{HTTP_USER_AGENT}).")");
}

#-------------------------------------------------------------------

=head2 addUserForm ( userId )

  Creates elements for the add user form specific to this Authentication Method.

=cut

sub addUserForm {
   #Added for interface purposes only.  Needs to be implemented in the subclass.
}

#-------------------------------------------------------------------

=head2 addUserFormSave ( properties [,userId] )

  Saves user elements unique to this authentication method

=cut

sub addUserFormSave {
   my $self = shift;
   $self->saveParams(($_[1] || $self->userId),$self->authMethod,$_[0]);
}

#-------------------------------------------------------------------

=head2 authenticate ( )

  Superclass method that performs standard login routines.  This method should return true or false.

=cut

sub authenticate {
   my $self = shift;
   my $username = shift;
   my $user = WebGUI::SQL->quickHashRef("select userId,authMethod,status from users where username=".quote($username));
   my $uid = $user->{userId};
   #If userId does not exist or is not active, fail login
   if(!$uid){
      $self->error(WebGUI::International::get(68));
	  return 0;
   } elsif($user->{status} ne 'Active'){
      $self->error(WebGUI::International::get(820));
	  _logLogin($uid, "failure");
	  return 0;
   }
   
   #Set User Id
   $self->user(WebGUI::User->new($uid));
   return 1;
}

#-------------------------------------------------------------------
=head2 authMethod ( [authMethod] )

  Gets or sets the authMethod in the Auth Object

=over

=item authMethod

   A string which sets the auth method for an instance of this class

=back

=cut

sub authMethod {
   my $self = shift;
   return $self->{authMethod} if(!$_[0]);
   $self->{authMethod} = $_[0];
}

#-------------------------------------------------------------------
=head2 createAccount ( method [,vars,template] )

  Superclass method that performs general functionality for creating new accounts.

=over

=item method

   Auth method that the form for creating users should call
   
=item vars
   
   Array ref of template vars from subclass
   
=item template

   Template that this class should use for display purposes

=back
  
=cut

sub createAccount {
    my $self = shift;
	my $method = $_[0];
	my $vars = $_[1];
    my $template = $_[2] || 'Auth/'.$self->authMethod.'/Create';
	$vars->{displayTitle} = '<h1>'.WebGUI::International::get(54).'</h1>';
   	
	$vars->{'create.form.header'} = "\n\n".WebGUI::Form::formHeader({});
	$vars->{'create.form.hidden'} .= WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
    $vars->{'create.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>$method});
	
	#User Defined Options
    $vars->{'create.form.profile'} = WebGUI::Operation::Profile::getRequiredProfileFields();
	
	$vars->{'create.form.submit'} = WebGUI::Form::submit({});
    $vars->{'create.form.footer'} = "</form>";
	
    $vars->{'create.options.accountExists'} = '<a href="'.WebGUI::URL::page('op=displayLogin').'">'.WebGUI::International::get(58).'</a>';

	if ($self->getSetting("passwordRecovery")) {
	   $vars->{'create.options.passwordRecovery'} = '<a href="'.WebGUI::URL::page('op=recoverPassword').'">'.WebGUI::International::get(59).'</a>';
	}
	return WebGUI::Template::process(WebGUI::Template::get(1,$template), $vars);
}

#-------------------------------------------------------------------
=head2 createAccountSave ( username,properties [,password,profile] )

  Superclass method that performs general functionality for saving new accounts.

=over

=item username

   Username for the account being created
   
=item properties
   
   Properties from the subclass that should be saved as authentication parameters
   
=item password

   Password entered by the user.  This is only used in for sending the user a notification by email of his/her username/password

=item profile
   
   Hashref of profile values returned by the function WebGUI::Operation::Profile::validateProfileData()
   
=back
  
=cut

sub createAccountSave {
   my $self = shift;
   my $username = $_[0];
   my $properties = $_[1];
   my $password = $_[2];
   my $profile = $_[3];
   
      
   my $u = WebGUI::User->new("new");
   $self->user($u);
   my $userId = $u->userId;
   $u->username($username);
   $u->authMethod($self->authMethod);
   $u->karma($session{setting}{karmaPerLogin},"Login","Just for logging in.") if ($session{setting}{useKarma});
   WebGUI::Operation::Profile::saveProfileFields($u,$profile) if($profile);
   $self->saveParams($userId,$self->authMethod,$properties);
   
   if ($self->getSetting("sendWelcomeMessage")){
      my $authInfo = "\n\n".WebGUI::International::get(50).": ".$username;
      $authInfo .= "\n".WebGUI::International::get(51).": ".$password if($password);
      $authInfo .= "\n\n";
      WebGUI::MessageLog::addEntry($self->userId,"",WebGUI::International::get(870),$self->getSetting("welcomeMessage").$authInfo);
   }
   
   WebGUI::Session::convertVisitorToUser($session{var}{sessionId},$userId);
   $self->_logLogin($userId,"success");
   system(WebGUI::Macro::process($session{setting}{runOnRegistration})) if ($session{setting}{runOnRegistration} ne "");
   WebGUI::MessageLog::addInternationalizedEntry('',$session{setting}{onNewUserAlertGroup},'',536) if ($session{setting}{alertOnNewUser});
   return "";
}

#-------------------------------------------------------------------
=head2 deactivateAccount ( method )

  Superclass method that displays a confirm message for deactivating a user's account.

=over

=item method

   Auth method that the form for creating users should call
   
=back
  
=cut

sub deactivateAccount {
   my $self = shift;
   my $method = $_[0];
   my ($output);
   return WebGUI::Privilege::vitalComponent() if($self->userId < 26);
   return WebGUI::Privilege::adminOnly() if(!$session{setting}{selfDeactivation});
   $output = '<h1>'.WebGUI::International::get(42).'</h1>';
   $output .= WebGUI::International::get(60).'<p>';
   $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=auth&method='.$method).'">'.WebGUI::International::get(44).'</a>';
   $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(45).'</a></div>';
   return $output;
}

#-------------------------------------------------------------------
=head2 deactivateAccount ( method )

  Superclass method that performs general functionality for deactivating accounts.
  
=cut

sub deactivateAccountConfirm {
   my $self = shift;
   return WebGUI::Privilege::vitalComponent() if ($self->userId < 26);
   my $u = $self->user;
   $u->status("Selfdestructed");
   WebGUI::Session::end($session{var}{sessionId});
   WebGUI::Session::start(1);   
}

#-------------------------------------------------------------------
=head2 deleteParams (  )

Removes the user's authentication parameters from the database for all authentication methods. This is primarily useful when deleting the user's account.

=cut

sub deleteParams {
   my $self = shift;
   WebGUI::SQL->write("delete from authentication where userId=".quote($self->userId));
}

#-------------------------------------------------------------------
=head2 displayAccount ( method [,vars,template] )

  Superclass method that performs general functionality for viewing editable fields related to a user's account.

=over

=item method

   Auth method that the form for updating a user's account should call
   
=item vars
   
   Array ref of template vars from subclass
   
=item template

   Template that this class should use for display purposes

=back
  
=cut

sub displayAccount {
   my $self = shift;
   my $method = $_[0];
   my $vars = $_[1];
   my $template = $_[2] || 'Auth/'.$self->authMethod.'/Account';
   
   $vars->{displayTitle} = '<h1>'.WebGUI::International::get(61).'</h1>';
   
   $vars->{'account.form.header'} = "\n\n".WebGUI::Form::formHeader({});
   $vars->{'account.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
   $vars->{'account.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>$method});
   if($session{setting}{useKarma}){
      $vars->{'account.form.karma'} = $session{user}{karma};
	  $vars->{'account.form.karma.label'} = WebGUI::International::get(537);
   }
   $vars->{'account.form.submit'} = WebGUI::Form::submit({});
   $vars->{'account.form.footer'} = "</form>";
   
   $vars->{'account.options'} = WebGUI::Operation::Shared::accountOptions();
   return WebGUI::Template::process(WebGUI::Template::get(1,$template), $vars);
}

#-------------------------------------------------------------------
=head2 displayLogin ( [method,vars,template] )

  Superclass method that performs general functionality for creating new accounts.

=over

=item method

   Auth method that the form for performing the login routine should call
   
=item vars
   
   Array ref of template vars from subclass
   
=item template

   Template that this class should use for display purposes

=back
  
=cut

sub displayLogin {
    my $self = shift;
	my $method = $_[0] || "login";
	my $vars = $_[1];
	my $template = $_[2] || 'Auth/'.$self->authMethod.'/Login';

	unless ($session{env}{REQUEST_URI} =~ "displayLogin" || $session{env}{REQUEST_URI} =~ "displayAccount" ||
	        $session{env}{REQUEST_URI} =~ "logout" || $session{env}{REQUEST_URI} =~ "deactivateAccount"){
	   WebGUI::Session::setScratch("redirectAfterLogin",$session{env}{REQUEST_URI});
	}

	$vars->{displayTitle} = '<h1>'.WebGUI::International::get(66).'</h1>';
	$vars->{'login.form.header'} = "\n\n".WebGUI::Form::formHeader({});
	if ($session{setting}{encryptLogin}) {
       $vars->{'login.form.header'} =~ s/http:/https:/;
    }
    $vars->{'login.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
	$vars->{'login.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>$method});
	$vars->{'login.form.username'} = WebGUI::Form::text({"name"=>"username"});
    $vars->{'login.form.username.label'} = WebGUI::International::get(50);
    $vars->{'login.form.password'} = WebGUI::Form::password({"name"=>"identifier"});
    $vars->{'login.form.password.label'} = WebGUI::International::get(51);
	$vars->{'login.form.submit'} = WebGUI::Form::submit({"value"=>WebGUI::International::get(52)});
	$vars->{'login.form.footer'} = "</form>";

	if ($session{setting}{anonymousRegistration}) {
	   $vars->{'login.options.anonymousRegistration'} = '<a href="'.WebGUI::URL::page('op=createAccount').'">'.WebGUI::International::get(67).'</a>';
    }
	if ($self->getSetting("passwordRecovery")) {
	   $vars->{'login.options.passwordRecovery'} = '<a href="'.WebGUI::URL::page('op=recoverPassword').'">'.WebGUI::International::get(59).'</a>';
	}
	return WebGUI::Template::process(WebGUI::Template::get(1,$template), $vars);
}

#-------------------------------------------------------------------

=head2 editUserForm (  )

  Creates user form elements specific to this Auth Method.

=cut

sub editUserForm {
   #Added for interface purposes only.  Needs to be implemented in the subclass.
}

#-------------------------------------------------------------------

=head2 editUserFormSave ( properties )

  Saves user elements unique to this authentication method

=cut

sub editUserFormSave {
   my $self = shift;
   $self->saveParams($self->userId,$self->authMethod,$_[0]);
}

#-------------------------------------------------------------------

=head2 error ( [errorMsg] )

  Sets or returns the error currently stored in the object

=cut

sub error {
   my $self = shift;
   return $self->{error} if (!$_[0]);
   $self->{error} = $_[0];
}

#-------------------------------------------------------------------

=head2 getParams ()

   Returns a hash reference with the user's authentication information.  This method uses data stored in the instance of the object.

=cut

sub getParams {
    my $self = shift;
	my $userId = $_[0] || $self->userId;
	my $authMethod = $_[1] || $self->authMethod;
	return WebGUI::SQL->buildHashRef("select fieldName, fieldData from authentication where userId=".quote($userId)." and authMethod=".quote($authMethod));
}

#-------------------------------------------------------------------

=head2 getSetting (  setting  )

 Returns a setting for this authMethod instance.  If none is specified, returns the system authMethod setting

=over

=item setting

   Specify a setting to retrieve

=back

=cut

sub getSetting {
	my $self = shift;
	my $setting = $_[0];
	$setting = lc($self->authMethod).ucfirst($setting);
	return $session{setting}{$setting};
}

#-------------------------------------------------------------------
=head2 init ( )

  Initialization function for these auth routines.  Default is a superclass function called displayLogin.
  Override this method in your subclass to change the initialization for custom authentication methods

=cut

sub init {
   my $self = shift;
   return $self->displayLogin;
}

#-------------------------------------------------------------------

=head2 isCallable ( method )

  Returns whether or not a method is callable

=cut

sub isCallable {
   my $self = shift;
   return isIn($_[0],@{$self->{callable}})
}


#-------------------------------------------------------------------

=head2 login ( )

  Superclass method that performs standard login routines.  This is what should happen after a user has been authenticated.
  Authentication should always happen in the subclass routine.

=cut

sub login {
   my $self = shift;
   my ($cmd, $uid, $u, $authMethod,$msg,$userData,$expireDate);
   
   #Create a new user
   $uid = $self->userId;
   $u = WebGUI::User->new($uid);
   WebGUI::Session::convertVisitorToUser($session{var}{sessionId},$uid);
   $u->karma($session{setting}{karmaPerLogin},"Login","Just for logging in.") if ($session{setting}{useKarma});
   _logLogin($uid,"success");
   
   if ($session{scratch}{redirectAfterLogin}) {
      $session{header}{redirect} = WebGUI::Session::httpRedirect($session{scratch}{redirectAfterLogin});
	  WebGUI::Session::deleteScratch("redirectAfterLogin");
   }
   return "";
}

#-------------------------------------------------------------------
=head2 logout ( )

  Superclass method that performs standard logout routines.

=cut

sub logout {
   WebGUI::Session::end($session{var}{sessionId});
   WebGUI::Session::start(1);
   return "";
}

#-------------------------------------------------------------------

=head2 new ( authMethod [,userId,callable] )

Constructor.

=over

=item authMethod
  
  This object's authentication method
  
=item userId

  userId for the user requesting authentication.  This defaults to $session{user}{userId}
  
=item callable

  Array reference of methods allowed to be called externally;  

=back

=cut

sub new {
	my $self = {};
	shift;
	
	#Initialize data
	$self->{authMethod} = $_[0];
	my $userId = $_[1] || $session{user}{userId};
	my $u = WebGUI::User->new($userId);
	$self->{user} = $u;
	$self->{error} = "";
	$self->{profile} = ();
	$self->{warning} = "";
	my @callable = ('init',@{$_[2]});
	$self->{callable} = \@callable;
	bless($self);
	return $self;
}

#-------------------------------------------------------------------

=head2 profile ()

   Sets or returns the Profile hash for a user.

=cut

sub profile {
  my $self = shift;
  return $self->{profile} if ($_[0]);
  $self->{profile} = $_[0];
}


#-------------------------------------------------------------------
=head2 recoverPassword ( method [,vars,template] )

  Superclass method that performs general functionality for creating new accounts.

=over

=item method

   Auth method that the form for recovering passwords should call
   
=item vars
   
   Array ref of template vars from subclass
   
=item template

   Template that this class should use for display purposes

=back
  
=cut

sub recoverPassword {
   my $self = shift;
   my $method = $_[0];
   my $vars = $_[1];
   my $template = $_[2] || 'Auth/'.$self->authMethod.'/Recovery';
      
   $vars->{displayTitle} = '<h1>'.WebGUI::International::get(71).'</h1>';
   
   my $output = '<h1>'.WebGUI::International::get(71).'</h1>';
   $vars->{'recover.form.header'} = "\n\n".WebGUI::Form::formHeader({});
   $vars->{'recover.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
   $vars->{'recover.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>$method});
   
   $vars->{'recover.form.submit'} = WebGUI::Form::submit({});
   $vars->{'recover.form.footer'} = "</form>";
   
   $vars->{'recover.options.accountExists'} = '<a href="'.WebGUI::URL::page('op=displayLogin').'">'.WebGUI::International::get(73).'</a>';
   if ($session{setting}{anonymousRegistration}) {
	   $vars->{'recover.options.anonymousRegistration'} = '<a href="'.WebGUI::URL::page('op=createAccount').'">'.WebGUI::International::get(67).'</a>';
   }
   return WebGUI::Template::process(WebGUI::Template::get(1,$template), $vars);
}

#-------------------------------------------------------------------
=head2 setCallable ( callableMethods )

  adds elements to the callable routines list.  This list determines whether or not a method in this instance is 
  allowed to be called externally

=over

=item callableMethods

  Array reference containing a list of methods for this authentication instance that can be called externally

=back

=cut

sub setCallable {
   my $self = shift;
   my @callable = @{$self->{callable}};
   @callable = (@callable,@{$_[0]});
}

#-------------------------------------------------------------------

=head2 saveParams ( userId, authMethod, data )

Saves the user's authentication parameters to the database.

=over

=item userId

Specify a user id.

=item authMethod

Specify the authentication method to save these paramaters under.

=item data

A hash reference containing parameter names and values to be saved.

=back

=cut

sub saveParams {
    my $self = shift;
	my ($uid, $authMethod, $data) = @_;
	foreach (keys %{$data}) {
       WebGUI::SQL->write("delete from authentication where userId=$uid and authMethod=".quote($authMethod)." and fieldName=".quote($_));
   	   WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldData,fieldName) values ($uid,".quote($authMethod).",".quote($data->{$_}).",".quote($_).")");
    }
}

#-------------------------------------------------------------------

=head2 user ( [user] )

  Sets or Returns the user object stored in the wobject

=cut

sub user {
   my $self = shift;
   return $self->{user} if (!$_[0]);
   $self->{user} = $_[0];
}

#-------------------------------------------------------------------

=head2 userId ( )

  Returns the userId currently stored in the object

=cut

sub userId {
   my $self = shift;
   my $u = $self->user;
   return $u->userId;
}

#-------------------------------------------------------------------

=head2 username ( )

  Returns the username currently stored in the object

=cut

sub username {
   my $self = shift;
   my $u = $self->user;
   return $u->username;
}

#-------------------------------------------------------------------

=head2 validUsernameAndPassword ( username,password,passwordConfirm )

  Validates the a username and password.

=cut

sub validUsernameAndPassword {
   my $self = shift;
   my $username = $_[0];
   my $password = $_[1];
   my $passwordConfirm = $_[2];
   my $error = "";
   
   if($self->_isDuplicateUsername($username)){
      $error .= $self->error;
   }
   
   if(!$self->_isValidUsername($username)){
      $error .= $self->error;
   }
   
   if(!$self->_isValidPassword($password,$passwordConfirm)){
      $error .= $self->error;
   }
   
   $self->error($error);
   return $error eq "";
}

#-------------------------------------------------------------------

=head2 warning ( [warningMsg] )

  Sets or Returns a warning in the object

=cut

sub warning {
   my $self = shift;
   return $self->{warning} if (!$_[0]);
   $self->{warning} = $_[0];
}

1;
