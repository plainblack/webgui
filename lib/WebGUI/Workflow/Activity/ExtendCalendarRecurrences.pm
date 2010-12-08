package WebGUI::Workflow::Activity::ExtendCalendarRecurrences;

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
use WebGUI::International;
use WebGUI::Asset;
use DateTime;

=head1 NAME

WebGUI::Workflow::Activity::ExtendCalendarRecurrences

=head1 DESCRIPTION

Generates events for all active calendar recurring events up to 2 years in the
future.

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
    my ( $class, $session, $definition ) = @_;
    my $i18n = WebGUI::International->new( $session, 'Activity_ExtendCalendarRecurrences' );
    push( @$definition, { name => $i18n->get('topicName') } );
    return $class->SUPER::definition( $session, $definition );
}

#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my ( $self, $obj, $instance ) = @_;
    my $timeLimit = time + $self->getTTL;

    my $piped = $instance->getScratch('recurrences')
        || $self->generateRecurrenceList();

    while (time < $timeLimit ) {
        return $self->COMPLETE unless $piped;
        my ( $recurId, $rest ) = split /\|/, $piped, 2;

        $self->processRecurrence( $recurId, $timeLimit );
        $piped = $rest;
    }

    $instance->setScratch( recurrences => $piped );
    return $self->WAITING(1);
} ## end sub execute

#-------------------------------------------------------------------

=head2 findRecurrenceIds ( calendarId )

Find all recurIds for the given calendarId.

=cut 

sub findRecurrenceIds {
    my ( $self, $calendarId ) = @_;
    my $sql = q{
		SELECT r.recurId
		FROM   Event_recur r
		INNER JOIN Event   e ON r.recurId = e.recurId
		INNER JOIN asset   a ON e.assetId = a.assetId
		WHERE  a.parentId = ?
	};
    return $self->session->db->buildArrayRef( $sql, [ $calendarId ] );
}

#-------------------------------------------------------------------

=head2 findCalendarIds

Returns an arrayref of assetIds for all Calendar assets in the asset tree.

=cut 

sub findCalendarIds {
    my $self = shift;
    my $root = WebGUI::Asset->getRoot( $self->session );
    return $root->getLineage( ['descendants'], { includeOnlyClasses => ['WebGUI::Asset::Wobject::Calendar'] } );
}

#-------------------------------------------------------------------

=head2 findLastEventId ( recurId )

Returns the assetId of the most WebGUI::Asset::Event generated for the given
recurrence.

=cut 

sub findLastEventId {
    my ( $self, $recurId ) = @_;
    my $sql = q{
		SELECT   assetId
		FROM     Event
		WHERE    recurId = ?
		ORDER BY startDate
		LIMIT 1
	};
    return $self->session->db->quickScalar( $sql, [$recurId] );
}

#-------------------------------------------------------------------

=head2 generateRecurrenceList ()

Returns a string of pipe-seperated recurrence IDs for all the calendars in the
asset tree.  This is called exactly once per workflow instance.

=cut 

sub generateRecurrenceList {
    my $self = shift;
    return join( '|', map { @{ $self->findRecurrenceIds($_) } } @{ $self->findCalendarIds } );
}

#-------------------------------------------------------------------

=head2 processRecurrence (recurId, timeLimit)

Generates as many WebGUI::Asset::Event objects as it can before timeLimit is
up or the recurrence is finished for the given recurId.  Returns true if it
exhausted the recurrence, false otherwise.

=cut 

sub processRecurrence {
    my ( $self, $recurId, $timeLimit ) = @_;
    my $eventId = $self->findLastEventId($recurId);
    my $event   = WebGUI::Asset::Event->new( $self->session, $eventId );
    if (! $event) {
        $self->session->log->warn("Unable to instanciate event with assetId $eventId");
        return 0;
    }
    my $recur   = $event->getRecurrence;

    my $start   = $event->getDateTimeStart->truncate(to => 'day');
    my $limit   = DateTime->today->add( years => 2 );
    my $end     = $event->limitedEndDate($limit);
    my $set     = $event->dateSet( $recur, $start, $end );
    my $i       = $set->iterator;

    while ( my $d = $i->next ) {
        return if ( time > $timeLimit );
        $event->generateRecurrence($d);
    }

    return 1;
} ## end sub processRecurrence

1;
