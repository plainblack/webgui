package WebGUI::Asset::Event;

use strict;

our $VERSION = "0.0.0";

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Tie::IxHash;
use Carp qw(croak);

use WebGUI::International;
use WebGUI::Asset::Template;
use WebGUI::Form;
use WebGUI::Storage;
use Test::Deep::NoTest qw(eq_deeply);
use DateTime::Event::ICal;
use DateTime::Set;

use base 'WebGUI::Asset';

use WebGUI::DateTime;



=head1 NAME

WebGUI::Asset::Event

=head1 DESCRIPTION

Package to handle events.


=head1 METHODS

=cut

####################################################################

=head2 addRevision ( )

Extent the method from the super class to handle iCalSequenceNumbers.

=cut

sub addRevision {
    my $self = shift;
    my $newRev = $self->SUPER::addRevision(@_);
    my $sequenceNumber = $newRev->get('iCalSequenceNumber');
    if (defined $sequenceNumber) {
        $sequenceNumber++;
    }
    else {
        $sequenceNumber = 0;
    }
    $newRev->update({iCalSequenceNumber => $sequenceNumber});
    if ($newRev->get("storageId") && $newRev->get("storageId") eq $self->get('storageId')) {
        my $newStorage = WebGUI::Storage->get($self->session,$self->get("storageId"))->copy;
        $newRev->update({storageId => $newStorage->getId});
    }
    return $newRev;
}

{

my %dayNamesToICal = (
    m => 'mo',
    t => 'tu',
    w => 'we',
    r => 'th',
    f => 'fr',
    s => 'sa',
    u => 'su',
);

my %weekNamesToICal = (
    first  => 1,
    second => 2,
    third  => 3,
    fourth => 4,
    fifth  => -1,
);

my %monthNamesToICal = (
    jan => 1,
    feb => 2,
    mar => 3,
    apr => 4,
    may => 5,
    jun => 6,
    jul => 7,
    aug => 8,
    sep => 9,
    oct => 10,
    nov => 11,
    dec => 12,
);

####################################################################

=head2 dateSet ( recur, start, end )

Produces a DateTime::Set for the given recurrence (see getRecurrence) spanning
from start to end (DateTime objects).  End is only required if the recurrence
does not have an 'endAfter'.  This can be called as a class or object method.

=cut

sub dateSet {
    my ($self, $recur, $start, $end) = @_;

    my $type = $recur->{recurType};
    my $interval = $recur->{every};
    $end or my $count = $recur->{endAfter} or croak('No end for dateSet');

    # The "every n weekdays" concept isn't supported in ical lingo.
    if ($type eq 'weekday') {
        my $i      = 0;
        my $weeks  = int($interval / 5);
        my $days   = $interval % 5;
        my $d      = $start->clone;
        my @dates  = ();
        my $c = $end ? sub { $d < $end } : sub { $i++ < $count };
        while ($c->()) {
            my $dw = $d->dow;
            my $n  = $days;
            if ($dw == 6) {
                $n++;
            } elsif ($n + $dw > 5) {
                $n += 2;
            }
            $d->add(weeks => $weeks, days => $n);
            push(@dates, $d->clone);
        }
        return DateTime::Set->from_datetimes(dates => \@dates);
    }

    my %a = (
        dtstart  => $start,
        interval => $interval,
    );
    if ($end) {
        $a{until} = $end;
    }
    else {
        $a{count} = $count;
    }

    my $daynames = [
        map { $dayNamesToICal{$_} }
        @{ $recur->{dayNames} }
    ];

    my $weeknos = [
        map { $weekNamesToICal{$_} }
        @{ $recur->{weeks} }
    ];

    my $monthnos = [
        map { $monthNamesToICal{$_} }
        @{ $recur->{months} }
    ];

    my $day = [ $recur->{dayNumber} ];

    {
        daily     => sub {
            $a{freq} = 'daily';
        },
        weekly    => sub {
            $a{freq}  = 'weekly';
            $a{byday} = $daynames,
        },
        monthDay  => sub {
            $a{freq}       = 'monthly';
            $a{bymonthday} = $day;
        },
        monthWeek => sub {
            $a{freq}     = 'monthly';
            $a{byday}    = $daynames;
            $a{bysetpos} = $weeknos;
        },
        yearDay   => sub {
            $a{freq}       = 'yearly';
            $a{bymonth}    = $monthnos;
            $a{bymonthday} = $day;
        },
        yearWeek  => sub {
            $a{freq}     = 'yearly';
            $a{bymonth}  = $monthnos;
            $a{byday}    = $daynames;
            $a{bysetpos} = $weeknos;
        },
    }->{$type}->();
    return DateTime::Event::ICal->recur(%a);
}

}

####################################################################

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;

    my $i18n        = WebGUI::International->new($session, 'Asset_Event');
    my $dt          = WebGUI::DateTime->new($session, time);

    ### Set up list options ###



    ### Build properties hash ###
    my %properties;
    tie %properties, 'Tie::IxHash';
    %properties = (

        ##### DEFAULTS #####
        'description' => {
            fieldType       => "HTMLArea",
            defaultValue    => "",
        },
        'startDate' => {
            fieldType       => "Date",
            defaultValue    => $dt->toMysqlDate,
        },
        'endDate' => {
            fieldType       => "Date",
            defaultValue    => $dt->toMysqlDate,
        },
        'startTime' => {
            fieldType       => "TimeField",
            defaultValue    => undef,
            format          => 'mysql',
        },
        'endTime' => {
            fieldType       => "TimeField",
            defaultValue    => undef,
            format          => 'mysql',
        },

        'recurId' => {
            fieldType       => "Text",
            defaultValue    => undef,
        },

        'location' => {
            fieldType       => "Text",
            defaultValue    => undef,
        },
        'feedId' => {
            fieldType       => "Text",
            defaultValue    => undef,
        },
        'storageId' => {
            fieldType       => "Image",
            defaultValue    => '',
            maxAttachments  => 1,
        },
        'feedUid' => {
            fieldType       => "Text",
            defaultValue    => undef,
        },
        'timeZone' => {
            fieldType       => 'TimeZone',
        },
        sequenceNumber => {
            fieldType       => 'hidden',
        },
        iCalSequenceNumber => {
            fieldType       => 'hidden',
        },
    );


    ### Add user defined fields
    for my $num (1..5) {
        $properties{"userDefined".$num} = {
            fieldType       => "text",
            defaultValue    => "",
        };
    }


    push(@{$definition}, {
        assetName   => $i18n->get('assetName'),
        icon        => 'calendar.gif',
        tableName   => 'Event',
        className   => 'WebGUI::Asset::Event',
        properties  => \%properties
    });

    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

sub duration {
    my $self  = shift;
    return $self->getDateTimeEnd - $self->getDateTimeStart;
}

#-------------------------------------------------------------------

=head2 canAdd ( session )

Class method to verify that the user has the privileges necessary to add this type of asset. Return a boolean.

=head3 session

The session variable.

=cut

sub canAdd {
	my $class = shift;
	my $session = shift;
	$class->SUPER::canAdd($session, undef, '7');
}


####################################################################

=head2 canEdit ( [userId] )

Returns true if the given userId can edit this asset. If userId is not given,
the userId of the current session is used.

Users can edit this event if they are the owner of the event, or if they are
allowed to edit the parent Calendar.

=cut

sub canEdit {
    my $self    = shift;
    my $userId  = shift;

    if ( !$userId ) {
        $userId     = $self->session->user->userId;
    }

    return 1 if ( $userId eq $self->get('ownerUserId') );
    return $self->getParent->canEdit( $userId );
}

#-------------------------------------------------------------------

=head2 generateRecurrence (date)

Creates an recurrence event in the parent calendar for the given date

=cut

sub generateRecurrence {
    my ($self, $start) = @_;
    my $end = $start + $self->duration;
    my ($sdb, $edb) = map { $_->ymd } ($start, $end);

    # Only generate if the recurId does not exist on this day
    my $sql = q{
        SELECT COUNT(*)
        FROM   Event
        WHERE  recurId = ? AND startDate = ?
    };
    my $db = $self->session->db;
    unless ($db->quickScalar($sql, [$self->get('recurId'), $sdb])) {
        my $child = $self->get;
        $child->{startDate} = $sdb;
        $child->{endDate}   = $edb;
        $self->getParent->addChild(
            $child, undef, undef, { skipAutoCommitWorkflows => 1 }
        );
    }
}

####################################################################

=head2 generateRecurringEvents()

Generates Events according to this Event's recurrence pattern.

=cut

sub generateRecurringEvents {
    my $self    = shift;
    my $recur   = $self->getRecurrence or croak(
        'Cannot generate recurring events: Event has no recurrence pattern.'
    );

    my $rstart = WebGUI::DateTime->new($self->session, $recur->{startDate});
    my $rend   = !$recur->{endAfter} && $self->limitedEndDate($rstart->clone->add(years => 2));
    my $i      = $self->dateSet($recur, $rstart, $rend)->iterator;

    while (my $d = $i->next) {
        $self->generateRecurrence($d);
    }

    return $recur->{recurId};
}

####################################################################

=head2 getAutoCommitWorkflowId

Gets the WebGUI::VersionTag workflow to use to automatically commit Events.
By specifying this method, you activate this feature.

=cut

sub getAutoCommitWorkflowId {
    my $self = shift;
    my $parent = $self->getParent;
    if ($parent->hasBeenCommitted) {
        return $parent->get('workflowIdCommit')
            || $self->session->setting->get('defaultVersionTagWorkflow');
    }
    return undef;
}





####################################################################

=head2 getDateTimeStart

Returns a WebGUI::DateTime object based on the startDate and startTime values,
adjusted for the current user's time zone.

If this is an all-day event, the start time is 00:00:00 and the timezone is not
adjusted.

=cut

sub getDateTimeStart {
    my $self    = shift;
    my $date    = $self->get("startDate");
    my $time    = $self->get("startTime");
    my $tz      = $self->session->datetime->getTimeZone;

    #$self->session->errorHandler->warn($self->getId.":: Date: $date -- Time: $time");
    if (!$date) {
        $self->session->errorHandler->warn("Event::getDateTimeStart -- This event (".$self->get("assetId").") has no start date.");
        return undef;
    }

    if ($time) {
        my $dt    = WebGUI::DateTime->new($self->session, $date." ".$time);
        $dt->set_time_zone($tz);
        return $dt;
    }
    else {
        my $dt    = WebGUI::DateTime->new($self->session, $date." 00:00:00");
        return $dt;
    }
}





####################################################################

=head2 getDateTimeEnd

Returns a WebGUI::DateTime object based on the endDate and endTime values,
adjusted for the current user's time zone.

If this is an all-day event, the end time is 23:59:59 and the timezone is not
adjusted.

=cut

sub getDateTimeEnd {
    my $self    = shift;
    my $date    = $self->get("endDate");
    my $time    = $self->get("endTime");
    my $tz      = $self->session->datetime->getTimeZone;

    #$self->session->errorHandler->warn($self->getId.":: Date: $date -- Time: $time");
    if (!$date) {
        $self->session->errorHandler->warn("Event::getDateTimeEnd -- This event (".$self->get("assetId").") has no end date.");
        return undef;
    }

    if ($time) {
        my $dt    = WebGUI::DateTime->new($self->session, $date." ".$time);
        $dt->set_time_zone($tz);
        return $dt;
    }
    else {
        my $dt    = WebGUI::DateTime->new($self->session, $date." 23:59:59");
        return $dt;
    }
}

####################################################################

=head2 getDateTimeEndNI

Since the iCal standard is that ending dates are non-inclusive (they
do not include the second at the end of the time period), this method
provide a copy of the DateTime object that is 1 second earlier than
the set ending time.  If the event has no ending time, then the ending
time is 1 second before midnight.

It's just one line of DateTime code to adjust this on any object, but
this is encapsulated here to make sure that the same amount of time
is used EVERYWHERE.

=cut

sub getDateTimeEndNI {
    my $self = shift;
    my $dt   = $self->getDateTimeEnd;
    if ($self->get('endTime') ) {
        $dt->subtract(seconds => 1);
    }
    return $dt;
}





####################################################################

=head2 getEventNext

Gets the event that occurs after this event in the calendar. Returns the
Event object.

=cut

sub getEventNext {
    my $self    = shift;
    my $db      = $self->session->db;

    my $where   = 'Event.startDate > "'.$self->get("startDate").'"'
                . '|| (Event.startDate = "'.$self->get("startDate").'" && ';

    # All day events must either look for null time or greater than 00:00:00
    if ($self->isAllDay) {
        $where  .= "((Event.startTime IS NULL "
                . "&& assetData.title > ".$db->quote($self->get("title")).") "
                . "|| Event.startTime >= '00:00:00')";
    }
    # Non all-day events must look for greater than time
    else {
        $where  .= "((Event.startTime = '".$self->get("startTime")."' "
                . "&& assetData.title > ".$db->quote($self->get("title")).")"
                . "|| Event.startTime > '".$self->get("startTime")."')";
    }
    $where    .= ")";


    my @orderByColumns = (
        'Event.startDate',
        'Event.startTime',
        'Event.endDate',
        'Event.endDate',
        'assetData.title',
        'assetData.assetId',
    );

    my $events = $self->getLineageIterator(['siblings'], {
        includeOnlyClasses  => ['WebGUI::Asset::Event'],
        joinClass           => 'WebGUI::Asset::Event',
        orderByClause       => join(",", @orderByColumns),
        whereClause         => $where,
        limit               => 1,
    });

    my $nextEvent;
    eval { $nextEvent = $events->() };
    if ( WebGUI::Error->caught('WebGUI::Error::ObjecNotFound') ) {
        return undef; # Normal error
    }
    return $nextEvent;
}






####################################################################

=head2 getEventPrev

Gets the event that occurs before this event in the calendar. Returns the Event
object.

=cut

sub getEventPrev {
    my $self    = shift;
    my $db      = $self->session->db;

    my $where   = 'Event.startDate < "'.$self->get("startDate").'"'
                . '|| (Event.startDate = "'.$self->get("startDate").'" && ';

    # All day events must either look for null time or greater than 00:00:00
    if ($self->isAllDay) {
        $where  .= "(Event.startTime IS NULL "
                . "&& assetData.title < ".$db->quote($self->get("title")).")";
    }
    # Non all-day events must look for greater than time
    else {
        $where  .= "((Event.startTime = '".$self->get("startTime")."' "
                . "&& assetData.title < ".$db->quote($self->get("title")).")"
                . "|| Event.startTime < '".$self->get("startTime")."')";
    }
    $where    .= ")";

    my @orderByColumns = (
        'Event.startDate DESC',
        'Event.startTime DESC',
        'Event.endDate DESC',
        'Event.endDate DESC',
        'assetData.title DESC',
        'assetData.assetId DESC',
    );

    my $events    = $self->getLineageIterator(['siblings'], {
                includeOnlyClasses  => ['WebGUI::Asset::Event'],
                joinClass           => 'WebGUI::Asset::Event',
                orderByClause       => join(",",@orderByColumns),
                whereClause         => $where,
                limit               => 1,
            });

    my $prevEvent;
    eval { $prevEvent = $events->() };
    if ( WebGUI::Error->caught( 'WebGUI::Error::ObjectNotFound' ) ) {
        return undef; # Normal error
    }
    return $prevEvent;
}





####################################################################

=head2 getIcalStart

If this event is an all-day event, gets an iCalendar (RFC 2445) Date string, not
adjusted for time zone.
.
Otherwise returns an iCalendar Date/Time string in the UTC time zone.

=cut

sub getIcalStart {
    my $self    = shift;

    if ($self->isAllDay) {
        my $date = $self->get("startDate");
        $date =~ s/\D//g;
        return $date;
    }
    else {
        my $date = $self->get("startDate");
        my $time = $self->get("startTime");

        $date =~ s/\D//g;
        $time =~ s/\D//g;

        return $date."T".$time."Z";
    }
}





####################################################################

=head2 getIcalEnd

If this event is an all-day event, gets an iCalendar (RFC 2445) Date string, not
adjusted for time zone.
.
Otherwise returns an iCalendar Date/Time string in the UTC time zone.

=cut

sub getIcalEnd {
    my $self    = shift;

    if ($self->isAllDay) {
        my $dte  = $self->getDateTimeEnd->add(days => 1);
        my $date = $dte->toIcalDate;
        return $date;
    }
    else {
        my $date = $self->get("endDate");
        my $time = $self->get("endTime");

        $date =~ s/\D//g;
        $time =~ s/\D//g;

        return $date."T".$time."Z";
    }
}





####################################################################

=head2 getRecurrence

Returns a hashref of recurrence information. Some of the keys are only
relevant to certain recurrence types.

B<NOTE: This hash IS GOING TO CHANGE after iCalendar recurrence patterns are
implemented using DateTime::Event::ICal, so DO NOT RELY ON THEM. This holds
true for getRecurrenceFromForm() and setRecurrence().>

=over 8

=item recurType

The recurrence type (daily, weekdays, weekly, monthDay, monthWeek, yearDay,
yearWeek)

=item startDate

The MySQL date to start creating recurring events

=item endDate

The MySQL date to end creating recurring events. If either this or endAfter does
not exist, the event recurs forever.

=item endAfter

The number of occurences this event ends after. If neither this nor endDate
exists, the event recurs forever.

=item every

The number of (days, weeks, months, years) between each recurrence.

=item dayNames

A list of day names that this event recurs on.

 u    - Sunday
 m    - Monday
 t    - Tuesday
 w    - Wednesday
 r    - Thursday
 f    - Friday
 s    - Saturday

=item dayNumber

The day number that this event recurs on

=item weeks

A list of weeks that this event recurs on

 first
 second
 third
 fourth
 last

=item months

A list of months that this event recurs on

 jan    - January
 feb    - February
 mar    - March
 apr    - April
 may    - May
 jun    - June
 jul    - July
 aug    - August
 sep    - September
 oct    - October
 nov    - November
 dec    - December

=back

=cut

sub getRecurrence {
    my $self = shift;
    return undef unless $self->get("recurId");

    return $self->{recurrence} ||= do {
        #use Data::Dumper;
        #$self->session->errorHandler->warn("recurId: ".$self->get("recurId"));

        my %data
            = $self->session->db->quickHash(
                "select * from Event_recur where recurId=?",
                [$self->get("recurId")]
            );

        my %recurrence = (
            recurType    => $data{recurType},
        );


        # We do not need the recurId, and in fact will screw up our later comparisons
        delete $data{"recurId"};

        my $type        = lc $data{"recurType"};
        if ($type eq "daily" || $type eq "weekday") {
            $recurrence{every}     = $data{pattern};
        }
        elsif ($type eq "weekly") {
            #(\d+) ([umtwrfs]+)
            $data{pattern}          =~ /(\d+) ([umtwrfs]+)/;
            $recurrence{every}      = $1;
            $recurrence{dayNames}   = [split //, $2];
        }
        elsif ($type eq "monthweek") {
            #(\d+) (first,second,third,fourth,last) ([umtwrfs]+)
            $data{pattern}          =~ /(\d+) ([a-z,]+) ([umtwrfs]+)/;
            $recurrence{every}      = $1;
            $recurrence{weeks}      = [split /,/, $2];
            $recurrence{dayNames}   = [split //, $3];
        }
        elsif ($type eq "monthday") {
            #(\d+) on (\d+)
            $data{pattern}          =~ /(\d+) (\d+)/;
            $recurrence{every}      = $1;
            $recurrence{dayNumber}  = $2;
        }
        elsif ($type eq "yearweek") {
            #(\d+) (first,second,third,fourth,last) ([umtwrfs]+)? (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
            $data{pattern}          =~ /(\d+) ([a-z,]+) ([umtwrfs]+) ([a-z,]+)/;
            $recurrence{every}      = $1;
            $recurrence{weeks}      = [split /,/, $2];
            $recurrence{dayNames}   = [split //, $3];
            $recurrence{months}     = [split /,/, $4];
        }
        elsif ($type eq "yearday") {
            #(\d+) on (\d+) (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
            $data{pattern}          =~ /(\d+) (\d+) ([a-z,]+)/;
            $recurrence{every}      = $1;
            $recurrence{dayNumber}  = $2;
            $recurrence{months}     = [split /,/, $3];
        }

        $recurrence{startDate} = $data{startDate};
        if ($data{endDate} && $data{endDate} =~ /^after (\d+)/i) {
            $recurrence{endAfter}   = $1;
        }
        elsif ($data{endDate}) {
            $recurrence{endDate}    = $data{endDate};
        }

        \%recurrence;
    };
}


####################################################################

=head2 getRecurrenceDates ()

DEPRECATED.  Gets a series of dates in this event's recurrence pattern.  This
is now implemented in terms of the dateSet method, which is what you should be
using.  This method remains for backwards compatibility.

=cut

sub getRecurrenceDates {
    my $self  = shift;
    my $recur = $self->getRecurrence;
    return undef unless $recur && $recur->{recurType};

    my $start = WebGUI::DateTime->new($self->session, "$recur->{startDate} 00:00:00");

    my $end = $recur->{endDate} && WebGUI::DateTime->new($self->session,
        "$recur->{endDate} 00:00:00");

    # Set an end for events with no end
    # TODO: Get the maintainRecurrenceOffset value
    if (!$recur->{endDate} && !$recur->{endAfter}) {
        $end = $start->clone->add(years=>2);
    }

    return
        map { $_->strftime('%F') }
        $self->dateSet($recur, $start, $end)->as_list;
}

####################################################################

=head2 getRecurrenceFromForm

Returns a recurrence hashref based on the form parameters.

The hash keys are the same as getRecurrence.

=cut

sub getRecurrenceFromForm {
    my $self    = shift;
    my $form    = $self->session->form;

    my %recurrence        = ();
    my $type        = lc $form->param("recurType");

    return undef unless ($type && $type !~ /none/i);

    if ($type eq "daily") {
        if (lc($form->param("recurSubType")) eq "weekday") {
            $recurrence{recurType}    = "weekday";
        }
        else {
            $recurrence{recurType}    = "daily";
        }

        $recurrence{every} = $form->param("recurDay");
    }
    elsif ($type eq "weekly") {
        $recurrence{recurType} = "weekly";
        $recurrence{dayNames} = [$form->param("recurWeekDay")];
        $recurrence{every} = $form->param("recurWeek");
    }
    elsif ($type eq "monthly") {
        if (lc($form->param("recurSubType")) eq "monthweek") {
            $recurrence{recurType} = "monthWeek";
            $recurrence{weeks} = [$form->param("recurMonthWeekNumber")];
            $recurrence{dayNames} = [$form->param("recurMonthWeekDay")];
        }
        elsif (lc($form->param("recurSubType")) eq "monthday") {
            $recurrence{recurType} = "monthDay";
            $recurrence{dayNumber} = $form->param("recurMonthDay");
        }

        $recurrence{every} = $form->param("recurMonth");
    }
    elsif ($type eq "yearly") {
        if (lc($form->param("recurSubType")) eq "yearweek") {
            $recurrence{recurType} = "yearWeek";
            $recurrence{weeks} = [$form->param("recurYearWeekNumber")];
            $recurrence{dayNames} = [$form->param("recurYearWeekDay")];
            $recurrence{months} = [$form->param("recurYearWeekMonth")];
        }
        elsif (lc($form->param("recurSubType")) eq "yearday") {
            $recurrence{recurType} = "yearDay";
            $recurrence{dayNumber} = $form->param("recurYearDay");
            $recurrence{months} = [$form->param("recurYearDayMonth")];
        }

        $recurrence{every} = $form->param("recurYear");
    }

    $recurrence{every} ||= 1;
    $recurrence{startDate} = $form->param("recurStart");

    if (lc $form->param("recurEndType") eq "date") {
        $recurrence{endDate} = $form->param("recurEndDate");
    }
    elsif (lc $form->param("recurEndType") eq "after") {
        $recurrence{endAfter} = $form->param("recurEndAfter");
    }

    return \%recurrence;
}





####################################################################

=head2 getRelatedLinks

Gets an arrayref of hashrefs of related links.

=cut

sub getRelatedLinks {
    my $self    = shift;

    my $sth
        = $self->session->db->prepare(
            "SELECT * FROM Event_relatedlink WHERE assetId=? ORDER BY sequenceNumber",
        );
    $sth->execute([ $self->getId ]);

    my @links;
    while ( my $link = $sth->hashRef ) {
        next unless $self->session->user->isInGroup( $link->{ groupIdView } );
        push @links, $link;
    }

    return \@links;
}

#-------------------------------------------------------------------

=head2 getStorageLocation ( )

Get the storage location associated with this Event.

=cut

sub getStorageLocation {
    my $self = shift;
    unless (exists $self->{_storageLocation}) {
        if ($self->get("storageId") eq "") {
            $self->{_storageLocation} = WebGUI::Storage->create($self->session);
            $self->update({storageId=>$self->{_storageLocation}->getId});
        } else {
            $self->{_storageLocation} = WebGUI::Storage->get($self->session,$self->get("storageId"));
        }
    }
    return $self->{_storageLocation};
}

####################################################################

=head2 getTemplateVars

Returns a hash of additional parameters to be used in templates, beyond the
standard definition.

Uses the current user's locale and timezone.

=cut

sub getTemplateVars {
    my $self    = shift;
    my $i18n    = WebGUI::International->new($self->session,"Asset_Event");
    my %var;

    # Some miscellaneous stuff
    $var{'canEdit'} = $self->canEdit;
    $var{"isPublic"} = 1
        if $self->get("groupIdView") eq "7";
    $var{"groupToView"} = $self->get("groupIdView");
    $var{"timeZone"}    = $self->get('timeZone');

    # Start date/time
    my $dtStart    = $self->getDateTimeStart;

    $var{ "startDateSecond"     } = sprintf "%02d", $dtStart->second;
    $var{ "startDateMinute"     } = sprintf "%02d", $dtStart->minute;
    $var{ "startDateHour24"     } = $dtStart->hour;
    $var{ "startDateHour"       } = $dtStart->hour_12;
    $var{ "startDateM"          } = ( $dtStart->hour < 12 ? "AM" : "PM" );
    $var{ "startDateDayName"    } = $dtStart->day_name;
    $var{ "startDateDayAbbr"    } = $dtStart->day_abbr;
    $var{ "startDateDayOfMonth" } = $dtStart->day_of_month;
    $var{ "startDateDayOfWeek"  } = $dtStart->day_of_week;
    $var{ "startDateMonthName"  } = $dtStart->month_name;
    $var{ "startDateMonthAbbr"  } = $dtStart->month_abbr;
    $var{ "startDateMonth"      } = $dtStart->month;
    $var{ "startDateYear"       } = $dtStart->year;
    $var{ "startDateYmd"        } = $dtStart->ymd;
    $var{ "startDateMdy"        } = $dtStart->mdy;
    $var{ "startDateDmy"        } = $dtStart->dmy;
    $var{ "startDateHms"        } = $dtStart->hms;
    $var{ "startDateEpoch"      } = $dtStart->epoch;

    # End date/time
    my $dtEnd   = $self->getDateTimeEnd;

    $var{ "endDateSecond"       } = sprintf "%02d", $dtEnd->second;
    $var{ "endDateMinute"       } = sprintf "%02d", $dtEnd->minute;
    $var{ "endDateHour24"       } = $dtEnd->hour;
    $var{ "endDateHour"         } = $dtEnd->hour_12;
    $var{ "endDateM"            } = ( $dtEnd->hour < 12 ? "AM" : "PM" );
    $var{ "endDateDayName"      } = $dtEnd->day_name;
    $var{ "endDateDayAbbr"      } = $dtEnd->day_abbr;
    $var{ "endDateDayOfMonth"   } = $dtEnd->day_of_month;
    $var{ "endDateDayOfWeek"    } = $dtEnd->day_of_week;
    $var{ "endDateMonthName"    } = $dtEnd->month_name;
    $var{ "endDateMonthAbbr"    } = $dtEnd->month_abbr;
    $var{ "endDateMonth"        } = $dtEnd->month;
    $var{ "endDateYear"         } = $dtEnd->year;
    $var{ "endDateYmd"          } = $dtEnd->ymd;
    $var{ "endDateMdy"          } = $dtEnd->mdy;
    $var{ "endDateDmy"          } = $dtEnd->dmy;
    $var{ "endDateHms"          } = $dtEnd->hms;
    $var{ "endDateEpoch"        } = $dtEnd->epoch;

    $var{ "isAllDay"            } = $self->isAllDay;
    $var{ "isOneDay"            } = $var{startDateDmy} eq $var{endDateDmy}
                                  ? 1 : 0
                                  ;

    # Make a Friendly date span.
    $var{dateSpan}
        = $var{startDateDayName}.", "
        . $var{startDateMonthName}." "
        . $var{startDateDayOfMonth};
    if (! $var{isAllDay}) {
        $var{dateSpan} .= ' '.$var{startDateHour}.":".$var{startDateMinute}." ".$var{startDateM};
    }
    if (! $var{isOneDay}) {
        $var{dateSpan}
            .= ' &bull; '
            .  $var{endDateDayName}.", "
            .  $var{endDateMonthName}." "
            .  $var{endDateDayOfMonth}." "
    }
    elsif (! $var{isAllDay}) {
        $var{dateSpan}
            .= ' &ndash; '
    }
    if (! $var{isAllDay}) {
        $var{dateSpan} .= ' '.$var{endDateHour}.":".$var{endDateMinute}." ".$var{endDateM};
    }

    # Make some friendly URLs
    my $urlStartParam   = $dtStart->cloneToUserTimeZone->truncate(to => "day");
    $var{ "url"         } = $self->getUrl;
    $var{ "urlEdit"     } = $self->getUrl("func=edit");
    $var{ "urlPrint"    } = $self->getUrl("print=1");
    $var{ "urlDelete"   } = $self->getUrl("func=delete");
    $var{ "urlDay"      } = $self->getParent->getUrl("type=day;start=".$urlStartParam);
    $var{ "urlWeek"     } = $self->getParent->getUrl("type=week;start=".$urlStartParam);
    $var{ "urlMonth"    } = $self->getParent->getUrl("type=month;start=".$urlStartParam);
    $var{ "urlList"     } = $self->getParent->getUrl("type=list");
    $var{ "urlParent"   } = $self->getParent->getUrl;
    $var{ "urlSearch"   } = $self->getParent->getSearchUrl;

    # Related links
    $var{ relatedLinks } = $self->getRelatedLinks;

    # Attachments
    my $gotImage;
    my $gotAttachment;
    $var{'attachment_loop'} = [];
    unless ($self->get("storageId") eq "") {
        my $storage = $self->getStorageLocation;
        foreach my $filename (@{$storage->getFiles}) {
            # Set top-level template vars for the first image and first non-image
            if (!$gotImage && $storage->isImage($filename)) {
                $var{ "image.url"       } = $storage->getUrl($filename);
                $var{ "image.thumbnail" } = $storage->getThumbnailUrl($filename);
                $gotImage = 1;
            }
            if (!$gotAttachment && !$storage->isImage($filename)) {
                $var{ "attachment.url"  } = $storage->getUrl($filename);
                $var{ "attachment.icon" } = $storage->getFileIconUrl($filename);
                $var{ "attachment.name" } = $filename;
                $gotAttachment = 1;
            }

            # All attachments get added to the loop
            push @{$var{"attachment_loop"}}, {
                url         => $storage->getUrl($filename),
                icon        => $storage->getFileIconUrl($filename),
                filename    => $filename,
                thumbnail   => $storage->getThumbnailUrl($filename),
                isImage     => $storage->isImage($filename),
            };
        }
    }

    return %var;
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of attachments and user defined fields. See WebGUI::Asset::indexContent() for additonal details.

=cut

sub indexContent {
    my $self = shift;
    my $indexer = $self->SUPER::indexContent;
    $indexer->addKeywords($self->get("userDefined1"));
    $indexer->addKeywords($self->get("userDefined2"));
    $indexer->addKeywords($self->get("userDefined3"));
    $indexer->addKeywords($self->get("userDefined4"));
    $indexer->addKeywords($self->get("userDefined5"));
    $indexer->addKeywords($self->get("location"));
    my $storage = $self->getStorageLocation;
    foreach my $file (@{$storage->getFiles}) {
               $indexer->addFile($storage->getPath($file));
    }
}




####################################################################

=head2 isAllDay

Returns true if this event is an all day event.

=cut

sub isAllDay {
    my $self    = shift;
    return 1 unless ($self->get("startTime") || $self->get("endTime"));
    return 0;
}

#-------------------------------------------------------------------

=head2 limitedEndDate ( date )

A datetime object for recurrence end or the supplied date, whichever comes
first.  If there is a count for the recurrence, there is no end date
(counted recurrences are always fully generated).

=cut

sub limitedEndDate {
    my ($self, $limit) = @_;
    my $recur = $self->getRecurrence;
    return undef if $recur->{endAfter};

    my $natural = do {
        my $mysql = $recur->{endDate};
        $mysql && WebGUI::DateTime->new($self->session, $mysql);
    };
    return ($natural and $limit > $natural) ? $natural : $limit;
}


####################################################################

=head2 prepareView

Prepares the view template to be used later. The template to be used is found
from this asset's parent (Usually a Calendar).

If the "print" form parameter is set, will prepare the print template.

=cut

sub prepareView {
    my $self    = shift;
    my $parent  = $self->getParent;
    my $templateId;

    if ($parent) {
        if ($self->session->form->param("print")) {
            $templateId = $parent->get("templateIdPrintEvent");
            $self->session->style->makePrintable(1);
        }
        else {
            $templateId = $parent->get("templateIdEvent");
        }
    }
    else {
        $templateId = "CalendarEvent000000001";
    }

    my $template = WebGUI::Asset::Template->new($self->session,$templateId);
    $template->prepare($self->getMetaDataAsTemplateVariables);

    $self->{_viewTemplate}    = $template;
}





####################################################################

=head2 processPropertiesFromFormPost

Processes the Event Edit form.

Makes the event hide from navigation (since there could be possibly thousands of
events across dozens of years. How would we even go about sorting such a list?)

If "allday" is "yes", sets the startTime and endTime to NULL.

If there's a time, convert from the user's timezone to UTC.

Updates the Event_recur table if necessary (creates a new recurId, points the
saved event to the new recurId, creates all the events under this new
recurId, and then deletes all the events under the old recurId).

Requests that the events be committed

=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    $self->SUPER::processPropertiesFromFormPost;    # Updates the event
    my $session = $self->session;
    my $form    = $session->form;

    ### Verify the form was filled out correctly...
    my @errors;
    # If the start date is after the end date
    my $i18n = WebGUI::International->new($session, 'Asset_Event');
    if ($self->get("startDate") gt $self->get("endDate")) {
        push @errors, $i18n->get("The event end date must be after the event start date.");
    }

    # If the dates are the same and the start time is after the end time
    if ($self->get("startDate") eq $self->get("endDate")
        && $self->get("startTime") gt $self->get("endTime")
       ) {
        push @errors, $i18n->get("The event end time must be after the event start time.");
    }

    if (@errors) {
        return \@errors;
    }

    # Since we may be adding more events, set out version tag to be active if needed
    # Leave the original version tag available, we will need to reactivate it before returning
    my $activeVersionTag = WebGUI::VersionTag->getWorking($session, 'nocreate');
    # if our version tag is active, we don't need a new one, and don't need to reactivate anything later
    if ($activeVersionTag && $activeVersionTag->getId eq $self->get('tagId')) {
        undef $activeVersionTag;
    }
    else {
        WebGUI::VersionTag->new($session, $self->get('tagId'))->setWorking;
    }

    ### Form is verified, fix properties
    if (!$session->form->hasParam('groupIdView')) {
        $self->update({
            groupIdView     => $self->getParent->get('groupIdView'),
        });
    }

    if (!$session->form->hasParam('groupIdEdit')) {
        my $groupIdEdit =  $self->getParent->get("groupIdEventEdit")
                        || $self->getParent->get("groupIdEdit")
                        ;

        $self->update({
            groupIdEdit     => $groupIdEdit,
        });
    }

    # Fix times according to input (allday, timezone)
    # All day events have no time
    if ($form->param("allday")) {
        $self->update({
            startTime   => '',
            endTime     => '',
        });
    }
    # Non-allday events need timezone conversion
    else {
        my $tz    = $self->get('timeZone');

        my $dtStart
            = WebGUI::DateTime->new($session,
                mysql       => $self->get("startDate") . " " . $self->get("startTime"),
                time_zone   => $tz,
            );

        my $dtEnd
            = WebGUI::DateTime->new($session,
                mysql       => $self->get("endDate") . " " . $self->get("endTime"),
                time_zone   => $tz,
            );

        $self->update({
            startDate   => $dtStart->toDatabaseDate,
            startTime   => $dtStart->toDatabaseTime,
            endDate     => $dtEnd->toDatabaseDate,
            endTime     => $dtEnd->toDatabaseTime,
        });
    }

    my $top_val = $session->db->dbh->selectcol_arrayref("SELECT sequenceNumber FROM Event ORDER BY sequenceNumber desc LIMIT 1")->[0];
    $top_val += 16384;
    my $assetId = $self->get('assetId');
    my $revisionDate = $self->get('revisionDate');

    $session->db->write("UPDATE Event SET sequenceNumber =? WHERE assetId = ? AND revisionDate =?",[(scalar($form->param('sequenceNumber')) || $top_val), $assetId, $revisionDate]);


    # Pre-process Related Links and manage changes
    # These parameters are the important ones
    #
    my @rel_keys = grep {/^rel_(?:delconfirm|url|text|group|seq)_/} $form->param;

    # Organize results
    my %rel_link_for;
    for (@rel_keys) {
       if (/^rel_group_id_(.+)$/) {  # Group assignment
           $rel_link_for{$1}{groupIdView} = $form->param($_);
       }
       elsif (/^rel_url_(.+)$/) {
           my $eventlinkId = $1;
           my $url = $form->param($_);
           $url =~ s/^\s+//;
           $url =~ s/\s+$//;
           if (0 && $url && $url !~ /^http:\/\//) {
               $url =~ s/ht+p[^\w]+//i;
               $url = "http://$url";
           }
           $rel_link_for{$eventlinkId}{linkurl} = $url || '';
       }
       elsif (/^rel_seq_(.+)$/) {
           $rel_link_for{$1}{sequenceNumber} = $form->param($_);
       }
       elsif (/^rel_text_(.+)$/) {
           my $eventlinkId = $1;
           my $text = $form->param($_);
           $text =~ s/^\s+//;
           $text =~ s/\s+$//;
           $rel_link_for{$eventlinkId}{linktext} = $text;
       }
       elsif (/^rel_delconfirm_(.+)$/) {
           $rel_link_for{$1}{delete} = $form->param($_);
       }
    }

    # The database entries for this assetId are compared and
    # then replaced by these (possibly new) values.  Deletions
    # are marked and passed on.
    #
    my @rel_link_saves;

    for (keys %rel_link_for) {
       if (!$rel_link_for{$_}{linkurl}) {
           $rel_link_for{$_}{delete}++;
           next;
       }
       if (/^new_/) {
           $rel_link_for{$_}{eventlinkId} = $self->session->id->generate();
           $rel_link_for{$_}{new_event}++;
       }
       else {
           $rel_link_for{$_}{eventlinkId} = $_;
       }
       push @rel_link_saves, \%{$rel_link_for{$_}};
    }

    $self->setRelatedLinks(\@rel_link_saves);

    # Determine if the pattern has changed
    if ($form->param("recurType")) {
        # Create the new recurrence hash
        my $recurrence_new      = $self->getRecurrenceFromForm;
        # Get the old recurrence hash and range
        my $recurrence_old      = $self->getRecurrence;

        # Pattern keys
        if (!eq_deeply($recurrence_new, $recurrence_old)) {
            # Delete all old events and create new ones
            my $old_id  = $self->get("recurId");

            # Set the new recurrence pattern
            if ($recurrence_new) {
                my $new_id  = $self->setRecurrence($recurrence_new);
                if (! $new_id) {
                    $activeVersionTag->setWorking
                        if $activeVersionTag;
                    return ["There is something wrong with your recurrence pattern."];
                }

                # Generate the new recurring events
                $self->generateRecurringEvents();
            }
            else {
                $self->update({recurId => undef});
            }

            # Delete old events
            if ($old_id) {
                my $events = $self->getLineageIterator(["siblings"], {
                    includeOnlyClasses  => ['WebGUI::Asset::Event'],
                    joinClass           => 'WebGUI::Asset::Event',
                    whereClause         => qq{Event.recurId = "$old_id"},
                });
                while ( 1 ) {
                    my $event;
                    eval { $event = $events->() };
                    if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                        $session->log->error(sprintf "Couldn't instance event asset %s to delete it", $x->id);
                        next;
                    }
                    last unless $event;
                    $event->purge;
                }
            }
        }
        else {
            # TODO: Give users a form property to decide what events to update
            # TODO: Make this use WebGUI::ProgressBar so 1 million events doesn't kill the server.
            # Just update related events
            my %properties    = %{ $self->get };
            delete $properties{startDate};
            delete $properties{endDate};
            delete $properties{url};    # addRevision will create a new url for us

            my $events = $self->getLineageIterator(["siblings"], {
                includeOnlyClasses  => ['WebGUI::Asset::Event'],
                joinClass           => 'WebGUI::Asset::Event',
                whereClause         => q{Event.recurId = "}.$self->get("recurId").q{"},
            });

            while ( 1 ) {
                my $event;
                eval { $event = $events->() };
                if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                    $session->log->error(sprintf "Couldn't instance event asset %s to update it", $x->id);
                    next;
                }
                last unless $event;
                # Add a revision
                $properties{ startDate  } = $event->get("startDate");
                $properties{ endDate    } = $event->get("endDate");

                # addRevision returns the new revision
                $event  = $event->addRevision(\%properties, undef, { skipAutoCommitWorkflows => 1 });
            }
        }
    }
    $activeVersionTag->setWorking
        if $activeVersionTag;

    delete $self->{_storageLocation};
    return undef;
}

#-------------------------------------------------------------------

=head2 purge ( )

Extent the method from the super class to delete all storage locations.

=cut

sub purge {
    my $self = shift;
    my $sth = $self->session->db->read("select storageId from Event where assetId=?",[$self->getId]);
    while (my ($storageId) = $sth->array) {
        my $storage = WebGUI::Storage->get($self->session,$storageId);
        $storage->delete if defined $storage;
    }
    $sth->finish;
    return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

Extent the method from the super class to delete the storage location for this revision.

=cut

sub purgeRevision {
    my $self = shift;
    $self->getStorageLocation->delete;
    return $self->SUPER::purgeRevision;
}

####################################################################

=head2 setRecurrence ( hashref )

Sets a hash of recurrence information to the database. The hash keys are the
same as the ones in getRecurrence()

This will always create a new row in the recurrence table.

Returns the ID of the row if success, otherwise returns 0.

=cut

sub setRecurrence {
    my $self    = shift;
    my $vars    = shift;

    my $type    = $vars->{recurType} || return undef;
    my $pattern;

    if ($type eq "daily" || $type eq "weekday") {
        return 0 unless ($vars->{every});
        #(\d+)
        $pattern = $vars->{every};
    }
    elsif ($type eq "weekly") {
        return 0 unless ($vars->{every} && $vars->{dayNames});
        #(\d+) ([umtwrfs]+)
        $pattern = $vars->{every}." ".join("",@{$vars->{dayNames}});
    }
    elsif ($type eq "monthWeek") {
        return 0 unless ($vars->{every} && $vars->{weeks} && $vars->{dayNames});
        #(\d+) (first,second,third,fourth,last) ([umtwrfs]+)
        $pattern = $vars->{every}." ".join(",",@{$vars->{weeks}})." ".join("",@{$vars->{dayNames}});
    }
    elsif ($type eq "monthDay") {
        return 0 unless ($vars->{every} && $vars->{dayNumber});
        #(\d+) on (\d+)
        $pattern = $vars->{every}." ".$vars->{dayNumber};
    }
    elsif ($type eq "yearWeek") {
        return 0 unless ($vars->{every} && $vars->{weeks} && $vars->{dayNames} && $vars->{months});
        #(\d+) (first,second,third,fourth,last) ([umtwrfs]+)? (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
        $pattern = $vars->{every}." ".join(",",@{$vars->{weeks}})." ".join("",@{$vars->{dayNames}})." ".join(",",@{$vars->{months}});
    }
    elsif ($type eq "yearDay") {
        return 0 unless ($vars->{every} && $vars->{dayNumber} && $vars->{months});
        #(\d+) on (\d+) (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
        $pattern = $vars->{every}." ".$vars->{dayNumber}." ".join(",",@{$vars->{months}});
    }


    my $end    = undef;
    if ($vars->{endAfter}) {
        $end    = "after ".$vars->{endAfter};
    }
    elsif ($vars->{endDate}) {
        $end    = $vars->{endDate};
    }


    my $data    = {
        recurId     => "new",
        recurType   => $type,
        pattern     => $pattern,
        startDate   => $vars->{startDate},
        endDate     => $end,
        };

    ## Set to the database
    ## Return the new recurId
    my $recurId = $self->session->db->setRow("Event_recur","recurId",$data);
    $self->update({recurId => $recurId});

    $self->{recurrence} = $vars;
    return $recurId;
}

####################################################################

=head2 setRelatedLinks ( links )

Sets the event's related links. C<links> is an array reference of
hash reference of links.

=cut

sub setRelatedLinks {
    my $self    = shift;
    my $links   = shift;

    my $assetId = $self->getId;

    # Don't make any changes unless asked, and then only change the known records
    #
    if (@$links) {
       for my $hr (@{$links}) {
           if ($hr->{new_event} && !$hr->{delete}) {
               $self->session->db->write(
                    q{INSERT INTO Event_relatedlink (assetId,sequenceNumber,linkurl,linktext,groupIdView,eventlinkId) VALUES (?,?,?,?,?,?)},
                    [ $assetId, @{$hr}{('sequenceNumber','linkurl','linktext','groupIdView','eventlinkId')} ]
                );
           }
           elsif ($hr->{delete}) {
                $self->session->db->write(
                    q{DELETE FROM Event_relatedlink WHERE assetId = ? AND eventlinkId = ?},
                    [ $assetId, $hr->{eventlinkId} ],
                );
           }
           else {
                $self->session->db->write(
                    q{UPDATE Event_relatedlink set sequenceNumber=?,linkurl=?,linktext=?,groupIdView=? where eventlinkId = ?},
                    [ @{$hr}{('sequenceNumber','linkurl','linktext','groupIdView','eventlinkId')} ],
                );
           }
       }
    }

    return undef;
}

####################################################################

=head2 update

Wrap update so that isHidden is always set to be a 1.

=cut

sub update {
    my $self       = shift;
    my $properties = shift;
    my $session    = $self->session;
    if (my $startTime = $properties->{startTime}) {
        my ($startHour, $startMinute, $startSecond) = $startTime =~ /^ (\d+) : (\d+) (?: :(\d+)) /x;
        if ($startHour > 23) {
            $startHour = 0;
            my $startDate = exists $properties->{startDate} ? $properties->{startDate} : $self->get('startDate');
            $session->log->warn('startDate: '. $startDate);
            my $startDt = WebGUI::DateTime->new($session, $startDate);
            $startDt->add(days => 1);
            $properties->{startDate} = $startDt->toMysqlDate;
            $session->log->warn('startDate: '. $properties->{startDate});
            $startSecond             = '00' if ! $startSecond;
            $properties->{startTime} = sprintf '%02d:%02d:%02d', $startHour, $startMinute, $startSecond;
        }
    }
    if (my $endTime = $properties->{endTime}) {
        my ($endHour, $endMinute, $endSecond) = $endTime =~ /^ (\d+) : (\d+) (?: :(\d+)) /x;
        if ($endHour > 23) {
            $endHour = 0;
            my $endDate = exists $properties->{endDate} ? $properties->{endDate} : $self->get('endDate');
            $session->log->warn('endDate: '. $endDate);
            my $endDt = WebGUI::DateTime->new($session, $endDate);
            $endDt->add(days => 1);
            $properties->{endDate} = $endDt->toMysqlDate;
            $session->log->warn('endDate: '. $properties->{endDate});
            $endSecond             = '00' if ! $endSecond;
            $properties->{endTime} = sprintf '%02d:%02d:%02d', $endHour, $endMinute, $endSecond;
        }
    }
    return $self->SUPER::update({%$properties, isHidden => 1});
}


#-------------------------------------------------------------------

=head2 validParent

Make sure that the current session asset is a Calendar for pasting and adding checks.

This is a class method.

=cut

sub validParent {
    my $class   = shift;
    my $session = shift;
    return $session->asset->isa('WebGUI::Asset::Wobject::Calendar');
}

####################################################################

=head2 view

Returns the template to be viewed.

=cut

sub view  {
    my $self        = shift;
    my $session     = $self->session;

    # Get, of course, the event data
    my $var         = $self->get;



    # Get some more template vars
    my %dates       = $self->getTemplateVars;
    $var->{$_}      = $dates{$_} for keys %dates;

    # Next and previous events
    my $next        = $self->getEventNext;
    $var->{"nextUrl"} = $next->getUrl
        if ($next);

    my $prev        = $self->getEventPrev;
    $var->{"prevUrl"} = $prev->getUrl
        if ($prev);


    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}



#-------------------------------------------------------------------

=head2 www_deleteFile ( )

Delete a file given in the form variable "filename" from the storage location.

=cut

sub www_deleteFile {
    my $self = shift;
    $self->getStorageLocation->deleteFile($self->session->form->process("filename")) if $self->canEdit;
    return $self->www_edit;
}



####################################################################

=head2 www_edit

Edit the event.

=cut

# Author's note: This sub is ugly and should be reformatted according to PBP
sub www_edit {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    my $tz          = $form->param('timeZone') || $self->get('timeZone') || $session->datetime->getTimeZone;
    my $func        = lc $session->form->param("func");
    my $var         = {};

    return $self->session->privilege->noAccess() unless $self->getParent->canAddEvent();

    if ($func eq "add" || $form->param("assetId") eq "new") {
        $var->{"formHeader"}
            = WebGUI::Form::formHeader($session, {
                action  => $self->getParent->getUrl,
            })
            . WebGUI::Form::hidden($self->session, {
                name    => "assetId",
                value   => "new",
            })
            . WebGUI::Form::hidden($self->session, {
                name    => "class",
                value   => $self->session->form->process("class","className"),
            })
            . WebGUI::Form::hidden( $self->session, {
                name    => 'ownerUserId',
                value   => $self->session->user->userId,
            } )
            ;
    }
    else {
        $var->{"formHeader"}
            = WebGUI::Form::formHeader($session, {
                action      => $self->getUrl,
            })
            . WebGUI::Form::hidden($self->session, {
                name    => "sequenceNumber",
                value   => $self->get("sequenceNumber"),
            })
            . WebGUI::Form::hidden( $self->session, {
                name    => 'ownerUserId',
                value   => $self->session->user->userId,
            } )
            ;
    }

    $var->{"formHeader"}
        .= WebGUI::Form::hidden($self->session, {
            name    => "func",
            value   => "editSave"
        })
        . WebGUI::Form::hidden($self->session, {
            name    => "recurId",
            value   => $self->get("recurId"),
        });

    $var->{"formFooter"} = WebGUI::Form::formFooter($session);


    ###### Event Tab
    # title AS long title
    $var->{"formTitle"}
        = WebGUI::Form::text($session, {
            name    => "title",
            value   => $form->process("title") || $self->get("title"),
        });

    # menu title AS short title
    $var->{"formMenuTitle"}
        = WebGUI::Form::text($session, {
            name        => "menuTitle",
            value       => $form->process("menuTitle") || $self->get("menuTitle"),
            maxlength   => 15,
            size        => 22,
        });

    # synopsis
    $var->{"formSynopsis"}
        = WebGUI::Form::textarea($session, {
            name        => "synopsis",
            value       => $form->process("synopsis") || $self->get("synopsis"),
        });

    # Group to View
    $var->{"formGroupIdView"}
        = WebGUI::Form::Group($session, {
            name         => "groupIdView",
            value        => $form->process("groupIdView") || $self->get("groupIdView"),
            defaultValue => $self->getParent->get("groupIdView"),
        });

    # location
    $var->{"formLocation"}
        = WebGUI::Form::text($session, {
            name    => "location",
            value   => $form->process("location") || $self->get("location"),
        });

    # description
    $var->{"formDescription"}
        = WebGUI::Form::HTMLArea($session, {
            name    => "description",
            value   => $form->process("description") || $self->get("description"),
        });

    # User defined
    for my $x (1..5) {
        my $userDefinedValue = $self->getValue("userDefined".$x);
        $var->{'formUserDefined'.$x} = WebGUI::Form::text($session, {
            name    => "userDefined" . $x,
            value   => $userDefinedValue,
        });
        $var->{'formUserDefined'.$x.'_yesNo'} = WebGUI::Form::yesNo($session, {
            name    => "userDefined".$x,
            value   => $userDefinedValue,
        });
        $var->{'formUserDefined'.$x.'_textarea'} = WebGUI::Form::textarea($session, {
            name    => "userDefined".$x,
            value   => $userDefinedValue,
        });
        $var->{'formUserDefined'.$x.'_htmlarea'} = WebGUI::Form::HTMLArea($session, {
            name    => "userDefined".$x,
            value   => $userDefinedValue,
        });
		$var->{'formUserDefined'.$x.'_float'} = WebGUI::Form::Float($session, {
            name    => "userDefined".$x,
            value   => $userDefinedValue,
        });
    }

    # File attachments
    $var->{"formAttachments"}
        = WebGUI::Form::Image($session, {
            name    => "storageId",
            maxAttachments => 5,
            value   => $form->process("storageId") || $self->get("storageId"),
            deleteFileUrl=>$self->getUrl("func=deleteFile;filename=")
        });

    ### Start date
    my $default_start;

    # Try to get a default start date from the form
    if ($session->form->param("start")) {
        $default_start
            = WebGUI::DateTime->new($session,
                mysql       => $session->form->param("start"),
                time_zone   => $tz,
            );
    }
    else {
        $default_start  = WebGUI::DateTime->new($session, time);
    }

    my ($startDate, $startTime);
    if ($form->param("func") ne "add" && $form->param("assetId") ne "new") {
        my $dtStart = $self->getDateTimeStart;
        if ($self->isAllDay) {
            $startDate  = $dtStart->toDatabaseDate;
        }
        else {
            my $start = $dtStart->clone->set_time_zone($tz);
            $startDate  = $start->toMysqlDate;
            $startTime  = $start->toMysqlTime;
        }
    }

    $var->{"formStartDate"}
        = WebGUI::Form::date($session, {
            name            => "startDate",
            value           => $form->param("startDate") || $startDate,
            defaultValue    => $default_start->toUserTimeZoneDate,
        });
    $var->{"formStartTime"}
        = WebGUI::Form::timeField($session, {
            name            => "startTime",
            value           => $form->param("startTime") || $startTime,
            defaultValue    => $default_start->toUserTimeZoneTime,
        });

    # end date
    # By default, it's the default start date plus an hour
    my $default_end = $default_start->clone->add(hours => 1);

    my ($endDate, $endTime);
    if ($form->param("func") ne "add" && $form->param("assetId") ne "new") {
        my $dtEnd = $self->getDateTimeEnd;
        if ($self->isAllDay) {
            $endDate    = $dtEnd->toDatabaseDate;
        }
        else {
            my $end = $dtEnd->clone->set_time_zone($tz);
            $endDate    = $end->toMysqlDate;
            $endTime    = $end->toMysqlTime;
        }
    }

    $var->{"formEndDate"}
        = WebGUI::Form::date($session, {
            name            => "endDate",
            value           => $form->param("endDate") || $endDate,
            defaultValue    => $default_end->toUserTimeZoneDate,
        });
    $var->{"formEndTime"}
        = WebGUI::Form::timeField($session, {
            name            => "endTime",
            value           => $form->param("endTime") || $endTime,
            defaultValue    => $default_end->toUserTimeZoneTime,
        });
    $var->{"formTimeZone"}
        = WebGUI::Form::TimeZone($session, {
            name    => "timeZone",
            value   => $tz,
        });


    # time
    my $allday  = defined $form->param("allday")
                ? $form->param("allday")
                : $self->isAllDay
                ;

    my $i18n = WebGUI::International->new($session, 'Asset_Event');
    $var->{"formTime"}
        = q|<input id="allday_yes" type="radio" name="allday" value="yes" |
        . ($allday ? 'checked="checked"' : '')
        . q| />
        <label for="allday_yes">|. $i18n->get('No specific time'). q|</label>
        <br/>
        <input id="allday_no" type="radio" name="allday" value="" |
        . (!$allday ? 'checked="checked"' : '')
        . q| />
        <label for="allday_no">|. $i18n->get('Specific start/end time'). q|</label>
        <br />
        <div id="times">|
        . $i18n->get('start')               . q|: | . $var->{"formStartTime"} . q|<br/>|
        . $i18n->get('end')                 . q|: | . $var->{"formEndTime"}   . q|<br/>|
        . $i18n->get('timezone', 'DateTime'). q|: | . $var->{formTimeZone}    . q|</div>|
        ;

    ###### related links
    my $relatedLinks = $self->getRelatedLinks();

    my $seqNum = 1;
    for (@$relatedLinks) {

        $_->{row_id} = "rel_row_".$_->{eventlinkId};
        $_->{div_id} = "rel_div_".$_->{eventlinkId};
        $_->{delete_name} = "rel_del_".$_->{eventlinkId};
        $_->{delete_id} = "rel_del_id_".$_->{eventlinkId};
        $_->{group_id} = WebGUI::Form::Group($session, {
            name         => "rel_group_id_".$_->{eventlinkId},
            value        => $form->process("rel_group_id_".$_->{eventlinkId}) || $_->{groupIdView} || $self->getParent->get("groupIdView"),
            defaultValue => $self->getParent->get("groupIdView"),
        });
       $_->{seq_num_name}  = "rel_seq_".$_->{eventlinkId};
       $_->{seq_num_id}    = "rel_seq_id_".$_->{eventlinkId};
       $_->{seq_num_value} = $seqNum++;
    }
    $var->{"relatedLinks"} = $relatedLinks;

    $var->{"genericGroup"} = WebGUI::Form::Group($session, {
            name         => "rel_group_id_ZZZZZZZZZZ",
            value        => $self->getParent->get("groupIdView"),
            defaultValue => $self->getParent->get("groupIdView"),
        });
    chomp $var->{"genericGroup"};



    ###### Recurrence tab
    # Pattern
    my $recur = $self->getRecurrenceFromForm || $self->getRecurrence;
    $recur->{every} ||= 1;

    $var->{"formRecurPattern"}
        = q|
        <div id="recurPattern">
        <p><input type="radio" name="recurType" id="recurType_none" value="none" onclick="toggleRecur()" />
        <label for="recurType_none">|. $i18n->get(881,'WebGUI'). q|</label></p>


        <p><input type="radio" name="recurType" id="recurType_daily" value="daily" onclick="toggleRecur()"  |.($recur->{recurType} =~ /^(daily|weekday)$/ ? q|checked="checked"| : q||).q|/>
        <label for="recurType_daily">|. $i18n->get('Daily'). q|</label></p>
        <div style="margin-left: 4em;" id="recurPattern_daily">
            |. $i18n->get('Every'). q| <input type="text" name="recurDay" size="3" value="|.$recur->{every}.q|" /><br/>
            <input type="radio" name="recurSubType" id="recurSubType_daily" value="daily" |.($recur->{recurType} eq "daily" ? q|checked="checked"| : q||).q|/>
            <label for="recurSubType_daily">|. $i18n->get(700, 'WebGUI'). q|</label><br />
            <input type="radio" name="recurSubType" id="recurSubType_weekday" value="weekday" |.($recur->{recurType} eq "weekday" ? q|checked="checked"| : q||).q|/>
            <label for="recurSubType_weekday">|. $i18n->get('Weekday(s)'). q|</label>
        </div>

        <p><input type="radio" name="recurType" id="recurType_weekly" value="weekly" onclick="toggleRecur()" |.($recur->{recurType} eq "weekly" ? q|checked="checked"| : q||).q|/>
        <label for="recurType_weekly">|. $i18n->get('Weekly'). q|</label></p>
        <div style="margin-left: 4em;" id="recurPattern_weekly">
            |. sprintf($i18n->get('Every N weeks on'), q|<input type="text" name="recurWeek" size="3" value="|.$recur->{every}.q|" />|). q|<br/>
            <input type="checkbox" name="recurWeekDay" value="u" id="recurWeekDay_U" |.(grep(/u/,@{$recur->{dayNames}}) ? 'checked="checked"' : '' ).q|/>
            <label for="recurWeekDay_U">|. $i18n->get('sunday', 'DateTime'). q|</label><br/>
            <input type="checkbox" name="recurWeekDay" value="m" id="recurWeekDay_M" |.(grep(/m/,@{$recur->{dayNames}}) ? 'checked="checked"' : '' ).q|/>
            <label for="recurWeekDay_M">|. $i18n->get('monday', 'DateTime'). q|</label><br/>
            <input type="checkbox" name="recurWeekDay" value="t" id="recurWeekDay_T" |.(grep(/t/,@{$recur->{dayNames}}) ? 'checked="checked"' : '' ).q|/>
            <label for="recurWeekDay_T">|. $i18n->get('tuesday', 'DateTime'). q|</label><br/>
            <input type="checkbox" name="recurWeekDay" value="w" id="recurWeekDay_W" |.(grep(/w/,@{$recur->{dayNames}}) ? 'checked="checked"' : '' ).q|/>
            <label for="recurWeekDay_W">|. $i18n->get('wednesday', 'DateTime'). q|</label><br/>
            <input type="checkbox" name="recurWeekDay" value="r" id="recurWeekDay_R" |.(grep(/r/,@{$recur->{dayNames}}) ? 'checked="checked"' : '' ).q|/>
            <label for="recurWeekDay_R">|. $i18n->get('thursday', 'DateTime'). q|</label><br/>
            <input type="checkbox" name="recurWeekDay" value="f" id="recurWeekDay_F" |.(grep(/f/,@{$recur->{dayNames}}) ? 'checked="checked"' : '' ).q|/>
            <label for="recurWeekDay_F">|. $i18n->get('friday', 'DateTime'). q|</label><br/>
            <input type="checkbox" name="recurWeekDay" value="s" id="recurWeekDay_S" |.(grep(/s/,@{$recur->{dayNames}}) ? 'checked="checked"' : '' ).q|/>
            <label for="recurWeekDay_S">|. $i18n->get('saturday', 'DateTime'). q|</label><br/>
        </div>

        <p><input type="radio" name="recurType" id="recurType_monthly" value="monthly" onclick="toggleRecur()" |.($recur->{recurType} =~ /^month/ ? q|checked="checked"| : q||).q|/>
        <label for="recurType_monthly">|. $i18n->get('Monthly'). q|</label></p>
        <div style="margin-left: 4em;" id="recurPattern_monthly">
            <p>|. sprintf($i18n->get('Every N months on'), q|<input type="text" name="recurMonth" size="3" value="|.$recur->{every}.q|" />|). q|</p>
            <p><input type="radio" name="recurSubType" id="recurSubType_monthDay" value="monthDay" |.($recur->{recurType} eq "monthDay" ? q|checked="checked"| : q||).q|/>
            <label for="recurSubType_monthDay">|. $i18n->get('day'). q| </label>
            <input type="text" name="recurMonthDay" size="3" value="|.$recur->{dayNumber}.q|"></p>

            <p>
            <input style="vertical-align: top;" type="radio" name="recurSubType" id="recurSubType_monthWeek" value="monthWeek" |.($recur->{recurType} eq "monthWeek" ? q|checked="checked"| : q||).q|/>
            <select style="vertical-align: top;" name="recurMonthWeekNumber">
                <option value="first"  |.(grep(/first/,  @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('first').  q|</option>
                <option value="second" |.(grep(/second/, @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('second'). q|</option>
                <option value="third"  |.(grep(/third/,  @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('third').  q|</option>
                <option value="fourth" |.(grep(/fourth/, @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('fourth'). q|</option>
                <option value="fifth"  |.(grep(/fifth/,  @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('last').   q|</option>
            </select> |. $i18n->get('week on'). q|
            <select style="vertical-align: top;" name="recurMonthWeekDay">
                <option value="u" |.(grep(/u/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('sunday', 'DateTime'). q|</option>
                <option value="m" |.(grep(/m/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('monday', 'DateTime').    q|</option>
                <option value="t" |.(grep(/t/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('tuesday', 'DateTime').   q|</option>
                <option value="w" |.(grep(/w/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('wednesday', 'DateTime'). q|</option>
                <option value="r" |.(grep(/r/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('thursday', 'DateTime').  q|</option>
                <option value="f" |.(grep(/f/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('friday', 'DateTime').    q|</option>
                <option value="s" |.(grep(/s/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('saturday', 'DateTime').  q|</option>
            </select>
            </p>
        </div>


        <p><input type="radio" name="recurType" id="recurType_yearly" value="yearly" onclick="toggleRecur()" |.($recur->{recurType} =~ /^year/ ? q|checked="checked"| : q||).q|/>
        <label for="recurType_yearly">|. $i18n->get('Yearly'). q|</label></p>
        <div style="margin-left: 4em;" id="recurPattern_yearly">
            <p>|. sprintf($i18n->get('Every N years on'),q|<input type="text" name="recurYear" size="3" value="|.$recur->{every}.q|" />|). q|</p>
            <p>
            <input type="radio" name="recurSubType" id="recurSubType_yearDay" value="yearDay" |.($recur->{recurType} eq "yearDay" ? q|checked="checked"| : q||).q|/>
            <select name="recurYearDayMonth">
                <option value="jan" |.(grep(/jan/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('january','DateTime').   q|</option>
                <option value="feb" |.(grep(/feb/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('february','DateTime').  q|</option>
                <option value="mar" |.(grep(/mar/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('march','DateTime').     q|</option>
                <option value="apr" |.(grep(/apr/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('april','DateTime').     q|</option>
                <option value="may" |.(grep(/may/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('may','DateTime').       q|</option>
                <option value="jun" |.(grep(/jun/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('june','DateTime').      q|</option>
                <option value="jul" |.(grep(/jul/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('july','DateTime').      q|</option>
                <option value="aug" |.(grep(/aug/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('august','DateTime').    q|</option>
                <option value="sep" |.(grep(/sep/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('september','DateTime'). q|</option>
                <option value="oct" |.(grep(/oct/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('october','DateTime').   q|</option>
                <option value="nov" |.(grep(/nov/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('november','DateTime').  q|</option>
                <option value="dec" |.(grep(/dec/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('december','DateTime').  q|</option>
            </select>
            <input type="text" name="recurYearDay" size="3" value="|.$recur->{dayNumber}.q|"/>
            </p>

            <p>
            <input style="vertical-align: top;" type="radio" name="recurSubType" id="recurSubType_yearWeek" value="yearWeek" |.($recur->{recurType} eq "yearWeek" ? q|checked="checked"| : q||).q|/>
            <select style="vertical-align: top;" name="recurYearWeekNumber">
                <option value="first"  |.(grep(/first/,  @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('first').  q|</option>
                <option value="second" |.(grep(/second/, @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('second'). q|</option>
                <option value="third"  |.(grep(/third/,  @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('third').  q|</option>
                <option value="fourth" |.(grep(/fourth/, @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('fourth'). q|</option>
                <option value="fifth"  |.(grep(/fifth/,  @{$recur->{weeks}}) ? 'selected="selected"' : '').q|>|. $i18n->get('last').   q|</option>
            </select>
            <select style="vertical-align: top;" name="recurYearWeekDay">
                <option value="u" |.(grep(/u/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('sunday', 'DateTime'). q|</option>
                <option value="m" |.(grep(/m/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('monday', 'DateTime').    q|</option>
                <option value="t" |.(grep(/t/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('tuesday', 'DateTime').   q|</option>
                <option value="w" |.(grep(/w/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('wednesday', 'DateTime'). q|</option>
                <option value="r" |.(grep(/r/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('thursday', 'DateTime').  q|</option>
                <option value="f" |.(grep(/f/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('friday', 'DateTime').    q|</option>
                <option value="s" |.(grep(/s/,@{$recur->{dayNames}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('saturday', 'DateTime').  q|</option>
            </select> |. $i18n->get('of'). q|
            <select name="recurYearWeekMonth">
                <option value="jan" |.(grep(/jan/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('january','DateTime').   q|</option>
                <option value="feb" |.(grep(/feb/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('february','DateTime').  q|</option>
                <option value="mar" |.(grep(/mar/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('march','DateTime').     q|</option>
                <option value="apr" |.(grep(/apr/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('april','DateTime').     q|</option>
                <option value="may" |.(grep(/may/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('may','DateTime').       q|</option>
                <option value="jun" |.(grep(/jun/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('june','DateTime').      q|</option>
                <option value="jul" |.(grep(/jul/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('july','DateTime').      q|</option>
                <option value="aug" |.(grep(/aug/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('august','DateTime').    q|</option>
                <option value="sep" |.(grep(/sep/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('september','DateTime'). q|</option>
                <option value="oct" |.(grep(/oct/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('october','DateTime').   q|</option>
                <option value="nov" |.(grep(/nov/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('november','DateTime').  q|</option>
                <option value="dec" |.(grep(/dec/,@{$recur->{months}}) ? 'selected="selected"' : '' ).q|>|. $i18n->get('december','DateTime').  q|</option>
            </select>
            </p>
        </div>
        </div>
        |;


    # Start
    $var->{"formRecurStart"}
        = WebGUI::Form::date($session, {
            name            => "recurStart",
            value           => $recur->{startDate},
            defaultValue    => $self->get("startDate"),
        });

    # End
    $var->{"formRecurEnd"}
        = q|
        <div><input type="radio" name="recurEndType" id="recurEndType_none" value="none" |.(!$recur->{endDate} && !$recur->{endAfter} ? 'checked="checked"' : '').q|/>
        <label for="recurEndType_none">|. $i18n->get('No end'). q|</label><br />

        <input type="radio" name="recurEndType" id="recurEndType_date" value="date" |.($recur->{endDate} ? 'checked="checked"' : '' ).q| />
        <label for="recurEndType_date">|. $i18n->get('By date'). q| </label>|
        . WebGUI::Form::date($session,{ name => "recurEndDate", value => $recur->{endDate}, defaultValue => $recur->{endDate} })
        . q|
        <br />

        <input type="radio" name="recurEndType" id="recurEndType_after" value="after" |.($recur->{endAfter} ? 'checked="checked"' : '' ).q| />
        <label for="recurEndType_after">|. $i18n->get('After'). q| </label>
        <input type="text" size="3" name="recurEndAfter" value="|.$recur->{endAfter}.q|" />
        |. $i18n->get('occurences'). q|.
        </div>
    |;

    # Include
    # TODO!

    # Exclude
    # TODO!



    # Add button
    $var->{"formSave"}
        = WebGUI::Form::submit($session, {
            name    => "save",
            value   => $i18n->get('62', 'WebGUI'),
        });

    # Cancel button
    $var->{"formCancel"}
        = WebGUI::Form::button($session, {
            name    => "cancel",
            value   => $i18n->get('cancel', 'WebGUI'),
            extras  => 'onClick="window.history.go(-1)"',
        });


    $var->{"formFooter"}    .= <<'ENDJS';
        <script type="text/javascript">
        function toggleTimes() {
            if (document.getElementById("allday_no").checked) {
                document.getElementById("times").style.display = "block";
            }
            else {
                document.getElementById("times").style.display = "none";
            }
        }

        YAHOO.util.Event.onContentReady("times",function(e) { toggleTimes(); });
        YAHOO.util.Event.on("allday_no",'click',function(e) { toggleTimes(); });
        YAHOO.util.Event.on("allday_yes",'click',function(e) { toggleTimes(); });


        function toggleRecur() {
            document.getElementById("recurPattern_daily").style.display = "none";
            document.getElementById("recurPattern_weekly").style.display = "none";
            document.getElementById("recurPattern_monthly").style.display = "none";
            document.getElementById("recurPattern_yearly").style.display = "none";

            if (document.getElementById("recurType_daily").checked) {
                document.getElementById("recurPattern_daily").style.display = "block";
            }
            else if (document.getElementById("recurType_weekly").checked) {
                document.getElementById("recurPattern_weekly").style.display = "block";
            }
            else if (document.getElementById("recurType_monthly").checked) {
                document.getElementById("recurPattern_monthly").style.display = "block";
            }
            else if (document.getElementById("recurType_yearly").checked) {
                document.getElementById("recurPattern_yearly").style.display = "block";
            }
        }
        YAHOO.util.Event.onAvailable("recurPattern",function(e) { toggleRecur(); });
        </script>
ENDJS



    ### Show any errors if necessary
    if ($self->session->stow->get("editFormErrors")) {
        my $errors = $self->session->stow->get("editFormErrors");
        push @{$var->{"formErrors"}}, { message => $_ }
            for @{$errors};
    }



    ### Load the template
    my $parent        = $self->getParent;
    my $template;
    if ($parent) {
        $template
            = WebGUI::Asset::Template->new($session,$parent->get("templateIdEventEdit"));
    }
    else {
        $template
            = WebGUI::Asset::Template->new($session,"CalendarEventEdit00001");
    }



    ### Show the processed template
    $session->http->sendHeader;
    my $style = $self->getParent->processStyle($self->getSeparator);
    my ($head, $foot) = split($self->getSeparator,$style);
    $self->session->output->print($head, 1);
    $self->session->output->print($self->processTemplate($var, undef, $template));
    $self->session->output->print($foot, 1);
    return "chunked";
}





####################################################################

=head2 www_view

Shows the event based on the parent asset's style and Event Details template

=head3 URL Parameters

=over 8

=item print

If true, will show the printable version of the event

=back

=cut

sub www_view {
    my $self = shift;
    return $self->session->privilege->noAccess() unless $self->canView;
    my $check = $self->checkView;
    return $check if (defined $check);
    $self->session->http->setCacheControl($self->get("visitorCacheTimeout")) if ($self->session->user->isVisitor);
    $self->session->http->sendHeader;
    $self->prepareView;
    my $style = $self->getParent->processStyle($self->getSeparator);
    my ($head, $foot) = split($self->getSeparator,$style);
    $self->session->output->print($head,1);
    $self->session->output->print($self->view);
    $self->session->output->print($foot,1);
    return "chunked";
}




=head1 Todo

Pages for Next Occurence >> and Prev Occurrence << on the Event Details page

Shared package global to set how many user defined fields there are.

Fix the Recurrence form. Use WebGUI::Form elements and combine them to create
the form.recurPattern field. If users want to create their own way to make the
pattern, let them.

Fix the Recurrence storage. Add DateTime::Event::ICal and dependencies to WebGUI
and use ICal recurrence rules. Why did I not do this before?

When sending ICalendar feeds, send the Recurrence Rule. Currently I'm not going
to be able to do that.

Recurring events should be created by the commit process, so that it's done
asynchronously with Spectre rather than making the browser wait for a long time
(to make many many events).

Related links need to be implemented using a separate table.

Optimizations!!!

BUG: Events with the same menuTitle, date, and time will not get their Next or
Previous event correctly because of the title. We must check if the title is
equal and then choose by assetId.

=cut

1;

