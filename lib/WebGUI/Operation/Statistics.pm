package WebGUI::Operation::Statistics;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use HTTP::Request;
use HTTP::Headers;
use LWP::UserAgent;
use strict;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewStatistics &www_killSession &www_viewLoginHistory &www_viewActiveSessions);

#-------------------------------------------------------------------
sub www_killSession {
        if (WebGUI::Privilege::isInGroup(3)) {
		WebGUI::Session::end($session{form}{sid});
		return www_viewActiveSessions();
        } else {
                return WebGUI::Privilege::adminOnly();
	}
}

#-------------------------------------------------------------------
sub www_viewActiveSessions {
	my ($output, $p, @row, $i, $sth, %data);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
                $output = '<h1>'.WebGUI::International::get(425).'</h1>';
		$sth = WebGUI::SQL->read("select * from users,userSession where users.userId=userSession.userId");
		while (%data = $sth->hash) {
                        $row[$i] = '<tr class="tableData"><td>'.$data{username}.' ('.$data{userId}.')</td>';
                        $row[$i] .= '<td>'.$data{sessionId}.'</td>';
                        $row[$i] .= '<td>'.epochToHuman($data{expires},"%H:%n%p %M/%D/%y").'</td>';
                        $row[$i] .= '<td>'.epochToHuman($data{lastPageView},"%H:%n%p %M/%D/%y").'</td>';
                        $row[$i] .= '<td>'.$data{lastIP}.'</td>';
			$row[$i] .= '<td align="center"><a href="'.WebGUI::URL::page("op=killSession&sid=$data{sessionId}").'">'.'<img src="'.$session{setting}{lib}.'/delete.gif" border="0"></a></td></tr>';
                        $i++;
		}
		$sth->finish;
		$p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewActiveSessions'),\@row);
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
        } else {
                $output = WebGUI::Privilege::adminOnly();
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_viewLoginHistory {
	my ($output, $p, @row, $i, $sth, %data);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(3)) {
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
		$p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewLoginHistory'),\@row);
		$output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
		$output .= '<tr class="tableHeader"><td>'.WebGUI::International::get(428).'</td>';
		$output .= '<td>'.WebGUI::International::get(434).'</td>';
		$output .= '<td>'.WebGUI::International::get(429).'</td>';
		$output .= '<td>'.WebGUI::International::get(431).'</td>';
		$output .= '<td>'.WebGUI::International::get(433).'</td></tr>';
                $output .= $p->getPage($session{form}{pn});
                $output .= '</table>';
                $output .= $p->getBar($session{form}{pn});
        } else {
                $output = WebGUI::Privilege::adminOnly();
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_viewStatistics {
        my ($output, $data, $header, $userAgent, $request, $response, $version, $referer);
        if (WebGUI::Privilege::isInGroup(3)) {
		$userAgent = new LWP::UserAgent;
		$userAgent->agent("WebGUI-Check/2.0");
		$userAgent->timeout(10);
		$header = new HTTP::Headers;
		$referer = "http://webgui.web.getversion/".$session{env}{SERVER_NAME}.$session{env}{REQUEST_URI};
		chomp $referer;
		$header->referer($referer);
		$request = new HTTP::Request (GET => "http://www.plainblack.com/downloads/latest-version.txt", $header);
		$response = $userAgent->request($request);
		$version = $response->content;
		chomp $version;
                $output .= helpLink(12);
                $output .= '<h1>'.WebGUI::International::get(437).'</h1>';
		$output .= '<table>';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(145).'</td><td class="tableData">'.$WebGUI::VERSION.' ('.WebGUI::International::get(349).': '.$version.')</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from userSession");
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(146).'</td><td class="tableData">'.$data.' (<a href="'.WebGUI::URL::page("op=viewActiveSessions").'">'.WebGUI::International::get(423).'</a> / <a href="'.WebGUI::URL::page("op=viewLoginHistory").'">'.WebGUI::International::get(424).'</a>)</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from page where parentId>25");
		$data++;
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(147).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from wobject");
		$data--;
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(148).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from style where styleId>25");
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(427).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from users where userId>25");
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(149).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from groups where groupId>25");
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(89).'</td><td class="tableData">'.$data.'</td></tr>';
		$output .= '</table>';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}



1;

