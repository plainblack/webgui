package WebGUI::Asset::File::GalleryFile::Photo;

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
use base 'WebGUI::Asset::File::GalleryFile';

use Carp qw( carp croak );
use Image::ExifTool qw( :Public );
use JSON qw/ to_json from_json /;
use URI::Escape;
use Tie::IxHash;

use WebGUI::DateTime;
use WebGUI::Friends;
use WebGUI::Utility;
use WebGUI::Storage;


=head1 NAME

WebGUI::Asset::File::GalleryFile::Photo

=head1 DESCRIPTION


=head1 SYNOPSIS

use WebGUI::Asset::File::GalleryFile::Photo

=head1 DIAGNOSTICS

=head2 Geometry '...' is invalid. Skipping.

makeResolutions will not pass invalid geometries to WebGUI::Storage::resize().
Valid geometries are one of the following forms:

 ^\d+$
 ^\d*x\d*$

These geometries are exactly as understood by ImageMagick.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 definition ( session, definition )

Define the properties of the Photo asset.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session, 'Asset_Photo');

    tie my %properties, 'Tie::IxHash', (
        exifData => {
            defaultValue        => undef,
        },
        location    => {
            defaultValue        => undef,
        },
    );

    push @{$definition}, {
        assetName           => $i18n->get('assetName'),
        autoGenerateForms   => 0,
        icon                => 'photo.gif',
        tableName           => 'Photo',
        className           => 'WebGUI::Asset::File::GalleryFile::Photo',
        properties          => \%properties,
    };

    return $class->SUPER::definition($session, $definition);
}

#----------------------------------------------------------------------------

=head2 applyConstraints ( options )

Apply the constraints to the original file. Called automatically by C<setFile>
and C<processPropertiesFromFormPost>.

This is a sort of catch-all method for applying things to the file after it's
uploaded. This method simply calls other methods to do its work.

C<options> is a hash reference of options and is currently not used. 

=cut

sub applyConstraints {
    my $self        = shift;
    my $options     = shift;
    my $gallery     = $self->getGallery;
    
    # Update the asset's size and make a thumbnail
    my $maxImageSize    = $gallery->get("imageViewSize") 
                            || $self->session->setting->get("maxImageSize");
    my $storage         = $self->getStorageLocation;
    my $file            = $self->get("filename");

    # Adjust orientation based on exif data. Do this before we start to 
    # generate resolutions so that all images have the correct orientation.
    $self->adjustOrientation;
    
    # Make resolutions before fixing image, so that we can get higher quality 
    # resolutions
    $self->makeResolutions;

    # adjust density before size, so that the dimensions won't change
    $storage->resize( $file, undef, undef, $gallery->get( 'imageDensity' ) );
    $storage->adjustMaxImageSize($file, $maxImageSize);

    $self->generateThumbnail;        
    $self->updateExifDataFromFile;
    
    # setSize method is already called by WebGUI::Asset::File::applyConstraints (SUPER)
    # $self->setSize;
    
    $self->SUPER::applyConstraints( $options );
}

#----------------------------------------------------------------------------

=head2 adjustOrientation ( )

Read orientation information from EXIF data and rotate image if required.
EXIF data is updated to reflect the new orientation of the image.

=cut

sub adjustOrientation {    
    my $self    = shift;
    my $storage = $self->getStorageLocation;
    
    # Extract orientation information from EXIF data
    my $exifTool = Image::ExifTool->new;
    $exifTool->ExtractInfo( $storage->getPath( $self->get('filename') ) );    
    my $orientation = $exifTool->GetValue('Orientation', 'ValueConv');

    # Check whether orientation information is present and transform image if
    # required. At the moment we handle only images that need to be rotated by 
    # (-)90 or 180 deg. Flipping of images is not supported yet.
    if ( $orientation ) {

        # We are going to update orientation information before the image is
        # rotated. Otherwise we would have to re-extract EXIF data due to 
        # manipulation by Image Magick.

        # Update orientation information
        $exifTool->SetNewValue( 'Exif:Orientation' => 1, Type => 'ValueConv');
        
        # Set the following options to make this as robust as possible
        $exifTool->Options( 'IgnoreMinorErrors', FixBase => '' );
        # Write updated exif data to disk
        $exifTool->WriteInfo( $storage->getPath( $self->get('filename') ) );
        
        # Log any errors
        my $error = $exifTool->GetValue('Error');
        $self->session->log->error( "Error on updating exif data: $error" ) if $error;       
        
        # Image rotated by 180°
        if ( $orientation == 3 || $orientation == 4 ) {
            $self->rotate(180);
        }
        # Image rotated by 90° CCW
        elsif ( $orientation == 5 || $orientation == 6 ) {            
            $self->rotate(90);
        }
        # Image rotated by 90° CW
        elsif ( $orientation == 7 || $orientation == 8 ) {
            $self->rotate(-90);
        }
    }    
}

#-------------------------------------------------------------------

=head2 generateThumbnail ( ) 

Generates a thumbnail for this image.

=cut

sub generateThumbnail {
    my $self        = shift;
    $self->getStorageLocation->generateThumbnail(
        $self->get("filename"),
        $self->getGallery->get("imageThumbnailSize"),
    );
    return;
}

#----------------------------------------------------------------------------

=head2 getDownloadFileUrl ( resolution )

Get the absolute URL to download the requested resolution. Will croak if the
resolution doesn't exist.

=cut

sub getDownloadFileUrl {
    my $self        = shift;
    my $resolution  = shift;

    croak "Photo->getDownloadFileUrl: resolution must be defined"
        unless $resolution;
    croak "Photo->getDownloadFileUrl: resolution doesn't exist for this Photo"
        unless grep /$resolution/, @{ $self->getResolutions };

    return $self->getStorageLocation->getUrl( $resolution . ".jpg" );
}

#----------------------------------------------------------------------------

=head2 getEditFormUploadControl

Returns the HTML to display the current photo, if it has one, and a file chooser
to either upload one, or replace the current one.  Subclasses the master class
to change i18n labels.

=cut

sub getEditFormUploadControl {
    my $self        = shift;
    my $session     = $self->session;
    my $i18n        = WebGUI::International->new($session, 'Asset_File');
    my $html        = '';

    if ($self->get("filename") ne "") {
        $html .= WebGUI::Form::readOnly( $session, {
            value       => '<p style="display:inline;vertical-align:middle;"><a href="'.$self->getFileUrl.'"><img src="'.$self->getThumbnailUrl.'" alt="'.$self->get("filename").'" style="border-style:none;vertical-align:middle;" /> '.$self->get("filename").'</a></p>'
        });
    }

    # Control to upload a new file
    $html .= WebGUI::Form::image( $session, {
        name            => 'newFile',
        label           => $i18n->get('new file'),
        hoverHelp       => $i18n->get('new file description'),
        forceImageOnly  => 1,
    });

    return $html;
}


#----------------------------------------------------------------------------

=head2 getExifData ( )

Gets a hash reference of Exif data about this Photo.

=cut

sub getExifData {
    my $self        = shift;

    return unless $self->get('exifData');    

    # Our processing and eliminating of bad / unparsable keys
    # isn't perfect, so handle errors gracefully
    my $exif    = eval { from_json( $self->get('exifData') ) };
    if ( $@ ) {
        $self->session->errorHandler->warn( 
            "Could not parse JSON data for EXIF in Photo '" . $self->get('title') 
            . "' (" . $self->getId . "): " . $@
        );
        return;
    }
    
    return $exif;
}

#----------------------------------------------------------------------------

=head2 getResolutions ( )

Get an array reference of download resolutions that exist for this image. 
Does not include the web view image or the thumbnail images.

=cut

sub getResolutions {
    my $self        = shift;
    my $storage     = $self->getStorageLocation;

    # Return a list not including the web view image.
    return [ sort { $a cmp $b } grep { $_ ne $self->get("filename") } @{ $storage->getFiles } ];
}

#----------------------------------------------------------------------------

=head2 getStorageClass ( )

Get the WebGUI::Storage subclass name for this file. This file uses the
Image class.

=cut

sub getStorageClass {
    return 'WebGUI::Storage';
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Get a hash reference of template variables shared by all views of this asset.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $session     = $self->session;
    my $var         = $self->SUPER::getTemplateVars;

    ### Download resolutions
    for my $resolution ( @{ $self->getResolutions } ) {
        my $label       = $resolution;
        $label          =~ s/\.[^.]+$//;
        my $downloadUrl = $self->getStorageLocation->getUrl( $resolution );
        push @{ $var->{ resolutions_loop } }, { 
            resolution      => $label,
            url_download    => $downloadUrl,
        };
        $var->{ "resolution_" . $resolution } = $downloadUrl;
    }

    ### Format exif vars
    my $exif        = $self->getExifData;
    for my $tag ( keys %$exif ) {
        # Hash of exif_tag => value
        $var->{ "exif_" . $tag } = $exif->{$tag};

        # Loop of tag => "...", value => "..."
        push @{ $var->{exifLoop} }, { tag => $tag, value => $exif->{$tag} };
    }

    return $var;
}

#----------------------------------------------------------------------------

=head2 getThumbnailUrl ( )

Get the URL to the thumbnail for this Photo.

=cut

sub getThumbnailUrl {
    my $self = shift;
    return $self->getStorageLocation->getThumbnailUrl(
        $self->get("filename")
    );
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Indexing the content of the Photo. See WebGUI::Asset::indexContent() for 
additonal details. 

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addKeywords($self->get("location"));
	return $indexer;
}

#----------------------------------------------------------------------------

=head2 makeResolutions ( [resolutions] )

Create the specified resolutions for this Photo. If resolutions is not 
defined, will get the resolutions to make from the Gallery this Photo is 
contained in.

=cut

sub makeResolutions {
    my $self        = shift;
    my $resolutions = shift;
    my $session     = $self->session;
    my $error;

    croak "Photo->makeResolutions: resolutions must be an array reference"
        if $resolutions && ref $resolutions ne "ARRAY";
    
#    # Return immediately if no image is available
#    if ( $self->get("filename") eq '' )
#    {
#        $session->log->error("makeResolutions skipped since no image available");
#        return;
#    }        
    
    # Get default if necessary
    $resolutions    ||= $self->getGallery->getImageResolutions;
    
    my $storage     = $self->getStorageLocation;
    $self->session->errorHandler->info(" Making resolutions for '" . $self->get("filename") . q{'});

    for my $res ( @$resolutions ) {
        # carp if resolution is bad
        if ( $res !~ /^\d+$/ && $res !~ /^\d*x\d*/ ) {
            carp "Geometry '$res' is invalid. Skipping.";
            next;
        }
        my $newFilename     = $res . ".jpg";
        $storage->copyFile( $self->get("filename"), $newFilename );
        $storage->resize( $newFilename, $res, undef, $self->getGallery->get( 'imageDensity' ) );
    }
}

#----------------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Process the asset edit form. 

Make the default title into the file name minus the extention.

=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    my $i18n    = WebGUI::International->new( $self->session,'Asset_Photo' );
    my $form    = $self->session->form;
    my $errors  = $self->SUPER::processPropertiesFromFormPost || [];

    # Make sure there is an image file attached to this asset.
    if ( !$self->get('filename') ) {
        push @{ $errors }, $i18n->get('error no image');
    }

    # Return if errors
    return $errors if @$errors;
    
    ### Passes all checks
    
    # If no title was given, make it the file name
    if ( !$form->get('title') ) {
        my $title   = $self->get('filename');
        $title  =~ s/\.[^.]*$//;
        $title  =~ tr/-/ /; # De-mangle the spaces at the expense of the dashes
        $self->update( {
            title       => $title,
            menuTitle   => $title,
        } );

        # If this is a new Photo, change some other things too
        if ( $form->get('assetId') eq "new" ) {
            $self->update( {
                url         => $self->session->url->urlize( join "/", $self->getParent->get('url'), $title ),
            } );
        }
    }

    return undef;
}


#----------------------------------------------------------------------------

=head2 rotate ( angle )

Rotate the photo clockwise by the specified C<angle> (in degrees) including the
thumbnail and all resolutions.

=cut

sub rotate {
    my $self    = shift;
    my $angle   = shift;
    my $storage = $self->getStorageLocation;
    
    # Rotate all files in the storage
    foreach my $file (@{$storage->getFiles}) {
        $storage->rotate($file, $angle);
    }
    # Re-create thumbnail
    $self->generateThumbnail;
}

#----------------------------------------------------------------------------

=head2 setFile ( filename )

Extend the superclass setFile to automatically generate thumbnails.

=cut

sub setFile {
    my $self    = shift;
    $self->SUPER::setFile(@_);
    $self->generateThumbnail;
}

#----------------------------------------------------------------------------

=head2 updateExifDataFromFile ( )

Gets the EXIF data from the uploaded image and store it in the database.

=cut

sub updateExifDataFromFile {
    my $self        = shift;
    my $storage     = $self->getStorageLocation;
    
    my $exifTool    = Image::ExifTool->new;
    $exifTool->Options( PrintConv => 1 );
    my $info        = $exifTool->ImageInfo( $storage->getPath( $self->get('filename') ) );
    
    # Sanitize Exif data by removing keys with references as values
    for my $key ( keys %$info ) {
        if ( ref $info->{$key} ) {
            delete $info->{$key};
        }
    }

    # Remove other, pointless, possibly harmful keys
    for my $key ( qw( Directory NativeDigest CameraID CameraType ) ) {
        delete $info->{ $key };
    }

    $self->update({
        exifData    => to_json( $info ),
    });
}

#----------------------------------------------------------------------------

=head2 www_download

Download the Photo with the specified resolution. If no resolution specified,
download the original file.

=cut

sub www_download {
    my $self        = shift;
    
    return $self->session->privilege->insufficient unless $self->canView;
    
    my $storage     = $self->getStorageLocation;

    $self->session->http->setMimeType( "image/jpeg" );
    $self->session->http->setLastModified( $self->getContentLastModified );

    my $resolution  = $self->session->form->get("resolution");
    if ($resolution) {
        return $storage->getFileContentsAsScalar( $resolution . ".jpg" ); 
    }
    else {
        return $storage->getFileContentsAsScalar( $self->get("filename") );
    }
}

#----------------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page

This page is only available to those who can edit this Photo.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;

    return $session->privilege->insufficient  unless $self->canEdit;
    return $session->privilege->locked        unless $self->canEditIfLocked;

    my $i18n = WebGUI::International->new($session, 'WebGUI');

    # Prepare the template variables
    # Cannot get all template vars since they require a storage location, doesn't work for
    # creating new assets.
    #my $var     = $self->getTemplateVars; 
    my $var     = {
        url_addArchive      => $self->getParent->getUrl('func=addArchive'),
        url_album           => $self->getParent->getUrl('func=album'),
    };
    
    # Process errors if any
    if ( $session->stow->get( 'editFormErrors' ) ) {
        for my $error ( @{ $session->stow->get( 'editFormErrors' ) } ) {
            push @{ $var->{ errors } }, {
                error       => $error,
            };
        }
    }

    if ( $form->get('func') eq "add" ) {
        $var->{ isNewPhoto }    = 1;
    }
    
    # Generate the form
    if ($form->get("func") eq "add") {
        $var->{ form_start  } 
            = WebGUI::Form::formHeader( $session, {
                action      => $self->getParent->getUrl('func=editSave;assetId=new;class='.__PACKAGE__),
                extras      => 'name="photoAdd"',
            })
            . WebGUI::Form::hidden( $session, {
                name        => 'ownerUserId',
                value       => $session->user->userId,
            })
            ;
    }
    else {
        $var->{ form_start  } 
            = WebGUI::Form::formHeader( $session, {
                action      => $self->getUrl('func=editSave'),
                extras      => 'name="photoEdit"',
            })
            . WebGUI::Form::hidden( $session, {
                name        => 'ownerUserId',
                value       => $self->get('ownerUserId'),
            })
            ;
    }
    $var->{ form_start } 
        .= WebGUI::Form::hidden( $session, {
            name        => "proceed",
            value       => $form->get('proceed') || "showConfirmation",
        });

    $var->{ form_end } = WebGUI::Form::formFooter( $session );
    
    $var->{ form_submit }
        = WebGUI::Form::submit( $session, {
            name        => "submit",
            value       => $i18n->get('save'),
        });

    $var->{ form_title  }
        = WebGUI::Form::Text( $session, {
            name        => "title",
            value       => ( $form->get("title") || $self->get("title") ),
        });
    
    $self->getGallery;

    $var->{ form_synopsis }
        = WebGUI::Form::HTMLArea( $session, {
            name        => "synopsis",
            value       => ( $form->get("synopsis") || $self->get("synopsis") ),
            richEditId  => $self->getGallery->get("richEditIdFile"),
        });

    $var->{ form_photo } = $self->getEditFormUploadControl;
    
    $var->{ form_keywords }
        = WebGUI::Form::Text( $session, {
            name        => "keywords",
            value       => ( $form->get("keywords") || $self->get("keywords") ),
        });

    $var->{ form_location }
        = WebGUI::Form::Text( $session, {
            name        => "location",
            value       => ( $form->get("location") || $self->get("location") ),
        });

    $var->{ form_friendsOnly }
        = WebGUI::Form::yesNo( $session, {
            name            => "friendsOnly",
            value           => ( $form->get("friendsOnly") || $self->get("friendsOnly") ),
            defaultValue    => undef,
        });


    return $self->processStyle(
        $self->processTemplate( $var, $self->getGallery->getTemplateIdEditFile )
    );
}

#----------------------------------------------------------------------------

=head2 www_showConfirmation ( ) 

Shows the confirmation message after adding / editing a gallery album. 
Provides links to view the photo and add more photos.

=cut

sub www_showConfirmation {
    my $self        = shift;
    my $i18n        = WebGUI::International->new( $self->session, 'Asset_Photo' );

    return $self->processStyle(
        sprintf( $i18n->get('save message'), 
            $self->getUrl, 
            $self->getParent->getUrl('func=add;class='.__PACKAGE__),
        )
    );
}

1;
