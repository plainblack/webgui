package WebGUI::Exception::Shop;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Exception;
use Exception::Class (

    'WebGUI::Error::Shop::MaxOfItemInCartReached' => {
        description  => "Some items restrict how many you can put into your cart.",
        isa          => 'WebGUI::Error',
    },

    'WebGUI::Error::Shop::RemoteShippingRate' => {
        description  => "Errors during the remote rate lookups.",
        isa          => 'WebGUI::Error',
    },

);


=head1 NAME

Package WebGUI::Exception::Shop

=head1 DESCRIPTION

Exceptions which apply only to the WebGUI commerce system.

=head1 SYNOPSIS

 use WebGUI::Exception::Shop;

 # throw
 WebGUI::Error::Shop::MaxOfItemInCartReached->throw(error=>"Too many in cart.");

 # try
 eval { $cart->addItem($ku) };

 # catch
 if (my $e = WebGUI::Error->caught("WebGUI::Error::Shop::MaxOfItemInCartReached")) {
    # do something
 }

=head1 EXCEPTION TYPES

These following exception classes are defined in this class.  Each is a subclass of
WebGUI::Error.

=head2 WebGUI::Error::Shop::MaxOfItemInCartReached

Throw this when there are too many items of a given type added to the cart so that the user can be notified. ISA WebGUI::Error.

=head2 WebGUI::Error::Shop::RemoteShippingRate

Shipping drivers should throw this when there is a problem with a remote rate lookup.

=cut


1;

