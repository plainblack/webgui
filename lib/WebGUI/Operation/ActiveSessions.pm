package WebGUI::Operation::ActiveSessions;

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

Package WebGUI::Operations::ActiveSessions

=head1 DESCRIPTION

Operation handler for displaying and killing active sessions.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the given user is allowed to use this operation. user must be
a WebGUI::User object. By default, checks the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminActiveSessions") );
}

#-------------------------------------------------------------------

=head2 www_killSession ( )

This method can be called directly, but is usually called
from www_viewActiveSessions. It ends the active session in
$session->form->process("sid").  Afterwards, it calls www_viewActiveSessions.

=cut

sub www_killSession {
	my $session = shift;
	return www_viewActiveSessions($session) if $session->form->process("sid") eq $session->var->get("sessionId");
	return $session->privilege->adminOnly unless canView($session);
	$session->db->write("delete from userSession where sessionId=?",[$session->form->process("sid")]);
	$session->db->write("delete from userSessionScratch where sessionId=?", [$session->form->process("sid")]);
	return www_viewActiveSessions($session);
}

#-------------------------------------------------------------------

=head2 www_viewActiveSessions ( )

Display a list of all active user sessions, along with an icon to
delete (kill) each one via www_killSession

=cut

sub www_viewActiveSessions {
    my $session = shift;
    return $session->privilege->adminOnly unless canView($session);
    my $i18n   = WebGUI::International->new($session);
    my $output = '<table border="1" cellpadding="5" cellspacing="0" align="center">';
    $output .= '<tr class="tableHeader"><td>'.$i18n->get(428).'</td>';
    $output .= '<td>'.$i18n->get(435).'</td>';
    $output .= '<td>'.$i18n->get(432).'</td>';
    $output .= '<td>'.$i18n->get(430).'</td>';
    $output .= '<td>'.$i18n->get(431).'</td>';
    $output .= '<td>'.$i18n->get(436).'</td></tr>';
    my $p = WebGUI::Paginator->new($session,$session->url->page('op=viewActiveSessions'));
    $p->setDataByQuery("select users.username,users.userId,userSession.sessionId,userSession.expires,
        userSession.lastPageView,userSession.lastIP from users,userSession where users.userId=userSession.userId
        and users.userId<>1 order by users.username,userSession.lastPageView desc");
    my $pn = $p->getPageNumber;
    foreach my $data (@{ $p->getPageData() }) {
        $output  = '<tr class="tableData"><td>'.$data->{username}.' ('.$data->{userId}.')</td>';
        $output .= '<td>'.$data->{sessionId}.'</td>';
        $output .= '<td>'.$session->datetime->epochToHuman($data->{expires}).'</td>';
        $output .= '<td>'.$session->datetime->epochToHuman($data->{lastPageView}).'</td>';
        $output .= '<td>'.$data->{lastIP}.'</td>';
        $output .= '<td align="center">'.$session->icon->delete("op=killSession;sid=".$data->{sessionId}.";pn=$pn").'</td></tr>';
    }
    $output .= '</table>';
    $output .= $p->getBarTraditional();
    return WebGUI::AdminConsole->new($session,"activeSessions")->render($output);
}

1;
