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
use WebGUI::Form;
use WebGUI::Operation::Help;
use WebGUI::Operation::Page;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_addUser &www_addUserSave &www_deleteUser &www_deleteUserConfirm &www_editUser &www_editUserSave &www_listUsers);

#-------------------------------------------------------------------
sub www_addUser {
        my ($output, %hash);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=5"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add User</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","addUserSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Username</td><td>'.WebGUI::Form::text("username",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Password</td><td>'.WebGUI::Form::password("identifier",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Email address</td><td>'.WebGUI::Form::text("email",20,255).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top"><a href="http://www.icq.com">ICQ</a> UIN</td><td>'.WebGUI::Form::text("icq",20,30).'</td></tr>';
                %hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">Groups</td><td>'.WebGUI::Form::selectList("groups",\%hash,'',5,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addUserSave {
        my ($output, @groups, $uid, $gid, $encryptedPassword, $passwordStatement);
        if (WebGUI::Privilege::isInGroup(3)) {
                $encryptedPassword = Digest::MD5::md5_base64($session{form}{identifier1});
                $passwordStatement = ', identifier='.quote($encryptedPassword);
		$uid = getNextId("userId");
                WebGUI::SQL->write("insert into user set userId=$uid, username=".quote($session{form}{username}).$passwordStatement.", email=".quote($session{form}{email}).", icq=".quote($session{form}{icq}),$session{dbh});
                @groups = $session{cgi}->param('groups');
                foreach $gid (@groups) {
                        WebGUI::SQL->write("insert into groupings set groupId=$gid, userId=$uid",$session{dbh});
                }
                $output = www_listUsers();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteUser {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3) && $session{form}{uid} > 25) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=7"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Please Confirm</h1>';
                $output .= 'Are you certain you want to delete this user? Be warned that all this user\'s information will be lost permanently if you choose to proceed.<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deleteUserConfirm&uid='.$session{form}{uid}.'">Yes, I\'m sure.</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'?op=listUsers">No, I made a mistake.</a></div>'; 
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteUserConfirm {
        if (WebGUI::Privilege::isInGroup(3) && $session{form}{uid} > 25) {
                WebGUI::SQL->write("delete from user where userId=$session{form}{uid}",$session{dbh});
                WebGUI::SQL->write("delete from groupings where userId=$session{form}{uid}",$session{dbh});
                return www_listUsers();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editUser {
        my ($output, %user, %hash, @array);
        if (WebGUI::Privilege::isInGroup(3)) {
		%user = WebGUI::SQL->quickHash("select * from user where userId=$session{form}{uid}",$session{dbh});
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=6"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit User</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editUserSave");
                $output .= WebGUI::Form::hidden("uid",$session{form}{uid});
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">username</td><td>'.WebGUI::Form::text("username",20,30,$user{username}).'</td></tr>';
                $output .= '<tr><td class="formDescription">password</td><td>'.WebGUI::Form::password("identifier",20,30,"password").'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">email address</td><td>'.WebGUI::Form::text("email",20,255,$user{email}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top"><a href="http://www.icq.com">ICQ</a> UIN</td><td>'.WebGUI::Form::text("icq",20,30,$user{icq}).'</td></tr>';
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName",$session{dbh});
		@array = WebGUI::SQL->buildArray("select groupId from groupings where userId=$session{form}{uid}",$session{dbh});
                $output .= '<tr><td class="formDescription" valign="top">Groups</td><td>'.WebGUI::Form::selectList("groups",\%hash,\@array,5,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
		$output = WebGUI::Privilege::insufficient();
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
                WebGUI::SQL->write("update user set username=".quote($session{form}{username}).$passwordStatement.", email=".quote($session{form}{email}).", icq=".quote($session{form}{icq})." where userId=".$session{form}{uid},$session{dbh});
		WebGUI::SQL->write("delete from groupings where userId=$session{form}{uid}",$session{dbh});
		@groups = $session{cgi}->param('groups');
		foreach $gid (@groups) {
			WebGUI::SQL->write("insert into groupings set groupId=$gid, userId=$session{form}{uid}",$session{dbh});
		}
		return www_listUsers();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_listUsers {
	my ($output, $sth, @data, $totalItems, $currentPage, $itemsPerPage);
        if (WebGUI::Privilege::isInGroup(3)) {
		$itemsPerPage = 50;
		if ($session{form}{pageNumber} < 1) {
			$currentPage = 1;
		} else {
			$currentPage = $session{form}{pageNumber};
		}
		($totalItems) = WebGUI::SQL->quickArray("select count(*) from user where username<>'Reserved'",$session{dbh});
		$output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=8"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Users</h1>';
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?op=addUser">Add a new user.</a></div>';
		$output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
		$sth = WebGUI::SQL->read("select userId,username,email from user where username<>'Reserved' order by username limit ".(($currentPage*$itemsPerPage)-$itemsPerPage).",".$itemsPerPage,$session{dbh});
		while (@data = $sth->array) {
			$output .= '<tr><td><a href="'.$session{page}{url}.'?op=deleteUser&uid='.$data[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?op=editUser&uid='.$data[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a></td>';
			#$output .= '<td><a href="'.$session{page}{url}.'?op=viewUserProfile&uid='.$data[0].'">'.$data[1].'</a></td>';
			$output .= '<td>'.$data[1].'</td>';
			$output .= '<td><a href="mailto:'.$data[2].'">'.$data[2].'</a></td></tr>';
		}
		$output .= '</table><div class="pagination">';
		if ($currentPage > 1) {
			$output .= '<a href="'.$session{page}{url}.'?op=listUsers&pageNumber='.($currentPage-1).'">&laquo;Previous Page</a>';
		} else {
			$output .= '&laquo;Previous Page';
		}
		$output .= ' &middot; ';
		if ($currentPage < round($totalItems/$itemsPerPage)) {
			$output .= '<a href="'.$session{page}{url}.'?op=listUsers&pageNumber='.($currentPage+1).'">Next Page&raquo;</a>';
		} else {
			$output .= 'Next Page&raquo;';
		}
		$output .= '</div>';
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;
