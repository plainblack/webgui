package WebGUI::Commerce::Item::Product;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::Commerce::Item::Product

=head1 DESCRIPTION

Item plugin for products in the Commerce system.

=cut

use strict;
#use WebGUI::SQL;
use WebGUI::Product;

our @ISA = qw(WebGUI::Commerce::Item);

#-------------------------------------------------------------------
sub available {
	return $_[0]->{_variant}->{available};
}

#-------------------------------------------------------------------
sub description {
	return $_[0]->{_product}->get('description');
}

#-------------------------------------------------------------------
#sub duration {
#

#-------------------------------------------------------------------
sub handler {
       my $self        = shift;

       ### Add to group action
       # If group is 'everyone', skip
       if ($self->{_product}->get('groupId') && $self->{_product}->get('groupId') ne '7') {
               my $g = WebGUI::Group->new($self->session,$self->{_product}->get('groupId'));
               my $expiresOffset;

               # Parse the value
               if ($self->{_product}->get('groupExpiresOffset') =~ /^(\d+)month/i) {
                       $expiresOffset = $1 * 3600*24*30;       # One month
               } elsif ($self->{_product}->get('groupExpiresOffset') =~ /^(\d+)year/i) {
                       $expiresOffset = $1 * 3600*24*365;      # One year
               }

               # Multiply by how many quantity we're purchasing
               #!!! TODO !!! - handlers don't know how many we're purchasing

               # If user has time left
               my $remains     = $g->userGroupExpireDate($self->session->user->userId);
               if ($remains) {
                       # Add any remaining time to the offset
                       $expiresOffset += $remains - time();
               }

               # Add user to group
               $g->addUsers([$self->session->user->userId],$expiresOffset);
       }
}


#-------------------------------------------------------------------
sub id {
	return $_[0]->{_variant}->{variantId};
}

#-------------------------------------------------------------------
sub isRecurring {
	return 0;
}

#-------------------------------------------------------------------
sub name {
	return $_[0]->{_product}->get('title').' ('.$_[0]->{_composition}.')';
}

#-------------------------------------------------------------------

=head2 new ( $session )

Overload default constructor to glue in a WebGUI::Product object.

=cut

sub new {
	my ($class, $session, $sku, $product, $variantId);
	$class = shift;
	$session = shift;
	$variantId = shift;
	
	$product = WebGUI::Product->getByVariantId($session,$variantId);
	my $variant = $product->getVariant($variantId);
	my %parameters = map {split(/\./, $_)} split(/,/, $variant->{composition});
	my $composition = join(', ',map {$product->getParameter($_)->{name} .': '. $product->getOption($parameters{$_})->{value}} keys (%parameters));
	
	bless {_product => $product, _composition => $composition, _variant => $variant, _session => $session }, $class;
}

#-------------------------------------------------------------------
sub needsShipping {
	return 1;
}

#-------------------------------------------------------------------
sub price {
	return $_[0]->{_variant}->{price};
}

#-------------------------------------------------------------------
sub useSalesTax {
	my $self = shift;
	return $self->{_product}->get('useSalesTax') ? 1 : 0;
}

#-------------------------------------------------------------------
sub type {
	return 'Product';
}

#-------------------------------------------------------------------
sub weight {
	return $_[0]->{_variant}->{weight};
}

1;

