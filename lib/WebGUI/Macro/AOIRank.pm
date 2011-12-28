package WebGUI::Macro::AOIRank;

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

Package WebGUI::Macro::AOIRank

=head1 DESCRIPTION

Macro for displaying the value for a metadata property by rank.

=head2 process ( key, [ rank ] )

=head3 key

The metadata property that will be looked up.

=head3 rank

Define which value, by it's ranking, will be displayed.  The highest ranking is
1.  If the rank is omitted, a default of 1 will be used.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my $key = shift;
	my $rank = shift || 1; # 1 is highest rank
	$rank--;	# Rank is zero based
	my $sql = "select value from passiveProfileAOI a, metaData_properties f 
			where a.fieldId=f.fieldId 
			and userId=".$session->db->quote($session->user->userId)." 
			and fieldName=".$session->db->quote($key)." order by a.count desc";
	my @values = $session->db->buildArray($sql);
	return $values[$rank];
}


1;


