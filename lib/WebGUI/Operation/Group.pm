package WebGUI::Operation::Group;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

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
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_deleteGroup &www_deleteGroupConfirm &www_editGroup &www_editGroupSave &www_listGroups);

#-------------------------------------------------------------------
sub www_deleteGroup {
        my ($output);
        if ($session{form}{gid} < 26) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                $output .= helpIcon(15);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(86).'<p>';
                $output .= '<div align="center"><a href="'.
			WebGUI::URL::page('op=deleteGroupConfirm&gid='.$session{form}{gid}).
			'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listGroups').'">'.
			WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_deleteGroupConfirm {
        if ($session{form}{gid} < 26) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::isInGroup(3)) {
                WebGUI::SQL->write("delete from groups where groupId=$session{form}{gid}");
                WebGUI::SQL->write("delete from groupings where groupId=$session{form}{gid}");
                return www_listGroups();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_editGroup {
        my ($output, $sth, %group, %hash, $f);
	tie %group, 'Tie::CPHash';
	tie %hash, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
		if ($session{form}{gid} eq "new") {
			$group{expireAfter} = 314496000;
			$group{karmaThreshold} = 1000000000;
		} else {
                	%group = WebGUI::SQL->quickHash("select * from groups where groupId=$session{form}{gid}");
		}
                $output .= helpIcon(17);
		$output .= '<h1>'.WebGUI::International::get(87).'</h1>';
		$f = WebGUI::HTMLForm->new;
                $f->hidden("op","editGroupSave");
                $f->hidden("gid",$session{form}{gid});
		$f->readOnly($session{form}{gid},WebGUI::International::get(379));
                $f->text("groupName",WebGUI::International::get(84),$group{groupName});
                $f->textarea("description",WebGUI::International::get(85),$group{description});
                $f->integer("expireAfter",WebGUI::International::get(367),$group{expireAfter});
		if ($session{setting}{useKarma}) {
                	$f->integer("karmaThreshold",WebGUI::International::get(538),$group{karmaThreshold});
		} else {
                	$f->hidden("karmaThreshold",$group{karmaThreshold});
		}
		$f->submit;
		$output .= $f->print;
		unless ($session{form}{gid} eq "new") {
			$output .= '<h1>'.WebGUI::International::get(88).'</h1>';
                	$output .= '<table><tr><td class="tableHeader">&nbsp;</td>
				<td class="tableHeader">'.WebGUI::International::get(50).'</td>
				<td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
                	$sth = WebGUI::SQL->read("select users.username,users.userId,groupings.expireDate 
				from groupings,users where groupings.groupId=$session{form}{gid} and groupings.userId=users.userId 
				order by users.username");
                	while (%hash = $sth->hash) {
                        	$output .= '<tr><td>'
					.deleteIcon('op=deleteGrouping&uid='.$hash{userId}.'&gid='.$session{form}{gid})
					.editIcon('op=editGrouping&uid='.$hash{userId}.'&gid='.$session{form}{gid})
					.'</td>';
                        	$output .= '<td class="tableData"><a href="'.WebGUI::URL::page('op=editUser&uid='.$hash{userId}).'">'
					.$hash{username}.'</a></td>';
                        	$output .= '<td class="tableData">'.epochToHuman($hash{expireDate},"%z").'</td></tr>';
                	}
                	$sth->finish;
                	$output .= '</table>';
		}
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editGroupSave {
        if (WebGUI::Privilege::isInGroup(3)) {
		if ($session{form}{gid} eq "new") {
			$session{form}{gid} = getNextId("groupId");
			WebGUI::SQL->write("insert into groups (groupId) values ($session{form}{gid})");
		}
                WebGUI::SQL->write("update groups set groupName=".quote($session{form}{groupName}).", 
			description=".quote($session{form}{description}).", expireAfter='$session{form}{expireAfter}',
			karmaThreshold='$session{form}{karmaThreshold}'
			where groupId=".$session{form}{gid});
                return www_listGroups();
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_listGroups {
        my ($output, $p, $sth, @data, @row, $i);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output = helpIcon(10);
		$output .= '<h1>'.WebGUI::International::get(89).'</h1>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=editGroup&gid=new').'">'.WebGUI::International::get(90).'</a></div>';
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $sth = WebGUI::SQL->read("select groupId,groupName,description from groups 
			where groupId<>1 and groupId<>2 and groupId<>7 order by groupName");
                while (@data = $sth->array) {
                        $row[$i] = '<tr><td valign="top" class="tableData"><a href="'.
				WebGUI::URL::page('op=deleteGroup&gid='.$data[0]).
				'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.
				WebGUI::URL::page('op=editGroup&gid='.$data[0]).
				'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a></td>';
                        $row[$i] .= '<td valign="top" class="tableData">'.$data[1].'</td>';
                        $row[$i] .= '<td valign="top" class="tableData">'.$data[2].'</td></tr>';
                        $i++;
                }
		$sth->finish;
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listGroups'),\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $output .= $p->getPage($session{form}{pn});
                $output .= '</table>';
                $output .= $p->getBarTraditional($session{form}{pn});
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}


1;
