package WebGUI::Operation::Account;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Digest::MD5 qw(md5_base64);
use Exporter;
use Net::LDAP;
use strict;
use URI;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Mail;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_createAccount &www_deactivateAccount &www_deactivateAccountConfirm &www_displayAccount &www_displayLogin &www_login &www_logout &www_recoverPassword &www_recoverPasswordFinish &www_saveAccount &www_updateAccount);
our %ldapStatusCode = ( 0=>'success (0)', 1=>'Operations Error (1)', 2=>'Protocol Error (2)', 3=>'Time Limit Exceeded (3)', 4=>'Size Limit Exceeded (4)', 5=>'Compare False (5)', 6=>'Compare True (6)', 7=>'Auth Method Not Supported (7)', 8=>'Strong Auth Required (8)', 9=>'Referral (10)', 11=>'Admin Limit Exceeded (11)', 12=>'Unavailable Critical Extension (12)', 13=>'Confidentiality Required (13)', 14=>'Sasl Bind In Progress (14)', 15=>'No Such Attribute (16)', 17=>'Undefined Attribute Type (17)', 18=>'Inappropriate Matching (18)', 19=>'Constraint Violation (19)', 20=>'Attribute Or Value Exists (20)', 21=>'Invalid Attribute Syntax (21)', 32=>'No Such Object (32)', 33=>'Alias Problem (33)', 34=>'Invalid DN Syntax (34)', 36=>'Alias Dereferencing Problem (36)', 48=>'Inappropriate Authentication (48)', 49=>'Invalid Credentials (49)', 50=>'Insufficient Access Rights (50)', 51=>'Busy (51)', 52=>'Unavailable (52)', 53=>'Unwilling To Perform (53)', 54=>'Loop Detect (54)', 64=>'Naming Violation (64)', 65=>'Object Class Violation (65)', 66=>'Not Allowed On Non Leaf (66)', 67=>'Not Allowed On RDN (67)', 68=>'Entry Already Exists (68)', 69=>'Object Class Mods Prohibited (69)', 71=>'Affects Multiple DSAs (71)', 80=>'other (80)');

#-------------------------------------------------------------------
sub _hasBadPassword {
	if ($_[0] ne $_[1] || $_[0] eq "") {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------
sub _hasBadUsername {
	my ($otherUser);
	($otherUser) = WebGUI::SQL->quickArray("select username from users where lcase(username)=lcase('$_[0]')",$session{dbh});
	if (($otherUser ne "" && $otherUser ne $session{user}{username}) || $_[0] eq "") {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------
sub _login {
	my ($cookieInfo);
	$cookieInfo = $_[0]."|".crypt($_[1],"yJ");
	WebGUI::Session::end($cookieInfo); #clearing out old session info just in case something bad happened
	if (WebGUI::Session::start($cookieInfo)) {
		WebGUI::Session::setCookie("wgSession",$cookieInfo);
		return "";
	} else {
		WebGUI::ErrorHandler::warn("Session signature '".$cookieInfo."' does not match account info for user ID ".$_[0]);
		return "<b>Error:</b> Unable to initialize session vars because your session signature does not match your account information.<p>";
	}
}

#-------------------------------------------------------------------
sub www_createAccount {
	my ($output, %language);
	if ($session{user}{userId} != 1) {
                $output .= www_displayAccount();
	} elsif ($session{setting}{anonymousRegistration} eq "no") {
		$output .= www_displayLogin();
        } else {
		$output .= '<h1>'.WebGUI::International::get(54).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'"> ';
		$output .= WebGUI::Form::hidden("op","saveAccount");
		$output .= '<table>';
		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.WebGUI::Form::text("username",20,30).'</td></tr>';
		if ($session{setting}{authMethod} eq "LDAP") {
			$output .= WebGUI::Form::hidden("identifier1","ldap-password");
			$output .= WebGUI::Form::hidden("identifier2","ldap-password");
			$output .= '<tr><td class="formDescription">'.$session{setting}{ldapIdName}.'</td><td>'.WebGUI::Form::text("ldapId",20,100).'</td></tr>';
			$output .= '<tr><td class="formDescription">'.$session{setting}{ldapPasswordName}.'</td><td>'.WebGUI::Form::password("ldapPassword",20,100).'</td></tr>';
		} else {
			$output .= '<tr><td class="formDescription">'.WebGUI::International::get(51).'</td><td>'.WebGUI::Form::password("identifier1",20,30).'</td></tr>';
			$output .= '<tr><td class="formDescription">'.WebGUI::International::get(55).'</td><td>'.WebGUI::Form::password("identifier2",20,30).'</td></tr>';
		}
		$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(56).'</td><td>'.WebGUI::Form::text("email",20,255).'<span class="formSubtext"><br>'.WebGUI::International::get(57).'</span></td></tr>';
		%language = WebGUI::SQL->buildHash("select distinct(language) from international",$session{dbh});
		$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(304).'</td><td>'.WebGUI::Form::selectList("language",\%language).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
		$output .= '</table>';
		$output .= '</form> ';
		$output .= '<div class="accountOptions"><ul>';
		$output .= '<li><a href="'.$session{page}{url}.'?op=displayLogin">'.WebGUI::International::get(58).'</a>';
		if ($session{setting}{authMethod} eq "WebGUI") {
			$output .= '<li><a href="'.$session{page}{url}.'?op=recoverPassword">'.WebGUI::International::get(59).'</a>';
		}
		$output .= '</ul></div>';
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_deactivateAccount {
        my ($output);
        if ($session{user}{userId} == 1) {
                $output .= www_displayLogin();
        } else {
                $output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(60).'<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deactivateAccountConfirm">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'">'.WebGUI::International::get(45).'</a></div>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deactivateAccountConfirm {
        if ($session{user}{userId} != 1) {
                WebGUI::SQL->write("delete from users where userId=$session{user}{userId}",$session{dbh});
                WebGUI::SQL->write("delete from groupings where userId=$session{user}{userId}",$session{dbh});
	        WebGUI::Session::end($session{var}{sessionId});
        	_login(1,"null");
        }
        return www_displayLogin();
}

#-------------------------------------------------------------------
sub www_displayAccount {
        my ($output, %hash, @array);
	if ($session{user}{userId} != 1) {
        	$output .= '<h1>'.WebGUI::International::get(61).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'"> ';
        	$output .= WebGUI::Form::hidden("op","updateAccount");
        	$output .= '<table>';
        	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.WebGUI::Form::text("username",20,30,$session{user}{username}).'</td></tr>';
		if ($session{user}{authMethod} eq "LDAP") {
        		$output .= WebGUI::Form::hidden("identifier","password");
		} else {
        		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(51).'</td><td>'.WebGUI::Form::password("identifier1",20,30,"password").'</td></tr>';
        		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(55).'</td><td>'.WebGUI::Form::password("identifier2",20,30,"password").'</td></tr>';
		}
        	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(56).'</td><td>'.WebGUI::Form::text("email",20,255,$session{user}{email}).'<span class="formSubtext"><br>'.WebGUI::International::get(57).'</span></td></tr>';
		%hash = WebGUI::SQL->buildHash("select distinct(language) from international",$session{dbh});
		$array[0] = $session{user}{language};
        	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(304).'</td><td>'.WebGUI::Form::selectList("language",\%hash,\@array).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
        	$output .= '</table>';
        	$output .= '</form> ';
		$output .= '<div class="accountOptions"><ul>';
		if (WebGUI::Privilege::isInGroup(3) || WebGUI::Privilege::isInGroup(4)) {
			if ($session{var}{adminOn}) {
				$output .= '<li><a href="'.$session{page}{url}.'?op=switchOffAdmin">'.WebGUI::International::get(12).'</a>';
			} else {
				$output .= '<li><a href="'.$session{page}{url}.'?op=switchOnAdmin">'.WebGUI::International::get(63).'</a>';
			}
		}
		$output .= '<li><a href="'.$session{page}{url}.'?op=logout">'.WebGUI::International::get(64).'</a>';
		$output .= '<li><a href="'.$session{page}{url}.'?op=deactivateAccount">'.WebGUI::International::get(65).'</a></ul></div>';
        } else {
                $output .= www_displayLogin();
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_displayLogin {
	my ($output);
	if ($session{var}{sessionId}) {
		$output .= www_displayAccount();
	} else {
        	$output .= '<h1>'.WebGUI::International::get(66).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'"> ';
		$output .= WebGUI::Form::hidden("op","login");
		$output .= '<table>';
        	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.WebGUI::Form::text("username",20,30).'</td></tr>';
        	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(51).'</td><td>'.WebGUI::Form::password("identifier",20,30).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(52)).'</td></tr>';
		$output .= '</table>';
		$output .= '</form>';
		$output .= '<div class="accountOptions"><ul>';
		if ($session{setting}{anonymousRegistration} eq "yes") {
			$output .= '<li><a href="'.$session{page}{url}.'?op=createAccount">'.WebGUI::International::get(67).'</a>';
		}
		if ($session{setting}{authMethod} eq "WebGUI") {
			$output .= '<li><a href="'.$session{page}{url}.'?op=recoverPassword">'.WebGUI::International::get(59).'</a>';
		}
		$output .= '</ul></div>';
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_login {
	my ($uri, $port, $ldap, %args, $auth, $error, $uid,$pass,$authMethod, $ldapURL, $connectDN, $success);
	($uid,$pass,$authMethod, $ldapURL, $connectDN) = WebGUI::SQL->quickArray("select userId,identifier,authMethod,ldapURL,connectDN from users where username=".quote($session{form}{username}),$session{dbh});
	if ($authMethod eq "LDAP") {
                $uri = URI->new($ldapURL);
                if ($uri->port < 1) {
                        $port = 389;
                } else {
                        $port = $uri->port;
                }
                %args = (port => $port);
                $ldap = Net::LDAP->new($uri->host, %args) or $error = WebGUI::International::get(79);
                $auth = $ldap->bind($connectDN, $session{form}{identifier});
                $ldap->unbind;
                if ($auth->code == 48 || $auth->code == 49) {
			$error = WebGUI::International::get(68);
			WebGUI::ErrorHandler::warn("Invalid login for user account: ".$session{form}{username});
		} elsif ($auth->code > 0) {
			$error .= 'LDAP error "'.$ldapStatusCode{$auth->code}.'" occured.';
			$error .= WebGUI::International::get(69);
			WebGUI::ErrorHandler::warn("LDAP error: ".$ldapStatusCode{$auth->code});
		} else {
			$success = 1;
		}
	} else {
		if (Digest::MD5::md5_base64($session{form}{identifier}) eq $pass && $session{form}{identifier} ne "") {
			$success = 1;
		} else {
			$error = WebGUI::International::get(68);
			WebGUI::ErrorHandler::warn("Invalid login for user account: ".$session{form}{username});
		}
	}
	if ($success) {
		_login($uid,$pass);
		return "";
	} else {
		return "<h1>".WebGUI::International::get(70)."</h1>".$error.www_displayLogin();
	}
}

#-------------------------------------------------------------------
sub www_logout {
	WebGUI::Session::end($session{var}{sessionId});
        #_login(1,"null");
	return "";
}

#-------------------------------------------------------------------
sub www_recoverPassword {
	my ($output);
        if ($session{var}{sessionId}) {
                $output .= www_displayAccount();
        } else {
                $output .= '<h1>'.WebGUI::International::get(71).'</h1>';
		$output .= '<form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","recoverPasswordFinish");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(56).'</td><td>'.WebGUI::Form::text("email",20,255).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(72)).'</td></tr>';
                $output .= '</table>';
                $output .= '</form>';
                $output .= '<div class="accountOptions"><ul>';
		if ($session{setting}{anonymousRegistration} eq "yes") {
			$output .= '<li><a href="'.$session{page}{url}.'?op=createAccount">'.WebGUI::International::get(67).'</a>';
		}
		$output .= '<li><a href="'.$session{page}{url}.'?op=displayLogin">'.WebGUI::International::get(73).'</a>';
		$output .= '</ul></div>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_recoverPasswordFinish {
	my ($sth, $username, $encryptedPassword, $userId, $password, $flag, $message, $output);
	$sth = WebGUI::SQL->read("select username, userId from users where email=".quote($session{form}{email}),$session{dbh});
	while (($username,$userId) = $sth->array) {
	        foreach (0,1,2,3,4,5) {
        	        $password .= chr(ord('A') + randint(32));
        	}
        	$encryptedPassword = Digest::MD5::md5_base64($password);
		WebGUI::SQL->write("update users set identifier='$encryptedPassword' where userId='$userId'",$session{dbh});
		$flag = 1;
		$message = $session{setting}{recoverPasswordEmail};
		$message .= "\n".WebGUI::International::get(50).": ".$username."\n";
		$message .= WebGUI::International::get(51).": ".$password."\n";
		WebGUI::Mail::send($session{form}{email},WebGUI::International::get(74),$message);	
	}
	$sth->finish();
	if ($flag) {
		$output = '<ul><li>'.WebGUI::International::get(75).'</ul>';
		$output .= www_displayLogin();
	} else {
		$output = '<ul><li>'.WebGUI::International::get(76).'</ul>';
		$output .= www_recoverPassword();
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_saveAccount {
	my ($uri, $ldap, $port, %args, $search, $connectDN, $auth, $output, $error, $uid, $encryptedPassword);
	if (_hasBadUsername($session{form}{username})) {
		$error = WebGUI::International::get(77);
		$error .= ' "'.$session{form}{username}.'too", ';
		$error .= '"'.$session{form}{username}.'2", ';
		$error .= '"'.$session{form}{username}.'_'.WebGUI::DateTime::epochToHuman(time(),"%y").'"';
		$error .= '<p>';
	}
	if (_hasBadPassword($session{form}{identifier1},$session{form}{identifier2})) {
		$error .= WebGUI::International::get(78);
	}
	if ($session{setting}{authMethod} eq "LDAP") {
		$uri = URI->new($session{setting}{ldapURL});
		if ($uri->port < 1) {
			$port = 389;
		} else {
			$port = $uri->port;
		}
		%args = (port => $port);
		$ldap = Net::LDAP->new($uri->host, %args) or $error .= WebGUI::International::get(79);
		$ldap->bind;
		$search = $ldap->search (base => $uri->dn, filter => $session{setting}{ldapId}."=".$session{form}{ldapId});
		$connectDN = "cn=".$search->entry(0)->get_value("cn");
		$ldap->unbind;
		$ldap = Net::LDAP->new($uri->host, %args) or $error .= WebGUI::International::get(79);
		$auth = $ldap->bind(dn=>$connectDN, password=>$session{form}{ldapPassword});
		if ($auth->code == 48 || $auth->code == 49) {
			$error .= WebGUI::International::get(68);
			WebGUI::ErrorHandler::warn("Invalid LDAP information for registration of LDAP ID: ".$session{form}{ldapId});
		} elsif ($auth->code > 0) {
			$error .= 'LDAP error "'.$ldapStatusCode{$auth->code}.'" occured. '.WebGUI::International::get(69);
			WebGUI::ErrorHandler::warn("LDAP error: ".$ldapStatusCode{$auth->code});
		}
		$ldap->unbind;
	}
	if ($error eq "") {
		$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
		$uid = getNextId("userId");
		WebGUI::SQL->write("insert into users (userId,username,identifier,email,authMethod,ldapURL,connectDN,language) values ($uid, ".quote($session{form}{username}).", ".quote($encryptedPassword).", ".quote($session{form}{email}).", ".quote($session{setting}{authMethod}).", ".quote($session{setting}{ldapURL}).", ".quote($connectDN).", ".quote($session{form}{language}).")",$session{dbh});
		WebGUI::SQL->write("insert into groupings values (2,$uid)",$session{dbh});
		_login($uid,$encryptedPassword);
		$output .= WebGUI::International::get(80).'<p>';
		$output .= www_displayAccount();
	} else {
		$output = "<h1>".WebGUI::International::get(70)."</h1>".$error.www_createAccount();
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_updateAccount {
        my ($output, $error, $encryptedPassword, $passwordStatement);
        if ($session{var}{sessionId}) {
        	if (_hasBadUsername($session{form}{username})) {
                	$error = WebGUI::International::get(77);
			$error .= ' "'.$session{form}{username}.'too", ';
                	$error .= '"'.$session{form}{username}.'2", ';
                	$error .= '"'.$session{form}{username}.'_'.WebGUI::DateTime::epochToHuman(time(),"%y").'"';
			$error .= '<p>';
        	}
        	if ($session{form}{identifier1} ne "password" && _hasBadPassword($session{form}{identifier1},$session{form}{identifier2})) {
                	$error .= WebGUI::International::get(78).'<p>';
        	} else {
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
			$passwordStatement = ', identifier='.quote($encryptedPassword);
		}
        	if ($error eq "") {
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
                	WebGUI::SQL->write("update users set username=".quote($session{form}{username}).$passwordStatement.", email=".quote($session{form}{email}).", language=".quote($session{form}{language})." where userId=".$session{user}{userId},$session{dbh});
			if ($passwordStatement ne "") {
                		_login($session{user}{userId},$encryptedPassword);
			}
                	$output .= WebGUI::International::get(81).'<p>';
                	$output .= www_displayAccount();
        	} else {
                	$output = $error;
                	$output .= www_createAccount();
        	}
	} else {
		$output .= www_displayLogin();
	}
        return $output;
}

1;

