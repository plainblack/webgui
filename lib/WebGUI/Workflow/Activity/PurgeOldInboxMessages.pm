package WebGUI::Workflow::Activity::PurgeOldInboxMessages;


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
use WebGUI::Asset;

=head1 NAME

Package WebGUI::Workflow::Activity::PurgeOldInboxMessages

=head1 DESCRIPTION

Removes old, completed inbox messages from the database

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
    my $i18n        = WebGUI::International->new($session, "Workflow_Activity_PurgeOldInboxMessages");

    push @{$definition}, {
        name        => $i18n->get("activityName"),
        properties  => {
            purgeAfter  => {
                fieldType       => "interval",
                defaultValue    => 60 * 60 * 24 * 365,
                label           => $i18n->get("editForm purgeAfter label"),
                hoverHelp       => $i18n->get("editForm purgeAfter description"),
            },
        },
    };
    
    return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my ($self, $nothing, $instance) = @_;
    my $session     = $self->session;
    my $log         = $session->errorHandler;

    # keep track of how much time it's taking
    my $start   = time;
    my $limit   = 2_500;

    my $sth 
        = $session->db->read(
            "SELECT messageId FROM inbox WHERE completedOn IS NOT NULL AND dateStamp < ?",
            [ $start - $self->get('purgeAfter') ],
        );

    while ( ( my $messageId ) = $sth->array ) {
        $session->db->write(
            "DELETE FROM inbox WHERE messageId = ?",
            [ $messageId ],
        );

        # give up if we're taking too long
        if (time - $start > 120) { 
            $sth->finish;
            return $self->WAITING(1);
        } 
    }
    
    # If there are more messages waiting to be purged, return WAITING
    if ( $sth->rows >= $limit ) {
        return $self->WAITING(1);
    }
    else {
        return $self->COMPLETE;
    }
}




1;


