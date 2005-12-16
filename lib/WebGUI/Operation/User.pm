package WebGUI::Operation::User;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::DateTime;
use WebGUI::FormProcessor;
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::Form;
use WebGUI::Form::DynamicField;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Auth;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::TabForm;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;


#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("users");
        if ($help) {
                $ac->setHelp($help);
        }
	if (WebGUI::Grouping::isInGroup(11)) {
		$ac->addSubmenuItem(WebGUI::URL::page("op=editUser;uid=new"), WebGUI::International::get(169));
	}
	if (WebGUI::Grouping::isInGroup(3)) {
		unless ($session{form}{op} eq "listUsers" 
			|| $session{form}{op} eq "deleteUserConfirm") {
			$ac->addSubmenuItem(WebGUI::URL::page("op=editUser;uid=".$session{form}{uid}), WebGUI::International::get(457));
			$ac->addSubmenuItem(WebGUI::URL::page('op=becomeUser;uid='.$session{form}{uid}), WebGUI::International::get(751));
			$ac->addSubmenuItem(WebGUI::URL::page('op=deleteUser;uid='.$session{form}{uid}), WebGUI::International::get(750));
			if ($session{setting}{useKarma}) {
				$ac->addSubmenuItem(WebGUI::URL::page("op=editUserKarma;uid=".$session{form}{uid}), WebGUI::International::get(555));
			}
		}
		$ac->addSubmenuItem(WebGUI::URL::page("op=listUsers"), WebGUI::International::get(456));
	}
        return $ac->render($workarea, $title);
}
                                                                                                                                                       

#-------------------------------------------------------------------
sub doUserSearch {
	my $op = shift;
	my $returnPaginator = shift;
	my $userFilter = shift;
	push(@{$userFilter},0);
	my $selectedStatus;
	if ($session{scratch}{userSearchStatus}) {
		$selectedStatus = "status='".$session{scratch}{userSearchStatus}."'";
	} else {
		$selectedStatus = "status like '%'";
	}
	my $keyword = $session{scratch}{userSearchKeyword};
	if ($session{scratch}{userSearchModifier} eq "startsWith") {
		$keyword .= "%";
	} elsif ($session{scratch}{userSearchModifier} eq "contains") {
		$keyword = "%".$keyword."%";
	} else {
		$keyword = "%".$keyword;
	}
	$keyword = quote($keyword);
	my $sql = "select users.userId, users.username, users.status, users.dateCreated, users.lastUpdated,
                email.fieldData as email from users 
                left join userProfileData email on users.userId=email.userId and email.fieldName='email'
                left join userProfileData useralias on users.userId=useralias.userId and useralias.fieldName='alias'
                where $selectedStatus  and (users.username like ".$keyword." or useralias.fieldData like ".$keyword." or email.fieldData like ".$keyword.") 
                and users.userId not in (".quoteAndJoin($userFilter).")  order by users.username";
	if ($returnPaginator) {
        	my $p = WebGUI::Paginator->new(WebGUI::URL::page("op=".$op));
		$p->setDataByQuery($sql);
		return $p;
	} else {
		my $sth = WebGUI::SQL->read($sql);
		return $sth;
	}
}


#-------------------------------------------------------------------
sub getUserSearchForm {
	my $op = shift;
	my $params = shift;
	WebGUI::Session::setScratch("userSearchKeyword",$session{form}{keyword});
	WebGUI::Session::setScratch("userSearchStatus",$session{form}{status});
	WebGUI::Session::setScratch("userSearchModifier",$session{form}{modifier});
	my $output = '<div align="center">'
		.WebGUI::Form::formHeader()
		.WebGUI::Form::hidden(
			name => "op",
			value => $op
			);
	foreach my $key (keys %{$params}) {
		$output .= WebGUI::Form::hidden(
			name=>$key,
			value=>$params->{$key}
			);
	}
	$output .= WebGUI::Form::hidden(
		-name=>"doit",
		-value=>1
		)
	.WebGUI::Form::selectBox(
		-name=>"modifier",
		-value=>($session{scratch}{userSearchModifier} || "contains"),
		-options=>{
			startsWith=>WebGUI::International::get("starts with"),
			contains=>WebGUI::International::get("contains"),
			endsWith=>WebGUI::International::get("ends with")
			}
		)
	.WebGUI::Form::text(
		-name=>"keyword",
		-value=>$session{scratch}{userSearchKeyword},
		-size=>15
		)
	.WebGUI::Form::selectBox(
		-name	=> "status",
		-value	=> ($session{scratch}{userSearchStatus} || "users.status like '%'"),
		-options=> { 
			""		=> WebGUI::International::get(821),
			Active		=> WebGUI::International::get(817),
			Deactivated	=> WebGUI::International::get(818),
			Selfdestructed	=> WebGUI::International::get(819)
			}
	)
	.WebGUI::Form::submit(value=>WebGUI::International::get(170))
	.WebGUI::Form::formFooter();
	$output .= '</div>';
	return $output;
}


#-------------------------------------------------------------------
sub www_becomeUser {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::Session::convertVisitorToUser($session{var}{sessionId},$session{form}{uid});
	return "";
}

#-------------------------------------------------------------------
sub www_deleteGrouping {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	if (($session{user}{userId} eq $session{form}{uid} || $session{form}{uid} eq '3') && $session{form}{gid} eq '3') {
		return _submenu(WebGUI::Privilege::vitalComponent());
        }
        my @users = WebGUI::FormProcessor::selectList('uid');
	my @groups = WebGUI::FormProcessor::group("gid");
	foreach my $user (@users) {
		my $u = WebGUI::User->new($user);
		$u->deleteFromGroups(\@groups);
	}
	if ($session{form}{return} eq "manageUsersInGroup") {
		return WebGUI::Operation::Group::www_manageUsersInGroup();
	}
	return www_editUserGroup(); 
}

#-------------------------------------------------------------------
sub www_deleteUser {
        my ($output);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        if ($session{form}{uid} eq '1' || $session{form}{uid} eq '3') {
		return _submenu(WebGUI::Privilege::vitalComponent());
        } else {
                $output .= WebGUI::International::get(167).'<p>';
                $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deleteUserConfirm;uid='.$session{form}{uid}).
			'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=listUsers').'">'.
			WebGUI::International::get(45).'</a></div>'; 
		return _submenu($output,'42',"user delete");
        }
}

#-------------------------------------------------------------------
sub www_deleteUserConfirm {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($u);
        if ($session{form}{uid} eq '1' || $session{form}{uid} eq '') {
	   return WebGUI::AdminConsole->new("users")->render(WebGUI::Privilege::vitalComponent());
    } else {
	   $u = WebGUI::User->new($session{form}{uid});
	   $u->delete;
       return www_listUsers();
    }
}

#-------------------------------------------------------------------
sub www_editUser {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(11));
	my $error = shift;
	my $i18n = WebGUI::International->new("WebGUI");
	my %tabs;
	tie %tabs, 'Tie::IxHash';
	%tabs = (
		"account"=> { label=>$i18n->get("account")},
		"profile"=> { label=>$i18n->get("profile")},
		"groups"=> { label=>$i18n->get('89')},
		);
	my $tabform = WebGUI::TabForm->new(\%tabs);
	my $u = WebGUI::User->new(($session{form}{uid} eq 'new') ? '' : $session{form}{uid});
	WebGUI::Style::setScript($session{config}{extrasURL}."/swapLayers.js", {type=>"text/javascript"});
	WebGUI::Style::setRawHeadTags('<script type="text/javascript">var active="'.$u->authMethod.'";</script>');
    	$tabform->hidden({name=>"op",value=>"editUserSave"});
    	$tabform->hidden({name=>"uid",value=>$session{form}{uid}});
    	$tabform->getTab("account")->raw('<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr>');
	$tabform->getTab("account")->readOnly(value=>$session{form}{uid},label=>$i18n->get(378));
    	$tabform->getTab("account")->readOnly(value=>$u->karma,label=>$i18n->get(537)) if ($session{setting}{useKarma});
    	$tabform->getTab("account")->readOnly(value=>epochToHuman($u->dateCreated,"%z"),label=>$i18n->get(453));
    	$tabform->getTab("account")->readOnly(value=>epochToHuman($u->lastUpdated,"%z"),label=>$i18n->get(454));
    	$tabform->getTab("account")->text(
		-name=>"username",
		-label=>$i18n->get(50),
		-value=>$session{form}{username}|| $u->username
		);
	my %status;
	tie %status, 'Tie::IxHash';
	%status = (
		Active		=>$i18n->get(817),
		Deactivated	=>$i18n->get(818),
		Selfdestructed	=>$i18n->get(819)
		);
	if ($u->userId eq $session{user}{userId}) {
		$tabform->getTab("account")->hidden(
			-name => "status",
			-value => $u->status
			);
	} else {
		$tabform->getTab("account")->selectBox(
			-name => "status",
			-options => \%status,
			-label => $i18n->get(816),
			-value => $u->status
			);
	}
	my $options;
	foreach (@{$session{config}{authMethods}}) {
		$options->{$_} = $_;
	}
	$tabform->getTab("account")->selectBox(
	        -name=>"authMethod",
		-options=>$options,
		-label=>$i18n->get(164),
		-value=>$u->authMethod,
		-extras=>"onChange=\"active=operateHidden(this.options[this.selectedIndex].value,active)\""
		);
	foreach (@{$session{config}{authMethods}}) {
		my $authInstance = WebGUI::Operation::Auth::getInstance($_,$u->userId);
		my $style = '" style="display: none;' unless ($_ eq $u->authMethod);
		$tabform->getTab("account")->raw('<tr id="'.$_.$style.'"><td colspan="2" align="center"><table>'.$authInstance->editUserForm.'<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr></table></td></tr>');
	}
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		$tabform->getTab("profile")->raw('<tr><td colspan="2" class="tableHeader">'.$category->getLabel.'</td></tr>');
		foreach my $field (@{$category->getFields}) {
			next if $field->getId =~ /contentPositions/;
			my $label = $field->getLabel . ($field->isRequired ? "*" : '');
			$tabform->getTab("profile")->raw($field->formField({label=>$label},1,$u));
		}
	}
	my @groupsToAdd = WebGUI::FormProcessor::group("groupsToAdd");
	my @exclude = WebGUI::SQL->buildArray("select groupId from groupings where userId=".quote($u->userId));
	@exclude = (@exclude,"1","2","7");
	$tabform->getTab("groups")->group(
		-name=>"groupsToAdd",
		-label=>$i18n->get("groups to add"),
		-excludeGroups=>\@exclude,
		-size=>15,
		-multiple=>1,
		-value=>\@groupsToAdd
		);
	my @include; 
	foreach my $group (@exclude) {
		unless (
			$group eq "1" || $group eq "2" || $group eq "7" # can't remove user from magic groups 
			|| ($session{user}{userId} eq $u->userId  && $group eq 3) # cannot remove self from admin
			|| ($u->userId eq "3" && $group eq "3") # admin user cannot be remove from admin
			) {
			push(@include,$group);
		}
	}
	push (@include, "0");
	my @groupsToDelete = WebGUI::FormProcessor::group("groupsToDelete");
	$tabform->getTab("groups")->selectList(
		-name=>"groupsToDelete",
		-options=>WebGUI::SQL->buildHashRef("select groupId, groupName from groups 
			where groupId in (".quoteAndJoin(\@include).") and showInForms=1 order by groupName"),
		-label=>$i18n->get("groups to delete"),
		-multiple=>1,
		-size=>15,
		-value=>\@groupsToDelete
		);
	return _submenu($error.$tabform->print,'168',"user add/edit");
}

#-------------------------------------------------------------------
sub www_editUserSave {	
	my $isAdmin = WebGUI::Grouping::isInGroup(3);
	my $isSecondary;
	unless ($isAdmin) {
		$isSecondary = (WebGUI::Grouping::isInGroup(11) && $session{form}{uid} eq "new");
	}
	return WebGUI::Privilege::adminOnly() unless ($isAdmin || $isSecondary);
	my ($uid) = WebGUI::SQL->quickArray("select userId from users where username=".quote($session{form}{username}));
	my $error;
	if (($uid eq $session{form}{uid} || $uid eq "") && $session{form}{username} ne '') {
	   	my $u = WebGUI::User->new($session{form}{uid});
		$session{form}{uid} = $u->userId unless ($isSecondary);
	   	$u->username($session{form}{username});
	   	$u->authMethod($session{form}{authMethod});
	   	$u->status($session{form}{status});
	   	foreach (@{$session{config}{authMethods}}) {
	      		my $authInstance = WebGUI::Operation::Auth::getInstance($_,$u->userId);
	      		$authInstance->editUserFormSave;
       		}
		foreach my $field (@{WebGUI::ProfileField->getFields}) {
			next if $field->getId =~ /contentPositions/;
			$u->profileField($field->getId,$field->formProcess);
		}
		my @groups = WebGUI::FormProcessor::group("groupsToAdd");
		$u->addToGroups(\@groups);
		@groups = WebGUI::FormProcessor::group("groupsToDelete");
		$u->deleteFromGroups(\@groups);
	} else {
       		$error = '<ul><li>'.WebGUI::International::get(77).' '.$session{form}{username}.'Too or '.$session{form}{username}.'02</li></ul>';
	}
	if ($isSecondary) {
		return _submenu(WebGUI::International::get(978));
	} else {
		return www_editUser($error);
	}
}

#-------------------------------------------------------------------
sub www_editUserKarma {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $f, $a, %user, %data, $method, $values, $category, $label, $default, $previousCategory);
        $f = WebGUI::HTMLForm->new;
        $f->hidden(
		-name => "op",
		-value => "editUserKarmaSave",
        );
        $f->hidden(
		-name => "uid",
		-value => $session{form}{uid},
        );
	$f->integer(
		-name => "amount",
		-label => WebGUI::International::get(556),
		-hoverHelp => WebGUI::International::get('556 description'),
	);
	$f->text(
		-name => "description",
		-label => WebGUI::International::get(557),
		-hoverHelp => WebGUI::International::get('557 description'),
	);
        $f->submit;
        $output .= $f->print;
        return _submenu($output,'558',"edit user karma");
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
sub www_listUsers {
	unless (WebGUI::Grouping::isInGroup(3)) {
		if (WebGUI::Grouping::isInGroup(11)) {
			$session{form}{uid} = "new";
			return www_editUser();
		}
		return WebGUI::Privilege::adminOnly();
	}
	my %status;
	my $output = getUserSearchForm("listUsers");
	my ($userCount) = WebGUI::SQL->quickArray("select count(*) from users");
	return _submenu($output) unless ($session{form}{doit} || $userCount<250 || $session{form}{pn} > 1);
	tie %status, 'Tie::IxHash';
	%status = (
		Active		=> WebGUI::International::get(817),
		Deactivated	=> WebGUI::International::get(818),
		Selfdestructed	=> WebGUI::International::get(819)
	);
        $output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
        $output .= '<tr>
                <td class="tableHeader">'.WebGUI::International::get(816).'</td>
                <td class="tableHeader">'.WebGUI::International::get(50).'</td>
                <td class="tableHeader">'.WebGUI::International::get(56).'</td>
                <td class="tableHeader">'.WebGUI::International::get(453).'</td>
                <td class="tableHeader">'.WebGUI::International::get(454).'</td>
                <td class="tableHeader">'.WebGUI::International::get(429).'</td>
                <td class="tableHeader">'.WebGUI::International::get(434).'</td>
		</tr>';
	my $p = doUserSearch("listUsers",1);
	foreach my $data (@{$p->getPageData}) {
		$output .= '<tr class="tableData">';
		$output .= '<td>'.$status{$data->{status}}.'</td>';
		$output .= '<td><a href="'.WebGUI::URL::page('op=editUser;uid='.$data->{userId})
			.'">'.$data->{username}.'</a></td>';
		$output .= '<td class="tableData">'.$data->{email}.'</td>';
		$output .= '<td class="tableData">'.epochToHuman($data->{dateCreated},"%z").'</td>';
		$output .= '<td class="tableData">'.epochToHuman($data->{lastUpdated},"%z").'</td>';
		my ($lastLoginStatus, $lastLogin) = WebGUI::SQL->quickArray("select status,timeStamp from userLoginLog where 
                        userId=".quote($data->{userId})." order by timeStamp DESC");
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
	return _submenu($output,undef,"users manage");
}

1;

