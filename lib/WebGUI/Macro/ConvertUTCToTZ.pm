package WebGUI::Macro::ConvertUTCToTZ;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use DateTime;
use DateTime::Format::Strptime;
use WebGUI::DateTime;

=head1 NAME

Package WebGUI::Macro::ConvertUTCToTZ

=head1 DESCRIPTION

Take input of any full timezone string, format, YYYY-MM-DD, HH:MM:SS
and convert it from UTC to the designated timezone when a time component is provided.

Without a time component, will return UTC date at midnight.

=head2 process( $session, $toTZ, $format, $date, $time )

=over 4

=item *

A session variable

=item *

toTZ - any DateTime::TimeZone TZ designation (e.g. 'Chicago/America', '+630', etc.)
  (if not set, will default to user's currently configured timezone)

=item *

format - perl DateTime format string
  (if not set, will default to user's currently configured dateFormat preference)

=item *

date - Date component formatted as YYYY-MM-DD

=item *

time - time component formatted as HH:MM:SS

=back

=cut

#-------------------------------------------------------------------
sub process {
    my ( $session, $toTZ, $format, $date, $time ) = @_;

    my $uTZ     = 'UTC';
    my $uFormat = '%F %T';

    # Change defaults only if we have a user defined and they have these set.
    eval { $session->user };
    unless ($@) {
        $uTZ     = $session->user->profileField("timeZone");
        $uFormat = $session->user->profileField("dateFormat");
    }
    
    $toTZ   ||= $uTZ;
    $format ||= $uFormat;

    # remove all whitespace including newlines
    $date =~ s/\s//msg;

    # Additional date delimiters accepted for edge cases
    my ( $year, $month, $day ) = split /[\/\-\.]/, $date;

    my $dt = WebGUI::DateTime->now;

    unless ( length($year) ) {
        $year = $dt->year;
    }

    unless ( length($month) ) {
        $month = $dt->month;
    }

    unless ( length($day) ) {
        $day = $dt->day;
    }

    my $formatter = DateTime::Format::Strptime->new( pattern => $format );

    # Macro calls also seem to include any spaces between commas
    $time =~ s/^\s+//msg;

    my ( $hour, $minute, $second );
    if ( length($time) ) {
        ( $hour, $minute, $second ) = split /\:/, $time;
    }
    my $dtOut = DateTime->new(
        year      => $year,
        month     => $month,
        day       => $day,
        hour      => $hour || 0,
        minute    => $minute || 0,
        second    => $second || 0,
        time_zone => 'UTC',
    );

    # If no time component, we use the date as provided with no conversion
    #   Without a time to convert between, there is no point to altering the date
    if ( length($time) ) {
        $dtOut->set_time_zone($toTZ);
    }
    $dtOut->set_formatter($formatter);

    # Stringify output
    return "" . $dtOut;

}

1;

#vim:ft=perl

