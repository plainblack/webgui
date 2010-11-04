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

use strict qw(subs vars);
use Scalar::Util qw( blessed );
use WebGUI::International;
use WebGUI::Asset::Template;
use WebGUI::User;
use WebGUI::Workflow::Instance;
use WebGUI::Inbox;
use WebGUI::Friends;
use WebGUI::Deprecate;

# Profile field name for the number of times the showMessageOnLogin has been
# seen.
my $LOGIN_MESSAGE_SEEN  = 'showMessageOnLoginSeen';

=head1 NAME

Package WebGUI::Auth

=head1 SYNOPSIS

 package WebGUI::Auth::MyAuth;
 use base 'WebGUI::Auth';

 sub www_view { 
     # default entry point
 }

=head1 DESCRIPTION

WebGUI::Auth allows you to authenticate and login users.

To write your own auth module, you should override C<www_view> to start the 
user off with a login form or a create account form.

To access your new auth module, add it to the config file (authMethods) and go to 
C<?op=auth;authType=MyAuth>. See L<WebGUI::Operation::Auth>.

=head1 SEE ALSO

 WebGUI::Operation::Auth
 WebGUI::User

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
            $self->session->request->address,
            $self->session->request->user_agent,
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

=head2 delete ( [param] )

Delete one or all parameters for this auth method. Deleting all parameters
effectively removes this auth method from the user.

=cut

sub delete {
    my ( $self, $param ) = @_;
    my ( $db ) = $self->session->quick(qw( db ));

    if ( $param ) {
        $db->write( "DELETE FROM authentication WHERE userId=? AND authMethod=? AND fieldName=?",
            [ $self->userId, $self->authMethod, $param ]
        );
    }
    else {
        $db->write( "DELETE FROM authentication WHERE userId=? AND authMethod=?", 
            [ $self->userId, $self->authMethod ]
        );
    }
}

#-------------------------------------------------------------------

=head2 deleteParams (  )

NOTE: This method is deprecated and will be removed in a future version. Instead,
use delete() to delete this auth method from the user.

Removes the user's authentication parameters from the database for all 
authentication methods. This is primarily useful when deleting the user's 
account.

=cut

# DEPRECATED. Remove in 9.0
sub deleteParams {
	my $self = shift;
	$self->delete;
}

#-------------------------------------------------------------------

=head2 deleteSingleParam ( )

NOTE: This method is deprecated and will be removed in a future version. Instead,
use delete("param") to delete a single param from this auth method.

Removes a single authentication parameter from the database.

=cut

# DEPRECATED. Remove in 9.0
sub deleteSingleParam {
       my $self = shift;
       my ($userId, $authMethod, $fieldName) = @_;

       $self->delete( $fieldName );

}

#-------------------------------------------------------------------

=head2 editUserForm (  )

Creates user form elements specific to this Auth Method.

=cut

sub editUserForm {
	#Added for interface purposes only.  Needs to be implemented in the subclass.
}

#-------------------------------------------------------------------

=head2 editUserFormSave ( )

Saves user elements unique to this authentication method

=cut

sub editUserFormSave {
        # Added for interface purposes only. Needs to be implemented in the subclass
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

You need to override this method in your auth module. It needs to return a the rows in a form for the stuff you want to be configured through webgui settings.

=cut

sub editSettingsForm {
}

deprecate editUserSettingsForm => 'editSettingsForm';

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

You need to override this method in your auth module. It's the save for the editSettingsFormSave method.

=cut

sub editSettingsFormSave {
}

# Backwards compatiblity for method renaming
deprecate editSettingsFormSave => 'editSettingsFormSave';

#-------------------------------------------------------------------

=head2 error ( [errorMsg] )

Sets or returns the error currently stored in the object

=cut

sub error {
	my $self = shift;
	return $self->{error} if (!$_[0]);
        $self->session->log->error( $_[0] );
	$self->{error} = $_[0];
}

#----------------------------------------------------------------------------

=head2 get ( [param] )

Get one or all parameters for this auth instance. Returns either a hashref or a 
single scalar.

=cut

sub get {
    my ( $self, $param ) = @_;
    my ( $db ) = $self->session->quick(qw( db ));

    if ( $param ) {
        return $db->quickScalar(
            "SELECT fieldData FROM authentication WHERE userId=? AND authMethod=? AND fieldName=?",
            [ $self->userId, $self->authMethod, $param ],
        );
    }
    else {
        return $db->buildHashRef(
            "SELECT fieldName, fieldData FROM authentication WHERE userId=? AND authMethod=?",
            [ $self->userId, $self->authMethod ],
        );
    }
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
    my $template   = WebGUI::Asset::Template->newById($session, $templateId);
    if (!$template) {
        $templateId = $self->getDefaultLoginTemplateId;
        $template   = WebGUI::Asset::Template->newById($session, $templateId);
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

NOTE: This method is deprecated and will be removed in a future version. Use get() instead.

Returns a hash reference with the user's authentication information.  This method uses data stored in the instance of the object.

=cut

# DEPRECATED. Remove in 9.0
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

=head2 isAdmin ()

NOTE: This method is deprecated. Use user->isAdmin instead.

Returns 1 if the user is user 3 (admin).

=cut

# DEPRECATED. Remove in 9.0
sub isAdmin {
	my $self = shift;
	return $self->user->isAdmin;
}

#-------------------------------------------------------------------

=head2 isCallable ( method )

NOTE: Deprecated. Unnecessary when setCallable is removed.

Returns whether or not a method is callable

=cut

# DEPRECATED. Remove in 9.0
sub isCallable {
	my $self = shift;
	return 1 if $_[0] ~~ $self->{callable};
        return 1 if $self->can( 'www_' . $_[0] );
        return 0;
}

#-------------------------------------------------------------------

=head2 isRegistered ()

NOTE: Deprecated. Use user->isRegistered instead.

Returns 1 if the user is not a visitor.

=cut

# DEPRECATED. Remove in 9.0
sub isRegistered {
	my $self = shift;
	return $self->user->isRegistered;
}

#-------------------------------------------------------------------

=head2 isVisitor ()

NOTE: Deprecated. Use user->isVisitor instead.

Returns 1 if the user is a visitor.

=cut

# DEPRECATED. Remove in 9.0
sub isVisitor {
	my $self = shift;
	return $self->userId eq '1';
}

#-------------------------------------------------------------------

=head2 new ( session, [ user|userId ] )

Constructor.

=head3 session

=head3 user|userId

A WebGUI::User object, or userId for the user requesting authentication.
This defaults to $self->session->user->userId

=cut

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	$self->{_session} = shift;

        if ( blessed $_[0] && $_[0]->isa('WebGUI::User') ) {
            $self->{user} = shift;
        }
        elsif ( my $userId = shift ) {
            $self->{user} = WebGUI::User->new($self->{_session}, $userId);
        }
        else {
            $self->{user} = $self->session->user;
        }

	$self->{error} = "";
	$self->{profile} = ();

    # Determine the authmethod from the classname
    ($self->{authMethod}) = $class =~ m/^WebGUI::Auth::(.+)/;

    $self->setCallable([qw( init showMessageOnLogin )]);

	return $self;
}

#-------------------------------------------------------------------

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setCallable ( callableMethods )

NOTE: This method is deprecated and will be removed in a future version. Instead, 
any method prefixed with www_ is available from the web interface.

adds elements to the callable routines list.  This list determines whether or not a method in this instance is 
allowed to be called externally

=head3 callableMethods

Array reference containing a list of methods for this authentication instance that can be called externally

=cut

# DEPRECATED. Remove in 9.0
sub setCallable {
	my $self = shift;
	my @callable = @{$self->{callable}};
	@callable = (@callable,@{$_[0]});
    $self->{callable} = \@callable;
}

#-------------------------------------------------------------------

=head2 saveParams ( userId, authMethod, data )

NOTE: This method is deprecated and will be removed in a future version. Instead,
use update() to update the parameters of this auth instance.

Saves the user's authentication parameters to the database.

=head3 userId

Specify a user id.

=head3 authMethod

Specify the authentication method to save these paramaters under.

=head3 data

A hash reference containing parameter names and values to be saved.

=cut

# DEPRECATED. Remove in 9.0
sub saveParams {
	my $self = shift;
	my ($uid, $authMethod, $data) = @_;
    return $self->update( $data );
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
        $self->session->log->warn("More than 1 old userLoginLog rows found, removing offending rows");
        $self->session->db->write("delete from userLoginLog where lastPageViewed = timeStamp and sessionId = ? ", [$self->session->getId] );
    }
}

#----------------------------------------------------------------------------

=head2 update ( params )

Update the parameters for this auth instance. Params is a list of name => value pairs.

=cut

sub update {
    my $self    = shift;
    my ( $db ) = $self->session->quick(qw( db ));
    my %params;

    # Allow both hashref and hash
    if ( @_ == 1 ) {
        %params = %{ $_[0] };
    }
    else {
        %params = @_;
    }

    foreach my $param (keys %params) {
        $db->write(
            "delete from authentication where userId=? and authMethod=? and fieldName=?",
            [ $self->userId, $self->authMethod, $param ],
        );
        $db->write(
            "insert into authentication (userId,authMethod,fieldName,fieldData) values (?,?,?,?)",
            [ $self->userId, $self->authMethod, $param, $params{ $param } ],
        );
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

=head2 www_createAccount ( method [,vars] )

Superclass method that performs general functionality for creating new accounts.

=head3 method

Auth method that the form for creating users should call

=head3 vars

Array ref of template vars from subclass

=cut

sub www_createAccount {
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
            $formField   = $field->formField($properties);
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

    return WebGUI::Asset::Template->newById($self->session,$self->getCreateAccountTemplateId)->process($vars);
}

deprecate createAccount => 'www_createAccount';

#-------------------------------------------------------------------

=head2 www_createAccountSave ( username,properties [,password,profile] )

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

sub www_createAccountSave {
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
    $self->update($properties);

	if ($self->getSetting("sendWelcomeMessage")){
        my $var;
        $var->{welcomeMessage}      = $self->getSetting("welcomeMessage");
        $var->{newUser_username}    = $username;
        $var->{newUser_password}    = $password;
        my $message = WebGUI::Asset::Template->newById($self->session,$self->getSetting('welcomeMessageTemplate'))->process($var);
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
        $self->session->http->setStatus(201);
    }

	return undef;
}

deprecate createAccountSave => 'www_createAccountSave';

#-------------------------------------------------------------------

=head2 www_deactivateAccount ( method )

Superclass method that displays a confirm message for deactivating a user's account.

=head3 method

Auth method that the form for creating users should call

=cut

sub www_deactivateAccount {
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
	return WebGUI::Asset::Template->new($self->session,$self->getDeactivateAccountTemplateId)->process(\%var);
}

deprecate deactivateAccount => 'www_deactivateAccount';

#-------------------------------------------------------------------

=head2 www_deactivateAccountConfirm ( )

Superclass method that performs general functionality for deactivating accounts.

=cut

sub www_deactivateAccountConfirm {
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

deprecate deactivateAccountConfirm => 'www_deactivateAccountConfirm';

#-------------------------------------------------------------------

=head2 www_displayAccount ( method [,vars] )

Superclass method that performs general functionality for viewing editable fields related to a user's account.

=head3 method

Auth method that the form for updating a user's account should call

=head3 vars

Array ref of template vars from subclass

=cut

sub www_displayAccount {
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
    my $output = WebGUI::Asset::Template->newById($self->session,$self->getAccountTemplateId)->process($vars);
    #If the account system is calling this method, just return the template
    my $op = $self->session->form->get("op");
    if($op eq "account") {
        return $output;
    }
    #Otherwise wrap the template into the account layout
    my $instance = WebGUI::Content::Account->createInstance($self->session,"user");
    return $instance->displayContent($output,1);
}

deprecate displayAccount => 'www_displayAccount';

#-------------------------------------------------------------------

=head2 www_displayLogin ( [method,vars] )

Superclass method that performs general functionality for creating new accounts.

=head3 method

Auth method that the form for performing the login routine should call

=head3 vars

Array ref of template vars from subclass

=cut

sub www_displayLogin {
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
            || $self->session->url->page( $self->session->request->env->{'QUERY_STRING'} )
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

deprecate displayLogin => 'www_displayLogin';

#-------------------------------------------------------------------

=head2 www_login ( )

Superclass method that performs standard login routines.  This is what should happen after a user has been authenticated.
Authentication should always happen in the subclass routine.

Open version tag is reclaimed if user is in site wide or singlePerUser mode.

=cut

sub www_login {
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
		$self->session->log->warn($error) if $error;
	}
	

    # Set the proper redirect
    if ( $self->session->setting->get( 'showMessageOnLogin' ) 
        && $self->user->profileField( $LOGIN_MESSAGE_SEEN ) 
            < $self->session->setting->get( 'showMessageOnLoginTimes' ) 
    ) {
        return $self->showMessageOnLogin;
    }
    elsif ( $self->session->form->get('returnUrl') ) {
		$self->session->http->setRedirect( $self->session->form->get('returnUrl') );
	  	$self->session->scratch->delete("redirectAfterLogin");
    }
	elsif ( my $url = $self->session->scratch->delete("redirectAfterLogin") ) {
		$self->session->http->setRedirect($url);
	}
    elsif ( $self->session->setting->get("redirectAfterLoginUrl") ) {
        $self->session->http->setRedirect($self->session->setting->get("redirectAfterLoginUrl"));
        $self->session->scratch->delete("redirectAfterLogin");
    }

    # Get open version tag. This is needed if we want
    # to reclaim a version right after login (singlePerUser and siteWide mode)
    # and to have the correct version displayed.
    WebGUI::VersionTag->getWorking($self->session(), q{noCreate});

	return undef;
}

deprecate login => 'www_login';

#-------------------------------------------------------------------

=head2 www_logout ( )

Superclass method that performs standard logout routines.

=cut

sub www_logout {
	my $self = shift;
	$self->session->var->end($self->session->var->get("sessionId"));
	$self->session->user({userId=>'1'});
	my $u = WebGUI::User->new($self->session,1);
	$self->{user} = $u;
	
	my $command = $self->session->config->get("runOnLogout");
    if ($command ne "") {
       WebGUI::Macro::process($self->session,\$command);
       my $error = qx($command);
       $self->session->log->warn($error) if $error;
    }

    # Do not allow caching of the logout page (to ensure the page gets requested)
    $self->session->http->setCacheControl( "none" );
   
	return undef;
}

deprecate logout => 'www_logout';

#----------------------------------------------------------------------------

=head2 www_showMessageOnLogin ( )

Show the requested message after the user logs in. Add another tally to the 
number of times the message has been displayed. Show a link to the next
stage for the user.

=cut

sub www_showMessageOnLogin {
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
    my $session = $self->session;
    my $redirectUrl =  $self->session->form->get( 'returnUrl' )
                    || $self->session->setting->get("redirectAfterLoginUrl")
                    || $self->session->scratch->get( 'redirectAfterLogin' )
                    || $self->session->url->getBackToSiteURL
                    ;

    $output     .= '<p><a href="' . $redirectUrl . '">' . $i18n->get( 'showMessageOnLogin return' ) 
                .  '</a></p>'
                ;

    # No matter what, we won't be redirecting after this
    $self->session->scratch->delete( 'redirectAfterLogin' );

    return $output;
}

deprecate 'showMessageOnLogin' => 'www_showMessageOnLogin';

#-------------------------------------------------------------------

=head2 www_view ( )

Initialization function for these auth routines.  Default is a superclass function called displayLogin.
Override this method in your subclass to change the initialization for custom authentication methods

=cut

sub www_view {
	my $self = shift;
	return $self->www_displayLogin;
}

deprecate init => 'www_view';

1;
