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
our @EXPORT = qw(&www_addUser &www_addUserSave &www_deleteUser &www_deleteUserConfirm &www_editUser &www_editUserSave &www_listUsers);

#-------------------------------------------------------------------
sub www_addUser {
        my ($output, %hash, @array);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=5"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
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
                $output .= '<tr><td class="formDescription" valign="top">'.WebGUI::International::get(304).'</td><td>'.WebGUI::Form::selectList("language",\%hash).'</td></tr>';
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
                WebGUI::SQL->write("insert into users values ($uid, ".quote($session{form}{username}).", ".quote($encryptedPassword).", ".quote($session{form}{email}).", ".quote($session{form}{authMethod}).", ".quote($session{form}{ldapURL}).", ".quote($session{form}{connectDN}).", ".quote($session{form}{language}).", '')",$session{dbh});
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
sub www_deleteUser {
        my ($output);
        if ($session{form}{uid} < 26) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=7"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
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
        my ($output, %user, %hash, @array);
	tie %hash, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
		%user = WebGUI::SQL->quickHash("select * from users where userId=$session{form}{uid}",$session{dbh});
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=5"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
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
                WebGUI::SQL->write("update users set username=".quote($session{form}{username}).$passwordStatement.", authMethod=".quote($session{form}{authMethod}).", ldapURL=".quote($session{form}{ldapURL}).", connectDN=".quote($session{form}{connectDN}).", email=".quote($session{form}{email}).", language=".quote($session{form}{language})." where userId=".$session{form}{uid},$session{dbh});
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
	my ($output, $sth, @data, @row, $pn, $i, $itemsPerPage, $search);
        if (WebGUI::Privilege::isInGroup(3)) {
		$itemsPerPage = 50;
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=8"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
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
		$output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
		$sth = WebGUI::SQL->read("select userId,username,email from users where username<>'Reserved' $search order by username",$session{dbh});
		while (@data = $sth->array) {
			$row[$i] = '<tr class="tableData"><td><a href="'.$session{page}{url}.'?op=deleteUser&uid='.$data[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?op=editUser&uid='.$data[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a></td>';
			#$row[$i] .= '<td><a href="'.$session{page}{url}.'?op=viewUserProfile&uid='.$data[0].'">'.$data[1].'</a></td>';
			$row[$i] .= '<td>'.$data[1].'</td>';
			$row[$i] .= '<td><a href="mailto:'.$data[2].'">'.$data[2].'</a></td></tr>';
			$i++;
		}
		if ($session{form}{pn} < 1) {
                        $pn = 0;
                } else {
                        $pn = $session{form}{pn};
                }
                for ($i=($itemsPerPage*$pn); $i<($itemsPerPage*($pn+1));$i++) {
                        $output .= $row[$i];
                }
                $output .= '</table>';
                $output .= '<div class="pagination">';
                if ($pn > 0) {
                        $output .= '<a href="'.$session{page}{url}.'?pn='.($pn-1).'&op=listUsers">&laquo;'.WebGUI::International::get(91).'</a>';
                } else {
                        $output .= '&laquo;'.WebGUI::International::get(91);
                }
                $output .= ' &middot; ';
                if ($pn < round($#row/$itemsPerPage)) {
                        $output .= '<a href="'.$session{page}{url}.'?pn='.($pn+1).'&op=listUsers">'.WebGUI::International::get(92).'&raquo;</a>';
                } else {
                        $output .= WebGUI::International::get(92).'&raquo;';
                }
                $output .= '</div>';
		return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}


1;

