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
	1 => 'SMB Server Error (1)<br>Something went wrong accessing the domain controller. Perhaps the connection timed out. Please try again or contact your sysadmin.',
	2 => 'SMB Protocol Error (2)<br>Please contact your sysadmin',
	3 => 'SMB Logon Error (3)<br>You have supplied an invalid username/password pair. Probably a typo, please try again.'
);

#-------------------------------------------------------------------
sub hasBadUserData {
	my ($pdc, $bdc, $ntDomain, $smbLogin, $smb, $error);

	$pdc = $session{setting}{smbPDC};
	$bdc = $session{setting}{smbBDC};
	$ntDomain = $session{setting}{smbDomain};
	$smbLogin = $session{form}{loginId};
	$smb = Authen::Smb::authen($smbLogin, $session{form}{smbPassword}, $pdc, $bdc, $ntDomain);
	if ($smb > 0) {
		$error = '<li>'. $smbError{$smb} . "pdc: $pdc, bdc: $bdc, domain: $ntDomain";
	}

	return $error;
}

#-------------------------------------------------------------------
sub validateUser {
	my ($uid, $password, $userData, $smb, $result);

	($uid, $password) = @_;
	$userData = WebGUI::Authentication::getParams($uid, 'SMB');

	$smb = Authen::Smb::authen($userData->{smbLogin}, $password, $userData->{smbPDC}, $userData->{smbBDC}, $userData->{smbDomain});
	if ($smb > 0) {
		$result = '<li>'. $smbError{$smb} . <br> ."Login: *$userData->{smbLogin}, PDC: *$userData->{smbPDC}*, BDC: *$userData->{smbBDC}*, Domain: *$userData->{smbDomain}*";
	} else {
		$result = 1;
	}

	return $result;
}

#-------------------------------------------------------------------------
# Below are the subs that create and save the forms used for inputting 
# config data for this auth module. The 'form' and 'save' subs of each
# from are so related that I've grouped by function. Apart from the 
# 'save' and 'form' stuff the subs are still in alphabetical order though.
#-------------------------------------------------------------------------

#-------------------------------------------------------------------
sub formAddUser {
	my $f;

	$f = WebGUI::HTMLForm->new;
	$f->readOnly("<b>SMB Authentication Options</b>");
	$f->text("smbPDC","PDC",$session{setting}{smbPDC});
	$f->text("smbBDC","BDC",$session{setting}{smbBDC});
	$f->text("smbDomain","NT Domain",$session{setting}{smbDomain});
	$f->text("smbLogin","NT Login name",'');
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub saveAddUser {
	WebGUI::Authentication::saveParams($session{form}{uid},'SMB', 
	{
		smbPDC 		=> $session{form}{smbPDC}, 
		smbBDC 		=> $session{form}{smbBDC},
		smbDomain 	=> $session{form}{smbDomain},
		smbLogin 	=> $session{form}{smbLogin}
	});
}

#-------------------------------------------------------------------
sub formCreateAccount {
	my $f;

	$f = WebGUI::HTMLForm->new;
	$f->password("smbPassword","NT Password");
	
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub saveCreateAccount {
	my $uid;

	$uid = shift; 
	WebGUI::Authentication::saveParams($uid,'SMB', 
	{
		smbPDC 		=> $session{setting}{smbPDC}, 
		smbBDC 		=> $session{setting}{smbBDC},
		smbDomain 	=> $session{setting}{smbDomain},
		smbLogin 	=> $session{form}{loginId}
	});
}

#-------------------------------------------------------------------
sub formEditUserSettings {
	my $f;

	$f = WebGUI::HTMLForm->new;
	$f->readOnly("<b>SMB Authentication Options</b>");
	$f->text("smbPDC","PDC",$session{setting}{smbPDC});
	$f->text("smbBDC","BDC",$session{setting}{smbBDC});
	$f->text("smbDomain","NT Domain",$session{setting}{smbDomain});

	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub formEditUser {
	my ($f, $userData);
	$userData = WebGUI::Authentication::getParams($session{form}{uid}, 'SMB');

	$f = WebGUI::HTMLForm->new;
	$f->readOnly("<b>SMB Authentication Options</b>");
	$f->text("smbPDC","PDC",$$userData{smbPDC});
	$f->text("smbBDC","BDC",$$userData{smbBDC});
	$f->text("smbDomain","NT Domain",$$userData{smbDomain});
	$f->text("smbLogin","NT Login name",$$userData{smbLogin});

	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub saveEditUser {
	WebGUI::Authentication::saveParams($session{form}{uid},'SMB', 
	{
		smbPDC 		=> $session{form}{smbPDC}, 
		smbBDC 		=> $session{form}{smbBDC},
		smbDomain 	=> $session{form}{smbDomain},
		smbLogin 	=> $session{form}{smbLogin}
	});
}

1;
