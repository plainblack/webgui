package WebGUI::PassiveProfiling;

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
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::PassiveProfiling

=head1 DESCRIPTION

This package provides an interface to the passive profiling system.

=head1 SYNOPSIS

 use WebGUI::PassiveProfiling;
 WebGUI::PassiveProfiling::add( $assetId );

=head1 METHODS

These functions/methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 add ( assetId )

Adds a assetId to the passive profile log.

=head3 assetId

The assetId to add.

=cut

sub add {
	return unless ($self->session->setting->get("passiveProfilingEnabled"));
	my $assetId = shift;
	my $sql = "insert into passiveProfileLog (passiveProfileLogId, userId, sessionId, assetId, dateOfEntry)
		     values (".$self->session->db->quote(WebGUI::Id::generate()).",".
				$self->session->db->quote($self->session->user->profileField("userId")).",".
				$self->session->db->quote($self->session->var->get("sessionId")).",".
				$self->session->db->quote($assetId).",".
				$self->session->db->quote($self->session->datetime->time()).")";
	$self->session->db->write($sql);
	return;
}

#-------------------------------------------------------------------
                                                                                                                             
=head2 addPage ( [ pageId ] )
                                                                                                                             
Adds all wobjects on current page to the passive profile log.
Optionally you can specify an alternate pageId.
                                                                                                                             
=head3 pageId
                                                                                                                             
The pageId of the page you want to log.
                                                                                                                             
=cut

sub addPage {
	return unless ($self->session->setting->get("passiveProfilingEnabled"));
	my $pageId = shift || $session{page}{pageId};
	my @wids = $self->session->db->buildArray("select * from wobject where pageId=".$self->session->db->quote($pageId));
	foreach my $wid (@wids) {
		add($wid);
	}
	return;
}

#-------------------------------------------------------------------

=head2 summarizeAOI ( hashRef )

Summarizes passive profile log data using the metadata attributes. An entry
is logged in the passiveProfileAOI table.

=head3 hashRef

A hashRef with userId and assetId.

=cut

sub summarizeAOI {
	my $data = shift;
	my $sql = "
		select f.fieldName, 
			f.fieldType, 
			d.fieldId, 
			d.assetId, 
			d.value 
		from metaData_values d , metaData_properties f 
		where f.fieldId = d.fieldId 
			and d.assetId = ".$self->session->db->quote($data->{assetId});

        my $sth = $self->session->db->read($sql);
        while (my $field = $sth->hashRef) {
		my $aoi = $self->session->db->quickHashRef("select * from passiveProfileAOI 
						where userId=".$self->session->db->quote($data->{userId})."
						and fieldId=".$self->session->db->quote($field->{fieldId})." and
						value=".$self->session->db->quote($field->{value}));
		if(not exists $aoi->{userId}) {
			# Add record to DB
			$self->session->db->write("insert into passiveProfileAOI (userId, fieldId, value)
						values (".$self->session->db->quote($data->{userId}).",".
							$self->session->db->quote($field->{fieldId}).",".
							$self->session->db->quote($field->{value}).")");
		}
		my $count = $aoi->{count};
		$count++;

		$self->session->db->write("update passiveProfileAOI set count=".$self->session->db->quote($count)."
					where userId=".$self->session->db->quote($data->{userId})."
                                        and fieldId=".$self->session->db->quote($field->{fieldId})." and
                                        value=".$self->session->db->quote($field->{value})); 
	}
	$sth->finish;
}

1;

