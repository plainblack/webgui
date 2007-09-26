package WebGUI::Operation::Group;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use WebGUI::Group;
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Mail::Send;
use WebGUI::Operation::User;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::Utility;

#----------------------------------------------------------------------------
sub _submenu {
	my $session = shift;
        my $workarea = shift;
        my $title = shift;
	my $i18n = WebGUI::International->new($session);
        $title = $i18n->get($title) if ($title);
        my $ac = WebGUI::AdminConsole->new($session,"groups");
	if (canEditAll($session)) {
	        $ac->addSubmenuItem($session->url->page('op=editGroup;gid=new'), $i18n->get(90));
	}
	if (canView($session)) {
        	unless ($session->form->process("op") eq "listGroups" 
			|| $session->form->process("gid") eq "new" 
			|| $session->form->process("op") eq "deleteGroupConfirm") {
        	        $ac->addSubmenuItem($session->url->page("op=editGroup;gid=".$session->form->process("gid")), $i18n->get(753));
                	$ac->addSubmenuItem($session->url->page("op=manageUsersInGroup;gid=".$session->form->process("gid")), $i18n->get(754));
	                $ac->addSubmenuItem($session->url->page("op=manageGroupsInGroup;gid=".$session->form->process("gid")), $i18n->get(807));
        	        $ac->addSubmenuItem($session->url->page("op=emailGroup;gid=".$session->form->process("gid")), $i18n->get(808));
                	$ac->addConfirmedSubmenuItem($session->url->page("op=deleteGroup;gid=".$session->form->process("gid")), $i18n->get(806), $i18n->get(86));
	        }
        	$ac->addSubmenuItem($session->url->page("op=listGroups"), $i18n->get(756));
	}
    return $ac->render($workarea, $title);
}


#----------------------------------------------------------------------------

=head2 canEditAll ( session [, user] )

Returns true if the user is allowed to edit all groups. user defaults to the
current user.

=cut

sub canEditAll {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminGroup") );
}

#----------------------------------------------------------------------------

=head2 canEditGroup ( session, group [, user] )

Returns true if the user can edit the specified group. user defaults to the
current user.

=cut

sub canEditGroup {
    my $session     = shift;
    my $groupId     = shift;
    my $user        = shift || $session->user;
    
    return 1 if canEditAll($session, $user);

	my $group = WebGUI::Group->new($session,$groupId);
    return
        unless $group;
    return $user->isInGroup( $session->setting->get("groupIdAdminGroupAdmin") )  
        && $group->userIsAdmin( $user->userId )
        ;
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user is allowed to use this control in any capacity. user
defaults to the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    
    return canEditAll($session, $user)
        || $user->isInGroup( $session->setting->get("groupIdAdminGroupAdmin") )
        ;
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
                my $p = WebGUI::Paginator->new($session,$session->url->page($op));
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
	my $keyword = $session->form->process("keyword");
	if (defined $keyword) {
		$session->scratch->set("groupSearchKeyword", $keyword);
	}
	my $modifier = $session->form->process("modifier");
	if (defined $modifier) {
		$session->scratch->set("groupSearchModifier", $modifier);
	}
	my $output = '<div align="center">';
	my $i18n = WebGUI::International->new($session);
	my $f = WebGUI::HTMLForm->new($session,1);
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
                -value=>($session->scratch->get("groupSearchModifier") || "contains" ),
                -options=>{
                        startsWith=>$i18n->get("starts with"),
                        contains=>$i18n->get("contains"),
                        endsWith=>$i18n->get("ends with")
                        }
                );
        $f->text(
                -name=>"keyword",
                -value=>$session->scratch->get("groupSearchKeyword"),
                -size=>15
                );
        $f->submit(value=>$i18n->get(170));
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
			.$session->icon->delete('op=deleteGroupGrouping;gid='.$parentId.';delete='.$id)
			.$session->icon->edit('op=editGroup;gid='.$id)
			.' '.$name.'<br />';
                $output .= walkGroups($session, $id,$indent."&nbsp; &nbsp; ");
        }
        $sth->finish;
	return $output;
}

#-------------------------------------------------------------------
sub www_addGroupsToGroupSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
	my $group = WebGUI::Group->new($session,$session->form->process("gid"));
	my @groups = $session->form->group('groups');
	$group->addGroups(\@groups);
	return www_manageGroupsInGroup($session);
}

#-------------------------------------------------------------------
sub www_addUsersToGroupSave {
	my $session = shift;
        return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
        my @users = $session->form->selectList('users');
	my $group = WebGUI::Group->new($session,$session->form->process("gid"));
	$group->addUsers(\@users);
        return www_manageUsersInGroup($session);
}

#-------------------------------------------------------------------
sub www_autoAddToGroup {
	my $session = shift;
        return WebGUI::AdminConsole->new($session,"groups")->render($session->privilege->insufficient()) unless ($session->user->userId ne 1);
	my $group = WebGUI::Group->new($session,$session->form->process("groupId"));
	if ($group->autoAdd) {
		$group->addUsers([$session->user->userId],[$session->form->process("groupId")]);
	}
	return "";
}

#-------------------------------------------------------------------
sub www_autoDeleteFromGroup {
	my $session = shift;
        return WebGUI::AdminConsole->new($session,"groups")->render($session->privilege->insufficient()) unless ($session->user->userId ne 1);
	my $group = WebGUI::Group->new($session,$session->form->process("groupId"));
	if ($group->autoDelete) {
		$group->deleteUsers([$session->user->userId],[$session->form->process("groupId")]);
	}
	return "";
}

#-------------------------------------------------------------------
sub www_deleteGroup {
	my $session = shift;
	return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
	return $session->privilege->vitalComponent() if (isIn($session->form->process("gid"), qw(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17)));
	my $g = WebGUI::Group->new($session,$session->form->process("gid"));
	$g->delete;
        return www_listGroups($session);
}

#-------------------------------------------------------------------
sub www_deleteGroupGrouping {
	my $session = shift;
	return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
	my $group = WebGUI::Group->new($session,$session->form->process("gid"));
	$group->deleteGroups([$session->form->process("delete")]);
	return www_manageGroupsInGroup($session);
}

#-------------------------------------------------------------------

=head2 www_deleteGrouping ( )

Deletes a set of users from a set of groups.  
The user and group lists are expected to
be found in form fields names uid and gid, respectively.  Visitors are not allowed to
perform this operation.

=cut

sub www_deleteGrouping {
	my $session = shift;
        return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
        if (($session->user->userId eq $session->form->process("uid") || $session->form->process("uid") eq '3') && $session->form->process("gid") eq '3') {
                return $session->privilege->vitalComponent();
        }
        my @users = $session->form->selectList('uid');
        my @groups = $session->form->group("gid");
        foreach my $user (@users) {
                my $u = WebGUI::User->new($session,$user);
                $u->deleteFromGroups(\@groups);
        }
        return WebGUI::Operation::Group::www_manageUsersInGroup($session);
}
                                                                                                                                                       

#-------------------------------------------------------------------
sub www_editGroup {
	my $session = shift;
	return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
        my ($output, $f, $g);
	if ($session->form->process("gid") eq "new") {
		$g = WebGUI::Group->new($session,"");
	} else {
		$g = WebGUI::Group->new($session,$session->form->process("gid"));
	}
	my $i18n = WebGUI::International->new($session);
	$f = WebGUI::HTMLForm->new($session);
	$f->submit;
        $f->hidden(
		-name => "op",
		-value => "editGroupSave",
	);
        $f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
        $f->readOnly(
		-label => $i18n->get(379),
		-value => $g->getId,
        );
        $f->text(
		-name => "groupName",
		-label => $i18n->get(84),
		-hoverHelp => $i18n->get('84 description'),
		-value => $g->name,
        );
        $f->textarea(
		-name => "description",
		-label => $i18n->get(85),
		-hoverHelp => $i18n->get('85 description'),
		-value => $g->description,
        );
        $f->interval(
		-name=>"expireOffset",
		-label=>$i18n->get(367), 
		-hoverHelp=>$i18n->get('367 description'), 
		-value=>$g->expireOffset
		);
	$f->yesNo(
		-name=>"expireNotify",
		-value=>$g->expireNotify,
		-label=>$i18n->get(865),
		-hoverHelp=>$i18n->get('865 description'),
		);
	$f->integer(
		-name=>"expireNotifyOffset",
		-value=>$g->expireNotifyOffset,
		-label=>$i18n->get(864),
		-hoverHelp=>$i18n->get('864 description'),
		);
        $f->textarea(
                -name=>"expireNotifyMessage",
		-value=>$g->expireNotifyMessage,
		-label=>$i18n->get(866),
		-hoverHelp=>$i18n->get('866 description'),
                );
        $f->integer(
                -name=>"deleteOffset",
                -value=>$g->deleteOffset,
                -label=>$i18n->get(863),
                -hoverHelp=>$i18n->get('863 description'),
                );
	if ($session->setting->get("useKarma")) {
		$f->integer(
                        -name=>"karmaThreshold",
                        -label=>$i18n->get(538),
                        -hoverHelp=>$i18n->get('538 description'),
                        -value=>$g->karmaThreshold
                        );
	}
	$f->textarea(
		-name=>"ipFilter",
		-value=>$g->ipFilter,
		-label=>$i18n->get(857),
		-hoverHelp=>$i18n->get('857 description'),
		);
	$f->textarea(
		-name=>"scratchFilter",
		-value=>$g->scratchFilter,
		-label=>$i18n->get(945),
		-hoverHelp=>$i18n->get('945 description'),
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
			-label=>$i18n->get(974),
			-hoverHelp=>$i18n->get('974 description'),
			);
		$f->yesNo(
			-name=>"autoDelete",
			-value=>$g->autoDelete,
			-label=>$i18n->get(975),
			-hoverHelp=>$i18n->get('975 description'),
			);
	}
	$f->databaseLink(
                -value=>[$g->databaseLinkId]
                );
	$f->textarea(
		-name=>"dbQuery",
		-value=>$g->dbQuery,
		-label=>$i18n->get(1005),
		-hoverHelp=>$i18n->get('1005 description'),
		);
		
    tie my %links, "Tie::IxHash";
	%links = %{WebGUI::LDAPLink->getList($session)};
	%links = (""=>$i18n->get("noldaplink"),%links);
	$f->selectBox(
	                -name=>"ldapLinkId",
					-label=>$i18n->get("ldapConnection","AuthLDAP"),
					-hoverHelp=>$i18n->get("ldapConnection description","AuthLDAP"),
					-options=>\%links,
					-value=>[$g->ldapLinkId]
				  );
	$f->text(
	       -name=>"ldapGroup",
		   -label=>$i18n->get("LDAPLink_ldapGroup","AuthLDAP"),
		   -hoverHelp=>$i18n->get("LDAPLink_ldapGroup","AuthLDAP"),
	       -value=>$g->ldapGroup
		);
    $f->text(
	       -name=>"ldapGroupProperty",
		   -label=>$i18n->get("LDAPLink_ldapGroupProperty","AuthLDAP"),
		   -hoverHelp=>$i18n->get("LDAPLink_ldapGroupProperty","AuthLDAP"),
		   -value=>$g->ldapGroupProperty,
		   -defaultValue=>"member"
	    );
    $f->text(
	       -name=>"ldapRecursiveProperty",
		   -label=>$i18n->get("LDAPLink_ldapRecursiveProperty","AuthLDAP"),
		   -hoverHelp=>$i18n->get("LDAPLink_ldapRecursiveProperty","AuthLDAP"),
		   -value=>$g->ldapRecursiveProperty
	    );
	$f->textarea(
	       -name=>"ldapRecursiveFilter",
		   -label=>$i18n->get("LDAPLink_ldapRecursiveFilter","AuthLDAP"),
		   -hoverHelp=>$i18n->get("LDAPLink_ldapRecursiveFilterDescription","AuthLDAP"),
		   -value=>$g->ldapRecursiveFilter
	    );
	$f->interval(
		-name=>"groupCacheTimeout",
		-label=>$i18n->get(1004), 
		-hoverHelp=>$i18n->get('1004 description'), 
		-value=>$g->groupCacheTimeout
		);
	$f->submit;
	$output .= $f->print;
        return _submenu($session,$output,'87');
}

#-------------------------------------------------------------------
sub www_editGroupSave {
    my $session = shift;
    my $gid = $session->form->process("gid");
    return $session->privilege->adminOnly
        unless canEditGroup($session, $gid);
    my $g = WebGUI::Group->new($session, $gid);
    # We don't want them to use an existing name.  If needed, we'll add a number to the name to keep it unique.
    my $groupName = $session->form->process("groupName");
    while (my $existingGroupId = WebGUI::Group->find($session, $groupName)->getId) {
        last
            if $existingGroupId eq $gid;
        $groupName =~ s/\A(.*?)(\d*)\z/
            my $newNum = ($2 || 0) + 1;
            substr($1, 0, 100 - length($newNum)) . $newNum;  #prevent name from growing over 100 chars
        /emsx;
    }
    $g->name($groupName);
    $g->description($session->form->process("description"));
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
	$g->groupCacheTimeout($session->form->interval("groupCacheTimeout"));
	$g->ldapLinkId($session->form->selectBox("ldapLinkId"));
	$g->ldapGroup($session->form->text("ldapGroup"));
	$g->ldapGroupProperty($session->form->text("ldapGroupProperty"));
	$g->ldapRecursiveProperty($session->form->text("ldapRecursiveProperty"));
	$g->ldapRecursiveFilter($session->form->process("ldapRecursiveFilter"));
	return www_listGroups($session);
}

#-------------------------------------------------------------------
sub www_editGrouping {
    my $session = shift;
    my $uid = $session->form->process('uid');
    my $gid = $session->form->process('gid');
    return $session->privilege->adminOnly()
        unless canEditGroup($session, $gid);
    my $i18n = WebGUI::International->new($session);
    my $f = WebGUI::HTMLForm->new($session);
    $f->submit;
    $f->hidden(
        -name => "op",
        -value => "editGroupingSave"
    );
    $f->hidden(
        -name => "uid",
        -value => $uid,
    );
    $f->hidden(
        -name => "gid",
        -value => $gid,
    );
    my $u = WebGUI::User->new($session,$uid);
    my $g = WebGUI::Group->new($session,$gid);
    $f->readOnly(
        -value => $u->username,
        -label => $i18n->get(50),
        -hoverHelp => $i18n->get('50 description'),
    );
    $f->readOnly(
        -value => $g && $g->name,
        -label => $i18n->get(84),
        -hoverHelp => $i18n->get('84 description'),
    );
    $f->date(
        -name => "expireDate",
        -label => $i18n->get(369),
        -hoverHelp => $i18n->get('369 description'),
        -value => $g && $g->userGroupExpireDate($uid),
    );
    $f->yesNo(
        -name=>"groupAdmin",
        -label=>$i18n->get(977),
        -hoverHelp=>$i18n->get('977 description'),
        -value=> $g && $g->userIsAdmin($uid),
    );
    $f->submit;
    return _submenu($session,$f->print,'370');
}

#-------------------------------------------------------------------
sub www_editGroupingSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
	my $group = WebGUI::Group->new($session,$session->form->process("gid"));
        $group->userGroupExpireDate($session->form->process("uid"),$session->datetime->setToEpoch($session->form->process("expireDate")));
        $group->userIsAdmin($session->form->process("uid"),$session->form->process("groupAdmin"));
        return www_manageUsersInGroup($session);
}

#-------------------------------------------------------------------
sub www_emailGroup {
	my $session = shift;
	return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
	my ($output,$f);
	my $i18n = WebGUI::International->new($session);
	$f = WebGUI::HTMLForm->new($session);
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
		-label=>$i18n->get(811),
		-hoverHelp=>$i18n->get('811 description'),
		);
	$f->text(
		-name=>"subject",
		-label=>$i18n->get(229),
		-hoverHelp=>$i18n->get('229 description'),
		);
	$f->HTMLArea(
		-name=>"message",
		-label=>$i18n->get(230),
		-hoverHelp=>$i18n->get('230 description'),
		);
	$f->submit($i18n->get(810));
	$output = $f->print;
	return _submenu($session,$output,'809');
}

#-------------------------------------------------------------------
sub www_emailGroupSend {
	my $session = shift;
	return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
	my $mail = WebGUI::Mail::Send->create($session, {toGroup=>$session->form->process("gid"),subject=>$session->form->process("subject"),from=>$session->form->process("from")});
	$mail->addHtml($session->form->process("message","HTMLArea"));
	$mail->addFooter;
	$mail->queue;
	my $i18n = WebGUI::International->new($session);
	return _submenu($session,$i18n->get(812));
}

#-------------------------------------------------------------------
sub www_listGroups {
	my $session = shift;
	my $i18n = WebGUI::International->new($session);
	if (canEditAll($session)) {
		my $output = getGroupSearchForm($session, "listGroups");
		my ($groupCount) = $session->db->quickArray("select count(*) from groups where isEditable=1");
        return _submenu($session,$output) unless ($session->form->process("doit") || $groupCount<250 || $session->form->process("pn") > 1);
		$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
		$output .= '<tr><td class="tableHeader">'.$i18n->get(84).'</td><td class="tableHeader">'
			.$i18n->get(85).'</td><td class="tableHeader">'
			.$i18n->get(748).'</td></tr>';
		my $p = doGroupSearch($session, "op=listGroups",1);
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
		return _submenu($session,$output);
	} elsif (canView($session)) {
		my ($output, $p, $sth, @data, @row, $i, $userCount);
        	my @editableGroups = $session->db->buildArray("select groupId from groupings where userId=".$session->db->quote($session->user->userId)." and groupAdmin=1");
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
        	$p = WebGUI::Paginator->new($session,$session->url->page('op=listGroups'));
        	$p->setDataByArrayRef(\@row);
        	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
        	$output .= '<tr><td class="tableHeader">'.$i18n->get(84).'</td><td class="tableHeader">'
                	.$i18n->get(85).'</td><td class="tableHeader">'
                	.$i18n->get(748).'</td></tr>';
        	$output .= $p->getPage($session->form->process("pn"));
        	$output .= '</table>';
        	$output .= $p->getBarTraditional($session->form->process("pn"));
        	return _submenu($session,$output,'89');
	}
    else {
	    return $session->privilege->adminOnly();
    }
}


#-------------------------------------------------------------------
sub www_manageGroupsInGroup {
	my $session = shift;
        return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
        my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
        $f->hidden(
		-name => "op",
		-value => "addGroupsToGroupSave"
	);
        $f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
	my @groups;
	my $group = WebGUI::Group->new($session,$session->form->process("gid"));
	my $groupsIn = $group->getGroupsIn(1);
	my $groupsFor = $group->getGroupsFor;
	push(@groups, @$groupsIn,@$groupsFor,$session->form->process("gid"));
	my $i18n = WebGUI::International->new($session);
        $f->group(
		-name=>"groups",
		-excludeGroups=>\@groups,
		-label=>$i18n->get(605),
		-size=>5,
		-multiple=>1
		);
        $f->submit;
        my $output = $f->print;
	$output .= '<p />';
	$output .= walkGroups($session, $session->form->process("gid"));
	return _submenu($session,$output,'813');
}

#-------------------------------------------------------------------
sub www_manageUsersInGroup {
	my $session = shift;
        return $session->privilege->adminOnly() unless (canEditGroup($session,$session->form->process("gid")));
	my $i18n = WebGUI::International->new($session);
	my $output = WebGUI::Form::formHeader($session,)
		.WebGUI::Form::hidden($session,{
			name=>"gid",
			value=>$session->form->process("gid")
			})
		.WebGUI::Form::hidden($session,{
			name=>"op",
			value=>"deleteGrouping"
			});
        $output .= '<table border="1" cellpadding="2" cellspacing="0"><tr><td class="tableHeader"><input type="image" src="'
		.$session->icon->getBaseURL().'delete.gif" border="0"></td>
                <td class="tableHeader">'.$i18n->get(50).'</td>
                <td class="tableHeader">'.$i18n->get(369).'</td></tr>';
	my $p = WebGUI::Paginator->new($session,$session->url->page("op=manageUsersInGroup;gid=".$session->form->process("gid")));
        $p->setDataByQuery("select users.username,users.userId,groupings.expireDate
                from groupings,users where groupings.groupId=".$session->db->quote($session->form->process("gid"))." and groupings.userId=users.userId
                order by users.username");
	foreach my $row (@{$p->getPageData}) {
                $output .= '<tr><td>'
			.WebGUI::Form::checkbox($session,{
				name=>"uid",
				value=>$row->{userId}
				})
                        .$session->icon->delete('op=deleteGrouping;uid='.$row->{userId}.';gid='.$session->form->process("gid"))
                        .$session->icon->edit('op=editGrouping;uid='.$row->{userId}.';gid='.$session->form->process("gid"))
                        .'</td>';
                $output .= '<td class="tableData"><a href="'.$session->url->page('op=editUser;uid='.$row->{userId}).'">'.$row->{username}.'</a></td>';
                $output .= '<td class="tableData">'.$session->datetime->epochToHuman($row->{expireDate},"%z").'</td></tr>';
        }
        $output .= '</table>'.WebGUI::Form::formFooter($session,);
	$output .= $p->getBarTraditional;
	$output .= '<p><h1>'.$i18n->get(976).'</h1>';
	$output .= WebGUI::Operation::User::getUserSearchForm($session, "manageUsersInGroup",{gid=>$session->form->process("gid")});
	my ($userCount) = $session->db->quickArray("select count(*) from users");
	return _submenu($session,$output) unless ($session->form->process("doit") || $userCount < 250 || $session->form->process("pn") > 1);
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		-name => "gid",
		-value => $session->form->process("gid")
	);
	$f->hidden(
		-name => "op",
		-value => "addUsersToGroupSave"
	);
	my $group = WebGUI::Group->new($session,$session->form->process("gid"));
	my $existingUsers = $group->getUsers;
	push(@{$existingUsers},"1");
	my %users;
	tie %users, "Tie::IxHash";
	my $sth = WebGUI::Operation::User::doUserSearch($session, "op=manageUsersInGroup;gid=".$session->form->process("gid"),0,$existingUsers);
	while (my $data = $sth->hashRef) {
		$users{$data->{userId}} = $data->{username};
		$users{$data->{userId}} .= " (".$data->{email}.")" if ($data->{email});
	}
	$sth->finish;
	$f->selectList(
		-name=>"users",
		-label=>$i18n->get(976),
		-options=>\%users,
		-multiple=>1,
		-size=>7
		);
	$f->submit;
	$output .= $f->print;
        return _submenu($session,$output,'88');
}



1;
