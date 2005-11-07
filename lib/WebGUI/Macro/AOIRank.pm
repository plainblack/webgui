package WebGUI::Macro::AOIRank;

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
	my $rank = $param[1] || 1; # 1 is highest rank
	$rank--;	# Rank is zero based
	my $sql = "select value from passiveProfileAOI a, metaData_properties f 
			where a.fieldId=f.fieldId 
			and userId=".quote($session{user}{userId})." 
			and fieldName=".quote($key)." order by a.count desc";
	my @values = WebGUI::SQL->buildArray($sql);
	return $values[$rank];
}


1;


