package WebGUI::Operation::User;

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
use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editUserGroupSave &www_deleteGrouping &www_editGrouping &www_editGroupingSave &www_becomeUser &www_addUser &www_addUserSave &www_deleteUser &www_deleteUserConfirm &www_editUser &www_editUserSave &www_listUsers);

#-------------------------------------------------------------------
sub www_addUser {
        my ($output, %hash, @array);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpLink(5);
		$output .= '<h1>'.WebGUI::International::get(163).'</h1>';
		if ($session{form}{op} eq "addUserSave") {
			$output .= '<ul><li>'.WebGUI::International::get(77).' '.$session{form}{username}.'Too or '.$session{form}{username}.'02</ul>';
		}
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("op","addUserSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(50),WebGUI::Form::text("username",20,30,$session{form}{username}));
               	$output .= tableFormRow(WebGUI::International::get(51),WebGUI::Form::password("identifier",20,30,$session{form}{username}));
		%hash = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
		$array[0] = $session{setting}{authMethod};
               	$output .= tableFormRow(WebGUI::International::get(164),WebGUI::Form::selectList("authMethod",\%hash, \@array));
                $output .= tableFormRow(WebGUI::International::get(165),WebGUI::Form::text("ldapURL",20,2048,$session{setting}{ldapURL}));
                $output .= tableFormRow(WebGUI::International::get(166),WebGUI::Form::text("connectDN",20,255,$session{form}{connectDN}));
                $output .= tableFormRow(WebGUI::International::get(56),WebGUI::Form::text("email",20,255,$session{form}{email}));
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName");
		$array[0] = 2;
                $output .= tableFormRow(WebGUI::International::get(89),WebGUI::Form::selectList("groups",\%hash,\@array,5,1));
		%hash = WebGUI::SQL->buildHash("select distinct(language) from international");
		$array[0] = "English";
                $output .= tableFormRow(WebGUI::International::get(304),WebGUI::Form::selectList("language",\%hash,\@array));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addUserSave {
        my ($output, @groups, $uid, $gid, $encryptedPassword, $expireAfter);
        if (WebGUI::Privilege::isInGroup(3)) {
		($uid) = WebGUI::SQL->quickArray("select userId from users where username='$session{form}{username}'");
		unless ($uid) {
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
			$uid = getNextId("userId");
                	WebGUI::SQL->write("insert into users (userId,username,identifier,email,authMethod,ldapURL,connectDN,language) values ($uid, ".quote($session{form}{username}).", ".quote($encryptedPassword).", ".quote($session{form}{email}).", ".quote($session{form}{authMethod}).", ".quote($session{form}{ldapURL}).", ".quote($session{form}{connectDN}).", ".quote($session{form}{language}).")");
                	@groups = $session{cgi}->param('groups');
                	foreach $gid (@groups) {
				($expireAfter) = WebGUI::SQL->quickArray("select expireAfter from groups where groupId=$gid");
                        	WebGUI::SQL->write("insert into groupings values ($gid, $uid, ".(time()+$expireAfter).")");
                	}
                	$output = www_listUsers();
		} else {
			$output = www_addUser();
		}
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_becomeUser {
        my ($cookieInfo, $output, $password);
        if (WebGUI::Privilege::isInGroup(3)) {
		($password) = WebGUI::SQL->quickArray("select identifier from users where userId='$session{form}{uid}'");
        	WebGUI::Session::end($session{var}{sessionId});
        	$cookieInfo = $session{form}{uid}."|".crypt($password,"yJ");
		WebGUI::Session::end($cookieInfo);
		WebGUI::Session::start($cookieInfo);
        	WebGUI::Session::setCookie("wgSession",$cookieInfo);
		$output = "";
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteGrouping {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("delete from groupings where groupId=$session{form}{gid} and userId=$session{form}{uid}");
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
                $output .= helpLink(7);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(167).'<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deleteUserConfirm&uid='.$session{form}{uid}.'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'?op=listUsers">'.WebGUI::International::get(45).'</a></div>'; 
		return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteUserConfirm {
        if ($session{form}{uid} < 26) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("delete from users where userId=$session{form}{uid}");
                WebGUI::SQL->write("delete from groupings where userId=$session{form}{uid}");
                return www_listUsers();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editGrouping {
        my ($output, $username, $group, $expireDate);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<h1>'.WebGUI::International::get(370).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editGroupingSave");
                $output .= WebGUI::Form::hidden("uid",$session{form}{uid});
                $output .= WebGUI::Form::hidden("gid",$session{form}{gid});
		($username) = WebGUI::SQL->quickArray("select username from users where userId=$session{form}{uid}");
		($group) = WebGUI::SQL->quickArray("select groupName from groups where groupId=$session{form}{gid}");
		($expireDate) = WebGUI::SQL->quickArray("select expireDate from groupings where groupId=$session{form}{gid} and userId=$session{form}{uid}");
		$output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(50),$username);
                $output .= tableFormRow(WebGUI::International::get(84),$group);
		$output .= tableFormRow(WebGUI::International::get(369),WebGUI::Form::text("expireDate",20,30,epochToSet($expireDate),1));
                $output .= formSave();
		$output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editGroupingSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update groupings set expireDate=".setToEpoch($session{form}{expireDate})." where groupId=$session{form}{gid} and userId=$session{form}{uid}");
                return www_editUser();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editUser {
        my ($output, %user, %hash, @array, %gender, $sth);
	tie %hash, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
		%gender = ('male'=>WebGUI::International::get(339),'female'=>WebGUI::International::get(340));
		%user = WebGUI::SQL->quickHash("select * from users where userId=$session{form}{uid}");
		$output .= '<table><tr><td valign="top">';
                $output .= helpLink(5);
		$output .= '<h1>'.WebGUI::International::get(168).'</h1>';
                if ($session{form}{op} eq "editUserSave") {
                        $output .= '<ul><li>'.WebGUI::International::get(77).' '.$session{form}{username}.'Too or '.$session{form}{username}.'02</ul>';
                }
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editUserSave");
                $output .= WebGUI::Form::hidden("uid",$session{form}{uid});
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(50),WebGUI::Form::text("username",20,30,$user{username}));
                $output .= tableFormRow(WebGUI::International::get(51),WebGUI::Form::password("identifier",20,30,"password"));
		%hash = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
		$array[0] = $user{authMethod};
                $output .= tableFormRow(WebGUI::International::get(164),WebGUI::Form::selectList("authMethod",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(165),WebGUI::Form::text("ldapURL",20,2048,$user{ldapURL}));
                $output .= tableFormRow(WebGUI::International::get(166),WebGUI::Form::text("connectDN",20,255,$user{connectDN}));
                $output .= tableFormRow(WebGUI::International::get(56),WebGUI::Form::text("email",20,255,$user{email}));
		%hash = WebGUI::SQL->buildHash("select distinct(language) from international");
		@array = [];
		$array[0] = $user{language};
                $output .= tableFormRow(WebGUI::International::get(304),WebGUI::Form::selectList("language",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(314),WebGUI::Form::text("firstName",20,50,$user{firstName}));
                $output .= tableFormRow(WebGUI::International::get(315),WebGUI::Form::text("middleName",20,50,$user{middleName}));
                $output .= tableFormRow(WebGUI::International::get(316),WebGUI::Form::text("lastName",20,50,$user{lastName}));
                $output .= tableFormRow(WebGUI::International::get(317),WebGUI::Form::text("icq",20,30,$user{icq}));
                $output .= tableFormRow(WebGUI::International::get(318),WebGUI::Form::text("aim",20,30,$user{aim}));
                $output .= tableFormRow(WebGUI::International::get(319),WebGUI::Form::text("msnIM",20,30,$user{msnIM}));
                $output .= tableFormRow(WebGUI::International::get(320),WebGUI::Form::text("yahooIM",20,30,$user{yahooIM}));
                $output .= tableFormRow(WebGUI::International::get(321),WebGUI::Form::text("cellPhone",20,30,$user{cellPhone}));
                $output .= tableFormRow(WebGUI::International::get(322),WebGUI::Form::text("pager",20,30,$user{pager}));
                $output .= tableFormRow(WebGUI::International::get(323),WebGUI::Form::text("homeAddress",20,128,$user{homeAddress}));
                $output .= tableFormRow(WebGUI::International::get(324),WebGUI::Form::text("homeCity",20,30,$user{homeCity}));
                $output .= tableFormRow(WebGUI::International::get(325),WebGUI::Form::text("homeState",20,30,$user{homeState}));
                $output .= tableFormRow(WebGUI::International::get(326),WebGUI::Form::text("homeZip",20,15,$user{homeZip}));
                $output .= tableFormRow(WebGUI::International::get(327),WebGUI::Form::text("homeCountry",20,30,$user{homeCountry}));
                $output .= tableFormRow(WebGUI::International::get(328),WebGUI::Form::text("homePhone",20,30,$user{homePhone}));
		$output .= tableFormRow(WebGUI::International::get(329),WebGUI::Form::text("workAddress",20,128,$user{workAddress}));
                $output .= tableFormRow(WebGUI::International::get(330),WebGUI::Form::text("workCity",20,30,$user{workCity}));
                $output .= tableFormRow(WebGUI::International::get(331),WebGUI::Form::text("workState",20,30,$user{workState}));
                $output .= tableFormRow(WebGUI::International::get(332),WebGUI::Form::text("workZip",20,15,$user{workZip}));
                $output .= tableFormRow(WebGUI::International::get(333),WebGUI::Form::text("workCountry",20,30,$user{workCountry}));
                $output .= tableFormRow(WebGUI::International::get(334),WebGUI::Form::text("workPhone",20,30,$user{workPhone}));
		@array = ($user{gender});
                $output .= tableFormRow(WebGUI::International::get(335),WebGUI::Form::selectList("gender",\%gender,\@array));
                $output .= tableFormRow(WebGUI::International::get(336),WebGUI::Form::text("birthdate",20,30,$user{birthdate}));
                $output .= tableFormRow(WebGUI::International::get(337),WebGUI::Form::text("homepage",20,2048,$user{homepage}));
                $output .= formSave();
                $output .= '</table>';
                $output .= '</form>';
		$output .= '</td><td>&nbsp;</td><td class="formDescription" valign="top">';
                $output .= '<h1>'.WebGUI::International::get(372).'</h1>';
                $output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editUserGroupSave");
                $output .= WebGUI::Form::hidden("uid",$session{form}{uid});
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName");
                @array = WebGUI::SQL->buildArray("select groupId from groupings where userId=$session{form}{uid}");
                $output .= WebGUI::Form::selectList("groups",\%hash,\@array,5,1);
                $output .= '<br>'.WebGUI::Form::submit(WebGUI::International::get(62));
                $output .= '<p>'.WebGUI::International::get(373).'<p></form>';
                $output .= '<table><tr><td class="tableHeader">'.WebGUI::International::get(89).'</td><td class="tableHeader">'.WebGUI::International::get(84).'</td><td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
                $sth = WebGUI::SQL->read("select groups.groupId,groups.groupName,groupings.expireDate from groupings,groups where groupings.groupId=groups.groupId and groupings.userId=$session{form}{uid} order by groups.groupName");
                while (%hash = $sth->hash) {
                        $output .= '<tr><td><a href="'.$session{page}{url}.'?op=deleteGrouping&uid='.$session{form}{uid}.'&gid='.$hash{groupId}.'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.
'?op=editGrouping&uid='.$session{form}{uid}.'&gid='.$hash{groupId}.'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a></td>';
                        $output .= '<td class="tableData">'.$hash{groupName}.'</td>';
			$output .= '<td class="tableData">'.epochToHuman($hash{expireDate},"%M/%D/%y").'</td></tr>';
                }
                $sth->finish;
                $output .= '</table>';
		$output .= '</td></tr></table>';
        } else {
		$output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editUserSave {
        my ($error, $uid, $encryptedPassword, $passwordStatement);
        if (WebGUI::Privilege::isInGroup(3)) {
                ($uid) = WebGUI::SQL->quickArray("select userId from users where username='$session{form}{username}'");
                unless ($uid) {
                	if ($session{form}{identifier} ne "password") {
                        	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
                        	$passwordStatement = ', identifier='.quote($encryptedPassword);
                	}
                	$encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
                	WebGUI::SQL->write("update users set username=".quote($session{form}{username}).$passwordStatement.", authMethod=".quote($session{form}{authMethod}).", ldapURL=".quote($session{form}{ldapURL}).", connectDN=".quote($session{form}{connectDN}).", email=".quote($session{form}{email}).", language=".quote($session{form}{language}).", firstName=".quote($session{form}{firstName}).", middleName=".quote($session{form}{middleName}).", lastName=".quote($session{form}{lastName}).", icq=".quote($session{form}{icq}).", aim=".quote($session{form}{aim}).", msnIM=".quote($session{form}{msnIM}).", yahooIM=".quote($session{form}{yahooIM}).", homeAddress=".quote($session{form}{homeAddress}).", homeCity=".quote($session{form}{homeCity}).", homeState=".quote($session{form}{homeState}).", homeZip=".quote($session{form}{homeZip}).", homeCountry=".quote($session{form}{homeCountry}).", homePhone=".quote($session{form}{homePhone}).", workAddress=".quote($session{form}{workAddress}).", workCity=".quote($session{form}{workCity}).", workState=".quote($session{form}{workState}).", workZip=".quote($session{form}{workZip}).", workCountry=".quote($session{form}{workCountry}).", workPhone=".quote($session{form}{workPhone}).", cellPhone=".quote($session{form}{cellPhone}).", pager=".quote($session{form}{pager}).", gender=".quote($session{form}{gender}).", birthdate=".quote($session{form}{birthdate}).", homepage=".quote($session{form}{homepage})." where userId=".$session{form}{uid});
			return www_listUsers();
		} else {
			return www_editUser();
		}
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editUserGroupSave {
        my (@groups, $gid, $expireAfter);
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("delete from groupings where userId=$session{form}{uid}");
                @groups = $session{cgi}->param('groups');
                foreach $gid (@groups) {
			($expireAfter) = WebGUI::SQL->quickArray("select expireAfter from groups where groupId=$gid");
                        WebGUI::SQL->write("insert into groupings values ($gid, $session{form}{uid}, ".(time()+$expireAfter).")");
                }
                return www_editUser();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listUsers {
	my ($output, $sth, @data, @row, $dataRows, $prevNextBar, $i, $search);
        if (WebGUI::Privilege::isInGroup(3)) {
		$output = helpLink(8);
		$output .= '<h1>'.WebGUI::International::get(149).'</h1>';
		$output .= '<table class="tableData" align="center" width="75%"><tr><td>';
		$output .= '<a href="'.$session{page}{url}.'?op=addUser">'.WebGUI::International::get(169).'</a>';
		$output .= '</td>'.formHeader().'<td align="right">';
		$output .= WebGUI::Form::hidden("op","listUsers");
		$output .= WebGUI::Form::text("keyword",20,50);
		$output .= WebGUI::Form::submit(WebGUI::International::get(170));
		$output .= '</td></form></tr></table><p>';
		if ($session{form}{keyword} ne "") {
			$search = " and (username like '%".$session{form}{keyword}."%' or email like '%".$session{form}{keyword}."%') ";
		}
		$sth = WebGUI::SQL->read("select userId,username,email from users where username<>'Reserved' $search order by username");
		while (@data = $sth->array) {
			$row[$i] = '<tr class="tableData"><td>';
			$row[$i] .= '<a href="'.$session{page}{url}.'?op=deleteUser&uid='.$data[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a>';
			$row[$i] .= '<a href="'.$session{page}{url}.'?op=editUser&uid='.$data[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a>';
			$row[$i] .= '<a href="'.$session{page}{url}.'?op=becomeUser&uid='.$data[0].'"><img src="'.$session{setting}{lib}.'/become.gif" border=0></a>';
			$row[$i] .= '</td>';
			$row[$i] .= '<td><a href="'.$session{page}{url}.'?op=viewProfile&uid='.$data[0].'">'.$data[1].'</a></td>';
			#$row[$i] .= '<td>'.$data[1].'</td>';
			$row[$i] .= '<td><a href="mailto:'.$data[2].'">'.$data[2].'</a></td></tr>';
			$i++;
		}
		$sth->finish;
                ($dataRows, $prevNextBar) = paginate(50,$session{page}{url}.'?op=listUsers',\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $output .= $dataRows;
                $output .= '</table>';
                $output .= $prevNextBar;
		return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}


1;

