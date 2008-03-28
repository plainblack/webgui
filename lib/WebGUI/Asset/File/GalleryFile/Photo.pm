package WebGUI::Asset::File::GalleryFile::Photo;

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
use base 'WebGUI::Asset::File::GalleryFile';

use Carp qw( carp croak );
use Image::ExifTool qw( :Public );
use JSON qw/ to_json from_json /;
use URI::Escape;
use Tie::IxHash;

use WebGUI::DateTime;
use WebGUI::Friends;
use WebGUI::Utility;
use WebGUI::Storage::Image;


=head1 NAME

WebGUI::Asset::File::GalleryFile::Photo

=head1 DESCRIPTION


=head1 SYNOPSIS

use WebGUI::Asset::File::GalleryFile::Photo

=head1 DIAGNOSTICS

=head2 Geometry '...' is invalid. Skipping.

makeResolutions will not pass invalid geometries to WebGUI::Storage::Image::resize().
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
    my $i18n        = __PACKAGE__->i18n($session);

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
    my $gallery     = $self->getGallery;
    
    # Update the asset's size and make a thumbnail
    my $maxImageSize    = $self->getGallery->get("imageViewSize") 
                        || $self->session->setting->get("maxImageSize");
    my $thumbnailSize   = $self->getGallery->get("imageThumbnailSize")
                        || $self->session->setting->get("thumbnailSize");
    my $parameters      = $self->get("parameters");
    my $storage         = $self->getStorageLocation;
    my $file            = $self->get("filename");
    $storage->adjustMaxImageSize($file, $maxImageSize);
    $self->generateThumbnail;
    $self->setSize;
    $self->makeResolutions;
    $self->updateExifDataFromFile;
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

=head2 getExifData ( )

Gets a hash reference of Exif data about this Photo.

=cut

sub getExifData {
    my $self        = shift;

    return unless $self->get('exifData');    
    return from_json( $self->get('exifData') );
}

#----------------------------------------------------------------------------

=head2 getResolutions ( )

Get an array reference of download resolutions that exist for this image. 
Does not include the web view image or the thumbnail image.

=cut

sub getResolutions {
    my $self        = shift;
    my $storage     = $self->getStorageLocation;

    # Return a list not including the web view image.
    return [ grep { $_ ne $self->get("filename") } @{ $storage->getFiles } ];
}

#----------------------------------------------------------------------------

=head2 getStorageClass ( )

Get the WebGUI::Storage subclass name for this file. This file uses the
Image class.

=cut

sub getStorageClass {
    return 'WebGUI::Storage::Image';
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
        push @{ $var->{ resolutions_loop } }, { 
            url_download => $self->getStorageLocation->getPathFrag($resolution) 
        };
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

#----------------------------------------------------------------------------

=head2 i18n ( [ session ] )

Get a WebGUI::International object for this class. 

Can be called as a class method, in which case a WebGUI::Session object
must be passed in.

NOTE: This method can NOT be inherited, due to a current limitation 
in the i18n system. You must ALWAYS call this with C<__PACKAGE__>

=cut

sub i18n {
    my $self    = shift;
    my $session = shift;
    
    return WebGUI::International->new($session, "Asset_Photo");
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
    my $error;

    croak "Photo->makeResolutions: resolutions must be an array reference"
        if $resolutions && ref $resolutions ne "ARRAY";
    
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
        $storage->resize( $newFilename, $res );
    }
}

#----------------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Process the asset edit form. 

Make the default title into the file name minus the extention.

=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    my $form    = $self->session->form;
    my $errors  = $self->SUPER::processPropertiesFromFormPost || [];

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

    # Remove other, pointless keys
    for my $key ( qw( directory ) ) {
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
    my $form    = $self->session->form;

    return $self->session->privilege->insufficient  unless $self->canEdit;
    return $self->session->privilege->locked        unless $self->canEditIfLocked;

    # Prepare the template variables
    # Cannot get all template vars since they require a storage location, doesn't work for
    # creating new assets.
    #my $var     = $self->getTemplateVars; 
    my $var     = {
        url_addArchive      => $self->getParent->getUrl('func=addArchive'),
    };

    if ( $form->get('func') eq "add" ) {
        $var->{ isNewPhoto }    = 1;
    }
    
    # Generate the form
    if ($form->get("func") eq "add") {
        $var->{ form_start  } 
            = WebGUI::Form::formHeader( $session, {
                action      => $self->getParent->getUrl('func=editSave;assetId=new;class='.__PACKAGE__),
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
            value       => "showConfirmation",
        });

    $var->{ form_end } = WebGUI::Form::formFooter( $session );
    
    $var->{ form_submit }
        = WebGUI::Form::submit( $session, {
            name        => "submit",
            value       => "Save",
        });

    $var->{ form_title  }
        = WebGUI::Form::Text( $session, {
            name        => "title",
            value       => ( $form->get("title") || $self->get("title") ),
        });

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
    my $i18n        = __PACKAGE__->i18n( $self->session );

    return $self->processStyle(
        sprintf( $i18n->get('save message'), 
            $self->getUrl, 
            $self->getParent->getUrl('func=add;className='.__PACKAGE__),
        )
    );
}

1;
