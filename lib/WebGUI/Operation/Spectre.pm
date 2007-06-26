package WebGUI::Operation::Spectre;

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
use JSON;
use POE::Component::IKC::ClientLite;
use WebGUI::Utility;
use WebGUI::Workflow::Cron;
use WebGUI::Workflow::Instance;

=head1 NAME

Package WebGUI::Operation::Spectre

=head1 DESCRIPTION

Operations for Spectre.

=cut

#-------------------------------------------------------------------

=head2 www_spectreGetSiteData ( )

Checks to ensure the requestor is who we think it is, and then returns a JSON string with worklfow and cron data. We do it in one payload for efficiency.

=cut

sub www_spectreGetSiteData {
        my $session = shift;
	$session->http->setMimeType("text/json");
	$session->http->setCacheControl("none");
	my %siteData = ();
	if (!isInSubnet($session->env->get("REMOTE_ADDR"), $session->config->get("spectreSubnets"))) {
		$session->errorHandler->security("make a Spectre workflow data load request, but we're only allowed to accept requests from "
			.join(",",@{$session->config->get("spectreSubnets")}).".");
	} 
  	else {
		my $sitename = $session->config->get("sitename")->[0];
		my $gateway = $session->config->get("gateway");
		my $cookieName = $session->config->getCookieName;
		my @instances = ();
		foreach my $instance (@{WebGUI::Workflow::Instance->getAllInstances($session)}) {
			next unless $instance->getWorkflow->get("enabled");
			push(@instances, {
				instanceId 	=> $instance->getId,
				priority 	=> $instance->get("priority"),
				cookieName	=> $cookieName,
				gateway		=> $gateway, 
				sitename	=> $sitename,
				});
		}
		$siteData{workflow} = \@instances;
		my @schedules = ();
		foreach my $task (@{WebGUI::Workflow::Cron->getAllTasks($session)}) {
			next unless $task->get("enabled");
			push(@schedules, {
				taskId 		=> $task->getId,
				cookieName	=> $cookieName,
				gateway		=> $gateway, 
				sitename	=> $sitename,
				minuteOfHour	=> $task->get('minuteOfHour'),
				hourOfDay	=> $task->get('hourOfDay'),
				dayOfMonth	=> $task->get('dayOfMonth'),
				monthOfYear	=> $task->get('monthOfYear'),
				dayOfWeek	=> $task->get('dayOfWeek'),
				runOnce		=> $task->get('runOnce'),
				});
		}
		$siteData{cron} = \@schedules;
	}
	return JSON::objToJson(\%siteData,{autoconv=>0, skipinvalid=>1});
}

#-------------------------------------------------------------------
  
=head2 www_spectreStatus (  )

Show information about Spectre's current workload.

=cut

sub www_spectreStatus {
    my $session = shift;
    
    return $session->privilege->adminOnly() unless $session->user->isInGroup(3);

    # start to prepare the display
    my $ac = WebGUI::AdminConsole->new($session, 'spectre');
    my $i18n = WebGUI::International->new($session, 'Spectre');

    $session->http->setCacheControl("none");
    unless (isInSubnet($session->env->get("REMOTE_ADDR"), $session->config->get("spectreSubnets"))) {
	$session->errorHandler->security("make a Spectre workflow runner request, but we're only allowed to accept requests from ".join(",",@{$session->config->get("spectreSubnets")}).".");
	return "subnet";
    }

    my $remote = create_ikc_client(
		port=>$session->config->get("spectrePort"),
		ip=>$session->config->get("spectreIp"),
		name=>rand(100000),
	        timeout=>10
    );

    if (!$remote) {
	return $ac->render($i18n->get('not running'), $i18n->get('spectre'));
    }

    my $sitename = $session->config()->get('sitename')->[0];
    my $workflowResult = $remote->post_respond('workflow/getJsonStatus',$sitename);
    if (!$workflowResult) {
        $remote->disconnect();
	return $ac->render($i18n->get('workflow status error'), $i18n->get('spectre'));
    }

    my $cronResult = $remote->post_respond('cron/getJsonStatus',$sitename);
    if (! defined $cronResult) {
        $remote->disconnect();
	return $ac->render($i18n->get('cron status error'), $i18n->get('spectre'));
    }	

    my %data = (
        workflow    =>  jsonToObj($workflowResult),
        cron        =>  jsonToObj($cronResult),
    );

    my $workflowCount = @{ $data{workflow}{Suspended} } + @{ $data{workflow}{Waiting} } + @{ $data{workflow}{Running} };
    my $workflowUrl   = $session->url->page('op=showRunningWorkflows');
    my $cronCount     = keys %{ $data{cron} };
    my $cronUrl       = $session->url->page('op=manageCron');

    my $output = $i18n->get('running').'<br/>';
    $output .= sprintf $i18n->get('workflow header'), $workflowUrl, $workflowCount;
    $output .= sprintf $i18n->get('cron header'), $cronUrl, $cronCount;

    return $ac->render($output, $i18n->get('spectre'));
}

#-------------------------------------------------------------------

=head2 www_spectreTest (  )

Spectre executes this function to see if WebGUI connectivity is working.

=cut

sub www_spectreTest {
	my $session = shift;
	$session->http->setMimeType("text/plain");
	$session->http->setCacheControl("none");
	unless (isInSubnet($session->env->get("REMOTE_ADDR"), $session->config->get("spectreSubnets"))) {
		$session->errorHandler->security("make a Spectre workflow runner request, but we're only allowed to accept requests from ".join(",",@{$session->config->get("spectreSubnets")}).".");
        	return "subnet";
	}
	my $remote = create_ikc_client(
		port=>$session->config->get("spectrePort"),
		ip=>$session->config->get("spectreIp"),
		name=>rand(100000),
		timeout=>10
		);
	# Can't perform this test until I get smarter. =)
	return "spectre" unless defined $remote;
	my $result = $remote->post_respond('admin/ping');
	$remote->disconnect;
	return "spectre" unless defined $result;
	return "success";
}


1;
