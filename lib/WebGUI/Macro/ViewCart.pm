package WebGUI::Macro::ViewCart;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

Defaults to "View Cart". 

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $text) = @_;
    unless ($text) {
        $text = WebGUI::International->new($session,"Shop")->get("view cart");
    }
    my $url = $session->url->page("shop=cart");
    return '<a href="'.$url.'"><img src="'.$session->url->extras('/macro/ViewCart/cart.gif').'" alt="'.$text.'" style="border: 0px;vertical-align: middle;" /></a> <a href="'.$url.'">'.$text.'</a>';
}

1;


