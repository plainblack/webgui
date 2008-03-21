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

Package WebGUI::Asset::Sku::EMSTicket

=head1 DESCRIPTION

A ticket for the Event Manager. Tickets allow you into invidivual events at a convention.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::EMSTicket;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addToCart ( {badgeId=>$badgeId })

Does some bookkeeping to keep track of limited quantities of tickets that are available, then adds to cart.

=cut

sub addToCart {
	my ($self, $badgeInfo) = @_;
	$self->session->db->write("insert into EMSRegistrantTicket (badgeId, ticketAssetId) values (?,?)",
		[$badgeInfo->{badgeId},$self->getId]);
	$self->SUPER::addToCart($badgeInfo);
}

#-------------------------------------------------------------------

=head2 definition

Adds price, seatsAvailable, eventNumber, startDate, endDate and relatedBadges fields.

=cut

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
			tab             => "commerce",
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
			label           => $i18n->get("event start date"),
			hoverHelp       => $i18n->get("start date help"),
			},
		endDate => {
			tab             => "properties",
			fieldType       => "dateTime",
			defaultValue    => $date->toDatabase,
			label           => $i18n->get("event end date"),
			hoverHelp       => $i18n->get("event end date help"),
			},
		location => {
			tab             => "properties",
			fieldType       => "comboBox",
			options			=> $session->db->buildHashRef("select distinct(location) from EMSTicket order by location"),
			label           => $i18n->get("seats available"),
			hoverHelp       => $i18n->get("seats available help"),
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

=head2 getConfiguredTitle

Returns title + badgeholder name.

=cut

sub getConfiguredTitle {
    my $self = shift;
	my $name = $self->session->db->quickScalar("select name from EMSRegistrant where badgeId=?",[$self->getOptions->{badgeId}]);
    return $self->getTitle." (".$name.")";
}

#-------------------------------------------------------------------

=head2 getMaxAllowedInCart

Returns 1.

=cut

sub getMaxAllowedInCart {
	return 1;
}

#-------------------------------------------------------------------

=head2 getPrice

Returns the value of the price field

=cut

sub getPrice {
    my $self = shift;
    return $self->get("price");
}

#-------------------------------------------------------------------

=head2 getQuantityAvailable

Returns seatsAvailable minus the count from the EMSRegistrantTicket table.

=cut

sub getQuantityAvailable {
	my $self = shift;
	my $seatsTaken = $self->session->db->quickScalar("select count(*) from EMSRegistrantTicket where ticketAssetId=?",[$self->getId]);
    return $self->get("seatsAvailable") - $seatsTaken;
}

#-------------------------------------------------------------------

=head2 onCompletePurchase

Marks the ticket as purchased.

=cut

sub onCompletePurchase {
	my ($self, $item) = @_;
	$self->session->db->write("update EMSRegistrantTicket set purchaseComplete=1 where ticketAssetId=? and badgeId=?",
		[$self->getId, $self->getOptions->{badgeId}]);
	return undef;
}

#-------------------------------------------------------------------

=head2 onRemoveFromCart

Frees up the ticket to be purchased by someone else.

=cut

sub onRemoveFromCart {
	my ($self, $item) = @_;
	$self->session->db->write("delete from EMSRegistrantTicket where ticketAssetId=? and badgeId=?",
		[$self->getId, $self->getOptions->{badgeId}]);
}

#-------------------------------------------------------------------

=head2 purge

Deletes all ticket purchases of this type. No refunds are given.

=cut

sub purge {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantTicket where ticketAssetId=?",[$self->getId]);
	$self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 view

Displays the ticket description.

=cut

sub view {
	my ($self) = @_;
	
	# build objects we'll need
	my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
	my $form = $self->session->form;
		
	
	# render the page;
	my $output = '<h1>'.$self->getTitle.' ('.$self->get('eventNumber').')</h1>'
		.'<p>'.$self->get('description').'</p>'
		.'<p>'.$self->get('startDate').'</p>';

	# build the add to cart form
	if ($form->get('badgeId') ne '') {
		my $addToCart = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
		$addToCart->hidden(name=>"func", value=>"addToCart");
		$addToCart->hidden(name=>"badgeId", value=>$form->get('badgeId'));
		$addToCart->submit(value=>$i18n->get('add to cart','Shop'), label=>$self->getPrice);
		$output .= $addToCart->print;		
	}
		
	return $output;
}

#-------------------------------------------------------------------

=head2 www_addToCart

Takes form variable badgeId and add the ticket to the cart.

=cut

sub www_addToCart {
	my ($self) = @_;
	return $self->session->privilege->noAccess() unless $self->getParent->canView;
	my $badgeId = $self->session->form->get('badgeId');
	$self->addToCart({badgeId=>$badgeId});
	return $self->getParent->www_viewExtras($badgeId);
}


1;
