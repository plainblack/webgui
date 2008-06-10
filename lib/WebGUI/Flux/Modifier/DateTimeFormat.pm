package WebGUI::Flux::Modifier::DateTimeFormat;
use strict;
use warnings;

use base 'WebGUI::Flux::Modifier';

=head1 NAME

Package WebGUI::Flux::Modifier::DateTimeFormat

=head1 DESCRIPTION

When Formatted As

See WebGUI::Flux::Modifier base class for more information.

=cut

#-------------------------------------------------------------------

sub evaluate {
    my ($self) = @_;

    # Assemble the ingredients..
    my $pattern     = $self->args()->{pattern};
    my $time_zone
        = ( $self->args()->{time_zone} eq 'user' )
        ? $self->user()->profileField("timeZone")
        : $self->args()->{time_zone};
    my $dt       = $self->operand()->set_time_zone($time_zone);
    return $dt->strftime($pattern);
}

#-------------------------------------------------------------------

sub definition {
    return { args => { pattern => 1, time_zone => 1 } };
}

1;
