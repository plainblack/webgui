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

=head1 NAME

Package WebGUI::Macro::AOIHits

=head1 DESCRIPTION

Macro for displaying the number of times a key,value pair occurs in the
metadata for content viewed by the current user.

=head2 process ( key, value )

=head3 key

The metadata property that will be looked up.

=head3 value

The value for the key that will be looked up.

=cut

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


