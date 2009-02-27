package WebGUI::Asset::Sku::Ad;

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
use WebGUI::Shop::Pay;

=head1 NAME

Package WebGUI::Asset::Sku::Ad	

=head1 DESCRIPTION

This Asset allows ads to be purchased via WebGUI shopping

=head1 SYNOPSIS

use WebGUI::Asset::Sku::Ad;

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
	my $i18n = WebGUI::International->new($session, "Asset_AdSku");
	%properties = (
		purchaseTemplate      => {
			tab             => "display",
			fieldType       => "template",
                        namespace       => "AdSku",
			defaultValue    => 'eqb9sWjFEVq0yHunGV8IGw',   #  TODO
			label           => $i18n->get("purchase template"),
			hoverHelp       => $i18n->get("purchase template help"),
		},
		manageTemplate      => {
			tab             => "display",
			fieldType       => "template",
                        namespace       => "AdSku",
			defaultValue    => 'eqb9sWjFEVq0yHunGV8IGw',   #  TODO
			label           => $i18n->get("manage template"),
			hoverHelp       => $i18n->get("manage template help"),
		},
        adSpace => {
            tab             => "properties",
            fieldType       => "AdSpace",
            namespace       => "AdSku",
            label           => $i18n->get("ad space"),
            hoverHelp       => $i18n->get("ad Space help"),
        },
        pricePerClick => {
            tab             => "properties",
            defaultValue    => '0.00',
		fieldType       => "float",
		label           => $i18n->get("price per click"),
		hoverHelp       => $i18n->get("price per click help"),
            },
        pricePerImpression => {
            tab             => "properties",
            defaultValue    => '0.00',
		fieldType       => "float",
		label           => $i18n->get("price per impression"),
		hoverHelp       => $i18n->get("price per impression help"),
            },
        clickDiscounts   => {
            fieldType       => 'textarea',
            label	    => $i18n->get('click discounts'),
            hoverHelp	    => $i18n->get('click discounts help'),
            defaultValue    => '',
        },
        impressionDiscounts => {
            fieldType       => 'textarea',
            label	    => $i18n->get('impression discounts'),
            hoverHelp	    => $i18n->get('impression discounts help'),
            defaultValue    => '',
        },
    );

    # Show the karma field only if karma is enabled
    if ($session->setting->get("useKarma")) {
        $properties{ karma    } = {
            type            => 'integer',
            label           => $i18n->get('adsku karma'),
            hoverHelp       => $i18n->get('adsku karma description'),
            defaultvalue	=> 0,
        };
    }

	push(@{$definition}, {
		assetName           => $i18n->get('assetName'),
		icon                => 'adsku.gif',
		autoGenerateForms   => 1,
		tableName           => 'AdSku',
		className           => 'WebGUI::Asset::Sku::AdSku',
		properties          => \%properties,
	    });
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 onCompletePurchase

Applies the first term of the subscription. This method is called when the payment is successful.

=cut

sub onCompletePurchase {
    my $self = shift;

    # $self->apply;
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

	my $i18n = WebGUI::International->new($session, "Asset_AdSku");
    my %var = (
        formHeader          => WebGUI::Form::formHeader($session, { action=>$self->getUrl })
            . WebGUI::Form::hidden( $session, { name=>"func", value=>"purchaseAdSku" }),
        formFooter          => WebGUI::Form::formFooter($session),
        purchaseButton      => WebGUI::Form::submit( $session,  { value => $i18n->get("purchase button") }),
        hasAddedToCart      => $self->{_hasAddedToCart},
        continueShoppingUrl => $self->getUrl,
        price               => sprintf("%.2f", $self->getPrice),
    );
    return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_purchaseAdSKu

Add this subscription to the cart.

=cut

sub www_purchaseAdSku {
    my $self = shift;
    if ($self->canView) {
        $self->{_hasAddedToCart} = 1;
        $self->addToCart({price => $self->getPrice});
    }
    return $self->www_view;
}

1;

