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
use WebGUI::DatabaseLink;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::FormProcessor;
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
	&www_addGroupsToGroupSave &www_deleteGroupGrouping &www_autoAddToGroup &www_autoDeleteFromGroup
	&www_listGroupsSecondary &www_manageUsersInGroupSecondary &www_addUsersToGroupSave &www_addUsersToGroupSecondarySave
	&www_deleteGroupingSecondary);


#-------------------------------------------------------------------
sub _hasSecondaryPrivilege {
	return 0 unless (WebGUI::Privilege::isInGroup(11));
	return WebGUI::Grouping::userGroupAdmin($session{user}{userId},$_[0]);
}


#-------------------------------------------------------------------
sub _submenu {
        my ($output, %menu);
        tie %menu, 'Tie::IxHash';
	if (WebGUI::Privilege::isInGroup(3)) {
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
	} else {
        	$menu{WebGUI::URL::page("op=listGroupsSecondary")} = WebGUI::International::get(756);
	}
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_addGroupsToGroupSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my @groups = $session{cgi}->param('groups');
	WebGUI::Grouping::addGroupsToGroups(\@groups,[$session{form}{gid}]);
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_addUsersToGroupSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my @users = $session{cgi}->param('users');
	WebGUI::Grouping::addUsersToGroups(\@users,[$session{form}{gid}]);
        return www_manageUsersInGroup();
}

#-------------------------------------------------------------------
sub www_addUsersToGroupSecondarySave {
        return WebGUI::Privilege::adminOnly() unless _hasSecondaryPrivilege($session{form}{gid});
        my @users = $session{cgi}->param('users');
	WebGUI::Grouping::addUsersToGroups(\@users,[$session{form}{gid}]);
        return www_manageUsersInGroupSecondary();
}

#-------------------------------------------------------------------
sub www_autoAddToGroup {
        return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	my $group = WebGUI::Group->new($session{form}{groupId});
	if ($group->autoAdd) {
		WebGUI::Grouping::addUsersToGroups([$session{user}{userId}],[$session{form}{groupId}]);
	}
	return "";
}

#-------------------------------------------------------------------
sub www_autoDeleteFromGroup {
        return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	my $group = WebGUI::Group->new($session{form}{groupId});
	if ($group->autoDelete) {
		WebGUI::Grouping::deleteUsersFromGroups([$session{user}{userId}],[$session{form}{groupId}]);
	}
	return "";
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
	my $g = WebGUI::Group->new($session{form}{gid});
	$g->delete;
        return www_listGroups();
}

#-------------------------------------------------------------------
sub www_deleteGroupGrouping {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	WebGUI::Grouping::deleteGroupsFromGroups([$session{form}{delete}],[$session{form}{gid}]);
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_deleteGroupingSecondary {
        return WebGUI::Privilege::adminOnly() unless _hasSecondaryPrivilege($session{form}{gid});
        if ($session{user}{userId} == $session{form}{uid}) {
                return WebGUI::Privilege::vitalComponent();
        }
        WebGUI::Grouping::deleteUsersFromGroups([$session{form}{uid}],[$session{form}{gid}]);
        return www_manageUsersInGroupSecondary();
}

#-------------------------------------------------------------------
sub www_editGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
        my ($output, $f, $g);
	if ($session{form}{gid} eq "new") {
		$g = WebGUI::Group->new("");
	} else {
		$g = WebGUI::Group->new($session{form}{gid});
	}
        $output .= helpIcon(17);
	$output .= '<h1>'.WebGUI::International::get(87).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","editGroupSave");
        $f->hidden("gid",$session{form}{gid});
	$f->readOnly($g->groupId,WebGUI::International::get(379));
        $f->text("groupName",WebGUI::International::get(84),$g->name);
        $f->textarea("description",WebGUI::International::get(85),$g->description);
        $f->interval("expireOffset",WebGUI::International::get(367), WebGUI::DateTime::secondsToInterval($g->expireOffset));
	$f->yesNo(
		-name=>"expireNotify",
		-value=>$g->expireNotify,
		-label=>WebGUI::International::get(865)
		);
	$f->integer(
		-name=>"expireNotifyOffset",
		-value=>$g->expireNotifyOffset,
		-label=>WebGUI::International::get(864)
		);
        $f->textarea(
                -name=>"expireNotifyMessage",
		-value=>$g->expireNotifyMessage,
		-label=>WebGUI::International::get(866)
                );
        $f->integer(
                -name=>"deleteOffset",
                -value=>$g->deleteOffset,
                -label=>WebGUI::International::get(863)
                );
	if ($session{setting}{useKarma}) {
		$f->integer(
                        -name=>"karmaThreshold",
                        -label=>WebGUI::International::get(538),
                        -value=>$g->karmaThreshold
                        );
	}
	$f->textarea(
		-name=>"ipFilter",
		-value=>$g->ipFilter,
		-label=>WebGUI::International::get(857)
		);
	$f->textarea(
		-name=>"scratchFilter",
		-value=>$g->scratchFilter,
		-label=>WebGUI::International::get(945)
		);
	$f->yesNo(
		-name=>"autoAdd",
		-value=>$g->autoAdd,
		-label=>WebGUI::International::get(974)
		);
	$f->yesNo(
		-name=>"autoDelete",
		-value=>$g->autoDelete,
		-label=>WebGUI::International::get(975)
		);
	my %databaseLinkOptions;
	tie %databaseLinkOptions, 'Tie::IxHash',
		"0"=>WebGUI::International::get(19,'SQLReport'),
		WebGUI::DatabaseLink::getHash();
	$f->selectList(
		-name=>"databaseLinkId",
		-options=>\%databaseLinkOptions,
		-label=>WebGUI::International::get(20,'SQLReport'),
		-value=>[$g->databaseLinkId],
		-subtext=>(WebGUI::Privilege::isInGroup(3)) ? '<a href="'.WebGUI::URL::page("op=listDatabaseLinks").'">'.WebGUI::International::get(981).'</a>' : ""
		);
	$f->textarea(
		-name=>"dbQuery",
		-value=>$g->dbQuery,
		-label=>WebGUI::International::get(1005)
		);
	$f->interval("dbCacheTimeout",WebGUI::International::get(1004), WebGUI::DateTime::secondsToInterval($g->dbCacheTimeout));
	$f->submit;
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editGroupSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(3));
	my $g = WebGUI::Group->new($session{form}{gid});
	$g->description($session{form}{description});
	$g->name($session{form}{groupName});
	$g->expireOffset(WebGUI::FormProcessor::interval("expireOffset"));
	$g->karmaThreshold($session{form}{karmaThreshold});
	$g->ipFilter($session{form}{ipFilter});
	$g->scratchFilter($session{form}{scratchFilter});
	$g->expireNotify(WebGUI::FormProcessor::yesNo("expireNotify"));
	$g->expireNotifyOffset($session{form}{expireNotifyOffset});
	$g->expireNotifyMessage($session{form}{expireNotifyMessage});
	$g->deleteOffset($session{form}{deleteOffset});
	$g->autoAdd(WebGUI::FormProcessor::yesNo("autoAdd"));
	$g->autoDelete(WebGUI::FormProcessor::yesNo("autoDelete"));
	$g->databaseLinkId($session{form}{databaseLinkId});
	$g->dbQuery($session{form}{dbQuery});
	$g->dbCacheTimeout(WebGUI::FormProcessor::interval("dbCacheTimeout"));
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
sub www_listGroupsSecondary {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Privilege::isInGroup(11));
        my ($output, $p, $sth, @data, @row, $i, $userCount);
	$output .= '<h1>'.WebGUI::International::get(89).'</h1>';
	my @editableGroups = WebGUI::SQL->buildArray("select groupId from groupings where userId=$session{user}{userId} and groupAdmin=1");
	push (@editableGroups,0);
        $sth = WebGUI::SQL->read("select groupId,groupName,description from groups 
		where groupId in (".join(",",@editableGroups).") order by groupName");
        while (@data = $sth->array) {
                $row[$i] = '<tr>';
                $row[$i] .= '<td valign="top" class="tableData"><a href="'
			.WebGUI::URL::page('op=manageUsersInGroupSecondary&gid='.$data[0]).'">'.$data[1].'</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data[2].'</td>';
		($userCount) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId=$data[0]");
                $row[$i] .= '<td valign="top" class="tableData">'.$userCount.'</td></tr>';
                $row[$i] .= '</tr>';
                $i++;
        }
	$sth->finish;
        $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listGroupsSecondary'),\@row);
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
	my ($output, $p, $group, $groups, $f);
	$output = '<h1>'.WebGUI::International::get(813).'</h1><div align="center">';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","addGroupsToGroupSave");
        $f->hidden("gid",$session{form}{gid});
	$groups = WebGUI::Grouping::getGroupsInGroup($session{form}{gid});
	push(@$groups,$session{form}{gid});
        $f->group(
		-name=>"groups",
		-excludeGroups=>$groups,
		-label=>WebGUI::International::get(605),
		-size=>5,
		-multiple=>1
		);
        $f->submit;
        $output .= $f->print;
	$output .= '</div><p/><table class="tableData" align="center">';
	$output .= '<tr class="tableHeader"><td></td><td>'.WebGUI::International::get(84).'</td></tr>';
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=manageGroupsInGroup&gid='.$session{form}{gid}));
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
	my $f = WebGUI::HTMLForm->new;
	$f->hidden("gid",$session{form}{gid});
	$f->hidden("op","addUsersToGroupSave");
	my $existingUsers = WebGUI::Grouping::getUsersInGroup($session{form}{gid});
	push(@{$existingUsers},"1");
	my $users = WebGUI::SQL->buildHashRef("select userId,username from users where status='Active' and userId not in (".join(",",@{$existingUsers}).") order by username");
	$f->selectList(
		-name=>"users",
		-label=>WebGUI::International::get(976),
		-options=>$users,
		-multiple=>1,
		-size=>7
		);
	$f->submit;
	$output .= $f->print;
        $output .= '<table border="1" cellpadding="2" cellspacing="0"><tr><td class="tableHeader">&nbsp;</td>
                <td class="tableHeader">'.WebGUI::International::get(50).'</td>
                <td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
        $sth = WebGUI::SQL->read("select users.username,users.userId,groupings.expireDate
                from groupings,users where groupings.groupId=$session{form}{gid} and groupings.userId=users.userId
                order by users.username");
        while (%hash = $sth->hash) {
                $output .= '<tr><td>'
                        .deleteIcon('op=deleteGrouping&return=manageUsersInGroup&uid='.$hash{userId}.'&gid='.$session{form}{gid})
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

#-------------------------------------------------------------------
sub www_manageUsersInGroupSecondary {
        return WebGUI::Privilege::adminOnly() unless _hasSecondaryPrivilege($session{form}{gid});
        my ($output, $sth, %hash);
        tie %hash, 'Tie::CPHash';
	my $group = WebGUI::Group->new($session{form}{gid});
        $output = '<h1>'.WebGUI::International::get(88).' '.$group->name.'</h1>';
	my $f = WebGUI::HTMLForm->new;
	$f->hidden("gid",$session{form}{gid});
	$f->hidden("op","addUsersToGroupSecondarySave");
	my $existingUsers = WebGUI::Grouping::getUsersInGroup($session{form}{gid});
	push(@{$existingUsers},"1");
	push(@{$existingUsers},"3");
	my $users = WebGUI::SQL->buildHashRef("select userId,username from users where status='Active' and userId not in (".join(",",@{$existingUsers}).") order by username");
	$f->selectList(
		-name=>"users",
		-label=>WebGUI::International::get(976),
		-options=>$users,
		-multiple=>1,
		-size=>7
		);
	$f->submit;
	$output .= $f->print;
        $output .= '<table border="1" cellpadding="2" cellspacing="0"><tr><td class="tableHeader">&nbsp;</td>
                <td class="tableHeader">'.WebGUI::International::get(50).'</td>
                <td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
        $sth = WebGUI::SQL->read("select users.username,users.userId,groupings.expireDate
                from groupings,users where groupings.groupId=$session{form}{gid} and groupings.userId=users.userId
                order by users.username");
        while (%hash = $sth->hash) {
                $output .= '<tr><td>'
                        .deleteIcon('op=deleteGroupingSecondary&uid='.$hash{userId}.'&gid='.$session{form}{gid})
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
