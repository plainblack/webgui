package WebGUI::AssetCollateral::DataForm::Entry;

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

=head1 NAME

Package WebGUI::AssetCollateral::DataForm::Entry

=head1 DESCRIPTION

Package to manipulate user entries for WebGUI::Asset::Wobject::DataForm.

There should be a list of data that this module uses and a description of how
they relate and function.

=head1 METHODS

This packages is a subclass of L<WebGUI::Crud>.  Please refer to that module
for a list of base methods that are available.

=cut

our $VERSION = '0.0.1';

use Class::InsideOut qw(readonly private public id register);
use WebGUI::Exception;
use WebGUI::Asset::Wobject::DataForm;

readonly    session         => my %session;
private     entryData       => my %entryData;
private     entryId         => my %entryId;
readonly    assetId         => my %assetId;
readonly    asset           => my %asset;
private     userId          => my %userId;
readonly    username        => my %username;
public      ipAddress       => my %ipAddress;
public      submissionDate  => my %submissionDate;

#-------------------------------------------------------------------

=head2 delete 

Deletes this entry from the database. Returns true.

=cut

sub delete {
    my $self = shift;
    $self->session->db->deleteRow('DataForm_entry', 'DataForm_entryId', $self->getId);
    delete $entryId{ id $self };
    return 1;
}

#-------------------------------------------------------------------

=head2 deleteField 

Deletes a field from this entry.  Throws an InvalidParam exception if the field
does not exist.  Otherwise, returns the entry for this field after deleting it.

=cut

sub deleteField {
    my $self = shift;
    my ($field) = @_;
    my $entryData = $entryData{ id $self };
    if ( !exists $entryData{ $field } ) {
        WebGUI::Error::InvalidParam->throw(error=>"cannot delete field that doesn't exist");
    }
    return delete $entryData{$field};
}

#-------------------------------------------------------------------

=head2 field ( $fieldName, [ $fieldValue ] )

Getter and setter for field data.  Returns the value of the field after
the set has been done.

=head3 $fieldName

The name of the field to work on.

=head3 $fieldValue

If passed in, this value will be stored in the field.

=cut

sub field {
    my $self = shift;
    my $fieldName = shift;
    my $entryData = $entryData{ id $self };
    if (@_) {
        my $fieldValue = shift;
        return $entryData->{ $fieldName } = $fieldValue;
    }
    return $entryData->{ $fieldName };
}

#-------------------------------------------------------------------

=head2 fields ( [ $newData ] )

Getter and setter for all fields.  Returns a hash of all fields in
this entry.

=head3 $newData

A hash reference of new data to store in this entry.

=cut

sub fields {
    my $self = shift;
    my $entryData = $entryData{ id $self };
    if (@_) {
        my $newData = shift;
        @{ $entryData }{ keys %$newData } = values %$newData;
    }
    return { %{ $entryData } };
}

#----------------------------------------------------------------------------

=head2 getHash ( )

Gets a hash reference of data for this entry, which looks like this:
 
 {
     DataForm_entryId    => "entryId",
     userId              => "userId",
     username            => "username",
     ipAddress           => "0.0.0.0",
     assetId             => "assetId",
     submissionDate      => "2008-00-00 00:00:00", # in UTC
     entryData           => { name => value, name => value, ... },
 }

=cut

sub getHash {
    my $self    = shift;
    my $id      = id $self;

    my $var = {
        DataForm_entryId    => $entryId{$id},
        userId              => $userId{$id},
        username            => $username{$id},
        ipAddress           => $ipAddress{$id},
        assetId             => $assetId{$id},
        submissionDate      => $submissionDate{$id}->toDatabase,
        entryData           => $entryData{$id},
    };

    return $var;
}

#-------------------------------------------------------------------

=head2 getCount ($asset)

Returns the number of entries for a dataform.

=head3 $asset

A reference to a Dataform object.

=cut

sub getCount {
    my $class = shift;
    my $asset = shift;
    my $entryCount = $asset->session->dbSlave->quickScalar(
        "SELECT COUNT(*) FROM `DataForm_entry` WHERE `assetId` = ?",
        [$asset->getId]
    );
    return $entryCount;
}

#-------------------------------------------------------------------

=head2 getId 

Returns the GUID for this entry.

=cut

sub getId {
    my $self = shift;
    return $entryId{ id $self };
}

#-------------------------------------------------------------------

=head2 iterateAll ( $asset, [ $options ] )

This class method returns an iterator set to iterate over all entries for a Dataform.

=head3 $asset

A reference to a Dataform object.

=head3 $options

A hashreference of options.

=head4 offset

The record number to start the iterator at.  Defaults to 0 if not set.

=head4 limit

The number of records for the iterator to return.  Defaults to a very large number if not set.

=cut

sub iterateAll {
    my $class   = shift;
    my $asset   = shift;
    my $options = shift;
    my $sql = "SELECT SQL_CALC_FOUND_ROWS `DataForm_entryId`, `userId`, `username`, `ipAddress`, `submissionDate`, `entryData` FROM `DataForm_entry` WHERE `assetId` = ? ORDER BY `submissionDate` DESC LIMIT ?,?";
    my $placeHolders = [ $asset->getId ];
    push @{ $placeHolders }, exists $options->{offset} ? $options->{offset} : 0;
    push @{ $placeHolders }, exists $options->{limit}  ? $options->{limit}  : 1234567890;
    my $slave   = $asset->session->dbSlave;  ##Use the same slave to calculate the number of rows
    my $sth     = $slave->read($sql, $placeHolders);
    my $allRows = $slave->quickScalar('SELECT FOUND_ROWS()');
    my $sub   = sub {
        return $allRows if $_[0] eq 'rowCount';
        if (defined wantarray) {
            my $properties = $sth->hashRef;
            if ($properties) {
                my $entry = $class->new($asset);
                $entry->setFromHash($properties);
                return $entry;
            }
            else {
                return;
            }
        }
        else {
            $sth->arrayRef;
        }
    };
    return $sub;
}

#-------------------------------------------------------------------

=head2 new ( asset [, entryId ] )

=head2 new ( session, entryId )

Instantiate an object. If C<entryId> is defined, will pull the correct entry
from the database. If C<entryId> is not defined, will create a new entry.

=cut

sub new {
    my ($class, $asset, $entryId) = @_;
    my $self = register($class);
    my $id = id $self;
    my $session;
    if (defined $asset && ref $asset && $asset->isa('WebGUI::Asset::Wobject::DataForm')) {
        $session = $session{$id} = $asset->session;
        $assetId{$id} = $asset->getId;
        $asset{$id} = $asset;
    }
    elsif (defined $asset && ref $asset && $asset->isa('WebGUI::Session') && $entryId) {
        $session = $session{$id} = $asset;
        undef $asset;
    }
    else {
        WebGUI::Error::InvalidObject->throw(error=>'need a DataForm object or a session and entryId', got => ref $asset, expected => 'WebGUI::Asset::Wobject::DataForm');
    }
    if ($entryId) {
        my $properties = $session->db->getRow('DataForm_entry', 'DataForm_entryId', $entryId);
        if (! defined $properties->{'DataForm_entryId'}) {
            WebGUI::Error::ObjectNotFound->throw(error => 'no such DataForm_entryId', id => $entryId);
        }
        if (! $assetId{$id}) {
            $assetId{$id} = $properties->{assetId};
            $asset{$id} = WebGUI::Asset::Wobject::DataForm->newById($session, $properties->{assetId});
        }
        $self->setFromHash($properties);
    }
    else {
        $self->user($session->user);
        $self->ipAddress($session->request->address);
        $self->submissionDate(WebGUI::DateTime->new($session, time));
        $entryData{id $self} = {};
    }
    return $self;
}

#----------------------------------------------------------------------------

=head2 newFromHash ( asset, properties )

=head2 newFromHash ( session, assetId, properties )

Create a new DataForm entry from the given properties.

=cut

sub newFromHash {
    my $class   = shift;
    my $asset   = shift;
    my $self;

    if ( defined $asset && ref $asset && $asset->isa( 'WebGUI::Asset::Wobject::DataForm' ) ) {
        my $properties  = shift;
        $self           = $class->new( $asset );
        $self->setFromHash( $properties );
    } 
    elsif ( defined $asset && ref $asset && $asset->isa( 'WebGUI::Session' ) ) {
        my $session     = $asset;
        my $assetId     = shift;
        my $properties  = shift;
        $asset          = WebGUI::Asset->newById( $session, $assetId );
        $self           = $class->new( $asset );
        $self->setFromHash( $properties );
    }

    return $self;
}

#-------------------------------------------------------------------

=head2 purgeAssetEntries ( $asset )

Delete all entries for a Dataform.

=head3 $asset

A reference to a Dataform object.

=cut

sub purgeAssetEntries {
    my $class = shift;
    my $asset = shift;
    $asset->session->db->write("DELETE FROM `DataForm_entry` WHERE `assetId`=?", [$asset->getId]);
    return 1;
}

#-------------------------------------------------------------------

=head2 renameField ($oldField, $newField)

Renames a field inside this entry.  Throws an InvalidParam exception if the old field
does not exist, or if the new field already exists.

=head3 $oldField

The name of the field to rename.

=head3 $newField

The new name of the field.

=cut

sub renameField {
    my $self = shift;
    my ($oldField, $newField) = @_;
    my $entryData = $entryData{ id $self };
    if ( !exists $entryData{ $oldField } ) {
        WebGUI::Error::InvalidParam->throw(error=>"cannot rename field that doesn't exist");
    }
    elsif ( exists $entryData{ $newField } ) {
        WebGUI::Error::InvalidParam->throw(error=>'cannot rename field over existing field');
    }
    $entryData->{$newField} = delete $entryData{$oldField};
    return $newField;
}

#-------------------------------------------------------------------

=head2 save 

Persists data from this entry into the db.

=cut

sub save {
    my $self = shift;
    my $id = id $self;
    my $entryData = $entryData{ $id };
    if (!$entryData || ref $entryData ne 'HASH') {
        $entryData = {};
    }
    my %dbData = (
        DataForm_entryId    => $entryId{$id} || 'new',
        userId              => $userId{$id},
        username            => $username{$id},
        ipAddress           => $ipAddress{$id},
        assetId             => $assetId{$id},
        submissionDate      => $submissionDate{$id}->toDatabase,
        entryData           => JSON::to_json($entryData),
    );
    return $entryId{$id} = $session{$id}->db->setRow('DataForm_entry', 'DataForm_entryId', \%dbData);
}

#-------------------------------------------------------------------

=head2 setFromHash ( $properties )

Sets all properties for this entry.  Returns true.

=head3 $properties

A hashref of data to set for this entry.  Only keys from the properties hash ref
will be set.  No old data missing from $properties will be lost.

=head4 DataForm_entryId

GUID that the DataForm uses to refer to this entry.

=head4 userId

GUID of the user who submitted this entry.

=head4 username

The user's username.

=head4 ipAddress

The IP address the user submitted it from.

=head4 submissionDate

The epoch date the entry was submitted.

=head4 entryData

Data, either as JSON or a perl data structure.

=cut

sub setFromHash {
    my $self = shift;
    my $id = id $self;
    my $properties = shift;
    my $session = $self->session;
    $entryId{$id}           = $properties->{DataForm_entryId}
        if defined $properties->{DataForm_entryId};
    $userId{$id}            = $properties->{userId}
        if defined $properties->{userId};
    $username{$id}          = $properties->{username}
        if defined $properties->{username};
    $ipAddress{$id}         = $properties->{ipAddress}
        if defined $properties->{ipAddress};
    $submissionDate{$id}    = WebGUI::DateTime->new($session, $properties->{submissionDate})
        if defined $properties->{submissionDate};
    if (defined $properties->{entryData}) {
        if (ref $properties->{entryData} && ref $properties->{entryData} eq 'HASH') {
            $entryData{$id} = $properties->{entryData};
        }
        else {
            if (!eval { $entryData{$id} = JSON::from_json($properties->{entryData}); 1 } ) {
                $session->log->warn('DataForm entry ' . $entryId{$id} . ' has invalid data, ignoring');
            }
        }
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 user ( [ $user ] )

Returns the userId of the user who submitted this entry.

=head3 $user

An optional WebGUI::User object.  If passed, the userId and username will be
set from it for this entry.

=cut

sub user {
    my $self = shift;
    my $id = id $self;
    if (@_) {
        my $user = shift;
        if (!defined $user || !ref $user || !$user->isa('WebGUI::User')) {
            WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::User', got=>(ref $user), error=>'Need a user.');
        }
        $userId{$id} = $user->userId;
        $username{$id} = $user->username;
    }
    return $userId{$id};
}

#-------------------------------------------------------------------

=head2 userId ( [ $user ] )

Returns the userId of the user who submitted this entry.

=head3 $user

An optional WebGUI::User object.  If passed, the userId and username will be
set from it for this entry.

=cut

sub userId {
    my $self = shift;
    my $id = id $self;
    if (@_) {
        my $userId = shift;
        my $user = WebGUI::User->new($self->session, $userId);
        if (!defined $user) {
            WebGUI::Error::InvalidParam->throw(error=>$userId . ' is not a valud userId');
        }
        $userId{$id} = $userId;
        $username{$id} = $user->username;
    }
    return $userId{$id};
}

1;

