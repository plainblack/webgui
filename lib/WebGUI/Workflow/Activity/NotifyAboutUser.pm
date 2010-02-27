package WebGUI::Workflow::Activity::NotifyAboutUser;


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
use WebGUI::Macro;
use WebGUI::Mail::Send;

=head1 NAME

Package WebGUI::Workflow::Activity::NotifyAboutUser

=head1 DESCRIPTION

Takes a user object and sends out a message. Can use macros in message, to and subject
fields.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_NotifyAboutUser");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			to => {
				fieldType=>"text",
				label=>$i18n->get("to"),
				defaultValue=>$session->setting->get("companyEmail"),
				hoverHelp=>$i18n->get("to help")
				},
			subject => {
				fieldType=>"text",
				label=>$i18n->get("subject"),
				defaultValue=>undef,
				hoverHelp=>$i18n->get("subject help")
				},
			message => {
				fieldType=>"textarea",
				label=>$i18n->get("message"),
				defaultValue=>undef,
				hoverHelp=>$i18n->get("message help")
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
	my $user = shift;
	my $previousUser = $self->session->user;
	$self->session->user({user=>$user});
	my $message = $self->get("message");
	WebGUI::Macro::process($self->session, \$message);
	my $to = $self->get("to");
	WebGUI::Macro::process($self->session, \$to);
	my $subject = $self->get("subject");
	WebGUI::Macro::process($self->session, \$subject);
	my $mail = WebGUI::Mail::Send->create($self->session, {
		to=>$to,
		subject=>$subject
		});
	$mail->addText($message);
	$mail->addFooter;
	$self->session->user({user=>$previousUser});
	$mail->queue;
    return $self->COMPLETE;
}



1;


