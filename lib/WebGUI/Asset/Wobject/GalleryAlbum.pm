package WebGUI::Asset::Wobject::GalleryAlbum;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName           => ['assetName', 'Asset_GalleryAlbum'];
define icon                => 'photoAlbum.gif';
define tableName           => 'GalleryAlbum';

property allowComments => (  ##Note, there's no UI for this feature.  There's just the framework for it.
            noFormPost      => 1,
            fieldType       => "yesNo",
            default         => 1,
         );
property othersCanAdd => (
            label           => ['editForm othersCanAdd label','Asset_GalleryAlbum'],
            fieldType       => "yesNo",
            default         => 0,
         );
property assetIdThumbnail => (
            label           => ['editForm assetIdThumbnail label','Asset_GalleryAlbum'],
            fieldType       => "asset",
            default         => undef,
         );
for my $i ( 1 .. 5 ) {
    property 'userDefined'.$i => (
        default     => undef,
        label       => '',
        fieldType   => 'text',
    );
}

with 'WebGUI::Role::Asset::AlwaysHidden';
with 'WebGUI::Role::Asset::RssFeed';

use Carp qw( croak );
use File::Find;
use File::Spec;
use File::Temp qw{ tempdir };
use WebGUI::International;
use WebGUI::HTML;

use Archive::Any;

=head1 NAME

=head1 DESCRIPTION

=head1 SYNOPSIS

=head1 DIAGNOSTICS

=head1 METHODS

#----------------------------------------------------------------------------

=head2 addArchive ( filename, properties )

Add an archive of Files to this Album. C<filename> is the full path of the 
archive. C<properties> is a hash reference of properties to assign to the
photos in the archive.

Will croak if cannot read the archive or if the archive will extract itself to
a directory outside of the storage location.

Will only handle file types handled by the parent Gallery.

=cut

sub addArchive {
    my $self        = shift;
    my $filename    = shift;
    my $properties  = shift;
    my $gallery     = $self->getParent;
    
    my $archive     = Archive::Any->new( $filename );

    die "Archive will extract to directory outside of storage location!\n"
        if $archive->is_naughty;

    my $tempdirName = tempdir( "WebGUI-Gallery-XXXXXXXX", TMPDIR => 1, CLEANUP => 1);
    $archive->extract( $tempdirName );

    # Get all the files in the archive
    my @files;
    my $wanted      = sub { push @files, $File::Find::name };
    find( {
        wanted      => $wanted,
    }, $tempdirName );

    for my $filePath (@files) {
        my ($volume, $directory, $filename) = File::Spec->splitpath( $filePath );
        next unless $filename;
        next if $filename =~ m{^[.]};
        next if $filename =~ m{^thumb-};
        my $class       = $gallery->getAssetClassForFile( $filePath );
        next unless $class; # class is undef for those files the Gallery can't handle

        $self->session->errorHandler->info( "Adding $filename to album!" );
        # Remove the file extention
        $filename   =~ s{\.[^.]+}{};

        $properties->{ className        } = $class;
        $properties->{ menuTitle        } = $filename;
        $properties->{ title            } = $filename;
        $properties->{ url              } = $self->session->url->urlize( $self->getUrl . "/" . $filename );

        my $asset   = $self->addChild( $properties, undef, undef, { skipAutoCommitWorkflows => 1 } );
        $asset->setFile( $filePath );
    }

    my $versionTag      = WebGUI::VersionTag->getWorking( $self->session );
    $versionTag->set({ 
        "workflowId" => $self->getParent->workflowIdCommit,
    });
    $versionTag->requestCommit;

    return undef;
}

#----------------------------------------------------------------------------

=head2 appendTemplateVarsFileLoop ( vars, assetIds )

Append template vars for a file loop for the specified assetIds. C<vars> is
a hash reference to add the file loop to. C<assetIds> is an array reference
of assetIds for the loop.

Returns the hash reference for convenience.

=cut

sub appendTemplateVarsFileLoop {
    my $self        = shift;
    my $var         = shift;
    my $assetIds    = shift;
    my $session     = $self->session;

    for my $assetId (@$assetIds) {
        my $asset = WebGUI::Asset->newById($session, $assetId);
        # Set the parent
        $asset->{_parent} = $self;
        push @{$var->{file_loop}}, $asset->getTemplateVars;
    }

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

=head2 canAddFile ( [userId] )

Returns true if the user can add a file to this album. C<userId> is a WebGUI
user ID. If no userId is passed, will check the current user.

Users can add files to this album if they are the owner, if 
C<othersCanAdd> is true and the Gallery allows them to add files, or if
they are allowed to edit the parent Gallery.

=cut

sub canAddFile {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    my $gallery     = $self->getParent;

    return 1 if $userId eq $self->ownerUserId;
    return 1 if $self->othersCanAdd && $gallery->canAddFile( $userId );
    return $gallery->canEdit( $userId );
}

#----------------------------------------------------------------------------

=head2 canComment ( [userId] )

Returns true if the user is allowed to comment on files in this Album. 
C<userId> is a WebGUI user ID. If no userId is passed, will check the current
user.

Users can comment on files if C<allowComments> is true and the parent Gallery
allows comments.

=cut

sub canComment {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    my $gallery     = $self->getParent;

    return 0 if !$self->allowComments;

    return $gallery->canComment( $userId );
}

#----------------------------------------------------------------------------

=head2 canEdit ( [userId] )

Returns true if the user can edit this asset. C<userId> is a WebGUI user ID. 
If no userId is passed, check the current user.

Users can edit this GalleryAlbum if they are the owner, or if they can edit
the Gallery parent.

Also handles adding of child assets by calling C<canAddFile>.

=cut

sub canEdit {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    my $gallery     = $self->getParent;
    my $form        = $self->session->form;

    # Handle adding a photo
    if ( $form->get("func") eq "add" ) {
        return $self->canAddFile;
    }
    elsif ( $form->get("func") eq "editSave" && $form->get("className") eq __PACKAGE__ ) {
        return $self->canAddFile;
    }
    else {
        return 1 if $userId eq $self->ownerUserId;
            
        return $gallery->canEdit($userId);
    }
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
If no userId is given, checks the current user.

Users can view this album if they can view the containing Gallery.

NOTE: It may be possible to view a GalleryAlbum that has no public files. In
such cases, the GalleryAlbum will appear empty to unprivileged users. This is 
not a bug.

=cut

sub canView {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    return $self->getParent->canView($userId);
}

#----------------------------------------------------------------------------

=head2 DESTROY

Destroy the cached assets

=cut

sub DESTROY {
    my $self        = shift;
    for my $key ( qw/ _nextAlbum _prevAlbum / ) {
        my $asset       = delete $self->{ $key };
        $asset->DESTROY if $asset;
    }
}

#----------------------------------------------------------------------------

=head2 getAutoCommitWorkflowId ( )

Returns the workflowId of the Gallery's approval workflow.

=cut

sub getAutoCommitWorkflowId {
    my $self        = shift;
    my $gallery = $self->getParent;
    if ($gallery->hasBeenCommitted) {
        return $gallery->workflowIdCommit
            || $self->session->setting->get('defaultVersionTagWorkflow');
    }
    return undef;
}

#----------------------------------------------------------------------------

=head2 getCurrentRevisionDate ( session, assetId )

Override this to allow instanciation of "pending" GalleryAlbums for those who
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
            "SELECT MAX(revisionDate) FROM GalleryAlbum WHERE assetId=?",
            [ $assetId ]
        );

    return undef unless $revisionDate;

    my $asset   = WebGUI::Asset->newById( $session, $assetId, $revisionDate );

    return undef unless $asset;

    if ( $asset->status eq "approved" || $asset->canEdit ) {
        return $revisionDate;
    }
    else {
        return $class->next::method( $session, $assetId );
    }
}

#----------------------------------------------------------------------------

=head2 getFileIds ( )

Gets an array reference of asset IDs for all the files in this album.

=cut

sub getFileIds {
    my $self        = shift;

    if ( !$self->session->stow->get( 'fileIds-' . $self->getId ) ) {
        my $gallery     = $self->getParent;
        
        # Deal with "pending" files.
        my %pendingRules;
        if ( $self->canEdit ) {
            $pendingRules{ statusToInclude } = [ 'pending', 'approved' ];
        }
        else {
            $pendingRules{ statusToInclude } = [ 'pending', 'approved' ];
            $pendingRules{ whereClause } = q{
                ( 
                    status = "approved" || ownerUserId = "} . $self->session->user->userId . q{"
                )
            };
        }
        
        $self->session->stow->set( 
            "fileIds-" . $self->getId, 
            $self->getLineage( ['descendants'], { (%pendingRules) } ),
        );
    }

    return $self->session->stow->get( "fileIds-" . $self->getId );
}

#----------------------------------------------------------------------------

=head2 getFilePaginator ( paginatorUrl )

Gets a WebGUI::Paginator for the files in this album. C<paginatorUrl> is the 
url to the current page that will be given to the paginator.

=cut

sub getFilePaginator {
    my $self        = shift;
    my $url         = shift     || $self->getUrl;
    my $perPage     = $self->getParent->defaultFilesPerPage;

    my $p           = WebGUI::Paginator->new( $self->session, $url, $perPage );
    $p->setDataByArrayRef( $self->getFileIds );

    return $p;
}

#----------------------------------------------------------------------------

=head2 getNextAlbum ( ) 

Get the next album from the Gallery. Returns an instance of a GalleryAlbum,
or undef if there is no next album.

=cut

sub getNextAlbum {
    my $self        = shift;
    return $self->{_nextAlbum} if $self->{_nextAlbum};
    my $nextId      = $self->getParent->getNextAlbumId( $self->getId );
    return undef unless $nextId;
    $self->{_nextAlbum } = WebGUI::Asset->newById( $self->session, $nextId );
    return $self->{_nextAlbum};
}

#----------------------------------------------------------------------------

=head2 getPreviousAlbum ( ) 

Get the previous album from the Gallery. Returns an instance of a GalleryAlbum,
or undef if there is no previous album.

=cut

sub getPreviousAlbum {
    my $self        = shift;
    return $self->{_previousAlbum} if $self->{_previousAlbum};
    my $previousId  = $self->getParent->getPreviousAlbumId( $self->getId );
    return undef unless $previousId;
    $self->{_previousAlbum} = WebGUI::Asset->newById( $self->session, $previousId );
    return $self->{_previousAlbum};
}

#-------------------------------------------------------------------

=head2 getRssFeedItems ()

Returns an array reference of hash references. Each hash reference has a title,
description, link, and date field. The date field can be either an epoch date, an RFC 1123
date, or a ISO date in the format of YYYY-MM-DD HH:MM::SS. Optionally specify an
author, and a guid field.

=cut

sub getRssFeedItems {
    my $self        = shift;

    my $p
        = $self->getFilePaginator( { 
            perpage     => $self->itemsPerFeed,
        } );
    
    my $var = [];
    for my $assetId ( @{ $p->getPageData } ) {
        my $asset       = WebGUI::Asset::Wobject::GalleryAlbum->newPending( $self->session, $assetId );
        push @{ $var }, {
            'link'          => $asset->getUrl,
            'guid'          => $asset->{_properties}->{ 'assetId' },
            'title'         => $asset->getTitle,
            'description'   => $asset->{_properties}->{ 'description' },
            'date'          => $asset->{_properties}->{ 'creationDate' },
            'author'        => WebGUI::User->new($self->session, $asset->{_properties}->{ 'ownerUserId' })->username
        };
    }
    
    return $var;
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Gets template vars common to all views.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $session     = $self->session;
    my $gallery     = $self->getParent;
    my $var         = $self->get;
    my $owner       = WebGUI::User->new( $session, $self->ownerUserId );

    # Fix 'undef' vars since HTML::Template does inheritence on them
    for my $key ( qw( description ) ) {
        unless ( defined $var->{$key} ) {
            $var->{ $key } = '';
        }
    }    
 
    # Set a flag for pending files
    if ( $self->status eq "pending" ) {
        $var->{ 'isPending' } = 1;
    }

    # Permissions
    $var->{ canAddFile              } = $self->canAddFile;
    $var->{ canEdit                 } = $self->canEdit;
    
    # Add some common template vars from Gallery
    $gallery->appendTemplateVarsSearchForm( $var );
    $var->{ url_listAlbums              } = $gallery->getUrl('func=listAlbums');
    $var->{ url_listAlbumsRss           } = $gallery->getUrl('func=listAlbumsRss');
    $var->{ url_listFilesForCurrentUser } = $gallery->getUrl('func=listFilesForUser');
    $var->{ url_search                  } = $gallery->getUrl('func=search');

    # Add some specific vars from the Gallery
    my $galleryVar      = $gallery->getTemplateVars;
    for my $key ( qw{ title menuTitle url displayTitle } ) {
        $var->{ "gallery_" . $key } = $galleryVar->{ $key };
    }

    # Friendly URLs
    $var->{ url                     } = $self->getUrl;
    $var->{ url_addArchive          } = $self->getUrl('func=addArchive');
    $var->{ url_addPhoto            } = $self->getUrl("func=add;class=WebGUI::Asset::File::GalleryFile::Photo");
    $var->{ url_addNoClass          } = $self->getUrl("func=add");
    $var->{ url_delete              } = $self->getUrl("func=delete");
    $var->{ url_edit                } = $self->getUrl("func=edit");
    $var->{ url_listFilesForOwner   } = $gallery->getUrl("func=listFilesForUser;userId=".$var->{ownerUserId});
    $var->{ url_viewRss             } = $self->getUrl("func=viewRss");
    $var->{ url_slideshow           } = $self->getUrl("func=slideshow");
    $var->{ url_thumbnails          } = $self->getUrl("func=thumbnails");
    
    if ( my $nextAlbum  = $self->getNextAlbum ) {
        $var->{ nextAlbum_url           } = $nextAlbum->getUrl;
        $var->{ nextAlbum_title         } = $nextAlbum->title;
        $var->{ nextAlbum_thumbnailUrl  } = $nextAlbum->getThumbnailUrl;
    }
    if ( my $prevAlbum  = $self->getPreviousAlbum ) {
        $var->{ previousAlbum_url           } = $prevAlbum->getUrl;
        $var->{ previousAlbum_title         } = $prevAlbum->title;
        $var->{ previousAlbum_thumbnailUrl  } = $prevAlbum->getThumbnailUrl;
    }

    $var->{ fileCount               } = $self->getChildCount;
    $var->{ ownerUsername           } = $owner->username;
    $var->{ thumbnailUrl            } = $self->getThumbnailUrl;

    return $var;
}

#----------------------------------------------------------------------------

=head2 getThumbnailUrl ( )

Gets the URL for the thumbnail for this asset. If no asset is set, gets the 
first child.

NOTE: If the asset does not have a getThumbnailUrl method, this method will
return undef.

=cut

sub getThumbnailUrl {
    my $self        = shift;
    my $asset       = undef;
    
    # Try to get the asset
    if ( $self->assetIdThumbnail ) {
        $asset      = WebGUI::Asset->newById( $self->session, $self->assetIdThumbnail );
    }
    elsif ( $self->getFirstChild ) {
        $asset      = $self->getFirstChild;
    }
    else {
        return undef;
    }

    # It is possible to get here and still not have an asset in cases of
    # "pending" assets, so just return
    if ( !$asset ) {
        return undef;
    }
    
    # Get the URL for the asset's thumbnail
    if ( $asset->can("getThumbnailUrl") ) {
        return $asset->getThumbnailUrl;
    }
    elsif ( $asset->isa( "WebGUI::Asset::Shortcut" ) ) {
        return $asset->getShortcut->getThumbnailUrl;
    }
    else {
        return undef;
    }
}

#----------------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->next::method();

    my $templateId  = $self->getParent->templateIdViewAlbum;

    my $template 
        = WebGUI::Asset::Template->newById($self->session, $templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);

    $self->{_viewTemplate}  = $template;
    $self->{_viewVariables} = $self->getTemplateVars;
}

#----------------------------------------------------------------------------

=head2 processFileSynopsis ( )

Process the synopsis for the files on the GalleryAlbum C<www_edit> page.

=cut

sub processFileSynopsis {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    
    # Do the version tag shuffle
    my $oldVersionTag   = WebGUI::VersionTag->getWorking( $session, "nocreate" );
    my $newVersionTag
        = WebGUI::VersionTag->create( $session, {
            workflowId      => $self->getParent->workflowIdCommit,
        } );
    $newVersionTag->setWorking;
    
    for my $key ( grep { /^fileSynopsis_/ } $form->param ) {
        ( my $assetId ) = $key =~ /^fileSynopsis_(.+)$/;
        my $synopsis    = $form->get( $key );
    
        my $asset       = WebGUI::Asset->newById( $session, $assetId );
        if ( $asset->synopsis ne $synopsis ) {
            my $properties  = $asset->get;
            $properties->{ synopsis } = $synopsis;

            $asset->addRevision( $properties, undef, { skipAutoCommitWorkflows => 1 } );
        }
    }
    
    # That's what it's all about
    $newVersionTag->commit;
    if ( $oldVersionTag ) {
        WebGUI::VersionTag->setWorking( $oldVersionTag );
    }

    return;
}

#----------------------------------------------------------------------------

=head2 processStyle ( )

Gets the parent Gallery's style template

=cut

sub processStyle {
    my $self        = shift;
    return $self->getParent->processStyle(@_);
}

#----------------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Process the form to save the asset. Request approval from the Gallery's 
approval workflow.

=cut

sub processPropertiesFromFormPost {
    my $self        = shift;
    my $form        = $self->session->form;
    my $errors      = $self->next::method || [];

    # Return if error
    return $errors  if @$errors;

    ### Passes all checks
}

#----------------------------------------------------------------------------

=head2 sendChunkedContent ( callback )

Send chunked content to the user. Will send the head of the style template, 
run the C<callback> to get the body content, then send the footer of the style
template.

=cut

sub sendChunkedContent {
    my $self        = shift;
    my $callback    = shift;

    my $session = $self->session;

	$session->http->setLastModified($self->getContentLastModified);
	$session->http->sendHeader;
	my $style = $self->processStyle($self->getSeparator);
	my ($head, $foot) = split($self->getSeparator,$style);
	$session->output->print($head, 1);
	$session->output->print( $callback->() );
	$session->output->print($foot, 1);
	return "chunked";
}

#-------------------------------------------------------------------

=head2 valid_parent_classes

Make sure that the current session asset is a Gallery for pasting and adding checks.

This is a class method.

=cut

sub valid_parent_classes {
    return [qw/WebGUI::Asset::Wobject::Gallery/];
}

#----------------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self        = shift;
    my $session     = $self->session;	
    my $var         = delete $self->{_viewVariables};
    
    my $p           = $self->getFilePaginator;
    $p->appendTemplateVars( $var );
    $self->appendTemplateVarsFileLoop( $var, $p->getPageData );

    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#----------------------------------------------------------------------------

=head2 view_slideshow ( )

method called by the www_slideshow method. Returns a processed template to be
displayed within the page style.

Show a slideshow of the GalleryAlbum's files.

=cut

sub view_slideshow {
    my $self        = shift;
    my $session     = $self->session;	
    my $var         = delete $self->{_templateVars};
    return $self->processTemplate($var, $self->getParent->templateIdViewSlideshow, $self->{_preparedTemplate});
}

#----------------------------------------------------------------------------

=head2 view_thumbnails ( )

method called by the www_thumbnails method. Returns a processed template to be
displayed within the page style.

Shows all the thumbnails for this GalleryAlbum. In addition, shows details 
about a specific thumbnail.

=cut

sub view_thumbnails {
    my $self        = shift;
    my $session     = $self->session;	
    my $var         = delete $self->{_templateVars};

    my $fileId      = $session->form->get("fileId");

    # Process the file loop to add an additional URL
    for my $file ( @{ $var->{file_loop} } ) {
        $file->{ url_albumViewThumbnails }
            = $self->getUrl('func=thumbnails;fileId=' . $file->{assetId});
    }

    # Add direct vars for the requested file
    my $asset;
    if ($fileId) {
        $asset  = WebGUI::Asset->newById( $session, $fileId );
    }
    # If no fileId given or fileId does not exist
    if (!$asset) {
        $asset  = $self->getFirstChild;
    }
    
    if ( $asset ) {
        my %assetVars   = %{ $asset->getTemplateVars };
        for my $key ( keys %assetVars ) {
            $var->{ 'file_' . $key } = $assetVars{ $key };
        }
    }

    return $self->processTemplate($var, $self->getParent->templateIdViewThumbnails);
}

#----------------------------------------------------------------------------

=head2 www_addArchive ( params )

Show the form to add an archive of files to this gallery. C<params> is a hash
reference of parameters with the following keys:

 error          => An error message to show to the user.

=cut

sub www_addArchive {
    my $self        = shift;
    my $params      = shift;
    
    return $self->session->privilege->insufficient unless $self->canAddFile;

    my $session     = $self->session;
    my $form        = $self->session->form;
    my $var         = $self->getTemplateVars;

    my $i18n = WebGUI::International->new($session);

    $var->{ error           } = $params->{ error };

    $var->{ form_start      } 
        = WebGUI::Form::formHeader( $session, {
            action          => $self->getUrl('func=addArchiveSave'),
        });
    $var->{ form_end        }
        = WebGUI::Form::formFooter( $session );

    $var->{ form_submit     } 
        = WebGUI::Form::submit( $session, {
            name            => "submit",
            value           => $i18n->get("submit",'WebGUI'),
        });

    $var->{ form_archive    } 
        = WebGUI::Form::File( $session, {
            name            => "archive",
            maxAttachments  => 1,
            value           => ( $form->get("archive") ),
        });

    $var->{ form_keywords   } 
        = WebGUI::Form::text( $session, {
            name            => "keywords",
            value           => ( $form->get("keywords") ),
        });

    $var->{ form_friendsOnly }
        = WebGUI::Form::yesNo( $session, {
            name            => "friendsOnly",
            value           => ( $form->get("friendsOnly") ),
        });

    return $self->processStyle(
        $self->processTemplate($var, $self->getParent->templateIdAddArchive)
    );
}

#-----------------------------------------------------------------------------

=head2 www_addArchiveSave ( )

Process the form for adding an archive.

=cut

sub www_addArchiveSave {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canAddFile;

    my $session     = $self->session;
    my $form        = $self->session->form;
    my $i18n        = WebGUI::International->new( $session, 'Asset_GalleryAlbum' );
    my $properties  = {
        keywords        => $form->get("keywords"),
        friendsOnly     => $form->get("friendsOnly"),
    };
    
    my $storageId   = $form->get("archive", "File");
    my $storage     = WebGUI::Storage->get( $session, $storageId );
    if (!$storage) {
        return $self->www_addArchive({
            error       => sprintf $i18n->get('addArchive error too big'),
        });
    }
    my $filename    = $storage->getPath( $storage->getFiles->[0] );

    eval { $self->addArchive( $filename, $properties ) };
    if ( my $error = $@ ) {
        return $self->www_addArchive({
            error       => sprintf( $i18n->get('addArchive error generic'), $error ),
        });
    }

    $storage->delete;

    return $self->processStyle(
        sprintf $i18n->get('addArchive message'), $self->getUrl,
    );
}

#----------------------------------------------------------------------------

=head2 www_addFileService ( )

A web service to create files in albums. Returns a json string that looks like this:

    {
       "lastUpdated" : "2008-10-13 20:06:13",
       "thumbnailUrl" : "http://dev.localhost.localdomain/uploads/W1/X9/W1X9A95iagNbq4n1utdXug/thumb-jt_25.jpg",
       "url" : "http://dev.localhost.localdomain/cool-gallery/the-cool-album3/jt13",
       "title" : "JT",
       "dateCreated" : "2008-10-13 20:06:13"
    }

You can make the request as a post to the gallery url with the following variables:

=head3 func

Required. Must have a value of "addFileService"

=head3 as

Defaults to 'json', but if specified as 'xml' then the return result will be:

    <opt>
      <dateCreated>2008-10-13 20:08:18</dateCreated>
      <lastUpdated>2008-10-13 20:08:18</lastUpdated>
      <thumbnailUrl>http://dev.localhost.localdomain/uploads/1k/-B/1k-BTF8m4e6wmXJKRxraIA/thumb-jt_25.jpg</thumbnailUrl>
      <title>JT</title>
      <url>http://dev.localhost.localdomain/cool-gallery/the-cool-album3/jt14</url>
    </opt>

=head3 title

The title of the album you wish to create.

=head3 synopsis

A brief description of the album you wish to create.

=head3 file

A file attached to the multi-part post.

=cut

sub www_addFileService {
    my $self        = shift;
    my $session     = $self->session;
    
    return $session->privilege->insufficient unless ($self->canAddFile);
    my $form = $session->form;
    
    
    my $file = $self->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
        title           => $form->get('title','text'),
        description     => $form->get('synopsis','textarea'),
        synopsis        => $form->get('synopsis','textarea'),
        ownerUserId     => $session->user->userId,
    });

    my $storage = $file->getStorageLocation;
    my $filename = $storage->addFileFromFormPost('file');
    $file->setFile;
#  my $storageId =  $form->get('file','File');
#    my $filePath = $storage->getPath( $storage->getFiles->[0] );
 #   $self->setFile( $filePath );
  #  $storage->delete;
    #$session->log->warn('XX:'. $filename);
    
    $file->requestAutoCommit;
    
    my $siteUrl = $session->url->getSiteURL;
    my $date = $session->datetime;
    my $as = $form->get('as') || 'json';

    my $document = {
        title           => $file->getTitle,
        url             => $siteUrl.$file->getUrl,
        thumbnailUrl    => $siteUrl.$file->getThumbnailUrl,
        dateCreated     => $date->epochToHuman($file->creationDate, '%y-%m-%d %j:%n:%s'),
        lastUpdated     => $date->epochToHuman($file->revisionDate, '%y-%m-%d %j:%n:%s'),
    };
    if ($as eq "xml") {
        $session->http->setMimeType('text/xml');
        return XML::Simple::XMLout($document, NoAttr => 1);
    }
        
    $session->http->setMimeType('application/json');
    return JSON->new->pretty->encode($document);
}

#-----------------------------------------------------------------------------

=head2 www_delete ( )

Show the form to confirm deleting this album and all files inside of it.

=cut

sub www_delete {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    my $var         = $self->getTemplateVars;
    $var->{ url_yes     } = $self->getUrl("func=deleteConfirm");

    return $self->processStyle(
        $self->processTemplate( $var, $self->getParent->templateIdDeleteAlbum )
    );
}

#-----------------------------------------------------------------------------

=head2 www_deleteConfirm ( )

Confirm deleting this album and all files inside of it.

=cut

sub www_deleteConfirm {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    my $gallery     = $self->getParent;
    my $i18n        = WebGUI::International->new( $self->session, 'Asset_GalleryAlbum' );

    $self->purge;
    
    return $self->processStyle(
        sprintf $i18n->get('delete message'), $self->getParent->getUrl,
    );
}

#----------------------------------------------------------------------------

=head2 www_edit ( )

Show the form to add / edit a GalleryAlbum asset.

Due to the advanced requirements of this form, we will ALWAYS post back to 
this page. This page will decide whether or not to make C<www_editSave> 
handle things.

=cut

sub www_edit {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    my $var         = $self->getTemplateVars;
    my $i18n        = WebGUI::International->new($session, 'Asset_GalleryAlbum');

    return $session->privilege->insufficient unless $self->canEdit;

    # Handle the button that was pressed
    # Save button
    if ( $form->get("save") ) {
        $self->processFileSynopsis;
        return $self->www_editSave;
    }
    # Cancel button
    elsif ( $form->get("cancel") ) {
        return $self->www_view;
    }
    # Promote the file
    elsif ( grep { $_ =~ /^promote-(.{22})$/ } $form->param ) {
        my $assetId     = ( grep { $_ =~ /^promote-(.{22})$/ } $form->param )[0];
        $assetId        =~ s/^promote-//;
        my $asset       = WebGUI::Asset->newById( $session, $assetId );
        if ( $asset ) {
            $asset->promote;
        }
        else {
            $session->errorHandler->error("Couldn't promote asset '$assetId' because we couldn't instantiate it.");
        }
    }
    # Demote the file
    elsif ( grep { $_ =~ /^demote-(.{22})$/ } $form->param ) {
        my $assetId     = ( grep { $_ =~ /^demote-(.{22})$/ } $form->param )[0];
        $assetId        =~ s/^demote-//;
        my $asset       = WebGUI::Asset->newById( $session, $assetId );
        if ( $asset ) {
            $asset->demote;
        }
        else {
            $session->errorHandler->error("Couldn't demote asset '$assetId' because we couldn't instantiate it.");
        }
    }
    elsif ( grep { $_ =~ /^delete-(.{22})$/ } $form->param ) {
        my $assetId     = ( grep { $_ =~ /^delete-(.{22})$/ } $form->param )[0];
        $assetId        =~ s/^delete-//;
        my $asset       = WebGUI::Asset->newById( $session, $assetId );
        if ( $asset ) {
            $asset->purge;
        }
        else {
            $session->errorHandler->error( "Couldn't delete asset '$assetId' because we couldn't instanciate it.");
        }
    }

    # Generate the form
    if ($form->get("func") eq "add") {
        # Add page is exempt from our button handling code since it calls the Gallery www_editSave
        $var->{ isNewAlbum  } = 1;
        $var->{ form_start  } 
            = WebGUI::Form::formHeader( $session, {
                action      => $self->getParent->getUrl('func=editSave;assetId=new;class='.__PACKAGE__),
            })
            . WebGUI::Form::hidden( $session, {
                name        => "ownerUserId",
                value       => $session->user->userId,
            });

        # Put in the buttons that may ignore button handling code
        $var->{ form_cancel }
            = WebGUI::Form::button( $session, {
                name        => "cancel",
                value       => $i18n->get("cancel"),
                extras      => 'onclick="history.go(-1)"',
            });
    }
    else {
        $var->{ form_start  } 
            = WebGUI::Form::formHeader( $session, {
                action      => $self->getUrl('func=edit'),
            })
            . WebGUI::Form::hidden( $session, {
                name        => "ownerUserId",
                value       => $self->ownerUserId,
            });
        
        # Put in the buttons that may ignore button handling code
        $var->{ form_cancel }
            = WebGUI::Form::submit( $session, {
                name        => "cancel",
                value       => $i18n->get("cancel"),
                extras      => 'onclick="history.go(-1)"',
            });
    }
    $var->{ form_start } 
        .= WebGUI::Form::hidden( $session, {
            name        => "proceed",
            value       => "showConfirmation",
        })
        ;

    $var->{ form_end    }
        = WebGUI::Form::formFooter( $session );

    $var->{ form_submit }
        = WebGUI::Form::submit( $session, {
            name        => "save",
            value       => $i18n->get("save"),
        });
    
    $var->{ form_title  }
        = WebGUI::Form::text( $session, {
            name        => "title",
            value       => $form->get("title") || $self->title,
        });

    $var->{ form_description }
        = WebGUI::Form::HTMLArea( $session, {
            name        => "description",
            value       => $form->get("description") || $self->description,
            richEditId  => $self->getParent->richEditIdAlbum,
        });

    $var->{ form_othersCanAdd }
        = WebGUI::Form::yesNo( $session, {
            name        => "othersCanAdd",
            value       => $form->get( "othersCanAdd" ) || $self->othersCanAdd,
        } );

    # Generate the file loop
    my $assetIdThumbnail    = $form->get("assetIdThumbnail") || $self->assetIdThumbnail;
    $self->appendTemplateVarsFileLoop( $var, $self->getFileIds );
    for my $file ( @{ $var->{file_loop} } ) {
        $file->{ form_assetIdThumbnail }
            = WebGUI::Form::radio( $session, {
                name        => "assetIdThumbnail",
                value       => $file->{ assetId },
                checked     => ( $assetIdThumbnail eq $file->{ assetId } ),
                id          => "assetIdThumbnail_$file->{ assetId }",
            } );

        # Raw HTML here to provide proper value for the image
        my $promoteLabel    = $i18n->get( 'Move Up', 'Icon' );
        $file->{ form_promote }
            = qq{<input type="submit" name="promote-$file->{assetId}" class="promote" value="$promoteLabel" />}
            ;

        my $demoteLabel     = $i18n->get( 'Move Down', 'Icon' );
        $file->{ form_demote }
            = qq{<input type="submit" name="demote-$file->{assetId}" class="demote" value="$demoteLabel" />}
            ;

        my $deleteConfirm   = $i18n->get( 'template delete message', 'Asset_Photo' );
        my $deleteLabel     = $i18n->get( 'Delete', 'Icon' );
        $file->{ form_delete }
            = qq{<input type="submit" name="delete-$file->{assetId}" class="delete" value="$deleteLabel" }
            . qq{ onclick="return confirm('$deleteConfirm')" />}
            ;

        $file->{ form_synopsis }
            = WebGUI::Form::HTMLArea( $session, {
                name        => "fileSynopsis_$file->{assetId}",
                value       => $form->get( "fileSynopsis_$file->{assetId}" ) || $file->{ synopsis },
                richEditId  => $self->getParent->richEditIdFile,
                height      => 150,
                width       => 300,
            });
    }

    return $self->processStyle( 
        $self->processTemplate( $var, $self->getParent->templateIdEditAlbum )
    );
}

#----------------------------------------------------------------------------

=head2 www_showConfirmation ( ) 

Shows the confirmation message after adding / editing a gallery album. 
Provides links to view the album.

=cut

sub www_showConfirmation {
    my $self        = shift;
    my $i18n        = WebGUI::International->new( $self->session, 'Asset_GalleryAlbum' );

    my $output      = '<p>' . sprintf( $i18n->get('save message'), $self->getUrl ) . '</p>'
                    . '<p>' . $i18n->get('what next') . '</p>'
                    . '<ul>'
                    . sprintf( '<li><a href="%s">%s</a></li>', $self->getUrl('func=add;class=WebGUI::Asset::File::GalleryFile::Photo'), $i18n->get('add photo')  )
                    . sprintf( '<li><a href="%s">%s</a></li>', $self->getUrl, $i18n->get('return to album') )
                    . '</ul>'
                    ;

    return $self->processStyle(
        $output
    );
}

#-----------------------------------------------------------------------------

=head2 www_slideshow ( )

Show a slideshow-type view of this album. The slideshow itself is powered by 
a javascript application in the template.

=cut

sub www_slideshow {
    my $self        = shift;

	my $check = $self->checkView;
	return $check if (defined $check);

    $self->{_templateVars} = $self->getTemplateVars;
    $self->appendTemplateVarsFileLoop( $self->{_templateVars}, $self->getFileIds );

    my $templateId = $self->getParent->templateIdViewSlideshow;
    my $template   = WebGUI::Asset::Template->newById($self->session, $templateId);
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_preparedTemplate} = $template;

    return $self->sendChunkedContent( sub { $self->view_slideshow } );
}

#----------------------------------------------------------------------------

=head2 www_thumbnails ( )

Show the thumbnails for the album.

=cut

sub www_thumbnails {
	my $self = shift;
	my $check = $self->checkView;
	return $check if (defined $check);
    $self->{_templateVars} = $self->getTemplateVars;
    $self->appendTemplateVarsFileLoop($self->{_templateVars}, $self->getFileIds);

    my $templateId = $self->getParent->templateIdViewThumbnails;
    my $template   = WebGUI::Asset::Template->newById($self->session, $templateId);
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_preparedTemplate} = $template;

    return $self->sendChunkedContent( sub { $self->view_thumbnails } );
}

#----------------------------------------------------------------------------

=head2 www_viewRss ( )

Display an RSS feed for this album.

=cut

sub www_viewRss {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canView;

    my $var         = $self->getTemplateVars;
    $self->appendTemplateVarsFileLoop( $var, $self->getFileIds );

    # Fix URLs to be full URLs
    for my $key ( qw( url url_viewRss ) ) {
        $var->{ $key } = $self->session->url->getSiteURL . $var->{ $key };
    }

    # Encode XML entities
    for my $key ( qw( title description synopsis gallery_title gallery_menuTitle ) ) {
        $var->{ $key } = WebGUI::HTML::filter($var->{$key}, 'xml');
    }

    # Process the file loop to add additional params
    for my $file ( @{ $var->{file_loop} } ) {
        # Fix URLs to be full URLs
        for my $key ( qw( url ) ) { 
            $file->{ $key }  = $self->session->url->getSiteURL . $file->{$key}; 
        }
        # Encode XML entities
        for my $key ( qw( title description synopsis ) ) {
            $file->{ $key } = WebGUI::HTML::filter($file->{$key}, 'xml');
        }

        $file->{ rssDate } 
            = $self->session->datetime->epochToMail( $file->{creationDate} );
    }

    $self->session->http->setMimeType('text/xml');
    return $self->processTemplate( $var, $self->getParent->templateIdViewAlbumRss );
}

1;
