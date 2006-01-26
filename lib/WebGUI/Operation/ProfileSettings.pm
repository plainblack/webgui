package WebGUI::Operation::ProfileSettings;

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
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Form::FieldType;
use WebGUI::ProfileField;
use WebGUI::ProfileCategory;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
        my $workarea = shift;
        my $title = shift;
        my $help = shift;
	my $namespace = shift;
	my $i18n = WebGUI::International->new($session,"WebGUIProfile");
        $title = $i18n->get($title,$namespace) if ($title);
        my $ac = WebGUI::AdminConsole->new($session,"userProfiling");
        if ($help) {
                $ac->setHelp($help,"WebGUIProfile");
        }
	$ac->addSubmenuItem($session->url->page("op=editProfileCategory;cid=new"), $i18n->get(490));
	$ac->addSubmenuItem($session->url->page("op=editProfileField;fid=new"), $i18n->get(491));
        if ((($session->form->process("op") eq "editProfileField" && $session->form->process("fid") ne "new") || $session->form->process("op") eq "deleteProfileField") && $session->form->process("cid") eq "") {
		$ac->addSubmenuItem($session->url->page('op=editProfileField;fid='.$session->form->process("fid")), $i18n->get(787));
		$ac->addSubmenuItem($session->url->page('op=deleteProfileField;fid='.$session->form->process("fid")), $i18n->get(788));
	}
        if ((($session->form->process("op") eq "editProfileCategory" && $session->form->process("cid") ne "new") || $session->form->process("op") eq "deleteProfileCategory") && $session->form->process("fid") eq "") {
		$ac->addSubmenuItem($session->url->page('op=editProfileCategory;cid='.$session->form->process("cid")), $i18n->get(789));
		$ac->addSubmenuItem($session->url->page('op=deleteProfileCategory;cid='.$session->form->process("cid")), $i18n->get(790));
        }
	$ac->addSubmenuItem($session->url->page("op=editProfileSettings"), $i18n->get(492));
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_deleteProfileCategoryConfirm {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $category = WebGUI::ProfileCategory->new($session,$session->form->process("cid"));
        return WebGUI::AdminConsole->new($session,"userProfiling")->render($session->privilege->vitalComponent()) if ($category->isProtected);
	$category->delete;	
        return www_editProfileSettings($session);
}

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $field = WebGUI::ProfileField->new($session,$session->form->process("fid"));
        return WebGUI::AdminConsole->new($session,"userProfiling")->render($session->privilege->vitalComponent()) if ($field->isProtected);
	$field->delete;
        return www_editProfileSettings($session); 
}

#-------------------------------------------------------------------
sub www_editProfileCategory {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $data = {};
	my $i18n = WebGUI::International->new($session,"WebGUIProfile");
	my $f = WebGUI::HTMLForm->new($session);
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
	return _submenu($session,$f->print,'468','user profile category add/edit','WebGUIProfile');
}

#-------------------------------------------------------------------
sub www_editProfileCategorySave {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my %data = (
		label=>$session->form->text("label"),
		visible=>$session->form->yesNo("visible"),
		editable=>$session->form->yesNo("editable"),
		);
	if ($session->form->process("cid") eq "new") {
		my $category = WebGUI::ProfileCategory->create($session,\%data);
	} else {
		WebGUI::ProfileCategory->new($session,$session->form->process("cid"))->set(\%data);
	}
	return www_editProfileSettings($session);
}

#-------------------------------------------------------------------
sub www_editProfileField {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $i18n = WebGUI::International->new($session,"WebGUIProfile");
        my $f = WebGUI::HTMLForm->new($session);
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
	$f->yesNo(
		-name=>"required",
		-label=>$i18n->get(474),
		-hoverHelp=>$i18n->get('474 description'),
		-value=>$data->{required}
		);
	my $fieldType = WebGUI::Form::FieldType->new($session,
		-name=>"fieldType",
		-label=>$i18n->get(486),
		-hoverHelp=>$i18n->get('486 description'),
		-value=>ucfirst $data->{fieldType},
		-defaultValue=>"Text",
	);
	my @profileForms = ();
	foreach my $form ( sort @{ $fieldType->get("types") }) {
		next if $form eq 'DynamicField';
		my $cmd = join '::', 'WebGUI::Form', $form;
		eval "use $cmd";
		my $w = eval {"$cmd"->new($session)};
		push @profileForms, $form if $w->get("profileEnabled");
	}

	$fieldType->set("types", \@profileForms);
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
	return _submenu($session,$f->print,'471','profile settings edit',"WebGUIProfile");
}

#-------------------------------------------------------------------
sub www_editProfileFieldSave {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my %data = (
		label=>$session->form->text("label"),
		editable=>$session->form->yesNo("editable"),
		visible=>$session->form->yesNo("visible"),
		required=>$session->form->yesNo("required"),
		possibleValues=>$session->form->textarea("possibleValues"),
		dataDefault=>$session->form->textarea("dataDefault"),
		fieldType=>$session->form->fieldType("fieldType"),
		);
	my $categoryId = $session->form->selectBox("profileCategoryId");
	if ($session->form->process("new")) {
		my $field = WebGUI::ProfileField->create($session,$session->form->text("fid"), \%data, $categoryId);
		$session->stow->set("editSavedFid",$field->getId);
	} else {
		my $field = WebGUI::ProfileField->new($session,$session->stow->get("editSavedFid"));
		$field->set(\%data);
		$field->setCategory($categoryId);
	}
	return www_editProfileSettings($session);
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
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
                        $output .= $session->icon->delete('op=deleteProfileFieldConfirm;fid='.$field->getId,'',$i18n->get(467));
       	                $output .= $session->icon->edit('op=editProfileField;fid='.$field->getId);
               	        $output .= $session->icon->moveUp('op=moveProfileFieldUp;fid='.$field->getId);
                       	$output .= $session->icon->moveDown('op=moveProfileFieldDown;fid='.$field->getId);
                       	$output .= ' '.$field->getLabel.'<br />';
		}
	}
	return _submenu($session,$output,undef,"profile settings edit",'WebGUIProfile');
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryDown {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	WebGUI::ProfileCategory->new($session,$session->form->process("cid"))->moveDown;
        return www_editProfileSettings($session);
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	WebGUI::ProfileCategory->new($session,$session->form->process("cid"))->moveUp;
        return www_editProfileSettings($session);
}

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	WebGUI::ProfileField->new($session,$session->form->process("fid"))->moveDown;
        return www_editProfileSettings($session);
}

#-------------------------------------------------------------------
sub www_moveProfileFieldUp {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	WebGUI::ProfileField->new($session,$session->form->process("fid"))->moveUp;
        return www_editProfileSettings($session);
}


1;
