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

=head2 indexContent ( )

Adding sku as a keyword. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
    $indexer->addKeywords($self->get('sku'));
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

