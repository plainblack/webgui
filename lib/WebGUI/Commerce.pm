package WebGUI::Commerce;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;

#-------------------------------------------------------------------
sub setCommerceSetting {
	my $session = shift;
	my ($entry);
	$entry = shift;
	$session->db->write("delete from commerceSettings where ". 
		"namespace=".$session->db->quote($entry->{namespace})." and ".
		"type=".$session->db->quote($entry->{type})." and fieldName=".$session->db->quote($entry->{fieldName}));
	$session->db->write("insert into commerceSettings (namespace, type, fieldName, fieldValue) values ".
		"(".$session->db->quote($entry->{namespace}).",".$session->db->quote($entry->{type}).",".$session->db->quote($entry->{fieldName}).",".$session->db->quote($entry->{fieldValue}).")");
}

1;

