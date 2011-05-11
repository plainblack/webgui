package WebGUI::Auth::WebGUI;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::FormBuilder;
use WebGUI::Macro;
use WebGUI::Mail::Send;
use WebGUI::Storage;
use WebGUI::User;
use WebGUI::Form::Captcha;
use WebGUI::Macro;
use WebGUI::Deprecate;
use Encode ();
use Tie::IxHash;

our @ISA = qw(WebGUI::Auth);

#-------------------------------------------------------------------

sub _hasNonWordCharacters {
	my $self = shift;
        my $password = shift;
	my $numberRequired = shift;
	return ($password =~ tr/A-Za-z0-9_//c) >= $numberRequired;
}

#-------------------------------------------------------------------

sub _hasNumberCharacters {
	my $self = shift;
        my $password = shift;
	my $numberRequired = shift;
	return ($password =~ tr/0-9//) >= $numberRequired;
}

#-------------------------------------------------------------------

sub _hasMixedCaseCharacters {
	my $self = shift;
        my $password = shift;
	my $numberRequired = shift;
	return $password =~ tr/a-z// && ($password =~ tr/A-Z//) >= $numberRequired;
}

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

   if ($self->getSetting("requiredDigits") && !$self->_hasNumberCharacters($password, $self->getSetting("requiredDigits"))) {
     $error .= '<li>'.sprintf($i18n->get('error password requiredDigits'), $self->getSetting("requiredDigits")).'</li>';
   }

   if ($self->getSetting("nonWordCharacters") && !$self->_hasNonWordCharacters($password, $self->getSetting("nonWordCharacters"))) {
     $error .= '<li>'.sprintf($i18n->get('error password nonWordCharacters'), $self->getSetting("nonWordCharacters")).'</li>';
   }

   if ($self->getSetting("requiredMixedCase") && !$self->_hasMixedCaseCharacters($password, $self->getSetting("requiredMixedCase"))) {
     $error .= '<li>'. sprintf($i18n->get('error password requiredMixedCase'), $self->getSetting("requiredMixedCase")).'</li>';
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
    $self->session->log->security("change password.  Password changed successfully");
}

#-------------------------------------------------------------------
sub authenticate {
    my $self = shift;
	my ($identifier, $userData, $auth);
	
	$auth = $self->SUPER::authenticate($_[0]);
	return 0 if !$auth;
	
	$identifier = $_[1];
	$userData = $self->get;
	if (($self->hashPassword($identifier) eq $$userData{identifier}) && ($identifier ne "")) {
		return 1;
	} 
	$self->user(WebGUI::User->new($self->session,1));
	$self->SUPER::authenticationError;
	return 0;
}

#-------------------------------------------------------------------

=head2 checkField ( )

Performs AJAX checks on form field input. For example, can check whether a user
name is free for registration.

Returns the JSON {"error":"errorString"} where errorString is an error message
or an empty string if the check was successful.

=cut

#-------------------------------------------------------------------

=head2 editUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub editUserForm {
   my $self = shift;
   my $userData = $self->get;
   my $f = WebGUI::FormBuilder->new($self->session);
	my $i18n = WebGUI::International->new($self->session);
   $f->addField( "password",
	name=>"authWebGUI.identifier",
	label=>$i18n->get(51),
	value=>"password",
    extras=>'autocomplete="off"',
	);
   $f->addField( "interval",
	name=>"authWebGUI.passwordTimeout",
	label=>$i18n->get(16,'AuthWebGUI'),
	value=>$userData->{passwordTimeout},
	defaultValue=>$self->session->setting->get("webguiPasswordTimeout")
	);
   my $userChange = $self->session->setting->get("webguiChangeUsername");
   if($userChange || $userChange eq "0"){
      $userChange = $userData->{changeUsername};
   }
   $f->addField( "yesNo",
                name=>"authWebGUI.changeUsername",
                value=>$userChange,
                label=>$i18n->get(21,'AuthWebGUI')
             );
   my $passwordChange = $self->session->setting->get("webguiChangePassword");
   if($passwordChange || $passwordChange eq "0"){
      $passwordChange = $userData->{changePassword};
   }
   $f->addField( "yesNo",
                name=>"authWebGUI.changePassword",
                value=>$passwordChange,
                label=>$i18n->get(20,'AuthWebGUI')
             );
   return $f;
}

#-------------------------------------------------------------------

=head2 editUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub editUserFormSave {
   my $self = shift;
   my $userId = $self->session->form->get("uid");
   my $properties;
   my $userData = $self->get;
   my $identifier = $self->session->form->process('authWebGUI.identifier');
   unless (!$identifier || $identifier eq "password") {
      $properties->{identifier} = $self->hashPassword($self->session->form->process('authWebGUI.identifier'));
	   if($userData->{identifier} ne $properties->{identifier}){
	     $properties->{passwordLastUpdated} =time();
      }
   }
   $properties->{passwordTimeout} = $self->session->form->interval('authWebGUI.passwordTimeout');
   $properties->{changeUsername} = $self->session->form->process('authWebGUI.changeUsername');
   $properties->{changePassword} = $self->session->form->process('authWebGUI.changePassword');
   	if($userId eq "new") {
   		$properties->{passwordLastUpdated} =time();
		if ($self->session->setting->get("webguiExpirePasswordOnCreation")){
      			$properties->{passwordLastUpdated} =time() - $properties->{passwordTimeout};   
		}
   	}
   
    $self->update( $properties );
}

#-------------------------------------------------------------------

=head2 editUserSettingsForm ( )

  Creates form elements for user settings page custom to this auth module

=cut

sub editUserSettingsForm {
    my $self = shift;
    my $i18n = WebGUI::International->new($self->session,'AuthWebGUI');
    my $f = WebGUI::FormBuilder->new($self->session);

    $f->addField( "integer",
        name      => "webguiPasswordLength",
        value     => $self->session->setting->get("webguiPasswordLength"),
        label     => $i18n->get(15),
        hoverHelp => $i18n->get('15 help'),
    );
    $f->addField( "integer",
        name      => "webguiRequiredDigits",
        label     => $i18n->get('setting webguiRequiredDigits'),
        value     => $self->session->setting->get("webguiRequiredDigits"),
        hoverHelp => $i18n->get('setting webguiRequiredDigits help'),
   	);
    $f->addField( "integer",
        name      => "webguiNonWordCharacters",
        label     => $i18n->get('setting webguiNonWordCharacters'),
        value     => $self->session->setting->get("webguiNonWordCharacters"),
        hoverHelp => $i18n->get('setting webguiNonWordCharacters help'),
   	);
    $f->addField( "integer",
        name      => "webguiRequiredMixedCase",
        label     => $i18n->get('setting webguiRequiredMixedCase'),
        value     => $self->session->setting->get("webguiRequiredMixedCase"),
        hoverHelp => $i18n->get('setting webguiRequiredMixedCase help'),
	);
    $f->addField( "interval",
        name      => "webguiPasswordTimeout",
        label     => $i18n->get(16),
        value     => $self->session->setting->get("webguiPasswordTimeout"),
        hoverHelp => $i18n->get('16 help'),
	);
    $f->addField( "yesNo",
        name      => "webguiExpirePasswordOnCreation",
        value     => $self->session->setting->get("webguiExpirePasswordOnCreation"),
        label     => $i18n->get(9),
        hoverHelp => $i18n->get('9 help')
    );
    $f->addField( "yesNo",
        name      => "webguiSendWelcomeMessage",
        value     => $self->session->setting->get("webguiSendWelcomeMessage"),
        label     => $i18n->get(868,'WebGUI'),
        hoverHelp => $i18n->get('868 help','WebGUI'),
    );
    $f->addField( "HTMLArea",
        name      => "webguiWelcomeMessage",
        value     => $self->session->setting->get("webguiWelcomeMessage"),
        label     => $i18n->get(869,'WebGUI'),
        hoverHelp => $i18n->get('869 help','WebGUI'),
    );
    $f->addField( "yesNo",
        name      => "webguiUseEmailAsUsername",
        value     => $self->session->setting->get("webguiUseEmailAsUsername"),
        label     => $i18n->get('use email as username label'),
        hoverHelp => $i18n->get('use email as username description'),
    );
    $f->addField( "yesNo",
        name      => "webguiChangeUsername",
        value     => $self->session->setting->get("webguiChangeUsername"),
        label     => $i18n->get(19),
        hoverHelp => $i18n->get('19 help'),
    );
    $f->addField( "yesNo",
        name      => "webguiChangePassword",
        value     => $self->session->setting->get("webguiChangePassword"),
        label     => $i18n->get(18),
        hoverHelp => $i18n->get('18 help'),
    );
    $f->addField( "selectList",
        name      => "webguiPasswordRecovery",
        value     => $self->session->setting->get("webguiPasswordRecovery"),
        label     => $i18n->get(6),
        hoverHelp => $i18n->get('webguiPasswordRecovery hoverHelp'),
        options   => $self->getPasswordRecoveryTypesAvailable,
        size      => 1,
        multiple  => 0,
    );
    $f->addField( "yesNo",
        name      => "webguiPasswordRecoveryRequireUsername",
        value     => $self->session->setting->get("webguiPasswordRecoveryRequireUsername"),
        label     => $i18n->get('require username for password recovery'),
        hoverHelp => $i18n->get('webguiPasswordRecoveryRequireUsername hoverHelp'),
    );
   	$f->addField( "yesNo",
        name      => "webguiValidateEmail",
        value     => $self->session->setting->get("webguiValidateEmail"),
        label     => $i18n->get('validate email'),
        hoverHelp => $i18n->get('validate email help'),
    );
   	$f->addField( "yesNo",
        name      => "webguiUseCaptcha",
        value     => $self->session->setting->get("webguiUseCaptcha"),
        label     => $i18n->get('use captcha'),
        hoverHelp => $i18n->get('use captcha help'),
    );
	$f->addField( "template",
		name      => "webguiAccountTemplate",
		value     => $self->session->setting->get("webguiAccountTemplate"),
		namespace => "Auth/WebGUI/Account",
		label     => $i18n->get("account template"),
		hoverHelp => $i18n->get("account template help"),
    );
	$f->addField( "template",
		name      => "webguiCreateAccountTemplate",
		value     => $self->session->setting->get("webguiCreateAccountTemplate"),
		namespace => "Auth/WebGUI/Create",
		label     => $i18n->get("create account template"),
		hoverHelp => $i18n->get("create account template help"),
    );
    $f->addField( "template",
        name      => "webguiDeactivateAccountTemplate",
        value     => $self->session->setting->get("webguiDeactivateAccountTemplate"),
        namespace => "Auth/WebGUI/Deactivate",
        label     => $i18n->get("deactivate account template"),
        hoverHelp => $i18n->get("deactivate account template help"),
    );
	$f->addField( "template",
		name      => "webguiExpiredPasswordTemplate",
		value     => $self->session->setting->get("webguiExpiredPasswordTemplate"),
		namespace => "Auth/WebGUI/Expired",
		label     => $i18n->get("expired password template"),
		hoverHelp => $i18n->get("expired password template"),
    );
	$f->addField( "template",
		name      => "webguiLoginTemplate",
		value     => $self->session->setting->get("webguiLoginTemplate"),
		namespace => "Auth/WebGUI/Login",
		label     => $i18n->get("login template"),
		hoverHelp => $i18n->get("login template help"),
		);
	$f->addField( "template",
		name      => "webguiPasswordRecoveryTemplate",
		value     => $self->session->setting->get("webguiPasswordRecoveryTemplate"),
		namespace => "Auth/WebGUI/Recovery2",
		label     => $i18n->get("password recovery template"),
		hoverHelp => $i18n->get("password recovery template help")
    );
    $f->addField( "template",
        name      => "webguiPasswordRecoveryEmailTemplate",
        value     => $self->session->setting->get('webguiPasswordRecoveryEmailTemplate'),
        label     => $i18n->get('Password Recovery Email Template'),
	hoverHelp => $i18n->get("password recovery email template help"),
		namespace => "Auth/WebGUI/RecoveryEmail",
    );
    $f->addField( "template",
        name      => "webguiWelcomeMessageTemplate",
        value     => $self->session->setting->get("webguiWelcomeMessageTemplate"),
        namespace => "Auth/WebGUI/Welcome",
        label     => $i18n->get("welcome message template"),
        hoverHelp => $i18n->get("welcome message template help")
    );
    $f->addField( "template",
        name      => "webguiAccountActivationTemplate",
        value     => $self->session->setting->get("webguiAccountActivationTemplate"),
        namespace => "Auth/WebGUI/Activation",
        label     => $i18n->get("account activation template"),
        hoverHelp => $i18n->get("account activation template help")
    );
    return $f;
}

#-------------------------------------------------------------------
sub editUserSettingsFormSave {
	my $self    = shift;
	my $f       = $self->session->form;
	my $s       = $self->session->setting;
    my $i18n    = WebGUI::International->new($self->session, 'AuthWebGUI');
    my @errors; # Array of errors to return, if any. See WebGUI::Operation::Settings->www_saveSettings
	$s->set("webguiPasswordLength", $f->process("webguiPasswordLength","integer"));
	$s->set("webguiRequiredDigits", $f->process("webguiRequiredDigits","integer"));
	$s->set("webguiNonWordCharacters", $f->process("webguiNonWordCharacters","integer"));
	$s->set("webguiRequiredMixedCase", $f->process("webguiRequiredMixedCase","integer"));
	$s->set("webguiPasswordTimeout", $f->process("webguiPasswordTimeout","interval"));
	$s->set("webguiExpirePasswordOnCreation", $f->process("webguiExpirePasswordOnCreation","yesNo"));
	$s->set("webguiSendWelcomeMessage", $f->process("webguiSendWelcomeMessage","yesNo"));
	$s->set("webguiWelcomeMessage", $f->process("webguiWelcomeMessage","textarea"));
	$s->set("webguiChangeUsername", $f->process("webguiChangeUsername","yesNo"));
	$s->set("webguiChangePassword", $f->process("webguiChangePassword","yesNo"));
    $s->set("webguiUseEmailAsUsername", $f->process("webguiUseEmailAsUsername"));

    # Make sure we have the ability to recover a password if we're trying to
    # enable password recovery
    my $passwordRecoveryType    = $f->process("webguiPasswordRecovery", "selectList");
    if ($passwordRecoveryType eq "profile") {
        # Profile recovery requires at least one field set to required
        my ($passwordRecoveryFields) 
            = $self->session->db->quickArray(
                "SELECT COUNT(*) FROM userProfileField WHERE requiredForPasswordRecovery = 1"
            );

        if ($passwordRecoveryFields <= 0) {
            push @errors, $i18n->get("error passwordRecoveryType no profile fields required");
        }
        else {
            $s->set("webguiPasswordRecovery", $passwordRecoveryType);
        }
    }
    # Recovery types that need no error checking
    else {
        $s->set("webguiPasswordRecovery", $passwordRecoveryType);
    }

	$s->set("webguiPasswordRecoveryRequireUsername", $f->process("webguiPasswordRecoveryRequireUsername","yesNo"));
	$s->set("webguiValidateEmail",                   $f->process("webguiValidateEmail","yesNo"));
	$s->set("webguiUseCaptcha",                      $f->process("webguiUseCaptcha","yesNo"));
	$s->set("webguiAccountTemplate",                 $f->process("webguiAccountTemplate","template"));
	$s->set("webguiCreateAccountTemplate",           $f->process("webguiCreateAccountTemplate","template"));
	$s->set("webguiDeactivateAccountTemplate",       $f->process("webguiDeactivateAccountTemplate","template"));
	$s->set("webguiExpiredPasswordTemplate",         $f->process("webguiExpiredPasswordTemplate","template"));
	$s->set("webguiLoginTemplate",                   $f->process("webguiLoginTemplate","template"));
	$s->set("webguiPasswordRecoveryTemplate",        $f->process("webguiPasswordRecoveryTemplate","template"));
    $s->set("webguiWelcomeMessageTemplate",          $f->process("webguiWelcomeMessageTemplate","template"));
    $s->set("webguiAccountActivationTemplate",       $f->process("webguiAccountActivationTemplate","template")); 
	$s->set("webguiPasswordRecoveryTemplate",        $f->process("webguiPasswordRecoveryTemplate","template"));
	$s->set("webguiPasswordRecoveryEmailTemplate",   $f->process("webguiPasswordRecoveryEmailTemplate","template"));

    if (@errors) {
        return \@errors;
    }
    else {
        return undef;
    }
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
sub getDeactivateAccountTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiDeactivateAccountTemplate") || $self->SUPER::getDeactivateAccountTemplateId;
}

#-------------------------------------------------------------------
sub getDefaultLoginTemplateId {
	return "PBtmpl0000000000000013";
}

#-------------------------------------------------------------------
sub getExpiredPasswordTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiExpiredPasswordTemplate") || "PBtmpl0000000000000012";
}

#-------------------------------------------------------------------
sub getLoginTemplateId {
	my $self = shift;
	return $self->session->setting->get("webguiLoginTemplate") || $self->getDefaultLoginTemplateId;
}

#-------------------------------------------------------------------
sub getPasswordRecoveryTemplateId {
    my $self = shift;
    return $self->session->setting->get("webguiPasswordRecoveryTemplate") || "PBtmpl0000000000000014";
}

#-------------------------------------------------------------------
sub getPasswordRecoveryType {
    my $self = shift;
    return $self->session->setting->get("webguiPasswordRecovery");
}

#----------------------------------------------------------------------------

=head2 getPasswordRecoveryTypesAvailable 

Returns a hash reference of password recovery types. Keys are the type, values
are an i18n label for the user.

=cut

sub getPasswordRecoveryTypesAvailable {
    my $self        = shift;
    my $i18n        = WebGUI::International->new($self->session, 'AuthWebGUI');

    tie my %types, 'Tie::IxHash', (
        ""          => $i18n->get("setting passwordRecoveryType none"),
        profile     => $i18n->get("setting passwordRecoveryType profile"),
        email       => $i18n->get("setting passwordRecoveryType email"),
    );

    return \%types;
}

#-------------------------------------------------------------------
sub getUserIdByPasswordRecoveryToken {
       my $self = shift;
       my $session = shift;
       my $token = shift;
       return $session->db->quickScalar("select userId from authentication where fieldName = 'emailRecoverPasswordVerificationNumber' and fieldData = ?", [$token]); 
}

#-------------------------------------------------------------------
sub hashPassword {
    my ($self, $password) = @_;
    return Digest::MD5::md5_base64(Encode::encode_utf8($password));
}

#-------------------------------------------------------------------
sub www_createAccount {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $session->form;
    my $setting     = $session->setting;

    my $message     = shift;
    my $confirm     = shift || $form->process("confirm");
    my $vars        = shift || {};
    my $i18n        = WebGUI::International->new($session);
    
    if ($self->session->user->isRegistered) {
        return $self->www_displayAccount;
    }
    elsif (!$setting->get("anonymousRegistration") && !$setting->get('inboxInviteUserEnabled')) {
        return $self->www_displayLogin;
    } 
    
    $vars->{'create.message'} = '<ul>'.$message.'</ul>' if ($message);
	$vars->{'useCaptcha'    } = $setting->get("webguiUseCaptcha");
    
	if ($vars->{useCaptcha}) {
		use WebGUI::Form::Captcha;
		my $captcha = WebGUI::Form::Captcha->new($session,{
            name   => "authWebGUI.captcha",
            extras => $self->getExtrasStyle
        });
   		$vars->{'create.form.captcha'} 
            = $captcha->toHtml . '<span class="formSubtext">' . $captcha->get('subtext').'</span>';
   		$vars->{'create.form.captcha.label'} = $i18n->get("captcha label","AuthWebGUI");
	}

    unless($setting->get('webguiUseEmailAsUsername')){   
        my $username = $form->process("authWebGUI.username");
        $vars->{'create.form.username'} 
            = WebGUI::Form::username($self->session, {
                name   => "authWebGUI.username",
                value  => $username,
                extras => $self->getExtrasStyle($username)
            });
        $vars->{'create.form.username.label'} = $i18n->get(50);
    }
    
    my $password = $form->process("authWebGUI.identifier");
    $vars->{'create.form.password'}
        = WebGUI::Form::password($self->session, {
            name    => "authWebGUI.identifier",
            value   => $password,
            extras  => $self->getExtrasStyle($password)
        });
    $vars->{'create.form.password.label'} = $i18n->get(51);

    my $passwordConfirm = $form->process("authWebGUI.identifierConfirm");
    $vars->{'create.form.passwordConfirm'} 
        = WebGUI::Form::password($self->session, {
            name   => "authWebGUI.identifierConfirm",
            value  =>  $passwordConfirm,
            extras => $self->getExtrasStyle($passwordConfirm)
        });
    $vars->{'create.form.passwordConfirm.label'} = $i18n->get(2,'AuthWebGUI');

    $vars->{'create.form.hidden'} 
        = WebGUI::Form::hidden($self->session, {
            "name"      => "confirm",
            "value"     => $confirm
        });
 	$vars->{'recoverPassword.isAllowed'     } = $self->getSetting("passwordRecovery");
    $vars->{'recoverPassword.url'           } = $self->session->url->page('op=auth;method=recoverPassword');
    $vars->{'recoverPassword.label'         } = $i18n->get(59);
    return $self->SUPER::www_createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
sub www_createAccountSave {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    my $setting     = $self->session->setting;
    my $i18n        = WebGUI::International->new($session);

    # Logged in users cannot see this page
    return $self->www_displayAccount if ($session->user->isRegistered);

    # Make sure anonymous registration is enabled 
    if (!$setting->get("anonymousRegistration") && !$setting->get("inboxInviteUserEnabled")) {    
        $session->log->security($i18n->get("no registration hack", "AuthWebGUI"));
        return $self->www_displayLogin;
    }
    my $username;
    if($setting->get('webguiUseEmailAsUsername')){
        $username    = $form->process('email');
    }
    else{
        $username    = $form->process('authWebGUI.username');
    }
    my $password    = $form->process('authWebGUI.identifier');
    my $passConfirm = $form->process('authWebGUI.identifierConfirm');
   
    # Validate input
    my $error;
    $error = $self->error unless($self->validUsername($username));
    if ($setting->get("webguiUseCaptcha")) {
        my $form = WebGUI::Form::Captcha->new($session, {name => 'authWebGUI.captcha'});
        if (! $form->getValue) {
            $error .= '<li>' . $form->getErrorMessage . '</li>';
        }
    }
    $error .= $self->error unless($self->_isValidPassword($password,$passConfirm));

    my $fields    = WebGUI::ProfileField->getRegistrationFields($session);
    my $retHash   = $self->user->validateProfileDataFromForm($fields);
    my $profile   = $retHash->{profile};
    my $temp      = "";
    my $warning   = "";

    my $format    = "<li>%s</li>";
    map { $warning .= sprintf($format,$_)  } @{$retHash->{warnings}};
    map { $temp    .= sprintf($format,$_)  } @{$retHash->{errors}};

    $error .= $temp;
     
    unless ($error eq "") {
        $self->error($error);
        return $self->www_createAccount($error);
    }

    # If Email address is not unique, a warning is displayed
    if ($warning ne "" && !$self->session->form->process("confirm")) {
        return $self->www_createAccount('<li>'.$i18n->get(1078).'</li>', 1);
    }

    # Create the new account
    my $properties;
    $properties->{ changeUsername       } = $setting->get("webguiChangeUsername");
    $properties->{ changePassword       } = $setting->get("webguiChangePassword");   
    $properties->{ identifier           } = $self->hashPassword($password);
    $properties->{ passwordLastUpdated  } = time();
    $properties->{ passwordTimeout      } = $setting->get("webguiPasswordTimeout");
    $properties->{ status } = 'Deactivated' if ($setting->get("webguiValidateEmail"));

    my $afterCreateMessage = $self->SUPER::createAccountSave($username,$properties,$password,$profile);

    # Send validation e-mail if required
    if ($setting->get("webguiValidateEmail")) {
        my $key = $session->id->generate;
        $self->update(emailValidationKey=>$key);
        my $mail = WebGUI::Mail::Send->create($self->session, {
            to      => $profile->{email},
            subject => $i18n->get('email address validation email subject','AuthWebGUI')
        });
        my $var;
        $var->{newUser_username} = $username;
        $var->{activationUrl} = $session->url->page("op=auth;method=validateEmail;key=".$key, 'full');
        my $text =
WebGUI::Asset::Template->newById($self->session,$self->getSetting('accountActivationTemplate'))->process($var);
        WebGUI::Macro::process($self->session,\$text);
        $mail->addText($text);
        $mail->addFooter;
        $mail->queue;
        $self->user->status("Deactivated");
        $session->end();
        $session->start(1, $session->getId);
        my $u = WebGUI::User->new($session, 1);
        $self->{user} = $u;
        $self->logout;
        return $self->www_displayLogin($i18n->get('check email for validation','AuthWebGUI'));
    }
    return $afterCreateMessage;
}

#-------------------------------------------------------------------
sub www_deactivateAccount {
   my $self = shift;
   return $self->www_displayLogin if($self->isVisitor);
   return $self->SUPER::www_deactivateAccount("deactivateAccountConfirm");
}

#-------------------------------------------------------------------
sub www_deactivateAccountConfirm {
    my $self = shift;
    return $self->www_displayLogin unless ($self->session->setting->get("selfDeactivation"));

    # Keep the username for a nice message
    my $username    = $self->user->username;

    # Deactivate the account
    my $response    = $self->SUPER::www_deactivateAccountConfirm;

    # If there was a response, it's probably an error 
    return $response if $response;

    # Otherwise show the login form with a friendly message
    my $i18n    = WebGUI::International->new($self->session);
    return $self->www_displayLogin(sprintf( $i18n->get("deactivateAccount success"), $username ));
}

#-------------------------------------------------------------------
sub www_displayAccount {
   my $self = shift;
   my $vars;
   return $self->www_displayLogin($_[0]) if ($self->isVisitor);
	my $i18n = WebGUI::International->new($self->session);
   my $userData = $self->get;
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
   return $self->SUPER::www_displayAccount("updateAccount",$vars);
}

#-------------------------------------------------------------------

=head2 www_displayLogin ( )

The initial login screen an unauthenticated user sees

=cut

sub www_displayLogin {
   	my $self = shift;
   	my $vars;
   	return $self->www_displayAccount($_[0]) if ($self->isRegistered);
    my $i18n = WebGUI::International->new($self->session);
   	$vars->{'login.message'}             = '<ul>'.$_[0].'</ul>' if ($_[0]);
   	$vars->{'recoverPassword.isAllowed'} = $self->getSetting("passwordRecovery");
   	$vars->{'recoverPassword.url'}       = $self->session->url->page('op=auth;method=recoverPassword');
   	$vars->{'recoverPassword.label'}     = $i18n->get(59);
   	return $self->SUPER::www_displayLogin("login",$vars);
}

#-------------------------------------------------------------------
sub www_login {
   my $self = shift;
   if(!$self->authenticate($self->session->form->process("username"),$self->session->form->process("identifier"))){
      $self->session->response->status(401);
      $self->session->log->security("login to account ".$self->session->form->process("username")." with invalid information.");
	my $i18n = WebGUI::International->new($self->session);
	  return $self->www_displayLogin("<h1>".$i18n->get(70)."</h1>".$self->error);
   }
   
   my $userData = $self->get;
   if($self->getSetting("passwordTimeout") && $userData->{passwordTimeout}){
      my $expireTime = $userData->{passwordLastUpdated} + $userData->{passwordTimeout};
      if (time() >= $expireTime){
		my $userId = $self->userId;
		 $self->logout;
   	     return $self->www_resetExpiredPassword($userId);
      }  
   }
      
   return $self->SUPER::www_login();
}

#-------------------------------------------------------------------

=head2 www_recoverPassword ( args )

Initiates the password recovery process.  Checks for recovery type, 
and then runs the appropriate method. Arguments to this sub are
passed directly to the approprate method.

=cut

sub www_recoverPassword {
    my $self = shift;

    return $self->www_displayLogin unless ($self->session->setting->get('webguiPasswordRecovery') ne '') and $self->isVisitor;

    my $type = $self->getPasswordRecoveryType;

    if ($type eq 'profile') {
        $self->www_profileRecoverPassword(@_);
    } 
    elsif ($type eq 'email') {
        $self->www_emailRecoverPassword(@_);
    }
}

deprecate 'recoverPassword' => 'www_recoverPassword';

#-------------------------------------------------------------------

=head2 www_emailRecoverPassword ( $error )

Templated email recovery form.

=head3 $error

$error is any error from the system which needs to be reported to the user.

=cut

sub www_emailRecoverPassword {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session);

    my $vars = {};
    $vars->{title}    = $i18n->get('recover password banner', 'AuthWebGUI');
    $vars->{subtitle} = $i18n->get('email recover password start message', 'AuthWebGUI');

	$vars->{'recoverFormHeader'} = "\n\n".WebGUI::Form::formHeader($session,{});
	$vars->{'recoverFormHidden'} = WebGUI::Form::hidden($session,{"name"=>"op","value"=>"auth"});
	$vars->{'recoverFormHidden'} .= WebGUI::Form::hidden($session,{"name"=>"method","value"=>"recoverPasswordFinish"});

	$vars->{'recoverFormSubmit'} = WebGUI::Form::submit($session,{});
	$vars->{'recoverFormFooter'} = WebGUI::Form::formFooter($session,);
	$vars->{'loginUrl'} = $session->url->page('op=auth;method=init');
	$vars->{'loginLabel'} = $i18n->get(58);

	$vars->{'anonymousRegistrationIsAllowed'} = ($session->setting->get("anonymousRegistration"));
	$vars->{'createAccountUrl'} = $session->url->page('op=auth;method=createAccount');
	$vars->{'createAccountLabel'} = $i18n->get(67);
	$vars->{'recoverMessage'} = $_[0] if ($_[0]);

    $vars->{'recoverFormProfile'} = [];
    
    ##just one element
    my $emailForm = WebGUI::Form::email($session, {name        => "email",});
    my $label     = $i18n->get('password recovery email label', 'AuthWebGUI');
    push @{$vars->{'recoverFormProfile'}},
        {
            'id'          => 'email',
            'formElement' => $emailForm,
            'label'       => $label,
        };

    $vars->{'recoverFormProfileFieldEmailFormElement'} = $emailForm;
    $vars->{'recoverFormProfileFieldEmailLabel'}       = $label;

    ##Username is handled by this form
    $vars->{'recoverFormUsername'}      = WebGUI::Form::text($session, {name => 'username'});
    $vars->{'recoverFormUsernameLabel'} = $i18n->get(50);

	return WebGUI::Asset::Template->newById($self->session,$self->getPasswordRecoveryTemplateId)->process($vars);
}

deprecate 'emailRecoverPassword' => 'www_emailRecoverPassword';

#-------------------------------------------------------------------
 
sub www_profileRecoverPassword {
    my $self = shift;

    my @fields = @{WebGUI::ProfileField->getPasswordRecoveryFields($self->session)};
    return $self->www_displayLogin unless @fields;

	my $vars = {};
	my $i18n = WebGUI::International->new($self->session);
	$vars->{title} = $i18n->get(71);
	$vars->{'recoverFormHeader'} = "\n\n".WebGUI::Form::formHeader($self->session,{});
	$vars->{'recoverFormHidden'} = WebGUI::Form::hidden($self->session,{"name"=>"op","value"=>"auth"});
	$vars->{'recoverFormHidden'} .= WebGUI::Form::hidden($self->session,{"name"=>"method","value"=>"recoverPasswordFinish"});

	$vars->{'recoverFormSubmit'} = WebGUI::Form::submit($self->session,{});
	$vars->{'recoverFormFooter'} = WebGUI::Form::formFooter($self->session,);
	$vars->{'loginUrl'} = $self->session->url->page('op=auth;method=init');
	$vars->{'loginLabel'} = $i18n->get(58);

	$vars->{'anonymousRegistrationIsAllowed'} = ($self->session->setting->get("anonymousRegistration"));
	$vars->{'createAccountUrl'} = $self->session->url->page('op=auth;method=createAccount');
	$vars->{'createAccountLabel'} = $i18n->get(67);
	$vars->{'recoverMessage'} = $_[0] if ($_[0]);

	# Semi-duplication with WebGUI::Auth::createAccount.  -.-
	$vars->{'recoverFormProfile'} = [];
	foreach my $field (@fields) {
		my ($id, $formField, $label) = ($field->getId, $field->formField, $field->getLabel);
		push @{$vars->{'recoverFormProfile'}},
		    +{ 'id' => $id, 'formElement' => $formField, 'label' => $label };

		my $prefix = 'recoverFormProfileField' . ucfirst($id);
		$vars->{$prefix.'FormElement'} = $formField;
		$vars->{$prefix.'Label'} = $label;
	}

	if ($self->getSetting('passwordRecoveryRequireUsername')) {
		$vars->{'recoverFormUsername'} = WebGUI::Form::text($self->session, {name => 'authWebGUI.username'});
		$vars->{'recoverFormUsernameLabel'} = $i18n->get(50);
	}

	return WebGUI::Asset::Template->newById($self->session,$self->getPasswordRecoveryTemplateId)->process($vars);
}

deprecate 'profileRecoverPassword' => 'www_profileRecoverPassword';

#-------------------------------------------------------------------

=head2 www_recoverPasswordFinish ( args ) 

Handles data for recovery of password.  Gets password recovery type, 
and then runs the appropriate method. Arguments are passed directly
to the appropriate method.

=cut

sub www_recoverPasswordFinish {
    my $self = shift;

    my $type = $self->getPasswordRecoveryType;

    if ($type eq 'profile') {
        $self->www_profileRecoverPasswordFinish(@_);
    } elsif ($type eq 'email') {
        $self->www_emailRecoverPasswordFinish(@_);
    }
}

deprecate 'recoverPasswordFinish' => 'www_recoverPasswordFinish';

#-------------------------------------------------------------------
 
sub www_profileRecoverPasswordFinish {
    my $self        = shift;
    my $session     = $self->session;
    my $i18n        = WebGUI::International->new($self->session);
    my $i18n2       = WebGUI::International->new($self->session, 'AuthWebGUI');
    return $self->www_displayLogin unless ($self->session->setting->get('webguiPasswordRecovery') ne '') and $self->isVisitor;
  
    my $username;
    if ($self->getSetting('passwordRecoveryRequireUsername')) {
		$username = $self->session->form->process('authWebGUI.username');
		return $self->www_recoverPassword($i18n->get('password recovery no username', 'AuthWebGUI')) unless defined $username;
	}

	my @fields = @{WebGUI::ProfileField->getPasswordRecoveryFields($self->session)};
	return $self->www_displayLogin unless @fields;

	my %fieldValues;
	my @failedRequiredFields;
	foreach my $field (@fields) {
		my $value = $field->formProcess;
		$fieldValues{$field->getId} = $value;
		push @failedRequiredFields, $field unless defined $value;
	}

	if (@failedRequiredFields) {
		my $errorMessage = '<ul>' . join("\n", map {
		        '<li>' . $_->getLabel . ' ' . $i18n->get(451) . '</li>'
		} @failedRequiredFields) . '</ul>';
		return $self->www_recoverPassword($errorMessage);
	}

	my @fieldNames = keys %fieldValues;
	my @fieldValues = values %fieldValues;
	my $wheres = join(' ', map{"AND $fieldNames[$_] = ?"} (0..$#fieldNames));
	$wheres .= ' AND u.username = ?' if defined $username;
	my $sql = "SELECT u.userId FROM users AS u JOIN userProfileData AS upd ON u.userId=upd.userId WHERE u.authMethod = ? $wheres";
	my @userIds = $self->session->db->buildArray($sql, [$self->authMethod, @fieldValues, (defined($username)? ($username) : ())]);

	if (@userIds == 0) {
		return $self->www_recoverPassword($i18n2->get('password recovery no results'));
	} 
    elsif (@userIds > 1) {
		return $self->www_recoverPassword($i18n2->get('password recovery multiple results'));
	}

	# Exactly one result.
	my $userId = $userIds[0];

        # Make sure the userId is not disabled
        my $user = WebGUI::User->new($self->session, $userId);
        if ( $user->status ne "Active" ) {
            return $self->www_recoverPassword( $i18n2->get( 'password recovery disabled' ) );
        }

	my ($password, $passwordConfirm) = ($self->session->form->process('authWebGUI.identifier'), $self->session->form->process('authWebGUI.identifierConfirm'));
	unless (defined $password and defined $passwordConfirm) {
		my $vars = {};
		$vars->{title} = $i18n->get(71);
		$vars->{'recoverFormHeader'} = "\n\n" . WebGUI::Form::formHeader($self->session, {});
		$vars->{'recoverFormHidden'}
		    = WebGUI::Form::hidden($session, {name => 'op', value => 'auth'})
		    . WebGUI::Form::hidden($session, {name => 'method', value => 'recoverPasswordFinish'})
		    . ( defined($username) 
            ? WebGUI::Form::hidden($session, {name => 'authWebGUI.username', value => $username}) 
            : '')
            ;

        # Add hidden fields for each required profile field
        for my $profileField (@fields) {
            my $formField   
                = $profileField->getFormControlClass->new($session, 
                    $profileField->formProperties({
                        name    => $profileField->getId,
                        value   => $fieldValues{ $profileField->getId },
                    })
                );
            
            $vars->{'recoverFormHidden'} .= $formField->toHtmlAsHidden;
        }

		$vars->{'recoverFormSubmit'} = WebGUI::Form::submit($self->session, {});
		$vars->{'recoverFormFooter'} = WebGUI::Form::formFooter($self->session);

		# Duplication with above in recoverPassword.
		$vars->{'loginUrl'} = $self->session->url->page('op=auth;method=init');
		$vars->{'loginLabel'} = $i18n->get(58);

		$vars->{'anonymousRegistrationIsAllowed'} = ($self->session->setting->get("anonymousRegistration"));
		$vars->{'createAccountUrl'} = $self->session->url->page('op=auth;method=createAccount');
		$vars->{'createAccountLabel'} = $i18n->get(67);
		# End duplication.

		$vars->{'recoverFormPassword'} = WebGUI::Form::password($self->session, {name => 'authWebGUI.identifier'});
		$vars->{'recoverFormPasswordConfirm'} = WebGUI::Form::password($self->session, {name => 'authWebGUI.identifierConfirm'});
		$vars->{'recoverFormPasswordLabel'} = $i18n->get(51);
		$vars->{'recoverFormPasswordConfirmLabel'} = $i18n2->get(2);
		
		# Mrgh.  z.z
		$vars->{'doingRecovery'} = 1;
		return WebGUI::Asset::Template->newById($self->session, $self->getPasswordRecoveryTemplateId)->process($vars);
	}

	if ($self->_isValidPassword($password, $passwordConfirm)) {
		$self->user( $user );
		$self->update(
				  identifier => $self->hashPassword($password),
				    passwordLastUpdated => time);
		$self->_logSecurityMessage;
		return $self->SUPER::www_login;
	} else {
		return $self->www_recoverPassword('<ul><li>'.$self->error.'</li></ul>');
	}
}

deprecate 'profileRecoverPasswordFinish' => 'www_profileRecoverPasswordFinish';

#-------------------------------------------------------------------

sub www_emailRecoverPasswordFinish {
    my $self = shift;
    return $self->www_displayLogin unless ($self->session->setting->get('webguiPasswordRecovery') ne '') and $self->isVisitor;

    my $i18n        = WebGUI::International->new($self->session);
    my $session     = $self->session;
    my ($form)      = $session->quick(qw/form/);
    my $email       = $form->param('email');
    my $username    = $form->param('username');
    my $user;

    # get user from email
    $user = WebGUI::User->newByEmail($session, $email) if $email;
    # get user from username
    if ($username) {
       $user = WebGUI::User->newByUsername($session, $username) unless $user; 
    }

    # return error unless we get a valid user.\
    unless ($user) {
       return $self->www_recoverPassword( $i18n->get('recover password not found', 'AuthWebGUI') );
    }

    # Make sure the user is Active
    if ( $user->status ne "Active" ) {
        return $self->www_recoverPassword( $i18n->get( 'password recovery disabled', 'AuthWebGUI' ) );
    }

    # generate information necessry to proceed
    my $recoveryGuid = $session->id->generate();
    my $userId = $user->userId; #get the user guid
    $email = $user->get('email');

    if ( ! $email ) {
        return $self->www_recoverPassword( $i18n->get( 'no email address', 'AuthWebGUI' ) );
    }

    my $authsettings = $self->get;
    $authsettings->{emailRecoverPasswordVerificationNumber} = $recoveryGuid;

    $self->update($authsettings);

    my $mail = WebGUI::Mail::Send->create($session, { to=>$email, subject=>$i18n->get('WebGUI password recovery')});
    my $vars = { };
    $vars->{recoverPasswordUrl} = $session->url->append($session->url->getSiteURL,'op=auth;method=emailResetPassword;token='.$recoveryGuid);
    my $template  = WebGUI::Asset->newById($session, $session->setting->get('webguiPasswordRecoveryEmailTemplate'));
    my $emailText = $template->process($vars);
    WebGUI::Macro::process($session, \$emailText);
    $mail->addText($emailText);
    $mail->queue;
    return "<h1>". $i18n->get('recover password banner', 'AuthWebGUI')." </h1> <br> <br> <h3>". $i18n->get('email recover password finish message', 'AuthWebGUI') . "</h3>";
}

deprecate emailRecoverPasswordFinish => 'www_emailRecoverPasswordFinish';

#-------------------------------------------------------------------
# handler for the link generated and mailed by emailRecoverPasswordFinish

sub www_emailResetPassword {
       my $self = shift;
       my $errormsg = shift;

       my $session = $self->session;
       my ($form) = $session->quick(qw/form/);
       my $passwordRecoveryToken = $form->param('token');

       my $i18n = WebGUI::International->new($self->session);
       my $userId = $self->getUserIdByPasswordRecoveryToken($session, $passwordRecoveryToken);

       my $u = $self->user(WebGUI::User->new($self->session, $userId));
       $self->session->user({user=>$u});

#      do not proceed unless we have an incoming guid from the email, and that guid corresponds to a valid user.
       if(!defined $userId){
            return $i18n->get("token already used", 'AuthWebGUI');
       }

#      login the user and take them to a page where they can change their password.

       my $output = "<h1>".$i18n->get('recover password banner', 'AuthWebGUI') ."</h1> <br><br><h3>". $i18n->get('email password recovery end message', 'AuthWebGUI')."</h3>";

       $output .= $errormsg if $errormsg;

       my $f = WebGUI::HTMLForm->new($self->session);

       $f->hidden(
               name => 'op',
               value => 'auth',
               );

       $f->hidden(
               name => "method",
               value => "emailResetPasswordFinish",
               );

       $f->hidden(
               name => "token",
               value => "$passwordRecoveryToken",
               );

    $f->password(
        name        => "newpassword",
        label       => $i18n->get('new password label', 'AuthWebGUI'),
        hoverHelp   => $i18n->get('new password help', 'AuthWebGUI'),
        uiLevel     => 0,
    );

    $f->password(
        name        => "newpwdverify",
        label       => $i18n->get('new password verify', 'AuthWebGUI'),
        hoverHelp   => $i18n->get('new password verify help', 'AuthWebGUI'),
        uiLevel     => 0,
    );

    $f->submit(
        value       => $i18n->get('submit'),
        uiLevel     => 0,
    );



       $output .= $f->print;
       return  $output;

}

deprecate 'emailResetPassword' => 'www_emailResetPassword';

#-------------------------------------------------------------------

sub www_emailResetPasswordFinish {
       my $self = shift;
       my $session = $self->session;
       my ($form) = $session->quick(qw/form/);
       my $password = $form->param('newpassword');
       my $passwordConfirm = $form->param('newpwdverify');
       my $passwordRecoveryToken = $form->param('token');

       my $userId = $self->getUserIdByPasswordRecoveryToken($session, $passwordRecoveryToken);
       
       if(!defined $userId){
	        my $i18n = WebGUI::International->new($self->session,"AuthWebGUI");
            return $i18n->get("token already used");
       }

       if ($self->_isValidPassword($password, $passwordConfirm)) {
               $self->user(WebGUI::User->new($self->session, $userId));
               $self->update(
                                 identifier => $self->hashPassword($password),
                                   passwordLastUpdated => time);
               $self->_logSecurityMessage;

#              delete the emailRecoverPasswordVerificationNumber
               $self->delete('emailRecoverPasswordVerificationNumber');
               return $self->SUPER::www_login;
       } else {
               return $self->www_emailResetPassword($self->error);
       }

}

deprecate emailResetPasswordFinish => 'www_emailResetPasswordFinish';

#-------------------------------------------------------------------
sub www_resetExpiredPassword {
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
	
	return WebGUI::Asset::Template->newById($self->session,$self->getExpiredPasswordTemplateId)->process($vars);
}

deprecate resetExpiredPassword => 'www_resetExpiredPassword';

#-------------------------------------------------------------------
sub www_resetExpiredPasswordSave {
   my $self = shift;
   my ($error,$u,$properties,$msg);
   
   $u = WebGUI::User->new($self->session,$self->session->form->process("uid"));
	my $i18n = WebGUI::International->new($self->session);
   
   $error .= $self->error if(!$self->authenticate($u->username,$self->session->form->process("oldPassword")));
   $error .= '<li>'.$i18n->get(5,'AuthWebGUI').'</li>' if($self->session->form->process("identifier") eq "password");
   $error .= '<li>'.$i18n->get(12,'AuthWebGUI').'</li>' if ($self->session->form->process("oldPassword") eq $self->session->form->process("identifier"));
   $error .= $self->error if(!$self->_isValidPassword($self->session->form->process("identifier"),$self->session->form->process("identifierConfirm")));
   
   return $self->www_resetExpiredPassword($u->userId, "<h1>".$i18n->get(70)."</h1><ul>".$error.'</ul>') if ($error);
   
   $properties->{identifier} = $self->hashPassword($self->session->form->process("identifier"));
   $properties->{passwordLastUpdated} =time();
   
   $self->update($properties);
   $self->_logSecurityMessage();
   return $self->SUPER::www_login();
}

deprecate resetExpiredPasswordSave => 'www_resetExpiredPasswordSave';

#-------------------------------------------------------------------
sub www_validateEmail {
	my $self = shift;
    my $session = $self->session;
	my ($userId) = $session->db->quickArray("select userId from authentication where fieldData=? and fieldName='emailValidationKey' and authMethod='WebGUI'", [$session->form->process("key")]);
    my $i18n = WebGUI::International->new($session, 'AuthWebGUI');
    my $message = '';
	if (defined $userId) {
		my $u = WebGUI::User->new($session,$userId);
		$u->status("Active");
		$self->session->db->write("DELETE FROM authentication WHERE userId = ? AND fieldName = 'emailValidationKey'", [$userId]);
        $message = $i18n->get('email validation confirmed','AuthWebGUI');
	}
	return $self->www_displayLogin($message);
}

deprecate validateEmail => 'www_validateEmail';

#-------------------------------------------------------------------

=head2 www_updateAccount (  )

  Sets properties to update and passes them to the superclass

=cut

sub www_updateAccount {
   my $self = shift;
   
	my $i18n = WebGUI::International->new($self->session);
   my $username = $self->session->form->process('authWebGUI.username');
   my $password = $self->session->form->process('authWebGUI.identifier');
   my $passConfirm = $self->session->form->process('authWebGUI.identifierConfirm');
   my $display = '<ul><li>'.$i18n->get(81).'</li></ul>';
   my $error = "";
   
   if($self->isVisitor){
      return $self->www_displayLogin;
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
      $display = '<ul>'.$error.'</ul>';
   }
   
   my $properties;
   my $u = $self->user;
   if(!$error){
      if($username){
	     $u->username($username);
	  }
	  if($password){
	     my $userData = $self->get;
         unless ($password eq "password") {
            $properties->{identifier} = $self->hashPassword($password);
			$self->_logSecurityMessage();
	        if($userData->{identifier} ne $properties->{identifier}){
	           $properties->{passwordLastUpdated} =time();
            }
         }
      }
   }
   $self->update($properties);
   $self->session->user(undef,undef,$u);
   
  return $self->www_displayAccount($display);
}

deprecate updateAccount => 'www_updateAccount';

1;

