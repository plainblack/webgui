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
use WebGUI::Macro;
use Tie::IxHash;
use WebGUI::ErrorHandler;

=head1 NAME

Package WebGUI::MetaData

=head1 DESCRIPTION

This package provides an interface to the MetaData system.

=head1 SYNOPSIS

 use WebGUI::MetaData;

 $wid = getWobjectByCriteria($hashRef);
 $hashRef = WebGUI::MetaData::getField( $fieldId );
 $hashRef = WebGUI::MetaData::getMetaDataFields();
 $wid = getWobjectByCriteria($hashRef);
 $arrayRef = WebGUI::MetaData::getFieldTypes;
 WebGUI::MetaData::metaDataSave( $wobjectId )
 WebGUI::MetaData::metaDataDelete( $wobjectId )
 WebGUI::MetaData::MetaDataDuplicate( $fromWobjectId , $toWobjectId )
 WebGUI::MetaData::deleteField( $fieldId );

=head1 METHODS

These functions/methods are available from this package:

=cut


#-------------------------------------------------------------------

                                                                                                                             
=head2 getFieldTypes ()
                                                                                                                             
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
        WebGUI::SQL->write("delete from metaData_properties where fieldId = ".quote($fieldId));
        WebGUI::SQL->write("delete from metaData_values where fieldId = ".quote($fieldId));
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
		from metaData_properties f
		left join metaData_values d on f.fieldId=d.fieldId and d.wobjectId=".quote($wobjectId);
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

=over

=item wobjectId

The Id from the wobject you want to save metadata for.

=back

=cut

sub metaDataSave {
	my $wobjectId = shift;
	foreach my $form (keys %{$session{form}}) {
		if ($form =~ /^metadata_(\d+)$/) {
			my $fieldId = $1; 
			my ($exists) = WebGUI::SQL->quickArray("select count(*) from metaData_values
							where wobjectId = ".quote($wobjectId)."
							and fieldId = ".quote($fieldId));
			if(! $exists && $session{form}{$form} ne "") {
				WebGUI::SQL->write("insert into metaData_values (fieldId, wobjectId)
							values (".quote($fieldId).",".quote($wobjectId).")");
			}
			if($session{form}{$form} eq "") {
				# Keep it clean
				WebGUI::SQL->write("delete from metaData_values where wobjectId = ".
							quote($wobjectId)." and fieldId = ".quote($fieldId));
			} else {
				WebGUI::SQL->write("update metaData_values set value = ".quote($session{form}{$form})."
							where wobjectId = ".quote($wobjectId)." and fieldId = ".
							quote($fieldId));
			}
		}
	}
}

#-------------------------------------------------------------------

=head2 metaDataDelete ( wobjectId )

Deletes the metadata for requested wobjectId

=over

=item wobjectId

The Id from the wobject you want to delete metadata for.

=back

=cut

sub metaDataDelete {
	my $wobjectId = shift;
	return WebGUI::SQL->write("delete from metaData_values where wobjectId = ".quote($wobjectId));
}

#-------------------------------------------------------------------

=head2 MetaDataDuplicate ( fromWobjectId , toWobjectId )

Duplicates Metadata

=over

=item fromWobjectId

The original wobject Id

=item toWobjectId

The new wobject Id

=back

=cut

sub MetaDataDuplicate {
	my $fromWobjectId = shift;
	my $toWobjectId = shift;
        my $sth = WebGUI::SQL->read("select * from metaData_values where wobjectId = ".quote($fromWobjectId));
        while( my $h = $sth->hashRef) {
		WebGUI::SQL->write("insert into metaData_values (fieldId, wobjectId, value) values (".
					quote($h->{fieldId}).",".quote($toWobjectId).",".quote($h->{value}).")");
        }
        $sth->finish;

}

#-------------------------------------------------------------------

=head2 getWobjectByCriteria ( hashRef )

This function will search for a wobject that match a metadata criteria set.
If no wobject is found, undef will be returned.

=over

=item hashRef

A typical hashRef for this function will look like:

{
	proxiedNamespace => "Article",
	resolveMultiples => "random",
	proxyCriteria => "State = Wisconsin AND Country != Sauk"
}

Most of the time this will be a:

WebGUI::SQL->quickHashRef("select * from WobjectProxy where wobjectId=$proxiedId");

=back

=cut

sub getWobjectByCriteria {
	my $wobjectProxy = shift;
	my $criteria = $wobjectProxy->{proxyCriteria};
	my $order = $wobjectProxy->{resolveMultiples};
	my $namespace = $wobjectProxy->{proxiedNamespace};
	my $wobjectId = $wobjectProxy->{wobjectId};

	# Parse macro's in criteria
	$criteria = WebGUI::Macro::process($criteria);

	# Once a wobject is found, we will stick to that wobject, 
	# to prevent the proxying of multiple- depth wobjects like Surveys and USS.
	my $scratchId;
	if ($wobjectId) {
		$scratchId = "WobjectProxy_" . $wobjectId;
		if($session{scratch}{$scratchId}) {
			return $session{scratch}{$scratchId} unless ($session{var}{adminOn});
		}
	}

	# $criteria = "State = Wisconsin AND Country != Sauk";
	#
	# State          =             Wisconsin AND Country != Sauk
	# |              |             |
	# |- $field      |_ $operator  |- $value
	# |_ $attribute                |_ $attribute
	my $operator = qr/<>|!=|=|>=|<=|>|<|like/i;
	my $attribute = qr/['"][^()|=><!]+['"]|[^()|=><!\s]+/i; 
                                                                                                      
	my $constraint = $criteria;
	
	# Get each expression from $criteria
	foreach my $expression ($criteria =~ /($attribute\s*$operator\s*$attribute)/gi) {
		# $expression will match "State = Wisconsin"

        	my $replacement = $expression;	# We don't want to modify $expression.
						# We need it later.

		# Get the field (State) and the value (Wisconsin) from the $expression.
	        $expression =~ /($attribute)\s*$operator\s*($attribute)/gi;
	        my $field = $1;
	        my $value = $2;

		# quote the field / value variables.
		my $quotedField = $field;
		my $quotedValue = $value;
		unless ($field =~ /^\s*['"].*['"]\s*/) {
			$quotedField = quote($field);
		}
                unless ($value =~ /^\s*['"].*['"]\s*/) {
                        $quotedValue = quote($value);
                }
		
		# transform replacement from "State = Wisconsin" to 
		# "(fieldname=State and value = Wisconsin)"
	        $replacement =~ s/\Q$field/(fieldname=$quotedField and value /;
	        $replacement =~ s/\Q$value/$quotedValue )/i;

		# replace $expression with the new $replacement in $constraint.
	        $constraint =~ s/\Q$expression/$replacement/;
	}
	my $sql =  "	select w.wobjectId 
			from metaData_values d, metaData_properties f, wobject w 
			where f.fieldId = d.fieldId
				and w.wobjectId = d.wobjectId
				and w.namespace = ".quote($namespace); 			

	
	# Add constraint only if it has been modified.
	$sql .= " and ".$constraint if (($constraint ne $criteria) && $constraint ne "");
	$sql .= " order by w.lastEdited desc";

	# Execute the query with an unconditional read
	my @wids;
        my $sth = WebGUI::SQL->unconditionalRead($sql);
        while (my ($data) = $sth->array) {
		push (@wids, $data);
        }
        $sth->finish;

	# No matching wobjects found.
        if (scalar(@wids) == 0) {
                return undef; # fall back to the originally mirrored wobject.
	}
	my $wid;
	# Grab a wid from the results
	if ($order == 'random') {
		$wid = $wids[ rand @wids ];
	} else { 
				 #default order is mostRecent
		$wid = $wids[0]; # 1st element in list is most recent.
	}

	# Store the matching wobjectId in user scratch. 
	WebGUI::Session::setScratch($scratchId,$wid) if ($scratchId);

	return $wid;		
}

1;

