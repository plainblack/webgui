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

=cut

our $VERSION = '0.0.1';

use Moose;
use Scalar::Util qw/blessed/;
use WebGUI::Exception;
use WebGUI::DateTime;
use WebGUI::Asset::Wobject::DataForm;

#readonly    session         => my %session;
#readonly    assetId         => my %assetId;
#readonly    asset           => my %asset;

has session => (
    is       => 'ro',
    required => 1,
);

has submissionDate => (
    isa => 'WebGUI::DateTime',
    is  => 'rw',
);

has [ qw{assetId asset ipAddress} ] => (
    is => 'rw',
);

has userId => (
    is      => 'rw',
    builder => '_default_userId',
    lazy    => 1,
);
sub _default_userId {
    return shift->session->user->userId;
}

has username => (
    is      => 'rw',
    builder => '_default_username',
    lazy    => 1,
);
sub _default_username {
    return shift->session->user->username;
}

has entryData => (
    is => 'rw',
    default    => sub { return {}; },
    traits     => ['Hash', 'WebGUI::Definition::Meta::Property::Serialize',],
    isa        => 'WebGUI::Type::JSONHash',
    coerce     => 1,
);

around userId => sub {
    my $orig   = shift;
    my $self   = shift;
    if (my $userId = $_[0]) {
        my $user   = WebGUI::User->new($self->session, $userId);
        if (!defined $user) {
            WebGUI::Error::InvalidParam->throw(error=>$userId . ' is not a valud userId');
        }
        $self->username($user->username);
    }
    $self->$orig(@_);
};

has entryId => (
    is     => 'ro',
    writer => '_set_entryId',
);

#private     entryData       => my %entryData;
#private     entryId         => my %entryId;
#private     userId          => my %userId;
#readonly    username        => my %username;
#public      ipAddress       => my %ipAddress;
#public      submissionDate  => my %submissionDate;

#-------------------------------------------------------------------

=head2 delete 

Deletes this entry from the database. Returns true.

=cut

sub delete {
    my $self = shift;
    $self->session->db->deleteRow('DataForm_entry', 'DataForm_entryId', $self->getId);
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
    my $entryData = $self->entryData;
    if ( !exists $entryData->{ $field } ) {
        WebGUI::Error::InvalidParam->throw(error=>"cannot delete field that doesn't exist");
    }
    return delete $entryData->{$field};
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
    my $entryData = $self->entryData;
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
    my $entryData = $self->entryData;
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

    my $var = {
        DataForm_entryId    => $self->entryId,
        userId              => $self->userId,
        username            => $self->username,
        ipAddress           => $self->ipAddress,
        assetId             => $self->assetId,
        submissionDate      => $self->submissionDate->toDatabase,
        entryData           => $self->entryData,
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
    return $self->entryId;
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
        return $allRows if $_[0] && $_[0] eq 'rowCount';
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

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my ($asset, $entryId) = @_;
    my $session;
    my %properties;
    if (blessed $asset && $asset->isa('WebGUI::Asset::Wobject::DataForm')) {
        $session = $properties{session} = $asset->session;
        $properties{assetId} = $asset->getId;
        $properties{asset}   = $asset;
    }
    elsif (blessed $asset && $asset->isa('WebGUI::Session') && $entryId) {
        $session = $properties{session} = $asset;
        undef $asset;
    }
    else {
        WebGUI::Error::InvalidObject->throw(error=>'need a DataForm object or a session and entryId', got => ref $asset, expected => 'WebGUI::Asset::Wobject::DataForm');
    }
    if ($entryId) {
        %properties = %{ $session->db->getRow('DataForm_entry', 'DataForm_entryId', $entryId) };
        if (! defined $properties{'DataForm_entryId'}) {
            WebGUI::Error::ObjectNotFound->throw(error => 'no such DataForm_entryId', id => $entryId);
        }
        $properties{asset} = $asset = eval { WebGUI::Asset->newById($session, $properties{assetId}); };
        $properties{submissionDate} = WebGUI::DateTime->new($session, $properties{submissionDate});
    }
    else {
        $properties{user}           = ($session->user);
        $properties{ipAddress}      = ($session->request->address);
        $properties{submissionDate} = (WebGUI::DateTime->new($session, time));
        $properties{entryData}      = {};
    }
    return $class->$orig(%properties);
};

#----------------------------------------------------------------------------

=head2 newFromHash ( asset, properties )

=head2 newFromHash ( session, assetId, properties )

Create a new DataForm entry from the given properties.

=cut

sub newFromHash {
    my $class   = shift;
    my $asset   = shift;
    my $self;

    if ( blessed $asset && $asset->isa( 'WebGUI::Asset::Wobject::DataForm' ) ) {
        my $properties  = shift;
        $self           = $class->new( $asset );
        $self->setFromHash( $properties );
    } 
    elsif ( blessed $asset && $asset->isa( 'WebGUI::Session' ) ) {
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
    my $entryData = $self->entryData;
    if ( !exists $entryData->{ $oldField } ) {
        WebGUI::Error::InvalidParam->throw(error=>"cannot rename field that doesn't exist");
    }
    elsif ( exists $entryData->{ $newField } ) {
        WebGUI::Error::InvalidParam->throw(error=>'cannot rename field over existing field');
    }
    $entryData->{$newField} = delete $entryData->{$oldField};
    return $newField;
}

#-------------------------------------------------------------------

=head2 save 

Persists data from this entry into the db.

=cut

sub save {
    my $self = shift;
    my $entryData = $self->entryData;
    if (!$entryData || ref $entryData ne 'HASH') {
        $entryData = {};
    }
    my %dbData = (
        DataForm_entryId    => $self->entryId || 'new',
        userId              => $self->userId,
        username            => $self->username,
        ipAddress           => $self->ipAddress,
        assetId             => $self->assetId,
        submissionDate      => $self->submissionDate->toDatabase,
        entryData           => JSON::to_json($entryData),
    );
    my $newId = $self->session->db->setRow('DataForm_entry', 'DataForm_entryId', \%dbData);
    $self->_set_entryId($newId);
    return $newId;
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
    my $properties = shift;
    my $session = $self->session;
    $self->_set_entryId($properties->{DataForm_entryId}) if defined $properties->{DataForm_entryId};
    $self->userId(    $properties->{userId}    )         if defined $properties->{userId};
    $self->username(  $properties->{username}  )         if defined $properties->{username};
    $self->ipAddress( $properties->{ipAddress} )         if defined $properties->{ipAddress};
    $self->entryData( $properties->{entryData} )         if defined $properties->{entryData};

    $self->submissionDate(WebGUI::DateTime->new($session, $properties->{submissionDate}))
        if defined $properties->{submissionDate};

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
    my ($self) = shift;
    if (@_) {
        my $user = shift;
        if (!(blessed $user && $user->isa('WebGUI::User'))) {
            WebGUI::Error::InvalidObject->throw(expected=>'WebGUI::User', got=>(ref $user), error=>'Need a user.');
        }
        $self->username($user->username);
        $self->userId($user->userId);
    }
    return $self->userId;
}

1;
