package WebGUI::Asset::Sku;

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
use base 'WebGUI::Asset';
use WebGUI::Utility;



=head1 NAME

Package WebGUI::Asset::Sku

=head1 DESCRIPTION

This is the base class for all products in the commerce system.

=head1 SYNOPSIS

use WebGUI::Asset::Sku;

 $self = WebGUI::Asset::Sku->newBySku($session, $sku);

 $self->addToCart;
 $self->applyOptions;
 $hashRef = $self->getOptions;
 $integer = $self->getMaxAllowedInCart;
 $float = $self->getPrice;
 $float = $self->getTaxRate;
 $boolean = $self->isShippingRequired;
 $html = $self->processStyle($output);

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 definition ( session, definition )

See super class.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session, "Asset_NewAsset");
	%properties = (
		templateId => {
			# Determines which tab this property appears in
			tab=>"display",
			#See the list of field/control types in /lib/WebGUI/Form/
			fieldType=>"template",  
			defaultValue=>'NewAssetTmpl0000000001',
			#www_editSave will ignore anyone's attempts to update this field if this is set to 1
			noFormPost=>0,  
			#This is an option specific to the template fieldType.
			namespace=>"NewAsset", 
			#This is what will appear when the user hovers the mouse over the label 
			# of your form field.
			hoverHelp=>$i18n->get('templateId label description'),
			# This is the text that will appear to the left of your form field.
			label=>$i18n->get('templateId label')
			},
		foo => {
			tab=>"properties",
			fieldType=>"text",
			defaultValue=>undef,
			label=>$i18n->get("foo label"),
			hoverHelp=>$i18n->get("foo label help")
			}
	);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'NewAsset.gif',
		autoGenerateForms=>1,
		tableName=>'NewAsset',
		className=>'WebGUI::Asset::NewAsset',
		properties=>\%properties
	});
	return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 applyOptions ( options )

Accepts a configuration data hash reference that configures a sku a certain way. For example to turn "a t-shirt" into "an XL red t-shirt". See also getOptions().

=head3 options

A hash reference containing the sku options.

=cut

sub applyOptions {
    my ($self, $options) = @_;
    $self->{_skuOptions} = $options;
}

#-------------------------------------------------------------------

=head2 getOptions ( )

Returns a hash reference of configuration data that can return this sku to a configured state. See applyOptions() for details.

=cut

sub getOptions {
    my $self = shift;
    return $self->{_skuOptions};
}

#-------------------------------------------------------------------

=head2 getMaxAllowedInCart ( )

Returns 99999999. Should be overriden by subclasses that have a specific value. Subclasses that are unique should return 1. Subclasses that have an inventory count should return the amount in inventory.

=cut

sub getMaxAllowedInCart {
    return 99999999;
}

#-------------------------------------------------------------------

=head2 getPrice ( )

Returns 0.00. Needs to be overriden by subclasses.

=cut

sub getPrice {
    return 0.00;
}

#-------------------------------------------------------------------

=head2 getTaxRate ( )

Returns undef unless the "Override tax rate?" switch is set to yes. If it is, then it returns the value of the "Tax Rate Override" field.

=cut

sub getTaxRate {
    my $self = shift;
    return ($self->get("overrideTaxRate")) ? $self->get("taxRateOverride") : undef;
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Adding sku as a keyword. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
    $indexer->addKeywords($self->get('sku'));
}


#-------------------------------------------------------------------

=head2 isShippingRequired

Returns a boolean indicating whether shipping is required. Defaultly returns 0. Needs to be overriden by subclasses that use shipping.

=cut

sub isShippingRequired {
    return 0;
}


#-------------------------------------------------------------------

=head2 newBySku ( session, sku )

Returns a sku subclass based upon a sku lookup.

=head3 session

A reference to the current session.

=head3 sku

The sku attached to the object you wish to instanciate.

=cut

sub newBySku {
    my ($class, $session, $sku) = @_;
    my $assetId = $session->db->quickScalar("select assetId from Sku where sku=?", [$sku]);
    return WebGUI::Asset->newByDynamicClass($session, $assetId); 
}


#-------------------------------------------------------------------

=head2 processStyle ( output )

Returns output parsed under the current style.

=head3 output

An HTML blob to be parsed into the current style.

=cut

sub processStyle {
	my $self = shift;
	my $output = shift;
	return $self->getParent->processStyle($output);
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page

=cut

sub www_edit {
   my $self = shift;
   return $self->session->privilege->insufficient() unless $self->canEdit;
   return $self->session->privilege->locked() unless $self->canEditIfLocked;
   return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('edit asset',"Asset_NewAsset"));
}

#-------------------------------------------------------------------

=head2 www_view (  )

Renders self->view based upon current style, subject to timeouts. Returns Privilege::noAccess() if canView is False.

=cut

sub www_view {
	my $self = shift;
	my $check = $self->checkView;
	return $check if (defined $check);
	$self->session->http->setLastModified($self->getContentLastModified);
	$self->session->http->sendHeader;
	$self->prepareView;
	my $style = $self->processStyle("~~~");
	my ($head, $foot) = split("~~~",$style);
	$self->session->output->print($head, 1);
	$self->session->output->print($self->view);
	$self->session->output->print($foot, 1);
	return "chunked";
}

