package WebGUI::Operation::User;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(vars subs);
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Operation::Auth;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editUserKarma &www_editUserKarmaSave &www_editUserGroup &www_editUserProfile &www_editUserProfileSave &www_addUserToGroupSave &www_deleteGrouping &www_editGrouping &www_editGroupingSave &www_becomeUser &www_addUser &www_addUserSave &www_deleteUser &www_deleteUserConfirm &www_editUser &www_editUserSave &www_listUsers);


#-------------------------------------------------------------------
sub _submenu {
	my ($output, %menu);
	tie %menu, 'Tie::IxHash';
	if (WebGUI::Grouping::isInGroup(3)) {
		$menu{WebGUI::URL::page("op=addUser")} = WebGUI::International::get(169);
		unless ($session{form}{op} eq "listUsers" 
			|| $session{form}{op} eq "addUser" 
			|| $session{form}{op} eq "deleteUserConfirm") {
			$menu{WebGUI::URL::page("op=editUser&uid=".$session{form}{uid})} = WebGUI::International::get(457);
			$menu{WebGUI::URL::page("op=editUserGroup&uid=".$session{form}{uid})} = WebGUI::International::get(458);
			$menu{WebGUI::URL::page("op=editUserProfile&uid=".$session{form}{uid})} = WebGUI::International::get(459);
			$menu{WebGUI::URL::page('op=viewProfile&uid='.$session{form}{uid})} = WebGUI::International::get(752);
			$menu{WebGUI::URL::page('op=becomeUser&uid='.$session{form}{uid})} = WebGUI::International::get(751);
			$menu{WebGUI::URL::page('op=deleteUser&uid='.$session{form}{uid})} = WebGUI::International::get(750);
			if ($session{setting}{useKarma}) {
				$menu{WebGUI::URL::page("op=editUserKarma&uid=".$session{form}{uid})} = WebGUI::International::get(555);
			}
		}
		$menu{WebGUI::URL::page("op=listUsers")} = WebGUI::International::get(456);
	} else {
		$menu{WebGUI::URL::page("op=addUser")} = WebGUI::International::get(169);
	}
	return menuWrapper($_[0],\%menu); 
}

#-------------------------------------------------------------------
sub www_addUser {
    my ($output, $f, $cmd, $html, %status);
    return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3) || WebGUI::Grouping::isInGroup(11));
    $output .= helpIcon("user add/edit");
	$output .= '<h1>'.WebGUI::International::get(163).'</h1>';
	$output .= WebGUI::Form::_javascriptFile("swapLayers.js");
	$output .= '<script language="JavaScript" > var active="'.$session{setting}{authMethod}.'"; </script>';
			
	if ($session{form}{op} eq "addUserSave") {
		$output .= '<ul><li>'.WebGUI::International::get(77).' '.$session{form}{username}.'Too or '.$session{form}{username}.'02</ul>';
	}
	
	$f = WebGUI::HTMLForm->new(-tableOptions=>"border=0 cellspacing=0 cellpadding=0");
	$f->hidden("op","addUserSave");
	$f->raw('<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr>');
    $f->text("username",WebGUI::International::get(50),$session{form}{username});
    $f->email("email",WebGUI::International::get(56));
    
	if(WebGUI::Grouping::isInGroup(3)){    
	   tie %status, 'Tie::IxHash';
	   %status = (
		   Active		=>WebGUI::International::get(817),
		   Deactivated	=>WebGUI::International::get(818)
		   );
	   $f->select("status",\%status,WebGUI::International::get(816), ['Active']);
       $f->group(
		     -name=>"groups",
		     -excludeGroups=>[1,2,7],
		     -label=>WebGUI::International::get(605),
		     -size=>5,
		     -multiple=>1
	   );
	}else{
	   $f->hidden("status","Active");
	}
	my $options;
	foreach (@{$session{config}{authMethods}}) {
		$options->{$_} = $_;
	}
	$f->select(
	            -name=>"authMethod",
				-options=>$options,
				-label=>WebGUI::International::get(164),
				-value=>[$session{setting}{authMethod}],
				-extras=>"onChange=\"active=operateHidden(this.options[this.selectedIndex].value,active)\""
			  );
	my $jscript = '<script language="JavaScript">';
	foreach (@{$session{config}{authMethods}}) {
		my $authInstance = WebGUI::Operation::Auth::getInstance($_,1);
		$f->raw('<tr id="'.$_.'"><td colspan="2" align="center"><table border=0 cellspacing=0 cellpadding=0>'.$authInstance->addUserForm("new").'<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr></table></td></tr>');
		$jscript .= "document.getElementById(\"$_\").style.display='".(($_ eq $session{setting}{authMethod})?"":"none")."';";
	}
	$jscript .= "</script>";	
	$f->submit;
	$output .= $f->print;
	$output .= $jscript;
    return _submenu($output);
}

#-------------------------------------------------------------------
sub www_addUserSave {
    my (@groups, $uid, $u);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3) || WebGUI::Grouping::isInGroup(11));
	($uid) = WebGUI::SQL->quickArray("select userId from users where username=".quote($session{form}{username}));
	return www_addUser if ($uid);
	
	$u = WebGUI::User->new("new");
	$u->username($session{form}{username});
	foreach (@{$session{config}{authMethods}}) {
	   my $authInstance = WebGUI::Operation::Auth::getInstance($_,$u->userId);
	   $authInstance->addUserFormSave;
	}
	$session{form}{uid}=$u->userId;
	$u->status($session{form}{status});
	$u->authMethod($session{form}{authMethod});
    @groups = $session{cgi}->param('groups');
	$u->addToGroups(\@groups);
	$u->profileField("email",$session{form}{email});
    return _submenu(WebGUI::International::get(978)) if(!WebGUI::Grouping::isInGroup(3));
	return www_editUser();
}

#-------------------------------------------------------------------
sub www_addUserToGroupSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my (@groups, $u);
        @groups = $session{cgi}->param('groups');
	$u = WebGUI::User->new($session{form}{uid});
	$u->addToGroups(\@groups);
        return www_editUserGroup();
}

#-------------------------------------------------------------------
sub www_becomeUser {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        WebGUI::Session::end($session{var}{sessionId});
	WebGUI::Session::start($session{form}{uid});
	return "";
}

#-------------------------------------------------------------------
sub www_deleteGrouping {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	if (($session{user}{userId} == $session{form}{uid} || $session{form}{uid} == 3) && $session{form}{gid} == 3) {
		return WebGUI::Privilege::vitalComponent();
        }
	my $u = WebGUI::User->new($session{form}{uid});
	$u->deleteFromGroups([$session{form}{gid}]);
	if ($session{form}{return} eq "manageUsersInGroup") {
		return WebGUI::Operation::Group::www_manageUsersInGroup();
	}
	return www_editUserGroup(); 
}

#-------------------------------------------------------------------
sub www_deleteUser {
        my ($output);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        if ($session{form}{uid} < 26) {
		return WebGUI::Privilege::vitalComponent();
        } else {
                $output .= helpIcon("user delete");
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(167).'<p>';
                $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteUserConfirm&uid='.$session{form}{uid}).
			'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listUsers').'">'.
			WebGUI::International::get(45).'</a></div>'; 
		return _submenu($output);
        }
}

#-------------------------------------------------------------------
sub www_deleteUserConfirm {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($u);
    if ($session{form}{uid} < 26) {
	   return WebGUI::Privilege::vitalComponent();
    } else {
	   $u = WebGUI::User->new($session{form}{uid});
	   $u->delete;
       return www_listUsers();
    }
}

#-------------------------------------------------------------------
sub www_editGrouping {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my $output .= '<h1>'.WebGUI::International::get(370).'</h1>';
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
	$output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editGroupingSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        WebGUI::Grouping::userGroupExpireDate($session{form}{uid},$session{form}{gid},setToEpoch($session{form}{expireDate}));
        WebGUI::Grouping::userGroupAdmin($session{form}{uid},$session{form}{gid},$session{form}{groupAdmin});
        return www_editUserGroup();
}

#-------------------------------------------------------------------
sub www_editUser {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $f, $u, $cmd, $html, %status);
	$u = WebGUI::User->new($session{form}{uid});
	$output .= WebGUI::Form::_javascriptFile("swapLayers.js");
	$output .= '<script language="JavaScript" > var active="'.$u->authMethod.'"; </script>';
    $output .= helpIcon("user add/edit");
	$output .= '<h1>'.WebGUI::International::get(168).'</h1>';
	$f = WebGUI::HTMLForm->new;
    $f->hidden("op","editUserSave");
    $f->hidden("uid",$session{form}{uid});
    $f->raw('<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr>');
	$f->readOnly($session{form}{uid},WebGUI::International::get(378));
    $f->readOnly($u->karma,WebGUI::International::get(537)) if ($session{setting}{useKarma});
    $f->readOnly(epochToHuman($u->dateCreated,"%z"),WebGUI::International::get(453));
    $f->readOnly(epochToHuman($u->lastUpdated,"%z"),WebGUI::International::get(454));
    $f->text("username",WebGUI::International::get(50),$u->username);
	tie %status, 'Tie::IxHash';
	%status = (
		Active		=>WebGUI::International::get(817),
		Deactivated	=>WebGUI::International::get(818),
		Selfdestructed	=>WebGUI::International::get(819)
		);
	if ($u->userId == $session{user}{userId}) {
		$f->hidden("status",$u->status);
	} else {
		$f->select("status",\%status,WebGUI::International::get(816),[$u->status]);
	}
	
	my $options;
	foreach (@{$session{config}{authMethods}}) {
		$options->{$_} = $_;
	}
	$f->select(
	            -name=>"authMethod",
				-options=>$options,
				-label=>WebGUI::International::get(164),
				-value=>[$u->authMethod],
				-extras=>"onChange=\"active=operateHidden(this.options[this.selectedIndex].value,active)\""
			  );
	my $jscript = '<script language="JavaScript">';
	foreach (@{$session{config}{authMethods}}) {
		my $authInstance = WebGUI::Operation::Auth::getInstance($_,$u->userId);
		$f->raw('<tr id="'.$_.'"><td colspan="2" align="center"><table>'.$authInstance->editUserForm.'<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr></table></td></tr>');
		$jscript .= "document.getElementById(\"$_\").style.display='".(($_ eq $u->authMethod)?"":"none")."';";
	}
	$jscript .= "</script>";	    
	$f->submit;
	$output .= $f->print;
	$output .= $jscript;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editUserSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
    my ($error, $uid, $u);
	($uid) = WebGUI::SQL->quickArray("select userId from users where username=".quote($session{form}{username}));
    
	if ($uid == $session{form}{uid} || $uid < 1) {
	   $u = WebGUI::User->new($session{form}{uid});
	   $u->username($session{form}{username});
	   $u->authMethod($session{form}{authMethod});
	   $u->status($session{form}{status});
	   foreach (@{$session{config}{authMethods}}) {
	      my $authInstance = WebGUI::Operation::Auth::getInstance($_,$u->userId);
	      $authInstance->editUserFormSave;
       }
	} else {
       $error = '<ul><li>'.WebGUI::International::get(77).' '.$session{form}{username}.'Too or '.$session{form}{username}.'02</ul>';
	}
	return $error.www_editUser();
}

#-------------------------------------------------------------------
sub www_editUserGroup {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $f, $groups, $sth, %hash);
	tie %hash, 'Tie::CPHash';
        $output .= '<h1>'.WebGUI::International::get(372).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("op","addUserToGroupSave");
        $f->hidden("uid",$session{form}{uid});
        $groups = WebGUI::Grouping::getGroupsForUser($session{form}{uid});
        push(@$groups,1); #visitors
        push(@$groups,2); #registered users
        push(@$groups,7); #everyone
        $f->group(
		-name=>"groups",
		-excludeGroups=>$groups,
		-label=>WebGUI::International::get(605),
		-size=>5,
		-multiple=>1
		);
        $f->submit;
	$output .= $f->print;
        $output .= '<p><table><tr><td class="tableHeader">'.WebGUI::International::get(89).
		'</td><td class="tableHeader">'.WebGUI::International::get(84).
		'</td><td class="tableHeader">'.WebGUI::International::get(369).'</td></tr>';
        $sth = WebGUI::SQL->read("select groups.groupId,groups.groupName,groupings.expireDate 
		from groupings,groups where groupings.groupId=groups.groupId and 
		groupings.userId=$session{form}{uid} order by groups.groupName");
        while (%hash = $sth->hash) {
                $output .= '<tr><td>'
			.deleteIcon('op=deleteGrouping&uid='.$session{form}{uid}.'&gid='.$hash{groupId})
                        .editIcon('op=editGrouping&uid='.$session{form}{uid}.'&gid='.$hash{groupId})
                        .'</td>';
                $output .= '<td class="tableData">'.$hash{groupName}.'</td>';
                $output .= '<td class="tableData">'.epochToHuman($hash{expireDate},"%z").'</td></tr>';
        }
        $sth->finish;
        $output .= '</table>';
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editUserKarma {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $f, $a, %user, %data, $method, $values, $category, $label, $default, $previousCategory);
        $output = helpIcon("karma using");
        $output .= '<h1>'.WebGUI::International::get(558).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","editUserKarmaSave");
        $f->hidden("uid",$session{form}{uid});
	$f->integer("amount",WebGUI::International::get(556));
	$f->text("description",WebGUI::International::get(557));
        $f->submit;
        $output .= $f->print;
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editUserKarmaSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($u);
        $u = WebGUI::User->new($session{form}{uid});
        $u->karma($session{form}{amount},$session{user}{username}." (".$session{user}{userId}.")",$session{form}{description});
        return www_editUser();
}

#-------------------------------------------------------------------
sub www_editUserProfile {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $f, $a, %user, %data, $method, $values, $category, $label, $default, $previousCategory);
	tie %data, 'Tie::CPHash';
	$output = helpIcon("user profile edit");
        $output .= '<h1>'.WebGUI::International::get(455).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("op","editUserProfileSave");
        $f->hidden("uid",$session{form}{uid});
	%user = WebGUI::SQL->buildHash("select fieldName,fieldData from userProfileData where userId=$session{form}{uid}");
        $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory
                where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
                order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
        while(%data = $a->hash) {
              	$category = eval $data{categoryName};
                if ($category ne $previousCategory) {
                      	$f->raw('<tr><td colspan="2" class="tableHeader">'.$category.'</td></tr>');
                }
                $values = eval $data{dataValues};
                $method = $data{dataType};
                $label = eval $data{fieldLabel};
                if ($method eq "selectList" || $method eq "checkList" || $method eq "radioList") {
                	# note: this big if statement doesn't look elegant, but doing regular
                        # ORs caused problems with the array reference.
                        
						# make sure the values are ordered         
                        my $orderedValues = {};
                        tie %{$orderedValues}, 'Tie::IxHash';
                        foreach my $ov (sort keys %{$values}) {
                        	$orderedValues->{$ov} = $values->{$ov};
                        }
                        
                        if ($session{form}{$data{fieldName}}) {
                      		$default = [$session{form}{$data{fieldName}}];
                        } elsif ($user{$data{fieldName}} && (defined($values->{$user{$data{fieldName}}}))) {
                                $default = [$user{$data{fieldName}}];
                        } else {
                                $default = eval $data{dataDefault};
                        }
                 	$f->$method(
				-name=>$data{fieldName},
				-options=>$orderedValues,
				-label=>$label,
				-value=>$default
				);
                } elsif ($method) {
			if ($session{form}{$data{fieldName}}) {
                        	$default = $session{form}{$data{fieldName}};
                        } elsif (exists $user{$data{fieldName}}) {
                                $default = $user{$data{fieldName}};
                        } else {
                                $default = eval $data{dataDefault};
                        }
                        $f->$method(
				-name=>$data{fieldName},
				-label=>$label,
				-value=>$default
				);
                }
                $previousCategory = $category;
        }
        $a->finish;
        $f->submit;
        $output .= $f->print;
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_editUserProfileSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($a, %field, $u);
      	tie %field, 'Tie::CPHash';
        $u = WebGUI::User->new($session{form}{uid});
      	$a = WebGUI::SQL->read("select * from userProfileField");
      	while (%field = $a->hash) {
               	if ($field{dataType} eq "date") {
                       	$session{form}{$field{fieldName}} = setToEpoch($session{form}{$field{fieldName}});
               	}
               	$u->profileField($field{fieldName},$session{form}{$field{fieldName}}) if (exists $session{form}{$field{fieldName}});
       	}
       	$a->finish;
        return www_editUserProfile();
}

#-------------------------------------------------------------------
sub www_listUsers {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::Session::setScratch("userSearchKeyword",$session{form}{keyword});
	WebGUI::Session::setScratch("userSearchStatus",$session{form}{status});
	my ($data, $rows, $p, %status, $selectedStatus);
	my $output = helpIcon("users manage");
	$output .= '<h1>'.WebGUI::International::get(149).'</h1>';
	$output .= '<div align="center">';
	tie %status, 'Tie::IxHash';
	%status = (
		""		=> WebGUI::International::get(821),
		Active		=> WebGUI::International::get(817),
		Deactivated	=> WebGUI::International::get(818),
		Selfdestructed	=> WebGUI::International::get(819)
	);
	my $f = WebGUI::HTMLForm->new(1);
	$f->hidden("op","listUsers");
	$f->hidden(
		-name=>"doit",
		-value=>1
		);
	$f->selectList(
		-name=>"modifier",
		-value=>([$session{form}{modifier}] || ["contains"]),
		-options=>{
			startsWith=>WebGUI::International::get("starts with"),
			contains=>WebGUI::International::get("contains"),
			endsWith=>WebGUI::International::get("ends with")
			}
		);
	$f->text(
		-name=>"keyword",
		-value=>$session{scratch}{userSearchKeyword},
		-size=>15
		);
	$f->selectList(
		-name	=> "status",
		-value	=> [$session{form}{status} || "users.status like '%'"],
		-options=> \%status
	);
	$f->submit(WebGUI::International::get(170));
	$output .= $f->print;
	$output .= '</div>';
	return _submenu($output) unless ($session{form}{doit});
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
        $output .= '<tr>
                <td class="tableHeader">'.WebGUI::International::get(816).'</td>
                <td class="tableHeader">'.WebGUI::International::get(50).'</td>
                <td class="tableHeader">'.WebGUI::International::get(56).'</td>
                <td class="tableHeader">'.WebGUI::International::get(453).'</td>
                <td class="tableHeader">'.WebGUI::International::get(454).'</td>
                <td class="tableHeader">'.WebGUI::International::get(429).'</td>
                <td class="tableHeader">'.WebGUI::International::get(434).'</td>
		</tr>';
	if ($session{scratch}{userSearchStatus}) {
		$selectedStatus = "status='".$session{scratch}{userSearchStatus}."'";
	} else {
		$selectedStatus = "status like '%'";
	}
	my $keyword = $session{scratch}{userSearchKeyword};
	if ($session{form}{modifier} eq "startsWith") {
		$keyword .= "%";
	} elsif ($session{form}{modifier} eq "contains") {
		$keyword = "%".$keyword."%";
	} else {
		$keyword = "%".$keyword;
	}
        $p = WebGUI::Paginator->new(WebGUI::URL::page("op=listUsers"));
	$p->setDataByQuery("select users.userId, users.username, users.status, users.dateCreated, users.lastUpdated,
		email.fieldData as email from users left join userProfileData email on users.userId=email.userId and email.fieldName='email'
		where $selectedStatus  and (users.username like ".quote($keyword)." or email.fieldData like ".quote($keyword).")  order by users.username");
	$rows = $p->getPageData;
	foreach $data (@$rows) {
		$output .= '<tr class="tableData">';
		$output .= '<td>'.$status{$data->{status}}.'</td>';
		$output .= '<td><a href="'.WebGUI::URL::page('op=editUser&uid='.$data->{userId})
			.'">'.$data->{username}.'</a></td>';
		$output .= '<td class="tableData">'.$data->{email}.'</td>';
		$output .= '<td class="tableData">'.epochToHuman($data->{dateCreated},"%z").'</td>';
		$output .= '<td class="tableData">'.epochToHuman($data->{lastUpdated},"%z").'</td>';
		my ($lastLoginStatus, $lastLogin) = WebGUI::SQL->quickArray("select status,timeStamp from userLoginLog where 
                        userId='$data->{userId}' order by timeStamp DESC");
                if ($lastLogin) {
                        $output .= '<td class="tableData">'.epochToHuman($lastLogin).'</td>';
                } else {
                        $output .= '<td class="tableData"> - </td>';
                }
                if ($lastLoginStatus) {
                        $output .= '<td class="tableData">'.$lastLoginStatus.'</td>';
                } else {
                        $output .= '<td class="tableData"> - </td>';
                }
		$output .= '</tr>';
	}
        $output .= '</table>';
        $output .= $p->getBarTraditional;
	return _submenu($output);
}

1;

