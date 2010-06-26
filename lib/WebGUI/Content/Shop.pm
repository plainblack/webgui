package WebGUI::Content::Shop;

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
use WebGUI::AdminConsole;
use WebGUI::Exception::Shop;
use WebGUI::Shop::AddressBook;
use WebGUI::Shop::Cart;
use WebGUI::Shop::Credit;
use WebGUI::Shop::Pay;
use WebGUI::Shop::Ship;
use WebGUI::Shop::Tax;
use WebGUI::Shop::Transaction;
use WebGUI::Shop::Vendor;

=head1 NAME

Package WebGUI::Content::Shop

=head1 DESCRIPTION

A content handler that opens up all the commerce functionality. The shop modules are accessed via the url like this:

 /pagename?shop=modulehandler;method=www_method
 
For example:

 /home?shop=transaction;method=manage

In the above we're accessing the WebGUI::Shop::Transaction module, which is configured with the www_transaction() sub in this package. And we're calling www_manage() on that object.

=head1 SYNOPSIS

 use WebGUI::Content::Shop;
 my $output = WebGUI::Content::Shop::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    my $output = undef;
    my $shop = $session->form->get("shop");
    return $output unless ($shop);
    my $function = "www_".$shop;
    if ($function ne "www_" && (my $sub = __PACKAGE__->can($function))) {
        $output = $sub->($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $function", method=>$function);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_address ()

Hand off to the address book.

=cut

sub www_address {
    my $session = shift;
    my $output = undef;
    my $method = "www_". ( $session->form->get("method") || "view");
    my $cart = WebGUI::Shop::AddressBook->newByUserId($session);

    if ($cart->can($method)) {
        $output = $cart->$method();
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_admin ()

Hand off to admin processor.

=cut

sub www_admin {
    my $session = shift;
    my $output = undef;
    my $method = "www_". ( $session->form->get("method") || "editSettings");
    my $admin = WebGUI::Shop::Admin->new($session);
    if ($admin->can($method)) {
        $output = $admin->$method();
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_cart ()

Hand off to the cart.

=cut

sub www_cart {
    my $session = shift;
    my $output = undef;
    my $method = "www_". ( $session->form->get("method") || "view");
    my $cart = WebGUI::Shop::Cart->newBySession($session);
    if ($cart->can($method)) {
        $output = $cart->$method();
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}


#-------------------------------------------------------------------

=head2 www_credit ()

Hand off to the credit system.

=cut

sub www_credit {
    my $session = shift;
    my $output = undef;
    my $method = "www_".$session->form->get("method");
    if ($method ne "www_" && WebGUI::Shop::Credit->can($method)) {
        $output = WebGUI::Shop::Credit->$method($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_pay ()

Hand off to the payment gateway.

=cut

sub www_pay {
    my $session = shift;
    my $output = undef;
    my $method = "www_".$session->form->get("method");
    my $pay = WebGUI::Shop::Pay->new(session => $session);
    if ($method ne "www_" && $pay->can($method)) {
        $output = $pay->$method();
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_ship ()

Hand off to the shipper.

=cut

sub www_ship {
    my $session = shift;
    my $output = undef;
    my $method = "www_".$session->form->get("method");
    my $ship = WebGUI::Shop::Ship->new(session => $session);
    if ($method ne "www_" && $ship->can($method)) {
        $output = $ship->$method($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_tax ()

Hand off to the tax system.

=cut

sub www_tax {
    my $session = shift;
    my $output = undef;
    my $method = "www_".$session->form->get("method");
    my $tax = WebGUI::Shop::Tax->new($session);
    if ($method ne "www_" && $tax->can($method)) {
        $output = $tax->$method();
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_transaction ()

Hand off to the transaction system.

=cut

sub www_transaction {
    my $session = shift;
    my $output = undef;
    my $method = "www_".$session->form->get("method");
    if ($method ne "www_" && WebGUI::Shop::Transaction->can($method)) {
        $output = WebGUI::Shop::Transaction->$method($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_vendor ()

Hand off to the vendor system.

=cut

sub www_vendor {
    my $session = shift;
    my $output = undef;
    my $method = "www_".$session->form->get("method");
    if ($method ne "www_" && WebGUI::Shop::Vendor->can($method)) {
        $output = WebGUI::Shop::Vendor->$method($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}



1;

