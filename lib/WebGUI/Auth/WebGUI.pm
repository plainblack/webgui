package WebGUI::Auth::WebGUI;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use Digest::MD5;
use strict;
use WebGUI::Auth;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Mail;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Auth);

#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub addUserForm {
   my $self = shift;
   my $userData = $self->getParams;
   my $f = WebGUI::HTMLForm->new;
   $f->password("authWebGUI.identifier",WebGUI::International::get(51),"password");
   $f->interval("authWebGUI.passwordTimeout",WebGUI::International::get(16,'Auth/WebGUI'),WebGUI::DateTime::secondsToInterval(($userData->{passwordTimeout} || $session{setting}{webguiPasswordTimeout})));
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
   
   $properties->{passwordTimeout} =  WebGUI::DateTime::intervalToSeconds($session{form}{'authWebGUI.passwordTimeout_interval'},$session{form}{'authWebGUI.passwordTimeout_units'});
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
	
	$auth = $self->SUPER::authenticate();
	return 0 if !$auth;
	
	$identifier = $_[0];
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
   if ($session{user}{userId} != 1) {
      return $self->displayAccount;
   } elsif (!$session{setting}{anonymousRegistration}) {
 	  return $self->displayLogin;
   } 
   $vars->{'create.message'} = $_[0] if ($_[0]);
   $vars->{'create.form.username'} = WebGUI::Form::text({"name"=>"authWebGUI.username","value"=>$session{form}{"authWebGUI.username"}});
   $vars->{'create.form.username.label'} = WebGUI::International::get(50);
   $vars->{'create.form.password'} = WebGUI::Form::password({"name"=>"authWebGUI.identifier","value"=>$session{form}{"authWebGUI.identifier"}});
   $vars->{'create.form.password.label'} = WebGUI::International::get(51);
   $vars->{'create.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"authWebGUI.identifierConfirm","value"=>$session{form}{"authWebGUI.identifierConfirm"}});
   $vars->{'create.form.passwordConfirm.label'} = WebGUI::International::get(2,'Auth/WebGUI');
   $vars->{'create.form.hidden'} = WebGUI::Form::hidden({"name"=>"confirm","value"=>$session{form}{confirm}});
   return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
sub createAccountSave {
   my $self = shift;
   
   return $self->displayAccount if ($session{user}{userId} != 1);
   
   my $username = $session{form}{'authWebGUI.username'};
   my $password = $session{form}{'authWebGUI.identifier'};
   my $passConfirm = $session{form}{'authWebGUI.identifierConfirm'};
   
   my $error = $self->error if(!$self->validUsernameAndPassword($username,$password,$passConfirm));
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData();
   $error .= $temp;
   
   return $self->createAccount($error) unless ($error eq "");
   
   #If Email address is not unique, a warning is displayed
   if($warning ne "" && !$session{form}{confirm}){
      $session{form}{confirm} = 1;
      return $self->createAccount('<li>'.WebGUI::International::get(1078));
   }

   my $properties;
   $properties->{identifier} = Digest::MD5::md5_base64($password);
   $properties->{passwordLastUpdated} = time();
   $properties->{passwordTimeout} = $session{setting}{webguiPasswordTimeout};
      
   return $self->SUPER::createAccountSave($username,$properties,$password,$profile);
   #my $u = WebGUI::User->new("new");
   #$self->user($u);
   #my $userId = $u->userId;
   #$u->username($username);
   #$u->authMethod($self->authMethod);
   #$u->karma($session{setting}{karmaPerLogin},"Login","Just for logging in.") if ($session{setting}{useKarma});
   #WebGUI::Operation::Profile::saveProfileFields($u,$profile);
   
   #my %properties;
   #$properties{identifier} = Digest::MD5::md5_base64($password);
   #$properties{passwordLastUpdated} = $lastUpdated;
   #$properties{passwordTimeout} = $session{setting}{webguiPasswordTimeout};
   #$self->saveParams($userId,$self->authMethod,\%properties);
   #my $authInfo = "\n\n".WebGUI::International::get(50).": ".$username."\n".WebGUI::International::get(51).": ".$password."\n\n";
   #WebGUI::MessageLog::addEntry($self->userId,"",WebGUI::International::get(870),$session{setting}{webguiWelcomeMessage}.$authInfo) if ($session{setting}{webguiSendWelcomeMessage});
   
   #WebGUI::Session::convertVisitorToUser($session{var}{sessionId},$userId);
   #$self->_logLogin($userId,"success");
   #system(WebGUI::Macro::process($session{setting}{runOnRegistration})) if ($session{setting}{runOnRegistration} ne "");
   #WebGUI::MessageLog::addInternationalizedEntry('',$session{setting}{onNewUserAlertGroup},'',536) if ($session{setting}{alertOnNewUser});
   #return "";
}

#-------------------------------------------------------------------
sub deactivateAccount {
   my $self = shift;
   return $self->displayLogin if($self->userId == 1);
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
   return $self->displayLogin($_[0]) if ($self->userId == 1);
   $vars->{'account.message'} = $_[0] if ($_[0]);
   $vars->{'account.form.username'} = WebGUI::Form::text({"name"=>"authWebGUI.username","value"=>$self->username});
   $vars->{'account.form.username.label'} = WebGUI::International::get(50);
   $vars->{'account.form.password'} = WebGUI::Form::password({"name"=>"authWebGUI.identifier","value"=>"password"});
   $vars->{'account.form.password.label'} = WebGUI::International::get(51);
   $vars->{'account.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"authWebGUI.identifierConfirm","value"=>"password"});
   $vars->{'account.form.passwordConfirm.label'} = WebGUI::International::get(2,'Auth/WebGUI');
   return $self->SUPER::displayAccount("updateAccount",$vars);
}

#-------------------------------------------------------------------

=head2 displayLogin ( )

   The initial login screen an unauthenticated user sees

=cut

sub displayLogin {
   my $self = shift;
   my $vars;
   return $self->displayAccount($_[0]) if ($self->userId != 1);
   $vars->{'login.message'} = $_[0] if ($_[0]);
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
   $properties->{passwordTimeout} = WebGUI::DateTime::intervalToSeconds($session{form}{'authWebGUI.passwordTimeout_interval'},$session{form}{'authWebGUI.passwordTimeout_units'});
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
			 -label=>WebGUI::International::get(15,'Auth/WebGUI'),
			 -size=>5,
			 -maxLength=>5,
			);
   $f->interval("webguiPasswordTimeout",WebGUI::International::get(16,'Auth/WebGUI'),WebGUI::DateTime::secondsToInterval($session{setting}{webguiPasswordTimeout}));
   $f->yesNo(
             -name=>"webguiExpirePasswordOnCreation",
             -value=>$session{setting}{webguiExpirePasswordOnCreation},
             -label=>WebGUI::International::get(9,'Auth/WebGUI')
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
	         -name=>"webguiPasswordRecovery",
             -value=>$session{setting}{webguiPasswordRecovery},
             -label=>WebGUI::International::get(6,'Auth/WebGUI')
             );
   $f->textarea("webguiRecoverPasswordEmail",WebGUI::International::get(134),$session{setting}{webguiRecoverPasswordEmail});
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub login {
   my $self = shift;
   if(!$self->authenticate($session{form}{identifier})){
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
   my @callable = ('createAccount','deactivateAccount','displayAccount','displayLogin','login','logout','recoverPassword','resetExpiredPasswordSave','recoverPasswordFinish','createAccountSave','deactivateAccountConfirm','resetExpiredPasswordSave','updateAccount');
   my $self = WebGUI::Auth->new($authMethod,$userId,\@callable);
   bless $self, $class;
}


#-------------------------------------------------------------------
sub recoverPassword {   
   my $self = shift;
   my $vars;
   return $self->displayLogin if($self->userId != 1);	
   $vars->{'recover.message'} = $_[0] if ($_[0]);
   $vars->{'recover.form.email'} = WebGUI::Form::text({"name"=>"email"});
   $vars->{'recover.form.email.label'} = WebGUI::International::get(56);
   $self->SUPER::recoverPassword("recoverPasswordFinish",$vars);
   return WebGUI::Template::process(WebGUI::Template::get(1,'Auth/WebGUI/Recovery'), $vars);
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
	   my $len = 6;
	   $password = "";
	   for(my $i = 0; $i < $len; $i++) {
          $password .= chr(ord('A') + randint(32));
   	   }
   	   $encryptedPassword = Digest::MD5::md5_base64($password);
	   $self->saveParams($userId,"WebGUI",{identifier=>$encryptedPassword});
	   $message = $session{setting}{webguiRecoverPasswordEmail};
	   $message .= "\n".WebGUI::International::get(50).": ".$username."\n";
	   $message .= WebGUI::International::get(51).": ".$password."\n";
	   WebGUI::Mail::send($session{form}{email},WebGUI::International::get(74),$message);
	   $flag++;
	}
	$sth->finish();
	 
   return $self->displayLogin('<ul><li>'.WebGUI::International::get(75).'</ul>') if($flag);
   return $self->recoverPassword('<ul><li>'.WebGUI::International::get(76).'</ul>');
}

#-------------------------------------------------------------------
sub resetExpiredPassword {
    my $self = shift;
	my $vars;
	
	$vars->{displayTitle} = '<h3>'.WebGUI::International::get(8,'Auth/WebGUI').'</h3>';
    $vars->{'expired.message'} = $_[0] if($_[0]);
    $vars->{'expired.form.header'} = "\n\n".WebGUI::Form::formHeader({});
    $vars->{'expired.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"auth"});
	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden({"name"=>"method","value"=>"resetExpiredPasswordSave"});
   	$vars->{'expired.form.hidden'} .= WebGUI::Form::hidden({"name"=>"uid","value"=>$session{form}{uid}});
    
    $vars->{'expired.form.oldPassword'} = WebGUI::Form::password({"name"=>"oldPassword"});
    $vars->{'expired.form.oldPassword.label'} = WebGUI::International::get(10,'Auth/WebGUI');
    $vars->{'expired.form.password'} = WebGUI::Form::password({"name"=>"identifier"});
    $vars->{'expired.form.password.label'} = WebGUI::International::get(11,'Auth/WebGUI');
    $vars->{'expired.form.passwordConfirm'} = WebGUI::Form::password({"name"=>"identifierConfirm"});
    $vars->{'expired.form.passwordConfirm.label'} = WebGUI::International::get(2,'Auth/WebGUI');
    $vars->{'expired.form.submit'} = WebGUI::Form::submit({});
    $vars->{'expired.form.footer'} = "</form>";
	
	return WebGUI::Template::process(WebGUI::Template::get(1,'Auth/WebGUI/Expired'), $vars);
}

#-------------------------------------------------------------------
sub resetExpiredPasswordSave {
   my $self = shift;
   my ($error,$u,$properties,$msg);
   
   $u = WebGUI::User->new($session{form}{uid});
   $session{form}{username} = $u->username;
   
   $error .= $self->error if(!$self->authenticate($session{form}{oldPassword}));
   $error .= '<li>'.WebGUI::International::get(5,'Auth/WebGUI') if($session{form}{identifier} eq "password");
   $error .= '<li>'.WebGUI::International::get(12,'Auth/WebGUI') if ($session{form}{oldPassword} eq $session{form}{identifier});
   $error .= $self->error if(!$self->_isValidPassword($session{form}{identifier},$session{form}{identifierConfirm}));
   
   return $self->resetExpiredPassword("<h1>".WebGUI::International::get(70)."</h1>".$error) if($error ne "");
   
   $properties->{identifier} = Digest::MD5::md5_base64($session{form}{identifier});
   $properties->{passwordLastUpdated} = time();
   
   $self->saveParams($u->userId,$self->authMethod,$properties);
   
   $msg = $self->login;
   if($msg eq ""){
      $msg = "<li>".WebGUI::International::get(17,'Auth/WebGUI');
   }
   return $self->displayLogin($msg);
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
   my $display = '<li>'.WebGUI::International::get(81).'<p>';
   
   if($self->userId == 1){
      return $self->displayLogin;
   }
   
   if(!$self->validUsernameAndPassword($username,$password,$passConfirm)){
      $display = $self->error; #overwrite display
   }
   
   my $properties;
   my $u = $self->user;
   $u->username($username);
   my $userData = $self->getParams;
   
   unless ($password eq "password") {
      $properties->{identifier} = Digest::MD5::md5_base64($password);
	   if($userData->{identifier} ne $properties->{identifier}){
	     $properties->{passwordLastUpdated} = time();
      }
   }
   
   $session{form}{uid} = $u->userId;
   $self->saveParams($u->userId,$self->authMethod,$properties);
   WebGUI::Session::refreshUserInfo($u->userId);
   
  return $self->displayAccount($display);
}

1;

