package WebGUI::Macro::RootTitle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;

=head1 NAME

Package WebGUI::Macro::RootTitle

=head1 DESCRIPTION

Macro for returning the title of the root for this page.

=head2 process ( )

If an asset exists in the session variable cache and and it's
topmost parent (root) can be found the title for that asset
is returned.  Otherwise a space is returned.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	if ($session->asset) {
		my $lineage = $session->asset->get("lineage");
		$lineage = substr($lineage,0,6);
		my $root = WebGUI::Asset->newByLineage($session,$lineage);
		if (defined $root) {
			return $root->get("title");	
		}
	}
	return "";
}


1;

