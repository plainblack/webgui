package WebGUI::Exception::Account;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

    'WebGUI::Error::Account::NoAccountInfo' => {
        description     => "Some items restrict how many you can put into your cart.",
        },
);


=head1 NAME

Package WebGUI::Exception::Account

=head1 DESCRIPTION

Exceptions which apply only to the WebGUI account system.

=head1 SYNOPSIS

 use WebGUI::Exception::Account;

 # throw
 WebGUI::Error::Account::MaxOfItemInCartReached->throw(error=>"Too many in cart.");

 # try
 eval { $cart->addItem($ku) };

 # catch
 if (my $e = WebGUI::Error->caught("WebGUI::Error::Shop::MaxOfItemInCartReached")) {
    # do something
 }

=head1 EXCEPTION TYPES

These exception classes are defined in this class:


=head2 WebGUI::Error::Shop::MaxOfItemInCartReached

Throw this when there are too many items of a given type added to the cart so that the user can be notified. ISA WebGUI::Error.

=cut


1;

