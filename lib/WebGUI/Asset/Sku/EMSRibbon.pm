package WebGUI::Asset::Sku::EMSRibbon;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Sku';
define assetName           => ['ems ribbon', 'Asset_EventManagementSystem'];
define icon                => 'EMSRibbon.gif';
define tableName           => 'EMSRibbon';
property price => (
            tab             => "shop",
            fieldType       => "float",
            default         => 0.00,
            label           => ["price", 'Asset_EventManagementSystem'],
            hoverHelp       => ["price help", 'Asset_EventManagementSystem'],
         );
property percentageDiscount => (
            tab             => "shop",
            fieldType       => "float",
            default         => 10.0,
            label           => ["percentage discount", 'Asset_EventManagementSystem'],
            hoverHelp       => ["percentage discount help", 'Asset_EventManagementSystem'],
         );

use WebGUI::FormBuilder;

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

=head2 getAddToCartForm

Returns a button to take the user to the view screen.

=cut

sub getAddToCartForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'Asset_Sku');
    return
        WebGUI::Form::formHeader($session, {action => $self->getUrl})
      . WebGUI::Form::hidden(    $session, {name => 'func', value => 'view'})
      . WebGUI::Form::submit(    $session, {value => $i18n->get('see more')})
      . WebGUI::Form::formFooter($session)
      ;
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

=head2 getEditForm

Extend the base class so that the user is returned to the viewAll screen after adding/editing
a ribbon.

=cut

override getEditForm => sub {
    my $form = super();
    $form->addField('hidden', name => 'proceed', value => 'viewAll',);
}; 

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
    return $self->price;
}

#-------------------------------------------------------------------

=head2 isCoupon

Returns 1.

=cut

sub isCoupon {
    return 1;
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

override purge => sub {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantRibbon where ribbonAssetId=?",[$self->getId]);
	super();
};

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
		.'<p>'.$self->description.'</p>';

	# build the add to cart form
	if ($form->get('badgeId') ne '') {
		my $f = WebGUI::FormBuilder->new($self->session, action=>$self->getUrl);
		$f->addField( "hidden", name=>"func", value=>"addToCart");
		$f->addField( "hidden", name=>"badgeId", value=>$form->get('badgeId'));
		$f->addField( "submit", value=>$i18n->get('add to cart','Shop'), label=>$self->getPrice);
		$output .= $f->toHtml;
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
	return $self->session->privilege->insufficient() unless ($self->canEdit && $self->canEditIfLocked);
    return $self->session->privilege->vitalComponent() if $self->isSystem;
    return $self->session->privilege->vitalComponent() if $self->getId ~~ [
        $self->session->setting->get("defaultPage"), $self->session->setting->get("notFoundPage")
    ];
    $self->trash;
    return $self->getParent->www_buildBadge(undef,'ribbons');
}


#-------------------------------------------------------------------

=head2 www_viewAll ()

Displays the list of ribbons in the parent.

=cut

sub www_viewAll {
	my $self = shift;
	return $self->getParent->www_buildBadge(undef,"ribbons");
}


__PACKAGE__->meta->make_immutable;
1;
