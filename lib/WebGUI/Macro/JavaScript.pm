package WebGUI::Macro::JavaScript;

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

Package WebGUI::Macro::JavaScript

=head1 DESCRIPTION

This Macro is a wrapper for $session->style->setScript, which puts a script
tag into the head of the current page with the contents of the javascript
found at the url that is passed in.

=head2 process ( url )

=head3 url

URL to the javascript to include in the page's header tags.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
	$session->style->setScript(shift,{type=>'text/javascript'});
	return undef;
}

1;


