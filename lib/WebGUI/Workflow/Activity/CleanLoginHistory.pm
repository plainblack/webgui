package WebGUI::Workflow::Activity::CleanLoginHistory;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use DateTime;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Workflow::Activity::CleanLoginHistory

=head1 DESCRIPTION

Deletes some of the old cruft from the userLoginLog table.

=head1 SYNOPSIS

Clean up the userLoginLog for space using age and last login preservation rules

=cut

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, "Workflow_Activity_CleanLoginHistory" );
    push(
        @{$definition}, {
            name       => $i18n->get("activityName"),
            properties => {
                ageToDelete => {
                    fieldType    => "interval",
                    label        => $i18n->get("age to delete"),
                    defaultValue => 60 * 60 * 24 * 90,
                    hoverHelp    => $i18n->get("age to delete help")
                },
                retainLastAlways => {
                    fieldType    => "yesNo",
                    defaultValue => 0,
                    label        => $i18n->get("retain last login is enabled"),
                    hoverHelp    => $i18n->get("retain last login is enabled help")
                },
            }
        }
    );
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self = shift;
    my $db   = $self->session->db;

    my $time = DateTime->now->set_time_zone('UTC')->epoch;
    my $epochTimeStamp = $time - ( $self->get("ageToDelete") );

    if ( not $self->get("retainLastAlways") ) {    # Brutish clean-up
        $db->write( "DELETE FROM userLoginLog WHERE timeStamp < ?", [$epochTimeStamp] );
    }
    else {                                         # Retain at least one login record for every user

        # Get only userIds for users with login information preceding ageToDelete
        my $sth = $db->read( "SELECT DISTINCT userId FROM userLoginLog WHERE timeStamp < ? ORDER BY timeStamp",
            [$epochTimeStamp] );

        my $finishTime = time() + $self->getTTL;

    USERLOOP: while ( my (@userIdData) = $sth->array ) {
            return $self->WAITING(1) if time() > $finishTime;

            my $userId = $userIdData[0];

            my @userTimes
                = $db->buildArray( "SELECT timeStamp FROM userLoginLog WHERE userId=? ORDER BY timeStamp desc",
                [$userId] );

            # Always preserve the most recent login, especially if it is older than ageToDelete.
            shift @userTimes;

            # Only delete times older than ageToDelete (retain all recent records)
            my @deleteTimes = ();
            while ( my $ts = shift @userTimes ) {
                push @deleteTimes, $ts if $ts < $epochTimeStamp;
            }

            # Stop if there are no records preceding ageToDelete
            next USERLOOP unless @deleteTimes;

            my $inTimes = $db->quoteAndJoin( \@deleteTimes );
            $db->write( "DELETE FROM userLoginLog WHERE userId = ? AND timeStamp IN ($inTimes)", [$userId] );
        } ## end while ( my (@userIdData) ...
    } ## end else [ if ( not $self->get("retainLastAlways"...
    return $self->COMPLETE;
} ## end sub execute

1;
