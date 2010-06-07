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
use WebGUI::Inbox::Message;

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
    my ($self, undef, $instance) = @_;
    my $session     = $self->session;

    # keep track of how much time it's taking
    my $endTime   = time() + $self->getTTL;;

    my $sth 
        = $session->db->read(
            "SELECT messageId FROM inbox WHERE completedOn IS NOT NULL AND dateStamp < ?",
            [ time() - $self->get('purgeAfter') ],
        );

    MESSAGE: while ( ( my $messageId ) = $sth->array ) {
        # give up if we're taking too long
        if (time() > $endTime) {
            $sth->finish;
            return $self->WAITING(1);
        }

        my $message = WebGUI::Inbox::Message->new($session, $messageId);
        next MESSAGE unless $message;
        $message->purge;
    }
    
    $sth->finish;
    return $self->COMPLETE;
}

1;
