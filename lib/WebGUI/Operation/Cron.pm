package WebGUI::Operation::Cron;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Workflow::Instance;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Operations::Cron

=head1 DESCRIPTION

Operation handler for managing scheduler activities.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminCron") );
}

#-------------------------------------------------------------------

=head2 www_deleteCronJob ( )

Deletes a cron job.

=cut

sub www_deleteCronJob {
    my $session = shift;
    return $session->privilege->adminOnly unless canView($session);
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
    return $session->privilege->adminOnly unless canView($session);
	my $i18n = WebGUI::International->new($session, "Workflow_Cron");
	my $cron = WebGUI::Workflow::Cron->new($session, $session->form->get("id"));
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		name=>"op",
		value=>"editCronJobSave"
		);
	$f->hidden(
		name=>"id",
		defaultValue=>"new",
		value=>$session->form->get("id"),
		);
	$f->readOnly(
		label=>$i18n->get("id"),
		defaultValue=>"new",
		value=>$session->form->get("id"),
		);
	my $value = $cron->get("title") if defined $cron;
	$f->text(
		name=>"title",
		value=>$value,
		label=>$i18n->get("title"),
		hoverHelp=>$i18n->get("title help")
		);
	$value = $cron->get("enabled") if defined $cron;
	$f->yesNo(
		name=>"enabled",
		value=>$value,
		defaultValue=>0,
		label=>$i18n->get("is enabled"),
		hoverHelp=>$i18n->get("is enabled help")
		);
	$value = $cron->get("runOnce") if defined $cron;
	$f->yesNo(
		name=>"runOnce",
		value=>$value,
		defaultValue=>0,
		label=>$i18n->get("run once"),
		hoverHelp=>$i18n->get("run once help")
		);
	$value = $cron->get("workflowId") if defined $cron;
	my $type = "None";
	if (defined $cron && $cron->get("className")) {
		$type = $cron->get("className");
	}
	$f->workflow(
		name=>"workflowId",
		value=>$value,
		type=>$type,
		label=>$i18n->get("workflow"),
		hoverHelp=>$i18n->get("workflow help")
		);
	my %priorities = ();
	tie %priorities, 'Tie::IxHash';
	%priorities = (1=>$i18n->get("high"), 2=>$i18n->get("medium"), 3=>$i18n->get("low"));
	$value = $cron->get("priority") if defined $cron;
	$f->radioList(
		name=>"priority",
		vertical=>1,
		value=>$value,
		defaultValue=>2,
		options=>\%priorities,
		label=>$i18n->get("priority"),
		hoverHelp=>$i18n->get("priority help")
		);
	$value = $cron->get("minuteOfHour") if defined $cron;
	$f->text(
		name=>"minuteOfHour",
		value=>$value,
		defaultValue=>0,
		label=>$i18n->get("minute of hour"),
		hoverHelp=>$i18n->get("minute of hour help")
		);
	$value = $cron->get("hourOfDay") if defined $cron;
	$f->text(
		name=>"hourOfDay",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("hour of day"),
		hoverHelp=>$i18n->get("hour of day help")
		);
	$value = $cron->get("dayOfMonth") if defined $cron;
	$f->text(
		name=>"dayOfMonth",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("day of month"),
		hoverHelp=>$i18n->get("day of month help")
		);
	$value = $cron->get("monthOfYear") if defined $cron;
	$f->text(
		name=>"monthOfYear",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("month of year"),
		hoverHelp=>$i18n->get("month of year help")
		);
	$value = $cron->get("dayOfWeek") if defined $cron;
	$f->text(
		name=>"dayOfWeek",
		value=>$value,
		defaultValue=>"*",
		label=>$i18n->get("day of week"),
		hoverHelp=>$i18n->get("day of week help")
		);
	$f->submit;
	my $ac = WebGUI::AdminConsole->new($session,"cron");
	$ac->addSubmenuItem($session->url->page("op=editCronJob"), $i18n->get("add a new task"));
	$ac->addSubmenuItem($session->url->page("op=manageCron"), $i18n->get("manage tasks"));
	return $ac->render($f->print);
}


#-------------------------------------------------------------------

=head2 www_editCronJobSave ( )

Saves the results of www_editCronJob()

=cut

sub www_editCronJobSave {
	my $session = shift;
	return $session->privilege->adminOnly unless canView($session);
	if ($session->form->get("id") eq "new") {
		WebGUI::Workflow::Cron->create($session,{
			monthOfYear=>$session->form->get("monthOfYear"),
			dayOfMonth=>$session->form->get("dayOfMonth"),
			minuteOfHour=>$session->form->get("minuteOfHour"),
			hourOfDay=>$session->form->get("hourOfDay"),
			dayOfWeek=>$session->form->get("dayOfWeek"),
			enabled=>$session->form->get("enabled","yesNo"),
			runOnce=>$session->form->get("runOnce","yesNo"),
			priority=>$session->form->get("priority","radioList"),
			workflowId=>$session->form->get("workflowId","workflow"),
			title=>$session->form->get("title"),
			});
	} else {
		my $cron = WebGUI::Workflow::Cron->new($session, $session->form->get("id"));
		$cron->set({
			monthOfYear=>$session->form->get("monthOfYear"),
			dayOfMonth=>$session->form->get("dayOfMonth"),
			minuteOfHour=>$session->form->get("minuteOfHour"),
			hourOfDay=>$session->form->get("hourOfDay"),
			dayOfWeek=>$session->form->get("dayOfWeek"),
			enabled=>$session->form->get("enabled","yesNo"),
			runOnce=>$session->form->get("runOnce","yesNo"),
			priority=>$session->form->get("priority","radioList"),
			workflowId=>$session->form->get("workflowId","workflow"),
			title=>$session->form->get("title"),
			});
	}
	return www_manageCron($session);
}


#-------------------------------------------------------------------

=head2 www_manageCron  ( )

Display a list of the scheduler activities.

=cut

sub www_manageCron {
	my $session = shift;
        return $session->privilege->adminOnly unless canView($session);
	my $i18n = WebGUI::International->new($session, "Workflow_Cron");
	my $output = '<table width="100%">'; 
	my $rs = $session->db->read("select taskId, title, concat(minuteOfHour, ' ', hourOfDay, ' ', dayOfMonth, ' ', monthOfYear, ' ', dayOfWeek), enabled from WorkflowSchedule");
	while (my ($id, $title, $schedule, $enabled) = $rs->array) {
		$output .= '<tr><td>'
			.$session->icon->delete("op=deleteCronJob;id=".$id, undef, $i18n->get("are you sure you wish to delete this scheduled task"))
			.$session->icon->edit("op=editCronJob;id=".$id)
			.'</td><td>'.$title.'</td><td>'.$schedule.'</td><td>'
			.($enabled ? $i18n->get("enabled") : $i18n->get("disabled"))
			."</td>";
		$output .= '<td><a href="'.$session->url->page("op=runCronJob;taskId=".$id).'">'.$i18n->get("run","Workflow").'</a></td>';
		$output .= "</tr>\n";
	}
	$output .= '</table>';
	my $ac = WebGUI::AdminConsole->new($session,"cron");
	$ac->addSubmenuItem($session->url->page("op=editCronJob"), $i18n->get("add a new task"));
	return $ac->render($output);
}


#-------------------------------------------------------------------

=head2 www_runCronJob ( )

Checks to ensure the requestor is who we think it is, and then executes a cron job and returns the results.

=cut

sub www_runCronJob {
        my $session = shift;
	$session->http->setMimeType("text/plain");
	$session->http->setCacheControl("none");
	unless (isInSubnet($session->env->getIp, $session->config->get("spectreSubnets")) || canView($session)) {
		$session->errorHandler->security("make a Spectre cron job runner request, but we're only allowed to accept requests from ".join(",",@{$session->config->get("spectreSubnets")}).".");
        	return "error";
	}
	my $taskId = $session->form->param("taskId");
	if ($taskId) {
		# Try to instantiate the task
                my $task = WebGUI::Workflow::Cron->new($session, $taskId);
		return "done" unless (defined $task);
                
                # Make a new workflow instance
                my $instance = 
                    WebGUI::Workflow::Instance->create($session, {
			workflowId  => $task->get("workflowId"),
			className   => $task->get("className"),
			methodName  => $task->get("methodName"),
			parameters  => $task->get("parameters"),
			priority    => $task->get("priority"),
                    });
                if ( !$instance ) {
                    if ($session->stow->get('singletonWorkflowClash')) {
                        $session->errorHandler->warn( 
                            "Could not create workflow instance for workflowId '" . $task->get( "workflowId" )
                            . "' from taskId '".$taskId."': It is a singleton workflow and is still running from the last invocation."
                        );
                        return "done";
                    }
                    $session->errorHandler->error( 
                        "Could not create workflow instance for workflowId '" . $task->get( "workflowId" )
                        . "' from taskId '".$taskId."': The result was undefined"
                    );
                    return "done";
                }
                
                # Run the instance
                $instance->start( 1 );
		$task->delete( 1 ) if ( $task->get("runOnce") );
		return "done";
	}
	$session->errorHandler->warn("No task ID passed to cron job runner.");
	return "error";
}


1;
