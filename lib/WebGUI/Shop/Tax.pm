package WebGUI::Shop::Tax;

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
use WebGUI::Exception::Shop;
use WebGUI::Shop::Admin;
use WebGUI::Pluggable;
use List::Util qw{sum};

=head1 NAME

Package WebGUI::Shop::Tax

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart.  It isn't a classic object
in that the only data it contains is a WebGUI::Session object, but it does provide several methods for
handling the information in the tax tables.

=head1 SYNOPSIS

 use WebGUI::Shop::Tax;

 my $tax = WebGUI::Shop::Tax->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

has session => (
    is              => 'ro',
    required        => 1,
);

around BUILDARGS => sub {
    my $orig       = shift;
    my $className  = shift;

    ##Original arguments start here.
    my $protoSession = $_[0];
    if (blessed $protoSession && $protoSession->isa('WebGUI::Session')) {
        return $className->$orig(session => $protoSession);
    }
    return $className->$orig(@_);
};


##-------------------------------------------------------------------
#sub appendSkuForm {
#    my $self    = shift;
#    my $assetId = shift;
#    my $form    = shift;
#    my $db      = $self->session->db;
#
#    my $values  = $db->buildHashRef( 'select name, value from skuTaxConfiguration where assetId=?', [
#        $assetId,
#    ] );
#
#    my $definition = $self->getDriver->skuFormDefinition;
#    foreach my $fieldName (keys %{ $definition }) {
#        $form->dynamicField(
#            %{ $definition->{ $fieldName } },
#            name    => $fieldName,
#            value   => $values->{ $fieldName },
#        );            
#    }
#}

#-------------------------------------------------------------------

=head2 calculate ( $cart )

Calculate the tax for the contents of the cart.  

=head3 cart

An instanciated cart object.

=cut

sub calculate {
    my $self = shift;
    my $cart = shift;
    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a WebGUI::Shop::Cart object')
        unless ref($cart) eq 'WebGUI::Shop::Cart';
    my $book = $cart->getAddressBook;

    my $driver  = $self->getDriver;
    my $tax     = 0;

    foreach my $item (@{ $cart->getItems }) {
        my $sku         = $item->getSku;
        my $quantity    = $item->quantity;
        my $unitPrice   = $sku->getPrice;

        my $taxRate = $driver->getTaxRate( $sku, $item->getShippingAddress );

        # Calc the monetary tax for the given quantity of this item and add it to the total.
        $tax += $unitPrice * $quantity * $taxRate / 100;
    }

    return $tax;
}

#-------------------------------------------------------------------

=head2 getDriver ( [ $session ] )

Return an instance of the enabled tax driver. This method can be invoked both as class or instance method. If you
invoke this method as a class method you must pass a WebGUI::Session object.

=head3 session

A WebGUI::Session object. Required in class context, optional in instance context.

=cut

sub getDriver {
    my $self    = shift;
    my $session = shift;
    if (!$session && blessed $self) {
        $session = $self->session;
    }

    WebGUI::Error::InvalidObject->throw( expected => "WebGUI::Session", got => (ref $session), error => "Need a session." )
        unless $session && $session->isa( 'WebGUI::Session' );

    my $className   = $session->setting->get( 'activeTaxPlugin' );
    my $driver      = eval {
        WebGUI::Pluggable::instanciate( $className, 'new', [ $session ] );
    };
    if ($@) {
        $session->log->error("Can't instanciate tax driver [$className] because $@");
        return undef;
    }

    return $driver;
}



#-------------------------------------------------------------------

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 www_do ( )

Allows tax drivers to define their own www_ methods. Pass the www_ method that must be executed in the 'do' form
var.

=cut

sub www_do {
    my $self    = shift;
    my $session = $self->session;

    my $taxDriver = $self->getDriver;
    my $method    = 'www_' . $session->form->process( 'do' );

    return "Invalid method name" unless $method =~ m{ ^[a-zA-Z0-9_]+$ }xms;

    if ( $taxDriver->can( $method ) ) {
        my $output = eval{ $taxDriver->$method };

        if ($@) {
            $session->log->error("An error occurred while executing method [$method] on active tax driver: $@");
            return "An error occurred while executing a method on a tax driver. Please consult the webgui log.";
        }
        else {
            return $output || $self->www_manage;
        }
    }

    return "Cannot call method [$method] on active tax driver.";
}

#-------------------------------------------------------------------

=head2 www_manage ( $status_message )

User interface to manage taxes.  Provides a list of current taxes, and forms for adding
new tax info, exporting and importing sets of taxes, and deleting individual tax data.

=head3 $status_message

A message to display to the user.  This is usually a problem that was found during
import.

=cut

sub www_manage {
    my $self            = shift;
    my $status_message  = shift;
    my $session         = $self->session;
    my $admin           = WebGUI::Shop::Admin->new( $session );

    return $session->privilege->insufficient unless $admin->canManage;

    my ($style, $url)   = $session->quick( qw(style url) );
    my $i18n            = WebGUI::International->new( $session, 'Tax' );

    my $activePlugin    = $session->setting->get( 'activeTaxPlugin' );
    my $plugins         = $session->config->get( 'taxDrivers' );
    my %options         = map { $_ => $_ } @{ $plugins };

    my $pluginSwitcher  =
        '<fieldset><legend>'.$i18n->get('Active tax plugin') . '</legend>'
        . WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden(     $session, { name => 'shop',      value => 'tax' } )
        . WebGUI::Form::hidden(     $session, { name => 'method',    value => 'setActivePlugin' } )
        . $i18n->get('Active tax plugin') . ' ' 
        . WebGUI::Form::selectBox(  $session, { name => 'className', value => $activePlugin, options => \%options } )
        . WebGUI::Form::submit(     $session, { value => $i18n->get('Switch') } )
        . WebGUI::Form::formFooter( $session )
        . '</fieldset>'
        ;

#    my $output;
#    if ($status_message) {
#        $output = qq{<div class="error">$status_message</div>};
#    }

    my $taxDriver   = $self->getDriver;
    my $editForm    = $taxDriver->getEditForm;
    my $editFormHtml = '';
    if ( blessed $editForm and $editForm->isa( 'WebGUI::FormBuilder' ) ) {
        $editFormHtml = $editForm->toHtml;
    }
    my $output      = 
        $pluginSwitcher
        . '<fieldset><legend>Plugin configuration</legend>' 
            . $editFormHtml
        . '</fieldset>'
        ;

    return $admin->getAdminConsole->render($output, $i18n->get('taxes', 'Shop'));
}

#-------------------------------------------------------------------

=head2 www_setActivePlugin ( )

Displays a warning that informs users that they're about to change the active taxing plugin. Includes a confirm and
cancel button.

=cut

sub www_setActivePlugin {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new( $session );

    return $session->privilege->insufficient unless $admin->canManage;

    my $i18n    = WebGUI::International->new( $session, 'Tax' );
    my $message = $i18n->get('Stern tax warning'); 

    my $proceedForm = 
        WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { name => 'shop',      value => 'tax' } )
        . WebGUI::Form::hidden( $session, { name => 'method',    value => 'setActivePluginConfirm' } )
        . WebGUI::Form::hidden( $session, { name => 'className', value => $session->form->process('className') } )
        . WebGUI::Form::submit( $session, { value => $i18n->get('Proceed') } )
        . WebGUI::Form::formFooter( $session );
        
    my $cancelForm = 
        WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { name => 'shop',    value => 'tax' } )
        . WebGUI::Form::hidden( $session, { name => 'method',    value => 'manage' } )
        . WebGUI::Form::submit( $session, { value => $i18n->get('cancel','WebGUI'), extras => 'class="backwardButton"' } )
        . WebGUI::Form::formFooter( $session );

    my $output = $message . $proceedForm . $cancelForm;
    return $admin->getAdminConsole->render( $output, $i18n->get('Switch tax plugin') );
}

#-------------------------------------------------------------------

=head2 www_setActivePluginConfirm ( )

Actually changes the active tax driver.

=cut

sub www_setActivePluginConfirm {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new( $session );

    return $session->privilege->insufficient unless $admin->canManage;
    
    my $className = $session->form->process( 'className', 'className' );
    #### TODO: Check aginst list of available plugins.
    $session->setting->set( 'activeTaxPlugin', $className );

    return $self->www_manage;
}

1;
