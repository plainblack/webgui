package WebGUI::Flux::Operand::AssetId;
use strict;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::AssetId

=head1 DESCRIPTION

Returns the assetId of the asset for which the Flux rule is being evaluated for

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

=head2 evaluate

See WebGUI::Flux::Operand base class for more information.

=cut

sub evaluate {
    my ($self) = @_;

    return $self->rule()->evaluatingForAssetId();
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Operand base class for more information.

=cut

sub definition {
    return { args => {} };
}

1;
