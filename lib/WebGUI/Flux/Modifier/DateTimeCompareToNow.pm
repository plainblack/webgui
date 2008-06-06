package WebGUI::Flux::Modifier::DateTimeCompareToNow;
use strict;
use warnings;

use base 'WebGUI::Flux::Modifier';

=head1 NAME

Package WebGUI::Flux::Modifier::DateTimeCompareToNow

=head1 DESCRIPTION

Compares a DateTime to now()

See WebGUI::Flux::Modifier base class for more information.

=cut

#-------------------------------------------------------------------

sub execute {
    my ($arg_ref) = @_;

    my $units     = $arg_ref->{args}{units};
    my $time_zone = $arg_ref->{args}{time_zone};
    my $dt        = $arg_ref->{operand};

    # Convert everything to UTC prior to maths
    $dt->set_time_zone('UTC');
    my $now = DateTime->now( time_zone => 'UTC' );

    my $dur = $now->subtract_datetime($dt);
    return $dur->in_units($units);
}

#-------------------------------------------------------------------

=head3 getArgs

This Modifier requies the following arguments

=head4 value

The simple string to be returned

=cut

sub getArgs {
    return {
        units     => { type => 'string' },
        time_zone => { type => 'string' },
    };
}

1;
