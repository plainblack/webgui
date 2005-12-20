package WebGUI::Macro::StyleSheet;

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

Package WebGUI::Macro::StyleSheet

=head1 DESCRIPTION

Macro for dynamically adding references to CSS documents to use in this page.

=head2 process ( url )

process is a wrapper around WebGUI::Style::setLink().

=head3 url

The URL to the CSS document.

=cut

#-------------------------------------------------------------------
sub process {
	WebGUI::Style::setLink(shift,{
		type=>'text/css',
		rel=>'stylesheet'
		});
	return "";
}

1;


