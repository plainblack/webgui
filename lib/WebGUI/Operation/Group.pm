package WebGUI::Operation::Group;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
	my $session = shift;
	return 0 unless ($session->user->isInGroup(11));
	return $group->userIsAdmin($session->user->profileField("userId"),$_[0]);
}


#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new($session,"groups");
        if ($help) {
                $ac->setHelp($help);
        }
	if ($session->user->isInGroup(3)) {
	        $ac->addSubmenuItem($session->url->page('op=editGroup;gid=new'), WebGUI::International::get(90));
	}
	if ($session->user->isInGroup(11)) {
        	unless ($session->form->process("op") eq "listGroups" 
			|| $session->form->process("gid") eq "new" 
			|| $session->form->process("op") eq "deleteGroupConfirm") {
        	        $ac->addSubmenuItem($session->url->page("op=editGroup;gid=".$session->form->process("gid")), WebGUI::International::get(753));
                	$ac->addSubmenuItem($session->url->page("op=manageUsersInGroup;gid=".$session->form->process("gid")), WebGUI::International::get(754));
	                $ac->addSubmenuItem($session->url->page("op=manageGroupsInGroup;gid=".$session->form->process("gid")), WebGUI::International::get(807));
        	        $ac->addSubmenuItem($session->url->page("op=emailGroup;gid=".$session->form->process("gid")), WebGUI::International::get(808));
                	$ac->addSubmenuItem($session->url->page("op=deleteGroup;gid=".$session->form->process("gid")), WebGUI::International::get(806));
	        }
        	$ac->addSubmenuItem($session->url->page("op=listGroups"), WebGUI::International::get(756));
	}
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub doGroupSearch {
	my $session = shift;
	my $op = shift;
        my $returnPaginator = shift;
        my $groupFilter = shift;
        push(@{$groupFilter},0);
        my $keyword = $session->scratch->get("groupSearchKeyword");
        if ($session->scratch->get("groupSearchModifier") eq "startsWith") {
                $keyword .= "%";
        } elsif ($session->scratch->get("groupSearchModifier") eq "contains") {
                $keyword = "%".$keyword."%";
        } else {
                $keyword = "%".$keyword;
        }
	$keyword = $session->db->quote($keyword);
	my $sql = "select groupId,groupName,description from groups where isEditable=1 and (groupName like $keyword or description like $keyword) 
		and groupId not in (".$session->db->quoteAndJoin($groupFilter).") order by groupName";
	if ($returnPaginator) {
                my $p = WebGUI::Paginator->new($session->url->page($op));
                $p->setDataByQuery($sql);
                return $p;
        } else {
                my $sth = $session->db->read($sql);
                return $sth;
        }
}


#-------------------------------------------------------------------
sub getGroupSearchForm {
	my $session = shift;
	my $op = shift;
	my $params = shift;
	$session->scratch->set("groupSearchKeyword",$session->form->process("keyword"));
        $session->scratch->set("groupSearchModifier",$session->form->process("modifier"));
	my $output = '<div align="center">';
	my $f = WebGUI::HTMLForm->new(1);
	foreach my $key (keys %{$params}) {
                $f->hidden(
                        -name=>$key,
                        -value=>$params->{$key}
                        );
        }  
        $f->hidden(
		-name => "op",
		-value => $op
	);
        $f->hidden(
                -name=>"doit",
                -value=>1
                );
        $f->selectBox(
                -name=>"modifier",
                -value=>($session->scratch->get("groupSearchModifier") || WebGUI::International::get("contains") ),
                -options=>{
                        startsWith=>WebGUI::International::get("starts with"),
                        contains=>WebGUI::International::get("contains"),
                        endsWith=>WebGUI::International::get("ends with")
                        }
                );
        $f->text(
                -name=>"keyword",
                -value=>$session->scratch->get("groupSearchKeyword"),
                -size=>15
                );
        $f->submit(value=>WebGUI::International::get(170));
        $output .= $f->print;
        $output .= '</div>';
	return $output;
}


#-------------------------------------------------------------------
sub walkGroups {
	my $session = shift;
        my $parentId = shift;
        my $indent = shift;
	my $output;
        my $sth = $session->db->read("select groups.groupId, groups.groupName from groupGroupings left join groups on groups.groupId=groupGroupings.groupId where groupGroupings.inGroup=".$session->db->quote($parentId));
        while (my ($id, $name) = $sth->array) {
		$output .= $indent
			.deleteIcon('op=deleteGroupGrouping;gid='.$parentId.';delete='.$id)
			.editIcon('op=editGroup;gid='.$id)
			.' '.$name.'<br />';
                $output .= walkGroups($id,$indent."&nbsp; &nbsp; ");
        }
        $sth->finish;
	return $output;
}

#-------------------------------------------------------------------
sub www_addGroupsToGroupSave {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
        my @groups = $session->form->group('groups');
	$group->addGroups(\@groups,[$session->form->process("gid")]);
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------
sub www_addUsersToGroupSave {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
        my @users = $session->form->selectList('users');
	$group->addUsers(\@users,[$session->form->process("gid")]);
        return www_manageUsersInGroup();
}

#-------------------------------------------------------------------
sub www_autoAddToGroup {
	my $session = shift;
        return WebGUI::AdminConsole->new($session,"groups")->render($session->privilege->insufficient()) unless ($session->user->profileField("userId") ne 1);
	my $group = WebGUI::Group->new($session->form->process("groupId"));
	if ($group->autoAdd) {
		$group->addUsers([$session->user->profileField("userId")],[$session->form->process("groupId")]);
	}
	return "";
}

#-------------------------------------------------------------------
sub www_autoDeleteFromGroup {
	my $session = shift;
        return WebGUI::AdminConsole->new($session,"groups")->render($session->privilege->insufficient()) unless ($session->user->profileField("userId") ne 1);
	my $group = WebGUI::Group->new($session->form->process("groupId"));
	if ($group->autoDelete) {
		$group->deleteUsers([$session->user->profileField("userId")],[$session->form->process("groupId")]);
	}
	return "";
}

#-------------------------------------------------------------------
sub www_deleteGroup {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
	return $session->privilege->vitalComponent() if (isIn($session->form->process("gid"), qw(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17)));
        my ($output);
        $output .= WebGUI::International::get(86).'<p>';
        $output .= '<div align="center"><a href="'.$session->url->page('op=deleteGroupConfirm;gid='.$session->form->process("gid")).
		'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session->url->page('op=listGroups').'">'
		.WebGUI::International::get(45).'</a></div>';
        return _submenu($output, '42',"group delete");
}

#-------------------------------------------------------------------
sub www_deleteGroupConfirm {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
	return $session->privilege->vitalComponent() if (isIn($session->form->process("gid"), qw(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17)));
	my $g = WebGUI::Group->new($session->form->process("gid"));
	$g->delete;
        return www_listGroups();
}

#-------------------------------------------------------------------
sub www_deleteGroupGrouping {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup('3') || _hasSecondaryPrivilege($session->form->process("gid")));
	$group->deleteGroups([$session->form->process("delete")],[$session->form->process("gid")]);
        return www_manageGroupsInGroup();
}

#-------------------------------------------------------------------

=head2 www_deleteGrouping ( )

Deletes a set of users from a set of groups.  Only Admins may perform this function.
The user and group lists are expected to
be found in form fields names uid and gid, respectively.  Visitors are not allowed to
perform this operation, and the 

=cut

sub www_deleteGrouping {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
        if (($session->user->profileField("userId") eq $session->form->process("uid") || $session->form->process("uid") eq '3') && $session->form->process("gid") eq '3') {
                return $session->privilege->vitalComponent();
        }
        my @users = $session->form->selectList('uid');
        my @groups = $session->form->group("gid");
        foreach my $user (@users) {
                my $u = WebGUI::User->new($user);
                $u->deleteFromGroups(\@groups);
        }
        return WebGUI::Operation::Group::www_manageUsersInGroup();
}
                                                                                                                                                       

#-------------------------------------------------------------------
sub www_editGroup {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
        my ($output, $f, $g);
	if ($session->form->process("gid") eq "new") {
		$g = WebGUI::Group->new("");
	} else {
		$g = WebGUI::Group->new($session->form->process("gid"));
	}
	$f = WebGUI::HTMLForm->new;
        $f->hidden(
		-name => "op",
		-value => "editGroupSave",
	);
        $f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
        $f->readOnly(
		-label => WebGUI::International::get(379),
		-value => $g->getId,
        );
        $f->text(
		-name => "groupName",
		-label => WebGUI::International::get(84),
		-hoverHelp => WebGUI::International::get('84 description'),
		-value => $g->name,
        );
        $f->textarea(
		-name => "description",
		-label => WebGUI::International::get(85),
		-hoverHelp => WebGUI::International::get('85 description'),
		-value => $g->description,
        );
        $f->interval(
		-name=>"expireOffset",
		-label=>WebGUI::International::get(367), 
		-hoverHelp=>WebGUI::International::get('367 description'), 
		-value=>$g->expireOffset
		);
	$f->yesNo(
		-name=>"expireNotify",
		-value=>$g->expireNotify,
		-label=>WebGUI::International::get(865),
		-hoverHelp=>WebGUI::International::get('865 description'),
		);
	$f->integer(
		-name=>"expireNotifyOffset",
		-value=>$g->expireNotifyOffset,
		-label=>WebGUI::International::get(864),
		-hoverHelp=>WebGUI::International::get('864 description'),
		);
        $f->textarea(
                -name=>"expireNotifyMessage",
		-value=>$g->expireNotifyMessage,
		-label=>WebGUI::International::get(866),
		-hoverHelp=>WebGUI::International::get('866 description'),
                );
        $f->integer(
                -name=>"deleteOffset",
                -value=>$g->deleteOffset,
                -label=>WebGUI::International::get(863),
                -hoverHelp=>WebGUI::International::get('863 description'),
                );
	if ($session->setting->get("useKarma")) {
		$f->integer(
                        -name=>"karmaThreshold",
                        -label=>WebGUI::International::get(538),
                        -hoverHelp=>WebGUI::International::get('538 description'),
                        -value=>$g->karmaThreshold
                        );
	}
	$f->textarea(
		-name=>"ipFilter",
		-value=>$g->ipFilter,
		-label=>WebGUI::International::get(857),
		-hoverHelp=>WebGUI::International::get('857 description'),
		);
	$f->textarea(
		-name=>"scratchFilter",
		-value=>$g->scratchFilter,
		-label=>WebGUI::International::get(945),
		-hoverHelp=>WebGUI::International::get('945 description'),
		);
	if ($session->form->process("gid") eq "3") {
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
			-label=>WebGUI::International::get(974),
			-hoverHelp=>WebGUI::International::get('974 description'),
			);
		$f->yesNo(
			-name=>"autoDelete",
			-value=>$g->autoDelete,
			-label=>WebGUI::International::get(975),
			-hoverHelp=>WebGUI::International::get('975 description'),
			);
	}
	$f->databaseLink(
                -value=>[$g->databaseLinkId]
                );
	$f->textarea(
		-name=>"dbQuery",
		-value=>$g->dbQuery,
		-label=>WebGUI::International::get(1005),
		-hoverHelp=>WebGUI::International::get('1005 description'),
		);
	$f->text(
	       -name=>"ldapGroup",
		   -label=>WebGUI::International::get("LDAPLink_ldapGroup","AuthLDAP"),
		   -hoverHelp=>WebGUI::International::get("LDAPLink_ldapGroup","AuthLDAP"),
	       -value=>$g->ldapGroup
		);
    $f->text(
	       -name=>"ldapGroupProperty",
		   -label=>WebGUI::International::get("LDAPLink_ldapGroupProperty","AuthLDAP"),
		   -hoverHelp=>WebGUI::International::get("LDAPLink_ldapGroupProperty","AuthLDAP"),
		   -value=>$g->ldapGroupProperty,
		   -defaultValue=>"member"
	    );
    $f->text(
	       -name=>"ldapRecursiveProperty",
		   -label=>WebGUI::International::get("LDAPLink_ldapRecursiveProperty","AuthLDAP"),
		   -hoverHelp=>WebGUI::International::get("LDAPLink_ldapRecursiveProperty","AuthLDAP"),
		   -value=>$g->ldapRecursiveProperty
	    );
	$f->interval(
		-name=>"dbCacheTimeout",
		-label=>WebGUI::International::get(1004), 
		-hoverHelp=>WebGUI::International::get('1004 description'), 
		-value=>$g->dbCacheTimeout
		);
	$f->submit;
	$output .= $f->print;
        return _submenu($output,'87',"group add/edit");
}

#-------------------------------------------------------------------
sub www_editGroupSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
	my $g = WebGUI::Group->new($session->form->process("gid"));
	$g->description($session->form->process("description"));
	$g->name($session->form->process("groupName"));
	$g->expireOffset($session->form->interval("expireOffset"));
	$g->karmaThreshold($session->form->process("karmaThreshold"));
	$g->ipFilter($session->form->process("ipFilter"));
	$g->scratchFilter($session->form->process("scratchFilter"));
	$g->expireNotify($session->form->yesNo("expireNotify"));
	$g->expireNotifyOffset($session->form->process("expireNotifyOffset"));
	$g->expireNotifyMessage($session->form->process("expireNotifyMessage"));
	$g->deleteOffset($session->form->process("deleteOffset"));
	$g->autoAdd($session->form->yesNo("autoAdd"));
	$g->autoDelete($session->form->yesNo("autoDelete"));
	$g->databaseLinkId($session->form->process("databaseLinkId"));
	$g->dbQuery($session->form->process("dbQuery"));
	$g->dbCacheTimeout($session->form->interval("dbCacheTimeout"));
	$g->ldapGroup($session->form->text("ldapGroup"));
	$g->ldapGroupProperty($session->form->text("ldapGroupProperty"));
	$g->ldapRecursiveProperty($session->form->text("ldapRecursiveProperty"));
    return www_listGroups();
}

#-------------------------------------------------------------------
sub www_editGrouping {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
	my $f = WebGUI::HTMLForm->new;
        $f->hidden(
		-name => "op",
		-value => "editGroupingSave"
	);
        $f->hidden(
		-name => "uid",
		-value => $session->form->process("uid")
	);
        $f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
	my $u = WebGUI::User->new($session->form->process("uid"));
	my $g = WebGUI::Group->new($session->form->process("gid"));
        $f->readOnly(
		-value => $u->username,
		-label => WebGUI::International::get(50),
		-hoverHelp => WebGUI::International::get('50 description'),
        );
        $f->readOnly(
		-value => $g->name,
		-label => WebGUI::International::get(84),
		-hoverHelp => WebGUI::International::get('84 description'),
        );
	$f->date(
		-name => "expireDate",
		-label => WebGUI::International::get(369),
		-hoverHelp => WebGUI::International::get('369 description'),
		-value => $group->userGroupExpireDate($session->form->process("uid"),$session->form->process("gid")),
	);
	$f->yesNo(
		-name=>"groupAdmin",
		-label=>WebGUI::International::get(977),
		-hoverHelp=>WebGUI::International::get('977 description'),
		-value=>$group->userIsAdmin($session->form->process("uid"),$session->form->process("gid"))
		);
	$f->submit;
        return _submenu($f->print,'370','grouping edit');
}

#-------------------------------------------------------------------
sub www_editGroupingSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
        $group->userGroupExpireDate($session->form->process("uid"),$session->form->process("gid")$session->datetime->setToEpoch($session->form->process("expireDate")));
        $group->userIsAdmin($session->form->process("uid"),$session->form->process("gid"),$session->form->process("groupAdmin"));
        return www_manageUsersInGroup();
}

#-------------------------------------------------------------------
sub www_emailGroup {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
	my ($output,$f);
	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => "op",
		-value => "emailGroupSend"
	);
	$f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
	$f->email(
		-name=>"from",
		-value=>$session->setting->get("companyEmail"),
		-label=>WebGUI::International::get(811),
		-hoverHelp=>WebGUI::International::get('811 description'),
		);
	$f->text(
		-name=>"subject",
		-label=>WebGUI::International::get(229),
		-hoverHelp=>WebGUI::International::get('229 description'),
		);
	$f->textarea(
		-name=>"message",
		-label=>WebGUI::International::get(230),
		-hoverHelp=>WebGUI::International::get('230 description'),
		-rows=>(5+$session->setting->get("textAreaRows")),
		);
	$f->submit(WebGUI::International::get(810));
	$output = $f->print;
	return _submenu($output,'809');
}

#-------------------------------------------------------------------
sub www_emailGroupSend {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
	my ($sth, $email);
	$sth = $session->db->read("select b.fieldData from groupings a left join userProfileData b 
		on a.userId=b.userId and b.fieldName='email' where a.groupId=".$session->db->quote($session->form->process("gid")));
	while (($email) = $sth->array) {
		if ($email ne "") {
			WebGUI::Mail::send($email,$session->form->process("subject"),$session->form->process("message"),'',$session->form->process("from"));
		}
	}
	$sth->finish;
	return _submenu(WebGUI::International::get(812));
}

#-------------------------------------------------------------------
sub www_listGroups {
	my $session = shift;
	if ($session->user->isInGroup(3)) {
		my $output = getGroupSearchForm("listGroups");
		my ($groupCount) = $session->db->quickArray("select count(*) from groups where isEditable=1");
        	return _submenu($output) unless ($session->form->process("doit") || $groupCount<250 || $session->form->process("pn") > 1);
		$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(84).'</td><td class="tableHeader">'
			.WebGUI::International::get(85).'</td><td class="tableHeader">'
			.WebGUI::International::get(748).'</td></tr>';
		my $p = doGroupSearch("op=listGroups",1);
		foreach my $row (@{$p->getPageData}) {
			my ($userCount) = $session->db->quickArray("select count(*) from groupings where groupId=".$session->db->quote($row->{groupId}));
			$output .= '
			<tr>
				<td valign="top" class="tableData"><a href="'.$session->url->page("op=editGroup;gid=".$row->{groupId}).'">'.$row->{groupName}.'</a></td>
				<td valign="top" class="tableData">'.$row->{description}.'</td>
				<td valign="top" class="tableData">'.$userCount.'</td>
			</tr>
			';	
		}
        	$output .= '</table>';
		$output .= $p->getBarTraditional;
		return _submenu($output,'',"groups manage");
	} elsif ($session->user->isInGroup(11)) {
		my ($output, $p, $sth, @data, @row, $i, $userCount);
        	my @editableGroups = $session->db->buildArray("select groupId from groupings where userId=".$session->db->quote($session->user->profileField("userId"))." and groupAdmin=1");
        	push (@editableGroups,0);
        	$sth = $session->db->read("select groupId,groupName,description from groups
                	where groupId in (".$session->db->quoteAndJoin(\@editableGroups).") order by groupName");
        	while (@data = $sth->array) {
                	$row[$i] = '<tr>';
                	$row[$i] .= '<td valign="top" class="tableData"><a href="'
                        	.$session->url->page('op=manageUsersInGroup;gid='.$data[0]).'">'.$data[1].'</td>';
                	$row[$i] .= '<td valign="top" class="tableData">'.$data[2].'</td>';
                	($userCount) = $session->db->quickArray("select count(*) from groupings where groupId=".$session->db->quote($data[0]));
                	$row[$i] .= '<td valign="top" class="tableData">'.$userCount.'</td></tr>';
                	$row[$i] .= '</tr>';
                	$i++;
        	}
        	$sth->finish;
        	$p = WebGUI::Paginator->new($session->url->page('op=listGroups'));
        	$p->setDataByArrayRef(\@row);
        	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
        	$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(84).'</td><td class="tableHeader">'
                	.WebGUI::International::get(85).'</td><td class="tableHeader">'
                	.WebGUI::International::get(748).'</td></tr>';
        	$output .= $p->getPage($session->form->process("pn"));
        	$output .= '</table>';
        	$output .= $p->getBarTraditional($session->form->process("pn"));
        	return _submenu($output,'89');
	}
	return $session->privilege->adminOnly();
}


#-------------------------------------------------------------------
sub www_manageGroupsInGroup {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
        my $f = WebGUI::HTMLForm->new;
        $f->hidden(
		-name => "op",
		-value => "addGroupsToGroupSave"
	);
        $f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
	my @groups;
	my $groupsIn = $group->getGroupsIn($session->form->process("gid"),1);
	my $groupsFor = $group->getGroupsFor($session->form->process("gid"));
	push(@groups, @$groupsIn,@$groupsFor,$session->form->process("gid"));
        $f->group(
		-name=>"groups",
		-excludeGroups=>\@groups,
		-label=>WebGUI::International::get(605),
		-size=>5,
		-multiple=>1
		);
        $f->submit;
        my $output = $f->print;
	$output .= '<p />';
	$output .= walkGroups($session->form->process("gid"));
	return _submenu($output,'813');
}

#-------------------------------------------------------------------
sub www_manageUsersInGroup {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3) || _hasSecondaryPrivilege($session->form->process("gid")));
	my $output = WebGUI::Form::formHeader($session,)
		.WebGUI::Form::hidden({
			name=>"gid",
			value=>$session->form->process("gid")
			})
		.WebGUI::Form::hidden({
			name=>"op",
			value=>"deleteGrouping"
			});
        $output .= '<table border="1" cellpadding="2" cellspacing="0"><tr><td class="tableHeader"><input type="image" src="'
		.WebGUI::Icon::_getBaseURL().'delete.gif" border="0"></td>
                <td class="tableHeader">'.WebGUI::International::get(50).'</td>
                <td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
	my $p = WebGUI::Paginator->new($session->url->page("op=manageUsersInGroup;gid=".$session->form->process("gid")));
        $p->setDataByQuery("select users.username,users.userId,groupings.expireDate
                from groupings,users where groupings.groupId=".$session->db->quote($session->form->process("gid"))." and groupings.userId=users.userId
                order by users.username");
	foreach my $row (@{$p->getPageData}) {
                $output .= '<tr><td>'
			.WebGUI::Form::checkbox({
				name=>"uid",
				value=>$row->{userId}
				})
                        .deleteIcon('op=deleteGrouping;uid='.$row->{userId}.';gid='.$session->form->process("gid"))
                        .editIcon('op=editGrouping;uid='.$row->{userId}.';gid='.$session->form->process("gid"))
                        .'</td>';
                $output .= '<td class="tableData"><a href="'.$session->url->page('op=editUser;uid='.$row->{userId}).'">'.$row->{username}.'</a></td>';
                $output .= '<td class="tableData">'$session->datetime->epochToHuman($row->{expireDate},"%z").'</td></tr>';
        }
        $output .= '</table>'.WebGUI::Form::formFooter($session,);
	$output .= $p->getBarTraditional;
	$output .= '<p><h1>'.WebGUI::International::get(976).'</h1>';
	$output .= WebGUI::Operation::User::getUserSearchForm("manageUsersInGroup",{gid=>$session->form->process("gid")});
	my ($userCount) = $session->db->quickArray("select count(*) from users");
	return _submenu($output) unless ($session->form->process("doit") || $userCount < 250 || $session->form->process("pn") > 1);
	my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
	$f->hidden(
		-name => "op",
		-value => "addUsersToGroupSave"
	);
	my $existingUsers = $group->getUsers($session->form->process("gid"));
	push(@{$existingUsers},"1");
	my %users;
	tie %users, "Tie::IxHash";
	my $sth = WebGUI::Operation::User::doUserSearch("op=manageUsersInGroup;gid=".$session->form->process("gid"),0,$existingUsers);
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



1;
