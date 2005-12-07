package WebGUI::Operation::ProfileSettings;

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
        my $workarea = shift;
        my $title = shift;
        my $help = shift;
	my $namespace = shift;
        $title = WebGUI::International::get($title,$namespace) if ($title);
        my $ac = WebGUI::AdminConsole->new("userProfiling");
        if ($help) {
                $ac->setHelp($help,"WebGUIProfile");
        }
	$ac->addSubmenuItem(WebGUI::URL::page("op=editProfileCategory;cid=new"), WebGUI::International::get(490,"WebGUIProfile"));
	$ac->addSubmenuItem(WebGUI::URL::page("op=editProfileField;fid=new"), WebGUI::International::get(491,"WebGUIProfile"));
        if ((($session{form}{op} eq "editProfileField" && $session{form}{fid} ne "new") || $session{form}{op} eq "deleteProfileField") && $session{form}{cid} eq "") {
		$ac->addSubmenuItem(WebGUI::URL::page('op=editProfileField;fid='.$session{form}{fid}), WebGUI::International::get(787,"WebGUIProfile"));
		$ac->addSubmenuItem(WebGUI::URL::page('op=deleteProfileField;fid='.$session{form}{fid}), WebGUI::International::get(788,"WebGUIProfile"));
	}
        if ((($session{form}{op} eq "editProfileCategory" && $session{form}{cid} ne "new") || $session{form}{op} eq "deleteProfileCategory") && $session{form}{fid} eq "") {
		$ac->addSubmenuItem(WebGUI::URL::page('op=editProfileCategory;cid='.$session{form}{cid}), WebGUI::International::get(789,"WebGUIProfile"));
		$ac->addSubmenuItem(WebGUI::URL::page('op=deleteProfileCategory;cid='.$session{form}{cid}), WebGUI::International::get(790,"WebGUIProfile"));
        }
	$ac->addSubmenuItem(WebGUI::URL::page("op=editProfileSettings"), WebGUI::International::get(492,"WebGUIProfile"));
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_deleteProfileCategoryConfirm {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $category = WebGUI::ProfileCategory->new($session{form}{cid});
        return WebGUI::AdminConsole->new("userProfiling")->render(WebGUI::Privilege::vitalComponent()) if ($category->isProtected);
	$category->delete;	
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_deleteProfileFieldConfirm {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $field = WebGUI::ProfileField->new($session{form}{fid});
        return WebGUI::AdminConsole->new("userProfiling")->render(WebGUI::Privilege::vitalComponent()) if ($field->isProtected);
	$field->delete;
        return www_editProfileSettings(); 
}

#-------------------------------------------------------------------
sub www_editProfileCategory {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $data = {};
	my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => "op",
		-value => "editProfileCategorySave",
	);
	if ($session{form}{cid}) {
		$f->hidden(
			-name => "cid",
			-value => $session{form}{cid},
		);
		$f->readOnly(
			-name => $session{form}{cid},
			-label => WebGUI::International::get(469,"WebGUIProfile"),
		);
		$data = WebGUI::ProfileCategory->new($session{form}{cid})->get;
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
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my %data = {
		label=>WebGUI::FormProcessor::text("label"),
		visible=>WebGUI::FormProcessor::yesNo("visible"),
		editable=>WebGUI::FormProcessor::yesNo("editable"),
		};
	if ($session{form}{cid} eq "new") {
		my $category = WebGUI::ProfileCategory->create(\%data);
		$session{form}{cid} = $category->getId;
	} else {
		WebGUI::ProfileCategory->new($session{form}{cid})->set(\%data);
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileField {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my $f = WebGUI::HTMLForm->new;
        $f->hidden(
		-name => "op",
		-value => "editProfileFieldSave",
        );
	my $data = {};
	if ($session{form}{fid} ne 'new') {
              	$f->hidden(
			-name => "fid",
			-value => $session{form}{fid},
              	);
		$f->readOnly(
			-value => $session{form}{fid},
			-label => WebGUI::International::get(475,"WebGUIProfile"),
			-hoverHelp => WebGUI::International::get('475 description',"WebGUIProfile"),
		);
		$data = WebGUI::ProfileField->new($session{form}{fid})->get;
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
		-name=>"dataType",
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
		-name => "dataValues",
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
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my %data = (
		label=>WebGUI::FormProcessor::text("label"),
		editable=>WebGUI::FormProcessor::yesNo("editable"),
		visible=>WebGUI::FormProcessor::yesNo("visible"),
		required=>WebGUI::FormProcessor::yesNo("required"),
		possibleValues=>WebGUI::FormProcessor::textarea("possibleValues"),
		dataDefault=>WebGUI::FormProcessor::textarea("dataDefault"),
		fieldType=>WebGUI::FormProcessor::fieldType("fieldType"),
		);
	if ($session{form}{new}) {
		my $field = WebGUI::ProfileField->create(WebGUI::FormProcessor::text("fieldName"), \%data, WebGUI::FormProcessor::selectBox("profileCategoryId"));
		$session{form}{fid} = $field->getId;
	} else {
		WebGUI::ProfileField->new($session{form}{fid})->set(\%data);
	}
	return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_editProfileSettings {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $output = "";
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		$output .= deleteIcon('op=deleteProfileCategoryConfirm;cid='.$category->getId,'',WebGUI::International::get(466,"WebGUIProfile")); 
		$output .= editIcon('op=editProfileCategory;cid='.$category->getId); 
		$output .= moveUpIcon('op=moveProfileCategoryUp;cid='.$category->getId); 
		$output .= moveDownIcon('op=moveProfileCategoryDown;cid='.$category->getId); 
		$output .= ' <b>'.$category->getLabel.'</b><br />';
		foreach my $field ($category->getFields) {
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
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileCategory->new($session{form}{cid})->moveDown;
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileCategoryUp {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileCategory->new($session{form}{cid})->moveUp;
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldDown {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileField->new($session{form}{fid})->moveDown;
        return www_editProfileSettings();
}

#-------------------------------------------------------------------
sub www_moveProfileFieldUp {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::ProfileField->new($session{form}{fid})->moveUp;
        return www_editProfileSettings();
}


1;
