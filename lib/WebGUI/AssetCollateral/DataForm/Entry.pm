package WebGUI::AssetCollateral::DataForm::Entry;
use strict;

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
sub delete {
    my $self = shift;
    $self->session->db->deleteRow('DataForm_entry', 'DataForm_entryId', $self->getId);
    delete $entryId{ id $self };
    return 1;
}

#-------------------------------------------------------------------
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
sub getId {
    my $self = shift;
    return $entryId{ id $self };
}

#-------------------------------------------------------------------
sub iterateAll {
    my $class = shift;
    my $asset = shift;
    my $sth = $asset->session->dbSlave->read("SELECT `DataForm_entryId`, `userId`, `username`, `ipAddress`, `submissionDate`, `entryData` FROM `DataForm_entry` WHERE `assetId` = ? ORDER BY `submissionDate` DESC", [$asset->getId]);
    my $sub = sub {
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
            $asset{$id} = WebGUI::Asset::Wobject::DataForm->new($session, $properties->{assetId});
        }
        $self->setFromHash($properties);
    }
    else {
        $self->user($session->user);
        $self->ipAddress($session->env->getIp);
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
        $asset          = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        $self           = $class->new( $asset );
        $self->setFromHash( $properties );
    }

    return $self;
}

#-------------------------------------------------------------------
sub purgeAssetEntries {
    my $class = shift;
    my $asset = shift;
    $asset->session->db->write("DELETE FROM `DataForm_entry` WHERE `assetId`=?", [$asset->getId]);
    return 1;
}

#-------------------------------------------------------------------
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
    $entryData->{$newField} = delete $entryData{$newField};
    return $newField;
}

#-------------------------------------------------------------------
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

