package WebGUI::Commerce::Shipping::PerTransaction;

our @ISA = qw(WebGUI::Commerce::Shipping);

use strict;

#-------------------------------------------------------------------
sub calc {
	my ($self);
	$self = shift;

	return 0 unless (scalar(@{$self->getShippingItems}));

	return $self->get('pricePerTransaction');
};

#-------------------------------------------------------------------
sub configurationForm {
	my ($self, $f);
	$self = shift;
	
	$f = WebGUI::HTMLForm->new($self->session);
	$f->float(
		-name	=> $self->prepend('pricePerTransaction'),
		-label	=> WebGUI::International::get('price', 'CommerceShippingPerTransaction'),
		-value	=> $self->get('pricePerTransaction')
	);

	return $self->SUPER::configurationForm($f->printRowsOnly);
}

#-------------------------------------------------------------------
sub init {
	my ($class, $self);
	$class = shift;
		
	$self = $class->SUPER::init('PerTransaction');

	return $self;
}

#-------------------------------------------------------------------
sub name {
	return WebGUI::International::get('title', 'CommerceShippingPerTransaction');
}

1;

