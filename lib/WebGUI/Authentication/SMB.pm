package WebGUI::Authentication::SMB;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------~
   
use strict;
use WebGUI::Session; 
use WebGUI::HTMLForm;
use WebGUI::Authentication;
use Authen::Smb;
use warnings;

my %smbError = (
	1 => WebGUI::International::get(2,'Auth/SMB'),
	2 => WebGUI::International::get(3,'Auth/SMB'),
	3 => WebGUI::International::get(4,'Auth/SMB')
);

#-------------------------------------------------------------------
sub authenticate {
        my ($userId, $password, $userData, $smb, $result);
        $userId = $_[0]->[0];
        $password = $_[0]->[1];
        $userData = WebGUI::Authentication::getParams($userId, 'SMB');
        return "<li>No SMB username specfified." unless ($userData->{smbLogin});
        $smb = Authen::Smb::authen($userData->{smbLogin}, $password, $userData->{smbPDC}, $userData->{smbBDC}, $userData->{smbDomain});
        if ($smb > 0) {
                return '<li>'. $smbError{$smb};
        } else {
                return 1;
        }
}
                                                                                                                                                             
#-------------------------------------------------------------------
sub adminForm {
	my $userData = WebGUI::Authentication::getParams($_[0], 'SMB');
	my $pdc = $session{form}{'authSMB.smbPDC'} || $userData->{smbPDC} || $session{setting}{smbPDC};
	my $bdc = $session{form}{'authSMB.smbBDC'} || $userData->{smbBDC} || $session{setting}{smbBDC};
	my $domain = $session{form}{'authSMB.smbDomain'} || $userData->{smbDomain} || $session{setting}{smbDomain};
	my $login = $session{form}{'authSMB.smbLogin'} || $userData->{smbLogin};
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->readOnly('<b>'.optionsLabel().'</b>');
	$f->text("authSMB.smbPDC",WebGUI::International::get(5,'Auth/SMB'),$pdc);
	$f->text("authSMB.smbBDC",WebGUI::International::get(6,'Auth/SMB'),$bdc);
	$f->text("authSMB.smbDomain",WebGUI::International::get(7,'Auth/SMB'),$domain);
	$f->text("authSMB.smbLogin",WebGUI::International::get(8,'Auth/SMB'),$login);
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub adminFormSave {
	WebGUI::Authentication::saveParams($session{form}{uid},'SMB', 
	{
		smbPDC 		=> $session{form}{'authSMB.smbPDC'}, 
		smbBDC 		=> $session{form}{'authSMB.smbBDC'},
		smbDomain 	=> $session{form}{'authSMB.smbDomain'},
		smbLogin 	=> $session{form}{'authSMB.smbLogin'}
	});
}

#-------------------------------------------------------------------
sub optionsLabel {
	return WebGUI::International::get(1,'Auth/SMB');
}

#-------------------------------------------------------------------
sub registrationForm {
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->text("authSMB.loginId",WebGUI::International::get(8,'Auth/SMB'));
	$f->password("authSMB.smbPassword",WebGUI::International::get(9,'Auth/SMB'));
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub registrationFormSave {
	my $uid;
	$uid = shift; 
	WebGUI::Authentication::saveParams($uid,'SMB', 
	{
		smbPDC 		=> $session{setting}{smbPDC}, 
		smbBDC 		=> $session{setting}{smbBDC},
		smbDomain 	=> $session{setting}{smbDomain},
		smbLogin 	=> $session{form}{'authSMB.loginId'}
	});
}

#-------------------------------------------------------------------
sub registrationFormValidate {
	my ($pdc, $bdc, $ntDomain, $smbLogin, $smb, $error);
        $pdc = $session{setting}{smbPDC};
       	$bdc = $session{setting}{smbBDC};
        $ntDomain = $session{setting}{smbDomain};
        $smbLogin = $session{form}{'authSMB.loginId'};
        $smb = Authen::Smb::authen($smbLogin, $session{form}{'authSMB.smbPassword'}, $pdc, $bdc, $ntDomain);
        if ($smb > 0) {
                $error = '<li>'. $smbError{$smb} . "pdc: $pdc, bdc: $bdc, domain: $ntDomain";
        }
       	return ($session{form}{'authSMB.loginId'}, $error);
}


#-------------------------------------------------------------------
sub settingsForm {
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->readOnly('<b>'.optionsLabel().'</b>');
	$f->text("smbPDC",WebGUI::International::get(5,'Auth/SMB'),$session{setting}{smbPDC});
	$f->text("smbBDC",WebGUI::International::get(6,'Auth/SMB'),$session{setting}{smbBDC});
	$f->text("smbDomain",WebGUI::International::get(7,'Auth/SMB'),$session{setting}{smbDomain});
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub userForm {
	return undef;
}

#-------------------------------------------------------------------
sub userFormSave {
}

#-------------------------------------------------------------------
sub userFormValidate {
	return ($session{user}{username},"");
}

1;

