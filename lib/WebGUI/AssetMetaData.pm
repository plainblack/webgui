package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

=head1 NAME

Package WebGUI::Asset

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all metadata related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 deleteMetaDataField ( )

Deletes a field from the metadata system.

=head3 fieldId

The fieldId to be deleted.

=cut

sub deleteMetaDataField {
	my $self = shift;
	my $fieldId = shift;
	WebGUI::SQL->beginTransaction;
        WebGUI::SQL->write("delete from metaData_properties where fieldId = ".quote($fieldId));
        WebGUI::SQL->write("delete from metaData_values where fieldId = ".quote($fieldId));
	WebGUI::SQL->commit;
}


#-------------------------------------------------------------------

=head2 getMetaDataFields ( [fieldId] )

Returns a hash reference containing all metadata field properties.  You can limit the output to a certain field by specifying a fieldId.

=head3 fieldId

If specified, the hashRef will contain only this field.

=cut

sub getMetaDataFields {
	my $self = shift;
	my $fieldId = shift;
	my $sql = "select
		 	f.fieldId, 
			f.fieldName, 
			f.description, 
			f.defaultValue,
			f.fieldType,
			f.possibleValues,
			d.value
		from metaData_properties f
		left join metaData_values d on f.fieldId=d.fieldId and d.assetId=".quote($self->getId);
	$sql .= " where f.fieldId = ".quote($fieldId) if ($fieldId);
	$sql .= " order by f.fieldName";
	if ($fieldId) {
		return WebGUI::SQL->quickHashRef($sql);	
	} else {
		tie my %hash, 'Tie::IxHash';
		my $sth = WebGUI::SQL->read($sql);
	        while( my $h = $sth->hashRef) {
			foreach(keys %$h) {
				$hash{$h->{fieldId}}{$_} = $h->{$_};
			}
		}
       	 	$sth->finish;
        	return \%hash;
	}
}


#-------------------------------------------------------------------

=head2 updateMetaData ( fieldName, value )

Updates the value of a metadata field for this asset.

=head3 fieldName

The name of the field to update.

=head3 value

The value to set this field to. Leave blank to unset it.

=cut

sub updateMetaData {
	my $self = shift;
	my $fieldName = shift;
	my $value = shift;
	my ($exists) = WebGUI::SQL->quickArray("select count(*) from metaData_values where assetId = ".quote($self->getId)." and fieldId = ".quote($fieldName));
        if (!$exists && $value ne "") {
        	WebGUI::SQL->write("insert into metaData_values (fieldId, assetId) values (".quote($fieldName).",".quote($self->getId).")");
        }
        if ($value  eq "") { # Keep it clean
                WebGUI::SQL->write("delete from metaData_values where assetId = ".quote($self->getId)." and fieldId = ".quote($fieldName));
        } else {
                WebGUI::SQL->write("update metaData_values set value = ".quote($value)." where assetId = ".quote($self->getId)." and fieldId=".quote($fieldName));
        }
}


#-------------------------------------------------------------------

=head2 www_deleteMetaDataField ( )

Deletes a MetaDataField and returns www_manageMetaData on self, if user isInGroup(4), if not, renders a "content profiling" AdminConsole as insufficient privilege. 

=cut

sub www_deleteMetaDataField {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	$self->deleteMetaDataField($session{form}{fid});
	return $self->www_manageMetaData;
}


#-------------------------------------------------------------------

=head2 www_editMetaDataField ( )

Returns a rendered page to edit MetaData.  Will return an insufficient Privilege if not InGroup(4).

=cut

sub www_editMetaDataField {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("contentProfiling");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
        my $fieldInfo;
	if($session{form}{fid} && $session{form}{fid} ne "new") {
		$fieldInfo = $self->getMetaDataFields($session{form}{fid});
	}
	my $fid = $session{form}{fid} || "new";
	my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
	$f->hidden(
		-name => "func",
		-value => "editMetaDataFieldSave"
	);
	$f->hidden(
		-name => "fid",
		-value => $fid
	);
	$f->readOnly(
		-value=>$fid,
		-label=>WebGUI::International::get('Field Id','Asset'),
	);
	$f->text(
		-name=>"fieldName",
		-label=>WebGUI::International::get('Field name','Asset'),
		-hoverHelp=>WebGUI::International::get('Field Name description','Asset'),
		-value=>$fieldInfo->{fieldName}
	);
	$f->textarea(
		-name=>"description",
		-label=>WebGUI::International::get(85,"Asset"),
		-hoverHelp=>WebGUI::International::get('Metadata Description description',"Asset"),
		-value=>$fieldInfo->{description});
	$f->fieldType(
		-name=>"fieldType",
		-label=>WebGUI::International::get(486,"Asset"),
		-hoverHelp=>WebGUI::International::get('Data Type description',"Asset"),
		-value=>$fieldInfo->{fieldType} || "text",
		-types=> [ qw /text integer yesNo selectList radioList/ ]
	);
	$f->textarea(
		-name=>"possibleValues",
		-label=>WebGUI::International::get(487,"Asset"),
		-hoverHelp=>WebGUI::International::get('Possible Values description',"Asset"),
		-value=>$fieldInfo->{possibleValues}
	);
	$f->submit();
	$ac->setHelp("metadata edit property","Asset");
	return $ac->render($f->print, WebGUI::International::get('Edit Metadata',"Asset"));
}

#-------------------------------------------------------------------

=head2 www_editMetaDataFieldSave ( )

Verifies that MetaData fields aren't duplicated or blank, assigns default values, and returns the www_manageMetaData() method. Will return an insufficient Privilege if not InGroup(4).

=cut

sub www_editMetaDataFieldSave {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("content profiling");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	$ac->setHelp("metadata edit property","Asset");
	# Check for duplicate field names
	my $sql = "select count(*) from metaData_properties where fieldName = ".
                                quote($session{form}{fieldName});
	if ($session{form}{fid} ne "new") {
		$sql .= " and fieldId <> ".quote($session{form}{fid});
	}
	my ($isDuplicate) = WebGUI::SQL->buildArray($sql);
	if($isDuplicate) {
		my $error = WebGUI::International::get("duplicateField", "Asset");
		$error =~ s/\%field\%/$session{form}{fieldName}/;
		return $ac->render($error,WebGUI::International::get('Edit Metadata',"Asset"));
	}
	if($session{form}{fieldName} eq "") {
		return $ac->render(WebGUI::International::get("errorEmptyField", "Asset"),WebGUI::International::get('Edit Metadata',"Asset"));
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

	return $self->www_manageMetaData; 
}


#-------------------------------------------------------------------

=head2 www_manageMetaData ( )

Returns an AdminConsole to deal with MetaDataFields. If isInGroup(4) is False, renders an insufficient privilege page.

=cut

sub www_manageMetaData {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("contentProfiling");
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(4));
	$ac->addSubmenuItem($self->getUrl('func=editMetaDataField'), WebGUI::International::get("Add new field","Asset"));
	my $output;
	my $fields = $self->getMetaDataFields();
	foreach my $fieldId (keys %{$fields}) {
		$output .= deleteIcon("func=deleteMetaDataField;fid=".$fieldId,$self->get("url"),WebGUI::International::get('deleteConfirm','Asset'));
		$output .= editIcon("func=editMetaDataField;fid=".$fieldId,$self->get("url"));
		$output .= " <b>".$fields->{$fieldId}{fieldName}."</b><br />";
	}	
        $ac->setHelp("metadata manage","Asset");
	return $ac->render($output);
}




1;

