package WebGUI::Shop::Admin;

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::AdminConsole;
use WebGUI::Exception::Shop;
use WebGUI::HTMLForm;
use WebGUI::International;


=head1 NAME

Package WebGUI::Shop::Admin

=head1 DESCRIPTION

All the admin stuff that didn't fit elsewhere.

=head1 SYNOPSIS

 use WebGUI::Shop::Admin;

 my $admin = WebGUI::Shop::Admin->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;

#-------------------------------------------------------------------

=head2 canManage ( [ $user ] )

Determine whether or not a user can manage commerce functions

=head3 $user

An optional WebGUI::User object to check for permission to do commerce functions.  If
this is not used, it uses the current session user object.

=cut

sub canManage {
    my $self   = shift;
    my $user   = shift || $self->session->user;
    return $user->isInGroup( $self->session->setting->get('groupIdAdminCommerce'));
}

#-------------------------------------------------------------------

=head2 getAdminConsole ()

Returns a reference to the admin console with all submenu items already added.

=cut

sub getAdminConsole {
    my $self = shift;
    my $ac = WebGUI::AdminConsole->new($self->session, 'shop');
    my $i18n = WebGUI::International->new($self->session, "Shop");
    my $url = $self->session->url;
    $ac->addSubmenuItem($url->page("shop=admin"), $i18n->get("shop settings"));
    $ac->addSubmenuItem($url->page("shop=tax;method=manage"), $i18n->get("taxes"));
    $ac->addSubmenuItem($url->page("shop=pay;method=manage"), $i18n->get("payment methods"));
    $ac->addSubmenuItem($url->page("shop=ship;method=manage"), $i18n->get("shipping methods"));
    $ac->addSubmenuItem($url->page("shop=transaction;method=manage"), $i18n->get("transactions"));
    $ac->addSubmenuItem($url->page("shop=vendor;method=manage"), $i18n->get("vendors"));
    $ac->addSubmenuItem($url->page("shop=vendor;method=managePayouts"), $i18n->get("vendor payouts"));
    $ac->addSubmenuItem($url->page("shop=credit;method=manage"), $i18n->get("in shop credit"));
    return $ac;
}

#-------------------------------------------------------------------

=head2 isCashier ( [ $user ] )

Determine whether or not a user is a cashier

=head3 $user

An optional WebGUI::User object. If this is not used, it uses the current session user object.

=cut

sub isCashier {
    my $self   = shift;
    my $user   = shift || $self->session->user;
    return $user->isInGroup( $self->session->setting->get('groupIdCashier'));
}

#-------------------------------------------------------------------

=head2 new ( session )

Constructor. 

=head3 session

A reference to the current session.

=cut

sub new {
    my ($class, $session) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    my $self = register $class;
    my $id        = id $self;
    $session{ $id } = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 www_editSettings ()

Displays the general commerce settings.

=cut

sub www_editSettings {
    my $self = shift;
    return $self->session->privilege->adminOnly() unless ($self->canManage);
    my $i18n = WebGUI::International->new($self->session, "Shop");    
    my $ac = $self->getAdminConsole; 
    my $setting = $self->session->setting;
    my $form = WebGUI::HTMLForm->new($self->session);
    $form->submit;
    $form->hidden(name=>"shop", value=>"admin");
    $form->hidden(name=>"method", value=>"editSettingsSave");
    $form->group(
        name        => "groupIdAdminCommerce",
        value       => $setting->get("groupIdAdminCommerce"),
        label       => $i18n->get('who can manage'),
        hoverHelp   => $i18n->get('who can manage help'),
        );
    $form->group(
        name        => "groupIdCashier",
        value       => $setting->get("groupIdCashier"),
        label       => $i18n->get('who is a cashier'),
        hoverHelp   => $i18n->get('who is a cashier help'),
        );
    $form->float(
        name        => 'shopCartCheckoutMinimum',
        value       => $setting->get('shopCartCheckoutMinimum'),
        defaultValue=> '0.00',
        label       => $i18n->get('cart checkout minimum'),
        hoverHelp   => $i18n->get('cart checkout minimum help'),
    );
    $form->template(
        name        => "shopCartTemplateId",
        value       => $setting->get("shopCartTemplateId"),
        label       => $i18n->get("cart template"),
        namespace   => "Shop/Cart",
        hoverHelp   => $i18n->get("cart template help"),
        );
    $form->template(
        name        => "shopAddressBookTemplateId",
        value       => $setting->get("shopAddressBookTemplateId"),
        label       => $i18n->get("address book template"),
        namespace   => "Shop/AddressBook",
        hoverHelp   => $i18n->get("address book template help"),
        );
    $form->template(
        name        => "shopAddressTemplateId",
        value       => $setting->get("shopAddressTemplateId"),
        namespace   => "Shop/Address",
        label       => $i18n->get("edit address template"),
        hoverHelp   => $i18n->get("edit address template help"),
        );
    $form->template(
        name        => "shopMyPurchasesTemplateId",
        value       => $setting->get("shopMyPurchasesTemplateId"),
        namespace   => "Shop/MyPurchases",
        label       => $i18n->get("my purchases template"),
        hoverHelp   => $i18n->get("my purchases template help"),
        );
    $form->template(
        name        => "shopMyPurchasesDetailTemplateId",
        value       => $setting->get("shopMyPurchasesDetailTemplateId"),
        namespace   => "Shop/MyPurchasesDetail",
        label       => $i18n->get("my purchases detail template"),
        hoverHelp   => $i18n->get("my purchases detail template help"),
        );
    $form->submit;
    return $ac->render($form->print, $i18n->get("shop settings"));
}

#-------------------------------------------------------------------

=head2 www_editSettingsSave () 

Saves the general commerce settings.

=cut

sub www_editSettingsSave {
    my $self = shift;
    return $self->session->privilege->adminOnly() unless ($self->session->user->isAdmin);
    my ($setting, $form) = $self->session->quick(qw(setting form));

    # Save shop templates
    foreach my $template (qw(shopMyPurchasesDetailTemplateId shopMyPurchasesTemplateId
        shopCartTemplateId shopAddressBookTemplateId shopAddressTemplateId)) {
        $setting->set($template, $form->get($template, "template"));
    }

    # Save group settings
    foreach my $group (qw(groupIdCashier groupIdAdminCommerce)) {
        $setting->set($group, $form->get($group, "group"));
    }

    # Save mininmum cart checkout
    $setting->set( 'shopCartCheckoutMinimum', $form->get( 'shopCartCheckoutMinimum', 'float' ) );

    return $self->www_editSettings();   
}


1;
