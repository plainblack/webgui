package WebGUI::Auth::LDAP;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Auth;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Form;
use WebGUI::Mail;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Operation::Shared;
use URI;
use Net::LDAP;

our @ISA = qw(WebGUI::Auth);

my %ldapStatusCode = ( 0=>'success (0)', 1=>'Operations Error (1)', 2=>'Protocol Error (2)',
        3=>'Time Limit Exceeded (3)', 4=>'Size Limit Exceeded (4)', 5=>'Compare False (5)',
        6=>'Compare True (6)', 7=>'Auth Method Not Supported (7)', 8=>'Strong Auth Required (8)',
        9=>'Referral (10)', 11=>'Admin Limit Exceeded (11)', 12=>'Unavailable Critical Extension (12)',
        13=>'Confidentiality Required (13)', 14=>'Sasl Bind In Progress (14)',
        15=>'No Such Attribute (16)', 17=>'Undefined Attribute Type (17)',
        18=>'Inappropriate Matching (18)', 19=>'Constraint Violation (19)',
        20=>'Attribute Or Value Exists (20)', 21=>'Invalid Attribute Syntax (21)', 32=>'No Such Object (32)',
        33=>'Alias Problem (33)', 34=>'Invalid DN Syntax (34)', 36=>'Alias Dereferencing Problem (36)',
        48=>'Inappropriate Authentication (48)', 49=>'Invalid Credentials (49)',
        50=>'Insufficient Access Rights (50)', 51=>'Busy (51)', 52=>'Unavailable (52)',
        53=>'Unwilling To Perform (53)', 54=>'Loop Detect (54)', 64=>'Naming Violation (64)',
        65=>'Object Class Violation (65)', 66=>'Not Allowed On Non Leaf (66)', 67=>'Not Allowed On RDN (67)',
        68=>'Entry Already Exists (68)', 69=>'Object Class Mods Prohibited (69)',
        71=>'Affects Multiple DSAs (71)', 80=>'other (80)');

#-------------------------------------------------------------------
sub _isValidLDAPUser {
   my $self = shift;
   my ($uri, $error, $ldap, $search, $auth, $connectDN);
   
   $uri = URI->new($session{setting}{ldapURL}) or $error = WebGUI::International::get(2,'Auth/LDAP');
   if($error ne ""){
      $self->error($error);
	  return 0;
   }
   
   if ($ldap = Net::LDAP->new($uri->host, (port=>$uri->port))) {
      if ($ldap->bind) {
         $search = $ldap->search (base=>$uri->dn,filter=>$session{setting}{ldapId}."=".$session{form}{'authLDAP.ldapId'});
            if (defined $search->entry(0)) {
				if ($session{setting}{ldapUserRDN} eq 'dn') {
                   $connectDN = $search->entry(0)->dn;
                } else {
                   $connectDN = $search->entry(0)->get_value($session{setting}{ldapUserRDN});
                }
                $ldap->unbind;
                $ldap = Net::LDAP->new($uri->host, (port=>$uri->port)) or $error .= WebGUI::International::get(2,'Auth/LDAP');
                $auth = $ldap->bind(dn=>$connectDN, password=>$session{form}{'authLDAP.identifier'});
                if ($auth->code == 48 || $auth->code == 49) {
                   $error .= '<li>'.WebGUI::International::get(68);
                   WebGUI::ErrorHandler::warn("Invalid LDAP information for registration of LDAP ID: ".$session{form}{'authLDAP.ldapId'});
                } elsif ($auth->code > 0) {
                   $error .= '<li>LDAP error "'.$ldapStatusCode{$auth->code}.'" occured. '.WebGUI::International::get(69);
           		   WebGUI::ErrorHandler::warn("LDAP error: ".$ldapStatusCode{$auth->code});
                }
                $ldap->unbind;
        	} else {
               $error .= '<li>'.WebGUI::International::get(68);
               WebGUI::ErrorHandler::warn("Invalid LDAP information for registration of LDAP ID: ".$session{form}{'authLDAP.ldapId'});
            }
	 } else {
	     $error = WebGUI::International::get(2,'Auth/LDAP');
		 WebGUI::ErrorHandler::warn("Couldn't bind to LDAP server: ".$session{setting}{ldapURL});
	 }
  } else {
     $error = WebGUI::International::get(2,'Auth/LDAP');
	 WebGUI::ErrorHandler::warn("Couldn't create LDAP object: ".$uri->host);
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
    my $ldapUrl = $session{form}{'authLDAP.ldapUrl'} || $userData->{ldapUrl} || $session{setting}{ldapURL};
	my $connectDN = $session{form}{'authLDAP.connectDN'} || $userData->{connectDN};
	
	my $f = WebGUI::HTMLForm->new;
	$f->url("authLDAP.ldapUrl",WebGUI::International::get(3,'Auth/LDAP'),$ldapUrl);
	$f->text("authLDAP.connectDN",WebGUI::International::get(4,'Auth/LDAP'),$connectDN);
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 addUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub addUserFormSave {
   my $self = shift;
   my $properties;
   $properties->{connectDN} = $session{form}{'authLDAP.connectDN'};
   $properties->{ldapUrl} = $session{form}{'authLDAP.ldapUrl'};
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
		
	
	$error .= WebGUI::International::get(12,'Auth/LDAP') if ($userData->{ldapUrl} eq "");
	$error .= WebGUI::International::get(11,'Auth/LDAP') if ($userData->{connectDN} eq "");
	
	$self->error($error);
    if($error ne ""){
	   $self->user(WebGUI::User->new(1));
	   return 0 ;
	}
	
	if($uri = URI->new($userData->{ldapUrl})) {
	   $ldap = Net::LDAP->new($uri->host, (port=>$uri->port)) or $error .= WebGUI::International::get(2,'Auth/LDAP');
	   if($error ne ""){
	      $self->user(WebGUI::User->new(1));
	      return 0 ;
	   }
	   $auth = $ldap->bind(dn=>$userData->{connectDN}, password=>$identifier);
       if ($auth->code == 48 || $auth->code == 49){
		  $error .= WebGUI::International::get(68);
	   }elsif($auth->code > 0){
	      $error .= 'LDAP error "'.$ldapStatusCode{$auth->code}.'" occured.'.WebGUI::International::get(69);
		  WebGUI::ErrorHandler::warn("LDAP error: ".$ldapStatusCode{$auth->code});
	   }
	   $ldap->unbind;
	}else{
	   $error .= WebGUI::International::get(13,'Auth/LDAP');
	   WebGUI::ErrorHandler::warn("Could not process this LDAP URL: ".$userData->{ldapUrl});
	}
	if($error ne ""){
	   $self->error($error);
	   $self->user(WebGUI::User->new(1));
	}
	return $error eq "";	
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
    $vars->{'create.form.ldapId'} = WebGUI::Form::text({"name"=>"authLDAP.ldapId","value"=>$session{form}{"authLDAP.ldapId"}});
    $vars->{'create.form.ldapId.label'} = $session{setting}{ldapIdName};
    $vars->{'create.form.password'} = WebGUI::Form::password({"name"=>"authLDAP.identifier","value"=>$session{form}{"authLDAP.identifier"}});
    $vars->{'create.form.password.label'} = $session{setting}{ldapPasswordName};
    
    $vars->{'create.form.hidden'} = WebGUI::Form::hidden({"name"=>"confirm","value"=>$session{form}{confirm}});
    return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
sub createAccountSave {
   my $self = shift;
   my $username = $session{form}{'authLDAP.ldapId'};
   my $password = $session{form}{'authLDAP.identifier'};
   my $error = "";
   
   #Validate user in LDAP
   if(!$self->_isValidLDAPUser()){
      return $self->createAccount("<h1>".WebGUI::International::get(70)."</h1>".$self->error);
   }
   
   #Get connectDN from settings   
   my $uri = URI->new($session{setting}{ldapURL});
   my $ldap = Net::LDAP->new($uri->host, (port=>$uri->port));
   $ldap->bind;
   my $search = $ldap->search (base => $uri->dn, filter=>$session{setting}{ldapId}."=".$username);
   my $connectDN = "";
   if (defined $search->entry(0)) {
      if ($session{setting}{ldapUserRDN} eq 'dn') {
	     $connectDN = $search->entry(0)->dn;
	  } else { 
		 $connectDN = $search->entry(0)->get_value($session{setting}{ldapUserRDN});
	  }
   }
   $ldap->unbind;
   
   
   #Check that username is valid and not a duplicate in the system.
   $error .= $self->error if($self->validUsername($username));
   #Validate profile data.
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData();
   $error .= $temp;
   return $self->createAccount("<h1>".WebGUI::International::get(70)."</h1>".$error) unless ($error eq "");
   #If Email address is not unique, a warning is displayed
   if($warning ne "" && !$session{form}{confirm}){
      $session{form}{confirm} = 1;
      return $self->createAccount('<li>'.WebGUI::International::get(1078));
   }
   
   my $properties;
   $properties->{connectDN} = $connectDN;
   $properties->{ldapUrl} = $session{setting}{ldapURL};
   
   return $self->SUPER::createAccountSave($username,$properties,$password,$profile);
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
   $vars->{displayTitle} = '<h1>'.WebGUI::International::get(61).'</h1>';
   $vars->{'account.message'} = WebGUI::International::get(856);
   if($session{setting}{useKarma}){
      $vars->{'account.form.karma'} = $session{user}{karma};
	  $vars->{'account.form.karma.label'} = WebGUI::International::get(537);
   }
   $vars->{'account.options'} = WebGUI::Operation::Shared::accountOptions();
   return WebGUI::Template::process(WebGUI::Template::get(1,'Auth/LDAP/Account'), $vars);
}

#-------------------------------------------------------------------
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
   return $self->addUserFormSave;
}

#-------------------------------------------------------------------

=head2 editUserSettingsForm ( )

  Creates form elements for user settings page custom to this auth module

=cut

sub editUserSettingsForm {
   my $self = shift;
   my $f = WebGUI::HTMLForm->new;
   $f->text("ldapUserRDN",WebGUI::International::get(9,'Auth/LDAP'),$session{setting}{ldapUserRDN});
   $f->url("ldapURL",WebGUI::International::get(5,'Auth/LDAP'),$session{setting}{ldapURL});
   $f->text("ldapId",WebGUI::International::get(6,'Auth/LDAP'),$session{setting}{ldapId});
   $f->text("ldapIdName",WebGUI::International::get(7,'Auth/LDAP'),$session{setting}{ldapIdName});
   $f->text("ldapPasswordName",WebGUI::International::get(8,'Auth/LDAP'),$session{setting}{ldapPasswordName});
   $f->yesNo(
             -name=>"ldapSendWelcomeMessage",
             -value=>$session{setting}{ldapSendWelcomeMessage},
             -label=>WebGUI::International::get(868)
             );
   $f->textarea(
                -name=>"ldapWelcomeMessage",
                -value=>$session{setting}{ldapWelcomeMessage},
                -label=>WebGUI::International::get(869)
               );
   return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub login {
   my $self = shift;
   if(!$self->authenticate($session{form}{username},$session{form}{identifier})){
      WebGUI::ErrorHandler::security("login to account ".$session{form}{username}." with invalid information.");
	  return $self->displayLogin("<h1>".WebGUI::International::get(70)."</h1>".$self->error);
   }
   return $self->SUPER::login();  #Standard login routine for login
}

#-------------------------------------------------------------------
sub new {
   my $class = shift;
   my $authMethod = $_[0];
   my $userId = $_[1];
   my @callable = ('createAccount','deactivateAccount','displayAccount','displayLogin','login','logout','createAccountSave','deactivateAccountConfirm');
   my $self = WebGUI::Auth->new($authMethod,$userId,\@callable);
   bless $self, $class;
}

1;

