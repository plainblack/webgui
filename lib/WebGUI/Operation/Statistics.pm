package WebGUI::Operation::Statistics;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _submenu {
	my $session = shift;
	my $workarea = shift;
	my $title = shift;
	$title = WebGUI::International::get($title) if ($title);
	my $ac = WebGUI::AdminConsole->new($session,"statistics");
	if ($session->setting->get("trackPageStatistics")) {
		$ac->addSubmenuItem( $session->url->page('op=viewStatistics'), WebGUI::International::get(144));
	}
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub www_viewStatistics {
	my $session = shift;
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $data);
	my $url = "http://www.plainblack.com/downloads/latest-version.txt";
	my $cache = WebGUI::Cache->new($session,$url,"URL");
	my $version = $cache->get;
	if (not defined $version) {
		$version = $cache->setByHTTP($url,43200);
	}
	chomp $version;
	$output .= '<table>';
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(145).':</td><td class="tableData">'.$WebGUI::VERSION.'-'.$WebGUI::STATUS.'</td></tr>';
	if ($version ne $WebGUI::VERSION) {
		my @rev = split(/\./,$version);
		
		$version = '<a href="http://files.plainblack.com/downloads/'.$rev[0].'.x.x/webgui-'.$version.'.tar.gz">'.$version.'</a>';
	}
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(349).':</td><td class="tableData">'.$version.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from asset where state='published'");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(147).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(distinct assetId) from assetData where isPackage=1");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(794).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from template");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(792).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from userSession");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(146).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from users");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(149).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = $session->db->quickArray("select count(*) from groups");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(89).':</td><td class="tableData">'.$data.'</td></tr>';
	$output .= '</table>';
        return _submenu($output);
}


1;

