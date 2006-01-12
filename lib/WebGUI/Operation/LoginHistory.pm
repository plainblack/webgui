package WebGUI::Operation::LoginHistory;

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
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Operation::LoginHistory

=cut

#-------------------------------------------------------------------

=head2 www_viewLoginHistory ( )

Display the login history for all users by when they logged in.
The login history is a table of username, userId, status, login date,
IP address they logged in from and what browser (really userAgent)
they used.

=cut

sub www_viewLoginHistory {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my ($output, $p, @row, $i, $sth, %data);
	tie %data, 'Tie::CPHash';
	$sth = $session->db->read("select * from users,userLoginLog where users.userId=userLoginLog.userId order by userLoginLog.timeStamp desc");	
	while (%data = $sth->hash) {
		$data{username} = WebGUI::International::get('unknown user') if ($data{userId} eq "0");
		$row[$i] = '<tr class="tableData"><td>'.$data{username}.' ('.$data{userId}.')</td>';
		$row[$i] .= '<td>'.$data{status}.'</td>';
		$row[$i] .= '<td>'$session->datetime->epochToHuman($data{timeStamp},"%H:%n%p %M/%D/%y").'</td>';
		$row[$i] .= '<td>'.$data{ipAddress}.'</td>';
		$row[$i] .= '<td>'.$data{userAgent}.'</td></tr>';
		$i++;
	}
	$sth->finish;
	$p = WebGUI::Paginator->new($session,$session->url->page('op=viewLoginHistory'));
	$p->setDataByArrayRef(\@row);
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr class="tableHeader"><td>'.WebGUI::International::get(428).'</td>';
	$output .= '<td>'.WebGUI::International::get(434).'</td>';
	$output .= '<td>'.WebGUI::International::get(429).'</td>';
	$output .= '<td>'.WebGUI::International::get(431).'</td>';
	$output .= '<td>'.WebGUI::International::get(433).'</td></tr>';
        $output .= $p->getPage($session->form->process("pn"));
        $output .= '</table>';
        $output .= $p->getBar($session->form->process("pn"));
	return WebGUI::AdminConsole->new($session,"loginHistory")->render($output);
}

1;
