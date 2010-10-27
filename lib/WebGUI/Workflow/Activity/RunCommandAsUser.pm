package WebGUI::Workflow::Activity::RunCommandAsUser;


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

=head1 NAME

Package WebGUI::Workflow::Activity::RunCommandAsUser

=head1 DESCRIPTION

This activity will tell the session to switch to the user object passed in as the current user, and then execute a command on the command line of the local operating system. It processes macros so feel free to use macros in the command line.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_RunCommandAsUser");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			commandLine => {
				fieldType=>"text",
				label=>$i18n->get("command"),
				defaultValue=>undef,
				hoverHelp=>$i18n->get("command help")
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
	my $cmd = $self->get("command");
    my $previousUser = $self->session->user;
	$self->session->user({user=>$user});
	WebGUI::Macro::process($self->session, \$cmd);
	if (system($cmd)) {
		$self->session->log->error("Workflow: RunCommandAsUser failed because: $!");
        $self->session->user({user=>$previousUser});
		return $self->ERROR;
	} else {
        $self->session->user({user=>$previousUser});
		return $self->COMPLETE;
	}
}



1;


