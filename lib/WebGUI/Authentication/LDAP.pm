package WebGUI::Authentication::LDAP;

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
use WebGUI::HTMLForm;
use WebGUI::Authentication;
use URI;
use Net::LDAP;

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
sub authenticate {
	my ($userId, $password, $userData, $uri, $port, %args, $ldap, $auth, $result);
	$userId = $_[0]->[0];
        my $identifier = $_[0]->[1];
	$userData = WebGUI::Authentication::getParams($userId, 'LDAP');
	$uri = URI->new($userData->{ldapURL});
	if ($uri->port < 1) {
		$port = 389;
	} else {
        	$port = $uri->port;
        }
        %args = (port => $port);
        $ldap = Net::LDAP->new($uri->host, %args) or $result = WebGUI::International::get(2,'Auth/LDAP');
	return $result if $result;
        $auth = $ldap->bind(dn=>$$userData{connectDN}, password=>$identifier);
                if ($auth->code == 48 || $auth->code == 49) {
			$result = WebGUI::International::get(68);
		} elsif ($auth->code > 0) {
			$result .= 'LDAP error "'.$ldapStatusCode{$auth->code}.'" occured.';
			$result .= WebGUI::International::get(69);
			WebGUI::ErrorHandler::warn("LDAP error: ".$ldapStatusCode{$auth->code});
		} else {
			$result = 1;
		}
                $ldap->unbind;
	return $result;
}

#-------------------------------------------------------------------
sub adminForm {
	my $userData = WebGUI::Authentication::getParams($_[0],'LDAP');
	my $ldapURL = $session{form}{authLDAP.ldapURL} || $userData->{ldapURL} || $session{setting}{ldapURL};
	my $connectDN = $session{form}{authLDAP.connectDN} || $userData->{connectDN};
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->readOnly('<b>'.optionsLabel().'</b>');
	$f->url("authLDAP.ldapURL",WebGUI::International::get(3,'Auth/LDAP'),$ldapURL);
	$f->text("authLDAP.connectDN",WebGUI::International::get(4,'Auth/LDAP'),$connectDN);
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub adminFormSave {
	WebGUI::Authentication::saveParams($_[0],'LDAP',
	{
		connectDN 	=> $session{form}{authLDAP.connectDN}, 
		ldapURL 	=> $session{form}{authLDAP.ldapURL}
	});
}

#-------------------------------------------------------------------
sub adminFormValidate {
	return "";
}

#-------------------------------------------------------------------
sub optionsLabel {
	return WebGUI::International::get(1,'Auth/LDAP');
}

#-------------------------------------------------------------------
sub registrationForm {
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->text("authLDAP.ldapId",$session{setting}{ldapIdName});
	$f->password("authLDAP.ldapPassword",$session{setting}{ldapPasswordName});
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub registrationFormSave { 
	my($uri, $port, %args, $ldap, $auth, $search, $connectDN, $uid);
	my $uid = shift;
	$uri = URI->new($session{setting}{ldapURL});
	if ($uri->port < 1) {
		$port = 389;
	} else {
		$port = $uri->port;
	}
	%args = (port => $port);
	$ldap = Net::LDAP->new($uri->host, %args);
	$ldap->bind;
	$search = $ldap->search (base => $uri->dn, filter => $session{setting}{ldapId}."=".$session{form}{authLDAP.ldapId});
	if (defined $search->entry(0)) {
		$connectDN = "cn=".$search->entry(0)->get_value("cn");
	}
	$ldap->unbind;
	WebGUI::Authentication::saveParams($uid,'LDAP',
	{
		connectDN 	=> $connectDN, 
		ldapURL 	=> $session{setting}{ldapURL}
	});
	return $session{form}{authLDAP.ldapId};
}

#-------------------------------------------------------------------
sub registrationFormValidate {
	my ($uri, $error, $ldap, $port, $search, $auth, $connectDN);
	$uri = URI->new($session{setting}{ldapURL});
        if ($uri->port < 1) {
                $port = 389;
        } else {
                $port = $uri->port;
        }
	if ($ldap = Net::LDAP->new($uri->host, {port=>$port})) {
        	if ($ldap->bind) {
        		$search = $ldap->search (base=>$uri->dn,filter=>$session{setting}{ldapId}."=".$session{form}{authLDAP.ldapId});
        		if (defined $search->entry(0)) {
                		$connectDN = "cn=".$search->entry(0)->get_value("cn");
                		$ldap->unbind;
                		$ldap = Net::LDAP->new($uri->host, {port=>$port}) or $error .= WebGUI::International::get(2,'Auth/LDAP');
                		$auth = $ldap->bind(dn=>$connectDN, password=>$session{form}{authLDAP.ldapPassword});
                		if ($auth->code == 48 || $auth->code == 49) {
                        		$error .= '<li>'.WebGUI::International::get(68);
                        		WebGUI::ErrorHandler::warn("Invalid LDAP information for registration of LDAP ID: ".$session{form}{authLDAP.ldapId});
                		} elsif ($auth->code > 0) {
                        		$error .= '<li>LDAP error "'.$ldapStatusCode{$auth->code}.'" occured. '
						.WebGUI::International::get(69);
                        		WebGUI::ErrorHandler::warn("LDAP error: ".$ldapStatusCode{$auth->code});
                		}
                		$ldap->unbind;
        		} else {
                		$error .= '<li>'.WebGUI::International::get(68);
                		WebGUI::ErrorHandler::warn("Invalid LDAP information for registration of LDAP ID: ".$session{form}{authLDAP.ldapId});
        		}
		} else {
			$error = WebGUI::International::get(2,'Auth/LDAP');
		}
	} else {
		$error = WebGUI::International::get(2,'Auth/LDAP');
	}
	return $error;
}

#-------------------------------------------------------------------
sub settingsForm {
	my $f;
	$f = WebGUI::HTMLForm->new;
	$f->readOnly('<b>'.optionsLabel().'</b>');
	$f->url("authLDAP.ldapURL",WebGUI::International::get(5,'Auth/LDAP'),$session{setting}{ldapURL});
        $f->text("authLDAP.ldapId",WebGUI::International::get(6,'Auth/LDAP'),$session{setting}{ldapId});
        $f->text("authLDAP.ldapIdName",WebGUI::International::get(7,'Auth/LDAP'),$session{setting}{ldapIdName});
        $f->text("authLDAP.ldapPasswordName",WebGUI::International::get(8,'Auth/LDAP'),$session{setting}{ldapPasswordName});
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub userForm {
	return "";
}

#-------------------------------------------------------------------
sub userFormSave {
}

#-------------------------------------------------------------------
sub userFormValidate {
	return "";
}

1;
