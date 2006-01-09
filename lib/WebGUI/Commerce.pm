package WebGUI::Commerce;

use strict;

#-------------------------------------------------------------------
sub setCommerceSetting {
	my ($entry);
	$entry = shift;
	$self->session->db->write("delete from commerceSettings where ". 
		"namespace=".$self->session->db->quote($entry->{namespace})." and ".
		"type=".$self->session->db->quote($entry->{type})." and fieldName=".$self->session->db->quote($entry->{fieldName}));
	$self->session->db->write("insert into commerceSettings (namespace, type, fieldName, fieldValue) values ".
		"(".$self->session->db->quote($entry->{namespace}).",".$self->session->db->quote($entry->{type}).",".$self->session->db->quote($entry->{fieldName}).",".$self->session->db->quote($entry->{fieldValue}).")");
}

1;

