package WebGUI::Macro::Splat_random;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Macro::Splat_random

=head1 DESCRIPTION

Macro for returning a bounded, integer random number.

=head2 process ( max )

Random numbers are rounded, not truncated.

=head3 max

The maximum random number.  If omitted, 1_000_000_000 is
used as a default.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my ($temp, @param);
        @param = @_;
        if ($param[0] ne "") {
        	$temp = round(rand()*$param[0]);
        } else {
        	$temp = round(rand()*1000000000);
        }
	return $temp;
}




1;
