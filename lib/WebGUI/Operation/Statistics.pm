package WebGUI::Operation::Statistics;

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
use WebGUI::AdminConsole;
use WebGUI::Cache;
use WebGUI::International;
use WebGUI::SQL;

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


#-------------------------------------------------------------------
sub www_viewStatistics {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
        my ($output, $data);
	my $i18n = WebGUI::International->new($session);
	my $url = "http://www.plainblack.com/downloads/latest-version.txt";
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
		
		$version = '<a href="http://files.plainblack.com/downloads/'.$rev[0].'.x.x/webgui-'.$version.'.tar.gz">'.$version.'</a>';
	}
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(349).':</td><td class="tableData">'.$version.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from asset where state='published'");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(147).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(distinct assetId) from assetData where isPackage=1");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(794).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from template");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(792).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from userSession");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(146).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from users");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(149).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from groups");
	$output .= '<tr><td align="right" class="tableHeader">'.$i18n->get(89).':</td><td class="tableData">'.$data.'</td></tr>';
	$output .= '</table>';
        return _submenu($output);
}


1;

