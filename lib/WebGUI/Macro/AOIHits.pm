package WebGUI::Macro::AOIHits;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

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
	my $session = shift;
	my $key = shift; 
	my $value = shift;
	my $sql = "select count from passiveProfileAOI a, metaData_properties f 
			where a.fieldId=f.fieldId 
			and userId=".$session->db->quote($session->user->userId)." 
			and fieldName=".$session->db->quote($key)." 
			and value=".$session->db->quote($value);
	my ($count) = $session->db->buildArray($sql);
	return $count;
}


1;


