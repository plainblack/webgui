package WebGUI::Operation::User;

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
use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editUserKarma &www_editUserKarmaSave &www_editUserGroup &www_editUserProfile &www_editUserProfileSave &www_addUserToGroupSave &www_deleteGrouping &www_editGrouping &www_editGroupingSave &www_becomeUser &www_addUser &www_addUserSave &www_deleteUser &www_deleteUserConfirm &www_editUser &www_editUserSave &www_listUsers);

#-------------------------------------------------------------------
sub _subMenu {
	my ($output);
	$output = '<table width="100%"><tr><td class="tableData" valign="top">';
	$output .= $_[0];
	$output .= '</td><td class="tableMenu" valign="top">';
	$output .= '<li><a href="'.WebGUI::URL::page("op=addUser").'">'.WebGUI::International::get(169).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page("op=editUser&uid=".$session{form}{uid}).'">'.WebGUI::International::get(457).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page("op=editUserGroup&uid=".$session{form}{uid}).'">'.WebGUI::International::get(458).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page("op=editUserProfile&uid=".$session{form}{uid}).'">'.WebGUI::International::get(459).'</a>';
	if ($session{setting}{useKarma}) {
		$output .= '<li><a href="'.WebGUI::URL::page("op=editUserKarma&uid=".$session{form}{uid}).'">'.WebGUI::International::get(555).'</a>';
	}
	$output .= '<li><a href="'.WebGUI::URL::page("op=listUsers").'">'.WebGUI::International::get(456).'</a>';
	$output .= '<li><a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(493).'</a>';
	$output .= '</td></tr></table>';
	return $output;
}

#-------------------------------------------------------------------
sub www_addUser {
        my (@array, $output, $groups, %hash, $f);
	tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(5);
		$output .= '<h1>'.WebGUI::International::get(163).'</h1>';
		$f = WebGUI::HTMLForm->new;
		if ($session{form}{op} eq "addUserSave") {
			$output .= '<ul><li>'.WebGUI::International::get(77).' '.$session{form}{username}.'Too or '.$session{form}{username}.'02</ul>';
		}
                $f->hidden("op","addUserSave");
                $f->text("username",WebGUI::International::get(50),$session{form}{username});
               	$f->password("identifier",WebGUI::International::get(51));
               	$f->email("email",WebGUI::International::get(56));
		%hash = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
               	$f->select("authMethod",\%hash,WebGUI::International::get(164),[$session{setting}{authMethod}]);
                $f->url("ldapURL",WebGUI::International::get(165),$session{setting}{ldapURL});
                $f->text("connectDN",WebGUI::International::get(166),$session{form}{connectDN});
                push(@array,1); #visitors
                push(@array,2); #registered users
                push(@array,7); #everyone
                $groups = WebGUI::SQL->buildHashRef("select groupId,groupName from groups where groupId not in (".join(",",@array).") order by groupName");
                $f->select("groups",$groups,WebGUI::International::get(605),[],5,1);
		$f->submit;
		$output .= $f->print;
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addUserSave {
        my ($output, @groups, $uid, $u, $gid, $encryptedPassword, $expireAfter);
        if (WebGUI::Privilege::isInGroup(3)) {
		($uid) = WebGUI::SQL->quickArray("select userId from users where username=".quote($session{form}{username}));
		unless ($uid) {
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
			$u = WebGUI::User->new("new");
			$u->username($session{form}{username});
			$u->identifier($encryptedPassword);
			$u->connectDN($session{form}{connectDN});
			$u->ldapURL($session{form}{ldapURL});
			$u->authMethod($session{form}{authMethod});
                	@groups = $session{cgi}->param('groups');
			$u->addToGroups(\@groups);
			$u->profileField("email",$session{form}{email});
			$session{form}{uid}=$u->userId;
                	$output = www_editUser();
		} else {
			$output = www_addUser();
		}
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addUserToGroupSave {
        my (@groups, $u);
        if (WebGUI::Privilege::isInGroup(3)) {
                @groups = $session{cgi}->param('groups');
		$u = WebGUI::User->new($session{form}{uid});
		$u->addToGroups(\@groups);
                return www_editUserGroup();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_becomeUser {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
        	WebGUI::Session::end($session{var}{sessionId});
		WebGUI::Session::start($session{form}{uid});
		$output = "";
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteGrouping {
	my ($u);
        if (WebGUI::Privilege::isInGroup(3)) {
		$u = WebGUI::User->new($session{form}{uid});
		$u->deleteFromGroups([$session{form}{gid}]);
                return www_editUser();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteUser {
        my ($output);
        if ($session{form}{uid} < 26) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(7);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(167).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteUserConfirm&uid='.$session{form}{uid}).
			'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listUsers').'">'.
			WebGUI::International::get(45).'</a></div>'; 
		return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteUserConfirm {
	my ($u);
        if ($session{form}{uid} < 26) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
		$u = WebGUI::User->new($session{form}{uid});
		$u->delete;
                return www_listUsers();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editGrouping {
        my ($output, $username, $group, $expireDate, $f);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<h1>'.WebGUI::International::get(370).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editGroupingSave");
                $f->hidden("uid",$session{form}{uid});
                $f->hidden("gid",$session{form}{gid});
		($username) = WebGUI::SQL->quickArray("select username from users where userId=$session{form}{uid}");
		($group) = WebGUI::SQL->quickArray("select groupName from groups where groupId=$session{form}{gid}");
		($expireDate) = WebGUI::SQL->quickArray("select expireDate from groupings where groupId=$session{form}{gid} and userId=$session{form}{uid}");
                $f->readOnly($username,WebGUI::International::get(50));
                $f->readOnly($group,WebGUI::International::get(84));
		$f->date("expireDate",WebGUI::International::get(369),$expireDate);
		$f->submit;
		$output .= $f->print;
                return _subMenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editGroupingSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update groupings set expireDate=".setToEpoch($session{form}{expireDate})." where groupId=$session{form}{gid} and userId=$session{form}{uid}");
                return www_editUserGroup();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editUser {
        my ($output, $f, $u, %data);
	tie %data, 'Tie::IxHash';
        if (WebGUI::Privilege::isInGroup(3)) {
		$u = WebGUI::User->new($session{form}{uid});
                $output .= helpIcon(5);
		$output .= '<h1>'.WebGUI::International::get(168).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editUserSave");
                $f->hidden("uid",$session{form}{uid});
                $f->readOnly($session{form}{uid},WebGUI::International::get(378));
                $f->readOnly($u->karma,WebGUI::International::get(537)) if ($session{setting}{useKarma});
                $f->readOnly(epochToHuman($u->dateCreated,"%z"),WebGUI::International::get(453));
                $f->readOnly(epochToHuman($u->lastUpdated,"%z"),WebGUI::International::get(454));
                $f->text("username",WebGUI::International::get(50),$u->username);
                $f->password("identifier",WebGUI::International::get(51),"password");
		%data = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
                $f->select("authMethod",\%data,WebGUI::International::get(164),[$u->authMethod]);
                $f->url("ldapURL",WebGUI::International::get(165),$u->ldapURL);
                $f->text("connectDN",WebGUI::International::get(166),$u->connectDN);
                $f->submit;
		$output .= $f->print;
		$output = _subMenu($output);
        } else {
		$output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editUserSave {
        my ($error, $uid, $u, $encryptedPassword, $passwordStatement);
        if (WebGUI::Privilege::isInGroup(3)) {
                ($uid) = WebGUI::SQL->quickArray("select userId from users where username=".
			quote($session{form}{username}));
                if ($uid == $session{form}{uid} || $uid < 1) {
			$u = WebGUI::User->new($session{form}{uid});
                	if ($session{form}{identifier} ne "password") {
                        	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
				$u->identifier($encryptedPassword);
                	}
			$u->username($session{form}{username});
			$u->authMethod($session{form}{authMethod});
			$u->connectDN($session{form}{connectDN});
			$u->ldapURL($session{form}{ldapURL});
		} else {
                        $error = '<ul><li>'.WebGUI::International::get(77).' '.$session{form}{username}.'Too or '.$session{form}{username}.'02</ul>';
		}
		return $error.www_editUser();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editUserGroup {
	my ($output, $f, $groups, @array, $sth, %hash);
	tie %hash, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<h1>'.WebGUI::International::get(372).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","addUserToGroupSave");
                $f->hidden("uid",$session{form}{uid});
                @array = WebGUI::SQL->buildArray("select groupId from groupings where userId=$session{form}{uid}");
                push(@array,1); #visitors
                push(@array,2); #registered users
                push(@array,7); #everyone
                $groups = WebGUI::SQL->buildHashRef("select groupId,groupName from groups where groupId not in (".join(",",@array).") order by groupName");
                $f->select("groups",$groups,WebGUI::International::get(605),[],5,1);
                $f->submit;
		$output .= $f->print;
                $output .= '<p><table><tr><td class="tableHeader">'.WebGUI::International::get(89).
			'</td><td class="tableHeader">'.WebGUI::International::get(84).
			'</td><td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
                $sth = WebGUI::SQL->read("select groups.groupId,groups.groupName,groupings.expireDate 
			from groupings,groups where groupings.groupId=groups.groupId and 
			groupings.userId=$session{form}{uid} order by groups.groupName");
                while (%hash = $sth->hash) {
                        $output .= '<tr><td>'
				.deleteIcon('op=deleteGrouping&uid='.$session{form}{uid}.'&gid='.$hash{groupId})
                                .editIcon('op=editGrouping&uid='.$session{form}{uid}.'&gid='.$hash{groupId})
                                .'</td>';
                        $output .= '<td class="tableData">'.$hash{groupName}.'</td>';
                        $output .= '<td class="tableData">'.epochToHuman($hash{expireDate},"%z").'</td></tr>';
                }
                $sth->finish;
                $output .= '</table>';
		$output = _subMenu($output);
        } else {
                return WebGUI::Privilege::adminOnly();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_editUserKarma {
        my ($output, $f, $a, %user, %data, $method, $values, $category, $label, $default, $previousCategory);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output = helpIcon(36);
                $output .= '<h1>'.WebGUI::International::get(558).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("op","editUserKarmaSave");
                $f->hidden("uid",$session{form}{uid});
		$f->integer("amount",WebGUI::International::get(556));
		$f->text("description",WebGUI::International::get(557));
                $f->submit;
                $output .= $f->print;
                $output = _subMenu($output);
        } else {
                $output .= WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editUserKarmaSave {
        my ($u);
        if (WebGUI::Privilege::isInGroup(3)) {
                $u = WebGUI::User->new($session{form}{uid});
                $u->karma($session{form}{amount},$session{user}{username}." (".$session{user}{userId}.")",$session{form}{description});
                return www_editUser();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editUserProfile {
        my ($output, $f, $a, %user, %data, $method, $values, $category, $label, $default, $previousCategory);
        if (WebGUI::Privilege::isInGroup(3)) {
		$output = helpIcon(32);
                $output .= '<h1>'.WebGUI::International::get(455).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("op","editUserProfileSave");
                $f->hidden("uid",$session{form}{uid});
		%user = WebGUI::SQL->buildHash("select fieldName,fieldData from userProfileData where userId=$session{form}{uid}");
                $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory
                        where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
                        order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
                while(%data = $a->hash) {
                	$category = eval $data{categoryName};
                        if ($category ne $previousCategory) {
                        	$f->raw('<tr><td colspan="2" class="tableHeader">'.$category.'</td></tr>');
                        }
                        $values = eval $data{dataValues};
                        $method = $data{dataType};
                        $label = eval $data{fieldLabel};
                        if ($method eq "select") {
                                # note: this big if statement doesn't look elegant, but doing regular
                                # ORs caused problems with the array reference.
                                if ($session{form}{$data{fieldName}}) {
                        		$default = [$session{form}{$data{fieldName}}];
                                } elsif ($user{$data{fieldName}}) {
                                        $default = [$user{$data{fieldName}}];
                                } else {
                                        $default = eval $data{dataDefault};
                                }
                                $f->select($data{fieldName},$values,$label,$default);
                        } else {
                                $default = $session{form}{$data{fieldName}}
                                        || $user{$data{fieldName}}
                                        || eval $data{dataDefault};
                                $f->$method($data{fieldName},$label,$default);
                        }
                        $previousCategory = $category;
                }
                $a->finish;
                $f->submit;
                $output .= $f->print;
		$output = _subMenu($output);
        } else {
                $output .= WebGUI::Privilege::adminOnly();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_editUserProfileSave {
        my ($a, %field, $u);
        if (WebGUI::Privilege::isInGroup(3)) {
        	tie %field, 'Tie::CPHash';
                $u = WebGUI::User->new($session{form}{uid});
        	$a = WebGUI::SQL->read("select * from userProfileField");
        	while (%field = $a->hash) {
                	if ($field{fieldType} eq "date") {
                        	$session{form}{$field{fieldName}} = setToEpoch($session{form}{$field{fieldName}});
                	}
                	$u->profileField($field{fieldName},$session{form}{$field{fieldName}}) if (exists $session{form}{$field{fieldName}});
        	}
        	$a->finish;
                return www_editUserProfile();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listUsers {
	my ($output, $sth, %data, $f, @row, $p, $i, $search);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
		$output = helpIcon(8);
		$output .= '<h1>'.WebGUI::International::get(149).'</h1>';
		$output .= '<table class="tableData" align="center" width="75%"><tr><td>';
		$output .= '<a href="'.WebGUI::URL::page('op=addUser').'">'.WebGUI::International::get(169).'</a>';
		$output .= '</td>';
		$f = WebGUI::HTMLForm->new(1);
		$f->raw('<td align="right">');
		$f->hidden("op","listUsers");
		$f->text("keyword",'',$session{form}{keyword});
		$f->submit(WebGUI::International::get(170));
		$f->raw('</td>');
		$output .= $f->print;
		$output .= '</tr></table><p>';
		if ($session{form}{keyword} ne "") {
			$search = " where (users.username like '%".$session{form}{keyword}."%') ";
		}
		$sth = WebGUI::SQL->read("select * from users $search order by users.username");
		while (%data = $sth->hash) {
			$row[$i] = '<tr class="tableData"><td>'
				.deleteIcon('op=deleteUser&uid='.$data{userId})
				.editIcon('op=editUser&uid='.$data{userId})
				.becomeIcon('op=becomeUser&uid='.$data{userId});
			$row[$i] .= '</td>';
			$row[$i] .= '<td><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$data{userId})
				.'">'.$data{username}.'</a></td>';
			#$row[$i] .= '<td class="tableData">'.epochToHuman($data{dateCreated},"%z").'</td>';
			#$row[$i] .= '<td class="tableData">'.epochToHuman($data{lastUpdated},"%z").'</td>';
			$row[$i] .= '</tr>';
			$i++;
		}
		$sth->finish;
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listUsers'),\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
		$output .= '<tr><td class="tableHeader"></td>
			<td class="tableHeader">'.WebGUI::International::get(50).'</td></tr>';
	#		<td class="tableHeader">'.WebGUI::International::get(453).'</td>
	#		<td class="tableHeader">'.WebGUI::International::get(454).'</td></tr>';
                $output .= $p->getPage($session{form}{pn});
                $output .= '</table>';
                $output .= $p->getBarTraditional($session{form}{pn});
		return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}


1;

