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

sub execute {
    my ($arg_ref) = @_;

    my $pattern  = $arg_ref->{args}{pattern};
    my $time_zone = $arg_ref->{args}{time_zone};
    my $dt       = $arg_ref->{operand}->set_time_zone($time_zone);
    return $dt->strftime($pattern);
}

#-------------------------------------------------------------------

=head3 getArgs

This Modifier requies the following arguments

=head4 value

The simple string to be returned

=cut

sub getArgs {
    return {
        pattern  => { type => 'string' },
        time_zone => { type => 'string' },
    };
}

1;
