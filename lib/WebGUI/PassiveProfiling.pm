package WebGUI::PassiveProfiling;

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

=head2 add ( session, assetId )

Adds a assetId to the passive profile log.

=head3 session

A reference to the current session.

=head3 assetId

The assetId to add.

=cut

sub add {
    my $session = shift;
    return undef unless ($session->setting->get("passiveProfilingEnabled"));
    my $assetId = shift;
	$session->db->write("insert into passiveProfileLog (passiveProfileLogId, userId, sessionId, assetId, dateOfEntry) values (?,?,?,?,?)",
                       [
                        $session->id->generate(),        $session->user->userId,
                        $session->var->get("sessionId"), $assetId,
                        time(),
                       ]);
    return undef;
}

#-------------------------------------------------------------------

=head2 addPage ( session, assetId )

Adds all wobjects on current page to the passive profile log.

=head3 session

A reference to the current session.

=head3 assetId

The assetId of the page you want to log.

=cut

sub addPage {
	my $session = shift;
	return undef unless ($session->setting->get("passiveProfilingEnabled"));
	my $pageId = shift;
	my @wids = $session->db->buildArray("select assetId from asset where parentId=".$session->db->quote($pageId));
	foreach my $wid (@wids) {
		add($session,$wid);
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 summarizeAOI ( session, hashRef )

Summarizes passive profile log data using the metadata attributes. An entry
is logged in the passiveProfileAOI table.

=head3 session

A reference to the session.

=head3 hashRef

A hashRef with userId and assetId.

=cut

sub summarizeAOI {
	my $session = shift;
	my $data = shift;
	my $sql = "
		select f.fieldName,
			f.fieldType,
			d.fieldId,
			d.assetId,
			d.value
		from metaData_values d , metaData_properties f
		where f.fieldId = d.fieldId
			and d.assetId = ".$session->db->quote($data->{assetId});

        my $sth = $session->db->read($sql);
        while (my $field = $sth->hashRef) {
		my $aoi = $session->db->quickHashRef("select * from passiveProfileAOI
						where userId=".$session->db->quote($data->{userId})."
						and fieldId=".$session->db->quote($field->{fieldId})." and
						value=".$session->db->quote($field->{value}));
		if(not exists $aoi->{userId}) {
			# Add record to DB
			$session->db->write("insert into passiveProfileAOI (userId, fieldId, value)
						values (".$session->db->quote($data->{userId}).",".
							$session->db->quote($field->{fieldId}).",".
							$session->db->quote($field->{value}).")");
		}
		my $count = $aoi->{count};
		$count++;
		$session->db->write("update passiveProfileAOI set count=".$session->db->quote($count)."
					where userId=".$session->db->quote($data->{userId})."
                                        and fieldId=".$session->db->quote($field->{fieldId})." and
                                        value=".$session->db->quote($field->{value}));
	}
	$sth->finish;
}

1;

