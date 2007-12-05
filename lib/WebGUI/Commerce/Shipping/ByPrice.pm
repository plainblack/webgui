package WebGUI::Commerce::Shipping::ByPrice;

use strict;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::Commerce::Shipping::ByPrice

=head1 DESCRIPTION

Shipping plugin for determining shipping cost by a percentage of total price.

=cut

our @ISA = qw(WebGUI::Commerce::Shipping);

#-------------------------------------------------------------------

=head2 calc ( $session )

Calculate the shipping price for this plugin.

=cut

sub calc {
	my ($self, $items, $price);
	$self = shift;
	
	$items = $self->getShippingItems;

	foreach (@$items) {
		$price += $_->{totalPrice};
	}

	return $price * $self->get('percentageOfPrice') / 100;
};

#-------------------------------------------------------------------

=head2 configurationForm ( $session )

Configuration form for this shipping method.

=cut

sub configurationForm {
	my ($self, $f);
	$self = shift;
	
	$f = WebGUI::HTMLForm->new($self->session);
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingByPrice');
	$f->float(
		-name	=> $self->prepend('percentageOfPrice'),
		-label	=> $i18n->get('percentage of price'),
		-value	=> $self->get('percentageOfPrice')
		);

	return $self->SUPER::configurationForm($f->printRowsOnly);
}

#-------------------------------------------------------------------
sub init {
	my ($class, $self);
	$class = shift;
	my $session = shift;
	$self = $class->SUPER::init($session,'ByPrice');

	return $self;
}

#-------------------------------------------------------------------

=head2 name ( $session )

Returns the internationalized name for this shipping plugin.

=cut

sub name {
	my ($self) = @_;
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingByPrice');
	return $i18n->get('title');
}

1;

