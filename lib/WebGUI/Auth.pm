package WebGUI::Auth;

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
use WebGUI::Friends;

# Profile field name for the number of times the showMessageOnLogin has been
# seen.
my $LOGIN_MESSAGE_SEEN  = 'showMessageOnLoginSeen';

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
	return 0 if($self->isRegistered && $self->session->user->username eq $username);
	my ($otherUser) = $self->session->db->quickArray("select count(*) from users where username=".$self->session->db->quote($username));
	return 0 if !$otherUser;
	my $i18n = WebGUI::International->new($self->session);
	$self->error('<li>'.sprintf($i18n->get(77), $username,$username,$username,$self->session->datetime->epochToHuman(time(),"%y")).'</li>');
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

	return 1 if($self->isRegistered && $self->session->user->username eq $username);

    my $i18n = WebGUI::International->new($self->session);

    my $filteredUsername = WebGUI::HTML::filter($username, 'all');
    if ($username ne $filteredUsername) {
        $error .= '<li>' . $i18n->get('username no html') . '</li>';
    }

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
    $self->timeRecordSession;
	$self->session->db->write("insert into userLoginLog values (?,?,?,?,?,?,?)",
		[ 
            $_[0],
            $_[1],
            time(),
            $self->session->env->getIp,
            $self->session->env->get("HTTP_USER_AGENT"),
            $self->session->getId,
            time(),
        ]
    );
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
		$self->authenticationError;
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

=head2 authenticationError

This subroutine is called by authenticate and its subclasses to make
sure these subroutines return the same errormessage on login failure.
Different errormessages would reveil if a username exists after
which only the password has to be guessed by brute force for example.

=cut

sub authenticationError {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	return ($self->error('<li>'.$i18n->get(68).'</li>'));
}

#-------------------------------------------------------------------

=head2 authMethod ( [authMethod] )

Gets or sets the authMethod in the Auth Object.  Returns 'WebGUI' as the
default method if a user has been created without an authMethod.

=head3 authMethod

   A string which sets the auth method for an instance of this class

=cut

sub authMethod {
	my $self = shift;
	if (!$_[0]) {
        return $self->{authMethod} || 'WebGUI';
    }
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
    my $self    = shift;
    my $method  = shift;
    my $vars    = shift;
    my $i18n    = WebGUI::International->new($self->session);
    $vars->{title} = $i18n->get(54);
    
    $vars->{'create.form.header'}
        = WebGUI::Form::formHeader($self->session)
        . WebGUI::Form::hidden($self->session,{"name"=>"op","value"=>"auth"})
        . WebGUI::Form::hidden($self->session,{"name"=>"method","value"=>$method})
        ;
    
    # User Defined Options
    my $userInvitation = $self->session->setting->get('inboxInviteUserEnabled');
    $vars->{'create.form.profile'} = [];
    foreach my $field (@{WebGUI::ProfileField->getRegistrationFields($self->session)}) {
        my $id         = $field->getId;
        my $label      = $field->getLabel;
        my $required   = $field->isRequired;
        
        my $properties = {};
        if ($required) {
            my $fieldValue = $self->session->form->process($field->getId,$field->get("fieldType"));
            $properties->{extras} = $self->getExtrasStyle($fieldValue);
        }

        my $formField;
        # Get the default email from the invitation
        if ($field->get('fieldName') eq "email" && $userInvitation ) {
            my $code = $self->session->form->get('code')
                    || $self->session->form->get('uniqueUserInvitationCode');
            my $defaultValue 
                = $self->session->db->quickScalar(
                    'SELECT email FROM userInvitations WHERE inviteId=?',
                    [$code]
                );
            $vars->{'create.form.header'} .= WebGUI::Form::hidden($self->session, {name=>"uniqueUserInvitationCode", value=>$code});
            $formField   = $field->formField($properties, undef, undef, undef, $defaultValue);
        }
        else {
            $formField   = $field->formField($properties, undef, undef, undef, undef, undef, 'useFormDefault');
        }
       

        # Old-style field loop.
        push @{$vars->{'create.form.profile'}}, { 
            'profile.formElement'       => $formField,
            'profile.formElement.label' => $label,
            'profile.required'          => $required,
        };

        # Individual field template vars.
        my $prefix = 'create.form.profile.'.$id.'.';
        $vars->{ $prefix . 'formElement'        } = $formField;
        $vars->{ $prefix . 'formElement.label'  } = $label;
        $vars->{ $prefix . 'required'           } = $required;
    }

    $vars->{'create.form.submit'} = WebGUI::Form::submit($self->session,{});
    $vars->{'create.form.footer'} = WebGUI::Form::formFooter($self->session,);

    $vars->{'login.url'} = $self->session->url->page('op=auth;method=init');
    $vars->{'login.label'} = $i18n->get(58);

    return WebGUI::Asset::Template->new($self->session,$self->getCreateAccountTemplateId)->process($vars);
}

#-------------------------------------------------------------------

=head2 createAccountSave ( username,properties [,password,profile] )

Superclass method that performs general functionality for saving new accounts.  Based
on various settings and user actions, it may return output that should be displayed
to the user.

=head3 username

Username for the account being created

=head3 properties

Properties from the subclass that should be saved as authentication parameters

=head3 password

Password entered by the user.  This is only used in for sending the user a notification by email of his/her username/password

=head3 profile

Hashref of profile values returned by the function WebGUI::User::validateProfileDataFromForm($fields);

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
	$u->updateProfileFields($profile) if ($profile);
    $self->saveParams($userId,$self->authMethod,$properties);

	if ($self->getSetting("sendWelcomeMessage")){
        my $var;
        $var->{welcomeMessage}      = $self->getSetting("welcomeMessage");
        $var->{newUser_username}    = $username;
        $var->{newUser_password}    = $password;
        my $message = WebGUI::Asset::Template->new($self->session,$self->getSetting('welcomeMessageTemplate'))->process($var);
        WebGUI::Macro::process($self->session,\$message);
        WebGUI::Inbox->new($self->session)->addMessage({
            message => $message,
			subject	=> $i18n->get(870),
			userId	=> $self->userId,
            status  => 'completed',
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
			})->start;
	}

    ##Finalize the record in the user invitation table.
    my $inviteId = $self->session->form->get('uniqueUserInvitationCode');
    if ($inviteId) {
        $self->session->db->setRow('userInvitations','inviteId',{
            inviteId    => $inviteId,
            newUserId   => $u->userId,
            dateCreated => WebGUI::DateTime->new($self->session, time)->toMysqlDate,
        });
        #Get the invite record
        my $inviteRecord = $self->session->db->getRow('userInvitations','inviteId',$inviteId);
        #Get the user
        my $inviteUser   = WebGUI::User->new($self->session,$inviteRecord->{userId});
        #Automatically add the friend that invited the user and vice versa if the friend has friends enabled
        if($inviteUser->acceptsFriendsRequests($u)) {
            my $friends  = WebGUI::Friends->new($self->session,$u);
            $friends->add([$inviteUser->userId]);
        }
    }

    # If we have something to do after login, do it
    if ( $self->session->setting->get( 'showMessageOnLogin' ) ) {
        return $self->showMessageOnLogin;
    }
    elsif ($self->session->form->get('returnUrl')) {
        $self->session->http->setRedirect( $self->session->form->get('returnUrl') );
        $self->session->scratch->delete("redirectAfterLogin");
    }
    elsif ($self->session->scratch->get("redirectAfterLogin")) {
        my $url = $self->session->scratch->delete("redirectAfterLogin");
        $self->session->http->setRedirect($url);
        return undef;
    } 
    else {
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
	return $self->session->privilege->vitalComponent() if($self->isVisitor || $self->isAdmin);
	return $self->session->privilege->adminOnly() if(!$self->session->setting->get("selfDeactivation"));
	my $i18n = WebGUI::International->new($self->session);
	my %var;
  	$var{title} = $i18n->get(42);
   	$var{question} =  $i18n->get(60);
   	$var{'yes.url'} = $self->session->url->page('op=auth;method='.$method);
	$var{'yes.label'} = $i18n->get(44);
   	$var{'no.url'} = $self->session->url->page();
	$var{'no.label'} = $i18n->get(45);
	return WebGUI::Asset::Template->new($self->session,$self->get('getDeactivateAccountTemplateId'))->process(\%var);
}

#-------------------------------------------------------------------

=head2 deactivateAccountConfirm ( )

Superclass method that performs general functionality for deactivating accounts.

=cut

sub deactivateAccountConfirm {
    my $self = shift;
    
    # Cannot deactivate "Visitor" or "Admin" users this way
    return $self->session->privilege->vitalComponent 
        if $self->isVisitor || $self->isAdmin;

    my $i18n    = WebGUI::International->new($self->session);

    # Change user's status
    my $user    = $self->user;
    $user->status("Selfdestructed");
    
    # TODO: Fix displayLogin in all subclasses to have the same prototype. THIS WILL BREAK API!
    # Show the login form 
    #$self->logout;
    #return $self->displayLogin(undef, {
        #'login.message' => sprintf( $i18n->get("deactivateAccount success"), $user->username )
    #});

    $self->logout;
    return undef;
}

#-------------------------------------------------------------------

=head2 deleteParams (  )

Removes the user's authentication parameters from the database for all 
authentication methods. This is primarily useful when deleting the user's 
account.

=cut

sub deleteParams {
	my $self = shift;
	$self->session->db->write("delete from authentication where userId=".$self->session->db->quote($self->userId));
}

#-------------------------------------------------------------------

=head2 deleteSingleParam ( )

Removes a single authentication parameter from the database.

=cut

sub deleteSingleParam {
       my $self = shift;
       my ($userId, $authMethod, $fieldName) = @_;

       $self->session->db->write('delete from authentication where userId = ? and authMethod = ? and fieldName = ?', [$userId, $authMethod, $fieldName]);

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
	my $self   = shift;
	my $method = shift;
	my $vars   = shift;
    
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
    
    ########### ACCOUNT SHUNT
    #The following is a shunt which allows the displayAccount page to be displayed in the
    #Account system.  This shunt will be replaced in WebGUI 8 when the API can be broken
    my $output = WebGUI::Asset::Template->new($self->session,$self->getAccountTemplateId)->process($vars);
    #If the account system is calling this method, just return the template
    my $op = $self->session->form->get("op");
    if($op eq "account") {
        return $output;
    }
    #Otherwise wrap the template into the account layout
    my $instance = WebGUI::Content::Account->createInstance($self->session,"user");
    return $instance->displayContent($output,1);
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
    # or it's already been set to perform another operation
    unless (
        $self->session->form->process("op") eq "auth" 
            || ($self->session->scratch->get("redirectAfterLogin") =~ /op=\w+/) 
        ) {
        my $returnUrl
            = $self->session->form->get('returnUrl')
            || $self->session->url->page( $self->session->env->get('QUERY_STRING') )
            ;
        $self->session->scratch->set("redirectAfterLogin", $returnUrl);
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
    my $template = $self->getLoginTemplate;
    return $template->process($vars);
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

=head2 getCreateAccountTemplateId ( )

This method should be overridden by the subclass and should return the template ID for the create account screen.

=cut

sub getCreateAccountTemplateId {
	return "PBtmpl0000000000000011";
}

#-------------------------------------------------------------------

=head2 getDeactivateAccountTemplateId ( )

This method should be overridden by the subclass and should return the template ID for the deactivate account screen.

=cut

sub getDeactivateAccountTemplateId {
	return "PBtmpl0000000000000057";
}

#-------------------------------------------------------------------

=head2 getDefaultLoginTemplateId ( )

This method should be overridden by the subclass and should return the default template ID for the login screen.

=cut

sub getDefaultLoginTemplateId {
	return "PBtmpl0000000000000013";
}

#-------------------------------------------------------------------

=head2 getExtrasStyle ( )

This method returns the proper field to display for required fields.

=cut

sub getExtrasStyle {
    my $self  = shift;
    my $value = shift;
    
    my $requiredStyleOff = q{class="authfield_required_off"}; 
    my $requiredStyle    = q{class="authfield_required"};
    my $errorStyle       = q{class="authfield_error"};     #Required Field Not Filled In and Error Returend

    return $errorStyle if($self->error && $value eq "");
    return $requiredStyle unless($value);
    return $requiredStyleOff;
}

#-------------------------------------------------------------------

=head2 getLoginTemplate ( )

Returns a WebGUI::Asset::Template object for the login template.  If the configured
template cannot be used, then it returns a default template object.

=cut

sub getLoginTemplate {
    my $self    = shift;
    my $session = $self->session;
    my $templateId = $self->getLoginTemplateId;
    my $template   = WebGUI::Asset::Template->newByDynamicClass($session, $templateId);
    if (!$template) {
        $templateId = $self->getDefaultLoginTemplateId;
        $template   = WebGUI::Asset::Template->newByDynamicClass($session, $templateId);
    }
	return $template;
}

#-------------------------------------------------------------------

=head2 getLoginTemplateId ( )

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
	my $self       = shift;
	my $userId     = $_[0] || $self->userId;
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

=head2 isAdmin ()

Returns 1 if the user is user 3 (admin).

=cut

sub isAdmin {
	my $self = shift;
	return $self->userId eq '3';
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

=head2 isRegistered ()

Returns 1 if the user is not a visitor.

=cut

sub isRegistered {
	my $self = shift;
	return $self->userId ne '1';
}

#-------------------------------------------------------------------

=head2 isVisitor ()

Returns 1 if the user is a visitor.

=cut

sub isVisitor {
	my $self = shift;
	return $self->userId eq '1';
}

#-------------------------------------------------------------------

=head2 login ( )

Superclass method that performs standard login routines.  This is what should happen after a user has been authenticated.
Authentication should always happen in the subclass routine.

Open version tag is reclaimed if user is in site wide or singlePerUser mode.

=cut

sub login {
	my $self = shift;

	#Create a new user
	my $uid = $self->userId;
	my $u = WebGUI::User->new($self->session,$uid);
   	$self->session->user({user=>$u});
	$u->karma($self->session->setting->get("karmaPerLogin"),"Login","Just for logging in.") if ($self->session->setting->get("useKarma"));
	$self->_logLogin($uid,"success");

	if ($self->session->setting->get('encryptLogin')) {
		my $currentUrl = $self->session->url->page(undef,1);
		$currentUrl =~ s/^https:/http:/;
		$self->session->http->setRedirect($currentUrl);
	}

        # Run on login
	my $command = $self->session->config->get("runOnLogin");
	if ($command ne "") {
		WebGUI::Macro::process($self->session,\$command);
		my $error = qx($command);
		$self->session->errorHandler->warn($error) if $error;
	}
	

    # Set the proper redirect
    if ( $self->session->setting->get( 'showMessageOnLogin' ) 
        && $self->user->profileField( $LOGIN_MESSAGE_SEEN ) 
            < $self->session->setting->get( 'showMessageOnLoginTimes' ) 
    ) {
        return $self->showMessageOnLogin;
    }
    elsif ( $self->session->setting->get("redirectAfterLoginUrl") ) {
        $self->session->http->setRedirect($self->session->setting->get("redirectAfterLoginUrl"));
	  	$self->session->scratch->delete("redirectAfterLogin");
    }
    elsif ( $self->session->form->get('returnUrl') ) {
		$self->session->http->setRedirect( $self->session->form->get('returnUrl') );
	  	$self->session->scratch->delete("redirectAfterLogin");
    }
	elsif ( my $url = $self->session->scratch->delete("redirectAfterLogin") ) {
		$self->session->http->setRedirect($url);
	}

    # Get open version tag. This is needed if we want
    # to reclaim a version right after login (singlePerUser and siteWide mode)
    # and to have the correct version displayed.
    WebGUI::VersionTag->getWorking($self->session(), q{noCreate});

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
       my $error = qx($command);
       $self->session->errorHandler->warn($error) if $error;
    }

    # Do not allow caching of the logout page (to ensure the page gets requested)
    $self->session->http->setCacheControl( "none" );
   
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
	my @callable = ('init', 'showMessageOnLogin', @{$call});
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
	return $self->{profile} if (!$_[0]);
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
    $self->{callable} = \@callable;
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

#----------------------------------------------------------------------------

=head2 showMessageOnLogin ( )

Show the requested message after the user logs in. Add another tally to the 
number of times the message has been displayed. Show a link to the next
stage for the user.

=cut

sub showMessageOnLogin {
    my $self        = shift;
    my $i18n        = WebGUI::International->new( $self->session, 'Auth' );

    # Increment the number of time seen.
    $self->user->profileField( $LOGIN_MESSAGE_SEEN, 
        $self->user->profileField( $LOGIN_MESSAGE_SEEN ) + 1
    );

    # Show the message, processing for macros
    my $output  =  $self->session->setting->get( 'showMessageOnLoginBody' );
    WebGUI::Macro::process( $self->session, \$output );

    # Add the link to continue
    my $redirectUrl =  $self->session->form->get( 'returnUrl' )
                    || $self->session->setting->get("redirectAfterLoginUrl")
                    || $self->session->scratch->get( 'redirectAfterLogin' )
                    || $self->session->url->getSiteURL . $self->session->url->gateway()
                    ;

    $output     .= '<p><a href="' . $redirectUrl . '">' . $i18n->get( 'showMessageOnLogin return' ) 
                .  '</a></p>'
                ;

    # No matter what, we won't be redirecting after this
    $self->session->scratch->delete( 'redirectAfterLogin' );

    return $output;
}

#----------------------------------------------------------------------------

=head2 timeRecordSession 

Record the last page viewed and the time viewed for the user

=cut

sub timeRecordSession {
    my $self = shift;
    my ($nonTimeRecordedRows) = $self->session->db->quickArray("select count(*) from userLoginLog where lastPageViewed = timeStamp and sessionId = ? ", [$self->session->getId] );
    if ($nonTimeRecordedRows eq "1") {
        # We would normally expect to only find one entry
        $self->session->db->write("update userLoginLog set lastPageViewed = (select lastPageView from userSession where sessionId = ?) where lastPageViewed = timeStamp and sessionId = ? ",
            [ $self->session->getId,
            $self->session->getId]);
    } elsif ($nonTimeRecordedRows eq "0") {
        # Do nothing
    } else {
        # If something strange happened and we ended up with > 1 matching rows, cut our losses and remove offending userLoginLog rows (otherwise we
        # could end up with ridiculously long user recorded times)
        $self->session->errorHandler->warn("More than 1 old userLoginLog rows found, removing offending rows");
        $self->session->db->write("delete from userLoginLog where lastPageViewed = timeStamp and sessionId = ? ", [$self->session->getId] );
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
