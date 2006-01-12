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
		
	$self = $class->SUPER::init('ByPrice');

	return $self;
}

#-------------------------------------------------------------------
sub name {
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingByPrice');
	return $i18n->get('title');
}

1;

