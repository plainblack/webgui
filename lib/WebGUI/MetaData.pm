package WebGUI::MetaData;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use WebGUI::Session;
use WebGUI::SQL;
use Tie::IxHash;

=head1 NAME

Package WebGUI::MetaData

=head1 DESCRIPTION

This package provides an interface to the MetaData system.

=head1 SYNOPSIS

 use WebGUI::MetaData;
 $arrayRef = WebGUI::MetaData::getFieldTypes;
 $hashRef = WebGUI::MetaData::getMetaDataFields;

=head1 METHODS

These functions/methods are available from this package:

=cut


#-------------------------------------------------------------------
                                                                                                                             
=head2 getFieldTypes ( )
                                                                                                                             
Returns an array ref with supported metadata field types.

=cut

sub getFieldTypes {
	return [ qw /text integer yesNo selectList radioList/ ];
}

#-------------------------------------------------------------------

=head2 deleteField ( fieldId )

Deletes a field from the metadata system.

=over

=item fieldId

The fieldId to be deleted.

=back

=cut

sub deleteField {
	my $fieldId = shift;
	return unless ($fieldId =~ /^\d+$/);
        WebGUI::SQL->write("delete from metaData_fields where fieldId = ".quote($fieldId));
        WebGUI::SQL->write("delete from metaData_data where fieldId = ".quote($fieldId));
}

#-------------------------------------------------------------------

=head2 getField ( fieldId , [ wobjectId ] )

Returns a hash reference containing metadata field properties
for a single field.

=over

=item fieldId

The fieldId for which you want to retrieve field properties.

=item wobjectId

If specified, the method will not only get the field properties,
but the value for this wobjectId as well.
=back

=cut

sub getField {
	my $hashRef = {};
	my $fieldId = shift;
	my $wobjectId = shift;
	my $field = getMetaDataFields($wobjectId, $fieldId);
	foreach (keys %{$field->{$fieldId}}) {
		$hashRef->{$_} = $field->{$fieldId}{$_};
	}
	return $hashRef;
}

#-------------------------------------------------------------------

=head2 getMetaDataFields ( [ wobjectId , fieldId] )

Returns a hash reference containing all metadata field properties.
If a wobjectId is specified, the metadata values for that wobject
are included as well. You can limit the output to a certain
field by specifying a fieldId.

=over

=item wobjectId 

If specified, the hashRef will contain the metadata values for 
this wobject.

=item fieldId

If specified, the hashRef will contain only this field.

=back

=cut

sub getMetaDataFields {
	my $wobjectId = shift;
	my $fieldId = shift;
	tie my %hash, 'Tie::IxHash';
	my $sql = "select
		 	f.fieldId, 
			f.fieldName, 
			f.description, 
			f.defaultValue,
			f.fieldType,
			f.possibleValues,
			d.value
		from metaData_fields f
		left join metaData_data d on f.fieldId=d.fieldId and d.wobjectId=".quote($wobjectId);
	$sql .= " where f.fieldId = ".quote($fieldId) if ($fieldId);
	$sql .= " order by f.fieldName";
	my $sth = WebGUI::SQL->read($sql);
        while( my $h = $sth->hashRef) {
		foreach(keys %$h) {
			$hash{$h->{fieldId}}{$_} = $h->{$_};
		}
	}
        $sth->finish;
        return \%hash;
}

#-------------------------------------------------------------------

=head2 metaDataSave ( wobjectId )

Saves posted metadata for requested wobjectId

=item wobjectId

The Id from the wobject you want to save metadata for.

=back

=cut

sub metaDataSave {
	my $wobjectId = shift;
	foreach my $form (keys %{$session{form}}) {
		if ($form =~ /^metadata_(\d+)$/) {
			my $fieldId = $1; 
			my ($exists) = WebGUI::SQL->quickArray("select count(*) from metaData_data
							where wobjectId = ".quote($wobjectId)."
							and fieldId = ".quote($fieldId));
			if(! $exists && $session{form}{$form} ne "") {
				WebGUI::SQL->write("insert into metaData_data (fieldId, wobjectId)
							values (".quote($fieldId).",".quote($wobjectId).")");
			}
			if($session{form}{$form} eq "") {
				# Keep it clean
				WebGUI::SQL->write("delete from metaData_data where wobjectId = ".
							quote($wobjectId)." and fieldId = ".quote($fieldId));
			} else {
				WebGUI::SQL->write("update metaData_data set value = ".quote($session{form}{$form})."
							where wobjectId = ".quote($wobjectId)." and fieldId = ".
							quote($fieldId));
			}
		}
	}
}

#-------------------------------------------------------------------

=head2 metaDataDelete ( wobjectId )

Deletes the metadata for requested wobjectId

=item wobjectId

The Id from the wobject you want to delete metadata for.

=back

=cut

sub metaDataDelete {
	my $wobjectId = shift;
	return WebGUI::SQL->write("delete from metaData_data where wobjectId = ".quote($wobjectId));
}

#-------------------------------------------------------------------

=head2 MetaDataDuplicate ( fromWobjectId , toWobjectId )

Duplicates Metadata

=item fromWobjectId

The original wobject Id

=item toWobjectId

The new wobject Id

=back

=cut

sub MetaDataDuplicate {
	my $fromWobjectId = shift;
	my $toWobjectId = shift;
        my $sth = WebGUI::SQL->read("select * from metaData_data where wobjectId = ".quote($fromWobjectId));
        while( my $h = $sth->hashRef) {
		WebGUI::SQL->write("insert into metaData_data (fieldId, wobjectId, value) values (".
					quote($h->{fieldId}).",".quote($toWobjectId).",".quote($h->{value}).")");
        }
        $sth->finish;

}

1;

