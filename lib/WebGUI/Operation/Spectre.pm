package WebGUI::Operation::Spectre;

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
use JSON;
use POE::Component::IKC::ClientLite;
use WebGUI::Workflow::Cron;
use WebGUI::Workflow::Instance;
use Net::CIDR::Lite;

=head1 NAME

Package WebGUI::Operation::Spectre

=head1 DESCRIPTION

Operations for Spectre.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminSpectre") );
}

#-------------------------------------------------------------------

=head2 www_spectreGetSiteData ( )

Checks to ensure the requestor is who we think it is, and then returns a JSON string with worklfow and cron data. We do it in one payload for efficiency.

=cut

sub www_spectreGetSiteData {
    my $session = shift;
	$session->response->content_type("application/json");
	$session->http->setCacheControl("none");
	my %siteData = ();
    my $subnets = $session->config->get("spectreSubnets");
    if (!defined $subnets) {
        $subnets = [];
    }
	if (!Net::CIDR::Lite->new(@$subnets)->find($session->request->address)) {
		$session->log->security("Tried to make a Spectre workflow data load request, but we're only allowed to accept requests from "
			.join(",",@{$subnets}).".");
	} 
  	else {
		my $sitename = $session->config->get("sitename")->[0];
		my $gateway = $session->config->get("gateway");
		my $cookieName = $session->config->getCookieName;
		my @instances = ();
		foreach my $instance (@{WebGUI::Workflow::Instance->getAllInstances($session)}) {
			next unless $instance->getWorkflow && $instance->getWorkflow->get("enabled");
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
	return JSON::to_json(\%siteData);
}

#-------------------------------------------------------------------

=head2 www_spectreStatus (  )

Show information about Spectre's current workload.

=cut

sub www_spectreStatus {
    my $session = shift;
    
    return $session->privilege->adminOnly unless canView($session);

    # start to prepare the display
    my $ac = WebGUI::AdminConsole->new($session, 'spectre');
    my $i18n = WebGUI::International->new($session, 'Spectre');

    $session->http->setCacheControl("none");

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
        workflow    =>  decode_json($workflowResult),
        cron        =>  decode_json($cronResult),
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

Spectre executes this function to see if WebGUI connectivity is working.  Note, the subnet checking
is done in here because it is only, ever intended that Spectre use this method.  If a user were to
call this method, it would lie, since it would be checking if the user's IP address was a valid
spectreSubnet, instead of checking the IP address of the spectre process.

=cut

sub www_spectreTest {
	my $session = shift;
	$session->response->content_type("text/plain");
	$session->http->setCacheControl("none");

    my $subnets = $session->config->get("spectreSubnets");
    if (!defined $subnets) {
        $subnets = [];
    }

    my $sessionIp = $session->request->address;
	unless (Net::CIDR::Lite->new(@$subnets)->find($sessionIp)) {
		$session->log->security(
            sprintf "Tried to make a Spectre workflow runner request from %s, but we're only allowed to accept requests from %s",
                $sessionIp, join(",",@{$subnets})
        );
        return "subnet";
	}
    return WebGUI::Operation::Spectre::spectreTest($session);
}

#-------------------------------------------------------------------

=head2 spectreTest (  )

Spectre executes this function to see if WebGUI connectivity is working.  It does not
do subnet checking, yet.

=cut

sub spectreTest{
	my $session = shift;
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
    ##A real spectre subnet test would go here, and would consist of the following
    ##events:
    ## 1) WebGUI talks to spectre.
    ## 2) Spectre makes a request of WebGUI
    ## 3) WebGUI returns a token or an error
    ## 4) spectre returns the result of the request to WebGUI
    ## 5) WebGUI lets the user know how it all ended up.
	return "success";
}


1;
