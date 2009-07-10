package WebGUI::Workflow::Activity::ExpireSubscriptionCodes;


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
use File::Path;
use File::stat;


=head1 NAME

Package WebGUI::Workflow::Activity::ExpireSubscriptionCodes

=head1 DESCRIPTION

Set old subscription codes expired.

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
	my $i18n = WebGUI::International->new($session, "Asset_Subscription");
	push(@{$definition}, {
		name=>$i18n->get("expire subscription codes"),
		properties=> { }
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	$self->session->db->write(
        "update Subscription_code set status='Expired' where status = 'Unused' and batchId in"
        ." ( select batchId from Subscription_codeBatch where expirationDate < ? )",
        [
            time()
        ]
    );

	return $self->COMPLETE;
}


1;


