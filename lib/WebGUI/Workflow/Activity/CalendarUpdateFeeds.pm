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
        $feedList = JSON::from_json($instance->getScratch('feeds'));
    }
    else {
        my $ua      = LWP::UserAgent->new(agent => "WebGUI");
        my $sth     = $self->session->db->read("select * from Calendar_feeds");

        FEED: while (my $feed = $sth->hashRef) {
            my $calendar = WebGUI::Asset->newByDynamicClass($self->session,$feed->{assetId});
            if (!defined $calendar) {
                $self->session->errorHandler->error("Calendar object failed to instanciate.  Did you commit the calendar wobject?");
                next FEED;
            }
            elsif ( $calendar->get( "state" ) ne "published" ) {
                $self->session->errorHandler->info( "Calendar is not state='published', skipping..." );
                next FEED;
            }
            
            #!!! KLUDGE - If the feed is on the same server, set a scratch value
            # I do not know how dangerous this is, so THIS MUST CHANGE!
            # Preferably: Spectre would add a userSession to the database, 
            # and send the appropriate cookie with the request.
            my $sitename    = $self->session->config->get("sitename")->[0];
            if ($feed->{url} =~ m{http://[^/]*$sitename})
            {
                $feed->{url} .= ( $feed->{url} =~ /[?]/ ? ";" : "?" ) . "adminId=".$session->getId;
                $self->session->db->write("REPLACE INTO userSessionScratch (sessionId,name,value) VALUES (?,?,?)",
                    [$session->getId,$feed->{assetId},"SPECTRE"]);
            }
            #/KLUDGE

            ## Somebody point me to a DECENT iCalendar parser...
            # Text::vFile perhaps?
            
            # Get the feed
            my $response    = $ua->get($feed->{url});
    
            if (!$response->is_success) {
                # Update the result and last updated fields
                $self->session->db->write("update Calendar_feeds set lastResult=?,lastUpdated=? where feedId=?",
                    [($response->message || $response->content),$dt,$feed->{feedId}]);
                next FEED;
            }

            my $data    = $response->content;
            # If doesn't start with BEGIN:VCALENDAR then error
            unless ($data =~ /^BEGIN:VCALENDAR/i) {
                # Update the result and last updated fields
                $self->session->db->write(
                    "update Calendar_feeds set lastResult=?,lastUpdated=? where feedId=?",
                    ["Not an iCalendar feed",$dt,$feed->{feedId}]);
                next FEED;
            }

            my $active      = 0;    # Parser on/off
            my %current_event   = ();
            my %events;
            my $line_number     = 0;
            $data =~ s/[ \t]?[\r\n]+[ \t]+/ /msg; #Process line continuations
            LINE: for my $line (split /[\r\n]+/,$data) {
                chomp $line;
                $line_number++;
                next unless $line =~ /\w/;
                
                #warn "LINE $line_number: $line\n";
                
                if ($line =~ /^BEGIN:VEVENT$/i) {
                    $active = 1;
                    next LINE;
                }
                elsif ($line =~ /^END:VEVENT$/i) {
                    $active = 0;
                    # Flush event
                    my $uid = lc $current_event{uid}[1];
                    delete $current_event{uid};
                    $events{$uid} = {%current_event};
                    $self->session->log->info( "Found event $uid from feed " . $feed->{feedId} );
                    %current_event  = ();
                    next LINE;
                }
                else {
                    # Flush old entry
                    # KEY;ATTRIBUTE=VALUE;ATTRIBUTE=VALUE:KEYVALUE
                    my ($key_attrs,$value) = split /:/,$line,2;
                    my @attrs   = $key_attrs ? (split /;/, $key_attrs) : ();
                    my $key     = shift @attrs;
                    my %attrs;
                    while (my $attribute = shift @attrs) {
                        my ($attr_key, $attr_value) = split /=/, $attribute, 2;
                        $attrs{lc $attr_key} = $attr_value;
                    }
                    
                    $current_event{lc $key} = [\%attrs,$value];
                }
            }
            
            my $feedData = $feedList->{$feed->{feedId}} = {
                added   => 0,
                updated => 0,
                errored => 0,
                assetId => $feed->{assetId},
            };
     EVENT: for my $id (keys %events) {
                #use Data::Dumper;
                #warn "EVENT: $id; ".Dumper $events{$id};
                
                # Prepare event data
                my $properties  = {
                    feedUid     => $id,
                    feedId      => $feed->{feedId},
                    description => _unwrapIcalText($events{$id}->{description}->[1]),
                    title       => _unwrapIcalText($events{$id}->{summary}->[1]),
                    location    => _unwrapIcalText($events{$id}->{location}->[1]),
                    menuTitle   => substr($events{$id}->{summary}->[1],0,15),
                    className   => 'WebGUI::Asset::Event',
                    isHidden    => 1,
                };
                
                # Prepare the date
                my $dtstart = $events{$id}->{dtstart}->[1];
                if ($dtstart =~ /T/) {
                    my ($date, $time) = split /T/, $dtstart;
                    
                    my ($year, $month, $day) = $date =~ /(\d{4})(\d{2})(\d{2})/;
                    my ($hour, $minute, $second) = $time =~ /(\d{2})(\d{2})(\d{2})/;
                    my $tz = $events{$id}->{dtstart}->[0]->{tzid};
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
                    $session->errorHandler->warn(
                        "Workflow::Activity::CalendarUpdateFeeds"
                        . " -- '$dtstart' does not appear to be a valid date"
                    );
                    $feedData->{errored}++;
                    next EVENT;
                }
                
                my $dtend       = $events{$id}->{dtend}->[1];
                my $duration    = $events{$id}->{duration}->[1];
                if ($dtend =~ /T/) {
                    my ($date, $time) = split /T/, $dtend;
                    
                    my ($year, $month, $day) = $date =~ /(\d{4})(\d{2})(\d{2})/;
                    my ($hour, $minute, $second) = $time =~ /(\d{2})(\d{2})(\d{2})/;
                    my $tz = $events{$id}->{dtend}->[0]->{tzid};
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
                    
                    $properties->{endDate} = join "-",$year,$month,$day;
                }
                # If we can't parse it, forget the whole event 
                elsif ($dtend) {
                    $session->errorHandler->warn(
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
                for my $key (grep /^x-webgui-/, keys %{$events{$id}}) {
                    my $property_name   = $key;
                    $property_name  =~ s/^x-webgui-//;
                    $property_name  = lc $property_name;
                    
                    if ($property_name eq "groupidedit")
                    {
                        $properties->{groupIdEdit} = $events{$id}->{$key}->[1];
                    }
                    elsif ($property_name eq "groupidview")
                    {
                        $properties->{groupIdView} = $events{$id}->{$key}->[1];
                    }
                    elsif ($property_name eq "url")
                    {
                        $properties->{url} = $events{$id}->{$key}->[1];
                    }
                    elsif ($property_name eq "menutitle")
                    {
                        $properties->{menuTitle} = $events{$id}->{$key}->[1];
                    }
                }

                my $recur;
                if ($events{$id}->{rrule}) {
                    $recur = _icalToRecur($session, $properties->{startDate}, $events{$id}->{rrule}->[1]);
                }
                
                # save events for later
                push @$eventList, {
                    properties  => $properties,
                    recur       => $recur,
                };
            }
        }
    }
    my $currentVersionTag = WebGUI::VersionTag->getWorking($self->session, 1);
    if ($currentVersionTag) {
        $currentVersionTag->clearWorking;
    }
    my $ttl = $self->getTTL;
    $self->session->log->info( "Have to add " . scalar( @$eventList ) . " events..." );
    while (@$eventList) {
        if ($startTime + $ttl < time()) {
            $instance->setScratch('events', JSON::to_json($eventList));
            $instance->setScratch('feeds', JSON::to_json($feedList));
            my $newVersionTag = WebGUI::VersionTag->getWorking($self->session, 1);
            if ($newVersionTag) {
                $newVersionTag->requestCommit;
            }
            if ($currentVersionTag) {
                $currentVersionTag->setWorking;
            }
            $session->user({user => $previousUser});
            return $self->WAITING(1);
        }
        my $eventData = shift @$eventList;
        my $recur = $eventData->{recur};
        my $properties = $eventData->{properties};
        my $id = $properties->{feedUid};
        my $feed = $feedList->{$properties->{feedId}};

        # Update event
        my $assetId   = $self->session->db->quickScalar("select assetId from Event where feedUid=?",[$id]);
        
        # If this event already exists, update
        if ($assetId) {
            $self->session->log->info( "Updating existing asset $assetId" );
            my $event   = WebGUI::Asset->newByDynamicClass($self->session,$assetId);
            
            if ($event) {
                $event->update($properties);
                $feed->{updated}++;
            }
        }
        else {
            $self->session->log->info( "Creating new Event!" );
            my $calendar = WebGUI::Asset->newByDynamicClass($self->session,$feed->{assetId});
            my $event   = $calendar->addChild($properties, undef, undef, { skipAutoCommitWorkflows => 1});
            $feed->{added}++;
            if ($recur) {
                $event->setRecurrence($recur);
                $event->generateRecurringEvents;
            }
        }
        
        # TODO: Only update if last-updated field is 
        # greater than the event's lastUpdated property
        $self->session->log->info( scalar @$eventList . " events left to load" );
    }
    my $newVersionTag = WebGUI::VersionTag->getWorking($self->session, 1);
    if ($newVersionTag) {
        $newVersionTag->requestCommit;
    }
    if ($currentVersionTag) {
        $currentVersionTag->setWorking;
    }
    for my $feedId (keys %$feedList) {
        my $feed = $feedList->{$feedId};
        $self->session->db->write("update Calendar_feeds set lastResult=?,lastUpdated=? where feedId=?",
            ["Success! $feed->{added} added, $feed->{updated} updated, $feed->{errored} parsing errors",$dt,$feedId]);
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


