package WebGUI::Operation::Account;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(vars subs);
use URI;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::FormProcessor;
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
our @EXPORT = qw(&www_viewMessageLogMessage &www_viewThreadSubscriptions &www_viewMessageLog &www_viewProfile &www_editProfile &www_editProfileSave &www_createAccount &www_deactivateAccount &www_deactivateAccountConfirm &www_displayAccount &www_displayLogin &www_login &www_logout &www_recoverPassword &www_recoverPasswordFinish &www_createAccountSave &www_updateAccount);

#-------------------------------------------------------------------
sub _accountOptions {
	my ($output);
	$output = '<div class="accountOptions"><ul>';
	if (WebGUI::Privilege::isInGroup(4) || WebGUI::Privilege::isInGroup(5) || WebGUI::Privilege::isInGroup(6) || WebGUI::Privilege::isInGroup(8)) {
		if ($session{var}{adminOn}) {
			$output .= '<li><a href="'.WebGUI::URL::page('op=switchOffAdmin').'">'.
				WebGUI::International::get(12).'</a>';
		} else {
			$output .= '<li><a href="'.WebGUI::URL::page('op=switchOnAdmin').'">'.WebGUI::International::get(63).'</a>';
		}
	}
	$output .= '<li><a href="'.WebGUI::URL::page('op=displayAccount').'">'.WebGUI::International::get(342).'</a>' 
		unless ($session{form}{op} eq "displayAccount");
	$output .= '<li><a href="'.WebGUI::URL::page('op=editProfile').'">'.WebGUI::International::get(341).'</a>'
		unless ($session{form}{op} eq "editProfile");
	$output .= '<li><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$session{user}{userId}).'">'.
		WebGUI::International::get(343).'</a>'
		unless ($session{form}{op} eq "viewProfile");
	$output .= '<li><a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.WebGUI::International::get(354).'</a>'
		unless ($session{form}{op} eq "viewMessageLog");
	$output .= '<li><a href="'.WebGUI::URL::page('op=viewThreadSubscriptions').'">'.WebGUI::International::get(876).'</a>'
		unless ($session{form}{op} eq "viewThreadSubscriptions");
	$output .= '<li><a href="'.WebGUI::URL::page('op=logout').'">'.WebGUI::International::get(64).'</a>'; 

	$output .= '<li><a href="'.WebGUI::URL::page('op=deactivateAccount').'">'.
		WebGUI::International::get(65).'</a>' if ($session{setting}{selfDeactivation}
		&& !WebGUI::Privilege::isInGroup(3));
	$output .= '</ul></div>';
	return $output;
}

#-------------------------------------------------------------------
sub _checkForDuplicateUsername {
	my $username = $_[0];
	my ($otherUser) = WebGUI::SQL->quickArray("select count(*) from users where username=".quote($username));
	if ($otherUser && $username ne $session{user}{username}) {
		return '<li>'.WebGUI::International::get(77).' "'.$username.'too", "'.$username.'2", '
                	.'"'.$username.'_'.WebGUI::DateTime::epochToHuman(time(),"%y").'"';
	} else {
		return "";
	}
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
        $a = WebGUI::SQL->read("select dataType,fieldName,fieldLabel,required from userProfileField");
        while (%field = $a->hash) {
		$data{$field{fieldName}} = WebGUI::FormProcessor::process($field{fieldName},$field{dataType});
		if ($field{required} && $data{$field{fieldName}} eq "") {
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
	my ($output, %language, @array,
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
		$f->raw(WebGUI::Authentication::registrationForm());
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
	($username, $error) = WebGUI::Authentication::registrationFormValidate();
	($profile, $temp) = _validateProfileData();
	$error .= $temp;
	$error .= _checkForDuplicateUsername($username);
        if ($error eq "") {
		$u = WebGUI::User->new("new");
		$u->username($username);
		$u->authMethod($session{setting}{authMethod});
		WebGUI::Authentication::registrationFormSave($u->userId);
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
		WebGUI::Session::start(1);
        }
        return www_displayLogin();
}

#-------------------------------------------------------------------
sub www_displayAccount {
        my ($output, %hash, @array, $f);
	if ($session{user}{userId} != 1) {
        	$output = '<h1>'.WebGUI::International::get(61).'</h1>';
		my $form = WebGUI::Authentication::userForm();
		unless (defined $form) {
			$output .= WebGUI::International::get(856);
		} else {
			$f = WebGUI::HTMLForm->new;
        		$f->hidden("op","updateAccount");
			$f->readOnly($session{user}{karma},WebGUI::International::get(537)) if ($session{setting}{useKarma});
			$f->raw($form);
			$f->submit;
			$output .= $f->print;
		}
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
		tie %data, 'Tie::CPHash';
               	$output .= '<h1>'.WebGUI::International::get(338).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editProfileSave");
                $f->hidden("uid",$session{user}{userId});
                $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory
                        where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
			and userProfileCategory.editable=1 and userProfileField.editable=1
                        order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
                while(%data = $a->hash) {
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
                        if ($method eq "selectList") {
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
				if ($session{form}{$data{fieldName}}) {
					$default = $session{form}{$data{fieldName}};
				} elsif (exists $session{user}{$data{fieldName}}) {
					$default = $session{user}{$data{fieldName}};
				} else {
					$default = eval $data{dataDefault};
				}
                                $f->$method(
					-name=>$data{fieldName},
					-label=>$label,
					-value=>$default,
					-subtext=>$subtext
					);
                        }
                        $previousCategory = $category;
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
			$success = WebGUI::Authentication::authenticate($uid,$session{form}{identifier},$u->authMethod);
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
		_logLogin($uid, "failure");
		WebGUI::ErrorHandler::security("login to account ".$session{form}{username}." with invalid information.");
		return "<h1>".WebGUI::International::get(70)."</h1>".$success.www_displayLogin();
	}
}

#-------------------------------------------------------------------
sub www_logout {
	WebGUI::Session::end($session{var}{sessionId});
	WebGUI::Session::start(1);
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
		WebGUI::Authentication::saveParams($userId,"WebGUI",{identifier=>$encryptedPassword});
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
        my ($output, $username, $error, $encryptedPassword, $passwordStatement, $u);
        if ($session{user}{userId} != 1) {
		($username, $error) = WebGUI::Authentication::userFormValidate();
		$error .= _checkForDuplicateUsername($username);
        	if ($error eq "") {
			$u = WebGUI::User->new($session{user}{userId});
			$u->username($username);
			WebGUI::Authentication::userFormSave();
                	$output .= '<li>'.WebGUI::International::get(81).'<p>';
			WebGUI::Session::refreshUserInfo($u->userId);
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
        my $header = '<h1>'.WebGUI::International::get(347).' '.$u->username.'</h1>';
	if ($u->username eq "") {
		return WebGUI::Privilege::notMember();
	} elsif ($u->profileField("publicProfile") < 1) {
		return $header.WebGUI::International::get(862);
        } elsif (WebGUI::Privilege::isInGroup(2)) {
                $output = $header;
                $output .= '<table>';
                $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory
                        where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
			and userProfileCategory.visible=1 and userProfileField.visible=1
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
			if ($data{dataType} eq "date") {
                                $value = WebGUI::DateTime::epochToHuman($value,"%z");
                        }
			unless ($data{fieldName} eq "email" and $u->profileField("publicEmail") < 1) {
				$output .= '<tr><td class="tableHeader">'.$label.'</td><td class="tableData">'.$value.'</td></tr>';
			}
                        $previousCategory = $category;
                }
                $a->finish;
                $output .= '</table>';
		if ($session{user}{userId} == $session{form}{uid}) {
                	$output .= _accountOptions();
		}
		return $output;
        } else {
               return WebGUI::Privilege::insufficient();
        }
}


#-------------------------------------------------------------------
sub www_viewThreadSubscriptions {
	WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup(2));
	my ($data, $output, $list);
	$output = '<h1>'.WebGUI::International::get(877).'</h1>';
	my $sth = WebGUI::SQL->read("select b.subject,b.messageId,b.wobjectId,b.subId,d.urlizedTitle
 		from discussionSubscription a left join discussion b on (a.threadId=b.rid and b.pid=0)
 		left join wobject c on (b.wobjectId=c.wobjectId) left join page d on (c.pageId=d.pageId)
 		where a.userId=$session{user}{userId}");
	while ($data = $sth->hashRef) {
		$list .= '<li><a href="'
			.WebGUI::URL::gateway($data->{urlizedTitle},'func=showMessage&wid='
			.$data->{wobjectId}.'&mid='.$data->{messageId}.'&sid='.$data->{subId})
			.'">'.$data->{subject}.'</a>';
	}
	$sth->finish;
	if ($list eq "") {
		$output .= WebGUI::International::get(878);
	} else {
		$output .= '<ul>'.$list.'</ul><hr>';
	}
	$output .= _accountOptions();	
	return $output;
}


1;

