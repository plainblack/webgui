package WebGUI::Commerce::Shipping::ByWeight;

our @ISA = qw(WebGUI::Commerce::Shipping);

use strict;

#-------------------------------------------------------------------
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
sub init {
	my ($class, $self);
	$class = shift;
		
	$self = $class->SUPER::init('ByWeight');

	return $self;
}

#-------------------------------------------------------------------
sub name {
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingByWeight');
	return $i18n->get('title');
}

1;

