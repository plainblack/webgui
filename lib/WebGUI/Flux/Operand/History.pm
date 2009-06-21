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
        my $latest
            = $self->session->db->quickScalar(
            "select max(dateCreated) from $table where historyEventId = ? and userId = ?",
            [ $historyEventId, $userId ] );
        push( @constraints, { 'dateCreated > ?' => $latest } ) if $latest;
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
