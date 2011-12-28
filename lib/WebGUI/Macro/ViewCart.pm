package WebGUI::Macro::ViewCart;

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
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::ViewCart

=head1 DESCRIPTION

Displays a view cart link and image.

=head2 process( $session, [ linktext ] )

Renders the macro.

=head3 linktext

Defaults to "View Cart". "linkonly" will return only the URL to the cart.

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $text) = @_;
    my $url = $session->url->page("shop=cart");
    if ($text eq "linkonly") {
		return $url;
	}
	elsif ($text) {
		# use text specified
	}
	else {
        $text = WebGUI::International->new($session,"Shop")->get("view cart");
    }
    return '<a href="'.$url.'">'.$text.'</a>';
}

1;


