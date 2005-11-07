package WebGUI::Auth::WebGUI;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use Digest::MD5;
use strict;
use URI;
use WebGUI::Asset::Template;
use WebGUI::Auth;
use WebGUI::DateTime;
use WebGUI::FormProcessor;
use WebGUI::HTMLForm;
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Storage::Image;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Auth);


#-------------------------------------------------------------------

=head2 _isValidPassword (  )

  Validates the password.

=cut

sub _isValidPassword {
   my $self = shift;
   my $password = shift;
	 WebGUI::Macro::negate(\$password);
   my $confirm = shift;
	WebGUI::Macro::negate(\$confirm);
   my $error = "";

   if ($password ne $confirm) {
      $error .= '<li>'.WebGUI::International::get(3,'AuthWebGUI').'</li>';
   }
   if ($password eq "") {
      $error .= '<li>'.WebGUI::International::get(4,'AuthWebGUI').'</li>';
   }

   if ($self->getSetting("passwordLength") && length($password) < $self->getSetting("passwordLength")){
      $error .= '<li>'.WebGUI::International::get(7,'AuthWebGUI')." ".$self->getSetting("passwordLength").'</li>';
   }

   $self->error($error);
   return $error eq "";
}

#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub _logSecurityMessage {
    WebGUI::ErrorHandler::security("change password.  Password changed successfully");
}

#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub addUserForm {
   my $self = shift;
   my $userData = $self->getParams;
   my $f = WebGUI::HTMLForm->new;
   $f->password(
	name=>"authWebGUI.identifier",
	label=>WebGUI::International::get(51),
	value=>"password"
	);
   $f->interval(
	-name=>"authWebGUI.passwordTimeout",
	-label=>WebGUI::International::get(16,'AuthWebGUI'),
	-value=>$userData->{passwordTimeout},
	-defaultValue=>$session{setting}{webguiPasswordTimeout}
	);
   my $userChange = $session{setting}{webguiChangeUsername};
   if($userChange || $userChange eq "0"){
      $userChange = $userData->{changeUsername};
   }
   $f->yesNo(
                -name=>"authWebGUI.changeUsername",
                -value=>$userChange,
                -label=>WebGUI::International::get(21,'AuthWebGUI')
             );
   my $passwordChange = $session{setting}{webguiChangePassword};
   if($passwordChange || $passwordChange eq "0"){
      $passwordChange = $userData->{changePassword};
   }
   $f->yesNo(
                -name=>"authWebGUI.changePassword",
                -value=>$passwordChange,
                -label=>WebGUI::International::get(20,'AuthWebGUI')
             );
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 addUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub addUserFormSave {
   my $self = shift;
   my $properties;
   unless ($session{form}{'authWebGUI.identifier'} eq "password") {
      $properties->{identifier} = Digest::MD5::md5_base64($session{form}{'authWebGUI.identifier'});
   }
   $properties->{changeUsername} = $session{form}{'authWebGUI.changeUsername'};
   $properties->{changePassword} = $session{form}{'authWebGUI.changePassword'};
   $properties->{passwordTimeout} =  WebGUI::FormProcessor::interval('authWebGUI.passwordTimeout');
   $properties->{passwordLastUpdated} = time();
   if($session{setting}{webguiExpirePasswordOnCreation}){
      $properties->{passwordLastUpdated} = time() - $properties->{passwordTimeout};   
   }
   $self->SUPER::addUserFormSave($properties);
}

#-------------------------------------------------------------------
sub authenticate {
    my $self = shift;
	my ($identifier, $userData, $auth);
	
	$auth = $self->SUPER::authenticate($_[0]);
	return 0 if !$auth;
	
	$identifier = $_[1];
	$userData = $self->getParams;
	if ((Digest::MD5::md5_base64($identifier) eq $$userData{identifier}) && ($identifier ne "")) {
		return 1;
	} 
	$self->user(WebGUI::User->new(1));
	$self->error(WebGUI::International::get(68));
	return 0;
}

#-------------------------------------------------------------------
sub createAccount {
   my $self = shift;
   my $vars;
   if ($session{user}{userId} ne "1") {
      return $self->displayAccount;
   } elsif (!$session{setting}{anonymousRegistration}) {
 	  return $self->displayLogin;
   } 
   $vars->{'create.message'} = $_[0] if ($_[0]);
	my $storage = WebGUI::Storage::Image->createTemp;
	my ($filename, $challenge) = $storage->addFileFromCaptcha;
	$vars->{useCaptcha} = $session{setting}{webguiUseCaptcha};
	if ($vars->{useCaptcha}) {
   		$vars->{'create.form.captcha'} = WebGUI::Form::text({"name"=>"authWebGUI.captcha", size=>6, maxlength=>6})
			.WebGUI::Form::hidden({name=>"authWebGUI.captcha.validation", value=>Digest::MD5::md5_base64(lc($challenge))})
			.'<img src="'.$storage->getUrl($filename).'" border="0" alt="captcha" align="middle" />';
   		$vars->{'create.form.captcha.label'} = WebGUI::International::get("captcha label","AuthWebGUI");
	}
   $vars->{'create.form.username'} = WebGUI::Form::text({"name"=>"authWebGUI.username","value"=>$session{form}{"authWebGUI.username"}});
   $vars->{'create.form.username.label'} = WebGUI::International::get(50);
   $vars->{'create.form.password'} = WebGUI::Form::password({"name"=>"authWebGUI.identifier"});
   $vars->{'create.form.password.label'} = WebGUI::International::get(51);
   $vars->{'create.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"authWebGUI.identifierConfirm"});
   $vars->{'create.form.passwordConfirm.label'} = WebGUI::International::get(2,'AuthWebGUI');
   $vars->{'create.form.hidden'} = WebGUI::Form::hidden({"name"=>"confirm","value"=>$session{form}{confirm}});
 	$vars->{'recoverPassword.isAllowed'} = $self->getSetting("passwordRecovery");
	   $vars->{'recoverPassword.url'} = WebGUI::URL::page('op=auth;method=recoverPassword');
	   $vars->{'recoverPassword.label'} = WebGUI::International::get(59);
   return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
sub createAccountSave {
   my $self = shift;
   
   return $self->displayAccount if ($session{user}{userId} ne "1");
   
   my $username = $session{form}{'authWebGUI.username'};
   my $password = $session{form}{'authWebGUI.identifier'};
   my $passConfirm = $session{form}{'authWebGUI.identifierConfirm'};
   
   my $error = $self->error if(!$self->validUsername($username));
	if ($session{setting}{webguiUseCaptcha}) {
		unless ($session{form}{'authWebGUI.captcha.validation'} eq Digest::MD5::md5_base64(lc($session{form}{'authWebGUI.captcha'}))) {
			$error .= WebGUI::International::get("captcha failure","AuthWebGUI");
		}
	}
   $error.= $self->error if(!$self->_isValidPassword($password,$passConfirm));
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData();
   $error .= $temp;
   
   return $self->createAccount($error) unless ($error eq "");
   
   #If Email address is not unique, a warning is displayed
   if($warning ne "" && !$session{form}{confirm}){
      $session{form}{confirm} = 1;
      return $self->createAccount('<li>'.WebGUI::International::get(1078).'</li>');
   }

   my $properties;
   $properties->{changeUsername} = $session{setting}{webguiChangeUsername};
   $properties->{changePassword} = $session{setting}{webguiChangePassword};   
   $properties->{identifier} = Digest::MD5::md5_base64($password);
   $properties->{passwordLastUpdated} = time();
   $properties->{passwordTimeout} = $session{setting}{webguiPasswordTimeout};
   $properties->{status} = 'Deactivated' if ($session{setting}{webguiValidateEmail});
   $self->SUPER::createAccountSave($username,$properties,$password,$profile);
   	if ($session{setting}{webguiValidateEmail}) {
		my $key = WebGUI::Id::generate();
		$self->saveParams($self->userId,"WebGUI",{emailValidationKey=>$key});
   		WebGUI::Mail::send(
			$profile->{email},
			WebGUI::International::get('email address validation email subject','AuthWebGUI'),
			WebGUI::International::get('email address validation email body','AuthWebGUI')."\n\n".WebGUI::URL::getSiteURL().WebGUI::URL::page("op=auth;method=validateEmail;key=".$key),
			);
		$self->user->status("Deactivated");
		WebGUI::Session::end($session{var}{sessionId});
		WebGUI::Session::start(1);
		my $u = WebGUI::User->new(1);
		$self->{user} = $u;
		$self->logout;
		return $self->displayLogin(WebGUI::International::get('check email for validation','AuthWebGUI'));
	}
	return "";
}

#-------------------------------------------------------------------
sub deactivateAccount {
   my $self = shift;
   return $self->displayLogin if($self->userId eq '1');
   return $self->SUPER::deactivateAccount("deactivateAccountConfirm");
}

#-------------------------------------------------------------------
sub deactivateAccountConfirm {
   my $self = shift;
   return $self->displayLogin unless ($session{setting}{selfDeactivation});
   return $self->SUPER::deactivateAccountConfirm;
}

#-------------------------------------------------------------------
sub displayAccount {
   my $self = shift;
   my $vars;
   return $self->displayLogin($_[0]) if ($self->userId eq '1');
   my $userData = $self->getParams;
   $vars->{'account.message'} = $_[0] if ($_[0]);
   $vars->{'account.noform'} = 1;
   if($userData->{changeUsername}  || (!defined $userData->{changeUsername} && $session{setting}{webguiChangeUsername})){
      $vars->{'account.form.username'} = WebGUI::Form::text({"name"=>"authWebGUI.username","value"=>$self->username});
      $vars->{'account.form.username.label'} = WebGUI::International::get(50);
      $vars->{'account.noform'} = 0;
   }
   if($userData->{changePassword} || (!defined $userData->{changePassword} && $session{setting}{webguiChangePassword})){
      $vars->{'account.form.password'} = WebGUI::Form::password({"name"=>"authWebGUI.identifier","value"=>"password"});
      $vars->{'account.form.password.label'} = WebGUI::International::get(51);
      $vars->{'account.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"authWebGUI.identifierConfirm","value"=>"password"});
      $vars->{'account.form.passwordConfirm.label'} = WebGUI::International::get(2,'AuthWebGUI');
      $vars->{'account.noform'} = 0;
   }
   $vars->{'account.nofields'} = WebGUI::International::get(22,'AuthWebGUI');
   return $self->SUPER::displayAccount("updateAccount",$vars);
}

#-------------------------------------------------------------------

=head2 displayLogin ( )

   The initial login screen an unauthenticated user sees

=cut

sub displayLogin {
   	my $self = shift;
   	my $vars;
   	return $self->displayAccount($_[0]) if ($self->userId ne "1");
   	$vars->{'login.message'} = $_[0] if ($_[0]);
   	$vars->{'recoverPassword.isAllowed'} = $self->getSetting("passwordRecovery");
   	$vars->{'recoverPassword.url'} = WebGUI::URL::page('op=auth;method=recoverPassword');
   	$vars->{'recoverPassword.label'} = WebGUI::International::get(59);
   	return $self->SUPER::displayLogin("login",$vars);
}

#-------------------------------------------------------------------

=head2 editUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub editUserForm {
   my $self = shift;
   return $self->addUserForm;
}

#-------------------------------------------------------------------

=head2 editUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub editUserFormSave {
   my $self = shift;
   my $properties;
   my $userData = $self->getParams;
   unless (!$session{form}{'authWebGUI.identifier'} || $session{form}{'authWebGUI.identifier'} eq "password") {
      $properties->{identifier} = Digest::MD5::md5_base64($session{form}{'authWebGUI.identifier'});
	   if($userData->{identifier} ne $properties->{identifier}){
	     $properties->{passwordLastUpdated} = time();
      }
   }
   $properties->{passwordTimeout} = WebGUI::FormProcessor::interval('authWebGUI.passwordTimeout');
   $properties->{changeUsername} = $session{form}{'authWebGUI.changeUsername'};
   $properties->{changePassword} = $session{form}{'authWebGUI.changePassword'};
   
   $self->SUPER::editUserFormSave($properties);
}

#-------------------------------------------------------------------

=head2 editUserSettingsForm ( )

  Creates form elements for user settings page custom to this auth module

=cut

sub editUserSettingsForm {
   my $self = shift;
   my $f = WebGUI::HTMLForm->new;
   $f->text(
	         -name=>"webguiPasswordLength",
			 -value=>$session{setting}{webguiPasswordLength},
			 -label=>WebGUI::International::get(15,'AuthWebGUI'),
			 -size=>5,
			 -maxLength=>5,
			);
   $f->interval(
	-name=>"webguiPasswordTimeout",
	-label=>WebGUI::International::get(16,'AuthWebGUI'),
	-value=>$session{setting}{webguiPasswordTimeout}
	);
   $f->yesNo(
             -name=>"webguiExpirePasswordOnCreation",
             -value=>$session{setting}{webguiExpirePasswordOnCreation},
             -label=>WebGUI::International::get(9,'AuthWebGUI')
             );
   $f->yesNo(
             -name=>"webguiSendWelcomeMessage",
             -value=>$session{setting}{webguiSendWelcomeMessage},
             -label=>WebGUI::International::get(868)
             );
   $f->textarea(
                -name=>"webguiWelcomeMessage",
                -value=>$session{setting}{webguiWelcomeMessage},
                -label=>WebGUI::International::get(869)
               );
   $f->yesNo(
                -name=>"webguiChangeUsername",
                -value=>$session{setting}{webguiChangeUsername},
                -label=>WebGUI::International::get(19,'AuthWebGUI')
             );
   $f->yesNo(
                -name=>"webguiChangePassword",
                -value=>$session{setting}{webguiChangePassword},
                -label=>WebGUI::International::get(18,'AuthWebGUI')
             );
   $f->yesNo(
	         -name=>"webguiPasswordRecovery",
             -value=>$session{setting}{webguiPasswordRecovery},
             -label=>WebGUI::International::get(6,'AuthWebGUI')
             );
   $f->textarea(
		-name=>"webguiRecoverPasswordEmail",
		-label=>WebGUI::International::get(134),
		-value=>$session{setting}{webguiRecoverPasswordEmail}
		);
   	$f->yesNo(
		-name=>"webguiValidateEmail",
             	-value=>$session{setting}{webguiValidateEmail},
             	-label=>WebGUI::International::get('validate email','AuthWebGUI')
             	);
   	$f->yesNo(
	     	-name=>"webguiUseCaptcha",
             	-value=>$session{setting}{webguiUseCaptcha},
             	-label=>WebGUI::International::get('use captcha','AuthWebGUI')
             	);
	$f->template(
		-name=>"webguiAccountTemplate",
		-value=>$session{setting}{webguiAccountTemplate},
		-namespace=>"Auth/WebGUI/Account",
		-label=>WebGUI::International::get("account template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiCreateAccountTemplate",
		-value=>$session{setting}{webguiCreateAccountTemplate},
		-namespace=>"Auth/WebGUI/Create",
		-label=>WebGUI::International::get("create account template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiExpiredPasswordTemplate",
		-value=>$session{setting}{webguiExpiredPasswordTemplate},
		-namespace=>"Auth/WebGUI/Expired",
		-label=>WebGUI::International::get("expired password template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiLoginTemplate",
		-value=>$session{setting}{webguiLoginTemplate},
		-namespace=>"Auth/WebGUI/Login",
		-label=>WebGUI::International::get("login template","AuthWebGUI")
		);
	$f->template(
		-name=>"webguiPasswordRecoveryTemplate",
		-value=>$session{setting}{webguiPasswordRecoveryTemplate},
		-namespace=>"Auth/WebGUI/Recovery",
		-label=>WebGUI::International::get("password recovery template","AuthWebGUI")
		);
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub getAccountTemplateId {
	return $session{setting}{webguiAccountTemplate} || "PBtmpl0000000000000010";
}

#-------------------------------------------------------------------
sub getCreateAccountTemplateId {
	return $session{setting}{webguiCreateAccountTemplate} || "PBtmpl0000000000000011";
}

#-------------------------------------------------------------------
sub getExpiredPasswordTemplateId {
	return $session{setting}{webguiExpiredPasswordTemplate} || "PBtmpl0000000000000012";
}

#-------------------------------------------------------------------
sub getLoginTemplateId {
	return $session{setting}{webguiLoginTemplate} || "PBtmpl0000000000000013";
}

#-------------------------------------------------------------------
sub getPasswordRecoveryTemplateId {
	return $session{setting}{webguiPasswordRecoveryTemplate} || "PBtmpl0000000000000014";
}


#-------------------------------------------------------------------
sub login {
   my $self = shift;
   if(!$self->authenticate($session{form}{username},$session{form}{identifier})){
      WebGUI::ErrorHandler::security("login to account ".$session{form}{username}." with invalid information.");
	  return $self->displayLogin("<h1>".WebGUI::International::get(70)."</h1>".$self->error);
   }
   
   my $userData = $self->getParams;
   if($self->getSetting("passwordTimeout") && $userData->{passwordTimeout}){
      my $expireTime = $userData->{passwordLastUpdated} + $userData->{passwordTimeout};
      if(time() >= $expireTime){
         $session{form}{uid} = $self->userId;
		 $self->logout;
   	     return $self->resetExpiredPassword;
      }  
   }
      
   return $self->SUPER::login();
}

#-------------------------------------------------------------------
sub new {
   my $class = shift;
   my $authMethod = $_[0];
   my $userId = $_[1];
   my @callable = ('validateEmail','createAccount','deactivateAccount','displayAccount','displayLogin','login','logout','recoverPassword','resetExpiredPassword','recoverPasswordFinish','createAccountSave','deactivateAccountConfirm','resetExpiredPasswordSave','updateAccount');
   my $self = WebGUI::Auth->new($authMethod,$userId,\@callable);
   bless $self, $class;
}


#-------------------------------------------------------------------
sub recoverPassword {
   my $self = shift;
   return $self->displayLogin if($self->userId ne "1");	
   my $template = 'Auth/WebGUI/Recovery';
   my $vars;
   $vars->{title} = WebGUI::International::get(71);
   $vars->{'recover.form.header'} = "\n\n".WebGUI::Form::formHeader({});
   $vars->{'recover.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
   $vars->{'recover.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>"recoverPasswordFinish"});

   $vars->{'recover.form.submit'} = WebGUI::Form::submit({});
   $vars->{'recover.form.footer'} = WebGUI::Form::formFooter();
    $vars->{'login.url'} = WebGUI::URL::page('op=auth;method=init');
    $vars->{'login.label'} = WebGUI::International::get(58);

	     $vars->{'anonymousRegistration.isAllowed'} = ($session{setting}{anonymousRegistration});
           $vars->{'createAccount.url'} = WebGUI::URL::page('op=auth=;method=createAccount');
           $vars->{'createAccount.label'} = WebGUI::International::get(67);
   $vars->{'recover.message'} = $_[0] if ($_[0]);
   $vars->{'recover.form.email'} = WebGUI::Form::text({"name"=>"email"});
   $vars->{'recover.form.email.label'} = WebGUI::International::get(56);
   return WebGUI::Asset::Template->new($self->getPasswordRecoveryTemplateId)->process($vars);
}

#-------------------------------------------------------------------
sub recoverPasswordFinish {
   my $self = shift;
   return $self->recoverPassword('<ul><li>'.WebGUI::International::get(743).'</li></ul>') if ($session{form}{email} eq "");
   return $self->displayLogin unless ($session{setting}{webguiPasswordRecovery});
   
   my($sth,$username,$userId,$password,$flag,$message,$output,$encryptedPassword,$authMethod);
   $sth = WebGUI::SQL->read("select users.username,users.userId from users, userProfileData where users.userId=userProfileData.userId and 
                             users.authMethod='WebGUI' and userProfileData.fieldName='email' and userProfileData.fieldData=".quote($session{form}{email}));
   $flag = 0;
   while (($username,$userId) = $sth->array) {
	   my $len = $session{setting}{webguiPasswordLength} || 6;
	   $password = "";
	   for(my $i = 0; $i < $len; $i++) {
          $password .= chr(ord('A') + randint(32));
   	   }
   	   $encryptedPassword = Digest::MD5::md5_base64($password);
	   $self->saveParams($userId,"WebGUI",{identifier=>$encryptedPassword});
	   _logSecurityMessage();
	   WebGUI::ErrorHandler::security("recover a password.  Password emailed to: ".$session{form}{email});
	   $message = $session{setting}{webguiRecoverPasswordEmail};
	   $message .= "\n".WebGUI::International::get(50).": ".$username."\n";
	   $message .= WebGUI::International::get(51).": ".$password."\n";
	   WebGUI::Mail::send($session{form}{email},WebGUI::International::get(74),$message);
	   $flag++;
	}
	$sth->finish();
	 
   return $self->displayLogin('<ul><li>'.WebGUI::International::get(75).'</li></ul>') if($flag);
   return $self->recoverPassword('<ul><li>'.WebGUI::International::get(76).'</li></ul>');
}

#-------------------------------------------------------------------
sub resetExpiredPassword {
    my $self = shift;
	my $vars;
	
	$vars->{displayTitle} = '<h3>'.WebGUI::International::get(8,'AuthWebGUI').'</h3>';
    $vars->{'expired.message'} = $_[0] if($_[0]);
    $vars->{'expired.form.header'} = "\n\n".WebGUI::Form::formHeader({});
    $vars->{'expired.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>"resetExpiredPasswordSave"});
   	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden({"name"=>"uid","value"=>$session{form}{uid}});
    
    $vars->{'expired.form.oldPassword'} = WebGUI::Form::password({"name"=>"oldPassword"});
    $vars->{'expired.form.oldPassword.label'} = WebGUI::International::get(10,'AuthWebGUI');
    $vars->{'expired.form.password'} = WebGUI::Form::password({"name"=>"identifier"});
    $vars->{'expired.form.password.label'} = WebGUI::International::get(11,'AuthWebGUI');
    $vars->{'expired.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"identifierConfirm"});
    $vars->{'expired.form.passwordConfirm.label'} = WebGUI::International::get(2,'AuthWebGUI');
    $vars->{'expired.form.submit'} = WebGUI::Form::submit({});
    $vars->{'expired.form.footer'} = WebGUI::Form::formFooter();
	
	return WebGUI::Asset::Template->new($self->getExpiredPasswordTemplateId)->process($vars);
}

#-------------------------------------------------------------------
sub resetExpiredPasswordSave {
   my $self = shift;
   my ($error,$u,$properties,$msg);
   
   $u = WebGUI::User->new($session{form}{uid});
   $session{form}{username} = $u->username;
   
   $error .= $self->error if(!$self->authenticate($u->username,$session{form}{oldPassword}));
   $error .= '<li>'.WebGUI::International::get(5,'AuthWebGUI').'</li>' if($session{form}{identifier} eq "password");
   $error .= '<li>'.WebGUI::International::get(12,'AuthWebGUI').'</li>' if ($session{form}{oldPassword} eq $session{form}{identifier});
   $error .= $self->error if(!$self->_isValidPassword($session{form}{identifier},$session{form}{identifierConfirm}));
   
   return $self->resetExpiredPassword("<h1>".WebGUI::International::get(70)."</h1>".$error) if($error ne "");
   
   $properties->{identifier} = Digest::MD5::md5_base64($session{form}{identifier});
   $properties->{passwordLastUpdated} = time();
   
   $self->saveParams($u->userId,$self->authMethod,$properties);
   _logSecurityMessage();
   
   $msg = $self->login;
   if($msg eq ""){
      $msg = "<li>".WebGUI::International::get(17,'AuthWebGUI').'</li>';
   }
   return $self->displayLogin($msg);
}

#-------------------------------------------------------------------
sub validateEmail {
	my $self = shift;
	my ($userId) = WebGUI::SQL->quickArray("select userId from authentication where fieldData=".quote($session{form}{key})." and fieldName='emailValidationKey' and authMethod='WebGUI'");
	if (defined $userId) {
		my $u = WebGUI::User->new($userId);
		$u->status("Active");
	}
	return $self->displayLogin;
}


#-------------------------------------------------------------------

=head2 updateAccount (  )

  Sets properties to update and passes them to the superclass

=cut

sub updateAccount {
   my $self = shift;
   
   my $username = $session{form}{'authWebGUI.username'};
   my $password = $session{form}{'authWebGUI.identifier'};
   my $passConfirm = $session{form}{'authWebGUI.identifierConfirm'};
   my $display = '<li>'.WebGUI::International::get(81).'</li>';
   my $error = "";
   
   if($self->userId eq '1'){
      return $self->displayLogin;
   }
   
   if($username){
      if($self->_isDuplicateUsername($username)){
         $error .= $self->error;
      }
   
      if(!$self->_isValidUsername($username)){
         $error .= $self->error;
      }	  
   }
    
   if($password){
      if(!$self->_isValidPassword($password,$passConfirm)){
         $error .= $self->error;
	  }
   }
   
   if($error){
      $display = $error;
   }
   
   my $properties;
   my $u = $self->user;
   if(!$error){
      if($username){
	     $u->username($username);
         $session{form}{uid} = $u->userId;
	  }
	  if($password){
	     my $userData = $self->getParams;
         unless ($password eq "password") {
            $properties->{identifier} = Digest::MD5::md5_base64($password);
			_logSecurityMessage();
	        if($userData->{identifier} ne $properties->{identifier}){
	           $properties->{passwordLastUpdated} = time();
            }
         }
      }
   }
   $self->saveParams($u->userId,$self->authMethod,$properties);
   WebGUI::Session::refreshUserInfo($u->userId);
   
  return $self->displayAccount($display);
}

1;

