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
    my $ac = WebGUI::AdminConsole->new($self->session);
    my $i18n = WebGUI::International->new($self->session, "Shop");
    my $url = $self->session->url;
    $ac->addSubmenuItem($url->page("shop=admin"), $i18n->get("shop settings"));
    $ac->addSubmenuItem($url->page("shop=tax;method=manage"), $i18n->get("taxes"));
    $ac->addSubmenuItem($url->page("shop=pay;method=manage"), $i18n->get("payment methods"));
    $ac->addSubmenuItem($url->page("shop=ship;method=manage"), $i18n->get("shipping methods"));
    $ac->addSubmenuItem($url->page("shop=transaction;method=manage"), $i18n->get("transactions"));
    return $ac;
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
    return $self->session->privilege->adminOnly() unless ($self->session->user->isInGroup("3"));
    my $i18n = WebGUI::International->new($self->session, "Shop");    
    my $ac = $self->getAdminConsole; 
    my $setting = $self->session->setting;
    my $form = WebGUI::HTMLForm->new($self->session);
    $form->submit;
    $form->hidden(name=>"shop", value=>"admin");
    $form->hidden(name=>"method", value=>"editSettingsSave");
    $form->template(
        name        => "shopCartTemplateId",
        value       => $setting->get("shopCartTemplateId"),
        label       => $i18n->get("shopping cart template"),
        namespace   => "Shop/Cart",
        hoverHelp   => $i18n->get("shopping cart template help"),
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
        name        => "myPurchasesTemplateId",
        value       => $setting->get("myPurchasesTemplateId"),
        namespace   => "Shop/MyPurchases",
        label       => $i18n->get("my purchases template"),
        hoverHelp   => $i18n->get("my purchases template help"),
        );
    $form->template(
        name        => "myPurchasesDetailTemplateId",
        value       => $setting->get("myPurchasesDetailTemplateId"),
        namespace   => "Shop/MyPurchases/Detail",
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
    return $self->session->privilege->adminOnly() unless ($self->session->user->isInGroup("3"));
    my ($setting, $form) = $self->session->quick(qw(setting form));
    $setting->set("shopCartTemplateId", $form->get("shopCartTemplateId", "template"));
    $setting->set("shopAddressBookTemplateId", $form->get("shopAddressBookTemplateId", "template"));
    $setting->set("shopAddressTemplateId", $form->get("shopAddressTemplateId", "template"));
    return $self->www_editSettings();   
}


1;
