package WebGUI::Account::Shop;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Shop::Vendor;
use JSON qw{ from_json };

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
    $var->{ 'managesPurchasesIsActive'  } = $method ~~ ["","managePurchases","view","viewTransaction"];

    $var->{ 'view_sales_url'            } = $self->getUrl( 'module=shop;do=viewSales' );
    $var->{ 'viewSalesIsActive'         } = $method eq 'viewSales';

    $var->{ 'manage_tax_url'            } = $self->getUrl( 'module=shop;do=manageTaxData' );
    $var->{ 'manageTaxIsActive'         } = $method eq 'manageTaxData';

    eval { WebGUI::Shop::Vendor->newByUserId($session, $session->user->userId); };
    $var->{ 'userIsVendor'              } = ! Exception::Class->caught();
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
        label       => $i18n->get('my sales template'),
        hoverHelp   => $i18n->get('my sales template help'),
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

Provides a list of all the users transactions, with links to view more details for each one.

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
            amount          => sprintf( '%.2f', $transaction->get('amount') - $transaction->get('shopCreditDeduction') ),
            amountMinusTax  => sprintf( '%.2f', $transaction->get('amount') - $transaction->get('shopCreditDeduction') - $transaction->get('taxes') ),
        };
    }

    $self->appendCommonVars($var);

    return $self->processTemplate($var,$session->setting->get("shopMyPurchasesTemplateId"));
}

#-------------------------------------------------------------------

=head2 www_manageTaxData ( )

A wrapper for TaxDriver->getUserScreen, allowing the user to enter configuration
data for himself.

=cut

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
    my $vendor  = eval { WebGUI::Shop::Vendor->newByUserId( $session, $session->user->userId ); };
    my @products;
    my $totalSales  = 0;
    my $var = {};
    if (! Exception::Class->caught()) {

        $var = $vendor->getPayoutTotals;

        my $sth = $session->db->read(
              q{ SELECT t1.*, sum(t1.quantity) as quantity, sum(t1.vendorPayoutAmount) as payoutAmount }
            . q{ FROM transactionItem as t1, transaction as t2 }
            . q{ WHERE t1.transactionId=t2.transactionId AND t2.isSuccessful <> 0 }
            . q{ AND vendorId=? }
            . q{ group by assetId order by quantity desc },
            [ $vendor->getId ]
        );
        while (my $row = $sth->hashRef) {
            my $data = $row;

            # Add asset properties to tmpl_vars.
            my $asset = eval { WebGUI::Asset->newById( $session, $row->{ assetId } ); };
            if (Exception::Class->caught()) {
                $session->log->error('Unable to instanciate assetId '.$row->{ assetId }.": $@");
                next;
            }
            $row = { %{ $row }, %{ $asset->get } } if $asset;
            
            push @products, $row;

            $totalSales += $row->{quantity};
        }
        $sth->finish;
    }

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
    my $transaction   = shift || WebGUI::Shop::Transaction->new( $session,$transactionId );
    my $notice        = shift;

    return $session->privilege->insufficient unless $transaction->get('userId') eq $session->user->userId;
   
    my $var = $transaction->getTransactionVars;
    $var->{ notice } = $notice;
    $self->appendCommonVars( $var );

    # render
    return $self->processTemplate( $var, $session->setting->get('shopMyPurchasesDetailTemplateId') );
}




1;
