package WebGUI::Operation::Statistics;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
	my $workarea = shift;
	my $title = shift;
	$title = WebGUI::International::get($title) if ($title);
	my $ac = WebGUI::AdminConsole->new;
	$ac->setAdminFunction("statistics");
	if ($session{setting}{trackPageStatistics}) {
		$ac->addSubmenuItem( WebGUI::URL::page("op=viewPageReport"), WebGUI::International::get(796));
#		$ac->addSubmenuItem( WebGUI::URL::page("op=viewTrafficReport"), WebGUI::International::get(797));
		$ac->addSubmenuItem( WebGUI::URL::page('op=viewStatistics'), WebGUI::International::get(144));
	}
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_viewPageReport {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $count, $user, $data, $sth, %page, $pageId);
	tie %page, "Tie::IxHash";
	unless ($session{setting}{trackPageStatistics}) {
		$output .= WebGUI::International::get(802);
	} else {
		$sth = WebGUI::SQL->read("select pageTitle,pageId,userId,ipAddress,wobjectId 
			from pageStatistics order by pageTitle,userId,ipAddress");
		while ($data = $sth->hashRef) {
			if ($data->{userId} == 1) {
				$user = $data->{ipAddress};
			} else {
				$user = $data->{userId};
			}
			$page{$data->{pageId}}{pageTitle} = $data->{pageTitle};
			$page{$data->{pageId}}{users}{$user}++;
			$page{$data->{pageId}}{views}++;
			$page{$data->{pageId}}{interact}++ if ($data->{wobjectId});
		}
		$sth->finish;
		$output .= '<table width="100%" cellpadding="3" cellspacing="0" border="1">
			<tr><td class="tableHeader">'.WebGUI::International::get(798).'</td>
			<td class="tableHeader">'.WebGUI::International::get(799).'</td>
			<td class="tableHeader">'.WebGUI::International::get(800).'</td>
			<td class="tableHeader">'.WebGUI::International::get(801).'</td></tr>';
		foreach $pageId (keys %page) {
			$output .= '<tr><td class="tableData">'.$page{$pageId}{pageTitle}.'</td>';
			$output .= '<td class="tableData">'.$page{$pageId}{views}.'</td>';
			$count = 0;
			foreach (keys %{$page{$pageId}{users}}) {
				$count++;
			}
			$output .= '<td class="tableData">'.$count.'</td>';
			$output .= '<td class="tableData">'.$page{$pageId}{interact}.'</td></tr>';
		}
		$output .= '</table>';
	}
	return _submenu($output,"page statistics");
}

#-------------------------------------------------------------------
sub www_viewStatistics {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $data);
	my $url = "http://www.plainblack.com/downloads/latest-version.txt";
	my $cache = WebGUI::Cache->new($url,"URL");
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
	($data) = WebGUI::SQL->quickArray("select count(*) from page where parentId<>3");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(147).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from page where parentId=0");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(795).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from page where parentId=5");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(794).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from wobject where pageId<>3");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(148).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from template where namespace='style'");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(427).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from template where namespace<>'style'");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(792).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from collateral");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(793).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from userSession");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(146).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from users");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(149).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from groups");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(89).':</td><td class="tableData">'.$data.'</td></tr>';
	$output .= '</table>';
        return _submenu($output);
}

#-------------------------------------------------------------------
sub www_viewTrafficReport {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $data);
	$output = '<h1>Pages</h1>';
	($data) = WebGUI::SQL->quickArray("select count(*) from pageStatistics where dateStamp>=".(time()-2592000));
	$output .= "Last 30 days: ".$data."<br>";
	($data) = WebGUI::SQL->quickArray("select count(*) from pageStatistics where dateStamp>=".(time()-604800));
	$output .= "Last 7 days: ".$data."<br>";
        ($data) = WebGUI::SQL->quickArray("select count(*) from pageStatistics where dateStamp>=".(time()-86400));
        $output .= "Last 24 hours: ".$data."<br>";
        $output .= '<h1>Visitors</h1>';
        ($data) = WebGUI::SQL->quickArray("select count(*) from pageStatistics where dateStamp>=".(time()-2592000)
		." group by ipAddress,userId");
        $output .= "Last 30 days: ".$data."<br>";
        ($data) = WebGUI::SQL->quickArray("select count(*) from pageStatistics where dateStamp>=".(time()-604800)
		." group by ipAddress,userId");
        $output .= "Last 7 days: ".$data."<br>";
        ($data) = WebGUI::SQL->quickArray("select count(*) from pageStatistics where dateStamp>=".(time()-86400)
		." group by ipAddress,userId");
        $output .= "Last 24 hours: ".$data."<br>";
	return _submenu($output);
}

1;

