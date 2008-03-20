package WebGUI::Asset::Sku::EMSToken;

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

Package WebGUI::Asset::Sku::EMSToken

=head1 DESCRIPTION

A token for the Event Manager. Tokens are like convention currency.

=head1 SYNOPSIS

use WebGUI::Asset::Sku::EMSToken;

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
		assetName           => $i18n->get('ems token'),
		icon                => 'EMSToken.gif',
		autoGenerateForms   => 1,
		tableName           => 'EMSToken',
		className           => 'WebGUI::Asset::Sku::EMSToken',
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
sub getPrice {
    my $self = shift;
    return $self->get("price");
}

#-------------------------------------------------------------------
sub onCompletePurchase {
	my ($self, $item) = @_;
	my $db = $self->session->db;
	my @params = ($self->getId, $self->getOptions->{badgeId});
	my $currentQuantity = $db->quickScalar("select quantity from EMSRegistrantToken where tokenAssetId=? and badgeId=?",\@params);
	unshift @params, $item->get("quantity");
	if (defined $currentQuantity) {
		$db->write("update EMSRegistrationToken set quantity=quantity+? where tokenAssetId=? and badgeId=?",\@params);
	}
	else {
		$db->write("insert into EMSRegistrationToken (quantity, tokenAssetId, badgeId) values (?,?,?)",\@params);
	}
	return undef;
}

#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->session->db->write("delete from EMSRegistrantToken where tokenAssetId=?",[$self->getId]);
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
