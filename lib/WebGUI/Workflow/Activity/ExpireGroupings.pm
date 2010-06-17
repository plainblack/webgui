package WebGUI::Workflow::Activity::ExpireGroupings;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::Inbox;
use WebGUI::International;

=head1 NAME

Package WebGUI::Workflow::Activity::ExpireGroupings

=head1 DESCRIPTION

Handles expiring user groupings.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "WebGUI");
	push(@{$definition}, {
		name=>$i18n->get("expire groupings"),
		properties=> {}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
 	my $now = time();
	my $inbox = WebGUI::Inbox->new($self->session);
	my $i18n = WebGUI::International->new($self->session, "WebGUI");
        my $a = $self->session->db->read("select groupId,expireNotifyOffset,expireNotifyMessage from groups where expireNotify=1");
        while (my $group = $a->hashRef) {
        	my $start = $now + ($group->{expireNotifyOffset}-1);
                my $end = $start + 86400;
                my $b = $self->session->db->read("select userId from groupings where groupId=? and expireDate>=? and expireDate<=?", [$group->{groupId}, $start, $end]);
                while (my ($userId) = $b->array) { 
			$inbox->addMessage({
				userId=>$userId,
				subject=>$i18n->get(867),
				message=>$group->{expireNotifyMessage}
				});	
                }
        } 
	my $sth = $self->session->db->read("select groupId,deleteOffset,groupCacheTimeout from groups");
        while (my $data = $sth->hashRef) {
        	if ($data->{groupCacheTimeout} > 0) {
        		# there is no need to wait deleteOffset days for expired external group cache data
                  	$self->session->db->write("delete from groupings where groupId=? and expireDate < ?", [$data->{groupId}, time()]);
                } else {
                        $self->session->db->write("delete from groupings where groupId=? and expireDate < ?", [$data->{groupId}, time()-$data->{deleteOffset}]);
                }
        }
	return $self->COMPLETE;
}



1;


