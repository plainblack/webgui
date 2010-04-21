package WebGUI::Operation::Statistics;

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
use WebGUI::International;
use WebGUI::Workflow::Cron;
use WebGUI::DateTime;

=head1 NAME

Package WebGUI::Operation::Statistics

=head1 DESCRIPTION

Handles displaying statistics about WebGUI.  This isn't page count, but rather information
about the number of assets, users, groups, etc.

#-------------------------------------------------------------------

=head2 _submenu ( $session, $workarea, $title, $help )

Utility routine for creating the AdminConsole for Statistics functions.

=head3 $session

The current WebGUI session object.

=head3 $workarea

The content to display to the user.

=head3 $title

The title of the Admin Console.  This should be an entry in the i18n
table in the WebGUI namespace.

=head3 $help

An entry in the Help system in the WebGUI namespace.  This will be shown
as a link to the user.

=cut

sub _submenu {
	my $session = shift;
	my $workarea = shift;
	my $title = shift;
	my $i18n = WebGUI::International->new($session);
	$title = $i18n->get($title) if ($title);
	my $ac = WebGUI::AdminConsole->new($session,"statistics");
	if ($session->setting->get("trackPageStatistics")) {
		$ac->addSubmenuItem( $session->url->page('op=viewStatistics'), $i18n->get(144));
	}
        return $ac->render($workarea, $title);
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminStatistics") );
}


#-------------------------------------------------------------------

=head2 www_disableSendWebguiStats ()

Deletes the workflow schedule that sends WebGUI statistics to webgui.org.

=cut

sub www_disableSendWebguiStats {
    my $session = shift;
    return $session->privilege->adminOnly() unless canView($session);
    my $task = WebGUI::Workflow::Cron->new($session, 'send_webgui_statistics');
    $task->delete;
    my $workflow = WebGUI::Workflow->new($session, 'send_webgui_statistics');
    $workflow->set({enabled => 0});
    return www_viewStatistics($session);
}


#-------------------------------------------------------------------

=head2 www_enableSendWebguiStats ()

Creates the workflow schedule that sends WebGUI statistics to webgui.org.

=cut

sub www_enableSendWebguiStats {
    my $session = shift;
    return $session->privilege->adminOnly() unless canView($session);
    # we set the current hour, minute, and day of week to send in the stats so we don't DOS webgui.org
    # by having everybody sending it at the same time
    my $dt = WebGUI::DateTime->new($session, time());
    WebGUI::Workflow::Cron->create($session, {
        enabled         => 1,
        workflowId      => 'send_webgui_statistics',
        minuteOfHour    => $dt->minute,
        hourOfDay       => $dt->hour,
        dayOfWeek       => ($dt->dow % 7),
        dayOfMonth      => '*',
        monthOfYear     => '*', 
        priority        => 3,
        title           => 'Send WebGUI Statistics',
        }, 'send_webgui_statistics');
    my $workflow = WebGUI::Workflow->new($session, 'send_webgui_statistics');
    $workflow->set({enabled => 1});
    return www_viewStatistics($session);
}


#-------------------------------------------------------------------

=head2 www_viewStatistics ( $session, $sent )

Displays information to the user about WebGUI statistics if they are
in group Admin (3).

=head3 Displayed information

=over 4

=item *

Newest WebGUI version.

=item *

Current WebGUI version, if different from newest.

=item *

Number of published assets.

=item *

Number of assets set to be packages.

=item *

Number of templates

=item *

Number of sessions

=item *

Number of users.

=item *

Number of groups.

=back

=cut

sub www_viewStatistics {
	my $session = shift;
    return $session->privilege->adminOnly() unless canView($session);
    my ($output, $data);
	my $i18n = WebGUI::International->new($session);
	
        # Get the latest WebGUI version
        my $url = "http://update.webgui.org/latest-version.txt";
	my $cache = $session->cache;
        my $version = $cache->compute( $url, sub { 
            my $ua = LWP::UserAgent->new(
                env_proxy       => 1,
                agent           => "WebGUI/" . $WebGUI::VERSION,
                timeout         => 30,
            );

            my $r = $ua->get( $url );
            if ( $r->is_error ) {
                $session->log->warn( "Could not get latest WebGUI version from '$url': " . $r->status_line );
            }
            else {
                return $r->decoded_content;
            }
        } );

	$output .= '<table>';
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(145).':</td><td class="tableData">'.$WebGUI::VERSION.'-'.$WebGUI::STATUS.'</td></tr>';
	if ($version ne $WebGUI::VERSION) {
		my @rev = split(/\./,$version);
		
		$version = '<a href="http://update.webgui.org/'.$rev[0].'.x.x/webgui-'.$version.'.tar.gz">'.$version.'</a>';
	}
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(349).':</td><td class="tableData">'.$version.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from asset where state='published'");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(147).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(distinct assetId) from assetData where isPackage=1");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(794).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(distinct(assetId)) from template");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(792).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from userSession");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(146).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from users");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(149).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from groups");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(89).':</td><td class="tableData">'.$data.'</td></tr>';
	$output .= '</table>';

    $output .= q|<p>|.$i18n->get('why to send','Activity_SendWebguiStats').q|</p>|;

    my $task = WebGUI::Workflow::Cron->new($session, 'send_webgui_statistics');
    if (defined $task) {
        $output .= q|<p><a href="|.$session->url->page("op=disableSendWebguiStats").q|">|.$i18n->get('disable','Activity_SendWebguiStats').q|</a></p>|;
    }
    else {
        $output .= q|<p><a href="|.$session->url->page("op=enableSendWebguiStats").q|">|.$i18n->get('enable','Activity_SendWebguiStats').q|</a></p>|;
    }
    $output .= q|<p><a href="http://www.webgui.org/stats">http://www.webgui.org/stats</a></p>|;
    return _submenu($session,$output);
}


1;

