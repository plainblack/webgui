package WebGUI::Commerce::Shipping::ByPrice;

our @ISA = qw(WebGUI::Commerce::Shipping);

use strict;

#-------------------------------------------------------------------
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
sub configurationForm {
	my ($self, $f);
	$self = shift;
	
	$f = WebGUI::HTMLForm->new($self->session);
	$f->float(
		-name	=> $self->prepend('percentageOfPrice'),
		-label	=> WebGUI::International::get('percentage of price', 'CommerceShippingByPrice'),
		-value	=> $self->get('percentageOfPrice')
		);

	return $self->SUPER::configurationForm($f->printRowsOnly);
}

#-------------------------------------------------------------------
sub init {
	my ($class, $self);
	$class = shift;
		
	$self = $class->SUPER::init('ByPrice');

	return $self;
}

#-------------------------------------------------------------------
sub name {
	return WebGUI::International::get('title', 'CommerceShippingByPrice');
}

1;

