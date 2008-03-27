package WebGUI::Asset::Wobject::Gallery;

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
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use base 'WebGUI::Asset::Wobject';

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
    );

    push @{$definition}, {
        assetName           => $i18n->get('assetName'),
        icon                => 'photoGallery.gif',
        autoGenerateForms   => 1,
        tableName           => 'Gallery',
        className           => __PACKAGE__,
        properties          => \%properties,
    };

    return $class->SUPER::definition($session, $definition);
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

    return $self->SUPER::addChild( $properties, @_ );
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
            value       => $form->get("creationDate_after","dateTime") || $oneYearAgo,
        });
    $var->{ searchForm_creationDate_before }
        = WebGUI::Form::dateTime( $session, {
            name        => "creationDate_before",
            value       => $form->get("creationDate_before","dateTime"),
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

    if ( $form->get('func') eq "add" ) {
        return $self->canAddFile( $userId );
    }
    elsif ( $form->get('func') eq "editSave" && $form->get('assetId') eq "new" ) {
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

 orderBy            => An SQL ORDER BY clause to sort the albums

=cut

sub getAlbumIds {
    my $self        = shift;
    my $options     = shift;
    
    my $orderBy     = $options->{ orderBy }      || "lineage ASC";

    my $assets 
        = $self->getLineage(['descendants'], {
            includeOnlyClasses  => ['WebGUI::Asset::Wobject::GalleryAlbum'],
            orderByClause       => $orderBy,
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

    # Checks for Photo assets
    if ( $filepath =~ /\.(jpe?g|gif|png)$/i ) {
        return "WebGUI::Asset::File::GalleryFile::Photo";
    }

    # No class found
    return undef;
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

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();

    if ( $self->get("viewDefault") eq "album" ) {
        my $asset
            = WebGUI::Asset->newByDynamicClass( $self->session, $self->get("viewAlbumAssetId") );
        $asset->prepareView;
        $self->{_viewAsset} = $asset;
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
    $template->prepare;
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

    if ( $self->get("viewDefault") eq "album" ) {
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

    my $orderBy     = $self->get('viewListOrderBy') 
                    . q{ } . $self->get('viewListOrderDirection');
    my $p
        = $self->getAlbumPaginator( { 
            perpage     => ( $form->get('perpage') || 20 ),
            orderBy     => $orderBy,
        } );
    $p->appendTemplateVars( $var );

    for my $assetId ( @{ $p->getPageData } ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
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
    
    if ( $self->getRevisionCount <= 1 && $self->get('status') eq "pending" ) {
        my $i18n    = WebGUI::International->new($self->session, 'Asset_Gallery');
        return $self->processStyle(
            $i18n->get("error add uncommitted")
        );
    }
    else {
        return $self->SUPER::www_add( @_ );
    }
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
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        my $assetVar    = $asset->getTemplateVars;

        # Fix URLs
        for my $key ( qw( url ) ) {
            $assetVar->{ $key } = $self->session->url->getSiteURL . $assetVar->{ $key };
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

=head2 www_search ( )

Search through the GalleryAlbums and files in this gallery. Show the form to
search and display the results if necessary.

=cut

sub www_search {
    my $self        = shift;
    my $form        = $self->session->form;
    my $db          = $self->session->db;

    my $var         = $self->getTemplateVars;
    # NOTE: Search form is added as part of getTemplateVars()

    # Get search results, if necessary.
    if ($form->get("submit")) {
        # Keywords to search on
        my $keywords        = join " ", $form->get('basicSearch'),
                                        $form->get('keywords'),
                                        $form->get('title'),
                                        $form->get('description')
                                        ;

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

        my $joinClass   = [
            'WebGUI::Asset::Wobject::GalleryAlbum',
            'WebGUI::Asset::File::GalleryFile::Photo',
        ];
        if ( $form->get("className") ) {
            $joinClass  = [ $form->get('className') ];
        }

        # Build a URL for the pagination
        my $url     
            = $self->getUrl( 
                'func=search;submit=1;'
                . 'basicSearch=' . $form->get('basicSearch') . ';'
                . 'keywords=' . $form->get('keywords') . ';'
                . 'title=' . $form->get('title') . ';'
                . 'description=' . $form->get('description') . ';'
                . 'className=' . $form->get('className') . ';'
                . 'creationDate_after=' . $form->get('creationDate_after') . ';'
                . 'creationDate_before=' . $form->get('creationDate_before') . ';'
                . 'userId=' . $form->get("userId") . ';'
            );

        my $p
            = $self->getSearchPaginator( { 
                url             => $url,
                keywords        => $keywords,
                where           => $where,
                joinClass       => $joinClass,
            } );
        
        $var->{ keywords }  = $keywords;

        $p->appendTemplateVars( $var );
        for my $result ( @{ $p->getPageData } ) {
            my $asset   = WebGUI::Asset->newByDynamicClass( $self->session, $result->{assetId} );
            push @{ $var->{search_results} }, $asset->getTemplateVars;
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
