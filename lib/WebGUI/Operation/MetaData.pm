package WebGUI::Operation::MetaData;

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
use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Operation::Shared;
use WebGUI::Icon;
use WebGUI::Privilege;
use WebGUI::SQL;
use WebGUI::MetaData;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editMetaDataField &www_manageMetaData &www_editMetaDataFieldSave &www_deleteMetaDataField
		 &www_deleteMetaDataFieldConfirm &www_saveSettings);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=manageSettings')} = WebGUI::International::get(4);
	if($session{form}{op} ne "manageMetaData") {
		$menu{WebGUI::URL::page('op=manageMetaData')} = WebGUI::International::get('Manage Metadata','MetaData');
	}
        $menu{WebGUI::URL::page('op=editMetaDataField')} = WebGUI::International::get('Add new field','MetaData');
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_saveSettings {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::SQL->write("update settings set value=".quote($session{form}{metaDataEnabled})." where name='metaDataEnabled'");
	WebGUI::SQL->write("update settings set value=".quote($session{form}{passiveProfilingEnabled})." where name='passiveProfilingEnabled'");
	$session{setting}{metaDataEnabled} = $session{form}{metaDataEnabled};
	$session{setting}{passiveProfilingEnabled} = $session{form}{passiveProfilingEnabled};
	return www_manageMetaData();
}

#-------------------------------------------------------------------
sub www_editMetaDataField {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        return WebGUI::Privilege::vitalComponent() if ($session{form}{fid} < 1000 && $session{form}{fid} > 0);

        my ($output, $fieldName, $defaultValue, $description, $fieldInfo);
        # TODO: add help / internationlize
        $output = helpIcon(22);
        $output .= '<h1>'.WebGUI::International::get('Edit Metadata','MetaData').'</h1>';
	
	if($session{form}{fid} && $session{form}{fid} ne "new") {
		$fieldInfo = WebGUI::MetaData::getField($session{form}{fid});
	}

	my $fid = $session{form}{fid} || "new";
	
        #TODO: internatioa
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
        #$f->text("defaultValue", "Default value", $defaultValue);
        $f->submit();
        $output .= $f->print;
	return _submenu($output);	
}

#-------------------------------------------------------------------
sub www_editMetaDataFieldSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	return WebGUI::Privilege::vitalComponent() if ($session{form}{fid} < 1000 && $session{form}{fid} > 0);
	# Check for duplicate field names
	my $sql = "select count(*) from metaData_fields where fieldName = ".
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
	if($session{form}{fid} eq 'new') {
		$session{form}{fid} = getNextId("metaData_fieldId");
		WebGUI::SQL->write("insert into metaData_fields (fieldId, fieldName, defaultValue, description, fieldType, possibleValues) values (".
					quote($session{form}{fid}).",".
					quote($session{form}{fieldName}).",".
					quote($session{form}{defaultValue}).",".
					quote($session{form}{description}).",".
					quote($session{form}{fieldType}).",".
					quote($session{form}{possibleValues}).")");
	} else {
                WebGUI::SQL->write("update metaData_fields set fieldName = ".quote($session{form}{fieldName}).", ".
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

	#TODO HELP
        my $output = helpIcon("theme delete");
        $output .= '<h1>'.WebGUI::International::get('Delete Metadata field','MetaData').'</h1>';
        $output .= WebGUI::International::get('deleteConfirm','MetaData').'<p>';
        $output .= '<div align="center"><a href="'.
                WebGUI::URL::page('op=deleteMetaDataFieldConfirm&fid='.$session{form}{fid})
                .'">'.WebGUI::International::get(44).'</a>';
        $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page('op=manageMetaData').
                '">'.WebGUI::International::get(45).'</a></div>';
        return _submenu($output);

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
        # TODO: add help
        $output = helpIcon(22);
        $output .= '<h1>'.WebGUI::International::get('Manage Metadata','MetaData').'</h1>';
	my $f = new WebGUI::HTMLForm;
	$f->hidden("op","saveSettings");
	$f->yesNo(
        	-name=>"metaDataEnabled",
	        -label=>WebGUI::International::get("Enable Metadata ?", 'MetaData'),
		-value=>$session{setting}{metaDataEnabled},
        );
	$f->yesNo(
		-name=>"passiveProfilingEnabled",
                -label=>WebGUI::International::get("Enable passive profiling ?", 'MetaData'),
                -value=>$session{setting}{passiveProfilingEnabled},
        );

	$f->submit();
	$output .= $f->print;
	$output .= "<h1>".WebGUI::International::get('Manage Metadata fields','MetaData')."</h1>";
	my $fields = WebGUI::MetaData::getMetaDataFields();
	foreach my $fieldId (keys %{$fields}) {
		$output .= deleteIcon("op=deleteMetaDataField&fid=".$fieldId);
		$output .= editIcon("op=editMetaDataField&fid=".$fieldId);
		$output .= "<b>".$fields->{$fieldId}{fieldName}."</b><br>";
	}	
	$output .= '<p><a href="'.WebGUI::URL::page("op=editMetaDataField&fid=new").'">'.
			WebGUI::International::get('Add new field','MetaData').
			'</a></p>';
        return _submenu($output);
}



1;
