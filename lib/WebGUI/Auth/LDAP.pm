package WebGUI::Auth::LDAP;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
   my $self = shift;
   my ($uri, $error, $ldap, $search, $auth, $connectDN, $username, $password);
   my $i18n = WebGUI::International->new($self->session);
   my $connection = $self->getLDAPConnection;
   
   $username = $self->session->form->get("authLDAP_ldapId") || $self->session->form->get("username");
   $password = $self->session->form->get("authLDAP_identifier") || $self->session->form->get("identifier");
   
   $uri = URI->new($connection->{ldapUrl}) or $error = $i18n->get(2,'AuthLDAP');
   
   if($error ne ""){
      $self->error($error);
      return 0;
   }
   
   # Create an LDAP object
   if ($ldap = Net::LDAP->new($uri->host, (port=>$uri->port))) {

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
            $ldap = Net::LDAP->new($uri->host, (port=>$uri->port)) or $error .= $i18n->get(2,'AuthLDAP');

            # Try to bind to the directory using the users dn and password
            $auth = $ldap->bind(dn=>$connectDN, password=>$password);

            # Invalid login credentials, directory did not authenticate the user
            if ($auth->code == 48 || $auth->code == 49) {
               $error .= '<li>'.$i18n->get(68).'</li>';
               $self->session->errorHandler->warn("Invalid LDAP information for registration of LDAP ID: ".$self->session->form->process('authLDAP_ldapId'));
            }
            elsif ($auth->code > 0) {  # Some other LDAP error occured
               $error .= '<li>LDAP error "'.$self->ldapStatusCode($auth->code).'" occured. '.$i18n->get(69).'</li>';
               $self->session->errorHandler->error("LDAP error: ".$self->ldapStatusCode($auth->code));
            }
            $ldap->unbind;
         }
         else { # Could not find the user in the directory to build a DN
            $error .= '<li>'.$i18n->get(68).'</li>';
            $self->session->errorHandler->warn("Invalid LDAP information for registration of LDAP ID: ".$self->session->form->process("authLDAP_ldapId"));
         }
      }
      else { # Unable to bind with proxy user credentials or anonymously for our search
         $error = $i18n->get(2,'AuthLDAP');
	 $self->session->errorHandler->error("Couldn't bind to LDAP server: ".$connection->{ldapUrl});
      }
   }
   else { # Could not create our LDAP object
      $error = $i18n->get(2,'AuthLDAP');
      $self->session->errorHandler->error("Couldn't create LDAP object: ".$uri->host);
   }
  
   $self->error($error);

   # Return 1 on successful authentication
   return $error eq "";
}

#-------------------------------------------------------------------

=head2 sub authenticate ( $username, $password )

This method checks a given username and password for the following:

1) Is there a WebGUI user account for the user and is it active
2) Does the user account have the properties set necessary to authenticate using
   LDAP.
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
		
   $error .= $i18n->get(12,'AuthLDAP') if ($userData->{ldapUrl} eq "");
   $error .= $i18n->get(11,'AuthLDAP') if ($userData->{connectDN} eq "");
   $self->error($error);

   if($error ne ""){
      $self->user(WebGUI::User->new($self->session,1));
         return 0 ;
   }
	
   if($uri = URI->new($userData->{ldapUrl})) {

      # Create an LDAP object
      $ldap = Net::LDAP->new($uri->host, (port=>$uri->port)) or $error .= $i18n->get(2,'AuthLDAP');

      if($error ne ""){
         $self->user(WebGUI::User->new($self->session,1));
         return 0 ;
      }

      # Try to bind using the users dn and password
      $auth = $ldap->bind(dn=>$userData->{connectDN}, password=>$identifier);

      # Authentication failed
      if ($auth->code == 48 || $auth->code == 49){
         $error .= $i18n->get(68);
      }
      elsif ($auth->code > 0) { # Some other LDAP error happened
         $error .= 'LDAP error "'.$self->ldapStatusCode($auth->code).'" occured.'.$i18n->get(69);
	 $self->session->errorHandler->error("LDAP error: ".$self->ldapStatusCode($auth->code));
      }
	   
      $ldap->unbind;
   }
   else { 
      $error .= $i18n->get(13,'AuthLDAP');
      $self->session->errorHandler->error("Could not process this LDAP URL: ".$userData->{ldapUrl});
   }
	
   if($error ne ""){
      $self->error($error);
      $self->user(WebGUI::User->new($self->session,1));
   }

   return $error eq "";	
}

#-------------------------------------------------------------------
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
   my $connection = $ldapLink->get;
   
   $self->{_connection} = $connection;   
   return $connection;
}

#-------------------------------------------------------------------
sub createAccount {
    my $self = shift;
	my $message = shift;
	my $confirm = shift || $self->session->form->process("confirm");
    my $vars;
    if ($self->session->user->userId ne "1") {
       return $self->displayAccount;
    }
    elsif (!$self->session->setting->get("anonymousRegistration") && !$self->session->setting->get('userInvitationsEnabled')) {
 	   return $self->displayLogin;
    } 
	
	
	my $connection = $self->getLDAPConnection;
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
    $vars->{'create.form.ldapId'} = WebGUI::Form::text($self->session,{"name"=>"authLDAP_ldapId","value"=>$self->session->form->process("authLDAP_ldapId")});
    $vars->{'create.form.ldapId.label'} = $connection->{ldapIdentityName};
    $vars->{'create.form.password'} = WebGUI::Form::password($self->session,{"name"=>"authLDAP_identifier","value"=>$self->session->form->process("authLDAP_identifier")});
    $vars->{'create.form.password.label'} = $connection->{ldapPasswordName};
    
    $vars->{'create.form.hidden'} = WebGUI::Form::hidden($self->session,{"name"=>"confirm","value"=>$confirm});
    return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
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
   #Get connectDN from settings   
   my $uri = URI->new($connection->{ldapUrl});
   my $ldap = Net::LDAP->new($uri->host, (port=>$uri->port));
   my $auth;
   if($connection->{connectDn}) {
      $auth = $ldap->bind(dn=>$connection->{connectDn}, password=>$connection->{identifier});
   }else{
      $auth = $ldap->bind;
   }
   #$ldap->bind;
   my $search = $ldap->search (base => $uri->dn, filter=>$connection->{ldapIdentity}."=".$username);
   my $connectDN = "";
   if (defined $search->entry(0)) {
      if ($connection->{ldapUserRDN} eq 'dn') {
	     $connectDN = $search->entry(0)->dn;
	  } else { 
		 $connectDN = $search->entry(0)->get_value($connection->{ldapUserRDN});
	  }
   }
   $ldap->unbind;
   
   
   #Check that username is valid and not a duplicate in the system.
   $error .= $self->error if(!$self->validUsername($username));
   #Validate profile data.
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData($self->session);
   $error .= $temp;
   return $self->createAccount("<h1>".$i18n->get(70)."</h1>".$error) unless ($error eq "");
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
   $vars->{displayTitle} = '<h1>'.$i18n->get(61).'</h1>';
   $vars->{'account.message'} = $i18n->get(856);
   if($self->session->setting->get("useKarma")){
      $vars->{'account.form.karma'} = $self->session->user->profileField("karma");
	  $vars->{'account.form.karma.label'} = $i18n->get(537);
   }
   $vars->{'account.options'} = WebGUI::Operation::Shared::accountOptions($self->session);
   return WebGUI::Asset::Template->new($self->session,$self->getAccountTemplateId)->process($vars);
}

#-------------------------------------------------------------------
sub displayLogin {
   my $self = shift;
   my $vars;
   return $self->displayAccount($_[0]) if ($self->userId ne "1");
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
		-label => $i18n->get(4),
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
sub editUserSettingsFormSave {
   my $self = shift;
   my $f = $self->session->form;
   my $s = $self->session->setting;
   $s->set("ldapConnection", $f->process("ldapConnection","selectBox"));
}

#-------------------------------------------------------------------
sub getAccountTemplateId {
    my $self = shift;
	return ($self->getLDAPConnection->{ldapAccountTemplate} || "PBtmpl0000000000000004");
}

#-------------------------------------------------------------------
sub getConnectDN {
   my $self = shift;
   return $self->{_connectDN};
}

#-------------------------------------------------------------------
sub getCreateAccountTemplateId {
    my $self = shift;
	return ($self->getLDAPConnection->{ldapCreateAccountTemplate} || "PBtmpl0000000000000005");
}

#-------------------------------------------------------------------
sub getLDAPConnection {
   my $self = shift;
   
   return $self->{_connection} if $self->{_connection};
   return $self->connectToLDAP;   
}

#-------------------------------------------------------------------
sub getLoginTemplateId {
    my $self = shift;
    return ($self->getLDAPConnection->{ldapLoginTemplate} || "PBtmpl0000000000000006");
}

#-------------------------------------------------------------------
sub login {
   my $self = shift;
   my $i18n = WebGUI::International->new($self->session);
   my $username = $self->session->form->process("username");
   my $identifier = $self->session->form->process("identifier");
   my $autoRegistration = $self->session->setting->get("automaticLDAPRegistration");
   my $hasAuthenticated = 0;
   
   $hasAuthenticated = 1 if ( $self->authenticate($username,$identifier) );
   
   # Autoregistration is on and they didn't authenticate yet
   if ($autoRegistration && !$hasAuthenticated) {
      # See if they are in LDAP and if so that they can bind with the password given.
      if($self->_isValidLDAPUser()) {
            
         # Create a WebGUI Account
         if ($self->validUsername($username)) {
            $self->SUPER::createAccountSave($username, {
                 connectDN => $self->getConnectDN,
                 ldapUrl   => $self->getLDAPConnection->{ldapUrl},
                 ldapConnection  => $self->getLDAPConnection->{ldapLinkId},
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

   $self->session->errorHandler->security("login to account ".$self->session->form->process("username")." with invalid information.");
   return $self->displayLogin("<h1>".$i18n->get(70)."</h1>".$self->error);
}

#-------------------------------------------------------------------
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
sub ldapStatusCode {
   my ($self, $code) = @_;
   return $self->{_statusCode}->{$code};
}

#-------------------------------------------------------------------
sub setConnectDN {
   my $self = shift;
   $self->{_connectDN} = $_[0];
}


1;

