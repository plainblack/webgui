package WebGUI::Operation::User;

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
use Tie::CPHash;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_becomeUser &www_addUser &www_addUserSave &www_deleteUser &www_deleteUserConfirm &www_editUser &www_editUserSave &www_listUsers);

#-------------------------------------------------------------------
sub www_addUser {
        my ($output, %hash, @array);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=5&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(163).'</h1>';
		$output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","addUserSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.WebGUI::Form::text("username",20,30).'</td></tr>';
               	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(51).'</td><td>'.WebGUI::Form::password("identifier",20,30).'</td></tr>';
		%hash = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
		$array[0] = $session{setting}{authMethod};
               	$output .= '<tr><td class="formDescription">'.WebGUI::International::get(164).'</td><td>'.WebGUI::Form::selectList("authMethod",\%hash, \@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(165).'</td><td>'.WebGUI::Form::text("ldapURL",20,2048,$session{setting}{ldapURL}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(166).'</td><td>'.WebGUI::Form::text("connectDN",20,255).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(56).'</td><td>'.WebGUI::Form::text("email",20,255).'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		$array[0] = 2;
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(89).'</td><td>'.WebGUI::Form::selectList("groups",\%hash,\@array,5,1).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select distinct(language) from international",$session{dbh});
		$array[0] = "English";
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(304).'</td><td>'.WebGUI::Form::selectList("language",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addUserSave {
        my ($output, @groups, $uid, $gid, $encryptedPassword);
        if (WebGUI::Privilege::isInGroup(3)) {
                $encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
		$uid = getNextId("userId");
                WebGUI::SQL->write("insert into users (userId,username,identifier,email,authMethod,ldapURL,connectDN,language) values ($uid, ".quote($session{form}{username}).", ".quote($encryptedPassword).", ".quote($session{form}{email}).", ".quote($session{form}{authMethod}).", ".quote($session{form}{ldapURL}).", ".quote($session{form}{connectDN}).", ".quote($session{form}{language}).")",$session{dbh});
                @groups = $session{cgi}->param('groups');
                foreach $gid (@groups) {
                        WebGUI::SQL->write("insert into groupings values ($gid, $uid)",$session{dbh});
                }
                $output = www_listUsers();
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_becomeUser {
        my ($cookieInfo, $output, $password);
        if (WebGUI::Privilege::isInGroup(3)) {
		($password) = WebGUI::SQL->quickArray("select identifier from users where userId='$session{form}{uid}'",$session{dbh});
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
sub www_deleteUser {
        my ($output);
        if ($session{form}{uid} < 26) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=7&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
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
                WebGUI::SQL->write("delete from users where userId=$session{form}{uid}",$session{dbh});
                WebGUI::SQL->write("delete from groupings where userId=$session{form}{uid}",$session{dbh});
                return www_listUsers();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editUser {
        my ($output, %user, %hash, @array, %gender);
	tie %hash, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
		%gender = ('male'=>WebGUI::International::get(339),'female'=>WebGUI::International::get(340));
		%user = WebGUI::SQL->quickHash("select * from users where userId=$session{form}{uid}",$session{dbh});
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=5&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(168).'</h1>';
		$output .= ' <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editUserSave");
                $output .= WebGUI::Form::hidden("uid",$session{form}{uid});
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(50).'</td><td>'.WebGUI::Form::text("username",20,30,$user{username}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(51).'</td><td>'.WebGUI::Form::password("identifier",20,30,"password").'</td></tr>';
		%hash = ('WebGUI'=>'WebGUI', 'LDAP'=>'LDAP');
		$array[0] = $user{authMethod};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(164).'</td><td>'.WebGUI::Form::selectList("authMethod",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(165).'</td><td>'.WebGUI::Form::text("ldapURL",20,2048,$user{ldapURL}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(166).'</td><td>'.WebGUI::Form::text("connectDN",20,255,$user{connectDN}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(56).'</td><td>'.WebGUI::Form::text("email",20,255,$user{email}).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		@array = WebGUI::SQL->buildArray("select groupId from groupings where userId=$session{form}{uid}",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(89).'</td><td>'.WebGUI::Form::selectList("groups",\%hash,\@array,5,1).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select distinct(language) from international",$session{dbh});
		@array = [];
		$array[0] = $user{language};
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(304).'</td><td>'.WebGUI::Form::selectList("language",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(314).'</td><td>'.WebGUI::Form::text("firstName",20,50,$user{firstName}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(315).'</td><td>'.WebGUI::Form::text("middleName",20,50,$user{middleName}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(316).'</td><td>'.WebGUI::Form::text("lastName",20,50,$user{lastName}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(317).'</td><td>'.WebGUI::Form::text("icq",20,30,$user{icq}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(318).'</td><td>'.WebGUI::Form::text("aim",20,30,$user{aim}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(319).'</td><td>'.WebGUI::Form::text("msnIM",20,30,$user{msnIM}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(320).'</td><td>'.WebGUI::Form::text("yahooIM",20,30,$user{yahooIM}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(321).'</td><td>'.WebGUI::Form::text("cellPhone",20,30,$user{cellPhone}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(322).'</td><td>'.WebGUI::Form::text("pager",20,30,$user{pager}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(323).'</td><td>'.WebGUI::Form::text("homeAddress",20,128,$user{homeAddress}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(324).'</td><td>'.WebGUI::Form::text("homeCity",20,30,$user{homeCity}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(325).'</td><td>'.WebGUI::Form::text("homeState",20,30,$user{homeState}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(326).'</td><td>'.WebGUI::Form::text("homeZip",20,15,$user{homeZip}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(327).'</td><td>'.WebGUI::Form::text("homeCountry",20,30,$user{homeCountry}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(328).'</td><td>'.WebGUI::Form::text("homePhone",20,30,$user{homePhone}).'</td></tr>';
		$output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(329).'</td><td>'.WebGUI::Form::text("workAddress",20,128,$user{workAddress}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(330).'</td><td>'.WebGUI::Form::text("workCity",20,30,$user{workCity}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(331).'</td><td>'.WebGUI::Form::text("workState",20,30,$user{workState}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(332).'</td><td>'.WebGUI::Form::text("workZip",20,15,$user{workZip}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(333).'</td><td>'.WebGUI::Form::text("workCountry",20,30,$user{workCountry}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(334).'</td><td>'.WebGUI::Form::text("workPhone",20,30,$user{workPhone}).'</td></tr>';
		@array = ($user{gender});
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(335).'</td><td>'.WebGUI::Form::selectList("gender",\%gender,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(336).'</td><td>'.WebGUI::Form::text("birthdate",20,30,$user{birthdate}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(337).'</td><td>'.WebGUI::Form::text("homepage",20,2048,$user{homepage}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
		$output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editUserSave {
        my (@groups, $error, $gid, $encryptedPassword, $passwordStatement);
        if (WebGUI::Privilege::isInGroup(3)) {
                if ($session{form}{identifier} ne "password") {
                        $encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier});
                        $passwordStatement = ', identifier='.quote($encryptedPassword);
                }
                $encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
                WebGUI::SQL->write("update users set username=".quote($session{form}{username}).$passwordStatement.", authMethod=".quote($session{form}{authMethod}).", ldapURL=".quote($session{form}{ldapURL}).", connectDN=".quote($session{form}{connectDN}).", email=".quote($session{form}{email}).", language=".quote($session{form}{language}).", firstName=".quote($session{form}{firstName}).", middleName=".quote($session{form}{middleName}).", lastName=".quote($session{form}{lastName}).", icq=".quote($session{form}{icq}).", aim=".quote($session{form}{aim}).", msnIM=".quote($session{form}{msnIM}).", yahooIM=".quote($session{form}{yahooIM}).", homeAddress=".quote($session{form}{homeAddress}).", homeCity=".quote($session{form}{homeCity}).", homeState=".quote($session{form}{homeState}).", homeZip=".quote($session{form}{homeZip}).", homeCountry=".quote($session{form}{homeCountry}).", homePhone=".quote($session{form}{homePhone}).", workAddress=".quote($session{form}{workAddress}).", workCity=".quote($session{form}{workCity}).", workState=".quote($session{form}{workState}).", workZip=".quote($session{form}{workZip}).", workCountry=".quote($session{form}{workCountry}).", workPhone=".quote($session{form}{workPhone}).", cellPhone=".quote($session{form}{cellPhone}).", pager=".quote($session{form}{pager}).", gender=".quote($session{form}{gender}).", birthdate=".quote($session{form}{birthdate}).", homepage=".quote($session{form}{homepage})." where userId=".$session{form}{uid},$session{dbh});
		WebGUI::SQL->write("delete from groupings where userId=$session{form}{uid}",$session{dbh});
		@groups = $session{cgi}->param('groups');
		foreach $gid (@groups) {
			WebGUI::SQL->write("insert into groupings values ($gid, $session{form}{uid})",$session{dbh});
		}
		return www_listUsers();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listUsers {
	my ($output, $sth, @data, @row, $dataRows, $prevNextBar, $i, $search);
        if (WebGUI::Privilege::isInGroup(3)) {
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=8&namespace=WebGUI"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(149).'</h1>';
		$output .= '<table class="tableData" align="center" width="75%"><tr><td>';
		$output .= '<a href="'.$session{page}{url}.'?op=addUser">'.WebGUI::International::get(169).'</a>';
		$output .= '</td><form method="post" action="'.$session{page}{url}.'"><td align="right">';
		$output .= WebGUI::Form::hidden("op","listUsers");
		$output .= WebGUI::Form::text("keyword",20,50);
		$output .= WebGUI::Form::submit(WebGUI::International::get(170));
		$output .= '</td></form></tr></table><p>';
		if ($session{form}{keyword} ne "") {
			$search = " and (username like '%".$session{form}{keyword}."%' or email like '%".$session{form}{keyword}."%') ";
		}
		$sth = WebGUI::SQL->read("select userId,username,email from users where username<>'Reserved' $search order by username",$session{dbh});
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

