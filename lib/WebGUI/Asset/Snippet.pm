package WebGUI::Asset::Snippet;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Session;

our @ISA = qw(WebGUI::Asset);


=head1 NAME

Package WebGUI::Asset::Snippet

=head1 DESCRIPTION

Provides a mechanism to publish arbitrary code snippets to WebGUI for reuse in other pages. Can be used for things like HTML segments, javascript, and cascading style sheets.

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
                tableName=>'snippet',
                className=>'WebGUI::Asset::Snippet',
                properties=>{
                                snippet=>{
                                        fieldType=>'codearea',
                                        defaultValue=>undef
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
        $tabform->getTab("properties")->codearea(
                -name=>"snippet",
                -label=>WebGUI::International::get('snippet', 'Asset'),
                -label=>"Snippet",
                -value=>$self->getValue("snippet")
                );
	return $tabform;
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/snippet.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/snippet.gif';
}


#-------------------------------------------------------------------

=head2 getUiLevel ()

Returns the UI level of this asset.

=cut

sub getUiLevel {
	return 5;
}

#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
	return "Snippet";
} 


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $output = WebGUI::Macro::process($self->get("snippet"));
# if it's a javascript file this would break it
#	$output = '<p>'.$self->getToolbar.'</p>'.$output if ($session{var}{adminOn});
	return WebGUI::Asset::Template->processRaw($output);
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Snippet");
}

#-------------------------------------------------------------------

=head2 www_view

A web accessible version of the view method.

=cut

sub www_view {
	my $self = shift;
	return $self->view;
}


1;

