package WebGUI::Operation::Statistics;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Cache;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewPageReport &www_viewStatistics &www_viewTrafficReport &www_killSession 
	&www_viewLoginHistory &www_viewActiveSessions);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page("op=viewActiveSessions")} = WebGUI::International::get(423);
	$menu{WebGUI::URL::page("op=viewLoginHistory")} = WebGUI::International::get(424);
	$menu{WebGUI::URL::page("op=viewPageReport")} = WebGUI::International::get(796);
#	$menu{WebGUI::URL::page("op=viewTrafficReport")} = WebGUI::International::get(797);
	$menu{WebGUI::URL::page('op=viewStatistics')} = WebGUI::International::get(144);
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_killSession {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::Session::end($session{form}{sid});
	return www_viewActiveSessions();
}

#-------------------------------------------------------------------
sub www_viewActiveSessions {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $p, @row, $i, $sth, %data);
	tie %data, 'Tie::CPHash';
        $output = '<h1>'.WebGUI::International::get(425).'</h1>';
	$sth = WebGUI::SQL->read("select users.username,users.userId,userSession.sessionId,userSession.expires,
		userSession.lastPageView,userSession.lastIP from users,userSession where users.userId=userSession.userId
		and users.userId<>1 order by users.username,userSession.lastPageView desc");
	while (%data = $sth->hash) {
                $row[$i] = '<tr class="tableData"><td>'.$data{username}.' ('.$data{userId}.')</td>';
                $row[$i] .= '<td>'.$data{sessionId}.'</td>';
                $row[$i] .= '<td>'.epochToHuman($data{expires}).'</td>';
                $row[$i] .= '<td>'.epochToHuman($data{lastPageView}).'</td>';
                $row[$i] .= '<td>'.$data{lastIP}.'</td>';
		$row[$i] .= '<td align="center">'.deleteIcon("op=killSession&sid=$data{sessionId}").'</td></tr>';
                $i++;
	}
	$sth->finish;
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewActiveSessions'));
	$p->setDataByArrayRef(\@row);
        $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
        $output .= '<tr class="tableHeader"><td>'.WebGUI::International::get(428).'</td>';
        $output .= '<td>'.WebGUI::International::get(435).'</td>';
        $output .= '<td>'.WebGUI::International::get(432).'</td>';
        $output .= '<td>'.WebGUI::International::get(430).'</td>';
        $output .= '<td>'.WebGUI::International::get(431).'</td>';
	$output .= '<td>'.WebGUI::International::get(436).'</td></tr>';
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBarTraditional($session{form}{pn});
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_viewLoginHistory {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $p, @row, $i, $sth, %data);
	tie %data, 'Tie::CPHash';
        $output = '<h1>'.WebGUI::International::get(426).'</h1>';
	$sth = WebGUI::SQL->read("select * from users,userLoginLog where users.userId=userLoginLog.userId order by userLoginLog.timeStamp desc");	
	while (%data = $sth->hash) {
		$data{username} = 'unknown user' if ($data{userId} == 0);
		$row[$i] = '<tr class="tableData"><td>'.$data{username}.' ('.$data{userId}.')</td>';
		$row[$i] .= '<td>'.$data{status}.'</td>';
		$row[$i] .= '<td>'.epochToHuman($data{timeStamp},"%H:%n%p %M/%D/%y").'</td>';
		$row[$i] .= '<td>'.$data{ipAddress}.'</td>';
		$row[$i] .= '<td>'.$data{userAgent}.'</td></tr>';
		$i++;
	}
	$sth->finish;
	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewLoginHistory'));
	$p->setDataByArrayRef(\@row);
	$output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
	$output .= '<tr class="tableHeader"><td>'.WebGUI::International::get(428).'</td>';
	$output .= '<td>'.WebGUI::International::get(434).'</td>';
	$output .= '<td>'.WebGUI::International::get(429).'</td>';
	$output .= '<td>'.WebGUI::International::get(431).'</td>';
	$output .= '<td>'.WebGUI::International::get(433).'</td></tr>';
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBar($session{form}{pn});
	return _submenu($output);
}

#-------------------------------------------------------------------
sub www_viewPageReport {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $count, $user, $data, $sth, %page, $pageId);
	tie %page, "Tie::IxHash";
	$output = '<h1>Page Statistics</h1>';
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
	return _submenu($output);
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
        $output .= helpIcon(12);
        $output .= '<h1>'.WebGUI::International::get(437).'</h1>';
	$output .= '<table>';
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(145).':</td><td class="tableData">'.$WebGUI::VERSION.'</td></tr>';
	if ($version ne $WebGUI::VERSION) {
		my @rev = split(/\./,$version);
		
		$version = '<a href="http://files.plainblack.com/downloads/'.$rev[0].'.x.x/webgui-'.$version.'.tar.gz">'.$version.'</a>';
	}
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(349).':</td><td class="tableData">'.$version.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from page where parentId>1000 and parentId<>3");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(147).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from page where parentId>1000 and parentId=0");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(795).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from page where parentId=5");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(794).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from wobject where wobjectId > 0 and pageId<>3");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(148).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from template where templateId>1000 and namespace='style'");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(427).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from template where templateId>1000 and namespace<>'style'");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(792).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from collateral");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(793).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from userSession");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(146).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from users where userId>25");
	$output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get(149).':</td><td class="tableData">'.$data.'</td></tr>';
	($data) = WebGUI::SQL->quickArray("select count(*) from groups where groupId>25");
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

