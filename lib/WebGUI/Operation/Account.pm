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
use strict;
use WebGUI::Form;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_createAccount &www_deactivateAccount &www_deactivateAccountConfirm &www_displayAccount &www_displayLogin &www_login &www_logout &www_recoverPassword &www_recoverPasswordFinish &www_saveAccount &www_updateAccount);

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
	($otherUser) = WebGUI::SQL->quickArray("select username from user where lcase(username)=lcase('$_[0]')",$session{dbh});
	if ($otherUser ne "" || $_[0] eq "") {
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
		return "<b>Error:</b> Unable to initialize session vars because your session signature does not match your account information.<p>";
	}
}

#-------------------------------------------------------------------
sub www_createAccount {
	my ($output);
	if ($session{user}{userId} != 1) {
                $output .= www_displayAccount();
        } else {
		$output .= ' <h1>Create Account</h1> <form method="post" action="'.$session{page}{url}.'"> ';
		$output .= WebGUI::Form::hidden("op","saveAccount");
		$output .= '<table>';
		$output .= '<tr><td class="formDescription">Username</td><td>'.WebGUI::Form::text("username",20,30).'</td></tr>';
		$output .= '<tr><td class="formDescription">Password</td><td>'.WebGUI::Form::password("identifier1",20,30).'</td></tr>';
		$output .= '<tr><td class="formDescription">Password (confirm)</td><td>'.WebGUI::Form::password("identifier2",20,30).'</td></tr>';
		$output .= '<tr><td class="formDescription" valign="top">Email Address</td><td>'.WebGUI::Form::text("email",20,255).'<span class="formSubtext"><br>This is only necessary if you wish to use features that require Email.</span></td></tr>';
		$output .= '<tr><td class="formDescription" valign="top"><a href="http://www.icq.com">ICQ</a> UIN</td><td>'.WebGUI::Form::text("icq",20,30).'<span class="formSubtext"><br>This is only necessary if you wish to use features that require ICQ.</span></td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit("create").'</td></tr>';
		$output .= '</table>';
		$output .= '</form> ';
		$output .= '<div class="accountOptions"><ul><li><a href="'.$session{page}{url}.'?op=displayLogin">I already have an account.</a><li><a href="'.$session{page}{url}.'?op=recoverPassword">I forgot my password.</a></ul></div>';
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_deactivateAccount {
        my ($output);
        if ($session{user}{userId} == 1) {
                $output .= www_displayLogin();
        } else {
                $output .= '<h1>Please Confirm</h1>';
                $output .= 'Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deactivateAccountConfirm">Yes, I\'m sure.</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'">No, I made a mistake.</a></div>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deactivateAccountConfirm {
        if ($session{user}{userId} != 1) {
                WebGUI::SQL->write("delete from user where userId=$session{user}{userId}",$session{dbh});
                WebGUI::SQL->write("delete from groupings where userId=$session{user}{userId}",$session{dbh});
	        WebGUI::Session::end($session{var}{sessionId});
        	_login(1,"null");
        }
        return www_displayLogin();
}

#-------------------------------------------------------------------
sub www_displayAccount {
        my ($output);
	if ($session{user}{userId} != 1) {
        	$output .= ' <h1>Update Account Information</h1> <form method="post" action="'.$session{page}{url}.'"> ';
        	$output .= WebGUI::Form::hidden("op","updateAccount");
        	$output .= '<table>';
        	$output .= '<tr><td class="formDescription">username</td><td>'.WebGUI::Form::text("username",20,30,$session{user}{username}).'</td></tr>';
        	$output .= '<tr><td class="formDescription">password</td><td>'.WebGUI::Form::password("identifier1",20,30,"password").'</td></tr>';
        	$output .= '<tr><td class="formDescription">password (confirm)</td><td>'.WebGUI::Form::password("identifier2",20,30,"password").'</td></tr>';
        	$output .= '<tr><td class="formDescription" valign="top">email address</td><td>'.WebGUI::Form::text("email",20,255,$session{user}{email}).'<span class="formSubtext"><br>This is only necessary if you wish to use features that require Email.</span></td></tr>';
        	$output .= '<tr><td class="formDescription" valign="top"><a href="http://www.icq.com">ICQ</a> UIN</td><td>'.WebGUI::Form::text("icq",20,30,$session{user}{icq}).'<span class="formSubtext"><br>This is only necessary if you wish to use features that require ICQ.</span></td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit("update").'</td></tr>';
        	$output .= '</table>';
        	$output .= '</form> ';
		$output .= '<div class="accountOptions"><ul>';
		if (WebGUI::Privilege::isInGroup(3) || WebGUI::Privilege::isInGroup(4)) {
			if ($session{var}{adminOn}) {
				$output .= '<li><a href="'.$session{page}{url}.'?op=switchOffAdmin">Turn admin off.</a>';
			} else {
				$output .= '<li><a href="'.$session{page}{url}.'?op=switchOnAdmin">Turn admin on.</a>';
			}
		}
		$output .= '<li><a href="'.$session{page}{url}.'?op=logout">Logout.</a><li><a href="'.$session{page}{url}.'?op=deactivateAccount">Please deactivate my account permanently.</a></ul></div>';
        } else {
                $output .= 'You need to be logged in to view your account information.<p>';
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
        	$output .= ' <h1>Login</h1> <form method="post" action="'.$session{page}{url}.'"> ';
		$output .= WebGUI::Form::hidden("op","login");
		$output .= '<table>';
        	$output .= '<tr><td class="formDescription">username</td><td>'.WebGUI::Form::text("username",20,30).'</td></tr>';
        	$output .= '<tr><td class="formDescription">password</td><td>'.WebGUI::Form::password("identifier",20,30).'</td></tr>';
		$output .= '<tr><td></td><td>'.WebGUI::Form::submit("login").'</td></tr>';
		$output .= '</table>';
		$output .= '</form>';
		$output .= '<div class="accountOptions"><ul><li><a href="'.$session{page}{url}.'?op=createAccount">Create a new account.</a><li><a href="'.$session{page}{url}.'?op=recoverPassword">I forgot my password.</a></ul></div>';
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_login {
	my ($uid,$pass);
	($uid,$pass) = WebGUI::SQL->quickArray("select userId,identifier from user where username=".quote($session{form}{username}),$session{dbh});
	if (Digest::MD5::md5_base64($session{form}{identifier}) eq $pass && $session{form}{identifier} ne "") {
		_login($uid,$pass);
		return "";
	} else {
		return "<h1>Invalid Account</h1>The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.".www_displayLogin();
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
                $output .= ' <h1>Recover Password</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","recoverPasswordFinish");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Email Address</td><td>'.WebGUI::Form::text("email",20,255).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("recover").'</td></tr>';
                $output .= '</table>';
                $output .= '</form>';
                $output .= '<div class="accountOptions"><ul><li><a href="'.$session{page}{url}.'?op=createAccount">Create a new account.</a><li><a href="'.$session{page}{url}.'?op=displayLogin">Login.</a></ul></div>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_recoverPasswordFinish {
	my ($sth, $username, $encryptedPassword, $userId, $password, $flag, $message, $output);
	$sth = WebGUI::SQL->read("select username, userId from user where email=".quote($session{form}{email}),$session{dbh});
	while (($username,$userId) = $sth->array) {
	        foreach (0,1,2,3,4,5) {
        	        $password .= chr(ord('A') + randint(32));
        	}
        	$encryptedPassword = Digest::MD5::md5_base64($password);
		WebGUI::SQL->write("update user set identifier='$encryptedPassword' where userId='$userId'",$session{dbh});
		$flag = 1;
		$message = 'Someone (probably you) requested your account information be sent. Your password has been reset. The following information represents your new account information:\nUser: '.$username.'\nPass: '.$password.'\n';
		WebGUI::Mail::send($session{form}{email},"Account Information",$message);	
	}
	$sth->finish();
	if ($flag) {
		$output = '<ul><li>Your account information has been sent to your email address.</ul>';
		$output .= www_displayLogin();
	} else {
		$output = '<ul><li>That email address is not in our databases.</ul>';
		$output .= www_recoverPassword();
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_saveAccount {
	my ($output, $error, $uid, $encryptedPassword);
	if (_hasBadUsername($session{form}{username})) {
		$error = '<b>Error:</b> The account name <b>'.$session{form}{username}.'</b> is in use by another member of this site. Please try a different username, perhaps "'.$session{form}{username}.'too" or "'.$session{form}{username}.'01"<p>';
	}
	if (_hasBadPassword($session{form}{identifier1},$session{form}{identifier2})) {
		$error .= '<b>Error:</b> Your passwords did not match. Please try again.<p>';
	}
	if ($error eq "") {
		$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
		$uid = getNextId("userId");
		WebGUI::SQL->write("insert into user set userId=$uid, username=".quote($session{form}{username}).", identifier=".quote($encryptedPassword).", email=".quote($session{form}{email}).", icq=".quote($session{form}{icq}),$session{dbh});
		WebGUI::SQL->write("insert into groupings set groupId=2,userId=$uid",$session{dbh});
		_login($uid,$encryptedPassword);
		$output .= 'Account created successfully!<p>';
		$output .= www_displayAccount();
	} else {
		$output = $error;
		$output = www_createAccount();
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_updateAccount {
        my ($output, $error, $encryptedPassword, $passwordStatement);
        if ($session{var}{sessionId}) {
        	if (_hasBadUsername($session{form}{username})) {
                	$error = '<b>Error:</b> The account name <b>'.$session{form}{username}.'</b> is in use by another member of this site. Please try a different username, perhaps "'.$session{form}{username}.'too" or "'.$session{form}{username}.'01"<p>';
        	}
        	if ($session{form}{identifier1} ne "password" && _hasBadPassword($session{form}{identifier1},$session{form}{identifier2})) {
                	$error .= '<b>Error:</b> Your passwords did not match. Please try again.<p>';
        	} else {
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
			$passwordStatement = ', identifier='.quote($encryptedPassword);
		}
        	if ($error eq "") {
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
                	WebGUI::SQL->write("update user set username=".quote($session{form}{username}).$passwordStatement.", email=".quote($session{form}{email}).", icq=".quote($session{form}{icq})." where userId=".$session{user}{userId},$session{dbh});
			if ($passwordStatement ne "") {
                		_login($session{user}{userId},$encryptedPassword);
			}
                	$output .= 'Account updated successfully!<p>';
                	$output .= www_displayAccount();
        	} else {
                	$output = $error;
                	$output = www_createAccount();
        	}
	} else {
		$output .= www_displayLogin();
	}
        return $output;
}

1;
