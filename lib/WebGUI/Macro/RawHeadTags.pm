package WebGUI::Macro::RawHeadTags;

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

=head1 NAME

Package WebGUI::Macro::RawHeadTags

=head1 DESCRIPTION

Macro for adding

=head2 process ( tags )

process is a wrapper for $session->style->setRawHeadTags();

=head3 text

Text that will be added to the HEAD tags for this page.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	$session->style->setRawHeadTags(shift);
	return "";
}

1;


