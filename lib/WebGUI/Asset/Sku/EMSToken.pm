package WebGUI::Asset::Sku::EMSToken;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
define assetName           => ['ems token', 'Asset_EMSToken'];
define icon                => 'EMSToken.gif';
define tableName           => 'EMSToken';
property price => (
            tab             => "shop",
            fieldType       => "float",
            default         => 0.00,
            label           => ["price", 'Asset_EMSToken'],
            hoverHelp       => ["price help", 'Asset_EMSToken'],
         );

use WebGUI::Utility;


=head1 NAME

Package WebGUI::Asset::Sku::EMSToken

=head1 DESCRIPTION

A token for the Event Manager. Tokens are like convention currency.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::EMSToken;

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

Returns title + badgeholder name.

=cut

sub getConfiguredTitle {
    my $self = shift;
	my $name = $self->session->db->quickScalar("select name from EMSRegistrant where badgeId=?",[$self->getOptions->{badgeId}]);
    return $self->getTitle." (".$name.")";
}

#-------------------------------------------------------------------

=head2 getPrice

Returns the value of the price field.

=cut

sub getPrice {
    my $self = shift;
    return $self->price;
}

#-------------------------------------------------------------------

=head2 onCompletePurchase

Adds tokens to the badge.

=cut

sub onCompletePurchase {
	my ($self, $item) = @_;
	my $db = $self->session->db;
	my @params = ($self->getId, $self->getOptions->{badgeId});
	my ($currentQuantity, $currentItemIds) = $db->quickArray("select quantity, transactionItemids from EMSRegistrantToken where tokenAssetId=? and badgeId=?",\@params);
	unshift @params, $item->get("quantity");
	if (defined $currentQuantity) {
		unshift @params, join(",", $currentItemIds, $item->getId);
		$db->write("update EMSRegistrantToken set transactionItemIds=?, quantity=quantity+? where tokenAssetId=? and badgeId=?",\@params);
	}
	else {
		unshift @params, $item->getId;
		$db->write("insert into EMSRegistrantToken (transactionItemIds, quantity, tokenAssetId, badgeId) values (?,?,?,?)",\@params);
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 onRefund ( item)

Destroys the token so that it can be resold.

=cut

sub onRefund {
	my ($self, $item) = @_;
	my $db = $self->session->db;
	my $token = $db->quickHashRef("select * from EMSRegistrantToken where transactionItemIds like ?",['%'.$item->getId.'%']);
	my @itemIds = split ',', $token->{transactionItemIds};
	for (my $i=0; $i<scalar @itemIds; $i++) {
		if ($itemIds[$i] eq $item->getId) {
			delete $itemIds[$i];
		}
	}
	if (scalar @itemIds < 2) {
		$db->write("delete from EMSRegistrantToken where badgeId=? and tokenAssetId=?",[$token->{badgeId}, $self->getId]);		
	}
	else {
		$db->write("update EMSRegistrantToken set quantity=?, transactionItemIds=? where badgeId=? and tokenAssetId=?",
			[($token->{quantity} - $item->get('quantity')), join(',', @itemIds), $token->{badgeId}, $self->getId]);
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 purge

Destroys all tokens of this type. No refunds are given.

=cut

override purge => sub {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantToken where tokenAssetId=?",[$self->getId]);
	super();
};

#-------------------------------------------------------------------

=head2 view

Displays the token description.

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
		my $addToCart = WebGUI::HTMLForm->new($self->session, action=>$self->getUrl);
		$addToCart->hidden(name=>"func", value=>"addToCart");
		$addToCart->hidden(name=>"badgeId", value=>$form->get('badgeId'));
		$addToCart->integer(name=>'quantity', value=>1, label=>$i18n->get('quantity','Shop'));
		$addToCart->submit(value=>$i18n->get('add to cart','Shop'), label=>$self->getPrice);
		$output .= $addToCart->print;		
	}
		
	return $output;
}

#-------------------------------------------------------------------

=head2 www_addToCart

Takes form variable badgeId and add the token to the cart.

=cut

sub www_addToCart {
	my ($self) = @_;
	return $self->session->privilege->noAccess() unless $self->getParent->canView && $self->canView;
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
    return $self->session->privilege->vitalComponent() if (isIn($self->getId,
$self->session->setting->get("defaultPage"), $self->session->setting->get("notFoundPage")));
    $self->trash;
    return $self->getParent->www_buildBadge(undef,'tokens');
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
	$form->addField( "hidden", name=>'proceed', value=>'viewAll');
	return $self->processStyle('<h1>'.$i18n->get('ems token').'</h1>'.$form->toHtml);
}

#-------------------------------------------------------------------

=head2 www_viewAll ()

Displays the list of tokens in the parent.

=cut

sub www_viewAll {
	my $self = shift;
	return $self->getParent->www_buildBadge(undef,"tokens");
}


__PACKAGE__->meta->make_immutable;
1;
