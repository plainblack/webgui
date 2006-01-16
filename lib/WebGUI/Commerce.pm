package WebGUI::Commerce;

use strict;

#-------------------------------------------------------------------
sub setCommerceSetting {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my ($entry);
	$entry = shift;
	$session->db->write("delete from commerceSettings where ". 
		"namespace=".$session->db->quote($entry->{namespace})." and ".
		"type=".$session->db->quote($entry->{type})." and fieldName=".$session->db->quote($entry->{fieldName}));
	$session->db->write("insert into commerceSettings (namespace, type, fieldName, fieldValue) values ".
		"(".$session->db->quote($entry->{namespace}).",".$session->db->quote($entry->{type}).",".$session->db->quote($entry->{fieldName}).",".$session->db->quote($entry->{fieldValue}).")");
}

1;

