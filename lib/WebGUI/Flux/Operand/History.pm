package WebGUI::Flux::Operand::History;
use strict;
use base 'WebGUI::Flux::Operand';
use WebGUI::History;
use Params::Validate qw(:all);

=head1 NAME

Package WebGUI::Flux::Operand::History

=head1 DESCRIPTION

Returns WebGUI::WebFlow::History object for user 

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ($self) = @_;

    my $user                   = $self->rule()->evaluatingForUser();
    my $userId                 = $user->userId;
    my $historyEventId         = $self->args->{historyEventId};
    my $afterAllHistoryEventId = $self->args->{afterAllHistoryEventId};
    my $assetId                = $self->args->{assetId};

    $self->session->log->debug( "Checking history event $historyEventId for user: " . $userId );

    my @constraints;
    push @constraints, { 'userId = ?'         => $user->userId };
    push @constraints, { 'historyEventId = ?' => $historyEventId } if $historyEventId;
    push @constraints, { 'assetId = ?'        => $assetId } if $assetId;

    if ($afterAllHistoryEventId) {
        
        my $table = WebGUI::History->crud_getTableName( $self->session );
        
        # Use Sequence Number rather than dateCreated - works better for tests that create >1 event in 1 sec
        # Must have a sequenceNumber greater than highest sequenceNumber for afterAllHistoryEventId event (for user)
        my ($sequenceNumber)
            = $self->session->db->quickScalar(
            "select max(sequenceNumber) from $table where historyEventId = ? and userId = ?",
            [ $afterAllHistoryEventId, $userId ] );
            
        if ($sequenceNumber) {
            $self->session->log->debug("Adding sequenceNumber constraint: $sequenceNumber for event $afterAllHistoryEventId userId $userId");
            push( @constraints, { 'sequenceNumber > ?' => $sequenceNumber } );
        }
    }

    my @ids = @{ WebGUI::History->getAllIds(
            $user->session,
            {   constraints => \@constraints,

                #            dataSuperHashOf        => $self->args->{dataSuperHashOf},
            }
        )
        };
    return unless @ids;
    return @ids;
}

#-------------------------------------------------------------------

sub definition {
    return {
        args => {
            historyEventId         => 0,
            dataSuperHashOf        => { type => HASHREF, optional => 1 },
            afterAllHistoryEventId => 0,
            assetId                => 0,
        }
    };
}
1;
