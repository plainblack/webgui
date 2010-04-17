package WebGUI::Workflow::Activity::NotifyAdminsWithOpenVersionTags;


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

use WebGUI::Mail::Send;

=head1 NAME

Package WebGUI::Workflow::Activity::NotifyAdminsWithOpenVersionTags

=head1 DESCRIPTION

This sends out notifications to all users that have an uncommitted tag. It only does this if the version tags are empty. It takes an arg which specifies the length of time a tag should be outstanding before sending the notification. The default is 3 days.

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
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session, "Workflow_Activity_NotifyAdminsWithOpenVersionTags");
    push(@{$definition}, {
        name       => $i18n->get('activityName'),
        properties => {
	    daysLeftOpen => {
                fieldType    => 'integer',
                label        => $i18n->get('days left open label'),
                defaultValue => 3,
                hoverHelp    => $i18n->get('days left open hoverhelp'),
            },
        }
    });

    return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self = shift;

    my $i18n = WebGUI::International->new($self->session, "Workflow_Activity_NotifyAdminsWithOpenVersionTags");

    my $daysLeftOpen = $self->get('daysLeftOpen') + 0;
    my $sql = <<"ENDSQL";
        SELECT email, count(distinct(tagId)) AS count
        FROM assetVersionTag
        JOIN assetData USING (tagId)
        JOIN userProfileData ON assetVersionTag.createdBy = userProfileData.userId
        WHERE isCommitted = 0
        AND DATE_ADD(FROM_UNIXTIME(creationDate), INTERVAL $daysLeftOpen DAY) < NOW()
        GROUP BY userId
ENDSQL

    my $dataArrayRef = $self->session->db->buildArrayRefOfHashRefs($sql);
    
    for my $userHashRef (@$dataArrayRef) {
        $self->_notify($userHashRef, $i18n);
    }

    return $self->COMPLETE;
}

# send an email to an admin about their open version tags
sub _notify {
    my $self = shift;
    my $dataHashRef = shift;
    my $i18n = shift;
    
    my $hostname = $self->session->config->get('sitename')->[0];
    my($from)    = $self->session->db->quickScalar(" SELECT email FROM userProfileData WHERE userId = 3 ");

    my $s = $dataHashRef->{count} > 1 ? 's' : '';
    my $subject = sprintf($i18n->get('email subject'), $s, $hostname);
    my $mail = WebGUI::Mail::Send->create($self->session, {
        from    => $from,
        to      => $dataHashRef->{email},
        subject => $subject,
    });

    my $html = sprintf $i18n->get('email message'), $dataHashRef->{count}, $s, $hostname, $hostname;
    $mail->addHtml($html);
    $mail->queue();
}

1;


