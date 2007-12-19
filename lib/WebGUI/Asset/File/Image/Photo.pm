package WebGUI::Asset::File::Image::Photo;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Asset::File::Image';

use Carp qw( croak );
use Image::ExifTool qw( :Public );
use JSON;
use Tie::IxHash;

use WebGUI::DateTime;
use WebGUI::Friends;
use WebGUI::Utility;


=head1 NAME

WebGUI::Asset::File::Image::Photo

=head1 DESCRIPTION


=head1 SYNOPSIS

use WebGUI::Asset::File::Image::Photo

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
        friendsOnly => {
            defaultValue        => 0,
        },
        location    => {
            defaultValue        => undef,
        },
        rating  => {
            defaultValue        => 0,
        },
    );

    # UserDefined Fields
    for my $i (1 .. 5) {
        $properties{"userDefined".$i} = {
            defaultValue        => undef,
        };
    }

    push @{$definition}, {
        assetName           => $i18n->get('assetName'),
        autoGenerateForms   => 0,
        icon                => 'Image.gif',
        tableName           => 'Photo',
        className           => 'WebGUI::Asset::File::Image::Photo',
        i18n                => 'Asset_Photo',
        properties          => \%properties,
    };

    return $class->SUPER::definition($session, $definition);
}

#----------------------------------------------------------------------------

=head2 appendTemplateVarsForCommentForm ( var ) 

Add the template variables necessary for the comment form to the given hash
reference. Returns the hash reference for convenience.

=cut

sub appendTemplateVarsForCommentForm {
    my $self        = shift;
    my $var         = shift;
    my $session     = $self->session;

    $var->{ commentForm_start }
        = WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { name => "func", value => "addCommentSave" } )
        ;
    $var->{ commentForm_end }
        = WebGUI::Form::formFooter( $session );

    $var->{ commentForm_bodyText }
        = WebGUI::Form::HTMLArea( $session, {
            name        => "bodyText",
            richEditId  => $self->getGallery->get("richEditIdComment"),
        });

    $var->{ commentForm_submit } 
        = WebGUI::Form::submit( $session, {
            name        => "submit",
            value       => "Save Comment",
        });

    return $var;
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
    $self->SUPER::applyConstraints({
        maxImageSize        => $self->getGallery->get("imageViewSize"),
        thumbnailSize       => $self->getGallery->get("imageThumbnailSize"),
    });

    $self->makeResolutions();
    $self->updateExifDataFromFile();
}

#----------------------------------------------------------------------------

=head2 canAdd ( )

Override canAdd to ignore its permissions check. Permissions are handled
by the parent Gallery and other permissions methods.

=cut

sub canAdd {
    return 1;
}

#----------------------------------------------------------------------------

=head2 canComment ( [userId] )

Returns true if the user can comment on this asset. C<userId> is a WebGUI 
user ID. If no userId is passed, check the current user.

Users can comment on this Photo if they are allowed to view and the album 
allows comments.

=cut

sub canComment {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    my $album       = $self->getParent;

    return 0 if !$self->canView($userId);

    return $album->canComment($userId);
}

#----------------------------------------------------------------------------

=head2 canEdit ( [userId] )

Returns true if the user can edit this asset. C<userId> is a WebGUI user ID. 
If no userId is passed, check the current user.

Users can edit this Photo if they are the owner or if they are able to edit
the parent Album asset.

=cut

sub canEdit {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    my $album       = $self->getParent;

    return 1 if $userId eq $self->get("ownerUserId");
    return $album->canEdit($userId);
}

#----------------------------------------------------------------------------

=head2 canView ( [userId] )

Returns true if the user can view this asset. C<userId> is a WebGUI user ID.
If no user is passed, checks the current user.

Users can view this photo if they can view the parent asset. If this is a
C<friendsOnly> photo, then they must also be in the owners friends list.

=cut

sub canView {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;

    my $album       = $self->getParent;
    return 0 unless $album->canView($userId);

    if ($self->isFriendsOnly) {
        return 0
            unless WebGUI::Friends->new($self->session, $self->get("ownerUserId"))->isFriend($userId);
    }

    # Passed all checks
    return 1;
}

#----------------------------------------------------------------------------

=head2 deleteComment ( commentId )

Delete a comment from this asset. C<id> is the ID of the comment to delete.

=cut

sub deleteComment {
    my $self        = shift;
    my $commentId   = shift;
    
    croak "Photo->deleteComment: No commentId specified."
        unless $commentId;

    return $self->session->db->write(
        "DELETE FROM Photo_comment WHERE assetId=? AND commentId=?",
        [$self->getId, $commentId],
    );
}

#----------------------------------------------------------------------------

=head2 getAutoCommitWorkflowId ( )

Returns the workflowId of the Gallery's approval workflow.

=cut

sub getAutoCommitWorkflowId {
    my $self        = shift;
    return $self->getGallery->get("workflowIdCommit");
}

#----------------------------------------------------------------------------

=head2 getComment ( commentId )

Get a comment from this asset. C<id> is the ID of the comment to get. Returns
a hash reference of comment information.

=cut

sub getComment {
    my $self        = shift;
    my $commentId   = shift;
    
    return $self->session->db->getRow(
        "Photo_comment", "commentId", $commentId,
    );
}

#----------------------------------------------------------------------------

=head2 getCommentIds ( )

Get an array reference of comment IDs for this Photo, in chronological order.

=cut

sub getCommentIds {
    my $self        = shift;
    
    return [ 
        $self->session->db->buildArray(
            "SELECT commentId FROM Photo_comment WHERE assetId=?",
            [$self->getId],
        ) 
    ];
}

#----------------------------------------------------------------------------

=head2 getCommentPaginator ( ) 

Get a WebGUI::Paginator for the comments for this Photo.

=cut

sub getCommentPaginator {
    my $self        = shift;
    my $session     = $self->session;
    
    my $p           = WebGUI::Paginator->new($session, $self->getUrl);
    $p->setDataByQuery(
        "SELECT * FROM Photo_comment WHERE assetId=? ORDER BY creationDate DESC",
        undef, undef,
        [$self->getId],
    );
    
    return $p;
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

    return $self->getStorageLocation->getFileUrl( $resolution . ".jpg" );
}

#----------------------------------------------------------------------------

=head2 getGallery ( )

Gets the Gallery asset this Photo is a member of. 

=cut

sub getGallery {
    my $self        = shift;
    my $gallery     = $self->getParent->getParent;
    return $gallery if $gallery->isa("WebGUI::Asset::Wobject::Gallery");
    return undef;
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
    return grep { $_ ne $self->get("filename") } @{ $storage->getFiles };
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Get a hash reference of template variables shared by all views of this asset.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $session     = $self->session;
    my $var         = $self->get;
    my $owner       = WebGUI::User->new( $session, $self->get("ownerUserId") );
    
    $var->{ canComment          } = $self->canComment;
    $var->{ canEdit             } = $self->canEdit;
    $var->{ numberOfComments    } = scalar @{ $self->getCommentIds };
    $var->{ ownerUsername       } = $owner->username;
    $var->{ url                 } = $self->getUrl;
    $var->{ url_delete          } = $self->getUrl('func=delete');
    $var->{ url_demote          } = $self->getUrl('func=demote');
    $var->{ url_edit            } = $self->getUrl('func=edit');
    $var->{ url_gallery         } = $self->getGallery->getUrl;
    $var->{ url_makeShortcut    } = $self->getUrl('func=makeShortcut');
    $var->{ url_listFilesForOwner } 
        = $self->getGallery->getUrl('func=listFilesForUser;userId=' . $self->get("ownerUserId"));
    $var->{ url_promote         } = $self->getUrl('func=promote');

    $var->{ fileUrl             } = $self->getFileUrl;
    $var->{ thumbnailUrl        } = $self->getThumbnailUrl;

    ### Download resolutions
    for my $resolution ( $self->getResolutions ) {
        push @{ $var->{ resolutions_loop } }, { 
            url_download => $self->getStorageLocation->getPathFrag($resolution) 
        };
    }

    ### Format exif vars
    my $exif        = jsonToObj( delete $var->{exifData} );
    $exif           = ImageInfo( $self->getStorageLocation->getPath( $self->get("filename") ) );
    for my $tag ( keys %$exif ) {
        # Hash of exif_tag => value
        $var->{ "exif_" . $tag } = $exif->{$tag};

        # Loop of tag => "...", value => "..."
        push @{ $var->{exifLoop} }, { tag => $tag, value => $exif->{$tag} };
    }

    return $var;
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

=head2 isFriendsOnly ( )

Returns true if this Photo is friends only. Returns false otherwise.

=cut

sub isFriendsOnly {
    my $self        = shift;
    return $self->get("friendsOnly");
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
        my $newFilename     = $res . ".jpg";
        $storage->copyFile( $self->get("filename"), $newFilename );
        $storage->resize( $newFilename, $res );
    }
}

#----------------------------------------------------------------------------

=head2 makeShortcut ( parentId [, overrides ] )

Make a shortcut to this asset under the specified parent, optionally adding 
the specified hash reference of C<overrides>.

Returns the created shortcut asset.

=cut

sub makeShortcut {
    my $self        = shift;
    my $parentId    = shift;
    my $overrides   = shift;
    my $session     = $self->session;

    croak "Photo->makeShortcut: parentId must be defined"
        unless $parentId;

    my $parent      = WebGUI::Asset->newByDynamicClass($session, $parentId)
                    || croak "Photo->makeShortcut: Could not instanciate asset '$parentId'";

    my $shortcut
        = $parent->addChild({ 
            className           => "WebGUI::Asset::Shortcut",
            shortcutToAssetId   => $self->getId,
        });
    
    if ($overrides) {
        $shortcut->setOverride( $overrides );
    }

    return $shortcut;
}

#----------------------------------------------------------------------------

=head2 prepareView ( )

Prepare the template to be used for the C<view> method.

=cut

sub prepareView {
    my $self        = shift;
    $self->SUPER::prepareView();

    my $template    
        = WebGUI::Asset::Template->new($self->session, $self->getGallery->get("templateIdViewFile"));
    $template->prepare;

    $self->{_viewTemplate}  = $template;
}

#----------------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )


=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    my $form    = $self->session->form;
    my $errors  = $self->SUPER::processPropertiesFromFormPost || [];

    # Return if errors
    return $errors if @$errors;
    
    ### Passes all checks
    # Fix if adding a new photo
    if ( $form->get("assetId") eq "new" ) {
        $self->update({
            ownerUserId         => $self->session->user->userId,
        });
    }


    $self->requestAutoCommit;
}

#----------------------------------------------------------------------------

=head2 processStyle ( html )

Returns the HTML from the Gallery's style.

=cut

sub processStyle {
    my $self        = shift;
    return $self->getGallery->processStyle( @_ );
}

#----------------------------------------------------------------------------

=head2 purge ( )

Purge the asset. Remove all comments on the photo.

=cut

sub purge {
    my $self        = shift;
    
    for my $commentId ( @{ $self->getCommentIds } ) {
        $self->deleteComment( $commentId );
    }

    return $self->SUPER::purge;
}

#----------------------------------------------------------------------------

=head2 setComment ( commentId, properties )

Set a comment. If C<commentId> is C<"new">, create a new comment. C<properties>
is a hash reference of comment information.

=cut

sub setComment {
    my $self        = shift;
    my $commentId   = shift;
    my $properties  = shift;

    croak "Photo->setComment: commentId must be defined"
        unless $commentId;
    croak "Photo->setComment: properties must be a hash reference"
        unless $properties && ref $properties eq "HASH";
    croak "Photo->setComment: properties must contain a bodyText key"
        unless $properties->{ bodyText };

    $properties->{ creationDate     } ||= WebGUI::DateTime->new($self->session, time)->toDatabase;
    $properties->{ assetId          } = $self->getId;

    $self->session->db->setRow( 
        "Photo_comment", "commentId", 
        { %$properties, commentId => $commentId }
    );
}

#----------------------------------------------------------------------------

=head2 updateExifDataFromFile ( )

Gets the EXIF data from the uploaded image and store it in the database.

=cut

sub updateExifDataFromFile {
    my $self        = shift;
    my $storage     = $self->getStorageLocation;
    
    return;
    my $info        = ImageInfo( $storage->getPath( $self->get('filename') ) );
    use Data::Dumper; $self->session->errorHandler->info( Dumper $info );
    $self->update({
        exifData    => objToJson( $info ),
    });
}

#----------------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;
    my $var     = $self->getTemplateVars;
    
    $self->appendTemplateVarsForCommentForm( $var ); 

    my $p       = $self->getCommentPaginator;
    for my $comment ( @{ $p->getPageData } ) {
        my $user        = WebGUI::User->new( $session, $comment->{userId} );
        $comment->{ username } = $user->username;
        
        my $dt          = WebGUI::DateTime->new( $session, $comment->{ creationDate } );
        $comment->{ creationDate } = $dt->toUserTimeZone;

        push @{ $var->{commentLoop} }, $comment;
    }
    $var->{ commentLoop_pageBar     } = $p->getBarAdvanced;

    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#----------------------------------------------------------------------------

=head2 www_addCommentSave ( )

Save a new comment to the Photo.

=cut

sub www_addCommentSave {
    my $self        = shift;
    my $session     = $self->session;
    
    return $session->privilege->insufficient unless $self->canComment;

    my $form        = $self->session->form;
    
    my $properties  = {
        assetId         => $self->getId,
        creationDate    => WebGUI::DateTime->new( $session, time )->toDatabase,
        userId          => $session->user->userId,
        visitorIp       => ( $session->user->userId eq "1" ? $session->env("REMOTE_ADDR") : undef ),
        bodyText        => $form->get("bodyText"),
    };

    $self->setComment( "new", $properties );

    return $self->www_view;
}

#----------------------------------------------------------------------------

=head2 www_delete ( )

Show the page to confirm the deletion of this Photo. Show a list of albums
this Photo exists in.

=cut

sub www_delete {
    my $self        = shift;
    my $session     = $self->session;
    
    return $self->session->privilege->insufficient unless $self->canEdit;

    my $var         = $self->getTemplateVars;
    $var->{ url_yes     } = $self->getUrl("func=deleteConfirm");

    # TODO Get albums with shortcuts to this asset

    return $self->processStyle(
        $self->processTemplate( $var, $self->getGallery->get("templateIdDeleteFile") )
    );
}

#----------------------------------------------------------------------------

=head2 www_deleteConfirm ( )

Confirm the deletion of this Photo. Show a message and a link back to the
album.

=cut

sub www_deleteConfirm {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    my $i18n        = __PACKAGE__->i18n( $self->session );

    $self->purge;

    return $self->processStyle(
        sprintf $i18n->get("delete message"), $self->getParent->getUrl,
    );
}

#----------------------------------------------------------------------------

=head2 www_demote

Override the default demote page to send the user back to the GalleryAlbum 
edit screen.

=cut

sub www_demote {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    $self->demote;
    
    return $self->session->asset( $self->getParent )->www_edit;
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
    my $var     = {
        url_addArchive          => $self->getParent->getUrl('func=addArchive'),    
    };
    
    # Generate the form
    if ($form->get("func") eq "add") {
        $var->{ form_start  } 
            = WebGUI::Form::formHeader( $session, {
                action      => $self->getParent->getUrl('func=editSave;assetId=new;class='.__PACKAGE__),
            });
    }
    else {
        $var->{ form_start  } 
            = WebGUI::Form::formHeader( $session, {
                action      => $self->getUrl('func=editSave'),
            });
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
            richEditId  => $self->getGallery->get("assetIdRichEditFile"),
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

=head2 www_editSave ( )

Save the edit form. Overridden to display a confirm message to the user.

=cut

sub www_editSave {
    my $self        = shift;
    $self->SUPER::www_editSave;

    my $i18n        = __PACKAGE__->i18n( $self->session );

    sprintf $i18n->get("save message"), $self->getUrl,
}

#----------------------------------------------------------------------------

=head2 www_makeShortcut ( )

Display the form to make a shortcut.

This page is only available to those who can edit this Photo.

=cut

sub www_makeShortcut {
    my $self        = shift;
    my $session     = $self->session;
    
    return $self->session->privilege->insufficient  unless $self->canEdit;

    # Create the form to make a shortcut
    my $var         = $self->getTemplateVars;
    
    $var->{ form_start }
        = WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { name => "func", value => "makeShortcutSave" });
    $var->{ form_end } 
        = WebGUI::Form::formFooter( $session );

    # Albums under this Gallery
    my $albums          = $self->getGallery->getAlbumIds;
    my %albumOptions;
    for my $assetId ( @$albums ) {
        my $asset   = WebGUI::Asset->newByDynamicClass($session, $assetId);
        if ($asset->canAddFile) {
            $albumOptions{ $assetId } = $asset->get("title");
        }
    }
    $var->{ form_parentId }
        = WebGUI::Form::selectBox( $session, {
            name        => "parentId",
            value       => $self->getParent->getId,
            options     => \%albumOptions,
        });

    return $self->processStyle(
        $self->processTemplate($var, $self->getGallery->get("templateIdMakeShortcut"))
    );
}

#----------------------------------------------------------------------------

=head2 www_makeShortcutSave ( )

Make the shortcut.

This page is only available to those who can edit this Photo.

=cut

sub www_makeShortcutSave {
    my $self        = shift;
    my $form        = $self->session->form;

    return $self->session->privilege->insufficient unless $self->canEdit;
    
    my $parentId    = $form->get('parentId');
    my $shortcut    = $self->makeShortcut( $parentId );
    
    return $shortcut->www_view; 
}

#----------------------------------------------------------------------------

=head2 www_promote

Override the default promote page to send the user back to the GalleryAlbum 
edit screen.

=cut

sub www_promote {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    $self->promote;
    
    return $self->session->asset( $self->getParent )->www_edit;
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

#----------------------------------------------------------------------------

=head2 www_view ( )

Shows the output of L<view> inside of the style provided by the gallery this
photo is in.

=cut

sub www_view {
    my $self    = shift;

    return $self->session->privilege->insufficient unless $self->canView;

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

1;
