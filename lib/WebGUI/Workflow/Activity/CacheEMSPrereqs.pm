package WebGUI::Workflow::Activity::CacheEMSPrereqs;


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
use WebGUI::Asset;
use WebGUI::Cache;
use WebGUI::International;
use base 'WebGUI::Workflow::Activity';

=head1 NAME

Package WebGUI::Workflow::Activity::CacheEMSPrereqs

=head1 DESCRIPTION

Tell a little about what this activity does.

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
	push(@{$definition}, {
		name=>'cacheEMSEvents',
		properties=> { }
	});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my ($emsId) = $self->session->db->quickArray("select assetId from asset where className='WebGUI::Asset::Wobject::EventManagementSystem' limit 1");
	return $self->COMPLETE unless $emsId;
	WebGUI::Cache->new($self->session)->deleteChunk(["verifyAllPrerequisites"]);
	my $ems = WebGUI::Asset->newByDynamicClass($self->session,$emsId);
	my @events = $self->session->db->buildArray("select productId from EventsManagementSystem_products");
	foreach (@events) {
		$ems->verifyAllPrerequisites($_);
	}
	$self->session->errorHandler->warn('EMS Cacher Ran!');
	return $self->COMPLETE;
}



1;


