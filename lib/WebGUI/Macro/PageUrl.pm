package WebGUI::Macro::PageUrl;

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

=head1 NAME

Package WebGUI::Macro::Page

=head1 DESCRIPTION

Macro for displaying the url for the current asset.

=head2 process ( )

process is really a wrapper around WebGUI::URL::page();

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return WebGUI::URL::page();
}


1;

