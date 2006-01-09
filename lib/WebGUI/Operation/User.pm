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

=head1 NAME

Package WebGUI::Operation::User

=head1 DESCRIPTION

Operation for creating, deleting, editing and many other user related functions.

=cut
#-------------------------------------------------------------------

=head2 _submenu ( $workarea [, $title, $help] )

Internal utility routine for setting up the Admin Console for User functions.

=head3 $workarea

The form and information to display to the administrator using the function.

=head3 $title

Internationalized title for the Admin Console, looked up in the WebGUI namespace if it exists.

=head3 $help

Help topic.  If set, then a Help icon will be displayed as a link to that topic.

=cut

sub _submenu {
	my $session = shift;
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new($session,"users");
        if ($help) {
                $ac->setHelp($help);
        }
	if (WebGUI::Grouping::isInGroup(11)) {
		$ac->addSubmenuItem($session->url->page("op=editUser;uid=new"), WebGUI::International::get(169));
	}
	if (WebGUI::Grouping::isInGroup(3)) {
		unless ($session->form->process("op") eq "listUsers" 
			|| $session->form->process("op") eq "deleteUserConfirm") {
			$ac->addSubmenuItem($session->url->page("op=editUser;uid=".$session->form->process("uid")), WebGUI::International::get(457));
			$ac->addSubmenuItem($session->url->page('op=becomeUser;uid='.$session->form->process("uid")), WebGUI::International::get(751));
			$ac->addSubmenuItem($session->url->page('op=deleteUser;uid='.$session->form->process("uid")), WebGUI::International::get(750));
			if ($session->setting->get("useKarma")) {
				$ac->addSubmenuItem($session->url->page("op=editUserKarma;uid=".$session->form->process("uid")), WebGUI::International::get(555));
			}
		}
		$ac->addSubmenuItem($session->url->page("op=listUsers"), WebGUI::International::get(456));
	}
        return $ac->render($workarea, $title);
}

=head2 doUserSearch ( $op, $returnPaginator, $userFilter )

Subroutine that actually performs the SQL search for users.

=head3 $op

The name of the calling operation, passed so that pagination links work correctly.

=head3 $returnPaginator

A boolean.  If true, a paginator object is returned.  Otherwise, a WebGUI::SQL
statement handler is returned.

=head3 $userFilter

Array reference, used to screen out user names via a SQL "not in ()" clause.

=cut

#-------------------------------------------------------------------
sub doUserSearch {
	my $session = shift;
	my $op = shift;
	my $returnPaginator = shift;
	my $userFilter = shift;
	push(@{$userFilter},0);
	my $selectedStatus;
	if ($session->scratch->get("userSearchStatus")) {
		$selectedStatus = "status='".$session->scratch->get("userSearchStatus")."'";
	} else {
		$selectedStatus = "status like '%'";
	}
	my $keyword = $session->scratch->get("userSearchKeyword");
	if ($session->scratch->get("userSearchModifier") eq "startsWith") {
		$keyword .= "%";
	} elsif ($session->scratch->get("userSearchModifier") eq "contains") {
		$keyword = "%".$keyword."%";
	} else {
		$keyword = "%".$keyword;
	}
	$keyword = $session->db->quote($keyword);
	my $sql = "select users.userId, users.username, users.status, users.dateCreated, users.lastUpdated,
                email.fieldData as email from users 
                left join userProfileData email on users.userId=email.userId and email.fieldName='email'
                left join userProfileData useralias on users.userId=useralias.userId and useralias.fieldName='alias'
                where $selectedStatus  and (users.username like ".$keyword." or useralias.fieldData like ".$keyword." or email.fieldData like ".$keyword.") 
                and users.userId not in (".$session->db->quoteAndJoin($userFilter).")  order by users.username";
	if ($returnPaginator) {
        	my $p = WebGUI::Paginator->new($session->url->page("op=".$op));
		$p->setDataByQuery($sql);
		return $p;
	} else {
		my $sth = $session->db->read($sql);
		return $sth;
	}
}

=head2 doUserSearchForm ( $op, $params )

Form front-end and display for searching for users.

=head3 $op

The name of the calling operation, passed so that pagination links work correctly.

=head3 $params

Hashref.  A set of key,value pairs that will be hidden in the user search form.

=cut

#-------------------------------------------------------------------
sub getUserSearchForm {
	my $session = shift;
	my $op = shift;
	my $params = shift;
	$session->scratch->set("userSearchKeyword",$session->form->process("keyword"));
	$session->scratch->set("userSearchStatus",$session->form->process("status"));
	$session->scratch->set("userSearchModifier",$session->form->process("modifier"));
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
		-value=>($session->scratch->get("userSearchModifier") || "contains"),
		-options=>{
			startsWith=>WebGUI::International::get("starts with"),
			contains=>WebGUI::International::get("contains"),
			endsWith=>WebGUI::International::get("ends with")
			}
		)
	.WebGUI::Form::text(
		-name=>"keyword",
		-value=>$session->scratch->get("userSearchKeyword"),
		-size=>15
		)
	.WebGUI::Form::selectBox(
		-name	=> "status",
		-value	=> ($session->scratch->get("userSearchStatus") || "users.status like '%'"),
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

=head2 www_becomeUser ( )

Allows an administrator to assume another user.

=cut

sub www_becomeUser {
	my $session = shift;
	return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	$session->user({userId=>$session->form->process("uid")});
	return "";
}

#-------------------------------------------------------------------

=head2 www_deleteUser ( )

Confirmation form for deleting a user. Only Admins are allowed to
delete users.  The WebGUI uses Visitor and Admin may not be deleted.
If the Admin confirms, then www_deleteUserConfirm is called.  The UID
of the user to delete is expected in a URL param names 'uid'.

=cut

sub www_deleteUser {
	my $session = shift;
        my ($output);
	return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        if ($session->form->process("uid") eq '1' || $session->form->process("uid") eq '3') {
		return _submenu($session->privilege->vitalComponent());
        } else {
                $output .= WebGUI::International::get(167).'<p>';
                $output .= '<div align="center"><a href="'.$session->url->page('op=deleteUserConfirm;uid='.$session->form->process("uid")).
			'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session->url->page('op=listUsers').'">'.
			WebGUI::International::get(45).'</a></div>'; 
		return _submenu($output,'42',"user delete");
        }
}

#-------------------------------------------------------------------

=head2 www_deleteUserConfirm ( )

Deletes a user.  Only Admins are allowed to delete users.  The UID of the user
to delete is expected in a URL param named 'uid'.  www_listUsers is called
after this.

=cut

sub www_deleteUserConfirm {
	my $session = shift;
	return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($u);
        if ($session->form->process("uid") eq '1' || $session->form->process("uid") eq '3') {
	   return WebGUI::AdminConsole->new($session,"users")->render($session->privilege->vitalComponent());
    } else {
	   $u = WebGUI::User->new($session->form->process("uid"));
	   $u->delete;
       return www_listUsers();
    }
}

#-------------------------------------------------------------------
sub www_editUser {
	my $session = shift;
	return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(11));
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
	my $u = WebGUI::User->new(($session->form->process("uid") eq 'new') ? '' : $session->form->process("uid"));
	$session->style->setScript($session->config->get("extrasURL")."/swapLayers.js", {type=>"text/javascript"});
	$session->style->setRawHeadTags('<script type="text/javascript">var active="'.$u->authMethod.'";</script>');
    	$tabform->hidden({name=>"op",value=>"editUserSave"});
    	$tabform->hidden({name=>"uid",value=>$session->form->process("uid")});
    	$tabform->getTab("account")->raw('<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr>');
	$tabform->getTab("account")->readOnly(value=>$session->form->process("uid"),label=>$i18n->get(378));
    	$tabform->getTab("account")->readOnly(value=>$u->karma,label=>$i18n->get(537)) if ($session->setting->get("useKarma"));
    	$tabform->getTab("account")->readOnly(value=>epochToHuman($u->dateCreated,"%z"),label=>$i18n->get(453));
    	$tabform->getTab("account")->readOnly(value=>epochToHuman($u->lastUpdated,"%z"),label=>$i18n->get(454));
    	$tabform->getTab("account")->text(
		-name=>"username",
		-label=>$i18n->get(50),
		-value=>$session->form->process("username")|| $u->username
		);
	my %status;
	tie %status, 'Tie::IxHash';
	%status = (
		Active		=>$i18n->get(817),
		Deactivated	=>$i18n->get(818),
		Selfdestructed	=>$i18n->get(819)
		);
	if ($u->userId eq $session->user->profileField("userId")) {
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
	foreach (@{$session->config->get("authMethods")}) {
		$options->{$_} = $_;
	}
	$tabform->getTab("account")->selectBox(
	        -name=>"authMethod",
		-options=>$options,
		-label=>$i18n->get(164),
		-value=>$u->authMethod,
		-extras=>"onChange=\"active=operateHidden(this.options[this.selectedIndex].value,active)\""
		);
	foreach (@{$session->config->get("authMethods")}) {
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
	my @groupsToAdd = $session->form->group("groupsToAdd");
	my @exclude = $session->db->buildArray("select groupId from groupings where userId=".$session->db->quote($u->userId));
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
			|| ($session->user->profileField("userId") eq $u->userId  && $group eq 3) # cannot remove self from admin
			|| ($u->userId eq "3" && $group eq "3") # admin user cannot be remove from admin
			) {
			push(@include,$group);
		}
	}
	push (@include, "0");
	my @groupsToDelete = $session->form->group("groupsToDelete");
	$tabform->getTab("groups")->selectList(
		-name=>"groupsToDelete",
		-options=>$session->db->buildHashRef("select groupId, groupName from groups 
			where groupId in (".$session->db->quoteAndJoin(\@include).") and showInForms=1 order by groupName"),
		-label=>$i18n->get("groups to delete"),
		-multiple=>1,
		-size=>15,
		-value=>\@groupsToDelete
		);
	return _submenu($error.$tabform->print,'168',"user add/edit");
}

#-------------------------------------------------------------------
sub www_editUserSave {
	my $session = shift;	
	my $isAdmin = WebGUI::Grouping::isInGroup(3);
	my $isSecondary;
	unless ($isAdmin) {
		$isSecondary = (WebGUI::Grouping::isInGroup(11) && $session->form->process("uid") eq "new");
	}
	return $session->privilege->adminOnly() unless ($isAdmin || $isSecondary);
	my ($uid) = $session->db->quickArray("select userId from users where username=".$session->db->quote($session->form->process("username")));
	my $error;
	if (($uid eq $session->form->process("uid") || $uid eq "") && $session->form->process("username") ne '') {
	   	my $u = WebGUI::User->new($session->form->process("uid"));
		$session->form->process("uid") = $u->userId unless ($isSecondary);
	   	$u->username($session->form->process("username"));
	   	$u->authMethod($session->form->process("authMethod"));
	   	$u->status($session->form->process("status"));
	   	foreach (@{$session->config->get("authMethods")}) {
	      		my $authInstance = WebGUI::Operation::Auth::getInstance($_,$u->userId);
	      		$authInstance->editUserFormSave;
       		}
		foreach my $field (@{WebGUI::ProfileField->getFields}) {
			next if $field->getId =~ /contentPositions/;
			$u->profileField($field->getId,$field->formProcess);
		}
		my @groups = $session->form->group("groupsToAdd");
		$u->addToGroups(\@groups);
		@groups = $session->form->group("groupsToDelete");
		$u->deleteFromGroups(\@groups);
	} else {
       		$error = '<ul><li>'.WebGUI::International::get(77).' '.$session->form->process("username").'Too or '.$session->form->process("username").'02</li></ul>';
	}
	if ($isSecondary) {
		return _submenu(WebGUI::International::get(978));
	} else {
		return www_editUser($error);
	}
}

#-------------------------------------------------------------------
sub www_editUserKarma {
	my $session = shift;
	return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $f, $a, %user, %data, $method, $values, $category, $label, $default, $previousCategory);
        $f = WebGUI::HTMLForm->new;
        $f->hidden(
		-name => "op",
		-value => "editUserKarmaSave",
        );
        $f->hidden(
		-name => "uid",
		-value => $session->form->process("uid"),
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
	my $session = shift;
	return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($u);
        $u = WebGUI::User->new($session->form->process("uid"));
        $u->karma($session->form->process("amount"),$session->user->profileField("username")." (".$session->user->profileField("userId").")",$session->form->process("description"));
        return www_editUser();
}

#-------------------------------------------------------------------
sub www_listUsers {
	my $session = shift;
	unless (WebGUI::Grouping::isInGroup(3)) {
		if (WebGUI::Grouping::isInGroup(11)) {
			$session->form->process("uid") = "new";
			return www_editUser();
		}
		return $session->privilege->adminOnly();
	}
	my %status;
	my $output = getUserSearchForm("listUsers");
	my ($userCount) = $session->db->quickArray("select count(*) from users");
	return _submenu($output) unless ($session->form->process("doit") || $userCount<250 || $session->form->process("pn") > 1);
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
		$output .= '<td><a href="'.$session->url->page('op=editUser;uid='.$data->{userId})
			.'">'.$data->{username}.'</a></td>';
		$output .= '<td class="tableData">'.$data->{email}.'</td>';
		$output .= '<td class="tableData">'.epochToHuman($data->{dateCreated},"%z").'</td>';
		$output .= '<td class="tableData">'.epochToHuman($data->{lastUpdated},"%z").'</td>';
		my ($lastLoginStatus, $lastLogin) = $session->db->quickArray("select status,timeStamp from userLoginLog where 
                        userId=".$session->db->quote($data->{userId})." order by timeStamp DESC");
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

