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
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingPerTransaction');
	$f->float(
		-name	=> $self->prepend('pricePerTransaction'),
		-label	=> $i18n->get('price'),
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
	my $i18n = WebGUI::International->new($self->session, 'CommerceShippingPerTransaction');
	return $i18n->get('title');
}

1;

