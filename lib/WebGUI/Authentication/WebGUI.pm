package WebGUI::Authentication::WebGUI;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;
use WebGUI::Authentication;
use WebGUI::HTMLForm;
use Digest::MD5;

#-------------------------------------------------------------------
sub hasBadUserData {
	return WebGUI::Operation::Account::_hasBadPassword($session{form}{identifier1},$session{form}{identifier2});
}

#-------------------------------------------------------------------
sub validateUser {
	my ($userId, $identifier, $userData, $success);
	($userId, $identifier) = @_;

	$userData = WebGUI::Authentication::getParams($userId, 'WebGUI');
	if ((Digest::MD5::md5_base64($identifier) eq $$userData{identifier}) && ($identifier ne "")) {
		$success = 1;
	} else {
		$success = WebGUI::International::get(68);
		WebGUI::ErrorHandler::security("login to account ".$session{form}{username}." with invalid information.");
	}
	return $success;
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
	$f->readOnly("<b>WebGUI Authentication options</b>");
	$f->password("identifier",WebGUI::International::get(51));
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub saveAddUser {
	my $encryptedPassword;

	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
	WebGUI::Authentication::saveParams($session{form}{uid},'WebGUI',{identifier => $encryptedPassword});
}

#-------------------------------------------------------------------
sub formCreateAccount {
	my $f;

	$f = WebGUI::HTMLForm->new;
	$f->password("identifier1",WebGUI::International::get(51));
	$f->password("identifier2",WebGUI::International::get(55));
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub saveCreateAccount {
	my ($encryptedPassword, $uid);
 
	$uid = shift;
	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
	WebGUI::Authentication::saveParams($uid, 'WebGUI', {identifier => $encryptedPassword});
}

#-------------------------------------------------------------------
sub formEditUser {
	my $f;

	$f = WebGUI::HTMLForm->new;
	$f->readOnly('<b>WebGUI Authentication Options</b>');
	$f->password("identifier",WebGUI::International::get(51),"password");
}

#-------------------------------------------------------------------
sub saveEditUser {
	my ($encryptedPassword);

	if ($session{form}{identifier} ne "password") {
		$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
		WebGUI::Authentication::saveParams($session{form}{uid}, 'WebGUI', {identifier => $encryptedPassword});
	}
}

#-------------------------------------------------------------------
sub formEditUserSettings {
	return '';
}

1;
