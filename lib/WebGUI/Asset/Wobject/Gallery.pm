package WebGUI::Asset::Wobject::Gallery;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Class::C3;
use base qw(WebGUI::AssetAspect::RssFeed WebGUI::Asset::Wobject);
use JSON;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use XML::Simple;
use WebGUI::HTML;

=head1 NAME

=head1 DESCRIPTION

=head1 SYNOPSIS

=head1 DIAGNOSTICS

=head1 METHODS

#-------------------------------------------------------------------

=head2 definition ( )

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session, 'Asset_Gallery');

    tie my %imageResolutionOptions, 'Tie::IxHash', (
        '640'       => '640',
        '800'       => '800',
        '1024'      => '1024',
        '1260'      => '1260',
        '1440'      => '1440',
        '1600'      => '1600',
        '2880'      => '2880',
    );
    
    tie my %viewDefaultOptions, 'Tie::IxHash', (
        list        => $i18n->get("viewDefault option list"),
        album       => $i18n->get("viewDefault option album"),
    );
   
    tie my %viewListOrderByOptions, 'Tie::IxHash', (
        creationDate    => $i18n->get("viewListOrderBy option creationDate"),
        lineage         => $i18n->get("viewListOrderBy option lineage"),
        revisionDate    => $i18n->get("viewListOrderBy option revisionDate"),
        title           => $i18n->get("viewListOrderBy option title"),
    );
    
    tie my %viewListOrderDirectionOptions, 'Tie::IxHash', (
        ASC             => $i18n->get("viewListOrderDirection option asc"),
        DESC            => $i18n->get("viewListOrderDirection option desc"),
    );

    tie my %imageDensityOptions, 'Tie::IxHash', (
        72              => $i18n->get( "imageDensity option web" ),
        300             => $i18n->get( "imageDensity option print" ),
    );

    tie my %properties, 'Tie::IxHash', (
        groupIdAddComment => {
            tab             => "security",
            fieldType       => "group",
            defaultValue    => 2, # Registered Users
            label           => $i18n->get("groupIdAddComment label"),
            hoverHelp       => $i18n->get("groupIdAddComment description"),
        },
        groupIdAddFile => {
            tab             => "security",
            fieldType       => "group",
            defaultValue    => 2, # Registered Users
            label           => $i18n->get("groupIdAddFile label"),
            hoverHelp       => $i18n->get("groupIdAddFile description"),
        },
        imageResolutions => {
            tab             => "properties",
            fieldType       => "checkList",
            defaultValue    => join("\n", '800', '1024', '1200', '1600', '2880'),
            options         => \%imageResolutionOptions,
            label           => $i18n->get("imageResolutions label"),
            hoverHelp       => $i18n->get("imageResolutions description"),
        },
        imageViewSize => {
            tab             => "properties",
            fieldType       => "integer",
            defaultValue    => 700,
            label           => $i18n->get("imageViewSize label"),
            hoverHelp       => $i18n->get("imageViewSize description"),
        },
        imageThumbnailSize => {
            tab             => "properties",
            fieldType       => "integer",
            defaultValue    => 300,
            label           => $i18n->get("imageThumbnailSize label"),
            hoverHelp       => $i18n->get("imageThumbnailSize description"),
        },
        imageDensity        => {
            tab             => "properties",
            fieldType       => "selectBox",
            options         => \%imageDensityOptions,
            defaultValue    => 72,
            label           => $i18n->get( "imageDensity label" ),
            hoverHelp       => $i18n->get( "imageDensity description" ),
        },
        maxSpacePerUser => {
            tab             => "properties",
            fieldType       => "integer",
            defaultValue    => 0,
            label           => $i18n->get("maxSpacePerUser label"),
            hoverHelp       => $i18n->get("maxSpacePerUser description"),
        },
        richEditIdAlbum => {
            tab             => "properties",
            fieldType       => "selectRichEditor",
            defaultValue    => "PBrichedit000000000001", # Content Managers editor
            label           => $i18n->get("richEditIdAlbum label"),
            hoverHelp       => $i18n->get("richEditIdAlbum description"),
        },
        richEditIdFile => {
            tab             => "properties",
            fieldType       => "selectRichEditor",
            defaultValue    => "PBrichedit000000000002", # Forum Rich editor
            label           => $i18n->get("richEditIdFile label"),
            hoverHelp       => $i18n->get("richEditIdFile description"),
        },
        richEditIdComment => {
            tab             => "properties",
            fieldType       => "selectRichEditor",
            defaultValue    => "PBrichedit000000000002", # Forum Rich Editor
            label           => $i18n->get("richEditIdFileComment label"),
            hoverHelp       => $i18n->get("richEditIdFileComment description"),
        },
        templateIdAddArchive => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "i0X4Q3tBWUb_thsVbsYz9xQ",
            namespace       => "GalleryAlbum/AddArchive",
            label           => $i18n->get("templateIdAddArchive label"),
            hoverHelp       => $i18n->get("templateIdAddArchive description"),
        },
        templateIdDeleteAlbum => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "UTNFeV7B_aSCRmmaFCq4Vw",
            namespace       => "GalleryAlbum/Delete",
            label           => $i18n->get("templateIdDeleteAlbum label"),
            hoverHelp       => $i18n->get("templateIdDeleteAlbum description"),
        },
        templateIdDeleteFile => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "zcX-wIUct0S_np14xxOA-A",
            namespace       => "GalleryFile/Delete",
            label           => $i18n->get("templateIdDeleteFile label"),
            hoverHelp       => $i18n->get("templateIdDeleteFile description"),
        },
        templateIdEditAlbum => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "6X-7Twabn5KKO_AbgK3PEw",
            namespace       => "GalleryAlbum/Edit",
            label           => $i18n->get("templateIdEditAlbum label"),
            hoverHelp       => $i18n->get("templateIdEditAlbum description"),
        },
        templateIdEditComment => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "OxJWQgnGsgyGohP2L3zJPQ",
            namespace       => "GalleryFile/EditComment",
            label           => $i18n->get("templateIdEditComment label"),
            hoverHelp       => $i18n->get("templateIdEditComment description"),
        },
        templateIdEditFile => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "7JCTAiu1U_bT9ldr655Blw",
            namespace       => "GalleryFile/Edit",
            label           => $i18n->get("templateIdEditFile label"),
            hoverHelp       => $i18n->get("templateIdEditFile description"),
        },
        templateIdListAlbums => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "azCqD0IjdQSlM3ar29k5Sg",
            namespace       => "Gallery/ListAlbums",
            label           => $i18n->get("templateIdListAlbums label"),
            hoverHelp       => $i18n->get("templateIdListAlbums description"),
        },
        templateIdListAlbumsRss => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "ilu5BrM-VGaOsec9Lm7M6Q",
            namespace       => "Gallery/ListAlbumsRss",
            label           => $i18n->get("templateIdListAlbumsRss label"),
            hoverHelp       => $i18n->get("templateIdListAlbumsRss description"),
        },
        templateIdListFilesForUser => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "OkphOEdaSGTXnFGhK4GT5A",
            namespace       => "Gallery/ListFilesForUser",
            label           => $i18n->get("templateIdListFilesForUser label"),
            hoverHelp       => $i18n->get("templateIdListFilesForUser description"),
        },
        templateIdListFilesForUserRss => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "-ANLpoTEP-n4POAdRxCzRw",
            namespace       => "Gallery/ListFilesForUserRss",
            label           => $i18n->get("templateIdListFilesForUserRss label"),
            hoverHelp       => $i18n->get("templateIdListFilesForUserRss description"),
        },
        templateIdMakeShortcut => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "m3IbBavqzuKDd2PGGhKPlA",
            namespace       => "GalleryFile/MakeShortcut",
            label           => $i18n->get("templateIdMakeShortcut label"),
            hoverHelp       => $i18n->get("templateIdMakeShortcut description"),
        },
        templateIdSearch => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "jME5BEDYVDlBZ8jIQA9-jQ",
            namespace       => "Gallery/Search",
            label           => $i18n->get("templateIdSearch label"),
            hoverHelp       => $i18n->get("templateIdSearch description"),
        },
        templateIdViewSlideshow => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "KAMdiUdJykjN02CPHpyZOw",
            namespace       => "GalleryAlbum/ViewSlideshow",
            label           => $i18n->get("templateIdViewSlideshow label"),
            hoverHelp       => $i18n->get("templateIdViewSlideshow description"),
        },
        templateIdViewThumbnails => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "q5O62aH4pjUXsrQR3Pq4lw",
            namespace       => "GalleryAlbum/ViewThumbnails",
            label           => $i18n->get("templateIdViewThumbnails label"),
            hoverHelp       => $i18n->get("templateIdViewThumbnails description"),
        },
        templateIdViewAlbum => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "05FpjceLYhq4csF1Kww1KQ",
            namespace       => "GalleryAlbum/View",
            label           => $i18n->get("templateIdViewAlbum label"),
            hoverHelp       => $i18n->get("templateIdViewAlbum description"),
        },
        templateIdViewAlbumRss => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "mM3bjP_iG9sv5nQb4S17tQ",
            namespace       => "GalleryAlbum/ViewRss",
            label           => $i18n->get("templateIdViewAlbumRss label"),
            hoverHelp       => $i18n->get("templateIdViewAlbumRss description"),
        },
        templateIdViewFile  => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "TEId5V-jEvUULsZA0wuRuA",
            namespace       => "GalleryFile/View",
            label           => $i18n->get("templateIdViewFile label"),
            hoverHelp       => $i18n->get("templateIdViewFile description"),
        },
        viewDefault     => {
            tab             => "display",
            fieldType       => "selectBox",
            defaultValue    => "list",
            options         => \%viewDefaultOptions,
            label           => $i18n->get("viewDefault label"),
            hoverHelp       => $i18n->get("viewDefault description"),
        },
        viewAlbumAssetId => {
            tab             => "display",
            fieldType       => "asset",
            class           => "WebGUI::Asset::Wobject::GalleryAlbum",
            label           => $i18n->get("viewAlbumAssetId label"),
            hoverHelp       => $i18n->get("viewAlbumAssetId description"),
        },
        viewListOrderBy => {
            tab             => "display",
            fieldType       => "selectBox",
            defaultValue    => "lineage", # "Sequence Number"
            options         => \%viewListOrderByOptions,
            label           => $i18n->get("viewListOrderBy label"),
            hoverHelp       => $i18n->get("viewListOrderBy description"),
        },
        viewListOrderDirection => {
            tab             => "display",
            fieldType       => "selectBox",
            defaultValue    => "ASC",
            options         => \%viewListOrderDirectionOptions,
            label           => $i18n->get("viewListOrderDirection label"),
            hoverHelp       => $i18n->get("viewListOrderDirection description"),
        },
        workflowIdCommit => {
            tab             => "security",
            fieldType       => "workflow",
            defaultValue    => "pbworkflow000000000003", # Commit without approval
            type            => 'WebGUI::VersionTag',
            label           => $i18n->get("workflowIdCommit label"),
            hoverHelp       => $i18n->get("workflowIdCommit description"),
        },
        defaultFilesPerPage => {
            tab             => 'display',
            fieldType       => 'integer',
            defaultValue    => 24,
            label           => $i18n->get( 'defaultFilesPerPage label' ),
            hoverHelp       => $i18n->get( 'defaultFilesPerPage description' ),
        },
    );

    push @{$definition}, {
        assetName           => $i18n->get('assetName'),
        icon                => 'photoGallery.gif',
        autoGenerateForms   => 1,
        tableName           => 'Gallery',
        className           => __PACKAGE__,
        properties          => \%properties,
    };

    return $class->next::method($session, $definition);
}

#----------------------------------------------------------------------------

=head2 addChild ( properties, [...] )

Add a child to this asset. See C<WebGUI::AssetLineage> for more info.

Overridden to ensure that only GalleryAlbums are added to Galleries.

=cut

sub addChild {
    my $self        = shift;
    my $properties  = shift;
    my $albumClass  = "WebGUI::Asset::Wobject::GalleryAlbum";

    # Load the class
    WebGUI::Pluggable::load( $properties->{className} );

    if ( !$properties->{className}->isa( $albumClass ) ) {
        $self->session->errorHandler->security(
            "add a ".$properties->{className}." to a ".$self->get("className")
        );
        return undef;
    }

    return $self->next::method( $properties, @_ );
}

#----------------------------------------------------------------------------

=head2 appendTemplateVarsSearchForm ( var )

Appends the template vars for the search form to the hash reference C<var>.
Returns the hash reference for convenience.

=cut

sub appendTemplateVarsSearchForm {
    my $self        = shift;
    my $var         = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    my $i18n        = WebGUI::International->new($session, 'Asset_Gallery');

    $var->{ searchForm_start    } 
        = WebGUI::Form::formHeader( $session, {
            action      => $self->getUrl('func=search'),
            method      => "GET",
        });

    $var->{ searchForm_end      } 
        = WebGUI::Form::formFooter( $session );

    $var->{ searchForm_basicSearch }
        = WebGUI::Form::text( $session, {
            name        => "basicSearch",
            value       => $form->get("basicSearch"),
        });

    $var->{ searchForm_title    }
        = WebGUI::Form::text( $session, {
            name        => "title",
            value       => $form->get("title"),
        });

    $var->{ searchForm_description }
        = WebGUI::Form::text( $session, {
            name        => "description",
            value       => $form->get("description"),
        });

    $var->{ searchForm_keywords }
        = WebGUI::Form::text( $session, {
            name        => "keywords",
            value       => $form->get("keywords"),
        });

    # Search classes
    tie my %searchClassOptions, 'Tie::IxHash', (
        'WebGUI::Asset::File::GalleryFile::Photo'   => $i18n->get("search class photo"),
        'WebGUI::Asset::Wobject::GalleryAlbum'      => $i18n->get("search class galleryalbum"),
        ''                                          => $i18n->get("search class any"),
    );
    $var->{ searchForm_className }
        = WebGUI::Form::radioList( $session, {
            name        => "className",
            value       => ( $form->get("className") || '' ),
            options     => \%searchClassOptions,
        });

    # Search creationDate
    my $oneYearAgo      = WebGUI::DateTime->new( $session, time )->add( years => -1 )->epoch;
    $var->{ searchForm_creationDate_after }
        = WebGUI::Form::dateTime( $session, {
            name        => "creationDate_after",
            value       => $form->get("creationDate_after",  "dateTime", $oneYearAgo),
        });
    $var->{ searchForm_creationDate_before }
        = WebGUI::Form::dateTime( $session, {
            name        => "creationDate_before",
            value       => $form->get("creationDate_before", "dateTime", time()),
        });

    # Buttons
    $var->{ searchForm_submit }
        = WebGUI::Form::submit( $session, {
            name        => "submit",
            value       => $i18n->get("search submit"),
        });

    return $var;
}

#----------------------------------------------------------------------------

=head2 canAddFile ( [userId] )

Returns true if the user can add files to this Gallery. C<userId> is the 
userId to check. If no userId is passed, will check the current user.

Users can add files to this gallery if they are part of the C<groupIdAddFile>

=cut

sub canAddFile {
    my $self        = shift;
    my $userId      = shift;

    my $user        = $userId
                    ? WebGUI::User->new( $self->session, $userId )
                    : $self->session->user
                    ;

    return $user->isInGroup( $self->get("groupIdAddFile") );
}

#----------------------------------------------------------------------------

=head2 canComment ( [userId] )

Returns true if the user can comment on this Gallery. C<userId> is the userId
to check. If no userId is passed, will check the current user.

Users can comment on this gallery if they are part of the 
C<groupIdAddComment> group.

=cut

sub canComment {
    my $self        = shift;
    my $userId      = shift;

    my $user        = $userId
                    ? WebGUI::User->new( $self->session, $userId )
                    : $self->session->user
                    ;

    return $user->isInGroup( $self->get("groupIdAddComment") );
}

#----------------------------------------------------------------------------

=head2 canEdit ( [userId] )

Returns true if the user can edit this Gallery. C<userId> is the userId to 
check. If no userId is passed, will check the current user.

Users can edit this gallery if they are part of the C<groupIdEdit> group.

Also checks if a user is adding a GalleryAlbum and allows them to if they are
part of the C<groupIdAddFile> group.

=cut

sub canEdit {
    my $self        = shift;
    my $userId      = shift;

    my $form        = $self->session->form;

    if ( $form->get('func') eq "add" && $form->get( 'class' )->isa( "WebGUI::Asset::Wobject::GalleryAlbum" ) ) {
        return $self->canAddFile( $userId );
    }
    elsif ( $form->get('func') eq "editSave" && $form->get('assetId') eq "new" && $form->get( 'class' )->isa( 'WebGUI::Asset::Wobject::GalleryAlbum' ) ) {
        return $self->canAddFile( $userId );
    }
    else {
        my $user        = $userId
                        ? WebGUI::User->new( $self->session, $userId )
                        : $self->session->user
                        ;
        
        return $user->isInGroup( $self->get("groupIdEdit") );
    }
}

#----------------------------------------------------------------------------

=head2 canView ( [userId] )

Returns true if the user can view this Gallery. C<userId> is the userId to 
check. If no userId is passed, will check the current user.

Users can view this gallery if they are part of the C<groupIdView> group.

=cut

sub canView {
    my $self        = shift;
    my $userId      = shift;

    my $user        = $userId
                    ? WebGUI::User->new( $self->session, $userId )
                    : $self->session->user
                    ;

    return $user->isInGroup( $self->get("groupIdView") );
}

#----------------------------------------------------------------------------

=head2 getAlbumIds ( options )

Gets an array reference of all the album IDs under this Gallery. C<options> 
is a hash reference with the following keys.

 orderBy            => An SQL ORDER BY clause to sort the albums. 
                    By default, uses the viewListOrderBy and viewListOrderDirection keys from
                    the asset properties.

=cut

sub getAlbumIds {
    my $self        = shift;
    my $options     = shift;
    
    my $orderBy     = $options->{ orderBy }
                    ? $options->{ orderBy }
                    : $self->get( 'viewListOrderBy' )
                    ? join( " ", $self->get( 'viewListOrderBy' ), $self->get( 'viewListOrderDirection' ) )
                    : "lineage ASC"
                    ;

    # Deal with "pending" albums.
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
    
    my $assets 
        = $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::Wobject::GalleryAlbum'],
            orderByClause       => $orderBy,
            ( %pendingRules ),
        });

    return $assets;
}

#----------------------------------------------------------------------------

=head2 getAlbumPaginator ( options )

Gets a WebGUI::Paginator for all the albums in this Gallery. C<options> is a
hash reference with the following keys.

 perpage            => The number of results to show per page. Default: 20

For more C<options>, see L</getAlbumIds>.

=cut

sub getAlbumPaginator {
    my $self        = shift;
    my $options     = shift;
    
    my $perpage     = $options->{ perpage }      || 20;
    delete $options->{ perpage };

    my $p
        = WebGUI::Paginator->new( $self->session, $self->getUrl, $perpage );
    $p->setDataByArrayRef( $self->getAlbumIds( $options ) );

    return $p;
}

#----------------------------------------------------------------------------

=head2 getAssetClassForFile ( filepath )

Gets the WebGUI Asset class for the file at the given C<filepath>. Returns
undef if the file cannot be saved under this Gallery.

=cut

sub getAssetClassForFile {
    my $self        = shift;
    my $filepath    = shift;

    $self->session->log->info( "Checking asset class for file '$filepath'" );

    # Checks for Photo assets
    if ( $filepath =~ /\.(jpe?g|gif|png)$/i ) {
        return "WebGUI::Asset::File::GalleryFile::Photo";
    }

    # No class found
    return undef;
}

#----------------------------------------------------------------------------

=head2 getGalleryFileClassesAvailable ( )

Returns an array reference of the Asset classes available to be added to this
Gallery.

=cut

sub getGalleryFileClassesAvailable {
    my $self        = shift;

    return [ 'WebGUI::Asset::File::GalleryFile::Photo' ];
}

#----------------------------------------------------------------------------

=head2 getImageResolutions ( )

Gets an array reference of the image resolutions to create for image-type
assets in this gallery.

=cut

sub getImageResolutions {
    my $self        = shift;
    return [ split /\n/, $self->get("imageResolutions") ];
}

#----------------------------------------------------------------------------

=head2 getNextAlbumId ( albumId )

Gets the next albumId from the list of albumIds. C<albumId> is the base 
albumId we want to find the next album for.

Returns C<undef> if there is no next albumId.

=cut

sub getNextAlbumId {
    my $self        = shift;
    my $albumId     = shift;
    my $allAlbumIds = $self->getAlbumIds;

    while ( my $checkId = shift @{ $allAlbumIds } ) {
        # If this is the last albumId
        return undef unless @{ $allAlbumIds };

        if ( $albumId eq $checkId ) {
            return shift @{ $allAlbumIds };
        }
    }
}

#----------------------------------------------------------------------------

=head2 getPreviousAlbumId ( albumId )

Gets the previous albumId from the list of albumIds. C<albumId> is the base 
albumId we want to find the previous album for.

Returns C<undef> if there is no previous albumId.

=cut

sub getPreviousAlbumId {
    my $self        = shift;
    my $albumId     = shift;
    my $allAlbumIds = $self->getAlbumIds; 

    while ( my $checkId = pop @{ $allAlbumIds } ) {
        # If this is the last albumId
        return undef unless @{ $allAlbumIds };

        if ( $albumId eq $checkId ) {
            return pop @{ $allAlbumIds };
        }
    }
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
        = $self->getAlbumPaginator( { 
            perpage     => $self->get('itemsPerFeed'),
        } );
    
    my $var     = [];
    my $siteUrl = $self->session->url->getSiteURL();
    for my $assetId ( @{ $p->getPageData } ) {
        my $asset       = WebGUI::Asset::Wobject::GalleryAlbum->newPending( $self->session, $assetId );
        push @{ $var }, {
            'link'          => $siteUrl . $asset->getUrl,
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

=head2 getSearchPaginator ( rules )

Gets a WebGUI::Paginator for a search. C<rules> is a hash reference of 
options with the following keys:

    keywords       => Keywords to search on 

Other keys are valid, see C<WebGUI::Search::search()> for details.

=cut

sub getSearchPaginator {
    my $self        = shift;
    my $rules       = shift;

    $rules->{ lineage       } = [ $self->get("lineage") ];

    my $search      = WebGUI::Search->new( $self->session );
    $search->search( $rules );
    my $paginator   = $search->getPaginatorResultSet( $rules->{url} );

    return $paginator;
}

#----------------------------------------------------------------------------

=head2 getTemplateIdEditFile ( )

Returns the ID for the template to edit a file.

NOTE: This may need to change in the future to take into account different
classes of files inside of a Gallery.

=cut

sub getTemplateIdEditFile {
    my $self        = shift;
    return $self->get("templateIdEditFile");
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Gets a hash reference of vars common to all templates.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $var         = $self->get;
    
    # Add the search form variables
    $self->appendTemplateVarsSearchForm( $var );

    $var->{ url                         } = $self->getUrl;
    $var->{ url_addAlbum                } = $self->getUrl('func=add;class=WebGUI::Asset::Wobject::GalleryAlbum');
    $var->{ url_listAlbums              } = $self->getUrl('func=listAlbums');
    $var->{ url_listAlbumsRss           } = $self->getUrl('func=listAlbumsRss');
    $var->{ url_listFilesForCurrentUser } = $self->getUrl('func=listFilesForUser');
    $var->{ url_search                  } = $self->getUrl('func=search');

    $var->{ canEdit             } = $self->canEdit;
    $var->{ canAddFile          } = $self->canAddFile;

    return $var;
}

#----------------------------------------------------------------------------

=head2 getUserAlbumIds ( [userId] )

Gets an array reference of assetIds for the GalleryAlbums in this Gallery 
owned by the specified C<userId>. If userId is not defined, will use the 
current user.

=cut

sub getUserAlbumIds {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;

    my $db          = $self->session->db;

    my $assetIds
        = $self->getLineage( ['descendants'], {
            includeOnlyClasses  => [ 'WebGUI::Asset::Wobject::GalleryAlbum' ],
            whereClause         => "ownerUserId = " . $db->quote($userId),
        });

    return $assetIds;
}

#----------------------------------------------------------------------------

=head2 getUserFileIds ( [userId] )

Gets an array reference of assetIds for the files in this Gallery owned by 
the specified C<userId>. If userId is not defined, will use the current user.

=cut

sub getUserFileIds {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;

    my $db          = $self->session->db;

    # Note: We use excludeClasses to avoid getting GalleryAlbum assets
    my $assetIds
        = $self->getLineage( ['descendants'], {
            excludeClasses      => [ 'WebGUI::Asset::Wobject::GalleryAlbum' ],
            whereClause         => "ownerUserId = " . $db->quote($userId),
        });

    return $assetIds;
}

#----------------------------------------------------------------------------

=head2 getUserFilePaginator ( options )

Gets a WebGUI::Paginator for the files owned by a specific C<userId>. 
C<options> is a hash reference of options with the following keys:

 userId         => The user who owns the asset. Defaults to the current user.
 url            => The URL to give to the paginator

=cut

sub getUserFilePaginator {
    my $self        = shift;
    my $options     = shift;
    my $userId      = delete $options->{userId};
    my $url         = delete $options->{url};

    my $p           = WebGUI::Paginator->new( $self->session, $url );
    $p->setDataByArrayRef( $self->getUserFileIds( $userId ) );

    return $p;
}

#----------------------------------------------------------------------------

=head2 hasSpaceAvailable ( spaceWanted [, userId ] )

Returns true if the user has at least the specified bytes of C<spaceWanted>
available to use in this Gallery.

=cut

sub hasSpaceAvailable {
    my $self        = shift;
    my $spaceWanted = shift;
    my $userId      = shift || $self->session->user->userId;
    
    # If we don't care, just return
    return 1 if ( $self->get( "maxSpacePerUser" ) == 0 );

    my $db          = $self->session->db;

    # Compile the amount of disk space used
    my $maxSpace    = $self->get( "maxSpacePerUser" ) * ( 1_024 ** 2 ); # maxSpacePerUser is in MB
    my $spaceUsed   = 0;
    my $fileIds
        = $self->getLineage( [ 'descendants' ], { 
            joinClass       => 'WebGUI::Asset::File::GalleryFile',
            whereClause     => 'ownerUserId = ' . $db->quote( $userId ),
        } );

    for my $assetId ( @{ $fileIds } ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $self->session, $assetId );
        next unless $asset;
        $spaceUsed += $asset->get( 'assetSize' );

        return 0 if ( $spaceUsed + $spaceWanted >= $maxSpace );
    }

    # We must have enough space
    return 1;
}

#----------------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->next::method();

    if ( $self->get("viewDefault") eq "album" && $self->get("viewAlbumAssetId") && $self->get("viewAlbumAssetId")
ne 'PBasset000000000000001') {
        my $asset
            = WebGUI::Asset->newByDynamicClass( $self->session, $self->get("viewAlbumAssetId") );
        if ($asset) {
            $asset->prepareView;
            $self->{_viewAsset} = $asset;
        }
        else {
            $self->prepareViewListAlbums;
        }
    }
    else {
        $self->prepareViewListAlbums;
    }
}

#----------------------------------------------------------------------------

=head2 prepareViewListAlbums ( )

Prepare the template for listing multiple albums.

=cut

sub prepareViewListAlbums {
    my $self        = shift;
    my $template 
        = WebGUI::Asset::Template->new($self->session, $self->get("templateIdListAlbums"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateIdListAlbums"),
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}

#----------------------------------------------------------------------------

=head2 view ( )

Show the default view based on the Gallery settings.

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;	
    my $var     = $self->get;

    if ( $self->get("viewDefault") eq "album" && $self->{_viewAsset}) {
        return $self->{_viewAsset}->view;
    }
    else {
        return $self->view_listAlbums;
    }
}

#----------------------------------------------------------------------------

=head2 view_listAlbums ( )

Show a paginated list of the albums in this gallery. This method does the 
actual work.

=cut

sub view_listAlbums {
    my $self        = shift;
    my $session     = $self->session;
    my $var         = $self->getTemplateVars;
    my $form        = $self->session->form;

    my $p
        = $self->getAlbumPaginator( { 
            perpage     => ( $form->get('perpage') || 20 ),
        } );
    $p->appendTemplateVars( $var );

    for my $assetId ( @{ $p->getPageData } ) {
        my $asset       = WebGUI::Asset::Wobject::GalleryAlbum->newPending( $session, $assetId );
        push @{ $var->{albums} }, $asset->getTemplateVars;
    }
    
    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
}

#----------------------------------------------------------------------------

=head2 www_add ( )

Add a GalleryAlbum to this Gallery. Overridden here to show an error message
if the Gallery is not committed.

If a GalleryAlbum is added to an uncommitted Gallery, and the GalleryAlbum
is committed before the Gallery, problems start happening.

TODO: This could be handled better by the requestAutoCommit subroutine 
instead of having to block things from being added.

=cut

sub www_add {
    my $self        = shift;
    
    unless ( $self->hasBeenCommitted ) {
        my $i18n    = WebGUI::International->new($self->session, 'Asset_Gallery');
        return $self->processStyle($i18n->get("error add uncommitted"));
    }

    return $self->next::method( @_ );
}

#----------------------------------------------------------------------------

=head2 www_addAlbumService ( )

A web service to create albums. Returns a json string that looks like this:

    {
       "lastUpdated" : "2008-10-13 17:31:32",
       "canAddFiles" : 1,
       "url" : "http://dev.localhost.localdomain/cool-gallery/the-cool-album2",
       "title" : "The Cool Album",
       "dateCreated" : "2008-10-13 17:31:32"
    }

You can make the request as a post to the gallery url with the following variables:

=head3 func

Required. Must have a value of "addAlbumService"

=head3 as

Defaults to 'json', but if specified as 'xml' then the return result will be:

    <opt>
      <canAddFiles>1</canAddFiles>
      <dateCreated>2008-10-13 17:39:22</dateCreated>
      <lastUpdated>2008-10-13 17:39:22</lastUpdated>
      <title>The Cool Album</title>
      <url>http://dev.localhost.localdomain/cool-gallery/the-cool-album3</url>
    </opt>

=head3 title

The title of the album you wish to create.

=head3 synopsis

A brief description of the album you wish to create.

=head3 othersCanAdd

A 1 or a 0 depending on whether you want other people to be able to add images to this album.

=cut

sub www_addAlbumService {
    my $self        = shift;
    my $session     = $self->session;
    
    return $session->privilege->insufficient unless ($self->canAddFile);
    my $form = $session->form;
    
    my $album = $self->addChild({
        className       => "WebGUI::Asset::Wobject::GalleryAlbum",
        title           => $form->get('title','text'),
        description     => $form->get('synopsis','textarea'),
        synopsis        => $form->get('synopsis','textarea'),
        othersCanAdd    => $form->get('othersCanAdd','yesNo'),
        ownerUserId     => $session->user->userId,
    });
    
    $album->requestAutoCommit;

    my $siteUrl = $session->url->getSiteURL;
    my $date = $session->datetime;
    my $as = $form->get('as') || 'json';

    my $document = {
        canAddFiles     => $album->canAddFile,
        title           => $album->getTitle,
        url             => $siteUrl.$album->getUrl,
        dateCreated     => $date->epochToHuman($album->get('creationDate'), '%y-%m-%d %j:%n:%s'),
        lastUpdated     => $date->epochToHuman($album->get('revisionDate'), '%y-%m-%d %j:%n:%s'),
    };
    if ($as eq "xml") {
        $session->http->setMimeType('text/xml');
        return XML::Simple::XMLout($document, NoAttr => 1);
    }

    $session->http->setMimeType('application/json');
    return JSON->new->pretty->encode($document);
}

#----------------------------------------------------------------------------

=head2 www_listAlbums ( )

Show a paginated list of the albums in this gallery.

=cut

sub www_listAlbums {
    my $self        = shift;
    
    # Perform the prepareView ourselves
    $self->prepareViewListAlbums;

    return $self->processStyle(
        $self->view_listAlbums
    );
}

#----------------------------------------------------------------------------

=head2 www_listAlbumsRss ( )

Show an RSS feed for the albums in this gallery.

=cut

sub www_listAlbumsRss {
    my $self        = shift;
    my $session     = $self->session;
    my $var         = $self->getTemplateVars;

    for my $assetId ( @{ $self->getAlbumIds } ) {
        my $asset       = WebGUI::Asset->new( $session, $assetId, 'WebGUI::Asset::Wobject::GalleryAlbum');
        my $assetVar    = $asset->getTemplateVars;

        # Fix URLs
        for my $key ( qw( url ) ) {
            $assetVar->{ $key } = $self->session->url->getSiteURL . $assetVar->{ $key };
        }

        # Encode XML entities
        for my $key ( qw( title description synopsis gallery_title gallery_menuTitle ) ) {
            $assetVar->{ $key } = WebGUI::HTML::filter($assetVar->{$key}, 'xml');
        }

        # Additional vars for RSS
        $assetVar->{ rssDate  } 
            = $session->datetime->epochToMail( $assetVar->{ creationDate } );

        push @{ $var->{albums} }, $assetVar;
    }

    $self->session->http->setMimeType('text/xml');
    return $self->processTemplate( $var, $self->get("templateIdListAlbumsRss") );
}

#----------------------------------------------------------------------------

=head2 www_listAlbumsService ( )

A web service to retrieve album information. You may request information from this gallery with a straight GET request:

http://admin:123qwe@www.example.com/gallery-url?func=listAlbumsService

The following parameters are optional, but may be passed along the query to change the output of this method.

=head3 as

Defaults to 'json', but can be overridden as 'xml'. If specified as 'json' the document returned will look like this:

    {
       "pageNumber" : 1,
       "gallery" : {
          "lastUpdated" : "2008-10-13 14:56:49",
          "synopsis" : "This is the summary.",
          "menuTitle" : "My Cool Gallery",
          "url" : "http://dev.localhost.localdomain/cool-gallery",
          "title" : "My Cool Gallery",
          "canAddAlbums" : 1,
          "dateCreated" : "2008-10-13 14:48:44"
       },
       "albums" : [
          {
             "thumbnailUrl" : "http://dev.localhost.localdomain",
             "lastUpdated" : "2008-10-13 14:51:38",
             "canAddFiles" : 1,
             "url" : "http://dev.localhost.localdomain/cool-gallery/the-gallery-you-can-post-to",
             "title" : "The Gallery You Can Post To",
             "dateCreated" : "2008-10-13 14:50:22"
          },
          {
             "thumbnailUrl" : "http://dev.localhost.localdomain",
             "lastUpdated" : "2008-10-13 14:51:20",
             "canAddFiles" : 0,
             "url" : "http://dev.localhost.localdomain/cool-gallery/another-album",
             "title" : "Another Album",
             "dateCreated" : "2008-10-13 14:51:20"
          }
       ]
    }

If specified as 'xml' the document returned will look like this:

    <opt>
      <albums>
        <canAddFiles>1</canAddFiles>
        <dateCreated>2008-10-13 14:50:22</dateCreated>
        <lastUpdated>2008-10-13 14:51:38</lastUpdated>
        <thumbnailUrl>http://dev.localhost.localdomain</thumbnailUrl>
        <title>The Gallery You Can Post To</title>
        <url>http://dev.localhost.localdomain/cool-gallery/the-gallery-you-can-post-to</url>
      </albums>
      <albums>
        <canAddFiles>0</canAddFiles>
        <dateCreated>2008-10-13 14:51:20</dateCreated>
        <lastUpdated>2008-10-13 14:51:20</lastUpdated>
        <thumbnailUrl>http://dev.localhost.localdomain</thumbnailUrl>
        <title>Another Album</title>
        <url>http://dev.localhost.localdomain/cool-gallery/another-album</url>
      </albums>
      <gallery>
        <canAddAlbums>1</canAddAlbums>
        <dateCreated>2008-10-13 14:48:44</dateCreated>
        <lastUpdated>2008-10-13 14:56:49</lastUpdated>
        <menuTitle>My Cool Gallery</menuTitle>
        <synopsis>This is the summary.</synopsis>
        <title>My Cool Gallery</title>
        <url>http://dev.localhost.localdomain/cool-gallery</url>
      </gallery>
      <pageNumber>1</pageNumber>
    </opt>

=head3 pn

Defaults to 1. This represents the page number. It will return up to 100 albums at a time.

=cut

sub www_listAlbumsService {
    my $self        = shift;
    my $session     = $self->session;
    
    return $session->privilege->insufficient unless ($self->canView);
    
    my $siteUrl = $session->url->getSiteURL;
    my @assets;
    my $date = $session->datetime;
    my $form = $session->form;
    my $as = $form->get('as') || 'json';
    my $pageNumber = $form->get('pn') || 1;
    my $user = $session->user;
    my $count = 1;

    for my $assetId ( @{ $self->getAlbumIds } ) {
        if ($count < $pageNumber * 100 - 100) { # skip low page numbers
            next;
        }
        if ($count > $pageNumber * 100 - 1) { # skip high page numbers
            last;
        }        
        my $asset       = WebGUI::Asset->new( $session, $assetId, 'WebGUI::Asset::Wobject::GalleryAlbum' );
        if (defined $asset) {
            if ($asset->canView) {
                push @assets, {
                    title           => $asset->getTitle,
                    url             => $siteUrl.$asset->getUrl,
                    dateCreated     => $date->epochToHuman($asset->get('creationDate'), '%y-%m-%d %j:%n:%s'),
                    lastUpdated     => $date->epochToHuman($asset->get('revisionDate'), '%y-%m-%d %j:%n:%s'),
                    thumbnailUrl    => $siteUrl.$asset->getThumbnailUrl,
                    canAddFiles     => $asset->canAddFile,
                };
            }
        }
        $count++;
    }

    my $document = {
        pageNumber  => $pageNumber,
        gallery     => {
            canAddAlbums    => $self->canAddFile,
            title           => $self->getTitle,
            menuTitle       => $self->get('menuTitle'),
            synopsis        => $self->get('synopsis'),
            url             => $siteUrl.$self->getUrl,
            dateCreated     => $date->epochToHuman($self->get('creationDate'), '%y-%m-%d %j:%n:%s'),
            lastUpdated     => $date->epochToHuman($self->get('revisionDate'), '%y-%m-%d %j:%n:%s'),
        },
        albums      => \@assets
    };
    if ($as eq "xml") {
        $session->http->setMimeType('text/xml');
        return XML::Simple::XMLout($document, NoAttr => 1);
    }
    $session->http->setMimeType('application/json');
    return JSON->new->pretty->encode($document);
}

#----------------------------------------------------------------------------

=head2 www_search ( )

Search through the GalleryAlbums and files in this gallery. Show the form to
search and display the results if necessary.

=cut

sub www_search {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $session->form;
    my $db          = $session->db;

    my $var         = $self->getTemplateVars;
    # NOTE: Search form is added as part of getTemplateVars()

    # Get search results, if necessary.
    my $doSearch    
        = ( 
            $form->get( 'basicSearch' ) || $form->get( 'keywords' )
            || $form->get( 'title' ) || $form->get( 'description' )
            || $form->get( 'userId' ) || $form->get( 'className' )
            || $form->get( 'creationDate_after' ) || $form->get( 'creationDate_before' )
        );

    if ( $doSearch ) {
        # Keywords to search on
        # Do not add a space to the
        my $keywords;
        FORMVAR: foreach my $formVar (qw/ basicSearch keywords title description /) {
            my $var = $form->get($formVar);
            next FORMVAR unless $var;
            $keywords = join ' ', $keywords, $var;
        }

        # Build a where clause from the advanced options
        # Lineage search can capture gallery
        my $where       = q{assetIndex.assetId <> '} . $self->getId . q{'};
        if ( $form->get("title") ) {
            $where      .= q{ AND assetData.title LIKE } 
                        . $db->quote( '%' . $form->get("title") . '%' ) 
                        ;
        }
        if ( $form->get("description") ) {
            $where      .= q{ AND assetData.synopsis LIKE } 
                        . $db->quote( '%' . $form->get("description") . '%' ) 
                        ;
        }
        if ( $form->get("userId") ) {
            $where      .= q{ AND assetData.ownerUserId = }
                        . $db->quote( $form->get("userId") )
                        ;
        }

        my $oneYearAgo = WebGUI::DateTime->new( $session, time )->add( years => -1 )->epoch;
        my $dateAfter  = $form->get("creationDate_after", "dateTime", $oneYearAgo);
        my $dateBefore = $form->get("creationDate_before", "dateTime", time());
        my $creationDate = {};
        if ($dateAfter) {
            $creationDate->{start} = $dateAfter;
        }
        if ($dateBefore) {
            $creationDate->{end  } = $dateBefore;
        }

        # Classes
        my $joinClass   = [
            'WebGUI::Asset::Wobject::GalleryAlbum',
            'WebGUI::Asset::File::GalleryFile::Photo',
        ];
        if ( $form->get("className") ) {
            $joinClass  = [ $form->get('className') ];
        }
        $where      .= q{ AND assetIndex.className IN ( } . $db->quoteAndJoin( $joinClass ) . q{ ) };
        

        # Build a URL for the pagination
        my $url     
            = $self->getUrl( 
                'func=search;'
                . 'basicSearch=' . $form->get('basicSearch') . ';'
                . 'keywords=' . $form->get('keywords') . ';'
                . 'title=' . $form->get('title') . ';'
                . 'description=' . $form->get('description') . ';'
                . 'creationDate_after=' . $dateAfter . ';'
                . 'creationDate_before=' . $dateBefore . ';'
                . 'userId=' . $form->get("userId") . ';'
            );
        for my $class ( @$joinClass ) {
            $url    .= 'className=' . $class . ';';
        }

        my $p
            = $self->getSearchPaginator( { 
                url             => $url,
                keywords        => $keywords,
                where           => $where,
                joinClass       => $joinClass,
                creationDate    => $creationDate,
            } );
        
        $var->{ keywords }  = $keywords;

        $p->appendTemplateVars( $var );
        for my $result ( @{ $p->getPageData } ) {
            my $asset   = WebGUI::Asset->newByDynamicClass( $session, $result->{assetId} );
            push @{ $var->{search_results} }, {
                %{ $asset->getTemplateVars },
                isAlbum     => $asset->isa( 'WebGUI::Asset::Wobject::GalleryAlbum' ),
            };
        }
    }

    return $self->processStyle(
        $self->processTemplate( $var, $self->get("templateIdSearch") )
    );
}

#----------------------------------------------------------------------------

=head2 www_listFilesForUser ( )

Show all the GalleryAlbums and files owned by a given userId. If no userId is
given, will use the current user.

=cut

sub www_listFilesForUser {
    my $self        = shift;
    my $session     = $self->session;
    my $var         = $self->getTemplateVars;
    my $userId      = $self->session->form->get("userId") || $self->session->user->userId;
    my $user        = WebGUI::User->new( $session, $userId );

    $var->{ url_rss         } = $self->getUrl('func=listFilesForUserRss;userId=' . $userId);
    $var->{ userId          } = $userId;
    $var->{ username        } = $user->username;

    # Get all the albums
    my $albumIds    = $self->getUserAlbumIds( $userId );
    for my $albumId ( @$albumIds ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $albumId );
        push @{ $var->{user_albums} }, $asset->getTemplateVars;
    }

    # Get a page of files
    my $p
        = $self->getUserFilePaginator({ 
            userId          => $userId, 
            url             => $self->getUrl("func=listFilesForUser") 
        });
    $p->appendTemplateVars( $var );

    for my $fileId ( @{ $p->getPageData } ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $fileId );
        push @{ $var->{user_files} }, $asset->getTemplateVars;
    }

    return $self->processStyle(
        $self->processTemplate( $var, $self->get("templateIdListFilesForUser") )
    );
}

#----------------------------------------------------------------------------

=head2 www_listFilesForUserRss ( )

=cut

sub www_listFilesForUserRss {
    my $self        = shift;
    my $session     = $self->session;
    my $var         = $self->getTemplateVars;
    my $userId      = $self->session->form("userId") || $self->session->user->userId;

    # Fix URLs for template vars
    for my $key ( qw( url ) ) {
        $var->{ $key } = $self->session->url->getSiteURL . $var->{ $key };
    }

    # Get all the albums
    my $albumIds    = $self->getUserAlbumIds( $userId );
    for my $albumId ( @$albumIds ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $albumId );
        my $assetVar    = $asset->getTemplateVars;

        for my $key ( qw( url ) ) {
            $assetVar->{ $key } = $self->session->url->getSiteURL . $assetVar->{ $key };
        }

        push @{ $var->{user_albums} }, $assetVar;
    }

    # Get all the files
    my $fileIds     = $self->getUserFileIds( $userId );
    for my $fileId ( @$fileIds ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $fileId );
        my $assetVar    = $asset->getTemplateVars;

        for my $key ( qw( url ) ) {
            $assetVar->{ $key } = $self->session->url->getSiteURL . $assetVar->{ $key };
        }

        push @{ $var->{user_files} }, $assetVar;
    }

    $self->session->http->setMimeType('text/xml');
    return $self->processTemplate( $var, $self->get("templateIdListFilesForUserRss") );
}

1;
