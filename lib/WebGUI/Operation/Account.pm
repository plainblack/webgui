package WebGUI::Operation::Account;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
use strict qw(vars subs);
use URI;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::MessageLog;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Authentication;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewMessageLogMessage &www_viewMessageLog &www_viewProfile &www_editProfile &www_editProfileSave &www_createAccount &www_deactivateAccount &www_deactivateAccountConfirm &www_displayAccount &www_displayLogin &www_login &www_logout &www_recoverPassword &www_recoverPasswordFinish &www_createAccountSave &www_updateAccount);

#-------------------------------------------------------------------
sub _accountOptions {
	my ($output);
	$output = '<div class="accountOptions"><ul>';
	if (WebGUI::Privilege::isInGroup(3) || WebGUI::Privilege::isInGroup(4) || WebGUI::Privilege::isInGroup(5) || WebGUI::Privilege::isInGroup(6)) {
		if ($session{var}{adminOn}) {
			$output .= '<li><a href="'.WebGUI::URL::page('op=switchOffAdmin').'">'.
				WebGUI::International::get(12).'</a>';
		} else {
			$output .= '<li><a href="'.WebGUI::URL::page('op=switchOnAdmin').'">'.WebGUI::International::get(63).'</a>';
		}
	}
	$output .= '<li><a href="'.WebGUI::URL::page('op=displayAccount').'">'.WebGUI::International::get(342).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=editProfile').'">'.WebGUI::International::get(341).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$session{user}{userId}).'">'.
		WebGUI::International::get(343).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.WebGUI::International::get(354).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page('op=logout').'">'.WebGUI::International::get(64).'</a>'; 

	$output .= '<li><a href="'.WebGUI::URL::page('op=deactivateAccount').'">'.
		WebGUI::International::get(65).'</a>' if ($session{setting}{selfDeactivation});
	$output .= '</ul></div>';
	return $output;
}

#-------------------------------------------------------------------
sub _hasBadPassword {
	my ($error);
	if ($_[0] ne $_[1]) {
		$error = '<li>'.WebGUI::International::get(78);
	} 
	if ($_[0] eq "password") {
		$error .= '<li>'.WebGUI::International::get(727);
	}
	if ($_[0] eq "") {
		$error .= '<li>'.WebGUI::International::get(726);
	}
	return $error;
}

#-------------------------------------------------------------------
sub _hasBadUsername {
	my ($error,$otherUser);
	if ($_[0] =~ /^\s/ || $_[0] =~ /\s$/) {
		$error = '<li>'.WebGUI::International::get(724);
	} 
	if ($_[0] eq "") {
		$error .= '<li>'.WebGUI::International::get(725);
	}
	unless ($_[0] =~ /^[A-Za-z0-9\-\_\.\,\@]+$/) {
		$error .= '<li>'.WebGUI::International::get(747);
	}
	($otherUser) = WebGUI::SQL->quickArray("select username from users where username='$_[0]'");
	if ($otherUser ne "" && $otherUser ne $session{user}{username}) {
		$error .= '<li>'.WebGUI::International::get(77).' "'.$_[0].'too", "'.$_[0].'2", '
                	.'"'.$_[0].'_'.WebGUI::DateTime::epochToHuman(time(),"%y").'"';
	}
	return $error;
}

#-------------------------------------------------------------------
sub _logLogin {
        WebGUI::SQL->write("insert into userLoginLog values ('$_[0]','$_[1]',".time().",".
                quote($session{env}{REMOTE_ADDR}).",".quote($session{env}{HTTP_USER_AGENT}).")");
}

#-------------------------------------------------------------------
sub _validateProfileData {
	my (%data, $error, $a, %field);
	tie %field, 'Tie::CPHash';
        $a = WebGUI::SQL->read("select * from userProfileField");
        while (%field = $a->hash) {
		if ($field{fieldType} eq "date") {
			$session{form}{$field{fieldName}} = setToEpoch($session{form}{$field{fieldName}});
		}
		$data{$field{fieldName}} = $session{form}{$field{fieldName}} if (exists $session{form}{$field{fieldName}});
		if ($field{required} && $session{form}{$field{fieldName}} eq "") {
			$error .= '<li>';
			$error .= eval $field{fieldLabel};
			$error .= ' '.WebGUI::International::get(451);
		}
        }
        $a->finish;
	return (\%data, $error);
}

#-------------------------------------------------------------------
sub www_createAccount {
	my ($output, %language, @array, $cmd, $return,
        	$previousCategory, $category, $f, $a, %data, $default, $label, $values, $method);
        tie %data, 'Tie::CPHash';
	if ($session{user}{userId} != 1) {
                $output .= www_displayAccount();
	} elsif (!$session{setting}{anonymousRegistration}) {
		$output .= www_displayLogin();
        } else {
		$output .= '<h1>'.WebGUI::International::get(54).'</h1>';

        	$f = WebGUI::HTMLForm->new();
		$f->hidden("op","createAccountSave");
		unless ($session{setting}{authMethod} ne "WebGUI" && $session{setting}{usernameBinding}) {
			$f->text("username",WebGUI::International::get(50),$session{form}{username});
		}
		if ($session{setting}{authMethod} ne 'WebGUI') {
			$f->text("loginId", 'loginName');
		}
 
		$cmd = $session{authentication}{$session{setting}{authMethod}} . "::formCreateAccount";
		$return = eval {&$cmd};
               	WebGUI::ErrorHandler::fatalError("Unable to load method formCreateAccount on Authentication module: $session{setting}{authMethod}. ".$@) if($@);
		$f->raw($return);

        	$a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory 
			where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId 
			order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
        	while(%data = $a->hash) {
                	if ($data{required}) {
                        	$category = eval $data{categoryName};
                        	if ($category ne $previousCategory) {
                                	#$f->raw('<tr><td colspan="2" class="tableHeader">'.$category.'</td></tr>');
                        	}
                        	$values = eval $data{dataValues};
                        	$method = $data{dataType};
                        	$label = eval $data{fieldLabel};
                        	if ($method eq "select") {
                                        # note: this big if statement doesn't look elegant, but doing regular
                                        # ORs caused problems with the array reference.
                                        if ($session{form}{$data{fieldName}}) {
                                                $default = [$session{form}{$data{fieldName}}];
                                        } elsif ($session{user}{$data{fieldName}}) {
                                                $default = [$session{user}{$data{fieldName}}];
                                        } else {
                                                $default = eval $data{dataDefault};
                                        }
                                	$f->select($data{fieldName},$values,$label,$default);
                        	} else {
                                	$default = $session{form}{$data{fieldName}} 
						|| $session{user}{$data{fieldName}} 
						|| eval $data{dataDefault};
                                	$f->$method($data{fieldName},$label,$default);
                        	}
                        	$previousCategory = $category;
                	}
       		}
        	$a->finish;
		$f->submit;
		$output .= $f->print;
		$output .= '<div class="accountOptions"><ul>';
		$output .= '<li><a href="'.WebGUI::URL::page('op=displayLogin').'">'.
			WebGUI::International::get(58).'</a>';

		if ($session{setting}{authMethod} eq "WebGUI") {
			$output .= '<li><a href="'.WebGUI::URL::page('op=recoverPassword').'">'.
				WebGUI::International::get(59).'</a>';
		}

		$output .= '</ul></div>';
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_createAccountSave {
        my ($profile, $u, $username, $uri, $temp, $ldap, $port, %args, $search, $cmd, 
		$connectDN, $auth, $output, $error, $uid,  $encryptedPassword, $fieldName);
        if ($session{setting}{authMethod} ne "WebGUI" && $session{setting}{usernameBinding}) {
		$username = $session{form}{loginId};
        } else {
                $username = $session{form}{username};
        }
	$error = _hasBadUsername($username);

	$cmd = $session{authentication}{$session{setting}{authMethod}} . '::hasBadUserData';
	$error .= eval {&$cmd};
	WebGUI::ErrorHandler::fatalError("Unable to load method hasBadUserData on Authentication module: $session{setting}{authMethod}. ".$@) if($@);

	($profile, $temp) = _validateProfileData();
	$error .= $temp;
        if ($error eq "") {
		$u = WebGUI::User->new("new");
		$u->username($username);
		$u->authMethod($session{setting}{authMethod});

		$cmd = $session{authentication}{$session{setting}{authMethod}} . '::saveCreateAccount';
		eval {&$cmd($u->userId)};
               	WebGUI::ErrorHandler::fatalError("Unable to load method saveCreateAccount on Authentication module: $session{setting}{authMethod}. ".$@) if($@);

		$u->karma($session{setting}{karmaPerLogin},"Login","Just for logging in.") if ($session{setting}{useKarma});
		foreach $fieldName (keys %{$profile}) {
			$u->profileField($fieldName,${$profile}{$fieldName});
		}
                WebGUI::Session::start($u->userId);
		_logLogin($u->userId,"success");
		system(WebGUI::Macro::process($session{setting}{runOnRegistration})) if ($session{setting}{runOnRegistration} ne "");
		WebGUI::MessageLog::addInternationalizedEntry('',$session{setting}{onNewUserAlertGroup},'',536) if ($session{setting}{alertOnNewUser});
        } else {
                $output = "<h1>".WebGUI::International::get(70)."</h1>".$error.www_createAccount();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deactivateAccount {
        my ($output);
        if ($session{user}{userId} == 1) {
                $output = www_displayLogin();
        } elsif ($session{user}{userId} < 26) {
		$output = WebGUI::Privilege::vitalComponent();
        } elsif ($session{setting}{selfDeactivation}) {
                $output = '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(60).'<p>';
                $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deactivateAccountConfirm').'">'.
			WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(45).'</a></div>';
        } else {
		$output = WebGUI::Privilege::adminOnly();
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_deactivateAccountConfirm {
	my ($u);
        if ($session{user}{userId} < 26) {
                return WebGUI::Privilege::vitalComponent();
        } elsif ($session{setting}{selfDeactivation}) {
		$u = WebGUI::User->new($session{user}{userId});
		$u->status("Selfdestructed");
	        WebGUI::Session::end($session{var}{sessionId});
        }
        return www_displayLogin();
}

#-------------------------------------------------------------------
sub www_displayAccount {
        my ($output, %hash, @array, $f);
	if ($session{user}{userId} != 1) {
        	$output .= '<h1>'.WebGUI::International::get(61).'</h1>';
		$f = WebGUI::HTMLForm->new;
        	$f->hidden("op","updateAccount");
		$f->readOnly($session{user}{karma},WebGUI::International::get(537)) if ($session{setting}{useKarma});

		if ($session{user}{authMethod} ne "WebGUI" && $session{setting}{usernameBinding}) {
			$f->hidden("username",$session{user}{username});
        		$f->readOnly($session{user}{username},WebGUI::International::get(50));
		} else {
        		$f->text("username",WebGUI::International::get(50),$session{user}{username});
		}

		if ($session{user}{authMethod} ne "WebGUI") {
        		$f->hidden("identifier1","password");
        		$f->hidden("identifier2","password");
		} else {
        		$f->password("identifier1",WebGUI::International::get(51),"password");
        		$f->password("identifier2",WebGUI::International::get(55),"password");
		}
		$f->submit;
		$output .= $f->print;
		$output .= _accountOptions();
        } else {
                $output .= www_displayLogin();
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_displayLogin {
	my ($output, $f);
	if ($session{user}{userId} != 1) {
		$output .= www_displayAccount();
	} else {
        	$output .= '<h1>'.WebGUI::International::get(66).'</h1>';
		$f = WebGUI::HTMLForm->new;
		$f->hidden("op","login");
        	$f->text("username",WebGUI::International::get(50));
        	$f->password("identifier",WebGUI::International::get(51));
		$f->submit(WebGUI::International::get(52));
		$output .= $f->print;
		$output .= '<div class="accountOptions"><ul>';
		if ($session{setting}{anonymousRegistration}) {
			$output .= '<li><a href="'.WebGUI::URL::page('op=createAccount').'">'.
				WebGUI::International::get(67).'</a>';
		}
		if ($session{setting}{authMethod} eq "WebGUI") {
			$output .= '<li><a href="'.WebGUI::URL::page('op=recoverPassword').'">'.
				WebGUI::International::get(59).'</a>';
		}
		$output .= '</ul></div>';
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_editProfile {
	my ($output, $f, $a, %data, $method, $values, $category, $label, $default, $previousCategory, $subtext);
        if ($session{user}{userId} != 1) {
               	$output .= '<h1>'.WebGUI::International::get(338).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editProfileSave");
                $f->hidden("uid",$session{user}{userId});
                $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory
                        where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
                        order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
                while(%data = $a->hash) {
                        if ($data{visible}) {
                                $category = eval $data{categoryName};
                                if ($category ne $previousCategory) {
                                        $f->raw('<tr><td colspan="2" class="tableHeader">'.$category.'</td></tr>');
                                }
                                $values = eval $data{dataValues};
                                $method = $data{dataType};
                                $label = eval $data{fieldLabel};
				if ($data{required}) {
					$subtext = "*";
				} else {
					$subtext = "";
				}
                                if ($method eq "select") {
                                        # note: this big if statement doesn't look elegant, but doing regular
					# ORs caused problems with the array reference.
					if ($session{form}{$data{fieldName}}) {
						$default = [$session{form}{$data{fieldName}}];
					} elsif ($session{user}{$data{fieldName}}) {
						$default = [$session{user}{$data{fieldName}}];
					} else {
						$default = eval $data{dataDefault};
					}
                                        $f->select(
						-name=>$data{fieldName},
						-options=>$values,
						-label=>$label,
						-value=>$default,
						-subtext=>$subtext
						);
                                } else {
                                        $default = $session{form}{$data{fieldName}}
                                                || $session{user}{$data{fieldName}}
                                                || eval $data{dataDefault};
                                        $f->$method(
						-name=>$data{fieldName},
						-label=>$label,
						-value=>$default,
						-subtext=>$subtext
						);
                                }
                                $previousCategory = $category;
                        }
                }
                $a->finish;
		$f->submit;
		$output .= $f->print;
                $output .= _accountOptions();
        } else {
                $output .= www_displayLogin();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_editProfileSave {
	my ($profile, $fieldName, $error, $u);
        if ($session{user}{userId} != 1) {
		($profile, $error) = _validateProfileData();
        	if ($error eq "") {
			$u = WebGUI::User->new($session{user}{userId});
                	foreach $fieldName (keys %{$profile}) {
                        	$u->profileField($fieldName,${$profile}{$fieldName});
			}
			return www_displayAccount();
                } else {
			return '<ul>'.$error.'</ul>'.www_editProfile();	
		}
	} else {
		return www_displayLogin();
	}
}

#-------------------------------------------------------------------
sub www_login {
	my ($cmd, $uid, $success, $u);

	($uid) = WebGUI::SQL->quickArray("select userId from users where username=".quote($session{form}{username}));

	if ($uid) {
		$u = WebGUI::User->new($uid);
		if ($u->status eq 'Active') {
			$cmd = $session{authentication}{$u->authMethod}."::validateUser";
			$success = eval{&$cmd($uid, $session{form}{identifier})};
			WebGUI::ErrorHandler::fatalError("Unable to load method validateUser on Authentication module: $_. ".$@) if($@);
		} else {
			$success = WebGUI::International::get(820);			
		}
	} else {
		$success = WebGUI::International::get(68);
	}

	if ($success == 1) {
		WebGUI::Session::convertVisitorToUser($session{var}{sessionId},$uid);
		$u->karma($session{setting}{karmaPerLogin},"Login","Just for logging in.") if ($session{setting}{useKarma});
                _logLogin($uid,"success");
		return "";
	} else {
		_logLogin($uid, $success);
		return "<h1>".WebGUI::International::get(70)."</h1>".$success.www_displayLogin();
	}
}

#-------------------------------------------------------------------
sub www_logout {
	WebGUI::Session::end($session{var}{sessionId});
	return "";
}

#-------------------------------------------------------------------
sub www_recoverPassword {
	my ($output, $f);
        if ($session{user}{userId} != 1) {
                $output .= www_displayAccount();
        } else {
                $output .= '<h1>'.WebGUI::International::get(71).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","recoverPasswordFinish");
                $f->email("email",WebGUI::International::get(56));
                $f->submit(WebGUI::International::get(72));
		$output .= $f->print;
                $output .= '<div class="accountOptions"><ul>';
		if ($session{setting}{anonymousRegistration}) {
			$output .= '<li><a href="'.WebGUI::URL::page('op=createAccount').'">'.
				WebGUI::International::get(67).'</a>';
		}
		$output .= '<li><a href="'.WebGUI::URL::page('op=displayLogin').'">'.
			WebGUI::International::get(73).'</a>';
		$output .= '</ul></div>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_recoverPasswordFinish {
	my ($sth, $username, $encryptedPassword, $userId, $password, $flag, $message, $output);
	if ($session{form}{email} eq "") {
		return '<ul><li>'.WebGUI::International::get(743).'</li></ul>'.www_recoverPassword() 
	}
	$sth = WebGUI::SQL->read("select users.username, users.userId from users, userProfileData 
		where users.userId=userProfileData.userId and userProfileData.fieldName='email' 
		and fieldData=".quote($session{form}{email}));
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
        my ($output, $error, $encryptedPassword, $passwordStatement, $u);
        if ($session{user}{userId} != 1) {
        	if ($session{form}{identifier1} ne "password") {
			$error = _hasBadPassword($session{form}{identifier1},$session{form}{identifier2});
        		unless ($error) {
                		$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
				$passwordStatement = ', identifier='.quote($encryptedPassword);
			}
		}
		$error .= _hasBadUsername($session{form}{username});
        	if ($error eq "") {
			$u = WebGUI::User->new($session{user}{userId});
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
			$u->identifier($encryptedPassword) if ($session{form}{identifier1} ne "password");
			$u->username($session{form}{username});
                	$output .= WebGUI::International::get(81).'<p>';
        	} else {
                	$output = $error;
        	}
                $output .= www_displayAccount();
	} else {
		$output .= www_displayLogin();
	}
        return $output;
}

#-------------------------------------------------------------------
sub www_viewMessageLog {
        my (%status, @data, $output, $sth, @row, $i, $p);
        if (WebGUI::Privilege::isInGroup(2,$session{user}{userId})) {
		%status = (notice=>WebGUI::International::get(551),pending=>WebGUI::International::get(552),completed=>WebGUI::International::get(350));
                $output = '<h1>'.WebGUI::International::get(159).'</h1>';
                $sth = WebGUI::SQL->read("select messageLogId,subject,url,dateOfEntry,status from messageLog where userId=$session{user}{userId} order by dateOfEntry desc");
                while (@data = $sth->array) {
                        $row[$i] = '<tr><td class="tableData">';
                        $row[$i] .= '<a href="'.WebGUI::URL::page('op=viewMessageLogMessage&mlog='.$data[0]).'">'.$data[1].'</a>';
			$row[$i] .= '</td><td class="tableData">';
                        if ($data[2] ne "") {
				$data[2] = WebGUI::URL::append($data[2],'mlog='.$data[0]);
                                $row[$i] .= '<a href="'.$data[2].'">';
                        }
                        $row[$i] .= $status{$data[4]};
                        if ($data[2] ne "") {
                                $row[$i] .= '</a>';
                        }
                        $row[$i] .= '</td><td class="tableData">'.epochToHuman($data[3]).'</td></tr>';
                        $i++;
                }
                $sth->finish;
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewMessageLog'),\@row);
                $output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
                $output .= '<tr><td class="tableHeader">'.WebGUI::International::get(351).'</td>
			<td class="tableHeader">'.WebGUI::International::get(553).'</td>
			<td class="tableHeader">'.WebGUI::International::get(352).'</td></tr>';
                if ($p->getPage($session{form}{pn}) eq "") {
                        $output .= '<tr><td rowspan=2 class="tableData">'.WebGUI::International::get(353).'</td></tr>';
                } else {
                        $output .= $p->getPage($session{form}{pn});
                }
                $output .= '</table>';
                $output .= $p->getBarSimple($session{form}{pn});
		$output .= _accountOptions();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_viewMessageLogMessage {
        my (%status, %data, $output, $sth, @row, $i, $p);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(2,$session{user}{userId})) {
        	%status = (notice=>WebGUI::International::get(551),pending=>WebGUI::International::get(552),completed=>WebGUI::International::get(350));
                $output = '<h1>'.WebGUI::International::get(159).'</h1>';
                %data = WebGUI::SQL->quickHash("select * from messageLog where messageLogId=$session{form}{mlog} and userId=$session{user}{userId}");
		$output .= '<b>'.$data{subject}.'</b><br>';
		$output .= epochToHuman($data{dateOfEntry}).'<br>';
                if ($data{url} ne "" && $data{status} eq 'pending') {
                	$data{url} = WebGUI::URL::append($data{url},'mlog='.$data{messageLogId});
                        $output .= '<a href="'.$data{url}.'">';
                }
		$output .= $status{$data{status}}.'<br>';
		if ($data{url} ne "") {
			$output .= '</a>';
		}
		$output .= '<br>'.$data{message}.'<p>';
		if ($data{url} ne "" && $data{status} eq 'pending') {
                        $output .= '<a href="'.$data{url}.'">'.WebGUI::International::get(554).'</a> &middot; ';
                }
		$output .= '<a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.WebGUI::International::get(354).'</a><p>';
                $output .= _accountOptions();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_viewProfile {
        my ($a, %data, $category, $label, $value, $previousCategory, $output, $u, %gender);
	%gender = ('neuter'=>WebGUI::International::get(403),'male'=>WebGUI::International::get(339),'female'=>WebGUI::International::get(340));
	$u = WebGUI::User->new($session{form}{uid});
	if ($u->username eq "") {
		WebGUI::Privilege::notMember();
        } elsif ($session{user}{userId} != 1) {
                $output .= '<h1>'.WebGUI::International::get(347).' '.$u->username.'</h1>';
                $output .= '<table>';
                $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory
                        where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
			and userProfileCategory.profileCategoryId<>4
			and userProfileField.visible=1
                        order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
                while (%data = $a->hash) {
                	$category = eval $data{categoryName};
                        if ($category ne $previousCategory) {
                        	$output .= '<tr><td colspan="2" class="tableHeader">'.$category.'</td></tr>';
                        }
                        $label = eval $data{fieldLabel};
			if ($data{dataValues}) {
				$value = eval $data{dataValues};
				$value = ${$value}{$u->profileField($data{fieldName})};
			} else {
				$value = $u->profileField($data{fieldName});
			}
			$output .= '<tr><td class="tableHeader">'.$label.'</td><td class="tableData">'.$value.'</td></tr>';
                        $previousCategory = $category;
                }
                $a->finish;
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

