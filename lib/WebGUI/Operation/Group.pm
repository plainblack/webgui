package WebGUI::Operation::Group;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Form;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_addGroup &www_addGroupSave &www_deleteGroup &www_deleteGroupConfirm &www_editGroup &www_editGroupSave &www_listGroups);

#-------------------------------------------------------------------
sub www_addGroup {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=17"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Group</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","addGroupSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">Group Name</td><td>'.WebGUI::Form::text("groupName",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Description</td><td>'.WebGUI::Form::textArea("description",'').'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addGroupSave {
        my ($output);
        if ($session{var}{sessionId}) {
                WebGUI::SQL->write("insert into groups set groupId=".getNextId("groupId").", groupName=".quote($session{form}{groupName}).", description=".quote($session{form}{description}),$session{dbh});
                $output = www_listGroups();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteGroup {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3) && $session{form}{gid} > 25) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=15"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Please Confirm</h1>';
                $output .= 'Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?op=deleteGroupConfirm&gid='.$session{form}{gid}.'">Yes, I\'m sure.</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'?op=listGroups">No, I made a mistake. </a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteGroupConfirm {
        if (WebGUI::Privilege::isInGroup(3) && $session{form}{gid} > 25) {
                WebGUI::SQL->write("delete from groups where groupId=$session{form}{gid}",$session{dbh});
                WebGUI::SQL->write("delete from groupings where groupId=$session{form}{gid}",$session{dbh});
                return www_listGroups();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editGroup {
        my ($output, $sth, %group, $user);
        if (WebGUI::Privilege::isInGroup(3)) {
                %group = WebGUI::SQL->quickHash("select * from groups where groupId=$session{form}{gid}",$session{dbh});
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=13"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Group</h1> <form method="post" action="'.$session{page}{url}.'"> ';
                $output .= WebGUI::Form::hidden("op","editGroupSave");
                $output .= WebGUI::Form::hidden("gid",$session{form}{gid});
                $output .= '<table>';
                $output .= '<tr><td class="formDescription" valign="top">Group Name</td><td>'.WebGUI::Form::text("groupName",20,30,$group{groupName}).'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Description</td><td>'.WebGUI::Form::textArea("description",$group{description}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '<tr><td class="formDescription" valign="top">Users In Group</td><td valign="top">';
		$sth = WebGUI::SQL->read("select user.username from user,groupings where groupings.groupId=$session{form}{gid} and groupings.userId=user.userId order by user.username",$session{dbh});
		while (($user) = $sth->array) {
			$output .= $user."<br>";
		}
		$sth->finish;
		$output .= '<br></td></tr>';
                $output .= '</table>';
                $output .= '</form> ';
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editGroupSave {
        if (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("update groups set groupName=".quote($session{form}{groupName}).", description=".quote($session{form}{description})." where groupId=".$session{form}{gid},$session{dbh});
                return www_listGroups();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_listGroups {
        my ($output, $pn, $sth, @data, @row, $i, $itemsPerPage);
        if (WebGUI::Privilege::isInGroup(3)) {
                $itemsPerPage = 50;
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=10"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Groups</h1>';
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?op=addGroup">Add a new group.</a></div>';
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $sth = WebGUI::SQL->read("select groupId,groupName,description from groups where groupName<>'Reserved' order by groupName",$session{dbh});
                while (@data = $sth->array) {
                        $row[$i] = '<tr><td valign="top"><a href="'.$session{page}{url}.'?op=deleteGroup&gid='.$data[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?op=editGroup&gid='.$data[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a></td>';
                        $row[$i] .= '<td valign="top">'.$data[1].'</td>';
                        $row[$i] .= '<td valign="top">'.$data[2].'</td></tr>';
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
                        $output .= '<a href="'.$session{page}{url}.'?pn='.($pn-1).'&op=listGroups">&laquo;Previous Page</a>';
                } else {
                        $output .= '&laquo;Previous Page';
                }
                $output .= ' &middot; ';
                if ($pn < round($#row/$itemsPerPage)) {
                        $output .= '<a href="'.$session{page}{url}.'?pn='.($pn+1).'&op=listGroups">Next Page&raquo;</a>';
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
