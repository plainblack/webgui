package WebGUI::Asset::Snippet;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Macro;
use WebGUI::HTTP;
use WebGUI::Session;

our @ISA = qw(WebGUI::Asset);


=head1 NAME

Package WebGUI::Asset::Snippet

=head1 DESCRIPTION

Provides a mechanism to publish arbitrary code snippets to WebGUI for reuse in other pages. Can be used for things like HTML segments, javascript, and cascading style sheets. You can also specify the MIME type of the snippet, allowing you to serve XML, CSS and other text files directly from the WebGUI asset system and have browsers recognize them correctly.

=head1 SYNOPSIS

use WebGUI::Asset::Snippet;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_Snippet"),
		uiLevel => 5,
		icon=>'snippet.gif',
                tableName=>'snippet',
                className=>'WebGUI::Asset::Snippet',
                properties=>{
 			snippet=>{
                        	fieldType=>'codearea',
                                defaultValue=>undef
                                },
 			processAsTemplate=>{
                        	fieldType=>'yesNo',
                                defaultValue=>0
                                },
			mimeType=>{
                        	fieldType=>'text',
                                defaultValue=>'text/html'
                                }

                        }
                });
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my %mimeTypes;
	foreach ('text/html','text/css','text/javascript','text/plain','text/xml','application/xml') {
	    $mimeTypes{$_}=$_;
	} 
        $tabform->getTab("properties")->codearea(
                -name=>"snippet",
                -label=>WebGUI::International::get('assetName', 'Asset_Snippet'),
                -hoverHelp=>WebGUI::International::get('snippet description', 'Asset_Snippet'),
                -value=>$self->getValue("snippet")
                );
        $tabform->getTab("properties")->yesNo(
                -name=>"processAsTemplate",
                -label=>WebGUI::International::get('process as template', 'Asset_Snippet'),
                -hoverHelp=>WebGUI::International::get('process as template description', 'Asset_Snippet'),
                -value=>$self->getValue("processAsTemplate")
                );
        $tabform->getTab("properties")->combo(
                -name=>"mimeType",
                -label=>WebGUI::International::get('mimeType', 'Asset_Snippet'),
                -hoverHelp=>WebGUI::International::get('mimeType description', 'Asset_Snippet'),
                -value=>[$self->getValue('mimeType')],
		-options=>\%mimeTypes
                );

	return $tabform;
}



#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	return undef if ($self->getToolbarState);
	return $self->SUPER::getToolbar();
}




#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $calledAsWebMethod = shift;
	my $output = $self->get("snippet");
	WebGUI::Macro::process($self->session,\$output);
	$output = '<p>'.$self->getToolbar.'</p>'.$output if ($self->session->var->get("adminOn") && !$calledAsWebMethod);
	return $output unless ($self->getValue("processAsTemplate")); 
	return WebGUI::Asset::Template->processRaw($output);
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        $self->getAdminConsole->setHelp("snippet add/edit","Asset_Snippet");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('snippet add/edit title',"Asset_Snippet"));
}

#-------------------------------------------------------------------

=head2 www_view

A web accessible version of the view method.

=cut

sub www_view {
	my $self = shift;
	my $mimeType=$self->getValue('mimeType');
	WebGUI::HTTP::setMimeType($mimeType || 'text/html');
	return $self->view(1);
}


1;

