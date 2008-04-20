package WebGUI::Asset::Sku::EMSBadge;

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
use JSON;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Shop::AddressBook;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Asset::Sku::EMSBadge

=head1 DESCRIPTION

A badge for the Event Manager. Badges allow you into the convention.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::EMSBadge;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addToCart ( badgeInfo )

Adds this badge as configured for an individual to the cart.

=cut

sub addToCart {
	my ($self, $badgeInfo) = @_;
	$badgeInfo->{badgeId} = "new";
	$badgeInfo->{badgeAssetId} = $self->getId;
	$badgeInfo->{emsAssetId} = $self->getParent->getId;
	my $badgeId = $self->session->db->setRow("EMSRegistrant","badgeId", $badgeInfo);
	$self->SUPER::addToCart({badgeId=>$badgeId});
}

#-------------------------------------------------------------------

=head2 definition

Adds price, seatsAvailable fields.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, "Asset_EventManagementSystem");
	%properties = (
		price => {
			tab             => "shop",
			fieldType       => "float",
			defaultValue    => 0.00,
			label           => $i18n->get("price"),
			hoverHelp       => $i18n->get("price help"),
			},
		seatsAvailable => {
			tab             => "shop",
			fieldType       => "integer",
			defaultValue    => 100,
			label           => $i18n->get("seats available"),
			hoverHelp       => $i18n->get("seats available help"),
			},
		relatedBadgeGroups => {
			tab             => "properties",
			fieldType		=> "checkList",
			customDrawMethod=> 'drawRelatedBadgeGroupsField',
			label           => $i18n->get("related badge groups"),
			hoverHelp       => $i18n->get("related badge groups badge help"),
			},
	    );
	push(@{$definition}, {
		assetName           => $i18n->get('ems badge'),
		icon                => 'EMSBadge.gif',
		autoGenerateForms   => 1,
		tableName           => 'EMSBadge',
		className           => 'WebGUI::Asset::Sku::EMSBadge',
		properties          => \%properties
	    });
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 drawRelatedBadgeGroupsField ()

Draws the field for the relatedBadgeGroups property.

=cut

sub drawRelatedBadgeGroupsField {
	my ($self, $params) = @_;
	return WebGUI::Form::checkList($self->session, {
		name		=> $params->{name},
		value		=> $self->get($params->{name}),
		vertical	=> 1,
		options		=> $self->getParent->getBadgeGroups,
		});
}


#-------------------------------------------------------------------

=head2 getConfiguredTitle

Returns title + badgeholder name

=cut

sub getConfiguredTitle {
    my $self = shift;
	my $name = $self->session->db->quickScalar("select name from EMSRegistrant where badgeId=?",[$self->getOptions->{badgeId}]);
    return $self->getTitle." (".$name.")";
}


#-------------------------------------------------------------------

=head2 getMaxAllowedInCart

Returns 1

=cut

sub getMaxAllowedInCart {
	return 1;
}

#-------------------------------------------------------------------

=head2 getPrice

Returns the price field value.

=cut

sub getPrice {
    my $self = shift;
    return $self->get("price");
}

#-------------------------------------------------------------------

=head2 getQuantityAvailable

Returns seatsAvailable - the count from the EMSRegistrant table.

=cut

sub getQuantityAvailable {
	my $self = shift;
	my $seatsTaken = $self->session->db->quickScalar("select count(*) from EMSRegistrant where badgeAssetId=?",[$self->getId]);
    return $self->get("seatsAvailable") - $seatsTaken;
}

#-------------------------------------------------------------------

=head2 onCompletePurchase (item)

Marks badge order as paid.

=cut

sub onCompletePurchase {
	my ($self, $item) = @_;
	my $badgeInfo = $self->getOptions;
	$badgeInfo->{purchaseComplete} = 1;
	$badgeInfo->{userId} = $self->session->user->userId; # they have to be logged in at this point
	$badgeInfo->{transactionItemId} = $item->getId;
	$self->session->db->setRow("EMSRegistrant","badgeId", $badgeInfo);
	return undef;
}

#-------------------------------------------------------------------

=head2 onRefund ( item)

Destroys the badge so that it can be resold.

=cut

sub onRefund {
	my ($self, $item) = @_;
	my $db = $self->session->db;
	my $badgeId = $self->getOptions->{badgeId};

	# refund any purchased tickets related to the badge 
	foreach my $id ($db->buildArray("select transactionItemId from EMSRegistrantTicket where badgeId=?",[$badgeId])) {		
		my $item = WebGUI::Shop::TransactionItem->newByDynamicTransaction($self->session, $id);
		if (defined $item) {
			$item->issueCredit;
		}
	}
	
	# refund any purchased ribbons related to the badge
	foreach my $id ($db->buildArray("select transactionItemId from EMSRegistrantRibbon where badgeId=?",[$badgeId])) {		
		my $item = WebGUI::Shop::TransactionItem->newByDynamicTransaction($self->session, $id);
		if (defined $item) {
			$item->issueCredit;
		}
	}
	
	# refund any purchased tokens related to this badge
	foreach my $ids ($db->buildArray("select transactionItemIds from EMSRegistrantToken where badgeId=?",[$badgeId])) {
		foreach my $id (split(',', $ids)) {
			my $item = WebGUI::Shop::TransactionItem->newByDynamicTransaction($self->session, $id);
			if (defined $item) {
				$item->issueCredit;
			}
		}
	}
	
	# get rid of any items in the cart related to this badge
	foreach my $cartitem (@{$self->getCart->getItems()}) {
		my $sku = $cartitem->getSku;
		if (isIn((ref $sku), qw(WebGUI::Asset::Sku::EMSTicket WebGUI::Asset::Sku::EMSRibbon WebGUI::Asset::Sku::EMSToken))) {
			if ($sku->getOptions->{badgeId} eq $badgeId) {
				$cartitem->remove;
			}
		}
	}
	
	# get rid ofthe badge itself 
	$db->write("delete from EMSRegistrant where transactionItemId=?",[$item->getId]);
	return undef;
}

#-------------------------------------------------------------------

=head2 onRemoveFromCart ( item )

Destroys badge.

=cut

sub onRemoveFromCart {
	my ($self, $item) = @_;
	my $badgeId = $self->getOptions->{badgeId};
	foreach my $cartitem (@{$item->cart->getItems()}) {
		my $sku = $cartitem->getSku;
		if (isIn((ref $sku), qw(WebGUI::Asset::Sku::EMSTicket WebGUI::Asset::Sku::EMSRibbon WebGUI::Asset::Sku::EMSToken))) {
			if ($sku->getOptions->{badgeId} eq $badgeId) {
				$cartitem->remove;
			}
		}
	}
	$self->session->db->deleteRow('EMSRegistrant','badgeId',$badgeId);
}

#-------------------------------------------------------------------

=head2 purge

Deletes all badges and things attached to the badges. No refunds are given.

=cut

sub purge {
	my $self = shift;
	my $db = $self->session->db;
	$db->write("delete from EMSRegistrantTicket where badgeAssetId=?",[$self->getId]);
	$db->write("delete from EMSRegistrantToken where badgeAssetId=?",[$self->getId]);
	$db->write("delete from EMSRegistrantRibbon where badgeAssetId=?",[$self->getId]);
	$db->write("delete from EMSRegistrant where badgeAssetId=?",[$self->getId]);
	$self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 view

Displays badge description.

=cut

sub view {
	my ($self) = @_;
	
	my $error = $self->{_errorMessage};
	my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
	my $form = $self->session->form;
	
	# build the form to allow the user to choose from their address book
	my $book = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
	$book->hidden(name=>"shop", value=>"address");
	$book->hidden(name=>"method", value=>"view");
	$book->hidden(name=>"callback", value=>JSON->new->utf8->encode({
		url		=> $self->getUrl,
		}));
	$book->submit(value=>$i18n->get("populate from address book"));
	
	# instanciate address
	my $address = WebGUI::Shop::AddressBook->newBySession($self->session)->getAddress($form->get("addressId")) if ($form->get("addressId"));
	
	# build the form that the user needs to fill out with badge holder information
	my $info = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
	$info->hidden(name=>"func", value=>"addToCart");
	$info->text(
		name			=> 'name',
		label			=> $i18n->get('name','Shop'),
		defaultValue	=> (defined $address) ? $address->get("name") : $form->get('name'),
		);
	$info->text(
		name			=> 'organization',
		label			=> $i18n->get('organization'),
		defaultValue	=> $form->get("organization"),
		);
	$info->text(
		name			=> 'address1',
		label			=> $i18n->get('address','Shop'),		
		defaultValue	=> (defined $address) ? $address->get("address1") : $form->get('address1'),
		);
	$info->text(
		name			=> 'address2',
		defaultValue	=> (defined $address) ? $address->get("address2") : $form->get('address2'),
		);
	$info->text(
		name			=> 'address3',
		defaultValue	=> (defined $address) ? $address->get("address3") : $form->get('address3'),
		);
	$info->text(
		name			=> 'city',
		label			=> $i18n->get('city','Shop'),		
		defaultValue	=> (defined $address) ? $address->get("city") : $form->get('city'),
		);
	$info->text(
		name			=> 'state',
		label			=> $i18n->get('state','Shop'),		
		defaultValue	=> (defined $address) ? $address->get("state") : $form->get('state'),
		);
	$info->zipcode(
		name			=> 'zipcode',
		label			=> $i18n->get('code','Shop'),		
		defaultValue	=> (defined $address) ? $address->get("code") : $form->get('zipcode','zipcode'),
		);
	$info->country(
		name			=> 'country',
		label			=> $i18n->get('country','Shop'),		
		defaultValue	=> (defined $address) ? $address->get("country") : ($form->get('country') || 'United States'),
		);
	$info->phone(
		name			=> 'phoneNumber',
		label			=> $i18n->get('phone number','Shop'),		
		defaultValue	=> (defined $address) ? $address->get("phoneNumber") : $form->get("phone","phone"),
		);
	$info->email(
		name			=> 'email',
		label			=> $i18n->get('email address'),
		defaultValue	=> $form->get("email","email")
		);
	$info->submit(value=>$i18n->get('add to cart'));
	
	# render the page;
	my $output = '<h1>'.$self->getTitle.'</h1>'
		.'<p>'.$self->get('description').'</p>'
		.'<h2>'.$i18n->get("badge holder information").'</h2>'
		.$book->print;
	if ($error ne "") {
		$output .= '<p><b>'.$error.'</b></p>';
	}
	$output .= $info->print;
	return $output;
}


#-------------------------------------------------------------------

=head2 www_addToCart

Processes form from view() and then adds to cart.

=cut

sub www_addToCart {
	my ($self) = @_;
	return $self->session->privilege->noAccess() unless $self->getParent->canView;
	
	# gather badge info
	my $form = $self->session->form;
	my %badgeInfo = ();
	foreach my $field (qw(name address1 address2 address3 city state organization)) {
		$badgeInfo{$field} = $form->get($field, "text");
	}
	$badgeInfo{'phoneNumber'} = $form->get('phoneNumber', 'phone');
	$badgeInfo{'email'} = $form->get('email', 'email');
	$badgeInfo{'country'} = $form->get('country', 'country');
	$badgeInfo{'zipcode'} = $form->get('zipcode', 'zipcode');
	

	# check for required fields
	my $error = "";
	my $i18n = WebGUI::International->new($self->session, 'Asset_EventManagementSystem');
	if ($badgeInfo{name} eq "") {
		$error =  sprintf $i18n->get('is required'), $i18n->get('name','Shop');
	}
	
	# return them back to the previous screen if they messed up
	if ($error) {
		$self->{_errorMessage} = $error;
		return $self->www_view($error);
	}
	
	# add it to the cart
	$self->addToCart(\%badgeInfo);
	return $self->getParent->www_buildBadge($self->getOptions->{badgeId});
}


#-------------------------------------------------------------------

=head2 www_edit ()

Displays the edit form.

=cut

sub www_edit {
	my ($self) = @_;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->session->privilege->locked() unless $self->canEditIfLocked;
	$self->session->style->setRawHeadTags(q|
		<style type="text/css">
		.forwardButton {
			background-color: green;
			color: white;
			font-weight: bold;
			padding: 3px;
		}
		.backwardButton {
			background-color: red;
			color: white;
			font-weight: bold;
			padding: 3px;
		}
		</style>
						   |);	
	my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
	return $self->processStyle('<h1>'.$i18n->get('ems badge').'</h1>'.$self->getEditForm->print);
}

1;
