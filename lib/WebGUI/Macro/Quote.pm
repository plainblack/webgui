package WebGUI::Macro::Quote;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Macro::Quote

=head1 DESCRIPTION

Macro for quoting data to make it safe for use in SQL queries.

=head2 process ( text )

process is really a wrapper around WebGUI::SQL::quote();

=head3 text

The text to quote.

=cut

#-------------------------------------------------------------------
sub process {
	return quote(shift);
	
}


1;

