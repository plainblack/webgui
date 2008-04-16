package WebGUI::Asset::Wobject::GalleryAlbum;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use base 'WebGUI::Asset::Wobject';
use Carp qw( croak );
use File::Find;
use File::Spec;
use File::Temp qw{ tempdir };
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;

use Archive::Any;

=head1 NAME

=head1 DESCRIPTION

=head1 SYNOPSIS

=head1 DIAGNOSTICS

=head1 METHODS

#-------------------------------------------------------------------

=head2 definition ( )

Define wobject properties for new GalleryAlbum wobjects.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = __PACKAGE__->i18n($session);

    tie my %properties, 'Tie::IxHash', (
        allowComments   => {
            fieldType       => "yesNo",
            defaultValue    => 1,
        },
        othersCanAdd    => {
            fieldType       => "yesNo",
            defaultValue    => 0,
        },
        assetIdThumbnail => {
            fieldType       => "asset",
            defaultValue    => undef,
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
        icon                => 'photoAlbum.gif',
        tableName           => 'GalleryAlbum',
        className           => __PACKAGE__,
        properties          => \%properties,
    };

    return $class->SUPER::definition($session, $definition);
}

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

    croak "Archive will extract to directory outside of storage location!"
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
        next if $filename =~ m{^[.]};
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
        "workflowId" => $self->getParent->get("workflowIdCommit"),
    });
    $versionTag->requestCommit;

    return undef;
}

#----------------------------------------------------------------------------

=head2 addChild ( properties [, ... ] )

Add a child to this GalleryAlbum. See C<WebGUI::AssetLineage> for more info.

Override to ensure only appropriate classes get added to GalleryAlbums.

=cut

sub addChild {
    my $self        = shift;
    my $properties  = shift;
    my $fileClass   = 'WebGUI::Asset::File::GalleryFile';
    
    # Load the class
    WebGUI::Pluggable::load( $properties->{className} );

    if ( !$properties->{className}->isa( $fileClass ) ) {
        $self->session->errorHandler->security(
            "add a ".$properties->{className}." to a ".$self->get("className")
        );
        return undef;
    }

    return $self->SUPER::addChild( $properties, @_ );
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
        push @{$var->{file_loop}}, 
            WebGUI::Asset->newByDynamicClass($session, $assetId)->getTemplateVars;
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

    return 1 if $userId eq $self->get("ownerUserId");
    return 1 if $self->get("othersCanAdd") && $gallery->canAddFile( $userId );
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

    return 0 if !$self->get("allowComments");

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
        return 1 if $userId eq $self->get("ownerUserId");
            
        return $gallery->canEdit($userId);
    }
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

=head2 i18n ( session )

Get a WebGUI::International object for this class. 

Can be called as a class method, in which case a WebGUI::Session object
must be passed in.

NOTE: This method can NOT be inherited, due to a current limitation 
in the i18n system. You must ALWAYS call this with C<__PACKAGE__>

=cut

sub i18n {
    my $self    = shift;
    my $session = shift;
    
    return WebGUI::International->new($session, "Asset_GalleryAlbum");
}

#----------------------------------------------------------------------------

=head2 getAutoCommitWorkflowId ( )

Returns the workflowId of the Gallery's approval workflow.

=cut

sub getAutoCommitWorkflowId {
    my $self        = shift;
    return $self->getParent->get("workflowIdCommit");
}

#----------------------------------------------------------------------------

=head2 getFileIds ( )

Gets an array reference of asset IDs for all the files in this album.

=cut

sub getFileIds {
    my $self        = shift;
    my $gallery     = $self->getParent;

    return $self->getLineage( ['descendants'], { } );
}

#----------------------------------------------------------------------------

=head2 getFilePaginator ( paginatorUrl )

Gets a WebGUI::Paginator for the files in this album. C<paginatorUrl> is the 
url to the current page that will be given to the paginator.

=cut

sub getFilePaginator {
    my $self        = shift;
    my $url         = shift     || $self->getUrl;

    my $p           = WebGUI::Paginator->new( $self->session, $url );
    $p->setDataByArrayRef( $self->getFileIds );

    return $p;
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
    my $owner       = WebGUI::User->new( $session, $self->get("ownerUserId") );
    
    # Permissions
    $var->{ canAddFile              } = $self->canAddFile;
    $var->{ canEdit                 } = $self->canEdit;
    
    # Add some common template vars from Gallery
    $gallery->appendTemplateVarsSearchForm( $var );
    $var->{ url_listAlbums              } = $gallery->getUrl('func=listAlbums');
    $var->{ url_listAlbumsRss           } = $gallery->getUrl('func=listAlbumsRss');
    $var->{ url_listFilesForCurrentUser } = $gallery->getUrl('func=listFilesForUser');
    $var->{ url_search                  } = $gallery->getUrl('func=search');

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

    if ( $self->get("assetIdThumbnail") ) {
        $asset      = WebGUI::Asset->newByDynamicClass( $self->session, $self->get("assetIdThumbnail") );
    }
    elsif ( $self->getFirstChild ) {
        $asset      = $self->getFirstChild;
    }
    else {
        return undef;
    }

    if ( $asset->can("getThumbnailUrl") ) {
        return $asset->getThumbnailUrl;
    }
    else {
        return undef;
    }
}

#----------------------------------------------------------------------------

=head2 othersCanAdd ( )

Returns true if people other than the owner can add files to this album.

=cut

sub othersCanAdd {
    my $self        = shift;
    return $self->get("othersCanAdd");
}

#----------------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();

    my $templateId  = $self->getParent->get("templateIdViewAlbum");

    my $template 
        = WebGUI::Asset::Template->new($self->session, $templateId);
    $template->prepare;

    $self->{_viewTemplate} = $template;
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
            workflowId      => $self->getParent->get("workflowIdCommit"),
        } );
    $newVersionTag->setWorking;
    
    for my $key ( grep { /^fileSynopsis_/ } $form->param ) {
        ( my $assetId ) = $key =~ /^fileSynopsis_(.+)$/;
        my $synopsis    = $form->get( $key );
    
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( $asset->get("synopsis") ne $synopsis ) {
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
    my $errors      = $self->SUPER::processPropertiesFromFormPost || [];

    # Return if error
    return $errors  if @$errors;

    ### Passes all checks

    $self->requestAutoCommit;
}

#----------------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self        = shift;
    my $session     = $self->session;	
    my $var         = $self->getTemplateVars;
    
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
    my $var         = $self->getTemplateVars;

    $self->appendTemplateVarsFileLoop( $var, $self->getFileIds );

    return $self->processTemplate($var, $self->getParent->get("templateIdViewSlideshow"));
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
    my $var         = $self->getTemplateVars;

    my $fileId      = $session->form->get("fileId");

    $self->appendTemplateVarsFileLoop( $var, $self->getFileIds );

    # Process the file loop to add an additional URL
    for my $file ( @{ $var->{file_loop} } ) {
        $file->{ url_albumViewThumbnails }
            = $self->getUrl('func=thumbnails;fileId=' . $file->{assetId});
    }

    # Add direct vars for the requested file
    my $asset;
    if ($fileId) {
        $asset  = WebGUI::Asset->newByDynamicClass( $session, $fileId );
    }
    # If no fileId given or fileId does not exist
    if (!$asset) {
        $asset  = $self->getFirstChild;
    }
    my %assetVars   = %{ $asset->getTemplateVars };
    for my $key ( keys %assetVars ) {
        $var->{ 'file_' . $key } = $assetVars{ $key };
    }

    return $self->processTemplate($var, $self->getParent->get("templateIdViewThumbnails"));
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
            value           => "Submit",
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
        $self->processTemplate($var, $self->getParent->get("templateIdAddArchive"))
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
    my $i18n        = __PACKAGE__->i18n( $session );
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

    $self->addArchive( $filename, $properties );

    $storage->delete;

    return $self->processStyle(
        sprintf $i18n->get('addArchive message'), $self->getUrl,
    );
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
        $self->processTemplate( $var, $self->getParent->get("templateIdDeleteAlbum") )
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
    my $i18n        = __PACKAGE__->i18n( $self->session );

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
    my $i18n        = __PACKAGE__->i18n($session);

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
    elsif ( $form->get("promote") ) {
        my $assetId     = $form->get("promote");
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( $asset ) {
            $asset->promote;
        }
        else {
            $session->errorHandler->error("Couldn't promote asset '$assetId' because we couldn't instantiate it.");
        }
    }
    # Demote the file
    elsif ( $form->get("demote") ) {
        my $assetId     = $form->get("demote");
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( $asset ) {
            $asset->demote;
        }
        else {
            $session->errorHandler->error("Couldn't demote asset '$assetId' because we couldn't instantiate it.");
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
                value       => $self->get("ownerUserId"),
            });
        
        # Put in the buttons that may ignore button handling code
        $var->{ form_cancel }
            = WebGUI::Form::submit( $session, {
                name        => "cancel",
                value       => $i18n->get("cancel"),
            });
    }
    $var->{ form_start } 
        .= WebGUI::Form::hidden( $session, {
            name        => "proceed",
            value       => "showConfirmation",
        });
    
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
            value       => $form->get("title") || $self->get("title"),
        });

    $var->{ form_description }
        = WebGUI::Form::HTMLArea( $session, {
            name        => "description",
            value       => $form->get("description") || $self->get("description"),
            richEditId  => $self->getParent->get("richEditIdAlbum"),
        });

    # Generate the file loop
    my $assetIdThumbnail    = $form->get("assetIdThumbnail") || $self->get("assetIdThumbnail");
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
        $file->{ form_promote }
            = qq{<button type="submit" name="promote" value="$file->{assetId}">}
            . $session->icon->moveUp( undef, undef, "disabled" )
            . qq{</button>}
            ;

        $file->{ form_demote }
            = qq{<button type="submit" name="demote" value="$file->{assetId}">}
            . $session->icon->moveDown( undef, undef, "disabled" )
            . qq{</button>}
            ;
        
        $file->{ form_synopsis }
            = WebGUI::Form::text( $session, {
                name        => "fileSynopsis_$file->{assetId}",
                value       => $form->get( "fileSynopsis_$file->{assetId}" ) || $file->{ synopsis },
            });
    }

    return $self->processStyle( 
        $self->processTemplate( $var, $self->getParent->get("templateIdEditAlbum") )
    );
}

#----------------------------------------------------------------------------

=head2 www_showConfirmation ( ) 

Shows the confirmation message after adding / editing a gallery album. 
Provides links to view the album.

=cut

sub www_showConfirmation {
    my $self        = shift;
    my $i18n        = __PACKAGE__->i18n( $self->session );

    my $output      = '<p>' . sprintf( $i18n->get('save message'), $self->getUrl ) . '</p>'
                    . '<p>' . $i18n->get('what next') . '</p>'
                    . '<ul>'
                    . sprintf( '<li><a href="%s">Add Photo</a></li>', $self->getUrl('func=add;class=WebGUI::Asset::File::GalleryFile::Photo') )
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

    return $self->session->privilege->insufficient unless $self->canView;

    return $self->processStyle( $self->view_slideshow );
}

#----------------------------------------------------------------------------

=head2 www_thumbnails ( )

Show the thumbnails for the album.

=cut

sub www_thumbnails {
    my $self        = shift;
    
    return $self->session->privilege->insufficient unless $self->canView;

    return $self->processStyle( $self->view_thumbnails );
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

    # Process the file loop to add additional params
    for my $file ( @{ $var->{file_loop} } ) {
        # Fix URLs to be full URLs
        for my $key ( qw( url ) ) { 
            $file->{ $key }  = $self->session->url->getSiteURL . $file->{$key}; 
        }

        $file->{ rssDate } 
            = $self->session->datetime->epochToMail( $file->{creationDate} );
    }

    $self->session->http->setMimeType('text/xml');
    return $self->processTemplate( $var, $self->getParent->get('templateIdViewAlbumRss') );
}

1;
