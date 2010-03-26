package WebGUI::Asset::Sku::Donation;

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
use base 'WebGUI::Asset::Sku';
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

=head2 definition

Adds templateId, thankYouMessage, and defaultPrice fields.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, "Asset_Donation");
	%properties = (
		templateId => {
			tab             => "display",
			fieldType       => "template",
            namespace       => "Donation",
			defaultValue    => "vrKXEtluIhbmAS9xmPukDA",
			label           => $i18n->get("donate template"),
			hoverHelp       => $i18n->get("donate template help"),
			},
        thankYouMessage => {
            tab             => "properties",
			defaultValue    => $i18n->get("default thank you message"),
			fieldType       => "HTMLArea",
			label           => $i18n->get("thank you message"),
			hoverHelp       => $i18n->get("thank you message help"),
            },
		defaultPrice => {
			tab             => "shop",
			fieldType       => "float",
			defaultValue    => 100.00,
			label           => $i18n->get("default price"),
			hoverHelp       => $i18n->get("default price help"),
			},
	    );
	push(@{$definition}, {
		assetName           => $i18n->get('assetName'),
		icon                => 'Donation.gif',
		autoGenerateForms   => 1,
		tableName           => 'donation',
		className           => 'WebGUI::Asset::Sku::Donation',
		properties          => \%properties
	    });
	return $class->SUPER::definition($session, $definition);
}


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
    return $self->getOptions->{price} || $self->get("defaultPrice") || 100.00;
}

#-------------------------------------------------------------------

=head2 prepareView

Prepares the template.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $templateId = $self->get("templateId");
	my $template = WebGUI::Asset::Template->new($self->session, $templateId);
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
}

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

1;
