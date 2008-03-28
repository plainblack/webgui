package WebGUI::Form::Image;

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
use base 'WebGUI::Form::File';
use WebGUI::International;
use WebGUI::Storage::Image;
use WebGUI::Form::YesNo;
use WebGUI::Utility qw/isIn/;

=head1 NAME

Package WebGUI::Form::Image

=head1 DESCRIPTION

Creates a javascript driven file upload control for files or images.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::File.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclasses for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

If no name is specified a default name of "file" will be used.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=head4 forceImageOnly

When set, form control will not allow file uploads unless the file has recognized image file extension

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("image")
			},
		name=>{
			defaultValue=>"image"
			},
		profileEnabled=>{
			defaultValue=>1
			},
		forceImageOnly=>{
			defaultValue=>0
			},
        enforceSizeLimits => {
            defaultValue    => 1
        },
        dbDataType  => {
            defaultValue    => "VARCHAR(22) BINARY",
        },
    });
    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 displayForm ( )

If an image is uploaded, then return the image and a control to
delete it.  Otherwise, display a form element to upload a file.

=cut

sub displayForm {
	my ($self) = @_;
	return $self->toHtml unless $self->get('value');
	##There are files inside here, for each one, display the image
	##and another form control for deleting it.
	my $location = WebGUI::Storage::Image->get($self->session, $self->get('value'));
	my $i18n = WebGUI::International->new($self->session);
	my $fileForm = '';
	my $file = shift @{ $location->getFiles };
	$fileForm .= sprintf qq!<img src="%s" /><br />!, $location->getUrl($file);
	$fileForm .= $i18n->get(392)
		  .  "&nbsp"x4
		  . WebGUI::Form::YesNo->new($self->session, {-name=>$self->privateName('delete'), -value=>0})->toHtml;
	$fileForm .= $self->toHtmlAsHidden();
	$fileForm .= WebGUI::Form::Hidden->new($self->session, {-name => $self->privateName('action'), -value => 'keep'})->toHtml();
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
	return '' unless $self->get("value");
	my $location = WebGUI::Storage::Image->get($self->session,$self->get("value"));
	my $file = shift @{ $location->getFiles };
	my $fileValue = sprintf qq|<img src="%s" />&nbsp;%s|, $location->getUrl($file), $file; 
	return $fileValue;
}

#-------------------------------------------------------------------

=head2 getFilePreview ( storage )

Returns a preview of the files attached to this form control. 

=head3 storage

A WebGUI::Storage object.

=cut

sub getFilePreview {
    my $self = shift;
    my $storage = shift;
    my $preview = "";
	foreach my $file (@{$storage->getFiles}) {
		if ($self->get("deleteFileUrl")) {
			$preview .= '<p style="display:inline;vertical-align:middle;"><a href="'.$self->get("deleteFileUrl").$file.'">'
			    .'<img src="'.$self->session->icon->getBaseURL().'delete.gif" style="vertical-align:middle;border: 0px;" alt="x" /></a></p> ';
		}
		my $image = $storage->isImage($file) ? $storage->getThumbnailUrl($file) : $storage->getFileIconUrl($file);
		$preview .= '<p style="display:inline;vertical-align:middle;"><a href="'.$storage->getUrl($file).'">'
		    .'<img src="'.$image.'" style="vertical-align:middle;border: 0px;" alt="'
			.$file.'" /> '.$file.'</a></p><br />';
	}
    return $preview;
}

#-------------------------------------------------------------------

=head2 getStorageLocation ( )

Returns the WebGUI::Storage object for this control.

=cut

sub getStorageLocation {
    my $self = shift;
	my $storage = WebGUI::Storage::Image->get($self->session, $self->get("value")) if ($self->get("value"));
    return $storage;
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

See WebGUI::Form::File::getValueFromPost() for details. Generates a thumbnail.

=cut

sub getValueFromPost {
	my $self = shift;
	my $id = $self->SUPER::getValueFromPost(@_);
	if (defined $id) {
		my $storage = WebGUI::Storage::Image->get($self->session, $id);
		if (defined $storage) {
			my @files = @{$storage->getFiles};
			my @images = grep{$storage->isImage($_)} @files; # Put all filenames that isImage returns true for into @images
			if ($self->get('forceImageOnly')) {
				$storage->deleteFile($_) for grep{!isIn($_, @images)} @files; # Search @files for filenames that are not in @images and delete them
				@files = @images;
			}

			return undef unless @files;
            for my $image (@images) {
                $storage->generateThumbnail($image); # Make a thumbnail for each file
                if ($self->get('enforceSizeLimits')) {
                    $storage->adjustMaxImageSize($image);
                }
            }
		}
	}
	return $id;
}


1;
