package WebGUI::Operation::Group;

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
use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Mail;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_manageUsersInGroup &www_deleteGroup &www_deleteGroupConfirm &www_editGroup 
	&www_editGroupSave &www_listGroups &www_emailGroup &www_emailGroupSend &www_manageGroupsInGroup
	&www_addGroupsToGroupSave &www_deleteGroupGrouping);

#-------------------------------------------------------------------
sub _submenu {
        my ($output, %menu);
        tie %menu, 'Tie::IxHash';
        $menu{WebGUI::URL::page('op=editGroup&gid=new')} = WebGUI::International::get(90);
        unless ($session{form}{op} eq "listGroups" 
		|| $session{form}{gid} eq "new" 
		|| $session{form}{op} eq "deleteGroupConfirm") {
                $menu{WebGUI::URL::page("op=editGroup&gid=".$session{form}{gid})} = WebGUI::International::get(753);
                $menu{WebGUI::URL::page("op=manageUsersInGroup&gid=".$session{form}{gid})} = WebGUI::International::get(754);
                $menu{WebGUI::URL::page("op=manageGroupsInGroup&gid=".$session{form}{gid})} = WebGUI::International::get(807);
                $menu{WebGUI::URL::page("op=emailGroup&gid=".$session{form}{gid})} = WebGUI::International::get(808);
                $menu{WebGUI::URL::page("op=deleteGroup&gid=".$session{form}{gid})} = WebGUI::International::get(806);
        }
        $menu{WebGUI::URL::page("op=listGroups")} = WebGUI::International::get(756);
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_addGroupsToGroupSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my (@groups, $group);
        @groups = $session{cgi}->param('groups');
	foreach $group (@groups) {
		WebGUI::SQL->write("insert into groupGroupings values ($group,$session{form}{gid})");
	}
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_deleteGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output);
        return WebGUI::Privilege::vitalComponent() if ($session{form}{gid} < 26);
        $output .= helpIcon(15);
	$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
        $output .= WebGUI::International::get(86).'<p>';
        $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteGroupConfirm&gid='.$session{form}{gid}).
		'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listGroups').'">'
		.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_deleteGroupConfirm {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{gid} < 26);
        WebGUI::SQL->write("delete from groups where groupId=$session{form}{gid}");
        WebGUI::SQL->write("delete from groupings where groupId=$session{form}{gid}");
        return www_listGroups();
}

#-------------------------------------------------------------------
sub www_deleteGroupGrouping {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	WebGUI::SQL->write("delete from groupGroupings where inGroup=$session{form}{gid} and groupId=$session{form}{delete}");
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_editGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, %group, $f);
	tie %group, 'Tie::CPHash';
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
        $f->interval("expireAfter",WebGUI::International::get(367), WebGUI::DateTime::secondsToInterval($group{expireAfter}));
	if ($session{setting}{useKarma}) {
               	$f->integer("karmaThreshold",WebGUI::International::get(538),$group{karmaThreshold});
	} else {
               	$f->hidden("karmaThreshold",$group{karmaThreshold});
	}
	$f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editGroupSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	if ($session{form}{gid} eq "new") {
		$session{form}{gid} = getNextId("groupId");
		WebGUI::SQL->write("insert into groups (groupId) values ($session{form}{gid})");
	}
        WebGUI::SQL->write("update groups set groupName=".quote($session{form}{groupName}).", 
		description=".quote($session{form}{description}).", 
		expireAfter='".WebGUI::DateTime::intervalToSeconds($session{form}{expireAfter_interval},
		$session{form}{expireAfter_units})."',
		karmaThreshold='$session{form}{karmaThreshold}'
		where groupId=".$session{form}{gid});
        return www_listGroups();
}

#-------------------------------------------------------------------
sub www_emailGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	my ($output,$f);
	$output = '<h1>'.WebGUI::International::get(809).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->hidden("op","emailGroupSend");
	$f->hidden("gid",$session{form}{gid});
	$f->email(
		-name=>"from",
		-value=>$session{setting}{companyEmail},
		-label=>WebGUI::International::get(811)
		);
	$f->text(
		-name=>"subject",
		-label=>WebGUI::International::get(229)
		);
	$f->textarea(
		-name=>"message",
		-label=>WebGUI::International::get(230),
		-rows=>(5+$session{setting}{textAreaRows})
		);
	$f->submit(WebGUI::International::get(810));
	$output = $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_emailGroupSend {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	my ($sth, $email);
	$sth = WebGUI::SQL->read("select b.fieldData from groupings a left join userProfileData b 
		on a.userId=b.userId and b.fieldName='email' where a.groupId=$session{form}{gid}");
	while (($email) = $sth->array) {
		if ($email ne "") {
			WebGUI::Mail::send($email,$session{form}{subject},$session{form}{message},'',$session{form}{from});
		}
	}
	$sth->finish;
	return _submenu(WebGUI::International::get(812));
}

#-------------------------------------------------------------------
sub www_listGroups {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, $p, $sth, @data, @row, $i, $userCount);
        $output = helpIcon(10);
	$output .= '<h1>'.WebGUI::International::get(89).'</h1>';
        $sth = WebGUI::SQL->read("select groupId,groupName,description from groups 
		where groupId<>1 and groupId<>2 and groupId<>7 order by groupName");
        while (@data = $sth->array) {
                $row[$i] = '<tr>';
                $row[$i] .= '<td valign="top" class="tableData"><a href="'
			.WebGUI::URL::page('op=editGroup&gid='.$data[0]).'">'.$data[1].'</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data[2].'</td>';
		($userCount) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId=$data[0]");
                $row[$i] .= '<td valign="top" class="tableData">'.$userCount.'</td></tr>';
                $row[$i] .= '</tr>';
                $i++;
        }
	$sth->finish;
        $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listGroups'),\@row);
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(84).'</td><td class="tableHeader">'
		.WebGUI::International::get(85).'</td><td class="tableHeader">'
		.WebGUI::International::get(748).'</td></tr>';
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_manageGroupsInGroup {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	my ($output, $p, $group, $groups, @array, $f);
	$output = '<h1>'.WebGUI::International::get(813).'</h1><div align="center">';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","addGroupsToGroupSave");
        $f->hidden("gid",$session{form}{gid});
        @array = WebGUI::SQL->buildArray("select groupId from groupGroupings where inGroup='$session{form}{gid}'");
	push(@array,$session{form}{gid});
     #   push(@array,1); #visitors
     #   push(@array,2); #registered users
     #   push(@array,7); #everyone
        $groups = WebGUI::SQL->buildHashRef("select groupId,groupName from groups where groupId not in (".join(",",@array).") order by groupName");
        $f->select("groups",$groups,WebGUI::International::get(605),[],5,1);
        $f->submit;
        $output .= $f->print;

	$output .= '</div><p/><table class="tableData" align="center">';
	$output .= '<tr class="tableHeader"><td></td><td>'.WebGUI::International::get(84).'</td></tr>';
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=manageGroupsInGroup'));
	$p->setDataByQuery("select a.groupName as name,a.groupId as id from groups a 
		left join groupGroupings b on a.groupId=b.groupId 
		where b.inGroup=$session{form}{gid} order by a.groupName");
	$groups = $p->getPageData;
	foreach $group (@$groups) {
		$output .= '<tr><td>'
			.deleteIcon('op=deleteGroupGrouping&gid='.$session{form}{gid}.'&delete='.$group->{id})
			.'</td><td><a href="'.WebGUI::URL::page('op=editGroup&gid='.$group->{id}).'">'
			.$group->{name}.'</a></td></tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_manageUsersInGroup {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, $sth, %hash);
        tie %hash, 'Tie::CPHash';
        $output = '<h1>'.WebGUI::International::get(88).'</h1>';
        $output .= '<table align="center" border="1" cellpadding="2" cellspacing="0"><tr><td class="tableHeader">&nbsp;</td>
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
        return _submenu($output);
}



1;
