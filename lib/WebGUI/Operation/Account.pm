package WebGUI::Operation::Account;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewMessageLog &www_viewProfile &www_editProfile &www_editProfileSave &www_createAccount &www_deactivateAccount &www_deactivateAccountConfirm &www_displayAccount &www_displayLogin &www_login &www_logout &www_recoverPassword &www_recoverPasswordFinish &www_createAccountSave &www_updateAccount);
our %ldapStatusCode = ( 0=>'success (0)', 1=>'Operations Error (1)', 2=>'Protocol Error (2)', 3=>'Time Limit Exceeded (3)', 4=>'Size Limit Exceeded (4)', 5=>'Compare False (5)', 6=>'Compare True (6)', 7=>'Auth Method Not Supported (7)', 8=>'Strong Auth Required (8)', 9=>'Referral (10)', 11=>'Admin Limit Exceeded (11)', 12=>'Unavailable Critical Extension (12)', 13=>'Confidentiality Required (13)', 14=>'Sasl Bind In Progress (14)', 15=>'No Such Attribute (16)', 17=>'Undefined Attribute Type (17)', 18=>'Inappropriate Matching (18)', 19=>'Constraint Violation (19)', 20=>'Attribute Or Value Exists (20)', 21=>'Invalid Attribute Syntax (21)', 32=>'No Such Object (32)', 33=>'Alias Problem (33)', 34=>'Invalid DN Syntax (34)', 36=>'Alias Dereferencing Problem (36)', 48=>'Inappropriate Authentication (48)', 49=>'Invalid Credentials (49)', 50=>'Insufficient Access Rights (50)', 51=>'Busy (51)', 52=>'Unavailable (52)', 53=>'Unwilling To Perform (53)', 54=>'Loop Detect (54)', 64=>'Naming Violation (64)', 65=>'Object Class Violation (65)', 66=>'Not Allowed On Non Leaf (66)', 67=>'Not Allowed On RDN (67)', 68=>'Entry Already Exists (68)', 69=>'Object Class Mods Prohibited (69)', 71=>'Affects Multiple DSAs (71)', 80=>'other (80)');

#-------------------------------------------------------------------
sub _accountOptions {
	my ($output);
	$output = '<div class="accountOptions"><ul>';
	if (WebGUI::Privilege::isInGroup(3) || WebGUI::Privilege::isInGroup(4) || WebGUI::Privilege::isInGroup(5) || WebGUI::Privilege::isInGroup(6)) {
		if ($session{var}{adminOn}) {
			$output .= '<li><a href="'.$session{page}{url}.'?op=switchOffAdmin">'.WebGUI::International::get(12).'</a>';
		} else {
			$output .= '<li><a href="'.$session{page}{url}.'?op=switchOnAdmin">'.WebGUI::International::get(63).'</a>';
		}
	}
	$output .= '<li><a href="'.$session{page}{url}.'?op=displayAccount">'.WebGUI::International::get(342).'</a>';
	$output .= '<li><a href="'.$session{page}{url}.'?op=editProfile">'.WebGUI::International::get(341).'</a>';
	$output .= '<li><a href="'.$session{page}{url}.'?op=viewProfile&uid='.$session{user}{userId}.'">'.WebGUI::International::get(343).'</a>';
	$output .= '<li><a href="'.$session{page}{url}.'?op=viewMessageLog">'.WebGUI::International::get(354).'</a>';
	$output .= '<li><a href="'.$session{page}{url}.'?op=logout">'.WebGUI::International::get(64).'</a>'; 
	$output .= '<li><a href="'.$session{page}{url}.'?op=deactivateAccount">'.WebGUI::International::get(65).'</a>';
	$output .= '</ul></div>';
	return $output;
}

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
	($otherUser) = WebGUI::SQL->quickArray("select username from users where username='$_[0]'");
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
	my ($output, %language, @array);
	if ($session{user}{userId} != 1) {
                $output .= www_displayAccount();
	} elsif ($session{setting}{anonymousRegistration} eq "no") {
		$output .= www_displayLogin();
        } else {
		$output .= '<h1>'.WebGUI::International::get(54).'</h1>';
		$output .= formHeader();
		$output .= WebGUI::Form::hidden("op","createAccountSave");
		$output .= '<table>';
		unless ($session{setting}{authMethod} eq "LDAP" && $session{setting}{usernameBinding} eq "yes") {
			$output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.WebGUI::Form::text("username",20,30).'</td></tr>';
		}
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
		%language = WebGUI::SQL->buildHash("select distinct(language) from international");
		$array[0] = "English";
		$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(304).'</td><td>'.WebGUI::Form::selectList("language",\%language,\@array).'</td></tr>';
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
sub www_createAccountSave {
        my ($username, $uri, $ldap, $port, %args, $search, $connectDN, $auth, $output, $error, $uid, $registeredUserExpire, $encryptedPassword);
        if ($session{setting}{authMethod} eq "LDAP" && $session{setting}{usernameBinding} eq "yes") {
                $username = $session{form}{ldapId};
        } else {
                $username = $session{form}{username};
        }
        if (_hasBadUsername($username)) {
                $error = WebGUI::International::get(77);
                $error .= ' "'.$username.'too", ';
                $error .= '"'.$username.'2", ';
                $error .= '"'.$username.'_'.WebGUI::DateTime::epochToHuman(time(),"%y").'"';
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
                if (defined $search->entry(0)) {
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
                } else {
                        $error .= WebGUI::International::get(68);
                        WebGUI::ErrorHandler::warn("Invalid LDAP information for registration of LDAP ID: ".$session{form}{ldapId});
                }
        }
        if ($error eq "") {
                $encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
                $uid = getNextId("userId");
                WebGUI::SQL->write("insert into users (userId,username,identifier,email,authMethod,ldapURL,connectDN,language) values ($uid, ".quote($username).", ".quote($encryptedPassword).", ".quote($session{form}{email}).", ".quote($session{setting}{authMethod}).", ".quote($session{setting}{ldapURL}).", ".quote($connectDN).", ".quote($session{form}{language}).")");
		($registeredUserExpire) = WebGUI::SQL->quickArray("select expireAfter from groups where groupId=2");
                WebGUI::SQL->write("insert into groupings values (2,$uid,".(time()+$registeredUserExpire).")");
                _login($uid,$encryptedPassword);
                $output .= WebGUI::International::get(80).'<p>';
                $output .= www_displayAccount();
        } else {
                $output = "<h1>".WebGUI::International::get(70)."</h1>".$error.www_createAccount();
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
                WebGUI::SQL->write("delete from users where userId=$session{user}{userId}");
                WebGUI::SQL->write("delete from groupings where userId=$session{user}{userId}");
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
		$output .= formHeader();
        	$output .= WebGUI::Form::hidden("op","updateAccount");
        	$output .= '<table>';
		if ($session{user}{authMethod} eq "LDAP" && $session{setting}{usernameBinding} eq "yes") {
			$output .= WebGUI::Form::hidden("username",$session{user}{username});
        		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.$session{user}{username}.'</td></tr>';
		} else {
        		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.WebGUI::Form::text("username",20,30,$session{user}{username}).'</td></tr>';
		}
		if ($session{user}{authMethod} eq "LDAP") {
        		$output .= WebGUI::Form::hidden("identifier1","password");
        		$output .= WebGUI::Form::hidden("identifier2","password");
		} else {
        		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(51).'</td><td>'.WebGUI::Form::password("identifier1",20,30,"password").'</td></tr>';
        		$output .= '<tr><td class="formDescription">'.WebGUI::International::get(55).'</td><td>'.WebGUI::Form::password("identifier2",20,30,"password").'</td></tr>';
		}
        	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(56).'</td><td>'.WebGUI::Form::text("email",20,255,$session{user}{email}).'<span class="formSubtext"><br>'.WebGUI::International::get(57).'</span></td></tr>';
		%hash = WebGUI::SQL->buildHash("select distinct(language) from international");
		$array[0] = $session{user}{language};
        	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(304).'</td><td>'.WebGUI::Form::selectList("language",\%hash,\@array).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
        	$output .= '</table>';
        	$output .= '</form> ';
		$output .= _accountOptions();
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
		$output .= formHeader();
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
sub www_editProfile {
	my ($output, %gender, @array);
	%gender = ('male'=>WebGUI::International::get(339),'female'=>WebGUI::International::get(340));
        if ($session{user}{userId} != 1) {
               	$output .= '<h1>'.WebGUI::International::get(338).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editProfileSave");
                $output .= WebGUI::Form::hidden("uid",$session{user}{userId});
                $output .= '<table>';
		if ($session{setting}{profileName}) {
			$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(314).'</td><td>'.WebGUI::Form::text("firstName",20,50,$session{user}{firstName}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(315).'</td><td>'.WebGUI::Form::text("middleName",20,50,$session{user}{middleName}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(316).'</td><td>'.WebGUI::Form::text("lastName",20,50,$session{user}{lastName}).'</td></tr>';
		}
		if ($session{setting}{profileExtraContact}) {
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(317).'</td><td>'.WebGUI::Form::text("icq",20,30,$session{user}{icq}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(318).'</td><td>'.WebGUI::Form::text("aim",20,30,$session{user}{aim}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(319).'</td><td>'.WebGUI::Form::text("msnIM",20,30,$session{user}{msnIM}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(320).'</td><td>'.WebGUI::Form::text("yahooIM",20,30,$session{user}{yahooIM}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(321).'</td><td>'.WebGUI::Form::text("cellPhone",20,30,$session{user}{cellPhone}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(322).'</td><td>'.WebGUI::Form::text("pager",20,30,$session{user}{pager}).'</td></tr>';
		}
		if ($session{setting}{profileHome}) {
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(323).'</td><td>'.WebGUI::Form::text("homeAddress",20,128,$session{user}{homeAddress}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(324).'</td><td>'.WebGUI::Form::text("homeCity",20,30,$session{user}{homeCity}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(325).'</td><td>'.WebGUI::Form::text("homeState",20,30,$session{user}{homeState}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(326).'</td><td>'.WebGUI::Form::text("homeZip",20,15,$session{user}{homeZip}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(327).'</td><td>'.WebGUI::Form::text("homeCountry",20,30,$session{user}{homeCountry}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(328).'</td><td>'.WebGUI::Form::text("homePhone",20,30,$session{user}{homePhone}).'</td></tr>';
		}
		if ($session{setting}{profileWork}) {
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(329).'</td><td>'.WebGUI::Form::text("workAddress",20,128,$session{user}{workAddress}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(330).'</td><td>'.WebGUI::Form::text("workCity",20,30,$session{user}{workCity}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(331).'</td><td>'.WebGUI::Form::text("workState",20,30,$session{user}{workState}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(332).'</td><td>'.WebGUI::Form::text("workZip",20,15,$session{user}{workZip}).'</td></tr>';
			$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(333).'</td><td>'.WebGUI::Form::text("workCountry",20,30,$session{user}{workCountry}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(334).'</td><td>'.WebGUI::Form::text("workPhone",20,30,$session{user}{workPhone}).'</td></tr>';
		}
		if ($session{setting}{profileMisc}) {
			$array[0] = $session{user}{gender};
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(335).'</td><td>'.WebGUI::Form::selectList("gender",\%gender,\@array).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(336).'</td><td>'.WebGUI::Form::text("birthdate",20,30,$session{user}{birthdate}).'</td></tr>';
                	$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(337).'</td><td>'.WebGUI::Form::text("homepage",20,2048,$session{user}{homepage}).'</td></tr>';
		}
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table>';
                $output .= '</form>';
                $output .= _accountOptions();
        } else {
                $output .= www_displayLogin();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_editProfileSave {
        if ($session{user}{userId} != 1) {
		WebGUI::SQL->write("update users set firstName=".quote($session{form}{firstName}).", middleName=".quote($session{form}{middleName}).", lastName=".quote($session{form}{lastName}).", icq=".quote($session{form}{icq}).", aim=".quote($session{form}{aim}).", msnIM=".quote($session{form}{msnIM}).", yahooIM=".quote($session{form}{yahooIM}).", homeAddress=".quote($session{form}{homeAddress}).", homeCity=".quote($session{form}{homeCity}).", homeState=".quote($session{form}{homeState}).", homeZip=".quote($session{form}{homeZip}).", homeCountry=".quote($session{form}{homeCountry}).", homePhone=".quote($session{form}{homePhone}).", workAddress=".quote($session{form}{workAddress}).", workCity=".quote($session{form}{workCity}).", workState=".quote($session{form}{workState}).", workZip=".quote($session{form}{workZip}).", workCountry=".quote($session{form}{workCountry}).", workPhone=".quote($session{form}{workPhone}).", cellPhone=".quote($session{form}{cellPhone}).", pager=".quote($session{form}{pager}).", gender=".quote($session{form}{gender}).", birthdate=".quote($session{form}{birthdate}).", homepage=".quote($session{form}{homepage})." where userId=".$session{form}{uid});
		return www_displayAccount();
	} else {
		return www_displayLogin();
	}
}

#-------------------------------------------------------------------
sub www_login {
	my ($uri, $port, $ldap, %args, $auth, $error, $uid,$pass,$authMethod, $ldapURL, $connectDN, $success);
	($uid,$pass,$authMethod, $ldapURL, $connectDN) = WebGUI::SQL->quickArray("select userId,identifier,authMethod,ldapURL,connectDN from users where username=".quote($session{form}{username}));
	if ($authMethod eq "LDAP") {
                $uri = URI->new($ldapURL);
                if ($uri->port < 1) {
                        $port = 389;
                } else {
                        $port = $uri->port;
                }
                %args = (port => $port);
                $ldap = Net::LDAP->new($uri->host, %args) or $error = WebGUI::International::get(79);
                $auth = $ldap->bind(dn=>$connectDN, password=>$session{form}{identifier});
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
                $ldap->unbind;
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
	return "";
}

#-------------------------------------------------------------------
sub www_recoverPassword {
	my ($output);
        if ($session{var}{sessionId}) {
                $output .= www_displayAccount();
        } else {
                $output .= '<h1>'.WebGUI::International::get(71).'</h1>';
		$output .= formHeader();
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
	$sth = WebGUI::SQL->read("select username, userId from users where email=".quote($session{form}{email}));
	while (($username,$userId) = $sth->array) {
	        foreach (0,1,2,3,4,5) {
        	        $password .= chr(ord('A') + randint(32));
        	}
        	$encryptedPassword = Digest::MD5::md5_base64($password);
		WebGUI::SQL->write("update users set identifier='$encryptedPassword' where userId='$userId'");
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
        	if ($session{form}{identifier1} ne "password") {
			if (_hasBadPassword($session{form}{identifier1},$session{form}{identifier2})) {
                		$error .= WebGUI::International::get(78).'<p>';
        		} else {
                		$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
				$passwordStatement = ', identifier='.quote($encryptedPassword);
			}
		}
        	if ($error eq "") {
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
                	WebGUI::SQL->write("update users set username=".quote($session{form}{username}).$passwordStatement.", email=".quote($session{form}{email}).", language=".quote($session{form}{language})." where userId=".$session{user}{userId});
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

#-------------------------------------------------------------------
sub www_viewMessageLog {
        my (@data, $output, $sth, @row, $i, $dataRows, $prevNextBar);
        if (WebGUI::Privilege::isInGroup(2,$session{user}{userId})) {
                $output = '<h1>'.WebGUI::International::get(159).'</h1>';
                $sth = WebGUI::SQL->read("select messageLogId,message,url,dateOfEntry from messageLog where userId=$session{user}{userId} order by dateOfEntry desc");
                while (@data = $sth->array) {
                        $row[$i] = '<tr><td class="tableData">';
                        if ($data[2] ne "") {
				$data[2] = appendToUrl($data[2],'mlog='.$data[0]);
                                $row[$i] .= '<a href="'.$data[2].'">';
                        }
                        $row[$i] .= $data[1];
                        if ($data[2] ne "") {
                                $row[$i] .= '</a>';
                        }
                        $row[$i] .= '</td><td class="tableData">'.epochToHuman($data[3],"%m/%d/%Y @ %H:%m%p").'</td></tr>';
                        $i++;
                }
                $sth->finish;
                ($dataRows, $prevNextBar) = paginate(50,$session{page}{url}.'?op=viewMessageLog',\@row);
                $output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
                $output .= '<tr><td class="tableHeader">'.WebGUI::International::get(351).'</td><td class="tableHeader">'.WebGUI::International::get(352).'</td></tr>';
                if ($dataRows eq "") {
                        $output .= '<tr><td rowspan=2 class="tableData">'.WebGUI::International::get(353).'</td></tr>';
                } else {
                        $output .= $dataRows;
                }
                $output .= '</table>';
                $output .= $prevNextBar;
		$output .= _accountOptions();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_viewProfile {
        my ($output, %user);
	%user = WebGUI::SQL->quickHash("select * from users where userId='$session{form}{uid}'");
	if ($user{username} eq "") {
		WebGUI::Privilege::notMember();
        } elsif ($session{user}{userId} != 1) {
                $output .= '<h1>'.WebGUI::International::get(347).' '.$user{username}.'</h1>';
                $output .= '<table>';
		if ($user{email} ne "") {
                	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(56).'</td><td class="tableData"><a href="mailto:'.$user{email}.'">'.$user{email}.'</a></td></tr>';
		}
                if ($session{setting}{profileName}) {
			if ($user{firstName} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(348).'</td><td class="tableData">'.$user{firstName}.' '.$user{middleName}.' '.$user{lastName}.'</td></tr>';
			}
                }
                if ($session{setting}{profileExtraContact}) {
			if ($user{icq} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(317).'</td><td class="tableData">'.$user{icq}.'</td></tr>';
			}
			if ($user{aim} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(318).'</td><td class="tableData">'.$user{aim}.'</td></tr>';
			}
			if ($user{msnIM} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(319).'</td><td class="tableData">'.$user{msnIM}.'</td></tr>';
			}
			if ($user{yahooIM} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(320).'</td><td class="tableData">'.$user{yahooIM}.'</td></tr>';
			}
			if ($user{cellPhone} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(321).'</td><td class="tableData">'.$user{cellPhone}.'</td></tr>';
			}
			if ($user{pager} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(322).'</td><td class="tableData">'.$user{pager}.'</td></tr>';
			}
                }
                if ($session{setting}{profileHome}) {
			if ($user{homeAddress} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(323).'</td><td class="tableData">'.$user{homeAddress}.'<br>'.$user{homeCity}.', '.$user{homeState}.' '.$user{homeZip}.' '.$user{homeCountry}.'</td></tr>';
			}
			if ($user{homePhone} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(328).'</td><td class="tableData">'.$user{homePhone}.'</td></tr>';
			}
                }
                if ($session{setting}{profileWork}) {
			if ($user{workAddress} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(329).'</td><td class="tableData">'.$user{workAddress}.'<br>'.$user{workCity}.', '.$user{workState}.' '.$user{workZip}.' '.$user{workCountry}.'</td></tr>';
			}
			if ($user{workPhone} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(334).'</td><td class="tableData">'.$user{workPhone}.'</td></tr>';
			}
                }
                if ($session{setting}{profileMisc}) {
			if ($user{gender} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(335).'</td><td class="tableData">'.$user{gender}.'</td></tr>';
			}
			if ($user{birthdate} ne "") {
                        	$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(336).'</td><td class="tableData">'.$user{birthdate}.'</td></tr>';
			}
			if ($user{homepage} ne "") {
				$output .= '<tr><td class="tableHeader" valign="top">'.WebGUI::International::get(337).'</td><td class="tableData"><a href="'.$user{homepage}.'">'.$user{homepage}.'</a></td></tr>';
			}
                }
                $output .= '</table>';
		if ($session{user}{userId} == $session{form}{uid}) {
                	$output .= _accountOptions();
		}
        } else {
                	$output .= WebGUI::Privilege::insufficient();
        }
        return $output;
}

1;

