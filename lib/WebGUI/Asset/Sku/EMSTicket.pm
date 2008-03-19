package WebGUI::Asset::Sku::EMSTicket;

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

Package WebGUI::Asset::Sku::EMSBadge

=head1 DESCRIPTION

A badge for the Event Manager.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::EMSBadge;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub addToCart {
	my ($self, $badgeInfo) = @_;
	$self->session->db->write("insert into EMSRegistrantTicket (badgeId, ticketAssetId) values (?,?)",
		[$badgeInfo->{badgeId},$self->getId]);
	$self->addToCart($badgeInfo);
}

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
		seatsAvailable => {
			tab             => "properties",
			fieldType       => "integer",
			defaultValue    => 25,
			label           => $i18n->get("seats available"),
			hoverHelp       => $i18n->get("seats available help"),
			},
		eventNumber => {
			tab             => "properties",
			fieldType       => "integer",
			defaultValue    => $session->db->quickScalar("select max(eventNumber)+1 from EMSTicket"),
			label           => $i18n->get("seats available"),
			hoverHelp       => $i18n->get("seats available help"),
			},
		startDate => {
			tab             => "properties",
			fieldType       => "dateTime",
			defaultValue    => $date->toDatabase,
			label           => $i18n->get("add/edit event start date"),
			hoverHelp       => $i18n->get("add/edit event start date description"),
			},
		endDate => {
			tab             => "properties",
			fieldType       => "dateTime",
			defaultValue    => $date->toDatabase,
			label           => $i18n->get("add/edit event end date"),
			hoverHelp       => $i18n->get("add/edit event end date description"),
			},
		relatedBadges => {
			tab             => "properties",
			fieldType       => "checkList",
			options			=> {},
			defaultValue    => undef,
			label           => $i18n->get("related badges"),
			hoverHelp       => $i18n->get("related badges help"),
			},
	    );
	push(@{$definition}, {
		assetName           => $i18n->get('ems ticket'),
		icon                => 'EMSTicket.gif',
		autoGenerateForms   => 1,
		tableName           => 'EMSTicket',
		className           => 'WebGUI::Asset::Sku::EMSTicket',
		properties          => \%properties
	    });
	return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------
sub getConfiguredTitle {
    my $self = shift;
    return $self->getTitle." (".$self->getOptions->{name}.")";
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
sub getQuantityAvailable {
	my $self = shift;
	my $seatsTaken = $self->session->db->quickScalar("select count(*) from EMSRegistrantTicket where ticketAssetId=? and purchaseComplete=1",[$self->getId]);
    return $self->get("seatsAvailable") - $seatsTaken;
}

#-------------------------------------------------------------------
sub onCompletePurchase {
	my ($self, $item) = @_;
	$self->session->db->write("update EMSRegistrantTicket set purchaseComplete=1 where ticketAssetId=? and badgeId=?",
		[$self->getId, $self->getOptions->{badgeId}]);
	return undef;
}

#-------------------------------------------------------------------
sub onRemoveFromCart {
	my ($self, $item) = @_;
	$self->session->db->write("delete from EMSRegistrantTicket where ticketAssetId=? and badgeId=?",
		[$self->getId, $self->getOptions->{badgeId}]);
}

#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantTicket where ticketAssetId=?",[$self->getId]);
	$self->SUPER::purge;
}

#-------------------------------------------------------------------
sub view {
    my ($self) = @_;
    my $session = $self->session;
    return "Don't know what it is to view this thing.";
}


1;
