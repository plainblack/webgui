package WebGUI::Macro::RawHeadTags;

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
use WebGUI::Style;

=head1 NAME

Package WebGUI::Macro::RawHeadTags

=head1 DESCRIPTION

Macro for adding

=head2 process ( tags )

process is a wrapper for WebGUI::Style::setRawHeadTags();

=head3 text

Text that will be added to the HEAD tags for this page.

=cut

#-------------------------------------------------------------------
sub process {
	WebGUI::Style::setRawHeadTags(shift);
	return "";
}

1;


