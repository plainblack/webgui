package WebGUI::Operation::LoginHistory;

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
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;


#-------------------------------------------------------------------
sub www_viewLoginHistory {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my ($output, $p, @row, $i, $sth, %data);
	tie %data, 'Tie::CPHash';
	$sth = WebGUI::SQL->read("select * from users,userLoginLog where users.userId=userLoginLog.userId order by userLoginLog.timeStamp desc");	
	while (%data = $sth->hash) {
		$data{username} = 'unknown user' if ($data{userId} eq "0");
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
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr class="tableHeader"><td>'.WebGUI::International::get(428).'</td>';
	$output .= '<td>'.WebGUI::International::get(434).'</td>';
	$output .= '<td>'.WebGUI::International::get(429).'</td>';
	$output .= '<td>'.WebGUI::International::get(431).'</td>';
	$output .= '<td>'.WebGUI::International::get(433).'</td></tr>';
        $output .= $p->getPage($session{form}{pn});
        $output .= '</table>';
        $output .= $p->getBar($session{form}{pn});
	return WebGUI::AdminConsole->new("loginHistory")->render($output);
}

1;
