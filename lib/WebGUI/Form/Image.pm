package WebGUI::Form::Image;

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
use base 'WebGUI::Form::File';
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Style;
use WebGUI::Form::YesNo;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::Image

=head1 DESCRIPTION

Creates a text input box form field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::File, and thereform WebGUI::Form::Image.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclasses for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

If no name is specified a default name of "image" will be used.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
			defaultValue=>WebGUI::International::get("image","WebGUI")
			},
		name=>{
			defaultValue=>"image"
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 displayForm ( )

If an image is uploaded, then return the image and a control to
delete it.  Otherwise, display a form element to upload a file.

=cut

sub displayForm {
	my ($self) = @_;
	return $self->toHtml unless $self->{value};
	##There are files inside here, for each one, display the image
	##and another form control for deleting it.
	my $location = WebGUI::Storage->get($self->{value});
	my $id = $location->getId;
	my $fileForm = '';
	my $file = shift @{ $location->getFiles };
	$fileForm .= sprintf qq!<img src="%s" /><br />!, $location->getUrl($file);
	$fileForm .= WebGUI::International::get(392)
		  .  "&nbsp"x4
		  . WebGUI::Form::YesNo->new({-name=>$self->privateName('delete'), -value=>0})->toHtml;
	$fileForm .= $self->toHtmlAsHidden();
	$fileForm .= WebGUI::Form::Hidden->new({-name => $self->privateName('action'), -value => 'keep'})->toHtml();
	return $fileForm;
}

#-------------------------------------------------------------------

=head2 displayValue ( )

This utility method is used to format values for the Profile system.  It
displays each image in the storage location that is the value of the
profile field.

=cut

sub displayValue {
	my ($self) = @_;
	return '' unless $self->{value};
	my $location = WebGUI::Storage->get($self->{value});
	my $file = shift @{ $location->getFiles };
	my $fileValue = sprintf qq!<img src="%s" />&nbsp;%s!, $location->getUrl($file), $file; 
	return $fileValue;
	}

1;
