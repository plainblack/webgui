package WebGUI::Commerce;

use strict;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub setCommerceSetting {
	my ($entry);
	$entry = shift;
	WebGUI::SQL->write("delete from commerceSettings where ". 
		"namespace=".quote($entry->{namespace})." and ".
		"type=".quote($entry->{type})." and fieldName=".quote($entry->{fieldName}));
	WebGUI::SQL->write("insert into commerceSettings (namespace, type, fieldName, fieldValue) values ".
		"(".quote($entry->{namespace}).",".quote($entry->{type}).",".quote($entry->{fieldName}).",".quote($entry->{fieldValue}).")");
}

1;

