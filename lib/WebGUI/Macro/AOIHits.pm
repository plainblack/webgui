package WebGUI::Macro::AOIHits;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	my (@param, $temp);
        @param = @_;
	my $key = $param[0];
	my $value = $param[1];
	my $sql = "select count from passiveProfileAOI a, metaData_properties f 
			where a.fieldId=f.fieldId 
			and userId=".quote($session{user}{userId})." 
			and fieldName=".quote($key)." 
			and value=".quote($value);
	my ($count) = WebGUI::SQL->buildArray($sql);
	return $count;
}


1;


