package WebGUI::Workflow::Activity::ExpireUnvalidatedEmailUsers;


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

=head1 NAME

Package WebGUI::Workflow::Activity::ExpireUnvalidatedEmailUsers

=head1 DESCRIPTION

Deletes users who are inactive for more than a period of time due to
not having validated their email addresses.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_ExpireUnvalidatedEmailUsers");
	push(@{$definition}, {
		name => $i18n->get('activityName'),
		properties => {
			interval => {
				fieldType => "interval",
				label => $i18n->get('interval label'),
				defaultValue => 86400,
				hoverHelp => $i18n->get('interval hoverHelp'),
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
	unless ($self->session->setting->get('webguiValidateEmail')) {
		# Do nothing.
		return $self->COMPLETE;
	}

	my @userIds = $self->session->db->buildArray("SELECT a.userId FROM authentication AS a INNER JOIN users AS u ON a.userId = u.userId WHERE a.authMethod = 'WebGUI' AND a.fieldName = 'emailValidationKey' AND u.status = 'Deactivated' AND u.dateCreated < ?", [time - $self->get('interval')]);
	foreach my $userId (@userIds) {
		WebGUI::User->new($self->session, $userId)->delete;
	}

	return $self->COMPLETE;
}

1;
