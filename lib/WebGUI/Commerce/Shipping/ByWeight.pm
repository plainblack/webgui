package WebGUI::Commerce::Shipping::ByWeight;

=head1 NAME

Package WebGUI::Commerce::Item::ByWeight

=head1 DESCRIPTION

Shipping plugin for determining shipping cost as a function of the total weight
or products being purchased.

=cut

our @ISA = qw(WebGUI::Commerce::Shipping);

use strict;

#-------------------------------------------------------------------

=head2 calc ( $session )

Calculate the shipping price for this plugin.

=cut

sub calc {
	my ($self, $items, $weight);
	$self = shift;
	
	$items = $self->getShippingItems;

	foreach (@$items) {
		$weight += $_->{item}->weight * $_->{quantity};
	}

	return $weight * $self->get('pricePerUnitWeight');
};

#-------------------------------------------------------------------

=head2 configurationForm ( $session )

Configuration form for this shipping method.

=cut

sub configurationForm {
	my ($self, $f);
	$self = shift;
	
	$f = WebGUI::HTMLForm->new($self->session);
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingByWeight');
	$f->float(
		-name	=> $self->prepend('pricePerUnitWeight'),
		-label	=> $i18n->get('price per weight'),
		-value	=> $self->get('pricePerUnitWeight')
		);

	return $self->SUPER::configurationForm($f->printRowsOnly);
}

#-------------------------------------------------------------------

=head2 init ( $session )

Constructor

=cut

sub init {
	my ($class, $self);
	$class = shift;
	my $session = shift;
	$self = $class->SUPER::init($session,'ByWeight');

	return $self;
}

#-------------------------------------------------------------------

=head2 name ( $session )

Returns the internationalized name for this shipping plugin.

=cut

sub name {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingByWeight');
	return $i18n->get('title');
}

1;

