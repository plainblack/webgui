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
	my $object = shift;
	my $instance = shift;
	my ($emsId) = $self->session->db->quickArray("select assetId from asset where className='WebGUI::Asset::Wobject::EventManagementSystem' limit 1");
	return $self->COMPLETE unless $emsId;
	WebGUI::Cache->new($self->session)->deleteChunk(["verifyAllPrerequisites"]);
	my $ems = WebGUI::Asset->newByDynamicClass($self->session,$emsId);
	my $start = time();
	my $leftOff = $instance->getScratch("emsleftoff");
	my $skip = ($leftOff ne "") ? 1 : 0;
	my $status = $self->COMPLETE;
	my @events = $self->session->db->buildArray("select productId from EventManagementSystem_products");
	foreach my $event (@events) {
		$skip = 0 if ($leftOff eq $event);
		next if $skip;
		if ((time() - $start) > 60) { # give up so something else can run for a while
			$instance->setScratch("emsleftoff",$event);	
			$status = $self->WAITING;
			last;
		} 
		$self->session->errorHandler->warn('EMS Cacher Running '.$event);
		$ems->verifyAllPrerequisites($event);
	}
	$self->session->errorHandler->warn('EMS Cacher Ran! Status: '.$status);
	return $status;
}



1;


