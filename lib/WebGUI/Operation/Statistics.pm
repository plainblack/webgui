package WebGUI::Operation::Statistics;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::Cache;
use WebGUI::International;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Operation::Statistics

=head1 DESCRIPTION

Handles displaying statistics about WebGUI.  This isn't page count, but rather information
about the number of assets, users, groups, etc.

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


#-------------------------------------------------------------------
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

=head2 www_viewStatistics ( $session )

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

#-------------------------------------------------------------------
sub www_viewStatistics {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
        my ($output, $data);
	my $i18n = WebGUI::International->new($session);
	my $url = "http://update.webgui.org/latest-version.txt";
	my $cache = WebGUI::Cache->new($session,$url,"URL");
	my $version = $cache->get;
	if (not defined $version) {
		$version = $cache->setByHTTP($url,43200);
	}
	chomp $version;
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
        return _submenu($session,$output);
}


1;

