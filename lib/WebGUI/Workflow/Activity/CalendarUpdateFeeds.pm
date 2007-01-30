package WebGUI::Workflow::Activity::CalendarUpdateFeeds;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use warnings;
use base 'WebGUI::Workflow::Activity';

use WebGUI::Asset::Wobject::Calendar;
use WebGUI::Asset::Event;
use WebGUI::DateTime;

use LWP::UserAgent;


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

See WebGUI::Workflow::Activity::defintion() for details.

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
	$self->session->user({userId => 3});
	
    ### TODO: If we take more than a minute, return WAITING so that some
    # other activity can run
	
	my $ua		= LWP::UserAgent->new(agent => "WebGUI");
	my $dt		= WebGUI::DateTime->new($session, time)->toMysql;
	
	my $sth	    = $self->session->db->prepare("select * from Calendar_feeds");
	$sth->execute();
	
	
	FEED:while (my $feed = $sth->hashRef) {
		#!!! KLUDGE - If the feed is on the same server, set a scratch value
		# I do not know how dangerous this is, so THIS MUST CHANGE!
		# Preferably: Spectre would add a userSession to the database, 
		# and send the appropriate cookie with the request.
		my $sitename	= $self->session->config->get("sitename")->[0];
		if ($feed->{url} =~ m{http://[^/]*$sitename})
		{
			$feed->{url} .= ( $feed->{url} =~ /[?]/ ? ";" : "?" ) . "adminId=".$session->getId;
			$self->session->db->write("REPLACE INTO userSessionScratch (sessionId,name,value) VALUES (?,?,?)",
				[$session->getId,$feed->{assetId},"SPECTRE"]);
		}
		#/KLUDGE
		#warn "FEED URL: ".$feed->{url} ."\n";
		
		
		
		## Somebody point me to a DECENT iCalendar parser...
		# Text::vFile perhaps?
		
		# Get the feed
		my $response	= $ua->get($feed->{url});
		
		if ($response->is_success)
		{
			my $data	= $response->content;
			
			# If doesn't start with BEGIN:VCALENDAR then error
			unless ($data =~ /^BEGIN:VCALENDAR/i)
			{
				# Update the result and last updated fields
				$self->session->db->write(
                    "update Calendar_feeds set lastResult=?,lastUpdated=? where feedId=?",
					["Not an iCalendar feed",$dt,$feed->{feedId}]);
				next FEED;
			}
			
			
			my $active		= 0;	# Parser on/off
			my %current_event	= ();
			my $current_entry	= "";
			my %events;
			my $line_number		= 0;
			for my $line (split /[\r\n]+/,$data)
			{
				chomp $line;
				$line_number++;
				next unless $line =~ /\w/;
				
				#warn "LINE $line_number: $line\n";
				
				if ($line =~ /^BEGIN:VEVENT$/i)
				{
					$active	= 1;
				}
				elsif ($line =~ /^END:VEVENT$/i)
				{
					$active = 0;
					# Flush event
					my $uid	= lc $current_event{uid}[1];
					delete $current_event{uid};
					$events{$uid} = {%current_event};
					%current_event	= ();
				}
				elsif ($line =~ /^ /)
				{
					# Add to entry data
					$current_entry .= substr $line, 1;
				}
				else
				{
					# Flush old entry
					# KEY;ATTRIBUTE=VALUE;ATTRIBUTE=VALUE:KEYVALUE
					my ($key_attrs,$value) = split /:/,$current_entry,2;
					
					my @attrs	= split /;/, $key_attrs;
					my $key		= shift @attrs;
					my %attrs;
					while (my $attribute = shift @attrs)
					{
						my ($attr_key, $attr_value) = split /=/, $attribute, 2;
						$attrs{lc $attr_key} = $attr_value;
					}
					
					# Unescape value
					
					
					$current_event{lc $key} = [\%attrs,$value];
					
					# Start new entry
					$current_entry	= $line;
				}
			}
			
			my $added	= 0;
			my $updated	= 0;
			for my $id (keys %events)
			{
				#use Data::Dumper;
				#warn "EVENT: $id; ".Dumper $events{$id};
				
				# Prepare event data
				my $properties	= {
					feedUid		=> $id,
					feedId		=> $feed->{feedId},
					description	=> $events{$id}->{description}->[1],
					title		=> $events{$id}->{summary}->[1],
					menuTitle	=> substr($events{$id}->{summary}->[1],0,15),
					className	=> 'WebGUI::Asset::Event',
					isHidden	=> 1,
					};
				
				# Prepare the date
				my $dtstart	= $events{$id}->{dtstart}->[1];
				if ($dtstart =~ /T/)
				{
					my ($date, $time) = split /T/, $dtstart;
					
					my ($year, $month, $day) = $date =~ /(\d{4})(\d{2})(\d{2})/;
					my ($hour, $minute, $second) = $time =~ /(\d{2})(\d{2})(\d{2})/;
					
					($properties->{startDate}, $properties->{startTime}) = 
						split / /, WebGUI::DateTime(
							year	=> $year,
							month	=> $month,
							day	=> $day,
							hour	=> $hour,
							minute	=> $minute,
							second	=> $second,
							time_zone	=> "UTC",
							)->toMysql;
				}
				elsif ($dtstart =~ /(\d{4})(\d{2})(\d{2})/)
				{
					my ($year, $month, $day) = $dtstart =~ /(\d{4})(\d{2})(\d{2})/;
					
					$properties->{startDate} = join "-",$year,$month,$day;
				}
				
				my $dtend	= $events{$id}->{dtend}->[1];
				if ($dtend =~ /T/)
				{
					my ($date, $time) = split /T/, $dtend;
					
					my ($year, $month, $day) = $date =~ /(\d{4})(\d{2})(\d{2})/;
					my ($hour, $minute, $second) = $time =~ /(\d{2})(\d{2})(\d{2})/;
					
					($properties->{endDate}, $properties->{endTime}) = 
						split / /, WebGUI::DateTime(
							year	=> $year,
							month	=> $month,
							day	=> $day,
							hour	=> $hour,
							minute	=> $minute,
							second	=> $second,
							time_zone	=> "UTC",
							)->toMysql;
				}
				elsif ($dtend =~ /(\d{4})(\d{2})(\d{2})/)
				{
					my ($year, $month, $day) = $dtend =~ /(\d{4})(\d{2})(\d{2})/;
					
					$properties->{endDate} = join "-",$year,$month,$day;
				}
				
				
				
				# If there are X-WebGUI-* fields
				for my $key (grep /^X-WEBGUI-/, keys %{$events{$id}})
				{
					my $property_name	= $key;
					$property_name	=~ s/^X-WEBGUI-//;
					
					if (lc $property_name eq "groupidedit")
					{
						$properties->{groupIdEdit} = $events{$id}->{$key}->[1];
					}
					elsif (lc $property_name eq "groupidview")
					{
						$properties->{groupIdView} = $events{$id}->{$key}->[1];
					}
					elsif (lc $property_name eq "url")
					{
						$properties->{url} = $events{$id}->{$key}->[1];
					}
				}
				
				
				# Update event
				my ($assetId)	= $self->session->db->quickArray("select assetId from Event where feedUid=?",[$id]);
				
				# If this event already exists, update
				if ($assetId)
				{
					#warn "Updating $assetId\n";
					
					my $event	= WebGUI::Asset->newByDynamicClass($self->session,$assetId);
					
					if ($event)
					{
						$event->update($properties);
						$updated++;
					}
				}
				else
				{
					my $calendar	= WebGUI::Asset->newByDynamicClass($self->session,$feed->{assetId});
					my $event	= $calendar->addChild($properties);
					$event->requestAutoCommit;
					$added++;
				}
				
				# TODO: Only update if last-updated field is 
				# greater than the event's lastUpdated property
			}
			
			# Update the result and last updated fields
			$self->session->db->write("update Calendar_feeds set lastResult=?,lastUpdated=? where feedId=?",
				["Success! $added added, $updated updated",$dt,$feed->{feedId}]);
		}
		else
		{
			# Update the result and last updated fields
			$self->session->db->write("update Calendar_feeds set lastResult=?,lastUpdated=? where feedId=?",
				[$response->message,$dt,$feed->{feedId}]);
		}
	}
	
	$sth->finish;
	
	return $self->COMPLETE;
}


=head1 BUGS

We should probably be using some sort of parser for the iCalendar files. I did
not have time to make a decent observation but the following were observed and
rejected

 Data::ICal	- Best one I saw. Rejected because I've run out of time
 Text::vFile	
 Net::ICal
 iCal::Parser	- Bad data structure
 Tie::iCal

=cut

1;


