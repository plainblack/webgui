package WebGUI::Asset::Sku::EMSRibbon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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



=head1 NAME

Package WebGUI::Asset::Sku::EMSRibbon

=head1 DESCRIPTION

A ribbon for the Event Manager. Ribbons are like coupons that give you discounts on events.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::EMSRibbon;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, "Asset_EventManagementSystem");
	my $date = WebGUI::DateTime->new($session, time());
	%properties = (
		price => {
			tab             => "commerce",
			fieldType       => "float",
			defaultValue    => 0.00,
			label           => $i18n->get("price"),
			hoverHelp       => $i18n->get("price help"),
			},
	    );
	push(@{$definition}, {
		assetName           => $i18n->get('ems ribbon'),
		icon                => 'EMSRibbon.gif',
		autoGenerateForms   => 1,
		tableName           => 'EMSRibbon',
		className           => 'WebGUI::Asset::Sku::EMSRibbon',
		properties          => \%properties
	    });
	return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------
sub getConfiguredTitle {
    my $self = shift;
	my $name = $self->session->db->getScalar("select name from EMSRegistrant where badgeId=?",[$self->getOptions->{badgeId}]);
    return $self->getTitle." (".$name.")";
}

#-------------------------------------------------------------------
sub getMaxAllowedInCart {
	return 1;
}

#-------------------------------------------------------------------
sub getPrice {
    my $self = shift;
    return $self->get("price");
}

#-------------------------------------------------------------------
sub onCompletePurchase {
	my ($self, $item) = @_;
	$self->session->db->write("insert into EMSRegistrationRibbon (ribbonAssetId, badgeId) values (?,?)",
		[$self->getId, $self->getOptions->{badgeId}]);
	return undef;
}

#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantRibbon where tokenAssetId=?",[$self->getId]);
	$self->SUPER::purge;
}

#-------------------------------------------------------------------
sub view {
    my ($self) = @_;
    return $self->getParent->view;
}

#-------------------------------------------------------------------
sub www_addToCart {
	my ($self) = @_;
	return $self->session->privilege->noAccess() unless $self->getParent->canView;
	$self->addToCart({badgeId=>$self->session->form->get('badgeId')});
	return $self->getParent->www_view;
}


1;
