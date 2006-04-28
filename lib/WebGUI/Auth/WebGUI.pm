package WebGUI::Auth::WebGUI;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::HTMLForm;
use WebGUI::Macro;
use WebGUI::Mail::Send;
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

	my $i18n = WebGUI::International->new($self->session,'AuthWebGUI');
   if ($password ne $confirm) {
      $error .= '<li>'.$i18n->get(3).'</li>';
   }
   if ($password eq "") {
      $error .= '<li>'.$i18n->get(4).'</li>';
   }

   if ($self->getSetting("passwordLength") && length($password) < $self->getSetting("passwordLength")){
      $error .= '<li>'.$i18n->get(7)." ".$self->getSetting("passwordLength").'</li>';
   }

   $self->error($error);
   return $error eq "";
}

#-------------------------------------------------------------------

=head2 _logSecurityMessage ( )

  Logs the successful password change message.

=cut

sub _logSecurityMessage {
	my $self = shift;
    $self->session->errorHandler->security("change password.  Password changed successfully");
}

#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub addUserForm {
   my $self = shift;
   my $userData = $self->getParams;
   my $f = WebGUI::HTMLForm->new($self->session);
	my $i18n = WebGUI::International->new($self->session);
   $f->password(
	name=>"authWebGUI.identifier",
	label=>$i18n->get(51),
	value=>"password"
	);
   $f->interval(
	-name=>"authWebGUI.passwordTimeout",
	-label=>$i18n->get(16,'AuthWebGUI'),
	-value=>$userData->{passwordTimeout},
	-defaultValue=>$self->session->setting->get("webguiPasswordTimeout")
	);
   my $userChange = $self->session->setting->get("webguiChangeUsername");
   if($userChange || $userChange eq "0"){
      $userChange = $userData->{changeUsername};
   }
   $f->yesNo(
                -name=>"authWebGUI.changeUsername",
                -value=>$userChange,
                -label=>$i18n->get(21,'AuthWebGUI')
             );
   my $passwordChange = $self->session->setting->get("webguiChangePassword");
   if($passwordChange || $passwordChange eq "0"){
      $passwordChange = $userData->{changePassword};
   }
   $f->yesNo(
                -name=>"authWebGUI.changePassword",
                -value=>$passwordChange,
                -label=>$i18n->get(20,'AuthWebGUI')
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
   unless ($self->session->form->process('authWebGUI.identifier') eq "password") {
      $properties->{identifier} = Digest::MD5::md5_base64($self->session->form->process('authWebGUI.identifier'));
   }
   $properties->{changeUsername} = $self->session->form->process('authWebGUI.changeUsername');
   $properties->{changePassword} = $self->session->form->process('authWebGUI.changePassword');
   $properties->{passwordTimeout} =  $self->session->form->interval('authWebGUI.passwordTimeout');
   $properties->{passwordLastUpdated} =$self->session->datetime->time();
   if($self->session->setting->get("webguiExpirePasswordOnCreation")){
      $properties->{passwordLastUpdated} =$self->session->datetime->time() - $properties->{passwordTimeout};   
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
	$self->user(WebGUI::User->new($self->session,1));
	my $i18n = WebGUI::International->new($self->session);
	$self->error($i18n->get(68));
	return 0;
}

#-------------------------------------------------------------------
sub createAccount {
   my $self = shift;
	my $message = shift;
	my $confirm = shift || $self->session->form->process("confirm");
   my $vars;
   if ($self->session->user->userId ne "1") {
      return $self->displayAccount;
   } elsif (!$self->session->setting->get("anonymousRegistration")) {
 	  return $self->displayLogin;
   } 
	my $i18n = WebGUI::International->new($self->session);
   $vars->{'create.message'} = $message if ($message);
	$vars->{useCaptcha} = $self->session->setting->get("webguiUseCaptcha");
	if ($vars->{useCaptcha}) {
		use WebGUI::Form::Captcha;
		my $captcha = WebGUI::Form::Captcha->new($self->session,{"name"=>"authWebGUI.captcha"});
   		$vars->{'create.form.captcha'} = $captcha->toHtml.'<span class="formSubtext">'.$captcha->get('subtext').'</span>';
   		$vars->{'create.form.captcha.label'} = $i18n->get("captcha label","AuthWebGUI");
	}
   $vars->{'create.form.username'} = WebGUI::Form::text($self->session,{"name"=>"authWebGUI.username","value"=>$self->session->form->process("authWebGUI.username")});
   $vars->{'create.form.username.label'} = $i18n->get(50);
   $vars->{'create.form.password'} = WebGUI::Form::password($self->session,{"name"=>"authWebGUI.identifier"});
   $vars->{'create.form.password.label'} = $i18n->get(51);
   $vars->{'create.form.passwordConfirm'} = WebGUI::Form::password($self->session,{"name"=>"authWebGUI.identifierConfirm"});
   $vars->{'create.form.passwordConfirm.label'} = $i18n->get(2,'AuthWebGUI');
   $vars->{'create.form.hidden'} = WebGUI::Form::hidden($self->session,{"name"=>"confirm","value"=>$confirm});
 	$vars->{'recoverPassword.isAllowed'} = $self->getSetting("passwordRecovery");
	   $vars->{'recoverPassword.url'} = $self->session->url->page('op=auth;method=recoverPassword');
	   $vars->{'recoverPassword.label'} = $i18n->get(59);
   return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
sub createAccountSave {
   my $self = shift;
   my $i18n = WebGUI::International->new($self->session);
 
  return $self->displayAccount if ($self->session->user->userId ne "1");

   #Make sure anonymous registration is enabled 
   unless ($self->session->setting->get("anonymousRegistration")) {    
     $self->session->errorHandler->security($i18n->get("no registration hack", "AuthWebGUI"));
     return $self->displayLogin;
   }
   my $username = $self->session->form->process('authWebGUI.username');
   my $password = $self->session->form->process('authWebGUI.identifier');
   my $passConfirm = $self->session->form->process('authWebGUI.identifierConfirm');
   
   my $error;
	
   $error = $self->error unless($self->validUsername($username));
	if ($self->session->setting->get("webguiUseCaptcha")) {
		unless ($self->session->form->process('authWebGUI.captcha', "Captcha")) {
			$error .= $i18n->get("captcha failure","AuthWebGUI");
		}
	}
   $error .= $self->error unless($self->_isValidPassword($password,$passConfirm));
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData($self->session);
   $error .= $temp;
   
   return $self->createAccount($error) unless ($error eq "");
   
   #If Email address is not unique, a warning is displayed
   if($warning ne "" && !$self->session->form->process("confirm")){
      return $self->createAccount('<li>'.$i18n->get(1078).'</li>', 1);
   }

   my $properties;
   $properties->{changeUsername} = $self->session->setting->get("webguiChangeUsername");
   $properties->{changePassword} = $self->session->setting->get("webguiChangePassword");   
   $properties->{identifier} = Digest::MD5::md5_base64($password);
   $properties->{passwordLastUpdated} =$self->session->datetime->time();
   $properties->{passwordTimeout} = $self->session->setting->get("webguiPasswordTimeout");
   $properties->{status} = 'Deactivated' if ($self->session->setting->get("webguiValidateEmail"));
   $self->SUPER::createAccountSave($username,$properties,$password,$profile);
   	if ($self->session->setting->get("webguiValidateEmail")) {
		my $key = $self->session->id->generate();
		$self->saveParams($self->userId,"WebGUI",{emailValidationKey=>$key});
   		my $mail = WebGUI::Mail::Send->create($self->session,{
			to=>$profile->{email},
			subject=>$i18n->get('email address validation email subject','AuthWebGUI')
			});
		$mail->addText($i18n->get('email address validation email body','AuthWebGUI')."\n\n".$self->session->url->getSiteURL().$self->session->url->page("op=auth;method=validateEmail;key=".$key));
		$mail->addFooter;
		$mail->send;
		$self->user->status("Deactivated");
		$self->session->var->end($self->session->var->get("sessionId"));
		$self->session->var->start(1,$self->session->getId);
		my $u = WebGUI::User->new($self->session,1);
		$self->{user} = $u;
		$self->logout;
		return $self->displayLogin($i18n->get('check email for validation','AuthWebGUI'));
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
   return $self->displayLogin unless ($self->session->setting->get("selfDeactivation"));
   return $self->SUPER::deactivateAccountConfirm;
}

#-------------------------------------------------------------------
sub displayAccount {
   my $self = shift;
   my $vars;
   return $self->displayLogin($_[0]) if ($self->userId eq '1');
	my $i18n = WebGUI::International->new($self->session);
   my $userData = $self->getParams;
   $vars->{'account.message'} = $_[0] if ($_[0]);
   $vars->{'account.noform'} = 1;
   if($userData->{changeUsername}  || (!defined $userData->{changeUsername} && $self->session->setting->get("webguiChangeUsername"))){
      $vars->{'account.form.username'} = WebGUI::Form::text($self->session,{"name"=>"authWebGUI.username","value"=>$self->username});
      $vars->{'account.form.username.label'} = $i18n->get(50);
      $vars->{'account.noform'} = 0;
   }
   if($userData->{changePassword} || (!defined $userData->{changePassword} && $self->session->setting->get("webguiChangePassword"))){
      $vars->{'account.form.password'} = WebGUI::Form::password($self->session,{"name"=>"authWebGUI.identifier","value"=>"password"});
      $vars->{'account.form.password.label'} = $i18n->get(51);
      $vars->{'account.form.passwordConfirm'} = WebGUI::Form::password($self->session,{"name"=>"authWebGUI.identifierConfirm","value"=>"password"});
      $vars->{'account.form.passwordConfirm.label'} = $i18n->get(2,'AuthWebGUI');
      $vars->{'account.noform'} = 0;
   }
   $vars->{'account.nofields'} = $i18n->get(22,'AuthWebGUI');
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
	my $i18n = WebGUI::International->new($self->session);
   	$vars->{'login.message'} = $_[0] if ($_[0]);
   	$vars->{'recoverPassword.isAllowed'} = $self->getSetting("passwordRecovery");
   	$vars->{'recoverPassword.url'} = $self->session->url->page('op=auth;method=recoverPassword');
   	$vars->{'recoverPassword.label'} = $i18n->get(59);
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
   my $userId = $self->session->form->get("uid");
   my $properties;
   my $userData = $self->getParams($userId);
   unless (!$self->session->form->process('authWebGUI.identifier') || $self->session->form->process('authWebGUI.identifier') eq "password") {
      $properties->{identifier} = Digest::MD5::md5_base64($self->session->form->process('authWebGUI.identifier'));
	   if($userData->{identifier} ne $properties->{identifier}){
	     $properties->{passwordLastUpdated} =$self->session->datetime->time();
      }
   }
   $properties->{passwordTimeout} = $self->session->form->interval('authWebGUI.passwordTimeout');
   $properties->{changeUsername} = $self->session->form->process('authWebGUI.changeUsername');
   $properties->{changePassword} = $self->session->form->process('authWebGUI.changePassword');
   
   $self->SUPER::editUserFormSave($properties);
}

#-------------------------------------------------------------------

=head2 editUserSettingsForm ( )

  Creates form elements for user settings page custom to this auth module

=cut

sub editUserSettingsForm {
   my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'AuthWebGUI');
   my $f = WebGUI::HTMLForm->new($self->session);
   $f->text(
	         -name=>"webguiPasswordLength",
			 -value=>$self->session->setting->get("webguiPasswordLength"),
			 -label=>$i18n->get(15),
			 -size=>5,
			 -maxLength=>5,
			);
   $f->interval(
	-name=>"webguiPasswordTimeout",
	-label=>$i18n->get(16),
	-value=>$self->session->setting->get("webguiPasswordTimeout")
	);
   $f->yesNo(
             -name=>"webguiExpirePasswordOnCreation",
             -value=>$self->session->setting->get("webguiExpirePasswordOnCreation"),
             -label=>$i18n->get(9)
             );
   $f->yesNo(
             -name=>"webguiSendWelcomeMessage",
             -value=>$self->session->setting->get("webguiSendWelcomeMessage"),
             -label=>$i18n->get(868,'WebGUI')
             );
   $f->textarea(
                -name=>"webguiWelcomeMessage",
                -value=>$self->session->setting->get("webguiWelcomeMessage"),
                -label=>$i18n->get(869,'WebGUI')
               );
   $f->yesNo(
                -name=>"webguiChangeUsername",
                -value=>$self->session->setting->get("webguiChangeUsername"),
                -label=>$i18n->get(19)
             );
   $f->yesNo(
                -name=>"webguiChangePassword",
                -value=>$self->session->setting->get("webguiChangePassword"),
                -label=>$i18n->get(18)
             );
   $f->yesNo(
	         -name=>"webguiPasswordRecovery",
             -value=>$self->session->setting->get("webguiPasswordRecovery"),
             -label=>$i18n->get(6)
             );
   $f->textarea(
		-name=>"webguiRecoverPasswordEmail",
		-label=>$i18n->get(134, 'WebGUI'),
		-value=>$self->session->setting->get("webguiRecoverPasswordEmail")
		);
   	$f->yesNo(
		-name=>"webguiValidateEmail",
             	-value=>$self->session->setting->get("webguiValidateEmail"),
             	-label=>$i18n->get('validate email')
             	);
   	$f->yesNo(
	     	-name=>"webguiUseCaptcha",
             	-value=>$self->session->setting->get("webguiUseCaptcha"),
             	-label=>$i18n->get('use captcha')
             	);
	$f->template(
		-name=>"webguiAccountTemplate",
		-value=>$self->session->setting->get("webguiAccountTemplate"),
		-namespace=>"Auth/WebGUI/Account",
		-label=>$i18n->get("account template")
		);
	$f->template(
		-name=>"webguiCreateAccountTemplate",
		-value=>$self->session->setting->get("webguiCreateAccountTemplate"),
		-namespace=>"Auth/WebGUI/Create",
		-label=>$i18n->get("create account template")
		);
	$f->template(
		-name=>"webguiExpiredPasswordTemplate",
		-value=>$self->session->setting->get("webguiExpiredPasswordTemplate"),
		-namespace=>"Auth/WebGUI/Expired",
		-label=>$i18n->get("expired password template")
		);
	$f->template(
		-name=>"webguiLoginTemplate",
		-value=>$self->session->setting->get("webguiLoginTemplate"),
		-namespace=>"Auth/WebGUI/Login",
		-label=>$i18n->get("login template")
		);
	$f->template(
		-name=>"webguiPasswordRecoveryTemplate",
		-value=>$self->session->setting->get("webguiPasswordRecoveryTemplate"),
		-namespace=>"Auth/WebGUI/Recovery",
		-label=>$i18n->get("password recovery template")
		);
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub getAccountTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiAccountTemplate") || "PBtmpl0000000000000010";
}

#-------------------------------------------------------------------
sub getCreateAccountTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiCreateAccountTemplate") || "PBtmpl0000000000000011";
}

#-------------------------------------------------------------------
sub getExpiredPasswordTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiExpiredPasswordTemplate") || "PBtmpl0000000000000012";
}

#-------------------------------------------------------------------
sub getLoginTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiLoginTemplate") || "PBtmpl0000000000000013";
}

#-------------------------------------------------------------------
sub getPasswordRecoveryTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiPasswordRecoveryTemplate") || "PBtmpl0000000000000014";
}


#-------------------------------------------------------------------
sub login {
   my $self = shift;
   if(!$self->authenticate($self->session->form->process("username"),$self->session->form->process("identifier"))){
      $self->session->http->setStatus("401","Incorrect Credentials");
      $self->session->errorHandler->security("login to account ".$self->session->form->process("username")." with invalid information.");
	my $i18n = WebGUI::International->new($self->session);
	  return $self->displayLogin("<h1>".$i18n->get(70)."</h1>".$self->error);
   }
   
   my $userData = $self->getParams;
   if($self->getSetting("passwordTimeout") && $userData->{passwordTimeout}){
      my $expireTime = $userData->{passwordLastUpdated} + $userData->{passwordTimeout};
      if ($self->session->datetime->time() >= $expireTime){
		 $self->logout;
   	     return $self->resetExpiredPassword($self->userId);
      }  
   }
      
   return $self->SUPER::login();
}

#-------------------------------------------------------------------
sub new {
   my $class = shift;
	my $session = shift;
   my $authMethod = $_[0];
   my $userId = $_[1];
   my @callable = ('validateEmail','createAccount','deactivateAccount','displayAccount','displayLogin','login','logout','recoverPassword','resetExpiredPassword','recoverPasswordFinish','createAccountSave','deactivateAccountConfirm','resetExpiredPasswordSave','updateAccount');
   my $self = WebGUI::Auth->new($session,$authMethod,$userId,\@callable);
   bless $self, $class;
}


#-------------------------------------------------------------------
sub recoverPassword {
	my $self = shift;
	return $self->displayLogin if($self->userId ne "1");	
	my $template = 'Auth/WebGUI/Recovery';
	my $vars;
	my $i18n = WebGUI::International->new($self->session);
	$vars->{title} = $i18n->get(71);
	$vars->{'recover.form.header'} = "\n\n".WebGUI::Form::formHeader($self->session,{});
	$vars->{'recover.form.hidden'} = WebGUI::Form::hidden($self->session,{"name"=>"op","value"=>"auth"});
	$vars->{'recover.form.hidden'} .= WebGUI::Form::hidden($self->session,{"name"=>"method","value"=>"recoverPasswordFinish"});

	$vars->{'recover.form.submit'} = WebGUI::Form::submit($self->session,{});
	$vars->{'recover.form.footer'} = WebGUI::Form::formFooter($self->session,);
	$vars->{'login.url'} = $self->session->url->page('op=auth;method=init');
	$vars->{'login.label'} = $i18n->get(58);

	$vars->{'anonymousRegistration.isAllowed'} = ($self->session->setting->get("anonymousRegistration"));
	$vars->{'createAccount.url'} = $self->session->url->page('op=auth;method=createAccount');
	$vars->{'createAccount.label'} = $i18n->get(67);
	$vars->{'recover.message'} = $_[0] if ($_[0]);
	$vars->{'recover.form.email'} = WebGUI::Form::text($self->session,{"name"=>"email"});
	$vars->{'recover.form.email.label'} = $i18n->get(56);
	return WebGUI::Asset::Template->new($self->session,$self->getPasswordRecoveryTemplateId)->process($vars);
}

#-------------------------------------------------------------------
sub recoverPasswordFinish {
   my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
   return $self->recoverPassword('<ul><li>'.$i18n->get(743).'</li></ul>') if ($self->session->form->process("email") eq "");
   return $self->displayLogin unless ($self->session->setting->get("webguiPasswordRecovery"));
   
   my($sth,$username,$userId,$password,$flag,$message,$output,$encryptedPassword,$authMethod);
   $sth = $self->session->db->read("select users.username,users.userId from users, userProfileData where users.userId=userProfileData.userId and 
                             users.authMethod='WebGUI' and userProfileData.fieldName='email' and userProfileData.fieldData=".$self->session->db->quote($self->session->form->process("email")));
   $flag = 0;
   while (($username,$userId) = $sth->array) {
	   my $len = $self->session->setting->get("webguiPasswordLength") || 6;
	   $password = "";
	   for(my $i = 0; $i < $len; $i++) {
          $password .= chr(ord('A') + randint(32));
   	   }
   	   $encryptedPassword = Digest::MD5::md5_base64($password);
	   $self->saveParams($userId,"WebGUI",{identifier=>$encryptedPassword});
	   $self->_logSecurityMessage();
	   $self->session->errorHandler->security("recover a password.  Password emailed to: ".$self->session->form->process("email"));
	   $message = $self->session->setting->get("webguiRecoverPasswordEmail");
	   $message .= "\n".$i18n->get(50).": ".$username."\n";
	   $message .= $i18n->get(51).": ".$password."\n";
	   my $mail = WebGUI::Mail::Send->new($self->session, {to=>$self->session->form->process("email"),subject=>$i18n->get(74)});
		$mail->addText($message);
		$mail->addFooter;
		$mail->send;
	   $flag++;
	}
	$sth->finish();
	 
   return $self->displayLogin('<ul><li>'.$i18n->get(75).'</li></ul>') if($flag);
   return $self->recoverPassword('<ul><li>'.$i18n->get(76).'</li></ul>');
}

#-------------------------------------------------------------------
sub resetExpiredPassword {
    my $self = shift;
	my $uid = shift || $self->session->form->process("uid");
	my $vars;
	
	my $i18n = WebGUI::International->new($self->session);
	$vars->{displayTitle} = '<h3>'.$i18n->get(8,'AuthWebGUI').'</h3>';
    $vars->{'expired.message'} = $_[0] if($_[0]);
    $vars->{'expired.form.header'} = "\n\n".WebGUI::Form::formHeader($self->session,{});
    $vars->{'expired.form.hidden'} = WebGUI::Form::hidden($self->session,{"name"=>"op","value"=>"auth"});
	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden($self->session,{"name"=>"method","value"=>"resetExpiredPasswordSave"});
   	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden($self->session,{"name"=>"uid","value"=>$uid});
    
    $vars->{'expired.form.oldPassword'} = WebGUI::Form::password($self->session,{"name"=>"oldPassword"});
    $vars->{'expired.form.oldPassword.label'} = $i18n->get(10,'AuthWebGUI');
    $vars->{'expired.form.password'} = WebGUI::Form::password($self->session,{"name"=>"identifier"});
    $vars->{'expired.form.password.label'} = $i18n->get(11,'AuthWebGUI');
    $vars->{'expired.form.passwordConfirm'} = WebGUI::Form::password($self->session,{"name"=>"identifierConfirm"});
    $vars->{'expired.form.passwordConfirm.label'} = $i18n->get(2,'AuthWebGUI');
    $vars->{'expired.form.submit'} = WebGUI::Form::submit($self->session,{});
    $vars->{'expired.form.footer'} = WebGUI::Form::formFooter($self->session,);
	
	return WebGUI::Asset::Template->new($self->session,$self->getExpiredPasswordTemplateId)->process($vars);
}

#-------------------------------------------------------------------
sub resetExpiredPasswordSave {
   my $self = shift;
   my ($error,$u,$properties,$msg);
   
   $u = WebGUI::User->new($self->session,$self->session->form->process("uid"));
	my $i18n = WebGUI::International->new($self->session);
   
   $error .= $self->error if(!$self->authenticate($u->username,$self->session->form->process("oldPassword")));
   $error .= '<li>'.$i18n->get(5,'AuthWebGUI').'</li>' if($self->session->form->process("identifier") eq "password");
   $error .= '<li>'.$i18n->get(12,'AuthWebGUI').'</li>' if ($self->session->form->process("oldPassword") eq $self->session->form->process("identifier"));
   $error .= $self->error if(!$self->_isValidPassword($self->session->form->process("identifier"),$self->session->form->process("identifierConfirm")));
   
   return $self->resetExpiredPassword("<h1>".$i18n->get(70)."</h1>".$error) if($error ne "");
   
   $properties->{identifier} = Digest::MD5::md5_base64($self->session->form->process("identifier"));
   $properties->{passwordLastUpdated} =$self->session->datetime->time();
   
   $self->saveParams($u->userId,$self->authMethod,$properties);
   $self->_logSecurityMessage();
   
   $msg = $self->login;
   if($msg eq ""){
      $msg = "<li>".$i18n->get(17,'AuthWebGUI').'</li>';
   }
   return $self->displayLogin($msg);
}

#-------------------------------------------------------------------
sub validateEmail {
	my $self = shift;
	my ($userId) = $self->session->db->quickArray("select userId from authentication where fieldData=".$self->session->db->quote($self->session->form->process("key"))." and fieldName='emailValidationKey' and authMethod='WebGUI'");
	if (defined $userId) {
		my $u = WebGUI::User->new($self->session,$userId);
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
   
	my $i18n = WebGUI::International->new($self->session);
   my $username = $self->session->form->process('authWebGUI.username');
   my $password = $self->session->form->process('authWebGUI.identifier');
   my $passConfirm = $self->session->form->process('authWebGUI.identifierConfirm');
   my $display = '<li>'.$i18n->get(81).'</li>';
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
	  }
	  if($password){
	     my $userData = $self->getParams;
         unless ($password eq "password") {
            $properties->{identifier} = Digest::MD5::md5_base64($password);
			$self->_logSecurityMessage();
	        if($userData->{identifier} ne $properties->{identifier}){
	           $properties->{passwordLastUpdated} =$self->session->datetime->time();
            }
         }
      }
   }
   $self->saveParams($u->userId,$self->authMethod,$properties);
   $self->session->user(undef,undef,$u);
   
  return $self->displayAccount($display);
}

1;

