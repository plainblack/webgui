package WebGUI::Form::Image;

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

use strict;
use base 'WebGUI::Form::File';
use WebGUI::International;
use WebGUI::Storage;
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

=head4 forceImageOnly

When set, form control will not allow file uploads unless the file has recognized image file extension

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		name=>{
			defaultValue=>"image"
			},
		forceImageOnly=>{
			defaultValue=>0
			},
        enforceSizeLimits => {
            defaultValue    => 1
        },
    });
    return $class->SUPER::definition($session, $definition);
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
	my $i18n = WebGUI::International->new($self->session);
	foreach my $file (@{$storage->getFiles}) {
		if ($self->get("deleteFileUrl")) {
			$preview .= '<p style="display:inline;vertical-align:middle;"><a href="'.$self->get("deleteFileUrl").$file.'">'
			    .'<img src="'.$self->session->icon->getBaseURL().'delete.gif" style="vertical-align:middle;border: 0px;" alt="x" /></a></p> ';
		}
		my $image = $storage->isImage($file) ? $storage->getThumbnailUrl($file) : $storage->getFileIconUrl($file);
		$preview .= '<p style="display:inline;vertical-align:middle;"><a href="'.$storage->getUrl($file).'">'
		    .'<img src="'.$image.'" style="vertical-align:middle;border: 0px;" alt="'
			.$file.'" /> '.$file.'</a> <br />';
	    $preview .= $i18n->get(392) .  "&nbsp"x4 . WebGUI::Form::YesNo->new($self->session, {-name=>$self->privateName('delete_'.$file), -value=>0})->toHtml;
		$preview .= '</p><br /><br />'
	}
    return $preview;
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('image');
}

#-------------------------------------------------------------------

=head2 getValue ( )

See WebGUI::Form::File::getValue() for details. Generates a thumbnail.  If forceImageOnly is
set, removes all images from the storage location that are not images, according Storage.pm.

=cut

sub getValue {
	my $self = shift;
	my $id = $self->SUPER::getValue(@_);
	if (defined $id) {
		my $storage = WebGUI::Storage->get($self->session, $id);
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

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Displays the image using an img tag.

=cut

sub getValueAsHtml {
	my ($self) = @_;
    my $value = $self->getOriginalValue;
	return '' unless $value;
	my $location = WebGUI::Storage->get($self->session, $value);
	my $file = shift @{ $location->getFiles };
	my $fileValue = sprintf qq|<img src="%s" />&nbsp;%s|, $location->getUrl($file), $file; 
	return $fileValue;
}


#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

1;
