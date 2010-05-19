package WebGUI::Asset::File::GalleryFile;

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
use base 'WebGUI::Asset::File';

use Carp qw( croak confess );
use URI::Escape;
use WebGUI::HTML;
use List::MoreUtils qw{ first_index };


=head1 NAME

WebGUI::Asset::File::GalleryFile - Superclass to create files for the Gallery

=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 METHODS

These methods are available from this class

=cut

#-------------------------------------------------------------------

=head2 definition ( session, definition )

Define the properties of all GalleryFile assets.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session,'Asset_Photo');

    tie my %properties, 'Tie::IxHash', (
        views   => {
            defaultValue        => 0,
        },
        friendsOnly => {
            defaultValue        => 0,
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
        tableName           => 'GalleryFile',
        className           => 'WebGUI::Asset::File::GalleryFile',
        properties          => \%properties,
    };

    return $class->SUPER::definition($session, $definition);
}

#----------------------------------------------------------------------------

=head2 appendTemplateVarsCommentForm ( var [, comment ] ) 

Add the template variables necessary for the comment form to the given hash
reference. Returns the hash reference for convenience. C<comment> is a hash
reference of values to populate the form with.

=cut

sub appendTemplateVarsCommentForm {
    my $self        = shift;
    my $var         = shift;
    my $comment     = shift     || {};
    my $session     = $self->session;

    # Default comment
    $comment->{ commentId        } ||= "new";

    $var->{ commentForm_start }
        = WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { 
            name    => "func", 
            value   => "editCommentSave" 
        } )
        . WebGUI::Form::hidden( $session, { 
            name    => "commentId", 
            value   => $comment->{ commentId } 
        } )
        ;

    # Add hidden fields for editing a comment
    if ( $comment->{ commentId } ne "new" ) {
        $var->{ commentForm_start } 
            .= WebGUI::Form::hidden( $session, {
                name    => "userId",
                value   => $comment->{ userId } 
            } )
            .  WebGUI::Form::hidden( $session, { 
                name    => "visitorIp", 
                value   => $comment->{ visitorIp } 
            } )
            .  WebGUI::Form::hidden( $session, { 
                name    => "creationDate", 
                value   => $comment->{ creationDate } 
            } )
            ;
    }

    $var->{ commentForm_end }
        = WebGUI::Form::formFooter( $session );

    $var->{ commentForm_bodyText }
        = WebGUI::Form::HTMLArea( $session, {
            name        => "bodyText",
            richEditId  => $self->getGallery->get("richEditIdComment"),
            value       => $comment->{ bodyText },
        });

    my $i18n = WebGUI::International->new($session, 'Asset_Photo');
    $var->{ commentForm_submit } 
        = WebGUI::Form::submit( $session, {
            name        => "submit",
            value       => $i18n->get('form comment save comment'),
        });

    return $var;
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

Users can comment on this GalleryFile if they are allowed to view and the album 
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

Users can edit this GalleryFile if they are the owner or if they are able to edit
the parent Album asset.

=cut

sub canEdit {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    my $album       = $self->getParent;

    return 1 if $userId eq $self->get("ownerUserId");
    return $album && $album->canEdit($userId);
}

#----------------------------------------------------------------------------

=head2 canEditIfLocked ( [userId] )

Override this to allow editing when locked under a different version tag.

=cut

sub canEditIfLocked {
    my $self        = shift;
    my $userId      = shift;

    return $self->canEdit( $userId );
}

#----------------------------------------------------------------------------

=head2 canView ( [userId] )

Returns true if the user can view this asset. C<userId> is a WebGUI user ID.
If no user is passed, checks the current user.

Users can view this GalleryFile if they can view the parent asset. If this is a
C<friendsOnly> GalleryFile, then they must also be in the owners friends list.

=cut

sub canView {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;

    my $album       = $self->getParent;
    return 0 unless $album && $album->canView($userId);

    if ($self->isFriendsOnly && $userId ne $self->get("ownerUserId") ) {
        my $owner       = WebGUI::User->new( $self->session, $self->get("ownerUserId") );
        return 0
            unless WebGUI::Friends->new($self->session, $owner)->isFriend($userId);
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
    
    croak "GalleryFile->deleteComment: No commentId specified."
        unless $commentId;

    return $self->session->db->write(
        "DELETE FROM GalleryFile_comment WHERE assetId=? AND commentId=?",
        [$self->getId, $commentId],
    );
}

#----------------------------------------------------------------------------

=head2 getAutoCommitWorkflowId ( )

Returns the workflowId of the Gallery's approval workflow.

=cut

sub getAutoCommitWorkflowId {
    my $self        = shift;
    my $gallery = $self->getGallery;
    if ($gallery->hasBeenCommitted) {
        return $gallery->get("workflowIdCommit")
            || $self->session->setting->get('defaultVersionTagWorkflow');
    }
    return undef;
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
        "GalleryFile_comment", "commentId", $commentId,
    );
}

#----------------------------------------------------------------------------

=head2 getCommentIds ( )

Get an array reference of comment IDs for this GalleryFile, in chronological order.

=cut

sub getCommentIds {
    my $self        = shift;
    
    return [ 
        $self->session->db->buildArray(
            "SELECT commentId FROM GalleryFile_comment WHERE assetId=?",
            [$self->getId],
        ) 
    ];
}

#----------------------------------------------------------------------------

=head2 getCommentPaginator ( ) 

Get a WebGUI::Paginator for the comments for this GalleryFile.

=cut

sub getCommentPaginator {
    my $self        = shift;
    my $session     = $self->session;
    
    my $p           = WebGUI::Paginator->new($session, $self->getUrl);
    $p->setDataByQuery(
        "SELECT * FROM GalleryFile_comment WHERE assetId=? ORDER BY creationDate DESC",
        undef, undef,
        [$self->getId],
    );
    
    return $p;
}

#----------------------------------------------------------------------------

=head2 getCurrentRevisionDate ( session, assetId )

Override this to allow instanciation of "pending" GalleryFiles for those who
are authorized to see them.

=cut

sub getCurrentRevisionDate {
    my $class       = shift;
    my $session     = shift;
    my $assetId     = shift;

    # Get the highest revision date, instanciate the asset, and see if 
    # the permissions are enough to return the revisionDate.
    my $revisionDate
        = $session->db->quickScalar( 
            "SELECT MAX(revisionDate) FROM GalleryFile WHERE assetId=?",
            [ $assetId ]
        );

    return undef unless $revisionDate;

    my $asset   = WebGUI::Asset->new( $session, $assetId, $class, $revisionDate );

    return undef unless $asset;

    if ( $asset->get( 'status' ) eq "approved" || $asset->canEdit ) {
        return $revisionDate;
    }
    else {
        return $class->SUPER::getCurrentRevisionDate( $session, $assetId );
    }
}

#----------------------------------------------------------------------------

=head2 getGallery ( )

Gets the Gallery asset this GalleryFile is a member of. 

=cut

sub getGallery {
    my $self        = shift;
    
    # We must use getParent->getParent because brand-new assets do not
    # have a lineage, but they do get assigned a parent.
    return $self->getParent->getParent;
}

#----------------------------------------------------------------------------

=head2 getParent ( )

Get the parent GalleryAlbum. If the only revision of the GalleryAlbum is 
"pending", return that anyway.

=cut

sub getParent {
    my $self        = shift;
    if ( my $album = $self->SUPER::getParent ) {
        return $album;
    }
    # Only get the pending version if we're allowed to see this photo in its pending status
    my $gallery
        = $self->getLineage( ['ancestors'], {
            includeOnlyClasses  => [ 'WebGUI::Asset::Wobject::Gallery' ],
            returnObjects       => 1,
            statusToInclude     => [ 'pending', 'approved' ],
            invertTree          => 1,
        } )->[ 0 ];
    if ( ($gallery && $gallery->canEdit) || $self->get( 'ownerUserId' ) eq $self->session->user->userId ) {
        my $album
            = $self->getLineage( ['ancestors'], {
                includeOnlyClasses  => [ 'WebGUI::Asset::Wobject::GalleryAlbum' ],
                returnObjects       => 1,
                statusToInclude     => [ 'pending', 'approved' ],
                invertTree          => 1,
            } )->[ 0 ];
        return $album;
    }
    return undef;
}

#----------------------------------------------------------------------------

=head2 getFirstFile ( ) 

Get the first file in the GalleryAlbum. Returns an instance of a GalleryFile
or undef if there is no first file.

=cut

sub getFirstFile {
    my $self       = shift;
    my $allFileIds = $self->getParent->getFileIds;

    return undef unless @{ $allFileIds };
    return WebGUI::Asset->newByDynamicClass( $self->session, shift @{ $allFileIds });
}

#----------------------------------------------------------------------------

=head2 getLastFile ( ) 

Get the last file in the GalleryAlbum. Returns an instance of a GalleryFile
or undef if there is no last file.

=cut

sub getLastFile {
    my $self       = shift;
    my $allFileIds = $self->getParent->getFileIds;

    return undef unless @{ $allFileIds };
    return WebGUI::Asset->newByDynamicClass( $self->session, pop @{ $allFileIds });
}

#----------------------------------------------------------------------------

=head2 getNextFile ( ) 

Get the next file in the GalleryAlbum. Returns an instance of a GalleryFile,
or undef if there is no next file.

=cut

sub getNextFile {
    my $self = shift;
    return $self->{_nextFile} if $self->{_nextFile};
    my $nextId = $self->getParent->getNextFileId( $self->getId );
    return undef unless $nextId;
    $self->{_nextFile} = WebGUI::Asset->newByDynamicClass( $self->session, $nextId );
    return $self->{_nextFile};
}

#----------------------------------------------------------------------------

=head2 getPreviousFile ( ) 

Get the previous file in the GalleryAlbum. Returns an instance of a GalleryFile,
or undef if there is no previous file.

=cut

sub getPreviousFile {
    my $self = shift;
    return $self->{_previousFile} if $self->{_previousFile};
    my $previousId  = $self->getParent->getPreviousFileId( $self->getId );
    return undef unless $previousId;
    $self->{_previousFile} = WebGUI::Asset->newByDynamicClass( $self->session, $previousId );
    return $self->{_previousFile};
}

#----------------------------------------------------------------------------

=head2 getThumbnailUrl ( )

Gets the URL to the thumbnail for this GalleryFile. This should probably be
overridded by your child class.

=cut

sub getThumbnailUrl {
    my $self        = shift;

    # TODO: Make a "default" thumbnail
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Gets the template vars for this GalleryFile. You should probably extend this 
method.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $session     = $self->session;
    my $var         = $self->get;
    my $owner       = WebGUI::User->new( $session, $self->get("ownerUserId") );

    $var->{ fileUrl             } = $self->getFileUrl;
    $var->{ thumbnailUrl        } = $self->getThumbnailUrl;

    # Set a flag for pending files
    if ( $self->get( "status" ) eq "pending" ) {
        $var->{ 'isPending' } = 1;
    }

    # Fix 'undef' vars since HTML::Template does inheritence on them
    for my $key ( qw( synopsis ) ) {
        unless ( defined $var->{$key} ) {
            $var->{ $key } = '';
        }
    }
    
    # Add a text-only synopsis
    $var->{ synopsis_textonly   } = WebGUI::HTML::filter( $self->get('synopsis'), "all" );

    # Figure out on what page of the album the gallery file belongs.
    my $album           = $self->getParent;
    my $fileIdsInAlbum  = $album->getFileIds;
    my $id              = $self->getId;
    my $pageNumber      = 
        int (
            ( first_index { $_ eq $id } @{ $fileIdsInAlbum } )     # Get index of file in album
            / $album->getParent->get( 'defaultFilesPerPage' )               # Divide by the number of files per page
        ) + 1;                                                              # Round upwards

    $var->{ canComment          } = $self->canComment;
    $var->{ canEdit             } = $self->canEdit;
    $var->{ numberOfComments    } = scalar @{ $self->getCommentIds };
    $var->{ ownerUsername       } = $owner->get("username");
    $var->{ ownerAlias          } = $owner->get("alias") || $owner->get("username");
    $var->{ ownerId             } = $owner->getId;
    $var->{ ownerProfileUrl     } = $owner->getProfileUrl;
    $var->{ url                 } = $self->getUrl;
    $var->{ url_addArchive      } = $self->getParent->getUrl('func=addArchive'),    
    $var->{ url_delete          } = $self->getUrl('func=delete');
    $var->{ url_demote          } = $self->getUrl('func=demote');
    $var->{ url_edit            } = $self->getUrl('func=edit');
    $var->{ url_gallery         } = $self->getGallery->getUrl;
    $var->{ url_album           } = $self->getParent->getUrl("pn=$pageNumber");
    $var->{ url_thumbnails      } = $self->getParent->getUrl('func=thumbnails');
    $var->{ url_slideshow       } = $self->getParent->getUrl('func=slideshow');
    $var->{ url_makeShortcut    } = $self->getUrl('func=makeShortcut');
    $var->{ url_listFilesForOwner } 
        = $self->getGallery->getUrl('func=listFilesForUser;userId=' . $self->get("ownerUserId"));
    $var->{ url_promote         } = $self->getUrl('func=promote');

    if ( my $firstFile = $self->getFirstFile ) {
        $var->{ firstFile_url             } = $firstFile->getUrl;
        $var->{ firstFile_title           } = $firstFile->get( "title" );
        $var->{ firstFile_thumbnailUrl    } = $firstFile->getThumbnailUrl;
    }
    if ( my $nextFile  = $self->getNextFile ) {
        $var->{ nextFile_url              } = $nextFile->getUrl;
        $var->{ nextFile_title            } = $nextFile->get( "title" );
        $var->{ nextFile_thumbnailUrl     } = $nextFile->getThumbnailUrl;
    }
    if ( my $prevFile  = $self->getPreviousFile ) {
        $var->{ previousFile_url          } = $prevFile->getUrl;
        $var->{ previousFile_title        } = $prevFile->get( "title" );
        $var->{ previousFile_thumbnailUrl } = $prevFile->getThumbnailUrl;
    }
    if ( my $lastFile = $self->getLastFile ) {
        $var->{ lastFile_url              } = $lastFile->getUrl;
        $var->{ lastFile_title            } = $lastFile->get( "title" );
        $var->{ lastFile_thumbnailUrl     } = $lastFile->getThumbnailUrl;
    }

    return $var;
}

#----------------------------------------------------------------------------

=head2 isFriendsOnly ( )

Returns true if this GalleryFile is friends only. Returns false otherwise.

=cut

sub isFriendsOnly {
    my $self        = shift;
    return $self->get("friendsOnly");
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

    croak "GalleryFile->makeShortcut: parentId must be defined"
        unless $parentId;

    my $parent      = WebGUI::Asset->newByDynamicClass($session, $parentId)
                    || croak "GalleryFile->makeShortcut: Could not instanciate asset '$parentId'";

    my $shortcut
        = $parent->addChild({ 
            className           => "WebGUI::Asset::Shortcut",
            shortcutToAssetId   => $self->getId,
        });
    
    if ($overrides) {
        $shortcut->setOverride( $overrides );
    }

    if (WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        allowComments   => 1,
        returnUrl       => $self->getUrl,
    }) eq 'redirect') {
        return 'redirect';
    };

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
    $template->prepare($self->getMetaDataAsTemplateVariables);

    $self->{_viewTemplate}  = $template;
}

#----------------------------------------------------------------------------

=head2 processCommentEditForm ( )

Process the Comment Add / Edit Form. Returns a hash reference of properties
that can be passed to C<setComment>.

Will die with an i18n-friendly error message if something is missing or 
wrong.

=cut

sub processCommentEditForm {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    my $now         = WebGUI::DateTime->new( $session, time );
    my $i18n        = WebGUI::International->new( $session,'Asset_Photo' );

    # Using die here to suppress line number and file path info
    die $i18n->get("commentForm error no commentId") . "\n"
        unless $form->get("commentId");
    die $i18n->get("commentForm error no bodyText") . "\n"
        unless $form->get("bodyText");

    my $new         = $form->get('commentId') eq "new" 
                    ? 1 
                    : 0
                    ;

    my $visitorIp   = $session->user->isVisitor
                    ? $session->env->get("REMOTE_ADDR")
                    : undef
                    ;

    my $properties  = {
        commentId       => $form->get("commentId"),
        assetId         => $self->getId,
        bodyText        => $form->get("bodyText"),
        creationDate    => ( $new ? $now->toDatabaseDate    : $form->get("creationDate") ), 
        userId          => ( $new ? $session->user->userId  : $form->get("userId") ),
        visitorIp       => ( $new ? $visitorIp              : $form->get("visitorIp") ),
    };

    return $properties;
}

#----------------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )


=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    my $i18n    = WebGUI::International->new( $self->session,'Asset_Photo' );
    my $form    = $self->session->form;
    my $errors  = $self->SUPER::processPropertiesFromFormPost || [];

    # Make sure we have the disk space for this
    if ( !$self->getGallery->hasSpaceAvailable( $self->get( 'assetSize' ) ) ) {
        push @{ $errors }, $i18n->get( "error no space" );
    }

    # Return if errors
    return $errors if @$errors;
    
    ### Passes all checks

    # If the album doesn't yet have a thumbnail, make this File the thumbnail
    if ( !$self->getParent->get('assetIdThumbnail') ) {
        $self->getParent->update( {
            assetIdThumbnail        => $self->getId,
        } );
    }

    return;
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

Purge the asset. Remove all comments on the GalleryFile.

=cut

sub purge {
    my $self        = shift;
    
    for my $commentId ( @{ $self->getCommentIds } ) {
        $self->deleteComment( $commentId );
    }

    return $self->SUPER::purge;
}

#----------------------------------------------------------------------------

=head2 setComment ( properties )

Set a comment. C<properties> is a hash reference of comment information with
the following keys:

 assetId        - The assetId of the asset this comment is for
 commentId      - The ID of the comment. If "new", will make a new comment.
 bodyText       - The body of the comment
 userId         - The userId of the user who made the comment
 visitorIp      - If the user was a visitor, the IP address of the user
 creationDate   - A MySQL-formatted date/time when the comment was posted

=cut

sub setComment {
    my $self        = shift;
    my $properties  = shift;

    croak "GalleryFile->setComment: properties must be a hash reference"
        unless $properties && ref $properties eq "HASH";
    croak "GalleryFile->setComment: commentId must be defined"
        unless $properties->{ commentId };
    croak "GalleryFile->setComment: properties must contain a bodyText key"
        unless $properties->{ bodyText };

    $properties->{ creationDate     } ||= WebGUI::DateTime->new($self->session, time)->toDatabase;
    $properties->{ assetId          } = $self->getId;

    return $self->session->db->setRow( 
        "GalleryFile_comment", "commentId", 
        $properties, 
    );
}

####################################################################

=head2 update

Wrap update so that isHidden is always set to be a 1.

=cut

sub update {
    my $self = shift;
    my $properties = shift;
    return $self->SUPER::update({%$properties, isHidden => 1});
}


#----------------------------------------------------------------------------

=head2 validParent ( )

Override validParent to only allow GalleryAlbums to hold GalleryFiles.

=cut

sub validParent {
    my ($class, $session) = @_;
    return $session->asset->isa('WebGUI::Asset::Wobject::GalleryAlbum');
}

#----------------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;
    my $var     = $self->getTemplateVars;
    
    $self->appendTemplateVarsCommentForm( $var ); 

    # Add the search form
    $self->getGallery->appendTemplateVarsSearchForm( $var );

    # Add some things from Gallery
    my $galleryVar  = $self->getGallery->getTemplateVars;
    for my $key ( qw{ url_listFilesForCurrentUser url_search } ) {
        $var->{ $key } = $galleryVar->{ $key };
    }

    # More things from Gallery, but with different names
    for my $key ( qw{ title menuTitle url } ) {
        $var->{ "gallery_" . $key } = $galleryVar->{ $key };
    }

    # Add some things from Album
    my $album       = $self->getParent;
    my $albumVar    = $album->getTemplateVars;
    for my $key ( qw{ title menuTitle url thumbnailUrl } ) {
        $var->{ "album_" . $key } = $albumVar->{ $key };
    }

    # Keywords
    my $k           = WebGUI::Keyword->new( $session );
    my $keywords    = $k->getKeywordsForAsset( { asArrayRef => 1, asset => $self } ); 
    $var->{keywords} = [ ];
    for my $keyword ( @{ $keywords } ) {
        push @{ $var->{keywords} }, {
            keyword             => $keyword,
            url_searchKeyword   
                => $self->getGallery->getUrl(
                    "func=search;submit=1;keywords=" . uri_escape_utf8($keyword) 
                ),
            url_searchKeywordUser
                => $self->getGallery->getUrl(
                    "func=search;submit=1;"
                    . "userId=" . $self->get("ownerUserId") . ';'
                    . 'keywords=' . uri_escape_utf8( $keyword ) 
                ),
        };
    }

    # Comments
    my $p       = $self->getCommentPaginator;
    for my $comment ( @{ $p->getPageData } ) {
        $comment->{ url_deleteComment } 
            = $self->getUrl('func=deleteComment;commentId=' . $comment->{commentId} );
        $comment->{ url_editComment }
            = $self->getUrl('func=editComment;commentId=' . $comment->{commentId} );

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

=head2 www_delete ( )

Show the page to confirm the deletion of this GalleryFile. Show a list of albums
this GalleryFile exists in.

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

=head2 www_deleteComment ( )

Delete a comment immediately. Only those who can edit this GalleryFile can delete
comments on it.

=cut

sub www_deleteComment {
    my $self        = shift;
    my $session     = $self->session;

    return $session->privilege->insufficient unless $self->canEdit;
    
    my $i18n        = WebGUI::International->new( $session,'Asset_Photo' );
    my $commentId   = $session->form->get('commentId');
    
    $self->deleteComment( $commentId );

    return $self->www_view;
}

#----------------------------------------------------------------------------

=head2 www_deleteConfirm ( )

Confirm the deletion of this GalleryFile. Show a message and a link back to the
album.

=cut

sub www_deleteConfirm {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    my $i18n        = WebGUI::International->new( $self->session,'Asset_Photo' );

    $self->purge;

    return $self->processStyle(
        sprintf $i18n->get("delete message"), $self->getParent->getUrl,
    );
}

#----------------------------------------------------------------------------

=head2 www_editComment ( params )

Form to edit a comment. C<params> is a hash reference of parameters
with the following keys:

 errors     = An array reference of errors to show the user.

=cut

sub www_editComment {
    my $self        = shift;
    my $params      = shift;
    my $session     = $self->session;
    
    # Get the comment, if needed
    my $commentId   = $session->form->get( "commentId" );
    my $comment     = $commentId ne "new"
                    ? $self->getComment( $commentId )
                    : {}
                    ;

    # Check permissions
    # Adding a new comment
    if ( $commentId eq "new" ) {
        return $session->privilege->insufficient unless $self->canComment;
    }
    # Editing your own comment
    elsif ( $comment->{ userId } ne "1" && $comment->{ userId } eq $self->session->user->userId ) {
        return $session->privilege->insufficient unless $self->canComment;
    }
    # Editing someone else's comment
    else {
        return $session->privilege->insufficient unless $self->canEdit;
    }

    my $var         = $self->getTemplateVars;
    
    if ( $params->{ errors } ) {
        $var->{ errors } = [ map { { "error" => $_ } } @{ $params->{errors} } ];
    }

    $self->appendTemplateVarsCommentForm( $var, $comment );

    $var->{ isNew   } = $commentId eq "new";

    return $self->processStyle(
        $self->processTemplate( $var, $self->getGallery->get("templateIdEditComment") )
    );
}

#----------------------------------------------------------------------------

=head2 www_editCommentSave ( )

Save a comment being edited

=cut

sub www_editCommentSave {
    my $self        = shift;
    my $session     = $self->session;
    my $i18n        = WebGUI::International->new( $session,'Asset_Photo' );

    # Process the form first, so we can know how to check permissions
    my $comment     = eval { $self->processCommentEditForm };
    if ( $@ ) {
        return $self->www_editComment( { errors => [ $@ ] } );
    }
    
    # Check permissions
    # Adding a new comment
    if ( $comment->{ commentId } eq "new" ) {
        return $session->privilege->insufficient unless $self->canComment;
    }
    # Editing your own comment
    elsif ( $comment->{ userId } ne "1" && $comment->{ userId } eq $self->session->user->userId ) {
        return $session->privilege->insufficient unless $self->canComment;
    }
    # Editing someone else's comment
    else {
        return $session->privilege->insufficient unless $self->canEdit;
    }
    
    # setComment changes commentId, so keep track if we're adding a new comment
    my $isNew       = $comment->{commentId} eq "new";
    $self->setComment( $comment );

    # Return different message for adding and editing
    if ( $isNew ) {
        return $self->processStyle(
            sprintf $i18n->get('comment message'), $self->getUrl
        );
    }
    else {
        return $self->processStyle(
            sprintf $i18n->get('editCommentSave message'), $self->getUrl
        );
    }
}

#----------------------------------------------------------------------------

=head2 www_makeShortcut ( )

Display the form to make a shortcut.

=cut

sub www_makeShortcut {
    my $self        = shift;
    my $session     = $self->session;
    
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

This page is only available to those who can edit this GalleryFile.

=cut

sub www_makeShortcutSave {
    my $self        = shift;
    my $form        = $self->session->form;

    my $parentId    = $form->get('parentId');
    my $shortcut    = $self->makeShortcut( $parentId );
    
    return $shortcut->www_view; 
}

#----------------------------------------------------------------------------

=head2 www_view ( )

Shows the output of L<view> inside of the style provided by the gallery this
GalleryFile is in.

=cut

sub www_view {
    my $self    = shift;

    return $self->session->privilege->insufficient unless $self->canView;

    # Add to views
    $self->update({ views => $self->get('views') + 1 });

    $self->session->http->setLastModified($self->getContentLastModified);
    $self->session->http->sendHeader;
    $self->prepareView;
    my $style = $self->processStyle($self->getSeparator);
    my ($head, $foot) = split($self->getSeparator,$style);
    $self->session->output->print($head, 1);
    $self->session->output->print($self->view);
    $self->session->output->print($foot, 1);
    return "chunked";
}

sub setPrivileges {
    my $self = shift;
    $self->getStorageLocation->setPrivileges($self);
}


1; # Who knew the truth would be so obvious?
