package WebGUI::Commerce::Shipping::PerTransaction;

=head1 NAME

Package WebGUI::Commerce::Item::PerTransaction

=head1 DESCRIPTION

Shipping plugin for a fixed shipping costs per transaction.

=cut

our @ISA = qw(WebGUI::Commerce::Shipping);

use strict;

#-------------------------------------------------------------------

=head2 calc ( $session )

Calculate the shipping price for this plugin.

=cut

sub calc {
	my ($self);
	$self = shift;

	return 0 unless (scalar(@{$self->getShippingItems}));

	return $self->get('pricePerTransaction');
};

#-------------------------------------------------------------------

=head2 configurationForm ( $session )

Configuration form for this shipping method.

=cut

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

=head2 init ( $session )

Constructor

=cut

sub init {
	my ($class, $self);
	$class = shift;
		
	$self = $class->SUPER::init('PerTransaction');

	return $self;
}

#-------------------------------------------------------------------

=head2 name ( $session )

Returns the internationalized name for this shipping plugin.

=cut

sub name {
	my ($session) = @_;
	my $i18n = WebGUI::International->new($session, 'CommerceShippingPerTransaction');
	return $i18n->get('title');
}

1;

