package WebGUI::Asset::Sku::FlatDiscount;

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
use Tie::IxHash;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Sku';
aspect assetName           => ['assetName', 'Asset_FlatDiscount'];
aspect icon                => 'FlatDiscount.gif';
aspect tableName           => 'FlatDiscount';
property templateId => (
            tab             => "display",
            fieldType       => "template",
            namespace       => "FlatDiscount",
            default         => "63ix2-hU0FchXGIWkG3tow",
            label           => ["template", 'Asset_FlatDiscount'],
            hoverHelp       => ["template help", 'Asset_FlatDiscount'],
         );
property mustSpend => (
            tab             => "shop",
            fieldType       => "float",
            default         => 0.00,
            label           => ["must spend", 'Asset_FlatDiscount'],
            hoverHelp       => ["must spend help", 'Asset_FlatDiscount'],
         );
property percentageDiscount => (
            tab             => "shop",
            fieldType       => "integer",
            default         => 0,
            label           => ["percentage discount", 'Asset_FlatDiscount'],
            hoverHelp       => ["percentage discount help", 'Asset_FlatDiscount'],
         );
property priceDiscount => (
            tab             => "shop",
            fieldType       => "float",
            default         => 0.00,
            label           => ["price discount", 'Asset_FlatDiscount'],
            hoverHelp       => ["price discount help", 'Asset_FlatDiscount'],
         );
property thankYouMessage => (
            tab             => "properties",
            builder         => '_thankYouMessage_default',
            lazy            => 1,
            fieldType       => "HTMLArea",
            label           => ["thank you message", 'Asset_FlatDiscount'],
            hoverHelp       => ["thank you message help", 'Asset_FlatDiscount'],
         );
sub _thankYouMessage_default {
    my $session = shift->session;
	my $i18n = WebGUI::International->new($session, "Asset_FlatDiscount");
    return $i18n->get("default thank you message");
}


use WebGUI::Asset::Template;
use WebGUI::Form;


=head1 NAME

Package WebGUI::Asset::Sku::FlatDiscount

=head1 DESCRIPTION

This asset is a basic coupon.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::FlatDiscount;

=head1 METHODS

These methods are available from this class:

=cut




#-------------------------------------------------------------------

=head2 addToCart ( ) 

Checks to make sure there isn't already a coupon of this type in the cart.

=cut

sub addToCart {
    my ($self, $options) = @_;
	my $found = $self->hasCoupon();
	unless ($found) {
        $self->{_hasAddedToCart} = 1;
		$self->SUPER::addToCart($options);
	}
}

#-------------------------------------------------------------------

=head2 getMaxAllowedInCart ( )

Returns 1.

=cut

sub getMaxAllowedInCart {
	return 1;
}


#-------------------------------------------------------------------

=head2 getPrice

Returns either 0 or a percentage off the price or a flat amount off the price depending upon what's in the cart.

=cut

sub getPrice {
    my $self = shift;
	my $subtotal = 0;
	foreach my $item (@{$self->getCart->getItems()}) {
		next if ($item->assetId eq $self->getId); # avoid an infinite loop
		$subtotal += $item->getSku->getPrice * $item->quantity;
	}
	if ($subtotal >= $self->mustSpend) {
		if ($self->percentageDiscount > 0) {
			return $subtotal * $self->percentageDiscount / -100;
		}
		else {
			return $self->priceDiscount;
		}
	}
	return 0;
}

#-------------------------------------------------------------------

=head2 hasCoupon

Returns 1 if this coupon is already in the user's cart.  It does a short-circuiting
search for speed.

=cut

sub hasCoupon {
    my $self = shift;
    my $hasCoupon = 0;
	ITEM: foreach my $item (@{$self->getCart->getItems()}) {
		if (ref($item->getSku) eq ref($self)) {
            $hasCoupon=1;
            last ITEM;
        }
	}
    return $hasCoupon;
}


#-------------------------------------------------------------------

=head2 isCoupon

Returns 1.

=cut

sub isCoupon {
    return 1;
}


#-------------------------------------------------------------------

=head2 prepareView

Prepares the template.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $templateId = $self->templateId;
	my $template = WebGUI::Asset::Template->new($self->session, $templateId);
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 view

Displays the FlatDiscount form.

=cut

sub view {
    my ($self) = @_;
    my $session = $self->session;
	my $i18n = WebGUI::International->new($session, "Asset_FlatDiscount");
    my %var = (
        formHeader      => WebGUI::Form::formHeader($session, { action=>$self->getUrl })
            . WebGUI::Form::hidden( $session, { name=>"func", value=>"addToCart" }),
        formFooter      => WebGUI::Form::formFooter($session),
        addToCartButton => WebGUI::Form::submit( $session, { value => $i18n->get("add to cart") }),
        hasAddedToCart  => $self->{_hasAddedToCart},
        continueShoppingUrl => $self->getUrl,
        );
    $var{alreadyHasCoupon} = $self->hasCoupon();

    return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_addToCart

Accepts the information from the form and adds it to the cart.

=cut

sub www_addToCart {
    my $self = shift;
    if ($self->canView) {
        $self->addToCart();
    }
    return $self->www_view;
}

1;
