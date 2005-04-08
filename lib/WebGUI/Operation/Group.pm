package WebGUI::Operation::Group;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::AdminConsole;
use WebGUI::DatabaseLink;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Mail;
use WebGUI::Operation::User;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _hasSecondaryPrivilege {
	return 0 unless (WebGUI::Grouping::isInGroup(11));
	return WebGUI::Grouping::userGroupAdmin($session{user}{userId},$_[0]);
}


#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("groups");
        if ($help) {
                $ac->setHelp($help);
        }
	if (WebGUI::Grouping::isInGroup(3)) {
	        $ac->addSubmenuItem(WebGUI::URL::page('op=editGroup&gid=new'), WebGUI::International::get(90));
        	unless ($session{form}{op} eq "listGroups" 
			|| $session{form}{gid} eq "new" 
			|| $session{form}{op} eq "deleteGroupConfirm") {
        	        $ac->addSubmenuItem(WebGUI::URL::page("op=editGroup&gid=".$session{form}{gid}), WebGUI::International::get(753));
                	$ac->addSubmenuItem(WebGUI::URL::page("op=manageUsersInGroup&gid=".$session{form}{gid}), WebGUI::International::get(754));
	                $ac->addSubmenuItem(WebGUI::URL::page("op=manageGroupsInGroup&gid=".$session{form}{gid}), WebGUI::International::get(807));
        	        $ac->addSubmenuItem(WebGUI::URL::page("op=emailGroup&gid=".$session{form}{gid}), WebGUI::International::get(808));
                	$ac->addSubmenuItem(WebGUI::URL::page("op=deleteGroup&gid=".$session{form}{gid}), WebGUI::International::get(806));
	        }
        	$ac->addSubmenuItem(WebGUI::URL::page("op=listGroups"), WebGUI::International::get(756));
	} else {
        	$ac->addSubmenuItem(WebGUI::URL::page("op=listGroupsSecondary"), WebGUI::International::get(756));
	}
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub doGroupSearch {
	my $op = shift;
        my $returnPaginator = shift;
        my $groupFilter = shift;
        push(@{$groupFilter},0);
        my $keyword = $session{scratch}{groupSearchKeyword};
        if ($session{scratch}{groupSearchModifier} eq "startsWith") {
                $keyword .= "%";
        } elsif ($session{scratch}{groupSearchModifier} eq "contains") {
                $keyword = "%".$keyword."%";
        } else {
                $keyword = "%".$keyword;
        }
	$keyword = quote($keyword);
	my $sql = "select groupId,groupName,description from groups where isEditable=1 and (groupName like $keyword or description like $keyword) 
		and groupId not in (".quoteAndJoin($groupFilter).") order by groupName";
	if ($returnPaginator) {
                my $p = WebGUI::Paginator->new(WebGUI::URL::page($op));
                $p->setDataByQuery($sql);
                return $p;
        } else {
                my $sth = WebGUI::SQL->read($sql);
                return $sth;
        }
}


#-------------------------------------------------------------------
sub getGroupSearchForm {
	my $op = shift;
	my $params = shift;
	WebGUI::Session::setScratch("groupSearchKeyword",$session{form}{keyword});
        WebGUI::Session::setScratch("groupSearchModifier",$session{form}{modifier});
	my $output = '<div align="center">';
	my $f = WebGUI::HTMLForm->new(1);
	foreach my $key (keys %{$params}) {
                $f->hidden(
                        -name=>$key,
                        -value=>$params->{$key}
                        );
        }  
        $f->hidden("op",$op);
        $f->hidden(
                -name=>"doit",
                -value=>1
                );
        $f->selectList(
                -name=>"modifier",
                -value=>([$session{scratch}{groupSearchModifier} || "contains"]),
                -options=>{
                        startsWith=>WebGUI::International::get("starts with"),
                        contains=>WebGUI::International::get("contains"),
                        endsWith=>WebGUI::International::get("ends with")
                        }
                );
        $f->text(
                -name=>"keyword",
                -value=>$session{scratch}{groupSearchKeyword},
                -size=>15
                );
        $f->submit(WebGUI::International::get(170));
        $output .= $f->print;
        $output .= '</div>';
	return $output;
}


#-------------------------------------------------------------------
sub walkGroups {
        my $parentId = shift;
        my $indent = shift;
	my $output;
        my $sth = WebGUI::SQL->read("select groups.groupId, groups.groupName from groupGroupings left join groups on groups.groupId=groupGroupings.groupId where groupGroupings.inGroup=".quote($parentId));
        while (my ($id, $name) = $sth->array) {
		$output .= $indent
			.deleteIcon('op=deleteGroupGrouping&gid='.$parentId.'&delete='.$id)
			.editIcon('op=editGroup&gid='.$id)
			.' '.$name.'<br />';
                $output .= walkGroups($id,$indent."&nbsp; &nbsp; ");
        }
        $sth->finish;
	return $output;
}

#-------------------------------------------------------------------
sub www_addGroupsToGroupSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my @groups = $session{cgi}->param('groups');
	WebGUI::Grouping::addGroupsToGroups(\@groups,[$session{form}{gid}]);
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_addUsersToGroupSave {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
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
        return WebGUI::AdminConsole->new("groups")->render(WebGUI::Privilege::insufficient()) unless ($session{user}{userId} != 1);
	my $group = WebGUI::Group->new($session{form}{groupId});
	if ($group->autoAdd) {
		WebGUI::Grouping::addUsersToGroups([$session{user}{userId}],[$session{form}{groupId}]);
	}
	return "";
}

#-------------------------------------------------------------------
sub www_autoDeleteFromGroup {
        return WebGUI::AdminConsole->new("groups")->render(WebGUI::Privilege::insufficient()) unless ($session{user}{userId} != 1);
	my $group = WebGUI::Group->new($session{form}{groupId});
	if ($group->autoDelete) {
		WebGUI::Grouping::deleteUsersFromGroups([$session{user}{userId}],[$session{form}{groupId}]);
	}
	return "";
}

#-------------------------------------------------------------------
sub www_deleteGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output);
        return WebGUI::AdminConsole->new("groups")->render(WebGUI::Privilege::vitalComponent()) if ($session{form}{gid} < 26 && $session{form}{gid} > 0);
        $output .= WebGUI::International::get(86).'<p>';
        $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteGroupConfirm&gid='.$session{form}{gid}).
		'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listGroups').'">'
		.WebGUI::International::get(45).'</a></div>';
        return _submenu($output, '42',"group delete");
}

#-------------------------------------------------------------------
sub www_deleteGroupConfirm {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        return WebGUI::AdminConsole->new("groups")->render(WebGUI::Privilege::vitalComponent()) if ($session{form}{gid} < 26 && $session{form}{gid} > 0);
	my $g = WebGUI::Group->new($session{form}{gid});
	$g->delete;
        return www_listGroups();
}

#-------------------------------------------------------------------
sub www_deleteGroupGrouping {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::Grouping::deleteGroupsFromGroups([$session{form}{delete}],[$session{form}{gid}]);
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_deleteGrouping {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        if (($session{user}{userId} == $session{form}{uid} || $session{form}{uid} == 3) && $session{form}{gid} == 3) {
                return _submenu(WebGUI::Privilege::vitalComponent());
        }
        my @users = $session{cgi}->param('uid');
        my @groups = $session{cgi}->param("gid");
        foreach my $user (@users) {
                my $u = WebGUI::User->new($user);
                $u->deleteFromGroups(\@groups);
        }
        return WebGUI::Operation::Group::www_manageUsersInGroup();
}
                                                                                                                                                       
#-------------------------------------------------------------------
sub www_deleteGroupingSecondary {
        return WebGUI::Privilege::adminOnly() unless _hasSecondaryPrivilege($session{form}{gid});
        if ($session{user}{userId} eq $session{form}{uid}) {
                return WebGUI::AdminConsole->new("groups")->render(WebGUI::Privilege::vitalComponent());
        }
        WebGUI::Grouping::deleteUsersFromGroups([$session{form}{uid}],[$session{form}{gid}]);
        return www_manageUsersInGroupSecondary();
}

#-------------------------------------------------------------------
sub www_editGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $f, $g);
	if ($session{form}{gid} eq "new") {
		$g = WebGUI::Group->new("");
	} else {
		$g = WebGUI::Group->new($session{form}{gid});
	}
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","editGroupSave");
        $f->hidden("gid",$session{form}{gid});
	$f->readOnly($g->groupId,WebGUI::International::get(379));
        $f->text("groupName",WebGUI::International::get(84),$g->name);
        $f->textarea("description",WebGUI::International::get(85),$g->description);
        $f->interval(
		-name=>"expireOffset",
		-label=>WebGUI::International::get(367), 
		-value=>$g->expireOffset
		);
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
	if ($session{form}{gid} eq "3") {
		$f->hidden(
			-name=>"autoAdd",
			-value=>0
			);
		$f->hidden(
			-name=>"autoDelete",
			-value=>0
			);
	} else {
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
	}
	$f->databaseLink(
                -value=>[$g->databaseLinkId]
                );
	$f->textarea(
		-name=>"dbQuery",
		-value=>$g->dbQuery,
		-label=>WebGUI::International::get(1005)
		);
	$f->interval(
		-name=>"dbCacheTimeout",
		-label=>WebGUI::International::get(1004), 
		-value=>$g->dbCacheTimeout
		);
	$f->submit;
	$output .= $f->print;
        return _submenu($output,'87',"group add/edit");
}

#-------------------------------------------------------------------
sub www_editGroupSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
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
sub www_editGrouping {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $f = WebGUI::HTMLForm->new;
        $f->hidden("op","editGroupingSave");
        $f->hidden("uid",$session{form}{uid});
        $f->hidden("gid",$session{form}{gid});
	my $u = WebGUI::User->new($session{form}{uid});
	my $g = WebGUI::Group->new($session{form}{gid});
        $f->readOnly($u->username,WebGUI::International::get(50));
        $f->readOnly($g->name,WebGUI::International::get(84));
	$f->date("expireDate",WebGUI::International::get(369),WebGUI::Grouping::userGroupExpireDate($session{form}{uid},$session{form}{gid}));
	$f->yesNo(
		-name=>"groupAdmin",
		-label=>WebGUI::International::get(977),
		-value=>WebGUI::Grouping::userGroupAdmin($session{form}{uid},$session{form}{gid})
		);
	$f->submit;
        return _submenu($f->print,'370');
}

#-------------------------------------------------------------------
sub www_editGroupingSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        WebGUI::Grouping::userGroupExpireDate($session{form}{uid},$session{form}{gid},setToEpoch($session{form}{expireDate}));
        WebGUI::Grouping::userGroupAdmin($session{form}{uid},$session{form}{gid},$session{form}{groupAdmin});
        return www_manageUsersInGroup();
}

#-------------------------------------------------------------------
sub www_emailGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output,$f);
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
	return _submenu($output,'809');
}

#-------------------------------------------------------------------
sub www_emailGroupSend {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($sth, $email);
	$sth = WebGUI::SQL->read("select b.fieldData from groupings a left join userProfileData b 
		on a.userId=b.userId and b.fieldName='email' where a.groupId=".quote($session{form}{gid}));
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
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $output = getGroupSearchForm("listGroups");
	my ($groupCount) = WebGUI::SQL->quickArray("select count(*) from groups");
        return _submenu($output) unless ($session{form}{doit} || $groupCount<250 || $session{form}{pn} > 1);
	$output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(84).'</td><td class="tableHeader">'
		.WebGUI::International::get(85).'</td><td class="tableHeader">'
		.WebGUI::International::get(748).'</td></tr>';
	my $p = doGroupSearch("op=listGroups",1);
	foreach my $row (@{$p->getPageData}) {
		my ($userCount) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId=".quote($row->{groupId}));
		$output .= '
		<tr>
			<td valign="top" class="tableData"><a href="'.WebGUI::URL::page("op=editGroup&gid=".$row->{groupId}).'">'.$row->{groupName}.'</a></td>
			<td valign="top" class="tableData">'.$row->{description}.'</td>
			<td valign="top" class="tableData">'.$userCount.'</td>
		</tr>
			';	
	}
        $output .= '</table>';
	$output .= $p->getBarTraditional;
	return _submenu($output,'',"groups manage");
}


#-------------------------------------------------------------------
sub www_listGroupsSecondary {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(11));
        my ($output, $p, $sth, @data, @row, $i, $userCount);
	my @editableGroups = WebGUI::SQL->buildArray("select groupId from groupings where userId=".quote($session{user}{userId})." and groupAdmin=1");
	push (@editableGroups,0);
        $sth = WebGUI::SQL->read("select groupId,groupName,description from groups 
		where groupId in (".quoteAndJoin(\@editableGroups).") order by groupName");
        while (@data = $sth->array) {
                $row[$i] = '<tr>';
                $row[$i] .= '<td valign="top" class="tableData"><a href="'
			.WebGUI::URL::page('op=manageUsersInGroupSecondary&gid='.$data[0]).'">'.$data[1].'</td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data[2].'</td>';
		($userCount) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId=".quote($data[0]));
                $row[$i] .= '<td valign="top" class="tableData">'.$userCount.'</td></tr>';
                $row[$i] .= '</tr>';
                $i++;
        }
	$sth->finish;
        $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listGroupsSecondary'));
	$p->setDataByArrayRef(\@row);
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(84).'</td><td class="tableHeader">'
		.WebGUI::International::get(85).'</td><td class="tableHeader">'
		.WebGUI::International::get(748).'</td></tr>';
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
        return _submenu($output,'89');
}

#-------------------------------------------------------------------
sub www_manageGroupsInGroup {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $p, $group, $groups, $f);
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","addGroupsToGroupSave");
        $f->hidden("gid",$session{form}{gid});
	$groups = WebGUI::Grouping::getGroupsInGroup($session{form}{gid},1);
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
	$output .= '<p />';
	$output .= walkGroups($session{form}{gid});
#<table class="tableData" align="center">';
#	$output .= '<tr class="tableHeader"><td></td><td>'.WebGUI::International::get(84).'</td></tr>';
#	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=manageGroupsInGroup&gid='.$session{form}{gid}));
#	$p->setDataByQuery("select a.groupName as name,a.groupId as id from groups a 
#		left join groupGroupings b on a.groupId=b.groupId 
#		where b.inGroup=".quote($session{form}{gid})." order by a.groupName");
#	$groups = $p->getPageData;
#	foreach $group (@$groups) {
#		$output .= '<tr><td>'
#			.deleteIcon('op=deleteGroupGrouping&gid='.$session{form}{gid}.'&delete='.$group->{id})
#			.'</td><td><a href="'.WebGUI::URL::page('op=editGroup&gid='.$group->{id}).'">'
#			.$group->{name}.'</a></td></tr>';
#	}
#	$output .= '</table>';
#	$output .= $p->getBarTraditional;
	return _submenu($output,'813');
}

#-------------------------------------------------------------------
sub www_manageUsersInGroup {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $output = WebGUI::Form::formHeader()
		.WebGUI::Form::hidden({
			name=>"gid",
			value=>$session{form}{gid}
			})
		.WebGUI::Form::hidden({
			name=>"op",
			value=>"deleteGrouping"
			});
        $output .= '<table border="1" cellpadding="2" cellspacing="0"><tr><td class="tableHeader"><input type="image" src="'
		.WebGUI::Icon::_getBaseURL().'delete.gif" border="0"></td>
                <td class="tableHeader">'.WebGUI::International::get(50).'</td>
                <td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
	my $p = WebGUI::Paginator->new(WebGUI::URL::page("op=manageUsersInGroup&gid=".$session{form}{gid}));
        $p->setDataByQuery("select users.username,users.userId,groupings.expireDate
                from groupings,users where groupings.groupId=".quote($session{form}{gid})." and groupings.userId=users.userId
                order by users.username");
	foreach my $row (@{$p->getPageData}) {
                $output .= '<tr><td>'
			.WebGUI::Form::checkbox({
				name=>"uid",
				value=>$row->{userId}
				})
                        .deleteIcon('op=deleteGrouping&uid='.$row->{userId}.'&gid='.$session{form}{gid})
                        .editIcon('op=editGrouping&uid='.$row->{userId}.'&gid='.$session{form}{gid})
                        .'</td>';
                $output .= '<td class="tableData"><a href="'.WebGUI::URL::page('op=editUser&uid='.$row->{userId}).'">'.$row->{username}.'</a></td>';
                $output .= '<td class="tableData">'.epochToHuman($row->{expireDate},"%z").'</td></tr>';
        }
        $output .= '</table>'.WebGUI::Form::formFooter();
	$output .= $p->getBarTraditional;
	$output .= '<p><h1>'.WebGUI::International::get(976).'</h1>';
	$output .= WebGUI::Operation::User::getUserSearchForm("manageUsersInGroup",{gid=>$session{form}{gid}});
	my ($userCount) = WebGUI::SQL->quickArray("select count(*) from users");
	return _submenu($output) unless ($session{form}{doit} || $userCount < 250 || $session{form}{pn} > 1);
	my $f = WebGUI::HTMLForm->new;
	$f->hidden("gid",$session{form}{gid});
	$f->hidden("op","addUsersToGroupSave");
	my $existingUsers = WebGUI::Grouping::getUsersInGroup($session{form}{gid});
	push(@{$existingUsers},"1");
	my %users;
	tie %users, "Tie::IxHash";
	my $sth = WebGUI::Operation::User::doUserSearch("op=manageUsersInGroup&gid=".$session{form}{gid},0,$existingUsers);
	while (my $data = $sth->hashRef) {
		$users{$data->{userId}} = $data->{username};
		$users{$data->{userId}} .= " (".$data->{email}.")" if ($data->{email});
	}
	$sth->finish;
	$f->selectList(
		-name=>"users",
		-label=>WebGUI::International::get(976),
		-options=>\%users,
		-multiple=>1,
		-size=>7
		);
	$f->submit;
	$output .= $f->print;
        return _submenu($output,'88');
}

#-------------------------------------------------------------------
sub www_manageUsersInGroupSecondary {
        return WebGUI::Privilege::adminOnly() unless _hasSecondaryPrivilege($session{form}{gid});
        my ($output, $sth, %hash);
        tie %hash, 'Tie::CPHash';
	my $group = WebGUI::Group->new($session{form}{gid});
	my $f = WebGUI::HTMLForm->new;
	$f->hidden("gid",$session{form}{gid});
	$f->hidden("op","addUsersToGroupSecondarySave");
	my $existingUsers = WebGUI::Grouping::getUsersInGroup($session{form}{gid});
	push(@{$existingUsers},"1");
	push(@{$existingUsers},"3");
	my $users = WebGUI::SQL->buildHashRef("select userId,username from users where status='Active' and userId not in (".quoteAndJoin($existingUsers).") order by username");
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
                from groupings,users where groupings.groupId=".quote($session{form}{gid})." and groupings.userId=users.userId
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
        return _submenu($output,'88');
}



1;
