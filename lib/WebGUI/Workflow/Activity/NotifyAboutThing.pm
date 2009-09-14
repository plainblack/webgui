package WebGUI::Workflow::Activity::NotifyAboutThing;


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
use WebGUI::VersionTag;
use WebGUI::Inbox;

=head1 NAME

Package WebGUI::Workflow::Activity::NotifyAboutVersionTag

=head1 DESCRIPTION

Send a message to a group when a Thing is modified.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_NotifyAboutThing");
	push(@{$definition}, {
		name=>$i18n->get("notify about thing"),
		properties=> { 
			groupToNotify => {
				fieldType=>"group",
				defaultValue=>["4"],
				label=>$i18n->get("group to notify"),
				hoverHelp=>$i18n->get("group to notify help")
				},
			message => {
				fieldType=>"textarea",
				defaultValue => "",
				label=> $i18n->get("notify message"),
				hoverHelp => $i18n->get("notify message help")
				},
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self            = shift;
    my $thingy          = shift;
    my $inbox           = WebGUI::Inbox->new($self->session);
    my $properties      = {
        status  => 'completed',
        subject => 'Thingy at URL ' . $thingy->getUrl . ' changed.',
        message => $self->get('message'),
        groupId => $self->get('groupToNotify'),
    };
    $inbox->addMessage($properties);
    return $self->COMPLETE;
}

1;
