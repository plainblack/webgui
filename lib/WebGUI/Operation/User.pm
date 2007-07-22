package WebGUI::Operation::User;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use WebGUI::Group;
use WebGUI::Form;
use WebGUI::Form::DynamicField;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Operation::Auth;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::User;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Operation::User

=head1 DESCRIPTION

Operation for creating, deleting, editing and many other user related functions.

=cut


#-------------------------------------------------------------------

=head2 _submenu ( session, properties )

Internal utility routine for setting up the Admin Console for User functions.

=head3 session

A reference to the current session.

=head3 properties

A hash reference containing all the properties to set in this submenu

workarea: content to render in admin console

userId: userId of user to be modified by submenu controls such as edit and delete

title: internationalization key from users for text to display as the admin consoles title

help: interanationalization key from users help to link current screen help icon to

=cut

sub _submenu {
	my $session = shift;
	my $properties = shift;
	my $i18n = WebGUI::International->new($session);
	my $ac = WebGUI::AdminConsole->new($session,"users");
	my $userId = $properties->{userId} || $session->form->get("uid");
	my $workarea = $properties->{workarea};
	my $title;
	$title = $i18n->get($properties->{title}) if ($properties->{title});

	if ($session->user->isInGroup(11)) {
		$ac->addSubmenuItem($session->url->page("op=editUser;uid=new"), $i18n->get(169));
	}

	if ($session->user->isInGroup(3)) {
		unless ($session->form->process("op") eq "listUsers" 
			|| $session->form->process("op") eq "deleteUserConfirm"
			|| $userId eq "new") {
			$ac->addSubmenuItem($session->url->page("op=editUser;uid=$userId"), $i18n->get(457));
			$ac->addSubmenuItem($session->url->page("op=becomeUser;uid=$userId"), $i18n->get(751));
			$ac->addConfirmedSubmenuItem($session->url->page("op=deleteUser;uid=$userId"), $i18n->get(750), $i18n->get(167));
			if ($session->setting->get("useKarma")) {
				$ac->addSubmenuItem($session->url->page("op=editUserKarma;uid=$userId"), $i18n->get(555));
			}
		}
		$ac->addSubmenuItem($session->url->page("op=listUsers"), $i18n->get(456));
	}
        return $ac->render($workarea, $title);
}

=head2 doUserSearch ( session, op, returnPaginator, userFilter )

Subroutine that actually performs the SQL search for users.

=head3 session

A reference to the current session.

=head3 op

The name of the calling operation, passed so that pagination links work correctly.

=head3 returnPaginator

A boolean.  If true, a paginator object is returned.  Otherwise, a WebGUI::SQL
statement handler is returned.

=head3 userFilter

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
                userProfileData.email from users 
                left join userProfileData on users.userId=userProfileData.userId 
                where $selectedStatus  and (users.username like ".$keyword." or alias like ".$keyword." or email like ".$keyword.") 
                and users.userId not in (".$session->db->quoteAndJoin($userFilter).")  order by users.username";
	if ($returnPaginator) {
        	my $p = WebGUI::Paginator->new($session,$session->url->page("op=".$op));
		$p->setDataByQuery($sql);
		return $p;
	} else {
		my $sth = $session->db->read($sql);
		return $sth;
	}
}

#-------------------------------------------------------------------

=head2 doUserSearchForm ( session, op, params, noStatus )

Form front-end and display for searching for users.

=head3 session

A reference to the current session.

=head3 op

The name of the calling operation, passed so that pagination links work correctly.

=head3 params

Hashref.  A set of key,value pairs that will be hidden in the user search form.

=head3 noStatus

Don't display the status filter.

=cut

sub getUserSearchForm {
	my $session = shift;
	my $op = shift;
	my $params = shift;
	my $noStatus = shift;
	$session->scratch->set("userSearchKeyword",$session->form->process("keyword")) if defined($session->form->process("keyword"));
	$session->scratch->set("userSearchStatus",$session->form->process("status")) if defined($session->form->process("status"));
	$session->scratch->set("userSearchModifier",$session->form->process("modifier")) if defined($session->form->process("modifier"));
	my $i18n = WebGUI::International->new($session);
	my $output = '<div align="center">'
		.WebGUI::Form::formHeader($session,)
		.WebGUI::Form::hidden($session,
			name => "op",
			value => $op
			);
	foreach my $key (keys %{$params}) {
		$output .= WebGUI::Form::hidden($session,
			name=>$key,
			value=>$params->{$key}
			);
	}
	$output .= WebGUI::Form::hidden($session,
		-name=>"doit",
		-value=>1
		)
	.WebGUI::Form::selectBox($session,
		-name=>"modifier",
		-value=>($session->scratch->get("userSearchModifier") || "contains"),
		-options=>{
			startsWith=>$i18n->get("starts with"),
			contains=>$i18n->get("contains"),
			endsWith=>$i18n->get("ends with")
			}
		)
	.WebGUI::Form::text($session,
		-name=>"keyword",
		-value=>$session->scratch->get("userSearchKeyword"),
		-size=>15
		);
	if ($noStatus) {	
		$output .= WebGUI::Form::hidden($session,
                        name => "status",
                        value => "Active"
                        );
	} else {
		$output .= WebGUI::Form::selectBox($session,
			-name	=> "status",
			-value	=> ($session->scratch->get("userSearchStatus") || "users.status like '%'"),
			-options=> { 
				""		=> $i18n->get(821),
				Active		=> $i18n->get(817),
				Deactivated	=> $i18n->get(818),
				Selfdestructed	=> $i18n->get(819)
				}
		);
	}
	$output .= WebGUI::Form::submit($session,value=>$i18n->get(170))
	.WebGUI::Form::formFooter($session,);
	$output .= '</div>';
	return $output;
}


#-------------------------------------------------------------------

=head2 www_becomeUser ( )

Allows an administrator to assume another user.

=cut

sub www_becomeUser {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	return unless WebGUI::User->validUserId($session, $session->form->process("uid"));
	$session->var->end($session->var->get("sessionId"));
	$session->user({userId=>$session->form->process("uid")});
	return "";
}

#-------------------------------------------------------------------

=head2 www_deleteUser ( )

Deletes a user.  Only Admins are allowed to delete users.  The UID of the user
to delete is expected in a URL param named 'uid'.  www_listUsers is called
after this.

=cut

sub www_deleteUser {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my ($u);
        if ($session->form->process("uid") eq '1' || $session->form->process("uid") eq '3') {
	   return WebGUI::AdminConsole->new($session,"users")->render($session->privilege->vitalComponent());
    } else {
	   $u = WebGUI::User->new($session,$session->form->process("uid"));
	   $u->delete;
       return www_listUsers($session);
    }
}

#-------------------------------------------------------------------
sub www_editUser {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(11));
	my $error = shift;
	my $uid = shift || $session->form->process("uid");
	my $i18n = WebGUI::International->new($session, "WebGUI");
	my %tabs;
	tie %tabs, 'Tie::IxHash';
	%tabs = (
		"account"=> { label=>$i18n->get("account")},
		"profile"=> { label=>$i18n->get("profile")},
		"groups"=> { label=>$i18n->get('89')},
		);
	my $tabform = WebGUI::TabForm->new($session,\%tabs);
	$tabform->formHeader({extras=>'autocomplete="off"'});	
	my $u = WebGUI::User->new($session,($uid eq 'new') ? '' : $uid); #Setting uid to '' when uid is 'new' so visitor defaults prefill field for new user
	my $username = ($u->userId eq '1' && $uid ne "1") ? '' : $u->username;
    	$tabform->hidden({name=>"op",value=>"editUserSave"});
    	$tabform->hidden({name=>"uid",value=>$uid});
    	$tabform->getTab("account")->raw('<tr><td width="170">&nbsp;</td><td>&nbsp;</td></tr>');
	$tabform->getTab("account")->readOnly(value=>$uid,label=>$i18n->get(378));
    	$tabform->getTab("account")->readOnly(value=>$u->karma,label=>$i18n->get(537)) if ($session->setting->get("useKarma"));
    	$tabform->getTab("account")->readOnly(value=>$session->datetime->epochToHuman($u->dateCreated,"%z"),label=>$i18n->get(453));
    	$tabform->getTab("account")->readOnly(value=>$session->datetime->epochToHuman($u->lastUpdated,"%z"),label=>$i18n->get(454));
    	$tabform->getTab("account")->text(
		-name=>"username",
		-label=>$i18n->get(50),
		-value=>$username
		);
	my %status;
	tie %status, 'Tie::IxHash';
	%status = (
		Active		=>$i18n->get(817),
		Deactivated	=>$i18n->get(818),
		Selfdestructed	=>$i18n->get(819)
		);
	if ($u->userId eq $session->user->userId) {
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
		);
	foreach (@{$session->config->get("authMethods")}) {
		$tabform->getTab("account")->fieldSetStart($_);
		my $authInstance = WebGUI::Operation::Auth::getInstance($session,$_,$u->userId);
		$tabform->getTab("account")->raw($authInstance->editUserForm);
		$tabform->getTab("account")->fieldSetEnd;
	}
	foreach my $category (@{WebGUI::ProfileCategory->getCategories($session)}) {
		$tabform->getTab("profile")->fieldSetStart($category->getLabel);
		foreach my $field (@{$category->getFields}) {
			next if $field->getId =~ /contentPositions/;
			my $label = $field->getLabel . ($field->isRequired ? "*" : '');
			if ($field->getId eq "alias" && $u->userId eq '1') {
				$tabform->getTab("profile")->raw($field->formField({label=>$label},1,undef,1));
			} else {
				$tabform->getTab("profile")->raw($field->formField({label=>$label},1,$u));
			}
		}
		$tabform->getTab("profile")->fieldSetEnd($category->getLabel);
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
			|| ($session->user->userId eq $u->userId  && $group eq 3) # cannot remove self from admin
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
	my $submenu = _submenu(
                        $session,
                        { workarea => $error.$tabform->print,
                          title    => 168,
                          userId   => $uid, }
                  );
	return $submenu;;
}

#-------------------------------------------------------------------
sub www_editUserSave {
	my $session = shift;
	my $postedUserId = $session->form->process("uid"); #userId posted from www_editUser form
	my $isAdmin = $session->user->isInGroup(3);
	my $isSecondary;
	my $i18n = WebGUI::International->new($session);
	my ($existingUserId) = $session->db->quickArray("select userId from users where username=".$session->db->quote($session->form->process("username")));
	my $error;
	my $actualUserId;  #userId returned from the user object

	unless ($isAdmin) {
		$isSecondary = ($session->user->isInGroup(11) && $postedUserId eq "new");
	}

	return $session->privilege->adminOnly() unless ($isAdmin || $isSecondary);

	# Check to see if 
	# 1) the userId associated with the posted username matches the posted userId (we're editing an account)
	# or that the userId is new and the username selected is unique (creating new account)
	# or that the username passed in isn't assigned a userId (changing a username)
	#
	# Also verify that the posted username is not blank (we need a username)
	#
	
	my $postedUsername = $session->form->process("username");
	$postedUsername = WebGUI::HTML::filter($postedUsername, "all");

	if (($existingUserId eq $postedUserId || ($postedUserId eq "new" && !$existingUserId) || $existingUserId eq '')
             && $postedUsername ne '') 
             {
		# Create a user object with the id passed in.  If the Id is 'new', the new method will return a new user,
		# otherwise return the existing users properties
	   	my $u = WebGUI::User->new($session,$postedUserId);
	   	$actualUserId = $u->userId;
	   	
		# Update the user properties with passed in values.  These methods will save changes to the db.
	   	$u->username($postedUsername);
	   	$u->authMethod($session->form->process("authMethod"));
	   	$u->status($session->form->process("status"));

	   	# Loop through all of this users authentication methods
	   	foreach (@{$session->config->get("authMethods")}) {

	   		# Instantiate each auth object and call it's save method.  These methods are responsible for
	   		# updating authentication information with values supplied by the www_editUser form.
	      		my $authInstance = WebGUI::Operation::Auth::getInstance($session, $_, $actualUserId);
	      		$authInstance->editUserFormSave();
       		}
       		
       		# Loop through all profile fields, and update them with new values.
		foreach my $field (@{WebGUI::ProfileField->getFields($session)}) {
			next if $field->getId =~ /contentPositions/;
			$u->profileField($field->getId,$field->formProcess($u));
		}
		
		# Update group assignements
		my @groups = $session->form->group("groupsToAdd");
		$u->addToGroups(\@groups);
		@groups = $session->form->group("groupsToDelete");
		$u->deleteFromGroups(\@groups);
		
	# Display an error telling them the username they are trying to use is not available and suggest alternatives	
	} else {
       		$error = '<ul>' . sprintf($i18n->get(77), $postedUsername, $postedUsername, $postedUsername, $session->datetime->epochToHuman($session->datetime->time(),"%y")).'</ul>';
	}
	if ($isSecondary) {
		return _submenu($session,{workarea => $i18n->get(978)});

	# Display updated user information
	} else {
		return www_editUser($session,$error,$actualUserId);
	}
}

#-------------------------------------------------------------------
sub www_editUserKarma {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
        my ($output, $f, $a, %user, %data, $method, $values, $category, $label, $default, $previousCategory);
	my $i18n = WebGUI::International->new($session);
        $f = WebGUI::HTMLForm->new($session);
	$f->submit;
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
		-label => $i18n->get(556),
		-hoverHelp => $i18n->get('556 description'),
	);
	$f->text(
		-name => "description",
		-label => $i18n->get(557),
		-hoverHelp => $i18n->get('557 description'),
	);
        $f->submit;
        $output .= $f->print;
	my $submenu = _submenu(
                    $session,
                    { workarea => $output,
					  title    => 558, }
                  );  
        return $submenu;
}

#-------------------------------------------------------------------
sub www_editUserKarmaSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
        my ($u);
        $u = WebGUI::User->new($session,$session->form->process("uid"));
        $u->karma($session->form->process("amount"),$session->user->username." (".$session->user->userId.")",$session->form->process("description"));
        return www_editUser($session);
}

#-------------------------------------------------------------------

=head2 www_formUsers ( session )

Form helper to pick a user from the system.

=head3 session

A reference to the current session.

=cut

sub www_formUsers {
	my $session = shift;
	$session->http->setCacheControl("none");
	return $session->privilege->insufficient() unless $session->user->isInGroup(12);
	$session->style->useEmptyStyle("1");
    my $output = getUserSearchForm($session,"formUsers",{formId=>$session->form->process("formId")},1);
	my ($userCount) = $session->db->quickArray("select count(*) from users");
	return $output unless ($session->form->process("doit") || $userCount<250 || $session->form->process("pn") > 1);
	$output .= '<ul>';
	my $p = doUserSearch($session,"formUsers",1);
	foreach my $data (@{$p->getPageData}) {
		$output .= '<li><a href="#" onclick="window.opener.document.getElementById(\''.$session->form->process("formId").'\').value=\''.$data->{userId}.'\';window.opener.document.getElementById(\''.$session->form->process("formId").'_display\').value=\''.$data->{username}.'\';window.close();">'.$data->{username}.'</a></li>';
	}
        $output .= '</ul>';
        $output .= $p->getBarTraditional;
	return $output;
}


#-------------------------------------------------------------------
sub www_listUsers {
	my $session = shift;
	unless ($session->user->isInGroup(3)) {
		if ($session->user->isInGroup(11)) {
			return www_editUser($session, undef, "new");
		}
		return $session->privilege->adminOnly();
	}
	my %status;
	my $i18n = WebGUI::International->new($session);
	my $output = getUserSearchForm($session,"listUsers");
	my ($userCount) = $session->db->quickArray("select count(*) from users");
	return _submenu($session,{workarea => $output}) unless ($session->form->process("doit") || $userCount<250 || $session->form->process("pn") > 1);
	tie %status, 'Tie::IxHash';
	%status = (
		Active		=> $i18n->get(817),
		Deactivated	=> $i18n->get(818),
		Selfdestructed	=> $i18n->get(819)
	);
        $output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
        $output .= '<tr>
                <td class="tableHeader">'.$i18n->get(816).'</td>
                <td class="tableHeader">'.$i18n->get(50).'</td>
                <td class="tableHeader">'.$i18n->get(56).'</td>
                <td class="tableHeader">'.$i18n->get(453).'</td>
                <td class="tableHeader">'.$i18n->get(454).'</td>
                <td class="tableHeader">'.$i18n->get(429).'</td>
                <td class="tableHeader">'.$i18n->get(434).'</td>
		</tr>';
	my $p = doUserSearch($session,"listUsers",1);
	foreach my $data (@{$p->getPageData}) {
		$output .= '<tr class="tableData">';
		$output .= '<td>'.$status{$data->{status}}.'</td>';
		$output .= '<td><a href="'.$session->url->page('op=editUser;uid='.$data->{userId})
			.'">'.$data->{username}.'</a></td>';
		$output .= '<td class="tableData">'.$data->{email}.'</td>';
		$output .= '<td class="tableData">'.$session->datetime->epochToHuman($data->{dateCreated},"%z").'</td>';
		$output .= '<td class="tableData">'.$session->datetime->epochToHuman($data->{lastUpdated},"%z").'</td>';
		my ($lastLoginStatus, $lastLogin) = $session->db->quickArray("select status,timeStamp from userLoginLog where 
                        userId=".$session->db->quote($data->{userId})." order by timeStamp DESC");
                if ($lastLogin) {
                        $output .= '<td class="tableData">'.$session->datetime->epochToHuman($lastLogin).'</td>';
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
        $p->setAlphabeticalKey('username');
        $output .= $p->getBarTraditional;
	my $submenu = _submenu(
                    $session,
                    { workarea => $output, }
                  );
	return $submenu;
}

1;

