package WebGUI::Operation::LoginHistory;

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
use WebGUI::Paginator;
use WebGUI::SQL;
use Tie::CPHash;

=head1 NAME

Package WebGUI::Operation::LoginHistory

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminLoginHistory") );
}

#-------------------------------------------------------------------

=head2 www_viewLoginHistory ( )

Display the login history for all users by when they logged in.
The login history is a table of username, userId, status, login date,
IP address they logged in from and what browser (really userAgent)
they used.

=cut

sub www_viewLoginHistory {
	my $session = shift;
        return $session->privilege->adminOnly() unless canView($session);
	my ($output, $p, @row, $i, $sth, %data);
	my $i18n = WebGUI::International->new($session);
	tie %data, 'Tie::CPHash';
	$sth = $session->db->read("select * from users,userLoginLog where users.userId=userLoginLog.userId order by userLoginLog.timeStamp desc");	
	while (%data = $sth->hash) {
		$data{username} = $i18n->get('unknown user') if ($data{userId} eq "0");
		$row[$i] = '<tr class="tableData"><td>'.$data{username}.' ('.$data{userId}.')</td>';
		$row[$i] .= '<td>'.$data{status}.'</td>';
		$row[$i] .= '<td>'.$session->datetime->epochToHuman($data{timeStamp}).'</td>';
		$row[$i] .= '<td>'.$data{ipAddress}.'</td>';
		$row[$i] .= '<td>'.$data{userAgent}.'</td>';
        $row[$i] .= '<td>'.$data{sessionId}.'</td>';
        if ($data{lastPageViewed}) {
            if ($data{lastPageViewed} == $data{timeStamp}) {
                $row[$i] .= "<td>Active</td>";
                $row[$i] .= "<td>Active</td></tr>";
            } else {
                $row[$i] .= '<td>'.$session->datetime->epochToHuman($data{lastPageViewed},"%H:%n%p %M/%D/%y").'</td>';
                my ($interval, $units) = $session->datetime->secondsToInterval($data{lastPageViewed} - $data{timeStamp});
                $row[$i] .= "<td>$interval $units</td></tr>";
            }
        } else {
            $row[$i] .= "<td></td>";
            $row[$i] .= "<td></td></tr>";
        }
		$i++;
	}
	$sth->finish;
	$p = WebGUI::Paginator->new($session,$session->url->page('op=viewLoginHistory'));
	$p->setDataByArrayRef(\@row);
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr class="tableHeader"><td>'.$i18n->get(428).'</td>';
	$output .= '<td>'.$i18n->get(434).'</td>';
	$output .= '<td>'.$i18n->get(429).'</td>';
	$output .= '<td>'.$i18n->get(431).'</td>';
    $output .= '<td>'.$i18n->get(433).'</td>';
    $output .= '<td>' . $i18n->get( 435 ) . '</td>';
    $output .= '<td>' . $i18n->get( 430 ) . '</td>';
    $output .= '<td>' . $i18n->get( "session length" ) . '</td></tr>';
        $output .= $p->getPage($session->form->process("pn"));
        $output .= '</table>';
        $output .= $p->getBar($session->form->process("pn"));
	return WebGUI::AdminConsole->new($session,"loginHistory")->render($output);
}

1;
