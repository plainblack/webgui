package WebGUI::Macro::BackToSite;

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

Package WebGUI::Macro::BackToSite

=head1 DESCRIPTION

Tries to return a URL to take the user back to the last page they were at before
using an operation or other function.  This will always include the gateway
url from the config file.

=head2 process

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return $session->url->getBackToSiteURL;
}



1;
