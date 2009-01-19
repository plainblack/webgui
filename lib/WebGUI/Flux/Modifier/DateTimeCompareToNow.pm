package WebGUI::Flux::Modifier::DateTimeCompareToNow;
use strict;

use base 'WebGUI::Flux::Modifier';
use DateTime;

=head1 NAME

Package WebGUI::Flux::Modifier::DateTimeCompareToNow

=head1 DESCRIPTION

Compares a DateTime to now(). 

The semantics are compatible with Perl's sort() function; it returns -1 if $dt < now, 0 if $dt == now, 1 if $dt > now.

The duration is added to dt prior to comparison, in whatever units and timezone you specify.

Units must be one of: nanoseconds, seconds, minutes, hours, weeks, months, years

Timezone can be something like 'Australia/Melbourne', or 'user' to use the user's timezone.

You might be wondering why this module lets you add a duration to the datetime prior to comparison. The reason is
that you can't subtract two dates and then freely convert the resulting DateTime::Duration object into whatever unit
you like (see "How Date Math Is Done" in the DateTime docs for more details). Instead, you use the duration/units/timezone
arguments to construct a DateTime::Duration object that is added to your datetime, and then check whether the resulting 
comparison with now is <, = or > than 0.

For example, say you want to contruct a flux rule that evaluates to true for users that are > 18 years old.
Operand1 would obviously be UserProfileField(birthdate). Using this module as the Modifier, you would specify:
 delta => 18, units => years, timezone => user
And then for Operator you'd use IsEqualTo and for Operand2 NumericValue(-1) (negative because you want it to be true when now() > dt)  

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
    my $duration = $self->args()->{duration};
    my $dt = $self->operand()->clone; # clone in case client code is still using $dt
    
    # Convert $dt to UTC prior to adding duration
    my $time_zone
        = ( $self->args()->{time_zone} eq 'user' )
        ? $self->user()->profileField("timeZone")
        : $self->args()->{time_zone};
    $dt->set_time_zone($time_zone) if $time_zone;
    
    # Add duration to $dt (arguments to DateTime->add() are used to construct a DateTime::Duration object) 
    $dt->add( $units => $duration);
    
    # Do the comparison
    return DateTime->compare($dt, DateTime->now);
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Modifier base class for more information.

=cut

sub definition {
    return { args => { units => 1, time_zone => 1, duration => 1 } };
}

1;
