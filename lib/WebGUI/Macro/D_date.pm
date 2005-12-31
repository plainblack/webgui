package WebGUI::Macro::D_date;

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
use WebGUI::DateTime;

=head1 NAME

Package WebGUI::Macro::D_date

=head1 DESCRIPTION

Macro for displaying dates formatted for reading by people using WebGUI::DateTime::epochToHuman().

=head2 process ( format string, [ date ] )

=head3 format string

A string specifying how to format the date using codes similar to those used by
sprintf.  See L<WebGUI::DateTime/"epochToHuman"> for a list of codes.

=head3 date

An optional date in epoch format.  If the date is omitted, then the present
time is used instead.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my (@param, $temp, $time);
        @param = @_;
	$time = $param[1] || time();
	$temp = epochToHuman($time,$param[0]);
	return $temp;
}


1;

