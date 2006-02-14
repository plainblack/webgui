package WebGUI::Operation::Cron;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Workflow::Cron;

=head1 NAME

Package WebGUI::Operations::Cron

=head1 DESCRIPTION

Operation handler for managing scheduler activities.

=cut

#-------------------------------------------------------------------

=head2 www_deleteCronJob ( )

Deletes a cron job.

=cut

sub www_deleteCronJob {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $cron = WebGUI::Workflow::Cron->new($session, $session->form->get("id"));
	$cron->delete if defined $cron;
	return www_manageCron($session);
}

#-------------------------------------------------------------------

=head2 www_editCronJob ( )

Displays an edit form for a cron job.

=cut

sub www_editCronJob {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $i18n = WebGUI::International->new($session, "Workflow_Cron");
	my $cron = WebGUI::Workflow::Cron->new($session, $session->form->get("id"));
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		name=>"op",
		value=>"editCronJobSave"
		);
	$f->hidden(
		name=>"id",
		value=>$session->form->get("id"),
		defaultValue=>"new",
		);
	$f->readOnly(
		label=>$i18n->get("id"),
		value=>$session->form->get("id"),
		defaultValue=>"new"
		);
	my $value = $cron->get("title") if defined $cron;
	$f->text(
		name=>"title",
		value=>$value,
		label=>$i18n->get("title"),
		hoverHelp=>$i18n->get("title help")
		);
	my $value = $cron->get("enabled") if defined $cron;
	$f->yesNo(
		name=>"enabled",
		value=>$value,
		defaultValue=>0,
		label=>$i18n->get("enabled"),
		hoverHelp=>$i18n->get("enabled help")
		);
	my $value = $cron->get("runOnce") if defined $cron;
	$f->yesNo(
		name=>"runOnce",
		value=>$value,
		defaultValue=>0,
		label=>$i18n->get("run once"),
		hoverHelp=>$i18n->get("ron once help")
		);
	my $value = $cron->get("workflowId") if defined $cron;
	$f->workflow(
		name=>"workflowId",
		value=>$value,
		label=>$i18n->get("workflow"),
		hoverHelp=>$i18n->get("workflow help")
		);
	my %priorities = ();
	tie %priorities, 'Tie::IxHash';
	%priorities = (1=>$i18n->get("high"), 2=>$i18n->get("medium"), 3=>$i18n->get("low"));
	my $value = $cron->get("priority") if defined $cron;
	$f->radioList(
		name=>"priority",
		vertical=>1,
		value=>$value,
		defaultValue=>2,
		options=>\%priorities,
		label=>$i18n->get("priority"),
		hoverHelp=>$i18n->get("priority help")
		);
	my $value = $cron->get("minuteOfHour") if defined $cron;
	$f->text(
		name=>"minuteOfHour",
		value=>$value,
		defaultValue=>0,
		label=>$i18n->get("minute of hour"),
		hoverHelp=>$i18n->get("minute of hour help")
		);
	my $value = $cron->get("hourOfDay") if defined $cron;
	$f->text(
		name=>"hourOfDay",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("hour of day"),
		hoverHelp=>$i18n->get("hour of day help")
		);
	my $value = $cron->get("dayOfMonth") if defined $cron;
	$f->text(
		name=>"dayOfMonth",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("day of month"),
		hoverHelp=>$i18n->get("day of month help")
		);
	my $value = $cron->get("monthOfYear") if defined $cron;
	$f->text(
		name=>"monthOfYear",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("month of year"),
		hoverHelp=>$i18n->get("month of year help")
		);
	my $value = $cron->get("dayOfWeek") if defined $cron;
	$f->text(
		name=>"dayOfWeek",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("day of week"),
		hoverHelp=>$i18n->get("day of week help")
		);
	$f->submit;
	return WebGUI::AdminConsole->new($session,"cron")->render($f->print);
}


#-------------------------------------------------------------------

=head2 www_manageCron  ( )

Display a list of the scheduler activities.

=cut

sub www_manageCron {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $i18n = WebGUI::International->new($session, "Workflow_Cron");
	my $output = '<table>'; 
	my $rs = $session->db->read("select taskId, title, concat(minuteOfHour, hourOfDay, dayOfMonth, monthOfYear, dayOfWeek), enabled from WorkflowSchedule");
	while (my ($id, $title, $schedule, $enabled) = $rs->array) {
		$output .= '<tr><td>'
			.$session->icon->delete("op=deleteCronJob;id=".$id, undef, $i18n->get("are you sure you want to delete this scheduled task"))
			.$session->icon->edit("op=editCronJob;id=".$id)
			.'</td><td>'.$title.'</td><td>'.$schedule.'</td><td>'
			.($enabled ? "X" : "")
			."</td></tr>\n";
	}
	$output .= '</table>';
	return WebGUI::AdminConsole->new($session,"cron")->render($output);
}

1;
