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

use Digest::MD5;
use strict;
use WebGUI::Session;
use WebGUI::Authentication;
use WebGUI::HTMLForm;


#-------------------------------------------------------------------
sub authenticate {
	my ($userId, $identifier, $userData, $success);
	$userId = $_[0]->[0];
	$identifier = $_[0]->[1];
	$userData = WebGUI::Authentication::getParams($userId, 'WebGUI');
	if ((Digest::MD5::md5_base64($identifier) eq $$userData{identifier}) && ($identifier ne "")) {
		$success = 1;
	} else {
		$success = WebGUI::International::get(68);
	}
	return $success;
}


#-------------------------------------------------------------------
sub adminForm {
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->readOnly('<b>'.optionsLabel().'</b>');
	$f->password("authWebGUI.identifier",WebGUI::International::get(51),"password");
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub adminFormSave {
	unless ($session{form}{'authWebGUI.identifier'} eq "password") {
		WebGUI::Authentication::saveParams($_[0],'WebGUI',{identifier => Digest::MD5::md5_base64($session{form}{'authWebGUI.identifier'})});
	}
}

#-------------------------------------------------------------------
sub adminFormValidate {
	return "";
}

#-------------------------------------------------------------------
sub optionsLabel {
        return WebGUI::International::get(1,'Auth/WebGUI');
}

#-------------------------------------------------------------------
sub registrationForm {
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->password("authWebGUI.identifier",WebGUI::International::get(51));
	$f->password("authWebGUI.identifierConfirm",WebGUI::International::get(2,'Auth/WebGUI'));
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub registrationFormSave {
	adminFormSave($_[0]);
}

#-------------------------------------------------------------------
sub registrationFormValidate {
	my ($error);
        if ($session{form}{'authWebGUI.identifier'} ne $session{form}{'authWebGUI.identifierConfirm'}) {
                $error = '<li>'.WebGUI::International::get(3,'Auth/WebGUI');
        }
        if ($session{form}{'authWebGUI.identifier'} eq "password") {
                $error .= '<li>'.WebGUI::International::get(5,'Auth/WebGUI');
        }
        if ($session{form}{'authWebGUI.identifier'} eq "") {
                $error .= '<li>'.WebGUI::International::get(4,'Auth/WebGUI');
        }
        return $error;
}

#-------------------------------------------------------------------
sub settingsForm {
	return "";
}

#-------------------------------------------------------------------
sub userForm {
        my $f;
        $f = WebGUI::HTMLForm->new;
        $f->password("authWebGUI.identifier",WebGUI::International::get(51),"password");
        $f->password("authWebGUI.identifierConfirm",WebGUI::International::get(2,'Auth/WebGUI'),"password");
        return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub userFormSave {
	adminFormSave($session{user}{userId});
}

#-------------------------------------------------------------------
sub userFormValidate {
        my ($error);
        if ($session{form}{'authWebGUI.identifier'} ne $session{form}{'authWebGUI.identifierConfirm'}) {
                $error = '<li>'.WebGUI::International::get(3,'Auth/WebGUI');
        }
        if ($session{form}{'authWebGUI.identifier'} eq "") {
                $error .= '<li>'.WebGUI::International::get(4,'Auth/WebGUI');
        }
        return $error;
}


1;

