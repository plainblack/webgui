package WebGUI::Auth::SMB;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::Session;
use WebGUI::Utility;
use Authen::Smb;
use warnings;

our @ISA = qw(WebGUI::Auth);

my %smbError = (
	1 => WebGUI::International::get(2,'Auth/SMB'),
	2 => WebGUI::International::get(3,'Auth/SMB'),
	3 => WebGUI::International::get(4,'Auth/SMB')
);


#-------------------------------------------------------------------

=head2 addUserForm ( )

  Creates user form elements specific to this Auth Method.

=cut

sub addUserForm {
    my $self = shift;
    my $userData = $self->getParams;
   	my $pdc = $session{form}{'authSMB.smbPDC'} || $userData->{smbPDC} || $session{setting}{smbPDC};
	my $bdc = $session{form}{'authSMB.smbBDC'} || $userData->{smbBDC} || $session{setting}{smbBDC};
	my $domain = $session{form}{'authSMB.smbDomain'} || $userData->{smbDomain} || $session{setting}{smbDomain};
	my $login = $session{form}{'authSMB.smbLogin'} || $userData->{smbLogin};

	my $f = WebGUI::HTMLForm->new;
	$f->text("authSMB.smbPDC",WebGUI::International::get(5,'Auth/SMB'),$pdc);
	$f->text("authSMB.smbBDC",WebGUI::International::get(6,'Auth/SMB'),$bdc);
	$f->text("authSMB.smbDomain",WebGUI::International::get(7,'Auth/SMB'),$domain);
	$f->text("authSMB.smbLogin",WebGUI::International::get(8,'Auth/SMB'),$login);
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 addUserFormSave ( )

  Saves user elements unique to this authentication method

=cut

sub addUserFormSave {
   my $self = shift;
   my $properties;
   $properties->{smbPDC} = $session{form}{'authSMB.smbPDC'};
   $properties->{smbBDC} = $session{form}{'authSMB.smbBDC'};
   $properties->{smbDomain} = $session{form}{'authSMB.smbDomain'};
   $properties->{smbLogin} = $session{form}{'authSMB.smbLogin'};
   $self->SUPER::addUserFormSave($properties); 
}

#-------------------------------------------------------------------
sub authenticate {
    my $self = shift;
	my ($smb, $error);
	return 0 if !$self->SUPER::authenticate($_[0]);  #authenticate that the username entered actually exists and is active
	
	my $userId = $self->userId;
   	my $password = $_[1];
	my $userData = $self->getParams;
    if($userData->{smbLogin}){
	   $smb = Authen::Smb::authen($userData->{smbLogin}, $password, $userData->{smbPDC}, $userData->{smbBDC}, $userData->{smbDomain});
	   $error .= "<li>".$smbError{$smb} if($smb > 0);
	}else{
	   $error .= "<li>".WebGUI::International::get(5,'Auth/SMB');
	}
    $self->error($error);
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
   $vars->{'create.form.loginId'} = WebGUI::Form::text({"name"=>"authSMB.loginId","value"=>$session{form}{"authSMB.loginId"}});
   $vars->{'create.form.loginId.label'} = WebGUI::International::get(8,'Auth/SMB');
   $vars->{'create.form.password'} = WebGUI::Form::password({"name"=>"authSMB.identifier","value"=>$session{form}{"authSMB.identifier"}});
   $vars->{'create.form.password.label'} = WebGUI::International::get(9,'Auth/SMB');
   $vars->{'create.form.hidden'} = WebGUI::Form::hidden({"name"=>"confirm","value"=>$session{form}{confirm}});
   return $self->SUPER::createAccount("createAccountSave",$vars);
}

#-------------------------------------------------------------------
sub createAccountSave {
   my $self = shift;
   my ($pdc, $bdc, $ntDomain, $smbLogin, $smb, $error,$username,$properties);
   $pdc = $session{setting}{smbPDC};
   $bdc = $session{setting}{smbBDC};
   $ntDomain = $session{setting}{smbDomain};
   $username = $session{form}{'authSMB.loginId'};
   #Validate SMB Info
   $smb = Authen::Smb::authen($username, $session{form}{'authSMB.smbPassword'}, $pdc, $bdc, $ntDomain);
   if ($smb > 0) {
      return $self->createAccount('<li>'. $smbError{$smb} . "pdc: $pdc, bdc: $bdc, domain: $ntDomain");
   }
   
   #Check that username is valid and not a duplicate in the system.
   $error .= $self->error if($self->_isDuplicateUsername($username));
   $error .= $self->error if(!$self->_isValidUsername($username));
   #Validate profile data.
   my ($profile, $temp, $warning) = WebGUI::Operation::Profile::validateProfileData();
   $error .= $temp;
   return $self->createAccount("<h1>".WebGUI::International::get(70)."</h1>".$error) unless ($error eq "");
   #If Email address is not unique, a warning is displayed
   if($warning ne "" && !$session{form}{confirm}){
      $session{form}{confirm} = 1;
      return $self->createAccount('<li>'.WebGUI::International::get(1078));
   }
   
   $properties->{smbPDC} = $session{setting}{smbPDC};
   $properties->{smbBDC} = $session{setting}{smbBDC};
   $properties->{smbDomain} = $session{setting}{smbDomain};
   $properties->{smbLogin} = $username;
   
   return $self->SUPER::createAccountSave($username,$properties,$session{form}{'authSMB.smbPassword'},$profile);
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
   return WebGUI::Template::process(WebGUI::Template::get(1,'Auth/SMB/Account'), $vars);
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
   $f->text("smbPDC",WebGUI::International::get(5,'Auth/SMB'),$session{setting}{smbPDC});
   $f->text("smbBDC",WebGUI::International::get(6,'Auth/SMB'),$session{setting}{smbBDC});
   $f->text("smbDomain",WebGUI::International::get(7,'Auth/SMB'),$session{setting}{smbDomain});
   $f->yesNo(
             -name=>"smbSendWelcomeMessage",
             -value=>$session{setting}{smbSendWelcomeMessage},
             -label=>WebGUI::International::get(868)
             );
   $f->textarea(
                -name=>"smbWelcomeMessage",
                -value=>$session{setting}{smbWelcomeMessage},
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
