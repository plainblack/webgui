package WebGUI::Workflow::Activity::CalendarUpdateFeeds;


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

use strict;
use base 'WebGUI::Workflow::Activity';

use WebGUI::Asset::Wobject::Calendar;
use WebGUI::Asset::Event;
use WebGUI::DateTime;
use DateTime::TimeZone;
use Data::Dumper;
use Data::ICal;

use LWP::UserAgent;
use JSON ();

=head1 NAME

Package WebGUI::Workflow::Activity::CalendarUpdateFeeds;

=head1 DESCRIPTION

Imports calendar events from Calendar feeds.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session, "Asset_Calendar");
    push(@{$definition}, {
        name        => $i18n->get("workflow updateFeeds"),
        properties  => { }
    });
    return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self    = shift;
    my $session = $self->session;

    my $object = shift;
    my $instance = shift;
    my $previousUser = $session->user;
    $session->user({userId => 3});

    ### TODO: If we take more than a minute, return WAITING so that some
    # other activity can run
    my $startTime = time();
    my $dt      = WebGUI::DateTime->new($session, $startTime)->toMysql;

    my $eventList   = [];
    my $feedList;
    if ($instance->getScratch('events')) {
        $eventList = JSON::from_json($instance->getScratch('events'));
        $feedList  = JSON::from_json($instance->getScratch('feeds'));
    }
    else {
        my $ua      = LWP::UserAgent->new(agent => "WebGUI");
        my $getCalendar = WebGUI::Asset::Wobject::Calendar->getIsa($session);

        CALENDAR: while (my $calendar = $getCalendar->()) {
            next unless defined $calendar;
            my $calendarTitle = $calendar->getTitle;
            my $calendarId    = $calendar->getId;
            if ( $calendar->get( "state" ) ne "published" ) {
                $session->log->info( "Calendar $calendarTitle ($calendarId) is not state='published', skipping..." );
                next CALENDAR;
            }
            elsif (! scalar @{ $calendar->getFeeds } ) {
                $session->log->info( "Calendar $calendarTitle ($calendarId) has no feeds, skipping..." );
                next CALENDAR;
            }

            $session->log->info( "Calendar $calendarTitle ($calendarId) has feeds, fetching..." );
            #!!! KLUDGE - If the feed is on the same server, set a scratch value
            # I do not know how dangerous this is, so THIS MUST CHANGE!
            # Preferably: Spectre would add a userSession to the database, 
            # and send the appropriate cookie with the request.
            my $sitename    = $session->config->get("sitename")->[0];
            FEED: foreach my $feed (@{ $calendar->getFeeds }) {
                my $url = $feed->{url};
                if ($url =~ m{http://[^/]*$sitename}) {
                    $url .= ( $url =~ /[?]/ ? ";" : "?" ) . "adminId=".$session->getId;
                    $session->db->write("REPLACE INTO userSessionScratch (sessionId,name,value) VALUES (?,?,?)",
                        [$session->getId,$calendar->getId,"SPECTRE"]);
                }

                # Get the feed
                $session->log->info( "Trying Calendar feed ".$url." for $calendarTitle" );
                my $response    = $ua->get($url);

                if (!$response->is_success) {
                    # Update the result and last updated fields
                    $feed->{lastResult}  = $response->message || $response->content;
                    $feed->{lastUpdated} = $dt;
                    $calendar->setFeed($feed->{feedId}, $feed);
                    $session->log->warn( "Calendar feed ".$url." for $calendarTitle failed" );
                    next FEED;
                }

                my $data  = $response->content;
                my $cal   = Data::ICal->new( data => $data );
                if (!$cal) {
                    # Update the result and last updated fields
                    $feed->{lastResult}  = "Error parsing iCal feed";
                    $feed->{lastUpdated} = $dt;
                    $calendar->setFeed($feed->{feedId}, $feed);
                    $session->log->warn( "Calendar feed ".$url." for $calendarTitle could not be parsed" );
                    next FEED;
                }
                my $feedData = $feedList->{$feed->{feedId}} = {
                    added   => 0,
                    updated => 0,
                    errored => 0,
                    assetId => $calendar->getId,
                };
         EVENT: foreach my $entry (@{ $cal->entries }) {
                    next EVENT unless $entry->ical_entry_type eq 'VEVENT';
                    #use Data::Dumper;
                    #warn "EVENT: $id; ".Dumper $events{$id};
                    my $event_properties = $entry->properties;

                    # Prepare event data
                    my $properties  = {
                        feedId      => $feed->{feedId},
                        className   => 'WebGUI::Asset::Event',
                        isHidden    => 1,
                    };
                    PROPERTY: foreach my $property (qw/uid description summary location/) {
                        next PROPERTY unless exists $event_properties->{$property};
                        $properties->{$property} = $event_properties->{$property}->[0]->value;
                    }
                    ##Fixup
                    $properties->{title}     = delete $properties->{summary};
                    $properties->{feedUid}   = delete $properties->{uid};

                    # Prepare the date
                    my $dtstart = $event_properties->{dtstart}->[0]->value;
                    if ($dtstart =~ /T/) {
                        my ($date, $time) = split /T/, $dtstart;

                        my ($year, $month, $day) = $date =~ /(\d{4})(\d{2})(\d{2})/;
                        my ($hour, $minute, $second) = $time =~ /(\d{2})(\d{2})(\d{2})/;
                        my $tz = '';
                        if ($event_properties->{dtstart}->[0]->{tzid}) {
                            $tz = $event_properties->{dtstart}->[0]->{tzid};
                        }
                        if (!$tz || !DateTime::TimeZone->is_valid_name($tz)) {
                            $tz = "UTC";
                        }

                        ($properties->{startDate}, $properties->{startTime}) =
                            split / /, WebGUI::DateTime->new(
                                year    => $year,
                                month   => $month,
                                day     => $day,
                                hour    => $hour,
                                minute  => $minute,
                                second  => $second,
                                time_zone   => $tz,
                            )->toMysql;
                        $properties->{timeZone} = $tz;
                    }
                    elsif ($dtstart =~ /(\d{4})(\d{2})(\d{2})/) {
                        my ($year, $month, $day) = $dtstart =~ /(\d{4})(\d{2})(\d{2})/;
                        $properties->{startDate} = join "-",$year,$month,$day;
                    }
                    elsif ($dtstart) {
                        $session->log->warn(
                            "Workflow::Activity::CalendarUpdateFeeds"
                            . " -- '$dtstart' does not appear to be a valid date"
                        );
                        $feedData->{errored}++;
                        next EVENT;
                    }

                    my $dtend     = exists $event_properties->{dtend}    ? $event_properties->{dtend}->[0]->value    : undef;
                    my $duration  = exists $event_properties->{duration} ? $event_properties->{duration}->[0]->value : undef;
                    if ($dtend =~ /T/) {
                        my ($date, $time) = split /T/, $dtend;

                        my ($year, $month, $day) = $date =~ /(\d{4})(\d{2})(\d{2})/;
                        my ($hour, $minute, $second) = $time =~ /(\d{2})(\d{2})(\d{2})/;
                        my $tz = '';
                        if (!$tz || !DateTime::TimeZone->is_valid_name($tz)) {
                            $tz = "UTC";
                        }

                        ($properties->{endDate}, $properties->{endTime}) = 
                            split / /, WebGUI::DateTime->new(
                                year    => $year,
                                month   => $month,
                                day     => $day,
                                hour    => $hour,
                                minute  => $minute,
                                second  => $second,
                                time_zone   => $tz,
                            )->toMysql;
                        $properties->{timeZone} = $tz;
                    }
                    elsif ($dtend =~ /(\d{4})(\d{2})(\d{2})/) {
                        my ($year, $month, $day) = $dtend =~ /(\d{4})(\d{2})(\d{2})/;

                        my $endDateLet = WebGUI::DateTime->new( year => $year, month => $month, day => $day);
                        $endDateLet->subtract( days => 1 );
                        $properties->{endDate} = $endDateLet->toDatabaseDate;
                    }
                    # If we can't parse it, forget the whole event 
                    elsif ($dtend) {
                        $session->log->warn(
                            "Workflow::Activity::CalendarUpdateFeeds"
                            . " -- '$dtend' does not appear to be a valid date"
                        );
                        $feedData->{errored}++;
                        next EVENT;
                    }
                    # No dtend, but we have duration!
                    elsif ($duration) {
                        my ($days, $hours, $minutes, $seconds)
                            = $duration =~ m{
                                P
                                (?:(\d+)D)?   # Days
                                T
                                (?:(\d+)H)?   # Hours
                                (?:(\d+)M)?   # Minutes
                                (?:(\d+)S)?   # Seconds
                            }ix;
                        my $startDate   = $properties->{startDate};
                        # Fill in bogus value to get a WebGUI::DateTime object,
                        # we'll figure out what we actually need later
                        my $startTime   = $properties->{startTime} || "00:00:00";
                        my $datetime    = WebGUI::DateTime->new($session,$startDate." ".$startTime);

                        $datetime->add(
                            days        => $days    || 0,
                            hours       => $hours   || 0,
                            minutes     => $minutes || 0,
                            seconds     => $seconds || 0,
                        );

                        $properties->{endDate}  = $datetime->toDatabaseDate;
                        # If it not an all-day event, set the end time too
                        if ($properties->{startTime}) {
                            $properties->{endTime}  = $datetime->toDatabaseTime;
                        }
                    }
                    # No dtend, no duration, just copy the start
                    else {
                        $properties->{endDate} = $properties->{startDate};
                        $properties->{endTime} = $properties->{startTime};
                    }

                    # If there are X-WebGUI-* fields
                    PROPERTY: foreach my $key (qw/groupIdEdit groupIdView url menuTitle timeZone/) {
                        my $property_name   = 'x-webgui-'.lc $key;
                        next PROPERTY unless exists $event_properties->{$property_name};
                        $properties->{$key} = $event_properties->{$property_name}->[0]->value;
                    }

                    my $recur;
                    if (exists $event_properties->{rrule}) {
                        $recur = _icalToRecur($session, $properties->{startDate}, $event_properties->{rrule}->[0]->value);
                    }

                    # save events for later
                    push @$eventList, {
                        properties  => $properties,
                        recur       => $recur,
                    };
                }
            }
        }
    }
    my $currentVersionTag = WebGUI::VersionTag->getWorking($session, 1);
    if ($currentVersionTag) {
        $currentVersionTag->clearWorking;
    }
    my $ttl = $self->getTTL;
    $session->log->info( "Have to add " . scalar( @$eventList ) . " events..." );
    while (@{ $eventList }) {
        if ($startTime + $ttl < time()) {
            $instance->setScratch('events', JSON::to_json($eventList));
            $instance->setScratch('feeds',  JSON::to_json($feedList));
            my $newVersionTag = WebGUI::VersionTag->getWorking($session, 1);
            if ($newVersionTag) {
                $newVersionTag->requestCommit;
            }
            if ($currentVersionTag) {
                $currentVersionTag->setWorking;
            }
            $session->user({user => $previousUser});
            return $self->WAITING(1);
        }
        my $eventData  = shift @$eventList;
        my $recur      = $eventData->{recur};
        my $properties = $eventData->{properties};
        my $id         = $properties->{feedUid};
        my $feed       = $feedList->{$properties->{feedId}};

        # Update event
        my $assetId   = $session->db->quickScalar("select assetId from Event where feedUid=?",[$id]);

        # If this event already exists, update
        if ($assetId) {
            $session->log->info( "Updating existing asset $assetId" );
            my $event   = WebGUI::Asset->newByDynamicClass($session,$assetId);

            if ($event) {
                $event->update($properties);
                $feed->{updated}++;
            }
        }
        else {
            $session->log->info( "Creating new Event!" );
            my $calendar = WebGUI::Asset->newByDynamicClass($session,$feed->{assetId});
            my $event   = $calendar->addChild($properties, undef, undef, { skipAutoCommitWorkflows => 1});
            $feed->{added}++;
            if ($recur) {
                $event->setRecurrence($recur);
                $event->generateRecurringEvents;
            }
        }

        # TODO: Only update if last-updated field is 
        # greater than the event's lastUpdated property
        $session->log->info( scalar @$eventList . " events left to load" );
    }
    my $newVersionTag = WebGUI::VersionTag->getWorking($session, 1);
    if ($newVersionTag) {
        $newVersionTag->requestCommit;
    }
    if ($currentVersionTag) {
        $currentVersionTag->setWorking;
    }
    for my $feedId (keys %$feedList) {
        my $feed = $feedList->{$feedId};
        my $calendar = WebGUI::Asset->newByDynamicClass($session, $feed->{assetId});
        my $feedData = $calendar->getFeed($feedId);
        $feedData->{lastResult}  = "Success! $feed->{added} added, $feed->{updated} updated, $feed->{errored} parsing errors";
        $feedData->{lastUpdated} = $dt;
        $calendar->setFeed($feedId, $feedData);
    }
    $instance->deleteScratch('events');
    $instance->deleteScratch('feeds');
    $session->user({user => $previousUser});
    return $self->COMPLETE;
}

# We need to use ical format for everything, but this is a stopgap until then.
sub _icalToRecur {
    my $session = shift;
    my $startDate = shift;
    my $rrule = lc shift;
    my $ical = {
        map {split /=/} split(/;/, $rrule)
    };
    my $date = WebGUI::DateTime->new($session, "$startDate 00:00:00");
    my $startWeekDay = substr('umtwrfs', $date->day_of_week % 7, 1);

    my $icalDays = {
        su => 'u',
        mo => 'm',
        tu => 't',
        we => 'w',
        th => 'r',
        fr => 'f',
        sa => 's',
    };

    my $icalMonths = {
        1 => 'jan',
        2 => 'feb',
        3 => 'mar',
        4 => 'apr',
        5 => 'may',
        6 => 'jun',
        7 => 'jul',
        8 => 'aug',
        9 => 'sep',
        10 => 'oct',
        11 => 'nov',
        12 => 'dec',
    };

    my $recur = {
        startDate   => $startDate,
        every       => $ical->{interval} || 1,
    };
    my $type = lc $ical->{"freq"};

    if ($type eq "daily") {
        $recur->{recurType} = 'daily';
    }
    elsif ($type eq "weekly") {
        $recur->{recurType} = 'weekly';
        $recur->{dayNames} = [];
        for my $day (split /,/, $ical->{byday}) {
            push @{$recur->{dayNames}}, $icalDays->{$day};
        }
        if(!@{$recur->{dayNames}}) {
            $recur->{dayNames} = [ $startWeekDay ];
        }
        elsif (!defined $recur->{dayNames}->[0]) {
            warn "---$ical->{byday}--- length:" . length($ical->{byday});
        }
    }
    elsif ($type eq "monthly") {
        $recur->{recurType} = "monthDay";
        $recur->{dayNumber} = $ical->{bymonthday};
    }
    elsif ($type eq "yearly") {
        $recur->{recurType} = "yearDay";
        $recur->{dayNumber} = $ical->{bymonthday};
        $recur->{months} = [
            map { $icalMonths->{lc $1} } split(',', $ical->{bymonth})
        ];
    }

    if ($ical->{count}) {
        $recur->{endAfter} = $ical->{count};
    }
    elsif ($ical->{until}) {
        $recur->{endDate} = (_icalToMySQL($ical->{until}))[0]; 
    }
    else {
        $recur->{endDate} = $date->clone->add(years => 2)->toDatabaseDate;
    }

    return $recur;
}

sub _icalToMySQL {
    my $dt = shift;
    my ($date, $time) = split /t/, $dt;

    my ($year, $month, $day) = $date =~ /(\d{4})(\d{2})(\d{2})/;
    my ($hour, $minute, $second) = $time =~ /(\d{2})(\d{2})(\d{2})/;
    return split / /, WebGUI::DateTime->new(
        year    => $year,
        month   => $month,
        day     => $day,
        hour    => $hour,
        minute  => $minute,
        second  => $second,
    )->toMysql;
}

=head2 _unwrapIcalText

This really just unescapes iCal text, handling commas, semi-colons, backslashes
and newlines

=cut

sub _unwrapIcalText {
    my $text = shift;
    $text =~ s/\\([,;\\])/$1/g;
    $text =~ s/\\n/\n/g;
    return $text;
}

=head1 BUGS

We should probably be using some sort of parser for the iCalendar files. I did
not have time to make a decent observation but the following were observed and
rejected

 Data::ICal - Best one I saw. Rejected because I've run out of time
 Text::vFile    
 Net::ICal
 iCal::Parser   - Bad data structure
 Tie::iCal

=cut

1;


