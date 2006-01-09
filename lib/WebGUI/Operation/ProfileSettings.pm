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
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
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
        $title = WebGUI::International::get($title,$namespace) if ($title);
        my $ac = WebGUI::AdminConsole->new($session,"userProfiling");
        if ($help) {
                $ac->setHelp($help,"WebGUIProfile");
        }
	$ac->addSubmenuItem($session->url->page("op=editProfileCategory;cid=new"), WebGUI::International::get(490,"WebGUIProfile"));
	$ac->addSubmenuItem($session->url->page("op=editProfileField;fid=new"), WebGUI::International::get(491,"WebGUIProfile"));
        if ((($session->form->process("op") eq "editProfileField" && $session->form->process("fid") ne "new") || $session->form->process("op") eq "deleteProfileField") && $session->form->process("cid") eq "") {
		$ac->addSubmenuItem($session->url->page('op=editProfileField;fid='.$session->form->process("fid")), WebGUI::International::get(787,"WebGUIProfile"));
		$ac->addSubmenuItem($session->url->page('op=deleteProfileField;fid='.$session->form->process("fid")), WebGUI::International::get(788,"WebGUIProfile"));
	}
        if ((($session->form->process("op") eq "editProfileCategory" && $session->form->process("cid") ne "new") || $session->form->process("op") eq "deleteProfileCategory") && $session->form->process("fid") eq "") {
		$ac->addSubmenuItem($session->url->page('op=editProfileCategory;cid='.$session->form->process("cid")), WebGUI::International::get(789,"WebGUIProfile"));
		$ac->addSubmenuItem($session->url->page('op=deleteProfileCategory;cid='.$session->form->process("cid")), WebGUI::International::get(790,"WebGUIProfile"));
        }
	$ac->addSubmenuItem($session->url->page("op=editProfileSettings"), WebGUI::International::get(492,"WebGUIProfile"));
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_deleteProfileCategoryConfirm {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $category = WebGUI::ProfileCategory->new($session->form->process("cid"));
        return WebGUI::AdminConsole->new($session,"userProfiling")->render($session->privilege->vitalComponent()) if ($category->isProtected);
	$category->delete;	
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $field = WebGUI::ProfileField->new($session->form->process("fid"));
        return WebGUI::AdminConsole->new($session,"userProfiling")->render($session->privilege->vitalComponent()) if ($field->isProtected);
	$field->delete;
        return www_editProfileSettings(); 
}

#-------------------------------------------------------------------
sub www_editProfileCategory {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $data = {};
	my $f = WebGUI::HTMLForm->new;
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
			-label => WebGUI::International::get(469,"WebGUIProfile"),
		);
		$data = WebGUI::ProfileCategory->new($session->form->process("cid"))->get;
	} else {
                $f->hidden(
			-name => "cid",
			-value => "new"
		);
	}
	$f->text(
		-name => "label",
		-label => WebGUI::International::get(470,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('470 description',"WebGUIProfile"),
		-value => $data->{label},
	);
	$f->yesNo(
                -name=>"visible",
                -label=>WebGUI::International::get(473,"WebGUIProfile"),
                -hoverHelp=>WebGUI::International::get('473 description',"WebGUIProfile"),
                -value=>$data->{visible}
                );
	$f->yesNo(
		-name=>"editable",
		-value=>$data->{editable},
		-label=>WebGUI::International::get(897,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('897 description',"WebGUIProfile"),
		);
	$f->submit;
	return _submenu($f->print,'468','user profile category add/edit','WebGUIProfile');
}

#-------------------------------------------------------------------
sub www_editProfileCategorySave {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my %data = (
		label=>$session->form->text("label"),
		visible=>$session->form->yesNo("visible"),
		editable=>$session->form->yesNo("editable"),
		);
	if ($session->form->process("cid") eq "new") {
		my $category = WebGUI::ProfileCategory->create(\%data);
		$session->form->process("cid") = $category->getId;
	} else {
		WebGUI::ProfileCategory->new($session->form->process("cid"))->set(\%data);
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileField {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my $f = WebGUI::HTMLForm->new;
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
			-label => WebGUI::International::get(475,"WebGUIProfile"),
			-hoverHelp => WebGUI::International::get('475 description',"WebGUIProfile"),
		);
		$data = WebGUI::ProfileField->new($session->form->process("fid"))->get;
	} else {
               	$f->hidden(
			-name => "new",
			-value => 1,
               	);
               	$f->text(
			-name => "fid",
			-label => WebGUI::International::get(475,"WebGUIProfile"),
			-hoverHelp => WebGUI::International::get('475 description',"WebGUIProfile"),
               	);
	}
	$f->text(
		-name => "label",
		-label => WebGUI::International::get(472,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('472 description',"WebGUIProfile"),
		-value => $data->{label},
	);
	$f->yesNo(
		-name=>"visible",
		-label=>WebGUI::International::get(473,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('473 description',"WebGUIProfile"),
		-value=>$data->{visible}
		);
	$f->yesNo(
                -name=>"editable",
                -value=>$data->{editable},
                -label=>WebGUI::International::get(897,"WebGUIProfile"),
                -hoverHelp=>WebGUI::International::get('897 description',"WebGUIProfile"),
                );
	$f->yesNo(
		-name=>"required",
		-label=>WebGUI::International::get(474,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('474 description',"WebGUIProfile"),
		-value=>$data->{required}
		);
	my $fieldType = WebGUI::Form::FieldType->new(
		-name=>"fieldType",
		-label=>WebGUI::International::get(486,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('486 description',"WebGUIProfile"),
		-value=>ucfirst $data->{fieldType},
		-defaultValue=>"Text",
	);
	my @profileForms = ();
	foreach my $form ( sort @{ $fieldType->{types} }) {
		next if $form eq 'DynamicField';
		my $cmd = join '::', 'WebGUI::Form', $form;
		eval "use $cmd";
		my $w = eval "$cmd->new();";
		push @profileForms, $form if $w->{profileEnabled};
	}

	$fieldType->{types} = \@profileForms;
	$f->raw($fieldType->toHtmlWithWrapper());
	$f->textarea(
		-name => "possibleValues",
		-label => WebGUI::International::get(487,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('487 description',"WebGUIProfile"),
		-value => $data->{possibleValues},
	);
	$f->textarea(
		-name => "dataDefault",
		-label => WebGUI::International::get(488,"WebGUIProfile"),
		-hoverHelp => WebGUI::International::get('488 description',"WebGUIProfile"),
		-value => $data->{dataDefault},
	);
	my %hash;
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		$hash{$category->getId} = $category->getLabel;
	}
	$f->selectBox(
		-name=>"profileCategoryId",
		-options=>\%hash,
		-label=>WebGUI::International::get(489,"WebGUIProfile"),
		-hoverHelp=>WebGUI::International::get('489 description',"WebGUIProfile"),
		-value=>$data->{profileCategoryId}
		);
        $f->submit;
	return _submenu($f->print,'471','profile settings edit',"WebGUIProfile");
}

#-------------------------------------------------------------------
sub www_editProfileFieldSave {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
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
		my $field = WebGUI::ProfileField->create($session->form->text("fid"), \%data, $categoryId);
		$session->form->process("fid") = $field->getId;
	} else {
		my $field = WebGUI::ProfileField->new($session->form->process("fid"));
		$field->set(\%data);
		$field->setCategory($categoryId);
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $output = "";
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		$output .= deleteIcon('op=deleteProfileCategoryConfirm;cid='.$category->getId,'',WebGUI::International::get(466,"WebGUIProfile")); 
		$output .= editIcon('op=editProfileCategory;cid='.$category->getId); 
		$output .= moveUpIcon('op=moveProfileCategoryUp;cid='.$category->getId); 
		$output .= moveDownIcon('op=moveProfileCategoryDown;cid='.$category->getId); 
		$output .= ' <b>'.$category->getLabel.'</b><br />';
		foreach my $field (@{$category->getFields}) {
			next if $field->getId =~ /contentPositions/;
			$output .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                        $output .= deleteIcon('op=deleteProfileFieldConfirm;fid='.$field->getId,'',WebGUI::International::get(467,"WebGUIProfile"));
       	                $output .= editIcon('op=editProfileField;fid='.$field->getId);
               	        $output .= moveUpIcon('op=moveProfileFieldUp;fid='.$field->getId);
                       	$output .= moveDownIcon('op=moveProfileFieldDown;fid='.$field->getId);
                       	$output .= ' '.$field->getLabel.'<br />';
		}
	}
	return _submenu($output,undef,"profile settings edit",'WebGUIProfile');
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryDown {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileCategory->new($session->form->process("cid"))->moveDown;
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileCategory->new($session->form->process("cid"))->moveUp;
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileField->new($session->form->process("fid"))->moveDown;
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldUp {
	my $session = shift;
        return $session->privilege->adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileField->new($session->form->process("fid"))->moveUp;
        return www_editProfileSettings();
}


1;
