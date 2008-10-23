package WebGUI::Flux::Modifier::DateTimeCompareToNow;
use strict;

use base 'WebGUI::Flux::Modifier';

=head1 NAME

Package WebGUI::Flux::Modifier::DateTimeCompareToNow

=head1 DESCRIPTION

Compares a DateTime to now()

See WebGUI::Flux::Modifier base class for more information.

=cut

#-------------------------------------------------------------------

=head2 evaluate

See WebGUI::Flux::Modifier base class for more information.

=cut

sub evaluate {
    my ($self) = @_;

    # Assemble the ingredients..
    my $units = $self->args()->{units};
    my $time_zone
        = ( $self->args()->{time_zone} eq 'user' )
        ? $self->user()->profileField("timeZone")
        : $self->args()->{time_zone};
    my $dt = $self->operand();

    # Convert everything to requested timezone prior to maths
    # Obviously, anything non-UTC could produce unintuitive results
    $dt->set_time_zone($time_zone);
    my $now = DateTime->now( time_zone => $time_zone );

    my $dur = $now->subtract_datetime($dt);

    return $dur->in_units($units);
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Modifier base class for more information.

=cut

sub definition {
    return { args => { units => 1, time_zone => 1 } };
}

1;
