package WebGUI::Auth;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::TabForm;
use WebGUI::Asset::Template;
use WebGUI::Utility;
use WebGUI::User;
use WebGUI::Operation::Shared;
use WebGUI::Operation::Profile;
use WebGUI::Workflow::Instance;
use WebGUI::Inbox;

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
	return 0 if($self->userId ne "1" && $self->session->user->username eq $username);
	my ($otherUser) = $self->session->db->quickArray("select count(*) from users where username=".$self->session->db->quote($username));
	return 0 if !$otherUser;
	my $i18n = WebGUI::International->new($self->session);
	$self->error(sprintf($i18n->get(77), $username,$username,$username,$self->session->datetime->epochToHuman($self->session->datetime->time(),"%y")));
	return 1;
}

#-------------------------------------------------------------------

=head2 _isValidUsername ( username )

Validates the username passed in.

=cut

sub _isValidUsername {
	my $self = shift;
	my $username = shift;
	my $error = "";

	return 1 if($self->userId ne "1" && $self->session->user->username eq $username);

	my $i18n = WebGUI::International->new($self->session);

	if ($username =~ /^\s/ || $username =~ /\s$/) {
		$error .= '<li>'.$i18n->get(724).'</li>';
	}
	if ($username eq "") {
		$error .= '<li>'.$i18n->get(725).'</li>';
	}
	$self->error($error);
	return $error eq "";
}

#-------------------------------------------------------------------
sub _logLogin {
	my $self = shift;
	$self->session->db->write("insert into userLoginLog values (".$self->session->db->quote($_[0]).",".$self->session->db->quote($_[1]).",".$self->session->datetime->time().","
	.$self->session->db->quote($self->session->env->getIp).",".$self->session->db->quote($self->session->env->get("HTTP_USER_AGENT")).")");
}


#-------------------------------------------------------------------

=head2 authenticate ( )

Superclass method that performs standard login routines.  This method returns true if login success, otherwise returns false.

=cut

sub authenticate {
	my $self = shift;
	my $username = shift;
	my $i18n = WebGUI::International->new($self->session);
	my $user = $self->session->db->quickHashRef("select userId,authMethod,status from users where username=".$self->session->db->quote($username));
	my $uid = $user->{userId};
	#If userId does not exist or is not active, fail login
	if (!$uid) {
		$self->error($i18n->get(68));
		return 0;
	} elsif($user->{status} ne 'Active') {
		$self->error($i18n->get(820));
		$self->_logLogin($uid, "failure");
		return 0;
	}

	#Set User Id
	$self->user(WebGUI::User->new($self->session,$uid));
	return 1;
}

#-------------------------------------------------------------------

=head2 authMethod ( [authMethod] )

Gets or sets the authMethod in the Auth Object

=head3 authMethod

   A string which sets the auth method for an instance of this class

=cut

sub authMethod {
	my $self = shift;
	return $self->{authMethod} if(!$_[0]);
	$self->{authMethod} = $_[0];
}

#-------------------------------------------------------------------

=head2 createAccount ( method [,vars] )

Superclass method that performs general functionality for creating new accounts.

=head3 method

Auth method that the form for creating users should call

=head3 vars

Array ref of template vars from subclass

=cut

sub createAccount {
	my $self = shift;
	my $method = $_[0];
	my $vars = $_[1];
	my $i18n = WebGUI::International->new($self->session);
	$vars->{title} = $i18n->get(54);
   	
	$vars->{'create.form.header'} = WebGUI::Form::formHeader($self->session,{});
	$vars->{'create.form.header'} .= WebGUI::Form::hidden($self->session,{"name"=>"op","value"=>"auth"});
    $vars->{'create.form.header'} .= WebGUI::Form::hidden($self->session,{"name"=>"method","value"=>$method});
	
	#User Defined Options
	$vars->{'create.form.profile'} = WebGUI::Operation::Profile::getRequiredProfileFields($self->session);
	
	$vars->{'create.form.submit'} = WebGUI::Form::submit($self->session,{});
	$vars->{'create.form.footer'} = WebGUI::Form::formFooter($self->session,);

	$vars->{'login.url'} = $self->session->url->page('op=auth;method=init');
	$vars->{'login.label'} = $i18n->get(58);

	$vars->{'login.url'} = $self->session->url->page('op=auth;method=init');
	$vars->{'login.label'} = $i18n->get(58);

	return WebGUI::Asset::Template->new($self->session,$self->getCreateAccountTemplateId)->process($vars);
}

#-------------------------------------------------------------------

=head2 createAccountSave ( username,properties [,password,profile] )

Superclass method that performs general functionality for saving new accounts.

=head3 username

Username for the account being created

=head3 properties

Properties from the subclass that should be saved as authentication parameters

=head3 password

Password entered by the user.  This is only used in for sending the user a notification by email of his/her username/password

=head3 profile

Hashref of profile values returned by the function WebGUI::Operation::Profile::validateProfileData($self->session)

=cut

sub createAccountSave {
	my $self = shift;
	my $username = $_[0];
	my $properties = $_[1];
	my $password = $_[2];
	my $profile = $_[3];

	my $i18n = WebGUI::International->new($self->session);


	my $u = WebGUI::User->new($self->session,"new");
	$self->user($u);
	my $userId = $u->userId;
	$u->username($username);
	$u->authMethod($self->authMethod);
	$u->karma($self->session->setting->get("karmaPerLogin"),"Login","Just for logging in.") if ($self->session->setting->get("useKarma"));
	WebGUI::Operation::Profile::saveProfileFields($self->session,$u,$profile) if($profile);
	$self->saveParams($userId,$self->authMethod,$properties);

	if ($self->getSetting("sendWelcomeMessage")){
		my $authInfo = "\n\n".$i18n->get(50).": ".$username;
		$authInfo .= "\n".$i18n->get(51).": ".$password if($password);
		$authInfo .= "\n\n";
		WebGUI::Inbox->new($self->session)->addMessage({
			message	=> $self->getSetting("welcomeMessage").$authInfo,
			subject	=> $i18n->get(870),
			userId	=> $self->userId,
		});
	}
	$self->session->user({user=>$u});
	$self->_logLogin($userId,"success");
	if ($self->session->setting->get("runOnRegistration")) {
		WebGUI::Workflow::Instance->create($self->session, {
			workflowId=>$self->session->setting->get("runOnRegistration"),
			methodName=>"new",
			className=>"WebGUI::User",
			parameters=>$self->session->user->userId,
			priority=>1
			});
	}
	
	
	# If we have a redirectOnLogin, redirect the user
	if ($self->session->scratch->get("redirectOnLogin")) {
		my $url = $self->session->scratch->delete("redirectOnLogin");
		$self->session->http->setRedirect($url);
	} else {
		$self->session->http->setStatus(201,"Account Registration Successful");
	}
	
	
	return undef;
}

#-------------------------------------------------------------------

=head2 deactivateAccount ( method )

Superclass method that displays a confirm message for deactivating a user's account.

=head3 method

Auth method that the form for creating users should call

=cut

sub deactivateAccount {
	my $self = shift;
	my $method = $_[0];
	return $self->session->privilege->vitalComponent() if($self->userId eq '1' || $self->userId eq '3');
	return $self->session->privilege->adminOnly() if(!$self->session->setting->get("selfDeactivation"));
	my $i18n = WebGUI::International->new($self->session);
	my %var;
  	$var{title} = $i18n->get(42);
   	$var{question} =  $i18n->get(60);
   	$var{'yes.url'} = $self->session->url->page('op=auth;method='.$method);
	$var{'yes.label'} = $i18n->get(44);
   	$var{'no.url'} = $self->session->url->page();
	$var{'no.label'} = $i18n->get(45);
	return WebGUI::Asset::Template->new($self->session,"PBtmpl0000000000000057")->process(\%var);
}

#-------------------------------------------------------------------

=head2 deactivateAccount ( method )

Superclass method that performs general functionality for deactivating accounts.

=cut

sub deactivateAccountConfirm {
   my $self = shift;
   return $self->session->privilege->vitalComponent() if($self->userId eq '1' || $self->userId eq '3');
   my $u = $self->user;
   $u->status("Selfdestructed");
   $self->session->var->end();
   $self->session->user({userId=>'1'});
}

#-------------------------------------------------------------------

=head2 deleteParams (  )

Removes the user's authentication parameters from the database for all authentication methods. This is primarily useful when deleting the user's account.

=cut

sub deleteParams {
	my $self = shift;
	$self->session->db->write("delete from authentication where userId=".$self->session->db->quote($self->userId));
}

#-------------------------------------------------------------------

=head2 displayAccount ( method [,vars] )

Superclass method that performs general functionality for viewing editable fields related to a user's account.

=head3 method

Auth method that the form for updating a user's account should call

=head3 vars

Array ref of template vars from subclass

=cut

sub displayAccount {
	my $self = shift;
	my $method = $_[0];
	my $vars = $_[1];

	my $i18n = WebGUI::International->new($self->session);
   $vars->{title} = $i18n->get(61);

	$vars->{'account.form.header'} = WebGUI::Form::formHeader($self->session,{});
	$vars->{'account.form.header'} .= WebGUI::Form::hidden($self->session,{"name"=>"op","value"=>"auth"});
	$vars->{'account.form.header'} .= WebGUI::Form::hidden($self->session,{"name"=>"method","value"=>$method});
	if ($self->session->setting->get("useKarma")) {
		$vars->{'account.form.karma'} = $self->session->user->karma;
		$vars->{'account.form.karma.label'} = $i18n->get(537);
	}
	$vars->{'account.form.submit'} = WebGUI::Form::submit($self->session,{});
	$vars->{'account.form.footer'} = WebGUI::Form::formFooter($self->session,);

	$vars->{'account.options'} = WebGUI::Operation::Shared::accountOptions($self->session);
	return WebGUI::Asset::Template->new($self->session,$self->getAccountTemplateId)->process($vars);
}

#-------------------------------------------------------------------

=head2 displayLogin ( [method,vars] )

Superclass method that performs general functionality for creating new accounts.

=head3 method

Auth method that the form for performing the login routine should call

=head3 vars

Array ref of template vars from subclass

=cut

sub displayLogin {
    	my $self = shift;
	my $method = $_[0] || "login";
	my $vars = $_[1];
	# Automatically set redirectAfterLogin unless we've linked here directly
	# or it's already been set.
	unless ($self->session->form->process("op") eq "auth"
		|| $self->session->scratch->get("redirectAfterLogin") ) {
	   	$self->session->scratch->set("redirectAfterLogin",$self->session->url->page($self->session->env->get("QUERY_STRING")));
	}
	my $i18n = WebGUI::International->new($self->session);
	$vars->{title} = $i18n->get(66);
	my $action;
        if ($self->session->setting->get("encryptLogin")) {
                $action = $self->session->url->page(undef,1);
                $action =~ s/http:/https:/;
        }
	$vars->{'login.form.header'} = WebGUI::Form::formHeader($self->session,{action=>$action});
    	$vars->{'login.form.hidden'} = WebGUI::Form::hidden($self->session,{"name"=>"op","value"=>"auth"});
	$vars->{'login.form.hidden'} .= WebGUI::Form::hidden($self->session,{"name"=>"method","value"=>$method});
	$vars->{'login.form.username'} = WebGUI::Form::text($self->session,{"name"=>"username"});
    	$vars->{'login.form.username.label'} = $i18n->get(50);
    	$vars->{'login.form.password'} = WebGUI::Form::password($self->session,{"name"=>"identifier"});
    	$vars->{'login.form.password.label'} = $i18n->get(51);
	$vars->{'login.form.submit'} = WebGUI::Form::submit($self->session,{"value"=>$i18n->get(52)});
	$vars->{'login.form.footer'} = WebGUI::Form::formFooter($self->session,);
	$vars->{'anonymousRegistration.isAllowed'} = ($self->session->setting->get("anonymousRegistration"));
	$vars->{'createAccount.url'} = $self->session->url->page('op=auth;method=createAccount');
	$vars->{'createAccount.label'} = $i18n->get(67);
	return WebGUI::Asset::Template->new($self->session,$self->getLoginTemplateId)->process($vars);
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

=head2 editUserSettingsForm ( )

You need to override this method in your auth module. It needs to return a the rows in a form for the stuff you want to be configured through webgui settings.

=cut

sub editUserSettingsForm {
}

#-------------------------------------------------------------------

=head2 editUserSettingsFormSave ( )

You need to override this method in your auth module. It's the save for the editUserSettingsFormSave method.

=cut

sub editUserSettingsFormSave {
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

=head2 getAccountTemplateId ( )

This method should be overridden by the subclass and should return the template ID for the display/edit account screen.

=cut

sub getAccountTemplateId {
	return "PBtmpl0000000000000010";
}

#-------------------------------------------------------------------

=head2 getAccountTemplateId ( )

This method should be overridden by the subclass and should return the template ID for the create account screen.

=cut

sub getCreateAccountTemplateId {
	return "PBtmpl0000000000000011";
}

#-------------------------------------------------------------------

=head2 getAccountTemplateId ( )

This method should be overridden by the subclass and should return the template ID for the login screen.

=cut

sub getLoginTemplateId {
	return "PBtmpl0000000000000013";
}

#-------------------------------------------------------------------

=head2 getParams ( )

Returns a hash reference with the user's authentication information.  This method uses data stored in the instance of the object.

=cut

sub getParams {
	my $self = shift;
	my $userId = $_[0] || $self->userId;
	my $authMethod = $_[1] || $self->authMethod;
	return $self->session->db->buildHashRef("select fieldName, fieldData from authentication where userId=".$self->session->db->quote($userId)." and authMethod=".$self->session->db->quote($authMethod));
}

#-------------------------------------------------------------------

=head2 getSetting (  setting  )

Returns a setting for this authMethod instance.  If none is specified, returns the system authMethod setting

=head3 setting

Specify a setting to retrieve

=cut

sub getSetting {
	my $self = shift;
	my $setting = $_[0];
	$setting = lc($self->authMethod).ucfirst($setting);
	return $self->session->setting->get($setting);
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
	$u = WebGUI::User->new($self->session,$uid);
   	$self->session->user({user=>$u});
	$u->karma($self->session->setting->get("karmaPerLogin"),"Login","Just for logging in.") if ($self->session->setting->get("useKarma"));
	$self->_logLogin($uid,"success");
	if ($self->session->scratch->get("redirectAfterLogin")) {
		$self->session->http->setRedirect($self->session->scratch->get("redirectAfterLogin"));
	  	$self->session->scratch->delete("redirectAfterLogin");
	}
	
	my $command = $self->session->config->get("runOnLogin");
    if ($command ne "") {
       WebGUI::Macro::process($self->session,\$command);
	   $self->session->errorHandler->warn("Executing $command");
       my $error = qx($command);
       $self->session->errorHandler->warn($error) if $error;
    }
   
	return undef;
}

#-------------------------------------------------------------------

=head2 logout ( )

Superclass method that performs standard logout routines.

=cut

sub logout {
	my $self = shift;
	$self->session->var->end($self->session->var->get("sessionId"));
	$self->session->user({userId=>'1'});
	my $u = WebGUI::User->new($self->session,1);
	$self->{user} = $u;
	
	my $command = $self->session->config->get("runOnLogout");
    if ($command ne "") {
       WebGUI::Macro::process($self->session,\$command);
	   $self->session->errorHandler->warn("Executing $command");
       my $error = qx($command);
       $self->session->errorHandler->warn($error) if $error;
    }
   
	return undef;
}

#-------------------------------------------------------------------

=head2 new ( session, authMethod [,userId,callable] )

Constructor.

=head3 session

=head3 authMethod

This object's authentication method

=head3 userId

userId for the user requesting authentication.  This defaults to $self->session->user->userId

=head3 callable

Array reference of methods allowed to be called externally;

=cut

sub new {
	my $self = {};
	my $class = shift;
	$self->{_session} = shift;
	$self->{authMethod} = shift;
	my $userId = shift || $self->{_session}->user->userId;
	# Can't do this... if you're updating the account of a user that's not you, this will not work
	#$self->{user} = $self->{_session}->user;
	$self->{user} = WebGUI::User->new($self->{_session}, $userId);
	$self->{error} = "";
	$self->{profile} = ();
	$self->{warning} = "";
	my $call = shift;
	my @callable = ('init', @{$call});
	$self->{callable} = \@callable;
	bless $self, $class;
	return $self;
}

#-------------------------------------------------------------------

=head2 profile ( )

Sets or returns the Profile hash for a user.

=cut

sub profile {
	my $self = shift;
	return $self->{profile} if ($_[0]);
	$self->{profile} = $_[0];
}

#-------------------------------------------------------------------

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setCallable ( callableMethods )

adds elements to the callable routines list.  This list determines whether or not a method in this instance is 
allowed to be called externally

=head3 callableMethods

Array reference containing a list of methods for this authentication instance that can be called externally

=cut

sub setCallable {
	my $self = shift;
	my @callable = @{$self->{callable}};
	@callable = (@callable,@{$_[0]});
}

#-------------------------------------------------------------------

=head2 saveParams ( userId, authMethod, data )

Saves the user's authentication parameters to the database.

=head3 userId

Specify a user id.

=head3 authMethod

Specify the authentication method to save these paramaters under.

=head3 data

A hash reference containing parameter names and values to be saved.

=cut

sub saveParams {
	my $self = shift;
	my ($uid, $authMethod, $data) = @_;
	foreach (keys %{$data}) {
		$self->session->db->write("delete from authentication where userId=".$self->session->db->quote($uid)." and authMethod=".$self->session->db->quote($authMethod)." and fieldName=".$self->session->db->quote($_));
		$self->session->db->write("insert into authentication (userId,authMethod,fieldData,fieldName) values (".$self->session->db->quote($uid).",".$self->session->db->quote($authMethod).",".$self->session->db->quote($data->{$_}).",".$self->session->db->quote($_).")");
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

=head2 validUsername ( username )

Validates the a username.

=cut

sub validUsername {
	my $self = shift;
	my $username = shift;
	WebGUI::Macro::negate(\$username);
	my $error = "";

	if ($self->_isDuplicateUsername($username)) {
		$error .= $self->error;
	}

	if (!$self->_isValidUsername($username)) {
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
