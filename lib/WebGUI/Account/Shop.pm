package WebGUI::Account::Shop;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::Shop

=head1 DESCRIPTION

Shop Features built into the Account system

=head1 SYNOPSIS

use WebGUI::Account::Shop;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 appendCommonVars ( var )

Appends common template variables that shop templates will use

=head3 var

The hash reference to append template variables to

=cut

sub appendCommonVars {
    my $self    = shift;
    my $var     = shift;

    $self->SUPER::appendCommonVars($var);
    
    my $session = $self->session;
    my $user    = $session->user;
    my $method  = $session->form->get("do");
    
    $var->{ 'manage_purchases_url'      } = $self->getUrl("module=shop;do=managePurchases");
    $var->{ 'managesPurchasesIsActive'  } = WebGUI::Utility::isIn($method,("","managePurchases","view","viewTransaction"));

    $var->{ 'view_sales_url'            } = $self->getUrl( 'module=shop;do=viewSales' );
    $var->{ 'viewSalesIsActive'         } = $method eq 'viewSales';

    $var->{ 'manage_tax_url'            } = $self->getUrl( 'module=shop;do=manageTaxData' );
    $var->{ 'manageTaxIsActive'         } = $method eq 'manageTaxData';
}

#-------------------------------------------------------------------

=head2 canView ( )

Returns whether or not the user can view the the tab for this module

=cut

sub canView {
    my $self  = shift;
    return ($self->uid eq ""); 
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

Creates form elements for user settings page custom to this account module

=cut

sub editSettingsForm {
    my $self     = shift;
    my $session  = $self->session;
    my $i18n     = WebGUI::International->new($session,'Account_Shop');
    my $shopi18n = WebGUI::International->new($session,'Shop');
    my $f        = WebGUI::HTMLForm->new($session);

    $f->template(
		name      => "shopStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("shop style template label"),
        hoverHelp => $i18n->get("shop style template hoverHelp")
    );
    $f->template(
		name      => "shopLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("shop layout template label"),
        hoverHelp => $i18n->get("shop layout template hoverHelp")
    );
    $f->template(
		name      => "shopMyPurchasesTemplateId",
		value     => $self->session->setting->get("shopMyPurchasesTemplateId"),
		namespace => "Shop/MyPurchases",
		label     => $shopi18n->get("my purchases template"),
        hoverHelp => $shopi18n->get("my purchases template help")
    );
    $f->template(
		name      => "shopMyPurchasesDetailTemplateId",
		value     => $self->session->setting->get("shopMyPurchasesDetailTemplateId"),
		namespace => "Shop/MyPurchasesDetail",
		label     => $shopi18n->get("my purchases detail template"),
        hoverHelp => $shopi18n->get("my purchases detail template help")
    );
    $f->template(
        name        => 'shopMySalesTemplateId',
        value       => $self->session->setting->get('shopMySalesTemplateId'),
        namespace   => 'Shop/MySales',
        label       => $shopi18n->echo('my sales template'),
        hoverHelp   => $shopi18n->echo('my sales template help'),
    );

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

Creates form elements for the settings page custom to this account module

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    $setting->set("shopStyleTemplateId", $form->process("shopStyleTemplateId","template"));
    $setting->set("shopLayoutTemplateId", $form->process("shopLayoutTemplateId","template"));
    $setting->set("shopMyPurchasesTemplateId", $form->process("shopMyPurchasesTemplateId","template"));
    $setting->set("shopMyPurchasesDetailTemplateId", $form->process("shopMyPurchasesDetailTemplateId","template"));
    $setting->set("shopMySalesTemplateId", $form->process("shopMySalesTemplateId","template"));
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the templateId for the layout of your new module.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("shopLayoutTemplateId") || "aUDsJ-vB9RgP-AYvPOy8FQ";
}


#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("shopStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 www_managePurchases ( )

The main view page for editing the user's profile.

=cut

sub www_managePurchases {
    my $self    = shift;
    my $session = $self->session;
    my $url     = $session->url;

    my $var     = {};
    $var->{transactions} = [];

    # build list
    foreach my $id (@{WebGUI::Shop::Transaction->getTransactionIdsForUser($session)}) {
        my $transaction = WebGUI::Shop::Transaction->new($session, $id);
        push @{$var->{transactions}}, {
            %{$transaction->get},
            viewDetailUrl   => $self->getUrl('op=account;module=shop;do=viewTransaction;transactionId='.$id),
            amount          => sprintf("%.2f", $transaction->get('amount')),
        };
    }

    $self->appendCommonVars($var);

    return $self->processTemplate($var,$session->setting->get("shopMyPurchasesTemplateId"));
}

#-------------------------------------------------------------------
sub www_manageTaxData {
    my $self    = shift;
    my $session = $self->session;

    my $userScreen = WebGUI::Shop::Tax->new( $session )->getDriver->getUserScreen;


    return $userScreen;
}

#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing the user's profile.

=cut

sub www_view {
    my $self    = shift;

    #Use the view class as the driver for now. This will likely grow
    return $self->www_managePurchases();

}

#-------------------------------------------------------------------

=head2 www_viewSales ( )

Page that show your earnings if you are a vendor.

=cut

sub www_viewSales {
    my $self    = shift;
    my $session = $self->session;
    my $vendor  = WebGUI::Shop::Vendor->newByUserId( $session, $session->user->userId );

    my $var         = $vendor->getPayoutTotals;
    my $totalSales  = 0;
    my @products;

    my $sth = $session->db->read(
        'select *, sum(quantity) as quantity, sum(vendorPayoutAmount) as payoutAmount from transactionItem '
        .'where vendorId=? group by assetId order by quantity desc',
        [ $vendor->getId ]
    );
    while (my $row = $sth->hashRef) {
        push @products, $row;
        $totalSales += $row->{quantity};
    }
    $sth->finish;

    $var->{ product_loop   } = \@products;
    $var->{ total_products  } = scalar @products;
    $var->{ total_sales     } = $totalSales;
    
    $self->appendCommonVars( $var );

    return $self->processTemplate( $var, $session->setting->get('shopMySalesTemplateId') ); 
}

#-------------------------------------------------------------------

=head2 www_viewTransaction ( )

The main view page for editing the user's profile.

=cut

sub www_viewTransaction {
    my $self    = shift;
    my $session = $self->session;
   
    my $transactionId = $session->form->get('transactionId');
    my $transaction   = shift || WebGUI::Shop::Transaction->new($session,$transactionId);
    my $notice        = shift;

    return $session->insufficient unless ($transaction->get('userId') eq $session->user->userId);

    my $i18n          = WebGUI::International->new($session, 'Shop');
    my ($style, $url) = $session->quick(qw(style url));
    
    my %var = (
        %{$transaction->get},
        notice                  => $notice,
        cancelRecurringUrl      => $url->page('shop=transaction;method=cancelRecurring;transactionId='.$transaction->getId),
        amount                  => sprintf("%.2f", $transaction->get('amount')),
        inShopCreditDeduction   => sprintf("%.2f", $transaction->get('inShopCreditDeduction')),
        taxes                   => sprintf("%.2f", $transaction->get('taxes')),
        shippingPrice           => sprintf("%.2f", $transaction->get('shippingPrice')),
        shippingAddress         => $transaction->formatAddress({
                                        name        => $transaction->get('shippingAddressName'),
                                        address1    => $transaction->get('shippingAddress1'),
                                        address2    => $transaction->get('shippingAddress2'),
                                        address3    => $transaction->get('shippingAddress3'),
                                        city        => $transaction->get('shippingCity'),
                                        state       => $transaction->get('shippingState'),
                                        code        => $transaction->get('shippingCode'),
                                        country     => $transaction->get('shippingCountry'),
                                        phoneNumber => $transaction->get('shippingPhoneNumber'),
                                        }),
        paymentAddress          =>  $transaction->formatAddress({
                                        name        => $transaction->get('paymentAddressName'),
                                        address1    => $transaction->get('paymentAddress1'),
                                        address2    => $transaction->get('paymentAddress2'),
                                        address3    => $transaction->get('paymentAddress3'),
                                        city        => $transaction->get('paymentCity'),
                                        state       => $transaction->get('paymentState'),
                                        code        => $transaction->get('paymentCode'),
                                        country     => $transaction->get('paymentCountry'),
                                        phoneNumber => $transaction->get('paymentPhoneNumber'),
                                        }),
        );
    
    # items
    my @items = ();
    foreach my $item (@{$transaction->getItems}) {
        my $address = '';
        if ($transaction->get('shippingAddressId') ne $item->get('shippingAddressId')) {
            $address = $transaction->formatAddress({
                            name        => $item->get('shippingAddressName'),
                            address1    => $item->get('shippingAddress1'),
                            address2    => $item->get('shippingAddress2'),
                            address3    => $item->get('shippingAddress3'),
                            city        => $item->get('shippingCity'),
                            state       => $item->get('shippingState'),
                            code        => $item->get('shippingCode'),
                            country     => $item->get('shippingCountry'),
                            phoneNumber => $item->get('shippingPhoneNumber'),
                            });
        }

        # Post purchase actions
        my $actionsLoop = [];
        my $actions     = $item->getSku->getPostPurchaseActions( $item );
        for my $label ( keys %{$actions} ) {
            push @{$actionsLoop}, {
                label       => $label,
                url         => $actions->{$label},
            }
        }

        push @items, {
            %{$item->get},
            viewItemUrl         => $url->page('shop=transaction;method=viewItem;transactionId='.$transaction->getId.';itemId='.$item->getId),
            price               => sprintf("%.2f", $item->get('price')),
            itemShippingAddress => $address,
            orderStatus         => $i18n->get($item->get('orderStatus')),
            actionsLoop         => $actionsLoop,
        };
    }
    $var{items} = \@items;

    $self->appendCommonVars(\%var);

    # render
    return $self->processTemplate(\%var,$session->setting->get("shopMyPurchasesDetailTemplateId"));
}




1;
