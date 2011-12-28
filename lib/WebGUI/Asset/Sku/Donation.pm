package WebGUI::Asset::Sku::Donation;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Sku';
define assetName           => ['assetName', 'Asset_Donation'];
define icon                => 'Donation.gif';
define tableName           => 'donation';
property templateId => (
            tab             => "display",
            fieldType       => "template",
            namespace       => "Donation",
            default         => "vrKXEtluIhbmAS9xmPukDA",
            label           => ["donate template", 'Asset_Donation'],
            hoverHelp       => ["donate template help", 'Asset_Donation'],
         );
property thankYouMessage => (
            tab             => "properties",
            builder         => '_thankYouMessage_default',
            lazy            => 1,
            fieldType       => "HTMLArea",
            label           => ["thank you message", 'Asset_Donation'],
            hoverHelp       => ["thank you message help", 'Asset_Donation'],
         );
sub _thankYouMessage_default {
    my $session = shift->session;
	my $i18n = WebGUI::International->new($session, "Asset_Donation");
    return $i18n->get("default thank you message");
}
property defaultPrice => (
            tab             => "shop",
            fieldType       => "float",
            default         => 100.00,
            label           => ["default price", 'Asset_Donation'],
            hoverHelp       => ["default price help", 'Asset_Donation'],
         );



use WebGUI::Asset::Template;
use WebGUI::Form;


=head1 NAME

Package WebGUI::Asset::Sku::Donation

=head1 DESCRIPTION

This asset makes donations possible.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::Donation;

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 getAddToCartForm ( )

Returns a form to add this Sku to the cart.  Used when this Sku is part of
a shelf.  Overrode master class to add price form.

=cut

sub getAddToCartForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'Asset_Donation');
    return
        WebGUI::Form::formHeader($session, {action => $self->getUrl})
      . WebGUI::Form::hidden(    $session, {name => 'func',  value => 'donate'})
      . WebGUI::Form::float(     $session, {name => 'price', defaultValue => $self->getPrice })
      . WebGUI::Form::submit(    $session, {value => $i18n->get('donate button')})
      . WebGUI::Form::formFooter($session)
      ;
}

#-------------------------------------------------------------------

=head2 getConfiguredTitle

Returns title + price

=cut

sub getConfiguredTitle {
    my $self = shift;
    return $self->getTitle." (".$self->getOptions->{price}.")";
}


#-------------------------------------------------------------------

=head2 getPrice

Returns configured price, or default price, or 100 if neither of those are available.

=cut

sub getPrice {
    my $self = shift;
    return $self->getOptions->{price} || $self->defaultPrice || 100.00;
}

#-------------------------------------------------------------------

=head2 prepareView

Prepares the template.

=cut

override prepareView => sub {
	my $self = shift;
	super();
	my $templateId = $self->templateId;
	my $template = WebGUI::Asset::Template->newById($self->session, $templateId);
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
};

#-------------------------------------------------------------------

=head2 view

Displays the donation form.

=cut

sub view {
    my ($self) = @_;
    my $session = $self->session;
	my $i18n = WebGUI::International->new($session, "Asset_Donation");
    my %var = (
        formHeader      => WebGUI::Form::formHeader($session, { action=>$self->getUrl })
            . WebGUI::Form::hidden( $session, { name=>"func", value=>"donate" }),
        formFooter      => WebGUI::Form::formFooter($session),
        donateButton    => WebGUI::Form::submit( $session, { value => $i18n->get("donate button") }),
        priceField      => WebGUI::Form::float($session, { name => "price", defaultValue => $self->getPrice }),
        hasAddedToCart  => $self->{_hasAddedToCart},
        continueShoppingUrl => $self->getUrl,
        );
    return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_donate

Accepts the information from the donation form and adds it to the cart.

=cut

sub www_donate {
    my $self    = shift;
    my $price   = $self->session->form->get("price") || $self->getPrice;

    if ($self->canView && $price > 0) {
        $self->{_hasAddedToCart} = 1;
        $self->addToCart( { price => $price } );
    }

    return $self->www_view;
}

__PACKAGE__->meta->make_immutable;
1;
