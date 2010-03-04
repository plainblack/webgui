package WebGUI::Operation::ProfileSettings;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Form::FieldType;
use WebGUI::Pluggable;
use WebGUI::ProfileField;
use WebGUI::ProfileCategory;

=head1 NAME

Package WebGUI::Operation::ProfileSettings

=head1 DESCRIPTION

Operation handler for configuring the user profile system in WebGUI.
You are allowed to create categories of profile settings and manage
them (delete, reorder, edit) as well as adding new fields to the
profile and managing them.

Only users in group Admin (3) are allowed to call subroutines in this package.

=head2 _submenu ( $session, $workarea, $title )

Utility routine for creating the AdminConsole for ProfileSetting functions.

=head3 $session

The current WebGUI session object.

=head3 $workarea

The content to display to the user.

=head3 $title

The title of the Admin Console.  This should be an entry in the i18n
table in the WebGUI namespace.

=cut

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
        my $workarea = shift;
        my $title = shift;
	my $namespace = shift;
	my $i18n = WebGUI::International->new($session,"WebGUIProfile");
        $title = $i18n->get($title,$namespace) if ($title);
        my $ac = WebGUI::AdminConsole->new($session,"userProfiling");
	$ac->addSubmenuItem($session->url->page("op=editProfileCategory;cid=new"), $i18n->get(490));
	$ac->addSubmenuItem($session->url->page("op=editProfileField;fid=new"), $i18n->get(491));
        if ((($session->form->process("op") eq "editProfileField" && $session->form->process("fid") ne "new") || $session->form->process("op") eq "deleteProfileFieldConfirm") && $session->form->process("cid") eq "") {
		$ac->addSubmenuItem($session->url->page('op=editProfileField;fid='.$session->form->process("fid")), $i18n->get(787));
		$ac->addConfirmedSubmenuItem($session->url->page('op=deleteProfileFieldConfirm;fid='.$session->form->process("fid")), $i18n->get(788), $i18n->get(467));
	}
        if ((($session->form->process("op") eq "editProfileCategory" && $session->form->process("cid") ne "new") || $session->form->process("op") eq "deleteProfileCategory") && $session->form->process("fid") eq "") {
		$ac->addSubmenuItem($session->url->page('op=editProfileCategory;cid='.$session->form->process("cid")), $i18n->get(789));
		$ac->addConfirmedSubmenuItem($session->url->page('op=deleteProfileCategory;cid='.$session->form->process("cid")), $i18n->get(790), $i18n->get(466));
        }
	$ac->addSubmenuItem($session->url->page("op=editProfileSettings"), $i18n->get(492));
        return $ac->render($workarea, $title);
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminProfileSettings") );
}

#-------------------------------------------------------------------

=head2 www_deleteProfileCategoryConfirm ( $session )

Deletes the profile category in form variable C<cid>, unless the category is
protected, or it contains protected fields, in which case it returns $session->privilege->vitalComponent.
Otherwise, it returns the user to www_editProfileSettings.

=cut

sub www_deleteProfileCategoryConfirm {
    my $session = shift;
    return $session->privilege->adminOnly() unless canView($session);
    my $category = WebGUI::ProfileCategory->new($session,$session->form->process("cid"));
    return WebGUI::AdminConsole->new($session,"userProfiling")->render($session->privilege->vitalComponent()) if ($category->isProtected or $category->hasProtected);
    $category->delete;	
    return www_editProfileSettings($session);
}

=head2 www_deleteProfileFieldConfirm ( $session )

Deletes the profile field in form variable C<fid>, unless the field is
protected, in which case it returns $session->privilege->vitalComponent.
Otherwise, it returns the user to www_editProfileSettings.

=cut

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
    my $session = shift;
    return $session->privilege->adminOnly() unless canView($session);
    my $field = WebGUI::ProfileField->new($session,$session->form->process("fid"));
    return WebGUI::AdminConsole->new($session,"userProfiling")->render($session->privilege->vitalComponent()) if ($field->isProtected);
    $field->delete;
    return www_editProfileSettings($session); 
}

=head2 www_editProfileCategory ( $session )

Add or edit a profile category specified in form variable C<cid>.  Calls www_editProfileCategorySave when done.

=cut


#-------------------------------------------------------------------
sub www_editProfileCategory {
	my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
	my $data = {};
	my $i18n = WebGUI::International->new($session,"WebGUIProfile");
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		-name => "op",
		-value => "editProfileCategorySave",
	);
	if ($session->form->process("cid")) {
		$f->hidden(
			-name => "cid",
			-value => $session->form->process("cid"),
		);
		$f->readOnly(
			-name => $session->form->process("cid"),
			-value => $session->form->process("cid"),
			-label => $i18n->get(469),
		);
		$data = WebGUI::ProfileCategory->new($session,$session->form->process("cid"))->get;
	} else {
                $f->hidden(
			-name => "cid",
			-value => "new"
		);
	}
	$f->text(
		-name => "label",
		-label => $i18n->get(470),
		-hoverHelp => $i18n->get('470 description'),
		-value => $data->{label},
	);
    $f->text(
		-name      => "shortLabel",
		-label     => $i18n->get('category short name'),
		-hoverHelp => $i18n->get('category short name description'),
		-value     => $data->{shortLabel},
	);
	$f->yesNo(
                -name=>"visible",
                -label=>$i18n->get(473),
                -hoverHelp=>$i18n->get('473 description'),
                -value=>$data->{visible}
                );
	$f->yesNo(
		-name=>"editable",
		-value=>$data->{editable},
		-label=>$i18n->get(897),
		-hoverHelp=>$i18n->get('897 description'),
		);
	$f->submit;
	return _submenu($session,$f->print,'468','WebGUIProfile');
}

=head2 www_editProfileCategorySave ( $session )

Saves the data submitted by www_editProfileCategorySave and/or creates a new category.
Returns the user to www_editProfileSettings when done.

=cut


#-------------------------------------------------------------------
sub www_editProfileCategorySave {
    my $session = shift;
    return $session->privilege->adminOnly() unless canView($session) && $session->form->validToken();
	my %data = (
		label      => $session->form->text("label"),
        shortLabel => $session->form->text("shortLabel"),
		visible    => $session->form->yesNo("visible"),
		editable   => $session->form->yesNo("editable"),
	);
	if ($session->form->process("cid") eq "new") {
		my $category = WebGUI::ProfileCategory->create($session,\%data);
	} else {
		WebGUI::ProfileCategory->new($session,$session->form->process("cid"))->set(\%data);
	}
	return www_editProfileSettings($session);
}

=head2 www_editProfileField ( $session )

Add or edit a profile field specified in form variable C<fid>.  Calls www_editProfileFieldSave when done.

=cut

#-------------------------------------------------------------------
sub www_editProfileField {
    my $session = shift;
    return $session->privilege->adminOnly() unless canView($session);
    my $i18n = WebGUI::International->new($session,"WebGUIProfile");
    my $f = WebGUI::HTMLForm->new($session);
    $f->submit;
    $f->hidden(
        -name => "op",
        -value => "editProfileFieldSave",
    );
    my $data = {};
    if ($session->form->process("fid") ne 'new') {
        $f->hidden(
            -name => "fid",
            -value => $session->form->process("fid"),
        );
        $f->readOnly(
            -value => $session->form->process("fid"),
            -label => $i18n->get(475),
            -hoverHelp => $i18n->get('475 description'),
        );
        $data = WebGUI::ProfileField->new($session,$session->form->process("fid"))->get;
    } else {
        $f->hidden(
            -name => "new",
            -value => 1,
        );
        $f->text(
            -name => "fid",
            -label => $i18n->get(475),
            -hoverHelp => $i18n->get('475 description'),
        );
    }
    $f->text(
        -name => "label",
        -label => $i18n->get(472),
        -hoverHelp => $i18n->get('472 description'),
        -value => $data->{label},
    );
    $f->yesNo(
        -name=>"visible",
        -label=>$i18n->get('473a'),
        -hoverHelp=>$i18n->get('473a description'),
        -value=>$data->{visible}
    );
    $f->yesNo(
        -name=>"editable",
        -value=>$data->{editable},
        -label=>$i18n->get('897a'),
        -hoverHelp=>$i18n->get('897a description'),
    );
    $f->yesNo(
        -name=>"required",
        -label=>$i18n->get(474),
        -hoverHelp=>$i18n->get('474 description'),
        -value=>$data->{required}
    );
    $f->yesNo(
        -name => 'showAtRegistration',
        -label => $i18n->get('showAtRegistration label'),
        -hoverHelp => $i18n->get('showAtRegistration hoverHelp'),
        -value => $data->{showAtRegistration}
    );
    $f->yesNo(
        -name => 'requiredForPasswordRecovery',
        -label => $i18n->get('requiredForPasswordRecovery label'),
        -hoverHelp => $i18n->get('requiredForPasswordRecovery hoverHelp'),
        -value => $data->{requiredForPasswordRecovery}
    );
    if ($data->{fieldType} eq "Image") {
        $f->yesNo(
            -name=>"forceImageOnly",
            -label=>$i18n->get('forceImageOnly label'),
            -hoverHelp=>$i18n->get('forceImageOnly hoverHelp'),
            -value=>$data->{forceImageOnly},
            -defaultValue=>1,
        );
    }
    $f->radioList(
        -name       => 'defaultPrivacySetting',
        -label      => $i18n->get('default privacy setting label'),
        -hoverHelp  => $i18n->get('default privacy setting description'),
        -options    => WebGUI::ProfileField->getPrivacyOptions($session),
        -value      => $data->{defaultPrivacySetting},
        -defaultValue => 'none',
    );	
    my $fieldType = WebGUI::Form::FieldType->new($session,
        -name=>"fieldType",
        -label=>$i18n->get(486),
        -hoverHelp=>$i18n->get('486 description'),
        -value=>ucfirst $data->{fieldType},
        -defaultValue=>"Text",
    );
    $f->raw($fieldType->toHtmlWithWrapper());
    $f->textarea(
        -name => "possibleValues",
        -label => $i18n->get(487),
        -hoverHelp => $i18n->get('487 description'),
        -value => $data->{possibleValues},
    );
    $f->textarea(
        -name => "dataDefault",
        -label => $i18n->get(488),
        -hoverHelp => $i18n->get('488 description'),
        -value => $data->{dataDefault},
    );
    $f->textarea(
        -name => "extras",
        -label => $i18n->get('profile field extras label'),
        -hoverHelp => $i18n->get('profile field extras hoverHelp'),
        -value => $data->{extras},
    );
    my %hash;
    foreach my $category (@{WebGUI::ProfileCategory->getCategories($session)}) {
        $hash{$category->getId} = $category->getLabel;
    }
    $f->selectBox(
        -name=>"profileCategoryId",
        -options=>\%hash,
        -label=>$i18n->get(489),
        -hoverHelp=>$i18n->get('489 description'),
        -value=>$data->{profileCategoryId}
    );
    $f->submit;
    return _submenu($session,$f->print,'471',"WebGUIProfile");
}

=head2 www_editProfileFieldSave ( $session )

Saves the data submitted by www_editProfileFieldSave and/or creates a new field.
Returns the user to www_editProfileSettings when done.

=cut

#-------------------------------------------------------------------
sub www_editProfileFieldSave {
    my $session = shift;
    return $session->privilege->adminOnly() unless canView($session) && $session->form->validToken();

	# Special case for WebGUI auth password recovery.
	my $requiredForPasswordRecovery = $session->form->yesNo('requiredForPasswordRecovery');
	if ($session->setting->get('authMethod') eq 'WebGUI'
	    and $session->setting->get('webguiPasswordRecovery')
	    and not $requiredForPasswordRecovery
	    and ($session->db->quickArray("SELECT COUNT(*) FROM userProfileField WHERE requiredForPasswordRecovery = 1"))[0] == 1) {
		# We'd be turning off the only one.  Don't do it.
		$requiredForPasswordRecovery = 1;
	}

	my %data = (
		label=>$session->form->text("label"),
		editable=>$session->form->yesNo("editable"),
		visible=>$session->form->yesNo("visible"),
		required=>$session->form->yesNo("required"),
		showAtRegistration=>$session->form->yesNo("showAtRegistration"),
		requiredForPasswordRecovery=>$requiredForPasswordRecovery,
		possibleValues=>$session->form->textarea("possibleValues"),
		dataDefault=>$session->form->textarea("dataDefault"),
		fieldType=>$session->form->fieldType("fieldType"),
		forceImageOnly=>$session->form->yesNo("forceImageOnly"),
        extras=>$session->form->text('extras'),
        defaultPrivacySetting=>$session->form->radioList('defaultPrivacySetting'),
		);
	my $categoryId = $session->form->selectBox("profileCategoryId");
	if ($session->form->process("new")) {
		my $field = WebGUI::ProfileField->create($session,$session->form->text("fid"), \%data, $categoryId);
	} else {
		my $field = WebGUI::ProfileField->new($session,	$session->form->process("fid"));
        $data{protected} = $field->get('protected');  ##Protected is sticky and not in the UI.
		$field->set(\%data);
		$field->setCategory($categoryId);
	}
	return www_editProfileSettings($session);
}

=head2 www_editProfileSettings ( $session )

Allows profile categories and fields to be managed (added, edited, deleted or moved).

=cut

#-------------------------------------------------------------------
sub www_editProfileSettings {
	my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
	my $i18n = WebGUI::International->new($session,"WebGUIProfile");
	my $output = "";
	foreach my $category (@{WebGUI::ProfileCategory->getCategories($session)}) {
		$output .= $session->icon->delete('op=deleteProfileCategoryConfirm;cid='.$category->getId,'',$i18n->get(466)); 
		$output .= $session->icon->edit('op=editProfileCategory;cid='.$category->getId); 
		$output .= $session->icon->moveUp('op=moveProfileCategoryUp;cid='.$category->getId); 
		$output .= $session->icon->moveDown('op=moveProfileCategoryDown;cid='.$category->getId); 
		$output .= ' <b>'.$category->getLabel.'</b><br />';
		foreach my $field (@{$category->getFields}) {
			next if $field->getId =~ /contentPositions/;
			$output .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                        $output .= $session->icon->delete('op=deleteProfileFieldConfirm;fid='.$field->getId,'',$i18n->get(467))
                                        unless $field->isProtected;
       	                $output .= $session->icon->edit('op=editProfileField;fid='.$field->getId);
               	        $output .= $session->icon->moveUp('op=moveProfileFieldUp;fid='.$field->getId);
                       	$output .= $session->icon->moveDown('op=moveProfileFieldDown;fid='.$field->getId);
                       	$output .= ' '.$field->getLabel.'<br />';
		}
	}
	return _submenu($session,$output,undef,'WebGUIProfile');
}

=head2 www_moveProfileCategoryDown ( $session )

Moves the profile category specified by form variable C<cid> down one notch.
Returns the user to www_editProfileSettings.

=cut


#-------------------------------------------------------------------
sub www_moveProfileCategoryDown {
	my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
	WebGUI::ProfileCategory->new($session,$session->form->process("cid"))->moveDown;
        return www_editProfileSettings($session);
}

=head2 www_moveProfileCategoryUp ( $session )

Moves the profile category specified by form variable C<cid> up one notch.
Returns the user to www_editProfileSettings.

=cut

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
	my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
	WebGUI::ProfileCategory->new($session,$session->form->process("cid"))->moveUp;
        return www_editProfileSettings($session);
}

=head2 www_moveProfileFieldDown ( $session )

Moves the profile field specified by form variable C<cid> down one notch.
This will not move the field into another category.
Returns the user to www_editProfileSettings.

=cut

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
	my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
	WebGUI::ProfileField->new($session,$session->form->process("fid"))->moveDown;
        return www_editProfileSettings($session);
}

=head2 www_moveProfileFieldUp ( $session )

Moves the profile field specified by form variable C<cid> up one notch.
This will not move the field into another category.
Returns the user to www_editProfileSettings.

=cut

#-------------------------------------------------------------------
sub www_moveProfileFieldUp {
	my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
	WebGUI::ProfileField->new($session,$session->form->process("fid"))->moveUp;
        return www_editProfileSettings($session);
}


1;
