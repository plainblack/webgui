package WebGUI::Authentication;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use WebGUI::SQL;
use strict;

sub saveParams {
	my ($uid, $authMethod, $data, @values);

	($uid, $authMethod, $data) = @_;
	foreach (keys(%$data)) {
		WebGUI::SQL->write("delete from authentication where userId=$uid and authMethod=".quote($authMethod)." and fieldName=".quote($_));
		WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldData,fieldName) values ($uid,".quote($authMethod).",".quote($$data{$_}).",".quote($_).")");
	}
}

sub getParams {
	my ($uid, $authMethod);
	$uid = shift;
	$authMethod = shift;
	return WebGUI::SQL->buildHashRef("select fieldName, fieldData from authentication where userId=$uid and authMethod='$authMethod'");
}

sub deleteParams {
	my $uid = shift;
	
	if ($uid) {
		WebGUI::SQL->write("delete from authentication where userId=$uid");
	}
}

1;
