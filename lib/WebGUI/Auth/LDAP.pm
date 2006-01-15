package WebGUI::Auth::LDAP;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Mail;
use WebGUI::Utility;
use WebGUI::Operation::Shared;
use WebGUI::Asset::Template;
use URI;
use Net::LDAP;

our @ISA = qw(WebGUI::Auth);


#-------------------------------------------------------------------
sub _isValidLDAPUser {
   my $self = shift;
   my ($uri, $error, $ldap, $search, $auth, $connectDN);
	my $i18n = WebGUI::International->new($self->session);
   my $connection = $self->{_connection};
   $uri = URI->new($connection->{ldapURL}) or $error = $i18n->get(2,'AuthLDAP');
   if($error ne ""){
      $self->error($error);
	  return 0;
   }
   
   if ($ldap = Net::LDAP->new($uri->host, (port=>$uri->port))) {
      if($connection->{connectDn}) {
	     $auth = $ldap->bind(dn=>$connection->{connectDn}, password=>$connection->{identifier});
	  }else{
	     $auth = $ldap->bind;
	  }
      if ($auth) {
	      $search = $ldap->search ( base=>$uri->dn, filter=>$connection->{ldapIdentity}."=".$self->session->form->process('authLDAP_ldapId'));
			if (defined $search->entry(0)) {
				if ($connection->{ldapUserRDN} eq 'dn') {
                   $connectDN = $search->entry(0)->dn;
                } else {
                   $connectDN = $search->entry(0)->get_value($connection->{ldapUserRDN});
                }
                $ldap->unbind;
                $ldap = Net::LDAP->new($uri->host, (port=>$uri->port)) or $error .= $i18n->get(2,'AuthLDAP');
                $auth = $ldap->bind(dn=>$connectDN, password=>$self->session->form->process('authLDAP_identifier'));
                if ($auth->code == 48 || $auth->code == 49) {
                   $error .= '<li>'.$i18n->get(68).'</li>';
                   $self->session->errorHandler->warn("Invalid LDAP information for registration of LDAP ID: ".$self->session->form->process('authLDAP_ldapId'));
                } elsif ($auth->code > 0) {
                   $error .= '<li>LDAP error "'.$self->ldapStatusCode($auth->code).'" occured. '.$i18n->get(69).'</li>';
           		   $self->session->errorHandler->error("LDAP error: ".$self->ldapStatusCode($auth->code));
                }
                $ldap->unbind;
        	} else {
               $error .= '<li>'.$i18n->get(68).'</li>';
               $self->session->errorHandler->warn("Invalid LDAP information for registration of LDAP ID: ".$self->session->form->process("authLDAP_ldapId"));
            }
	 } else {
	     $error = $i18n->get(2,'AuthLDAP');
		 $self->session->errorHandler->error("Couldn't bind to LDAP server: ".$connection->{ldapURL});
	 }
  } else {
     $error = $i18n->get(2,'AuthLDAP');
	 $self->session->errorHandler->error("Couldn't create LDAP object: ".$uri->host);
  }
  $self->error($error);
  return $error eq "";
}
#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub addUserForm {
    my $self = shift;
    my $userData = $self->getParams;
	my $connection = $self->{_connection};
    my $ldapUrl = $self->session->form->process('authLDAP_ldapUrl') || $userData->{ldapUrl} || $connection->{ldapURL};
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

=head2 addUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub addUserFormSave {
   my $self = shift;
   my $properties;
   $properties->{connectDN} = $self->session->form->process('authLDAP_connectDN');
   $properties->{ldapUrl} = $self->session->form->process('authLDAP_ldapUrl');
   $properties->{ldapConnection} = $self->session->form->process('authLDAP_ldapConnection');
   $self->SUPER::addUserFormSave($properties); 
}

#-------------------------------------------------------------------
sub authenticate {
	my $self = shift;
	my ($uri, $ldap, $auth, $result, $error);
	return 0 if !$self->SUPER::authenticate($_[0]);  #authenticate that the username entered actually exists and is active
	my $userId = $self->userId;
   	my $identifier = $_[1];
	my $userData = $self->getParams;
		
	
	my $i18n = WebGUI::International->new($self->session);
	$error .= $i18n->get(12,'AuthLDAP') if ($userData->{ldapUrl} eq "");
	$error .= $i18n->get(11,'AuthLDAP') if ($userData->{connectDN} eq "");
	
	$self->error($error);
    if($error ne ""){
	   $self->user(WebGUI::User->new($self->session,1));
	   return 0 ;
	}
	
	if($uri = URI->new($userData->{ldapUrl})) {
	   $ldap = Net::LDAP->new($uri->host, (port=>$uri->port)) or $error .= $i18n->get(2,'AuthLDAP');
	   if($error ne ""){
	      $self->user(WebGUI::User->new($self->session,1));
	      return 0 ;
	   }
	   $auth = $ldap->bind(dn=>$userData->{connectDN}, password=>$identifier);
       if ($auth->code == 48 || $auth->code == 49){
		  $error .= $i18n->get(68);
	   }elsif($auth->code > 0){
	      $error .= 'LDAP error "'.$self->ldapStatusCode($auth->code).'" occured.'.$i18n->get(69);
		  $self->session->errorHandler->error("LDAP error: ".$self->ldapStatusCode($auth->code));
	   }
	   $ldap->unbind;
	}else{
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
sub createAccount {
    my $self = shift;
    my $vars;
    if ($self->session->user->profileField("userId") ne "1") {
       return $self->displayAccount;
    } elsif (!$self->session->setting->get("anonymousRegistration")) {
 	   return $self->displayLogin;
    } 
	
	if($self->session->form->process("connection")) {
	   $self->session->scratch->set("ldapConnection",$self->session->form->process("connection"));
	   $self->{_connection} = WebGUI::LDAPLink->new($self->session,$self->session->form->process("connection"))->get; 
	}
	my $connection = $self->{_connection};
	$vars->{'create.message'} = $_[0] if ($_[0]);
	my $i18n = WebGUI::International->new($self->session,"AuthLDAP");
	$vars->{'create.form.ldapConnection.label'} = $i18n->get("ldapConnection");
	
	my $url = $self->session->url->page("op=auth;method=createAccount;connection=");
	$vars->{'create.form.ldapConnection'} = WebGUI::Form::selectBox({
	                name=>"ldapConnection",
					options=>WebGUI::LDAPLink->getList($self->session,),
					value=>[$connection->{ldapLinkId}],
					extras=>qq|onchange="location.href='$url'+this.options[this.selectedIndex].value"|
				  });
    $vars->{'create.form.ldapId'} = WebGUI::Form::text($self->session,{"name"=>"authLDAP_ldapId","value"=>$self->session->form->process("authLDAP_ldapId"}));
    $vars->{'create.form.ldapId.label'} = $connection->{ldapIdentityName};
    $vars->{'create.form.password'} = WebGUI::Form::password($self->session,{"name"=>"authLDAP_identifier","value"=>$self->session->form->process("authLDAP_identifier")});
    $vars->{'create.form.password.label'} = $connection->{ldapPasswordName};
    
    $vars->{'create.form.hidden'} = WebGUI::Form::hidden($self->session,{"name"=>"confirm","value"=>$self->session->form->process("confirm")});
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
   
   my $connection = $self->{_connection};
   #Get connectDN from settings   
   my $uri = URI->new($connection->{ldapURL});
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
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData();
   $error .= $temp;
   return $self->createAccount("<h1>".$i18n->get(70)."</h1>".$error) unless ($error eq "");
   #If Email address is not unique, a warning is displayed
   if($warning ne "" && !$self->session->form->process("confirm")){
      $self->session->form->process("confirm") = 1;
      return $self->createAccount('<li>'.$i18n->get(1078).'</li>');
   }
   
   my $properties;
   $properties->{connectDN} = $connectDN;
   $properties->{ldapUrl} = $connection->{ldapURL};
   
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
   $vars->{'account.options'} = WebGUI::Operation::Shared::accountOptions();
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
   return $self->addUserForm;  
}

#-------------------------------------------------------------------

=head2 editUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub editUserFormSave {
   my $self = shift;
   return $self->addUserFormSave;
}

#-------------------------------------------------------------------

=head2 editUserSettingsForm ( )

  Creates form elements for user settings page custom to this auth module

=cut

sub editUserSettingsForm {
   my $self = shift;
   my $f = WebGUI::HTMLForm->new($self->session);
   my $ldapConnection = WebGUI::Form::selectBox({
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
sub getAccountTemplateId {
    my $self = shift;
	return ($self->{_connection}->{ldapAccountTemplate} || "PBtmpl0000000000000004");
}

#-------------------------------------------------------------------
sub getCreateAccountTemplateId {
    my $self = shift;
	return ($self->{_connection}->{ldapCreateAccountTemplate} || "PBtmpl0000000000000005");
}

#-------------------------------------------------------------------
sub getLoginTemplateId {
    my $self = shift;
    return ($self->{_connection}->{ldapLoginTemplate} || "PBtmpl0000000000000006");
}

#-------------------------------------------------------------------
sub login {
   my $self = shift;
   if(!$self->authenticate($self->session->form->process("username"),$self->session->form->process("identifier"))){
      $self->session->errorHandler->security("login to account ".$self->session->form->process("username")." with invalid information.");
	my $i18n = WebGUI::International->new($self->session);
	  return $self->displayLogin("<h1>".$i18n->get(70)."</h1>".$self->error);
   }
   $self->session->scratch->delete("ldapConnection");
   return $self->SUPER::login();  #Standard login routine for login
}

#-------------------------------------------------------------------
sub new {
   my $class = shift;
   my $authMethod = $_[0];
   my $userId = $_[1];
   my @callable = ('createAccount','deactivateAccount','displayAccount','displayLogin','login','logout','createAccountSave','deactivateAccountConfirm');
   my $self = WebGUI::Auth->new($authMethod,$userId,\@callable);
   $self->{_connection} = WebGUI::LDAPLink->new($self->session,($self->session->scratch->get("ldapConnection") || $self->session->setting->get("ldapConnection")))->get;
	my $i18n = WebGUI::International->new($self->session, "AuthLDAP");
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

1;

