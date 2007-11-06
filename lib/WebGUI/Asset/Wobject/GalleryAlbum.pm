package WebGUI::Asset::Wobject::GalleryAlbum;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use base 'WebGUI::Asset::Wobject';
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
            defaultValue    => 0,
            label           => $i18n->get("allowComments label"),
            hoverHelp       => $i18n->get("allowComments description"),
        },
        othersCanAdd    => {
            fieldType       => "yesNo",
            defaultValue    => 0,
            label           => $i18n->get("othersCanAdd label"),
            hoverHelp       => $i18n->get("othersCanAdd description"),
        },
    );

    push @{$definition}, {
        assetName           => $i18n->get('assetName'),
        icon                => 'newWobject.gif',
        autoGenerateForms   => 1,
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
    
    my $archive     = Archive::Any->new( $filename );

    croak "Archive will extract to directory outside of storage location!"
        if $archive->is_naughty;

    use File::Temp qw{ tempdir };
    my $tempdirName = tempdir( "WebGUI-Gallery-XXXXXXXX", TMPDIR => 1, CLEANUP => 1);
    $archive->extract( $tempdir );

    opendir my $dh, $tempdirName or die "Could not open temp dir $tempdirName: $!";
    for my $file (readdir $dh) {
        my $class       = $gallery->getAssetClassForFile( $file );
        next unless $class; # class is undef for those files the Gallery can't handle

        $self->addChild({
            className       => $class,
            title           => $properties->{title},
            menuTitle       => $properties->{menuTitle} || $properties->{title},
            synopsis        => $properties->{synopsis},
        });
    }
    closedir $dh;
}

#----------------------------------------------------------------------------

=head2 appendTemplateVarsFileLoop ( vars, options )

Append template vars for a file loop with the specified options. C<vars> is
a hash reference to add the file loop to. C<options> is a hash reference of
options with the following keys:

 perpage        => number | "all"
                If "all", no pagination will be done.
 url            => url
                The URL to the current page

Returns the hash reference for convenience.

=cut

sub appendTemplateVarsFileLoop {
    my $self        = shift;
    my $var         = shift;
    my $options     = shift;

    my @assetIds;
    if ($options->{perpage} eq "all") {
        @assetIds   = @{ $self->getFileIds };
    }
    else {
        @assetIds   = @{ $self->getFilePaginator($options->{url})->getPageData };
    }

    for my $assetId (@assetIds) {
        push @{$var->{file_loop}}, 
            WebGUI::Asset->newByDynamicClass($session, $assetId)->getTemplateVars;
    }

    return $var;
}

#----------------------------------------------------------------------------

=head2 canAddFile ( [userId] )

Returns true if the user can add a file to this album. C<userId> is a WebGUI
user ID. If no userId is passed, will check the current user.

Users can add files to this album if they are the owner, or if 
C<othersCanAdd> is true and the Gallery allows them to add files.

=cut

sub canAddFile {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;

    return 1 if $userId eq $self->get("ownerUserId");
    return 1 if $self->get("othersCanAdd") && $gallery->canAddFile( $userId );
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

    # Handle adding a photo
    if ( $form->get("func") eq "add" ) {
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

=cut

# Inherited from superclass

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
    
    return WebGUI::International->new($session, "Asset_GalleryAlbum");
}

#----------------------------------------------------------------------------

=head2 getFileIds ( )

Gets an array reference of asset IDs for all the files in this album.

=cut

sub getFileIds {
    my $self        = shift;
    my $gallery     = $self->getParent;

    return $self->assetLineage( ['descendants'], {
        includeOnlyClasses      => $gallery->getAllAssetClassesForFile,
    });
}

#----------------------------------------------------------------------------

=head2 getFilePaginator ( paginatorUrl )

Gets a WebGUI::Paginator for the files in this album. C<paginatorUrl> is the 
url to the current page that will be given to the paginator.

=cut

sub getFilePaginator {
    my $self        = shift;
    my $url         = shift;

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
    my $var         = $self->get;

    $var->{ url         } = $self->getUrl;

    return $var;
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

=head2 processStyle ( )

Gets the parent Gallery's style template

=cut

sub processStyle {
    my $self        = shift;
    return $self->getParent->processStyle(@_);
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

    $self->appendTemplateVarsFileLoop( $var );

    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#----------------------------------------------------------------------------

=head2 view_slideshow ( )

method called by the www_slideshow method. Returns a processed template to be
displayed within the page style.

=cut

sub view_slideshow {
    my $self        = shift;
    my $session     = $self->session;	
    my $var         = $self->getTemplateVars;

    $self->appendTemplateVarsFileLoop( $var, { perpage => "all" } );
    
    return $self->processTemplate($var, $self->getParent->get("templateIdSlideshow"));
}

#----------------------------------------------------------------------------

=head2 view_thumbnails ( )

method called by the www_thumbnails method. Returns a processed template to be
displayed within the page style.

=cut

sub view_thumbnails {
    my $self        = shift;
    my $session     = $self->session;	
    my $var         = $self->getTemplateVars;

    $self->appendTemplateVarsFileLoop( $var, { perpage => "all" } );

    return $self->processTemplate($var, $self->getParent->get("templateIdThumbnails"));
}

#----------------------------------------------------------------------------

=head2 www_addArchive ( )

Show the form to add an archive of files to this gallery. 

=cut

sub www_addArchive {
    my $self        = shift;
    
    return $self->session->privilege->insufficient unless $self->canAddFile;

    my $var         = $self->getTemplateVars;

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

    return $self->session->privilege->insufficient unless $self->canAddfile;

    my $form        = $self->session->form;
    my $properties  = {
        keywords        => $form->get("keywords"),
        friendsOnly     => $form->get("friendsOnly"),
    };
    
    my $storage     = $form->get("archive", "File");
    my $filename    = $storage->getFilePath( $storage->getFiles->[0] );

    $self->addArchive( $filename, $properties );

    return $self->www_view;
}

#-----------------------------------------------------------------------------

=head2 www_delete ( )

Show the form to confirm deleting this album and all files inside of it.

=cut

sub www_delete {
    my $self        = shift;

    return $self->session->privilege->insufficient unless $self->canEdit;

    my $var         = $self->getTemplateVars;
    $var->{ url_yes     } = $self->getUrl("?func=deleteConfirm");

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

    $self->purge;
    
    return $self->getParent->www_view;
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

    
}

1;
