package WebGUI::Operation::MetaData;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::MetaData;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title,"MetaData") if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new;
        if ($help) {
                $ac->setHelp($help,"MetaData");
        }
        $ac->setAdminFunction("contentProfiling");
	if($session{form}{op} ne "manageMetaData") {
		$ac->addSubmenuItem(WebGUI::URL::page('op=manageMetaData'), WebGUI::International::get('content profiling','MetaData'));
	}
        $ac->addSubmenuItem(WebGUI::URL::page('op=editMetaDataField'), WebGUI::International::get('Add new field','MetaData'));
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_editMetaDataField {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{fid} < 1000 && $session{form}{fid} > 0);

        my ($output, $fieldName, $defaultValue, $description, $fieldInfo);
	
	if($session{form}{fid} && $session{form}{fid} ne "new") {
		$fieldInfo = WebGUI::MetaData::getField($session{form}{fid});
	}

	my $fid = $session{form}{fid} || "new";
	
        my $f = WebGUI::HTMLForm->new;
        $f->hidden("op", "editMetaDataFieldSave");
        $f->hidden("fid", $fid);
        $f->readOnly(
                -value=>$fid,
                -label=>WebGUI::International::get('Field Id','MetaData'),
                );

        $f->text("fieldName", WebGUI::International::get('Field name','MetaData'), $fieldInfo->{fieldName});
	$f->textarea("description", WebGUI::International::get(85), $fieldInfo->{description});
        $f->fieldType(
                -name=>"fieldType",
                -label=>WebGUI::International::get(486),
                -value=>[$fieldInfo->{fieldType} || "text"],
		-types=>WebGUI::MetaData::getFieldTypes()
                );
	$f->textarea("possibleValues",WebGUI::International::get(487),$fieldInfo->{possibleValues});
        $f->submit();
        $output .= $f->print;
	return _submenu($output,'Edit Metadata',"metadata edit property");
}

#-------------------------------------------------------------------
sub www_editMetaDataFieldSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	return WebGUI::Privilege::vitalComponent() if ($session{form}{fid} < 1000 && $session{form}{fid} > 0);
	# Check for duplicate field names
	my $sql = "select count(*) from metaData_properties where fieldName = ".
                                quote($session{form}{fieldName});
	if ($session{form}{fid} ne "new") {
		$sql .= " and fieldId <> ".quote($session{form}{fid});
	}
	my ($isDuplicate) = WebGUI::SQL->buildArray($sql);
	if($isDuplicate) {
		my $error = WebGUI::International::get("duplicateField", "MetaData");
		$error =~ s/\%field\%/$session{form}{fieldName}/;
		return $error . www_editMetaDataField();
	}
	if($session{form}{fieldName} eq "") {
		return WebGUI::International::get("errorEmptyField", "MetaData")
			. www_editMetaDataField();
	}
	if($session{form}{fid} eq 'new') {
		$session{form}{fid} = WebGUI::Id::generate();
		WebGUI::SQL->write("insert into metaData_properties (fieldId, fieldName, defaultValue, description, fieldType, possibleValues) values (".
					quote($session{form}{fid}).",".
					quote($session{form}{fieldName}).",".
					quote($session{form}{defaultValue}).",".
					quote($session{form}{description}).",".
					quote($session{form}{fieldType}).",".
					quote($session{form}{possibleValues}).")");
	} else {
                WebGUI::SQL->write("update metaData_properties set fieldName = ".quote($session{form}{fieldName}).", ".
					"defaultValue = ".quote($session{form}{defaultValue}).", ".
					"description = ".quote($session{form}{description}).", ".
					"fieldType = ".quote($session{form}{fieldType}).", ".
					"possibleValues = ".quote($session{form}{possibleValues}).
					" where fieldId = ".quote($session{form}{fid}));
	}

	return www_manageMetaData(); 
}

#-------------------------------------------------------------------
sub www_deleteMetaDataField {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{fid} < 1000 && $session{form}{fid} > 0);

        my $output = WebGUI::International::get('deleteConfirm','MetaData').'<p>';
        $output .= '<div align="center"><a href="'.
                WebGUI::URL::page('op=deleteMetaDataFieldConfirm&fid='.$session{form}{fid})
                .'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=manageMetaData').
                '">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output,'Delete Metadata field');
}

#-------------------------------------------------------------------
sub www_deleteMetaDataFieldConfirm {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{fid} < 1000 && $session{form}{fid} > 0);

	WebGUI::MetaData::deleteField($session{form}{fid});

	return www_manageMetaData();
}

#-------------------------------------------------------------------
sub www_manageMetaData {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $output;
	my $fields = WebGUI::MetaData::getMetaDataFields();
	foreach my $fieldId (keys %{$fields}) {
		$output .= deleteIcon("op=deleteMetaDataField&fid=".$fieldId);
		$output .= editIcon("op=editMetaDataField&fid=".$fieldId);
		$output .= "<b>".$fields->{$fieldId}{fieldName}."</b><br>";
	}	
	$output .= '<p><a href="'.WebGUI::URL::page("op=editMetaDataField&fid=new").'">'.
			WebGUI::International::get('Add new field','MetaData').
			'</a></p>';
        return _submenu($output,undef,"metadata manage");
}



1;
