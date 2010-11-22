package WebGUI::Operation::Workflow;

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
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Workflow;
use WebGUI::Workflow::Activity;
use WebGUI::Workflow::Instance;
use POE::Component::IKC::ClientLite;
use JSON qw/ decode_json /;
use Net::CIDR::Lite;

=head1 NAME

Package WebGUI::Operations::Workflow

=head1 DESCRIPTION

Operation handler for managing workflows.

=cut

#----------------------------------------------------------------------------

=head2 canRunWorkflow ( session [, user] )

Returns true if the user can run workflows from this operation. user defaults to 
the current user.

=cut

sub canRunWorkflow {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminWorkflowRun") );
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminWorkflow") );
}

#-------------------------------------------------------------------

=head2 www_activityHelper ( session )

Calls an activity helper. In the URL you must pass the activity class name, the subroutine to call and any other 
parameters you wish the activity helper to use. Here's an example:

/page?op=activityHelper;class=MyActivity;sub=doTheBigThing;param1=makeItGo

=cut

sub www_activityHelper {
    my $session     = shift;
    my $form        = $session->form;
    my $class       = "WebGUI::Workflow::Activity::".$form->get("class");
    my $sub         = $form->get("sub");
    return "ERROR" unless (defined $sub && defined $class);

    my $output = eval {WebGUI::Pluggable::instanciate($class, "www_".$sub, [$session])};
    if ($@) {
        $session->log->error($@); 
        return "ERROR";
    }
    return $output;
}


#-------------------------------------------------------------------

=head2 www_addWorkflow ( )

Allows the user to choose the type of workflow that's going to be created. 

=cut

sub www_addWorkflow {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		name=>"op",
		value=>"addWorkflowSave"
		);
	my %options = ();
	foreach my $object (keys %{$session->config->get("workflowActivities")}) {
		if ($object eq "None") {
			$options{$object} = $i18n->get("no object");
		} else {
			$options{$object} = $object;
		}
	}
	$f->selectBox(
		name=>"type",
		label=>$i18n->get("object type"),
		options=>\%options,
		value=>"None",
		hoverHelp=>$i18n->get("object type help")
		);
	$f->submit;
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=manageWorkflows"), $i18n->get("manage workflows"));
	return $ac->render($f->print, $i18n->get('add a new workflow'));
}

#-------------------------------------------------------------------

=head2 www_addWorkflowSave ( )

Saves the results from www_addWorkflow().

=cut

sub www_addWorkflowSave {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $workflow = WebGUI::Workflow->create($session, {type=>$session->form->get("type")});	
	return www_editWorkflow($session, $workflow);
}

#-------------------------------------------------------------------

=head2 www_deleteWorkflow ( )

Deletes an entire workflow.

=cut

sub www_deleteWorkflow {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId"));
	$workflow->delete if defined $workflow;
	return www_manageWorkflows($session);
}

#-------------------------------------------------------------------

=head2 www_deleteWorkflowActivity ( )

Deletes an activity from a workflow.

=cut

sub www_deleteWorkflowActivity {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId"));
	if (defined $workflow) {
		$workflow->deleteActivity($session->form->get("activityId"));
	}
	return www_editWorkflow($session);
}

#------------------------------------------------------------------

=head2 www_demoteWorkflowActivity ( session )

Moves a workflow activity down one position in the execution order.

=head3 session

A reference to the current session.

=cut

sub www_demoteWorkflowActivity {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
	my $workflow = WebGUI::Workflow->new($session, $session->form->param("workflowId"));
	$workflow->demoteActivity($session->form->param("activityId"));
	return www_editWorkflow($session);
}

#-------------------------------------------------------------------

=head2 www_editWorkflow ( session, workflow )

Displays the editable properties of a workflow.

=cut

sub www_editWorkflow {
	my $session = shift;
	my $workflow = shift;
        return $session->privilege->insufficient() unless canView($session);
	$workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId")) unless (defined $workflow);
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $workflowActivities = $session->config->get("workflowActivities");
	my $addmenu = '<div style="float: left; width: 200px; font-size: 11px;">';
	foreach my $class (@{$workflowActivities->{$workflow->get("type")}}) {
		my $activity = WebGUI::Workflow::Activity->newByPropertyHashRef($session, {className=>$class});
        if (defined $activity) {
            $addmenu .= '<a href="'.$session->url->page("op=editWorkflowActivity;className=".$class.";workflowId=".$workflow->getId).'">'.$activity->getName."</a><br />\n";
        }
        else {
            $addmenu .= sprintf $i18n->get('bad workflow activity code'), $class;
        }
	}	
	$addmenu .= '</div>';
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(
		name=>"op",
		value=>"editWorkflowSave"
		);
	$f->hidden(
		name=>"workflowId",
		value=>$workflow->getId
		);
	$f->readOnly(
		label=>$i18n->get("workflowId"),
		value=>$workflow->getId
		);
	$f->readOnly(
		label=>$i18n->get("object type"),
		value=>$workflow->get("type"),
		hoverHelp=>$workflow->get("object type help2"),
		);
	$f->text(
		name=>"title",
		value=>$workflow->get("title"),
		label=>$i18n->get("title"),
		hoverHelp=>$i18n->get("title help")
		);
	$f->textarea(
		name=>"description",
		value=>$workflow->get("description"),
		label=>$i18n->get("description"),
		hoverHelp=>$i18n->get("description help")
		);
	$f->yesNo(
		name=>"enabled",
		value=>$workflow->get("enabled"),
		defaultValue=>0,
		label=>$i18n->get("is enabled"),
		hoverHelp=>$i18n->get("is enabled help")
		);
	$f->selectBox(
		name=>"mode",
        options=>{
            singleton=>$i18n->get("singleton"),
            parallel=>$i18n->get("parallel"),
            serial=>$i18n->get("serial"),
        },
		value=>$workflow->get("mode") || "parallel",
		defaultValue=>"parallel",
		label=>$i18n->get("mode"),
		hoverHelp=>$i18n->get("mode help")
		);
	$f->submit;
	my $steps = '<table class="content">';
	my $rs = $session->db->read("select activityId, title from WorkflowActivity where workflowId=? order by sequenceNumber",[$workflow->getId]);
	while (my ($id, $title) = $rs->array) {
		$steps .= '<tr><td>'
			.$session->icon->delete("op=deleteWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id, undef, $i18n->get("confirm delete activity"))
			.$session->icon->edit("op=editWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id)
			.$session->icon->moveDown("op=demoteWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id)
			.$session->icon->moveUp("op=promoteWorkflowActivity;workflowId=".$workflow->getId.";activityId=".$id)
			.'</td><td>'.$title.'</td></tr>';	
	}
	$steps .= '</table><div style="clear: both;"></div>';
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=addWorkflow"), $i18n->get("add a new workflow"));
	$ac->addSubmenuItem($session->url->page("op=manageWorkflows"), $i18n->get("manage workflows"));
	return $ac->render($f->print.$addmenu.$steps, $i18n->get('edit workflow'));
}

#-------------------------------------------------------------------

=head2 www_editWorkflowPriority ( )

Save the submitted new workflow priority.

=cut

sub www_editWorkflowPriority {
    my $session = shift;

    return $session->privilege->insufficient() unless $session->user->isAdmin;

    my $i18n = WebGUI::International->new($session, 'Workflow');
    my $ac = WebGUI::AdminConsole->new($session,"workflow");
    $ac->addSubmenuItem($session->url->page("op=showRunningWorkflows"), $i18n->get('show running workflows'));

    # make sure the input is good
    my $instanceId  = $session->form->get('instanceId')  || '';
    my $newPriority = $session->form->get('newPriority') || '';
    if (! $instanceId) {
	my $output = $i18n->get('edit priority bad request');
	return $ac->render($output, $i18n->get('show running workflows'));
    }

    # make the request
    my $remote = create_ikc_client(
		port=>$session->config->get("spectrePort"),
		ip=>$session->config->get("spectreIp"),
		name=>rand(100000),
	        timeout=>10
    );
    if (! $remote) {
	my $output = $i18n->get('edit priority no spectre error');
	return $ac->render($output, $i18n->get('show running workflows'));
    }

    my $argHref = {
	instanceId  => $instanceId,
	newPriority => $newPriority,
    };
    my $resultJson = $remote->post_respond('workflow/editWorkflowPriority', $argHref);
    if (! defined $resultJson) {
	$remote->disconnect();
	my $output = $i18n->get('edit priority no info error');
	return $ac->render($output, $i18n->get('show running workflows'));
    }

    my $responseHref = decode_json($resultJson);

    my $message = $i18n->get($responseHref->{message}) || $i18n->get('edit priority unknown error');
    return $ac->render($message, $i18n->get('show running workflows'));
}

#-------------------------------------------------------------------

=head2 www_editWorkflowSave ( )

Saves the results of www_editWorkflow()

=cut

sub www_editWorkflowSave {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $workflow = WebGUI::Workflow->new($session, $session->form->param("workflowId"));
	$workflow->set({
		enabled     => $session->form->get("enabled",     "yesNo"),
		mode        => $session->form->get("mode"),
		title       => $session->form->get("title"),
		description => $session->form->get("description", "textarea"),
		});
	return www_editWorkflow($session, $workflow);
}


#-------------------------------------------------------------------

=head2 www_editWorkflowActivity ( )

Displays a form to edit the properties of a workflow activity.

=cut

sub www_editWorkflowActivity {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $activity = '';
	if ($session->form->process("className","className")) {
		$activity = WebGUI::Workflow::Activity->newByPropertyHashRef($session, {activityId=>"new",className=>$session->form->process("className","className")});
	} else {
		$activity = WebGUI::Workflow::Activity->new($session, $session->form->get("activityId"));
	}
	my $form = $activity->getEditForm;
	$form->hidden( name=>"op", value=>"editWorkflowActivitySave");
	$form->hidden( name=>"workflowId", value=>$session->form->get("workflowId"));
	$form->submit;
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=addWorkflow"), $i18n->get("add a new workflow"));
	$ac->addSubmenuItem($session->url->page("op=manageWorkflows"), $i18n->get("manage workflows"));
	return $ac->render($form->print,$activity->getName);
}

#-------------------------------------------------------------------

=head2 www_editWorkflowActivitySave ( )

Saves the results of www_editWorkflowActivity().

=cut

sub www_editWorkflowActivitySave {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $workflow = WebGUI::Workflow->new($session, $session->form->get("workflowId"));
	if (defined $workflow) {
		my $activityId = $session->form->get("activityId");
		my $activity = '';
		if ($activityId eq "new") {
			$activity = $workflow->addActivity($session->form->process("className","className"));
		} else {
			$activity = $workflow->getActivity($activityId);
		}
		$activity->processPropertiesFromFormPost;
	}
	return www_editWorkflow($session);
}

#-------------------------------------------------------------------

=head2 www_manageWorkflows ( )

Display a list of the workflows.

=cut

sub www_manageWorkflows {
	my $session = shift;
        return $session->privilege->insufficient() unless canView($session);
	my $i18n = WebGUI::International->new($session, "Workflow");
	my $output = '<table width="100%">'; 
	my $rs = $session->db->read("select workflowId, title, enabled from Workflow order by title");
	while (my ($id, $title, $enabled) = $rs->array) {
		$output .= '<tr><td>'
			.$session->icon->delete("op=deleteWorkflow;workflowId=".$id, undef, $i18n->get("are you sure you want to delete this workflow"))
			.$session->icon->edit("op=editWorkflow;workflowId=".$id)
			.'</td><td>'.$title.'</td><td>'
			.($enabled ? $i18n->get("enabled") : $i18n->get("disabled"))
			."</td></tr>\n";
	}
	$output .= '</table>';
	my $ac = WebGUI::AdminConsole->new($session,"workflow");
	$ac->addSubmenuItem($session->url->page("op=addWorkflow"), $i18n->get("add a new workflow"));
	$ac->addSubmenuItem($session->url->page("op=showRunningWorkflows"), $i18n->get("show running workflows"));
	return $ac->render($output, $i18n->get('manage workflows'));
}


#------------------------------------------------------------------

=head2 www_promoteWorkflowActivity ( session )

Moves a workflow activity up one position in the execution order.

=head3 session

A reference to the current session.

=cut

sub www_promoteWorkflowActivity {
	my $session = shift;
	return $session->privilege->insufficient() unless canView($session);
	my $workflow = WebGUI::Workflow->new($session, $session->form->param("workflowId"));
	$workflow->promoteActivity($session->form->param("activityId"));
	return www_editWorkflow($session);
}

#-------------------------------------------------------------------

=head2 www_runWorkflow ( )

Checks to ensure the requestor is who we think it is, and then executes a workflow and returns the results.

=cut

sub www_runWorkflow {
        my $session = shift;
	$session->response->content_type("text/plain");
	$session->http->setCacheControl("none");
	unless (Net::CIDR::Lite->new(@{ $session->config->get('spectreSubnets')} )->find($session->request->address) || canRunWorkflow($session)) {
		$session->log->security("make a Spectre workflow runner request, but we're only allowed to accept requests from ".join(",",@{$session->config->get("spectreSubnets")}).".");
        	return "error";
	}
	my $instanceId = $session->form->param("instanceId");
	if ($instanceId) {
		my $instance = WebGUI::Workflow::Instance->new($session, $instanceId);
		if (defined $instance) {
			return $instance->run;
		} else {
                        return "done";
		}
		return "complete";
	}
	$session->log->warn("No instance ID passed to workflow runner.");
	return "error";
}

#-------------------------------------------------------------------

=head2 www_showRunningWorkflows ( )

Display a list of the running workflow instances.

=cut

sub www_showRunningWorkflows {
    my $session = shift;

    return $session->privilege->insufficient() unless canView($session);

    my $i18n = WebGUI::International->new($session, "Workflow");
    my $ac = WebGUI::AdminConsole->new($session,"workflow");
    my $isAdmin = canRunWorkflow($session);

    # javascript for creating/showing/hiding the edit priority form
    my $cancel = $i18n->get('edit priority cancel');
    my $updatePriority = $i18n->get('edit priority update priority');
    my $output = <<"ENDCODE";
    <style>
    .waiting { color: #808000; }
    .complete { color: #008000; }
    .error { color: #800000; }
    .disabled { color: #808000; }
    .done { color: #008000; }
    .undefined { color: #800000; }
    </style>
    <script type="text/javascript">
        function showEditPriorityForm(iid) {
            var alreadyOpenForm = document.getElementById('edit-priority-form');
            if (alreadyOpenForm) {
                var oldIid = alreadyOpenForm.instanceId.value;
                hideEditPriorityForm(oldIid);
            }
            var ele = document.getElementById('priority-'+iid)
            ele.style.display = 'none';
            ele.parentNode.insertBefore(getEditPriorityFormNode(iid,ele.innerHTML),ele);
        }
        function getEditPriorityFormNode(iid,currentPriority) {
            var f = document.createElement('form');
            f.setAttribute('id','edit-priority-form');
            f.setAttribute('method','POST');
            f.setAttribute('action','?op=editWorkflowPriority');
            f.innerHTML = '<input type="hidden" name="instanceId" value="'+iid+'"/>'+
                '<input type="input" name="newPriority" size="3" value="'+currentPriority+'"/>'+
                '<input type="submit" value="$updatePriority"/>'+
                '<a href="javascript:void(0)" onclick="hideEditPriorityForm(\\''+iid+'\\')">$cancel</a>';
            return f;
        }
        function hideEditPriorityForm(iid) {
            var f = document.getElementById('edit-priority-form');
            f.parentNode.removeChild(f);
            document.getElementById('priority-'+iid).style.display = '';
        }
    </script>
ENDCODE

    my $remote = create_ikc_client(
        port=>$session->config->get("spectrePort"),
        ip=>$session->config->get("spectreIp"),
        name=>rand(100000),
        timeout=>10
    );
    my $sitename = $session->config()->get('sitename')->[0];
    my $workflowResult;
    if ($remote) {
        $workflowResult = $remote->post_respond('workflow/getJsonStatus',$sitename);
        if (!defined $workflowResult) {
            $remote->disconnect();
            $output = $i18n->get('spectre no info error');
        }
    }
    else {
        $output = $i18n->get('spectre not running error')
    }

    if (defined $workflowResult) {
        my $workflowsHref = decode_json($workflowResult);

        my $workflowTitleFor = $session->db->buildHashRef(<<"");
        SELECT wi.instanceId, w.title
        FROM WorkflowInstance wi
        JOIN Workflow w USING (workflowId)

        my $lastActivityFor = $session->db->buildHashRef(<<"");
        SELECT wi.instanceId, wa.title
        FROM WorkflowInstance wi
        JOIN WorkflowActivity wa ON wi.currentActivityId = wa.activityId

        for my $workflowType (qw( Suspended Waiting Running )) {
            my $workflowsAref = $workflowsHref->{$workflowType};
            my $workflowCount = @$workflowsAref;

            my $titleHeader = $i18n->get('title header');
            my $priorityHeader = $i18n->get('priority header');
            my $activityHeader = $i18n->get('activity header');
            my $lastStateHeader = $i18n->get('last state header');
            my $lastRunTimeHeader = $i18n->get('last run time header');
            $output .= sprintf $i18n->get('workflow type count'), $workflowCount, $workflowType;
            $output .= '<table style="width: 100%;">';
            $output .= "<tr><th>$titleHeader</th><th>$priorityHeader</th><th>$activityHeader</th>";
            $output .= "<th>$lastStateHeader</th><th>$lastRunTimeHeader</th></tr>";

            for my $workflow (@$workflowsAref) {
                my($priority, $id, $instance) = @$workflow;

                my $originalPriority = ($instance->{priority} - 1) * 10;
                my $instanceId       = $instance->{instanceId};
                my $title            = $workflowTitleFor->{$instanceId} || '(no title)';
                my $lastActivity     = $lastActivityFor->{$instanceId} || '(none)';
                my $lastRunTime      = $instance->{lastRunTime} || '(never)';

                $output .= '<tr>';
                $output .= "<td>$title</td>";
                $output .= qq[<td><a id="priority-$instanceId" href="javascript:void(0);" title="Edit Priority" onclick="showEditPriorityForm('$instanceId')">$priority</a>/$originalPriority</td>];
                $output .= "<td>$lastActivity</td>";
                $output .= "<td>$instance->{lastState}</td>";
                $output .= "<td>$lastRunTime</td>";

                if ($isAdmin) {
                    my $run = $i18n->get('run');
                    my $href = $session->url->page(qq[op=runWorkflow;instanceId=$instanceId]);
                    $output .= qq[<td><a href="$href">$run</a></td>];
                }
                $output .= "</tr>\n";
            }
            $output .= '</table>';
        }
    }
    else {
        $output .= '<table width="100%">';
        my $rs = $session->db->read("select Workflow.title, WorkflowInstance.lastStatus, WorkflowInstance.runningSince, WorkflowInstance.lastUpdate, WorkflowInstance.instanceId from WorkflowInstance left join Workflow on WorkflowInstance.workflowId=Workflow.workflowId order by WorkflowInstance.runningSince desc");
        while (my ($title, $status, $runningSince, $lastUpdate, $id) = $rs->array) {
            my $class = $status || "complete";
            $output .= '<tr class="'.$class.'">'
                .'<td>'.$title.'</td>'
                .'<td>'.$session->datetime->epochToHuman($runningSince).'</td>';
            if ($status) {
                $output .= '<td>'
                    .$status.' / '.$session->datetime->epochToHuman($lastUpdate)
                    .'</td>';
            }
            $output .= '<td><a href="'.$session->url->page("op=runWorkflow;instanceId=".$id).'">'.$i18n->get("run").'</a></td>'
                if ($isAdmin);
            $output .= "</tr>\n";
        }
        $output .= '</table>';
    }
 
    $ac->addSubmenuItem($session->url->page("op=addWorkflow"), $i18n->get("add a new workflow"));
    $ac->addSubmenuItem($session->url->page("op=manageWorkflows"), $i18n->get("manage workflows"));

    return $ac->render($output, $i18n->get('show running workflows'));
}

1;
