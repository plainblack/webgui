package WebGUI::Shop::TaxDriver;

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

=head1 NAME

Package WebGUI::Shop::TaxDriver

=head1 DESCRIPTION

This package is the base class for all modules which implement a tax driver.

=head1 SYNOPSIS

 use WebGUI::Shop::TaxDriver;

 my $taxDriver = WebGUI::Shop::TaxDriver->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

use strict;

use Class::InsideOut qw{ :std };
use JSON qw{ from_json to_json };

=head1 NAME

Package WebGUI::Shop::TaxDriver

=head1 DESCRIPTION

Base class for all modules which do tax calculations in the Shop.

=head1 SYNOPSIS

 use base WebGUI::Shop::TaxDriver;

 my $driver = WebGUI::Shop::TaxDriver->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session    => my %session;
readonly messages   => my %messages;
private  options    => my %options;


=head2 appendCartItemVars ( var, cartItem ) 

Adds tax driver specific template variables for the given cart item to the supplied hashref.

=head3 var

The template variable hash ref to add the tax vars to.

=head3 cartItem

The instanstance of WebGUI::Shop::CartItem to add the vars for.

=cut

sub appendCartItemVars {
    my $self    = shift;
    my $var     = shift;
    my $item    = shift;

    WebGUI::Error::InvalidParam->throw( 'Must supply a hash ref' )
        unless $var && ref $var eq 'HASH';
    WebGUI::Error::InvalidObject->throw( expected => 'WebGUI::Shop::CartItem', got => ref $item, error => 'Must pass a cart item' )
        unless $item && $item->isa( 'WebGUI::Shop::CartItem' );

    my $sku         = $item->getSku;
    my $address     = eval { $item->getShippingAddress };
    my $taxRate     = $self->getTaxRate( $sku, $address );

    my $quantity    = $item->get( 'quantity' );
    my $price       = $sku->getPrice;
    my $tax         = $price * $taxRate / 100;

    $var->{ taxRate                 } = $taxRate;
    $var->{ taxAmount               } = $item->cart->formatCurrency( $tax );
    $var->{ pricePlusTax            } = $item->cart->formatCurrency( $price + $tax );
    $var->{ extendedPricePlusTax    } = $item->cart->formatCurrency( $quantity * ( $price + $tax ) );
}

#-----------------------------------------------------------

=head2 canManage ( )

Returns true if the current user can manage taxes.

=cut

sub canManage {
    my $self    = shift;
    my $admin   = WebGUI::Shop::Admin->new( $self->session );

    return $admin->canManage;
}

#-----------------------------------------------------------

=head2 className {

Returns the class name of your plugin. You must overload this method in you own plugin.

=cut

sub className {
    my $self = shift;

    $self->session->log->fatal( "Tax plugin (".$self->className.") is required to overload the className method" );

    return 'WebGUI::Shop::TaxDriver';
}

#-----------------------------------------------------------

=head2 get ( [ property ] )

Returns the value of the requested configuration property. Returns a hash ref of all property/value pairs when no
specific property is passed.

=head3 property

The property whose value should be returned.

=cut

sub get {
    my $self    = shift;
    my $key     = shift;

    my $options = $options{ id $self };

    # Return safe copy of options hash if no key is passed.
    return { %{ $options } }  unless $key;

    # Return option if key is passed.
    return $options->{ $key } if exists $options->{ $key };

    # Key does not exist.
    $self->session->log->warn( "Non-existant option [$key] was queried by tax plugin $self" );
    return undef;
}

#-----------------------------------------------------------

=head2 getConfigurationScreen ( )

Returns the configuration screen that contains the configuration options for this plugin in the admin console.

=cut

sub getConfigurationScreen {
    return 'This plugin has no configuration options';
}

#-----------------------------------------------------------

=head2 getTaxRate ( sku, [ address ] )

Returns the tax rate in percents (eg. 19 for a rate of 19%) for the given sku and shipping address. Your tax driver
must overload this method.

Note that address is optional and that it's up to your plugin to handle that case.

=head3 sku

The sku for which the tax rate must be determined. Should be a WebGUI::Asset::Sku::* instance.

=head3 address

Optional, the shipping address for which to calculate the tax. Must be an instance of WebGUI::Shop::Address.

=cut

sub getTaxRate {
    my $self = shift;

    $self->session->log->fatal("Tax plugin ". $self->className ." is required to overload getTaxRate");
}

#-----------------------------------------------------------

=head2 getTransactionTaxData ( sku, address )

Returns a hashref containing tax information that should be stored along with transaction items.

=head3 sku

The sku belonging to the transaction item.

=head3 address

The address belonging to the transaction item.

=cut

sub getTransactionTaxData {
    my $self = shift;

    my $config = {
        className => $self->className,
    };

    return $config;
}

#-----------------------------------------------------------

=head2 getUserScreen ( )

Returns the screen for entering per user configuration for this tax driver.

=cut

sub getUserScreen {
    return 'There are no tax options to configure.';
}

#-----------------------------------------------------------

=head2 skuFormDefinition ( )

Returns a hash ref containing the form definition for the per sku options for this tax driver.

=cut

sub skuFormDefinition {
    return {};
}

#-------------------------------------------------------------------

=head2 new ( $session )

Constructor

=head3 session

Instanciated WebGUI::Session object.

=cut

sub new {
    my $class   = shift;
    my $session = shift;

    WebGUI::Error::InvalidObject->throw( expected => "WebGUI::Session", got => (ref $session), error => "Need a session." )
        unless $session && $session->isa( 'WebGUI::Session' );

    my $self    = {};
    bless $self, $class;
    register $self;

    my $id = id $self;
    $session{  $id } = $session;
    $messages{ $id } = [];

    # Load plugin configuration
    my $optionsJSON = $session->db->quickScalar( 'select options from taxDriver where className=?', [
        $self->className,
    ] );
    $options{  $id } = $optionsJSON ? from_json( $optionsJSON ) : {};

    return $self;
}

#-------------------------------------------------------------------

=head2 processSkuFormPost ( )

Processes the form parameters defined in the skuFormDefinition method and returns a hash ref containing the result.

=cut

sub processSkuFormPost {
    my $self            = shift;
    my $form            = $self->session->form;
    my $configuration   = {};

    my $definition  = $self->skuFormDefinition;

    foreach my $fieldName ( keys %{ $definition } ) {
        my ($fieldType, $defaultValue) = @{ $definition->{ $fieldName } }{ qw{ fieldType defaultValue } };

        $configuration->{ $fieldName } = $form->process( $fieldName, $fieldType, $defaultValue );
    }

    return $configuration;
}

#-----------------------------------------------------------

=head2 update ( properties )

Updates the properties of the tax driver according to those passed.

=head3 properties

Hash ref containing the properties to set.

=cut

sub update {
    my $self    = shift;
    my $update  = shift;
    my $db      = $self->session->db;

    # update local options hash
    $options{ id $self } = { %{ $options{ id $self } }, %{ $update } };

    # Persist to db
    $db->write( 'replace into taxDriver (className, options) values (?,?)', [
        $self->className,
        to_json( $options{ id $self } ),
    ] );
}

1;
