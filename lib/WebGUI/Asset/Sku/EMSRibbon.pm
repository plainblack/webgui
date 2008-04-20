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
use WebGUI::HTMLForm;


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

=head2 definition

Add price field to the definition.

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
			tab             => "shop",
			fieldType       => "float",
			defaultValue    => 0.00,
			label           => $i18n->get("price"),
			hoverHelp       => $i18n->get("price help"),
			},
		percentageDiscount => {
			tab             => "shop",
			fieldType       => "float",
			defaultValue    => 10.0,
			label           => $i18n->get("percentage discount"),
			hoverHelp       => $i18n->get("percentage discount help"),
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

=head2 getConfiguredTitle

Return title + badge holder name.

=cut

sub getConfiguredTitle {
    my $self = shift;
	my $name = $self->session->db->quickScalar("select name from EMSRegistrant where badgeId=?",[$self->getOptions->{badgeId}]);
    return $self->getTitle." (".$name.")";
}

#-------------------------------------------------------------------

=head2 getMaxAllowedInCart

Return 1;

=cut

sub getMaxAllowedInCart {
	return 1;
}

#-------------------------------------------------------------------

=head2 getPrice

Returns the price from the definition.

=cut

sub getPrice {
    my $self = shift;
    return $self->get("price");
}

#-------------------------------------------------------------------

=head2 onCompletePurchase

Does bookkeeping on EMSRegistrationRibbon table.

=cut

sub onCompletePurchase {
	my ($self, $item) = @_;
	$self->session->db->write("insert into EMSRegistrantRibbon (transactionItemId, ribbonAssetId, badgeId) values (?,?,?)",
		[$item->getId, $self->getId, $self->getOptions->{badgeId}]);
	return undef;
}

#-------------------------------------------------------------------

=head2 onRefund ( item)

Destroys the ribbon so that it can be resold.

=cut

sub onRefund {
	my ($self, $item) = @_;
	$self->session->db->write("delete from EMSRegistrantRibbon where transactionItemId=?",[$item->getId]);
	return undef;
}

#-------------------------------------------------------------------

=head2 purge

Deletes all entries in EMSRegistrationRibbon table for this sku. No refunds are given.

=cut

sub purge {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantRibbon where tokenAssetId=?",[$self->getId]);
	$self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 view

Displays the ribbon description.

=cut

sub view {
	my ($self) = @_;
	
	# build objects we'll need
	my $i18n = WebGUI::International->new($self->session, "Asset_EventManagementSystem");
	my $form = $self->session->form;
		
	
	# render the page;
	my $output = '<h1>'.$self->getTitle.'</h1>'
		.'<p>'.$self->get('description').'</p>';

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

Takes form variable badgeId and add the ribbon to the cart.

=cut

sub www_addToCart {
	my ($self) = @_;
	return $self->session->privilege->noAccess() unless $self->getParent->canView;
	my $badgeId = $self->session->form->get('badgeId');
	$self->addToCart({badgeId=>$badgeId});
	return $self->getParent->www_buildBadge($badgeId);
}

#-------------------------------------------------------------------

=head2 www_delete

Override to return to appropriate page.

=cut

sub www_delete {
	my ($self) = @_;
	$self->SUPER::www_delete;
	return $self->getParent->www_buildBadge(undef,'ribbons');
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
	my $form = $self->getEditForm;
	$form->hidden({name=>'proceed', value=>'viewAll'});
	return $self->processStyle('<h1>'.$i18n->get('ems ribbon').'</h1>'.$form->print);
}

#-------------------------------------------------------------------

=head2 www_viewAll ()

Displays the list of ribbons in the parent.

=cut

sub www_viewAll {
	my $self = shift;
	return $self->getParent->www_buildBadge(undef,"ribbons");
}


1;
