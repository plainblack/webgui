package WebGUI::Auth::LDAP;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Auth;
use WebGUI::HTMLForm;
use WebGUI::Form;
use WebGUI::LDAPLink;
use WebGUI::Utility;
use WebGUI::Workflow;
use WebGUI::Operation::Shared;
use WebGUI::Asset::Template;
use URI;
use Net::LDAP;

our @ISA = qw(WebGUI::Auth);


#-------------------------------------------------------------------

=head2 sub _isValidLDAPUser ( )

Private method that gets username and password supplied by a user attempting to
login and then attempts to bind to the LDAP server using credentials provided.
If the bind is successful, the user is considered valid and authenticated as far
as LDAP is concerned.

Note: This method does not ensure that the user is valid in WebGUI.
i.e., it does not validate their username or ensure their account is active.

=cut

sub _isValidLDAPUser {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my ($error, $ldap, $search, $auth, $connectDN);
    my $i18n = WebGUI::International->new($session);

    my $connection = $self->getLDAPConnection;
    return 0 unless $connection;
    
    #Check to see that the LDAP Link is valid
    my $ldapLink = $self->getLDAPLink;
    unless ($ldapLink) {
        $self->error('<li>'.$i18n->get(2,'AuthLDAP').'</li>');
        return 0;
    }
    my $username = $form->get("authLDAP_ldapId")     || $form->get("username");
    my $password = $form->get("authLDAP_identifier") || $form->get("identifier");

    my $uri = URI->new($connection->{ldapUrl}) or $error = '<li>'.$i18n->get(2,'AuthLDAP').'</li>';

    if($error ne ""){
        $self->error($error);
        return 0;
    }

    # Create an LDAP object
    if ($ldap = Net::LDAP->new($uri->host, (port=>$uri->port,scheme=>$uri->scheme))) {

        # Bind as a proxy user to search for the user trying to login
        if($connection->{connectDn}) {
            $auth = $ldap->bind(dn=>$connection->{connectDn}, password=>$connection->{identifier});
        }
        else {  # No proxy user specified, try to bind anonymously for the search
            $auth = $ldap->bind;
        }
        
        # If we were able to bind
        if ($auth) {
            # Search for the user trying to login
            $search = $ldap->search(base=>$uri->dn, filter=>$connection->{ldapIdentity}.'='.$username);

            # If we found a match
            if (defined $search->entry(0)) {
                # Determine the users distinguished name using dn
                if ($connection->{ldapUserRDN} eq 'dn') {
                    $connectDN = $search->entry(0)->dn;
                }
                else { # or... use a releative distinguished name instead
                    $connectDN = $search->entry(0)->get_value($connection->{ldapUserRDN});
                }

                # Remember the users DN so we can use it later.
                $self->setConnectDN($connectDN);
                $ldap->unbind;

                # Create a new LDAP object
                $ldap = $ldapLink->connectToLDAP or $error .= $i18n->get(2,'AuthLDAP');

                #Try to bind to the directory using the users dn and password
                $auth = $ldap->bind(dn=>$connectDN, password=>$password);

                # Invalid login credentials, directory did not authenticate the user
                if ($auth->code == 48 || $auth->code == 49) {
                    $error .= '<li>'.$i18n->get(68).'</li>';
                    $session->log->warn("Invalid LDAP information for registration of LDAP ID: ".$self->session->form->process('authLDAP_ldapId'));
                }
                elsif ($auth->code > 0) {  # Some other LDAP error occured
                    $error .= '<li>LDAP error "'.$self->ldapStatusCode($auth->code).'" occured. '.$i18n->get(69).'</li>';
                    $session->log->error("LDAP error: ".$self->ldapStatusCode($auth->code));
                }
                $ldap->unbind;
            }
            else { # Could not find the user in the directory to build a DN
                $error .= '<li>'.$i18n->get(68).'</li>';
                $session->log->warn("Invalid LDAP information for registration of LDAP ID: ".$self->session->form->process("authLDAP_ldapId"));
            }
        }
        else { # Unable to bind with proxy user credentials or anonymously for our search
            $error = '<li>'.$i18n->get(2,'AuthLDAP').'</li>';
            $session->log->error("Couldn't bind to LDAP server: ".$connection->{ldapUrl});
        }
   }
   else { # Could not create our LDAP object
      $error = '<li>'.$i18n->get(2,'AuthLDAP').'</li>';
      $session->log->error("Couldn't create LDAP object: ".$connection->{ldapUrl});
   }

   $self->error($error);

   # Return 1 on successful authentication
   return $error eq "";
}

#-------------------------------------------------------------------

=head2 sub authenticate ( $username, $password )

This method checks a given username and password for the following:

1) Is there a WebGUI user account for the user and is it active
2) Does the user account have the properties set necessary to authenticate using LDAP.
3) Can we bind to the LDAP server using their account information

Returns 1 on success.

=cut

sub authenticate {
    my $self = shift;
    my ($uri, $ldap, $auth, $result, $error);
    my $i18n = WebGUI::International->new($self->session);      
    return 0 if !$self->SUPER::authenticate($_[0]);  #see that the username entered actually exists and is active in webgui

    my $userId = $self->userId;
    my $identifier = $_[1];
    my $userData = $self->getParams;

    $error .= '<li>'.$i18n->get(12,'AuthLDAP').'</li>' if ($userData->{ldapUrl} eq "");
    $error .= '<li>'.$i18n->get(11,'AuthLDAP').'</li>' if ($userData->{connectDN} eq "");
    $self->error($error);

    if($error ne ""){
        $self->user(WebGUI::User->new($self->session,1));
        return 0 ;
    }

    if($uri = URI->new($userData->{ldapUrl})) {

        # Create an LDAP object
        $ldap = Net::LDAP->new($uri->host, (port=>$uri->port, scheme=>$uri->scheme)) or $error .= '<li>'.$i18n->get(2,'AuthLDAP').'</li>';

        if($error ne ""){
            $self->user(WebGUI::User->new($self->session,1));
            return 0 ;
        }

        # Try to bind using the users dn and password
        $auth = $ldap->bind(dn=>$userData->{connectDN}, password=>$identifier);

        # Failure to bind could have resulted from change to in DN on LDAP server.
        # Test for new DN and update user account as needed
        if ($auth->code > 0 && $self->_isValidLDAPUser()) {
            # Update user profile and log change
            # _isValidLDAPUser will set _connectDN to new correct value
            $auth = $ldap->bind(dn=>$self->{_connectDN}, password=>$identifier);
            my $message = "DN has been changed for user ".$_[0]." from \"".$userData->{connectDN}."\" to \"".$self->{_connectDN}."\"";
            $self->saveParams($self->user->userId, $self->authMethod, { connectDN => $self->{_connectDN} });
            $self->session->errorHandler->warn($message);
        }
        
        # Authentication failed
        if ($auth->code == 48 || $auth->code == 49 || $auth->code == 32){
            $error .= $self->SUPER::authenticationError;
        }
        elsif ($auth->code > 0) { # Some other LDAP error happened
            $error .= '<li>LDAP error "'.$self->ldapStatusCode($auth->code).'" occured.'.$i18n->get(69).'</li>';
            $self->session->log->error("LDAP error: ".$self->ldapStatusCode($auth->code));
        }

        $ldap->unbind;
    }
    else { 
        $error .= '<li>'.$i18n->get(13,'AuthLDAP').'</li>';
        $self->session->log->error("Could not process this LDAP URL: ".$userData->{ldapUrl});
    }

    if($error ne ""){
        $self->error($error);
        $self->user(WebGUI::User->new($self->session,1));
    }

    return $error eq "";	
}

#-------------------------------------------------------------------

=head2 connectToLDAP ( ) 

Create a new WebGUI::LDAPLink connection, if possible.

=cut

sub connectToLDAP {

    # This method needs to do some excpetion handling when we try to create an LDAPLink object
    # Lot's to do though because then everything calling connectToLDAP must also handle exceptions on up
    #
    # Problem is that $connectionId may not have a value or the object creation may fail for other reasons.
    # Quick fix for now is to ensure the ldapConnection setting is set in the settings table with the id of 
    # the default ldap connection.

    my $self = shift;
    my $connectionId = $self->session->form->process("connection") || $self->session->setting->get("ldapConnection");
    my $ldapLink = WebGUI::LDAPLink->new($self->session,$connectionId);
    return undef unless defined $ldapLink;
    my $connection = $ldapLink->get;

    $self->{'_ldapLink'  } = $ldapLink;
    $self->{'_connection'} = $connection;   
    return $connection;
}

#-------------------------------------------------------------------

=head2 createAccount ( message, confirm ) 

Show the form to create a new LDAP account relationship

=cut

sub createAccount {
    my $self = shift;
	my $message = shift;
	my $confirm = shift || $self->session->form->process("confirm");
    my $vars;
    if ($self->session->user->isRegistered) {
       return $self->displayAccount;
    }
    elsif (!$self->session->setting->get("anonymousRegistration") && !$self->session->setting->get('inboxInviteUserEnabled')) {
 	   return $self->displayLogin;
    } 


	my $connection = $self->getLDAPConnection;
    if (! $connection) {
       $self->session->log->error('Unable to create LDAP account as there is no LDAP connection defined');
       return $self->displayLogin;
    }
	$vars->{'create.message'} = $message if ($message);
	my $i18n = WebGUI::International->new($self->session,"AuthLDAP");
	$vars->{'create.form.ldapConnection.label'} = $i18n->get("ldapConnection");

	my $url = $self->session->url->page("op=auth;method=createAccount;connection=");
	$vars->{'create.form.ldapConnection'} = WebGUI::Form::selectBox($self->session, {
	                name=>"ldapConnection",
					options=>WebGUI::LDAPLink->getList($self->session,),
					value=>[$connection->{ldapLinkId}],
					extras=>qq|onchange="location.href='$url'+this.options[this.selectedIndex].value"|
				  });
   my $ldapId =  $self->session->form->process("authLDAP_ldapId");
   $vars->{'create.form.ldapId'} = WebGUI::Form::text($self->session,{
      name   =>"authLDAP_ldapId",
      value  =>$ldapId,
      extras => $self->getExtrasStyle($ldapId)
   });
   $vars->{'create.form.ldapId.label'} = $connection->{ldapIdentityName};
   
   my $ldapPwd = $self->session->form->process("authLDAP_identifier");
   $vars->{'create.form.password'} = WebGUI::Form::password($self->session,{
      "name"=>"authLDAP_identifier",
      "value"=> $ldapPwd,
      extras => $self->getExtrasStyle($ldapPwd)
   });
   $vars->{'create.form.password.label'} = $connection->{ldapPasswordName};

   $vars->{'create.form.hidden'} = WebGUI::Form::hidden($self->session,{"name"=>"confirm","value"=>$confirm});
   return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------

=head2 createAccountSave (  )

Process the form to create a new LDAP account relationship

=cut

sub createAccountSave {
    my $self = shift;
    my $username = $self->session->form->process('authLDAP_ldapId');
    my $password = $self->session->form->process('authLDAP_identifier');
    my $error = "";
    my $i18n = WebGUI::International->new($self->session);

    #Validate user in LDAP
    if(!$self->_isValidLDAPUser()){
        return $self->createAccount("<h1>".$i18n->get(70)."</h1>".$self->error);
    }

    my $connection = $self->getLDAPConnection;
    if (! $connection) {
        return $self->createAccount("<h1>".$i18n->get('no ldap link for auth')."</h1>".$self->error);
    }
    #Get connectDN from settings   
    my $uri = URI->new($connection->{ldapUrl});
    my $ldap = Net::LDAP->new($uri->host, (port=>$uri->port,scheme=>$uri->scheme));
    my $auth;
    if($connection->{connectDn}) {
        $auth = $ldap->bind(dn=>$connection->{connectDn}, password=>$connection->{identifier});
    }
    else{
        $auth = $ldap->bind;
    }
    #$ldap->bind;
    my $search = $ldap->search (base => $uri->dn, filter=>$connection->{ldapIdentity}."=".$username);
    my $connectDN = "";
    if (defined $search->entry(0)) {
        if ($connection->{ldapUserRDN} eq 'dn') {
            $connectDN = $search->entry(0)->dn;
        }
        else { 
            $connectDN = $search->entry(0)->get_value($connection->{ldapUserRDN});
        }
    }
    $ldap->unbind;


    #Check that username is valid and not a duplicate in the system.
    $error .= $self->error if(!$self->validUsername($username));
    #Validate profile data.
    my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData($self->session);
    $error .= $temp;
    return $self->createAccount("<li>".$error."</li1>") unless ($error eq "");
    #If Email address is not unique, a warning is displayed
    if($warning ne "" && !$self->session->form->process("confirm")){
        return $self->createAccount('<li>'.$i18n->get(1078).'</li>', 1);
    }

    my $properties;
    $properties->{connectDN} = $connectDN;
    $properties->{ldapUrl} = $connection->{ldapUrl};
    $properties->{ldapConnection} = $connection->{ldapLinkId};

    return $self->SUPER::createAccountSave($username,$properties,$password,$profile);
}

#-------------------------------------------------------------------

=head2 deactivateAccount ( )

Show the confirmation form to deactivate the user's account

=cut

sub deactivateAccount {
    my $self = shift;
    return $self->displayLogin if($self->userId eq '1');
    return $self->SUPER::deactivateAccount("deactivateAccountConfirm");
}

#-------------------------------------------------------------------

=head2 deactivateAccountConfirm ( )

Confirm the user is deactivating their account.

=cut

sub deactivateAccountConfirm {
   my $self = shift;
   return $self->displayLogin unless ($self->session->setting->get("selfDeactivation"));
   return $self->SUPER::deactivateAccountConfirm;
}

#-------------------------------------------------------------------

=head2 displayAccount ( message ) 

Display the account details.

=cut

sub displayAccount {
    my $self = shift;
    my $vars;
    return $self->displayLogin($_[0]) if ($self->isVisitor);
	my $i18n = WebGUI::International->new($self->session);
    $vars->{displayTitle} = '<h1>'.$i18n->get(61).'</h1>';
    $vars->{'account.message'} = $i18n->get(856);
    if($self->session->setting->get("useKarma")){
        $vars->{'account.form.karma'} = $self->session->user->profileField("karma");
        $vars->{'account.form.karma.label'} = $i18n->get(537);
    }

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

=head2 displayLogin ( message )

Web-facing method to display the login form.

=cut

sub displayLogin {
   my $self = shift;
   my $vars;
   return $self->displayAccount($_[0]) if ($self->isRegistered);
   $vars->{'login.message'} = $_[0] if ($_[0]);
   return $self->SUPER::displayLogin("login",$vars);
}

#-------------------------------------------------------------------

=head2 editUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub editUserForm {
    my $self = shift;
    my $userData = $self->getParams;
	my $connection = $self->getLDAPConnection;
    return '' unless $connection;
    my $ldapUrl = $self->session->form->process('authLDAP_ldapUrl') || $userData->{ldapUrl} || $connection->{ldapUrl};
	my $connectDN = $self->session->form->process('authLDAP_connectDN') || $userData->{connectDN};
	my $ldapConnection = $self->session->form->process('authLDAP_ldapConnection') || $userData->{ldapConnection};
	my $ldapLinks = $self->session->db->buildHashRef("select ldapLinkId,ldapUrl from ldapLink");
	my $f = WebGUI::HTMLForm->new($self->session);
	my $jscript = "";
	my $i18n = WebGUI::International->new($self->session,'AuthLDAP');
	if(scalar(keys %{$ldapLinks}) > 0) {
	   my $jsArray = "";
	   foreach my $key (keys %{$ldapLinks}) {
	      next unless ($key);
	      $jsArray .= 'ldapValue["'.$key.'"]="'.$ldapLinks->{$key}.'";'."\n";
	   }
	   $jsArray .= 'ldapValue["0"]="'.$ldapUrl.'";'."\n";
	   $jscript = qq|
	   <script type="text/javascript">
	      <!--
	        var ldapValue = new Array();
		    $jsArray
	      //-->
	   </script>|;
	   $f->selectBox(
	                -name=>"authLDAP_ldapConnection",
					-label=>$i18n->get("ldapConnection"),
					-hoverHelp=>$i18n->get("ldapConnection description"),
					-options=>WebGUI::LDAPLink->getList($self->session,),
					-value=>[$ldapConnection],
					-extras=>q|onchange="this.form.authLDAP_ldapUrl.value=ldapValue[this.options[this.selectedIndex].value];"|
				  );
	}
	$f->url(
		-name => "authLDAP_ldapUrl",
		-label => $i18n->get(3),
		-value => $ldapUrl,
	);
	$f->text(
		-name => "authLDAP_connectDN",
		-label => $i18n->get('LDAP User DN'),
		-value => $connectDN,
	);
	$self->session->style->setRawHeadTags($jscript);
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub editUserFormSave {
   my $self = shift;
   my $properties;
   $properties->{connectDN} = $self->session->form->process('authLDAP_connectDN');
   $properties->{ldapUrl} = $self->session->form->process('authLDAP_ldapUrl');
   $properties->{ldapConnection} = $self->session->form->process('authLDAP_ldapConnection');
   $self->SUPER::editUserFormSave($properties); 
}

#-------------------------------------------------------------------

=head2 editUserSettingsForm ( )

  Creates form elements for user settings page custom to this auth module

=cut

sub editUserSettingsForm {
   my $self = shift;
   my $f = WebGUI::HTMLForm->new($self->session);
   my $ldapConnection = WebGUI::Form::selectBox($self->session, {
	                name=>"ldapConnection",
					options=>WebGUI::LDAPLink->getList($self->session,),
					value=>[$self->session->setting->get("ldapConnection")]
				  });
	my $i18n = WebGUI::International->new($self->session,'AuthLDAP');
   my $ldapConnectionLabel = $i18n->get("ldapConnection"); 
   my $buttons = "";
   if($self->session->setting->get("ldapConnection")) {
      $buttons = $self->session->icon->edit("op=editLDAPLink;returnUrl=".$self->session->url->escape($self->session->url->page("op=editSettings")).";llid=".$self->session->setting->get("ldapConnection"));
   }
   $buttons .= $self->session->icon->manage("op=listLDAPLinks;returnUrl=".$self->session->url->escape($self->session->url->page("op=editSettings")));
   $f->raw(qq|<tr><td class="formDescription" valign="top" style="width: 25%;">$ldapConnectionLabel</td><td class="tableData" style="width: 75%;">$ldapConnection&nbsp;$buttons</td></tr>|);
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editUserSettingsFormSave ( )

Process the editUserSettingsForm

=cut

sub editUserSettingsFormSave {
   my $self = shift;
   my $f = $self->session->form;
   my $s = $self->session->setting;
   $s->set("ldapConnection", $f->process("ldapConnection","selectBox"));
}

#-------------------------------------------------------------------

=head2 getAccountTemplateId ( )

Get the templateId of the template to show the user's account details

=cut

sub getAccountTemplateId {
    my $self = shift;
    my $ldapConnect = $self->getLDAPConnection;
    return "PBtmpl0000000000000004" unless $ldapConnect;
	return ($self->getLDAPConnection->{ldapAccountTemplate} || "PBtmpl0000000000000004");
}

#-------------------------------------------------------------------

=head2 getConnectDN ( )

Get the Distinguished Name used to connect to the LDAP server.

=cut

sub getConnectDN {
   my $self = shift;
   return $self->{_connectDN};
}

#-------------------------------------------------------------------

=head2 getCreateAccountTemplateId ( )

Get the templateId to create a new LDAP account relationship

=cut

sub getCreateAccountTemplateId {
    my $self = shift;
    my $ldapConnect = $self->getLDAPConnection;
    return "PBtmpl0000000000000005" unless $ldapConnect;
	return ($ldapConnect->{ldapCreateAccountTemplate} || "PBtmpl0000000000000005");
}

#-------------------------------------------------------------------

=head2 getDeactivateAccountTemplateId ( )

Get the default template ID for the deactivate account form.

=cut

sub getDeactivateAccountTemplateId {
    my $self = shift;
    my $ldapConnect = $self->getLDAPConnection;
    return $self->SUPER::getDeactivateAccountTemplateId unless $ldapConnect;
    return ($ldapConnect->{ldapDeactivateAccountTemplate} || $self->SUPER::getDeactivateAccountTemplateId);
}

#-------------------------------------------------------------------

=head2 getDefaultLoginTemplateId ( )

Get the default template ID for the login form.

=cut

sub getDefaultLoginTemplateId {
    return "PBtmpl0000000000000006";
}

#-------------------------------------------------------------------

=head2 getLDAPConnection ( )

Get the properties of the LDAP connection we're using for Auth.

=cut

sub getLDAPConnection {
   my $self = shift;

   return $self->{_connection} if $self->{_connection};
   return $self->connectToLDAP;   
}

#-------------------------------------------------------------------

=head2 getLDAPLink ( )

Get the WebGUI::LDAPLink for this auth connection

=cut

sub getLDAPLink {
   my $self = shift;
   
   return $self->{_ldapLink};
}

#-------------------------------------------------------------------

=head2 getLoginTemplateId ( )

Get the template ID for the login form.

=cut

sub getLoginTemplateId {
    my $self = shift;
    my $ldapConnect = $self->getLDAPConnection;
    return $self->getDefaultLoginTemplateId unless $ldapConnect;
    return ($self->getLDAPConnection->{ldapLoginTemplate} || $self->getDefaultLoginTemplateId);
}

#-------------------------------------------------------------------

=head2 login ( )

Process the login form. Create a new account if auto registration is enabled.

=cut

sub login {
    my $self = shift;
    my $i18n = WebGUI::International->new($self->session);
    my $username         = $self->session->form->process("username");
    my $identifier       = $self->session->form->process("identifier");
    my $autoRegistration = $self->session->setting->get("automaticLDAPRegistration");
    my $hasAuthenticated = 0;

    $hasAuthenticated = 1 if ( $self->authenticate($username,$identifier) );

    my $connection = $self->getLDAPConnection;
    if (! $connection) {
       return $self->displayLogin("<h1>".$i18n->get('no ldap logins')."</h1>".$self->error);
    }

   # Autoregistration is on and they didn't authenticate yet
   if ($autoRegistration && !$hasAuthenticated) {
      # See if they are in LDAP and if so that they can bind with the password given.
      if($self->_isValidLDAPUser()) {

         # Create a WebGUI Account
         if ($self->validUsername($username)) {
            $self->SUPER::createAccountSave($username, {
                 connectDN       => $self->getConnectDN,
                 ldapUrl         => $connection->{ldapUrl},
                 ldapConnection  => $connection->{ldapLinkId},
            },$identifier);
            $hasAuthenticated = 1;

            # Pull the users profile from LDAP to WebGUI
            WebGUI::Workflow::Instance->create($self->session, {
			workflowId=>'AuthLDAPworkflow000001',
			methodName=>"new",
			className=>"WebGUI::User",
			parameters=>$self->session->user->userId,
			priority=>3
            })->start;    
         }
      }
   }
   return $self->SUPER::login() if $hasAuthenticated;  #Standard login routine for login

   $self->session->log->security("login to account ".$self->session->form->process("username")." with invalid information.");
   return $self->displayLogin("<h1>".$i18n->get(70)."</h1>".$self->error);
}

#-------------------------------------------------------------------

=head2 new ( session, authMethod, userId )

Create a new Auth instance. C<authMethod> is the name of this auth method ("ldap").
C<userId> is the ID of the user to be authenticated.

=cut

sub new {
   my $class = shift;
	my $session = shift;
   my $authMethod = $_[0];
   my $userId = $_[1];
   my @callable = ('createAccount','deactivateAccount','displayAccount','displayLogin','login','logout','createAccountSave','deactivateAccountConfirm');
   my $self = WebGUI::Auth->new($session,$authMethod,$userId,\@callable);
   #my $connection = $session->scratch->get("ldapConnection") || $session->setting->get("ldapConnection");
   #my $ldaplink = WebGUI::LDAPLink->new($session,$connection); 
   #$self->{_connection} = $ldaplink->get if $ldaplink;

	my $i18n = WebGUI::International->new($session, "AuthLDAP");
	my %ldapStatusCode = map { $_ => $i18n->get("LDAPLink_".$_) }
			     (0..21, 32,33,34,36, 48..54, 64..71, 80);
	$self->{_statusCode} = \%ldapStatusCode;
   bless $self, $class;
}

#-------------------------------------------------------------------

=head2 ldapStatusCode ( code )

Get the friendly i18n message for the given LDAP status code.

=cut

sub ldapStatusCode {
   my ($self, $code) = @_;
   return $self->{_statusCode}->{$code};
}

#-------------------------------------------------------------------

=head2 setConnectDN ( connectDn ) 

Set a distinguished name to connect with

=cut

sub setConnectDN {
   my $self = shift;
   $self->{_connectDN} = $_[0];
}


1;
