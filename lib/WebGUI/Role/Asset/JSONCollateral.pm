package WebGUI::Role::Asset::JSONCollateral;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Moose::Role;
use WebGUI::Definition::Asset;

=head1 NAME

Package WebGUI::Role::Asset::JSONCollateral

=head1 DESCRIPTION

This is an aspect which allows you to use JSON in the database transparently.

=head1 SYNOPSIS

 with 'WebGUI::Role::Asset::JSONCollateral';

 $self->setJSONCollateral();
 $self->getJSONCollateral();
 $self->moveJSONCollateralUp();
 $self->moveJSONCollateralDown();

Classes that use this Aspect must have an update method that transparently serializes and deserializes data
to and from JSON into perl data structures.  See WebGUI::Crud->update, and Asset->update for examples.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 deleteJSONCollateral ( fieldName, keyName, keyValue )

Deletes a row of collateral data. Returns false if the requested collateral
was not deleted.

=head3 fieldName

The name of the field you wish to delete the data from.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to delete.

=cut

sub deleteJSONCollateral {
    my $self      = shift;
    my $fieldName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;
    my $field = $self->get($fieldName);
    my $index = $self->getJSONCollateralDataIndex($field, $keyName, $keyValue);
    return if $index == -1;
    splice @{ $field }, $index, 1;
    $self->update({ $fieldName => $field });
    return 1;
}

#-------------------------------------------------------------------

=head2 getJSONCollateral ( fieldName, keyName, keyValue )

Returns a hash reference containing one row of collateral data from a particular
field.

=head3 fieldName

The name of the field you wish to retrieve the data from.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to get.
If this is equal to "new", then an empty hashRef will be returned to avoid
strict errors in the caller.  If the requested data does not exist in the
collateral array, it also returns an empty hashRef.

=cut

sub getJSONCollateral {
    my $self      = shift;
    my $fieldName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;
    if ($keyValue eq "new" || $keyValue eq "") {
        return {}
    }
    my $field = $self->get($fieldName);
    my $index = $self->getJSONCollateralDataIndex($field, $keyName, $keyValue);
    return {} if $index == -1;
    my %copy = %{ $field->[$index] };
    return \%copy;
}


#-------------------------------------------------------------------

=head2 getJSONCollateralDataIndex ( field, keyName, keyValue )

Returns the index in a set of collateral where an element of the
data (keyName) has a certain value (keyValue).  If the criteria
are not found, returns -1.

=head3 field

The collateral data to search

=head3 keyName

The name of a key in the collateral hash.

=head3 keyValue

The value that keyName should have to meet the criteria.

=cut

sub getJSONCollateralDataIndex {
    my $self     = shift;
    my $field    = shift;
    my $keyName  = shift;
    my $keyValue = shift;
    for (my $index=0; $index <= $#{ $field }; $index++) {
        return $index
            if (exists($field->[$index]->{$keyName}) && ($field->[$index]->{$keyName} eq $keyValue ));
    }
    return -1;
}

#-------------------------------------------------------------------

=head2 moveJSONCollateralDown ( fieldName, keyName, keyValue )

Moves a collateral data item down one position, toward the end of the array where the
indices are the highest, swapping the referenced piece of collateral (index) with the collateral
just above it (index+1).  For the list of collateral 1,2,3, if called on 2 the resultig
list will be 1,3,2.  If called on the last element of the collateral array then it does nothing.

Returns 1 if the move is successful.  Returns undef or the empty array otherwise.

=head3 fieldName

A string indicating the field that contains the collateral data.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to move.

=cut

sub moveJSONCollateralDown {
    my $self      = shift;
    my $fieldName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;

    my $field = $self->get($fieldName);
    my $index = $self->getJSONCollateralDataIndex($field, $keyName, $keyValue);
    return if $index == -1;
    return unless (abs($index) < $#{$field});
    @{ $field }[$index,$index+1] = @{ $field }[$index+1,$index];
    $self->update({ $fieldName => $field });
    return 1;
}

#-------------------------------------------------------------------

=head2 moveJSONCollateralUp ( fieldName, keyName, keyValue )

Moves a collateral data item "up" one position, toward the end of the array where the
indices are the lowest, swapping the referenced piece of collateral (index) with the collateral
just below it (index-1).  For the list of collateral 1,2,3, if called on 2 the resultig
list will be 2,1,3.  If called on the first element of the collateral array then it does nothing.

Returns 1 if the move is successful.  Returns undef or the empty array otherwise.

=head3 fieldName

A string indicating the field that contains the collateral data.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to move.

=cut

sub moveJSONCollateralUp {
    my $self      = shift;
    my $fieldName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;

    my $field = $self->get($fieldName);
    my $index = $self->getJSONCollateralDataIndex($field, $keyName, $keyValue);
    return unless $index > 0; #-1 means that it could not be found, and we cannot move index 0
    @{ $field }[$index-1,$index] = @{ $field }[$index,$index-1];
    $self->update({ $fieldName => $field });
    return 1;
}

#-----------------------------------------------------------------

=head2 setJSONCollateral ( fieldName, keyName, keyValue, properties )

Performs and insert/update of collateral data for any wobject's collateral data.
Returns the id of the data that was set, even if a new row was added to the
data.

=head3 fieldName

The name of the field to insert the data.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to set.
The index of the collateral data to set.  If the keyValue = "new", then a
new entry will be appended to the end of the collateral array.  Otherwise,
the appropriate entry will be overwritten with the new data.

=head3 properties

A hash reference containing the name/value pairs to be inserted into the collateral, using
the criteria mentioned above.

=cut

sub setJSONCollateral {
    my $self       = shift;
    my $fieldName  = shift;
    my $keyName    = shift;
    my $keyValue   = shift;
    my $properties = shift;
    ##Note, since this returns a reference, it is actually updating
    ##the object cache directly.
    my $field = $self->get($fieldName);
    if ($keyValue eq 'new' || $keyValue eq '') {
        if (  ! exists $properties->{$keyName}
           or ! $self->session->id->valid($properties->{$keyName})) {
            $properties->{$keyName} = $self->session->id->generate;
        }
        push @{ $field }, $properties;
        $self->update({$fieldName => $field});
        return $properties->{$keyName};
    }
    my $index = $self->getJSONCollateralDataIndex($field, $keyName, $keyValue);
    return if $index == -1;
    $field->[$index] = $properties;
    $self->update({ $fieldName => $field });
    return $keyValue;
}


1;
