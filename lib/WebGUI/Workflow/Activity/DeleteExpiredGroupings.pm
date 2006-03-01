package WebGUI::Workflow::Activity::DeleteExpiredGroupings;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Cache::FileCache;

=head1 NAME

Package WebGUI::Workflow::Activity::DeleteExpiredGroupings;

=head1 DESCRIPTION

Deletes user groupings that are past their expire date.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_DeleteExpiredGroupings");
	push(@{$definition}, {
		name=>$i18n->get("topicName"),
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
	my $sth = $self->session->db->read("select groupId,deleteOffset,dbCacheTimeout from groups");
        while (my $data = $sth->hashRef) {
        	if ($data->{dbCacheTimeout} > 0) {
        		# there is no need to wait deleteOffset days for expired external group cache data
                  	$self->session->db->write("delete from groupings where groupId=? and expireDate < ?", [$data->{groupId}, time()]);
                } else {
                        $self->session->db->write("delete from groupings where groupId=? and expireDate < ?", [$data->{groupId}, time()-(86400*$data->{deleteOffset})]);
                }
        }
}



1;


