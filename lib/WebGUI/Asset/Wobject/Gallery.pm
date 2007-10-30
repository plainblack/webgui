package WebGUI::Asset::Wobject::Gallery;

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
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for New Wobject instances.  You absolutely need 
this method in your new Wobjects.  If you choose to "autoGenerateForms", the
getEditForm method is unnecessary/redundant/useless.  

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
        groupIdModerator => {
            tab             => "security",
            fieldType       => "group",
            defaultValue    => 3, # Admins
            label           => $i18n->get("groupIdModerator label"),
            hoverHelp       => $i18n->get("groupIdModerator description"),
        },
        imageResolutions => {
            tab             => "properties",
            fieldType       => "checkList",
            defaultValue    => ['800','1024','1200','1600'],
            options         => \%imageResolutionOptions,
            label           => $i18n->get("imageResolutions label"),
            hoverHelp       => $i18n->get("imageResolutions description"),
        },
        imageViewSize => {
            tab             => "properties",
            fieldType       => "integer",
            defaultValue    => 0,
            label           => $i18n->get("imageViewSize label"),
            hoverHelp       => $i18n->get("imageViewSize description"),
        },
        imageThumbnailSize => {
            tab             => "properties",
            fieldType       => "integer",
            defaultValue    => 0,
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
        richEditIdFileComment => {
            tab             => "properties",
            fieldType       => "selectRichEditor",
            defaultValue    => undef, # Rich Editor for Posts
            label           => $i18n->get("richEditIdFileComment label"),
            hoverHelp       => $i18n->get("richEditIdFileComment description"),
        },
        templateIdAddArchive => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryAlbum/AddArchive",
            label           => $i18n->get("templateIdAddArchive label"),
            hoverHelp       => $i18n->get("templateIdAddArchive description"),
        },
        templateIdDeleteAlbum => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryAlbum/Delete",
            label           => $i18n->get("templateIdDeleteAlbum label"),
            hoverHelp       => $i18n->get("templateIdDeleteAlbum description"),
        },
        templateIdDeleteFile => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryFile/Delete",
            label           => $i18n->get("templateIdDeleteFile label"),
            hoverHelp       => $i18n->get("templateIdDeleteFile description"),
        },
        templateIdEditFile => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryFile/Edit",
            label           => $i18n->get("templateIdEditFile label"),
            hoverHelp       => $i18n->get("templateIdEditFile description"),
        },
        templateIdListAlbums => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "Gallery/ListAlbums",
            label           => $i18n->get("templateIdListAlbums label"),
            hoverHelp       => $i18n->get("templateIdListAlbums description"),
        },
        templateIdListAlbumsRss => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "Gallery/ListAlbumsRss",
            label           => $i18n->get("templateIdListAlbumsRss label"),
            hoverHelp       => $i18n->get("templateIdListAlbumsRss description"),
        },
        templateIdListUserFiles => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "Gallery/ListUserFiles",
            label           => $i18n->get("templateIdListUserFiles label"),
            hoverHelp       => $i18n->get("templateIdListUserFiles description"),
        },
        templateIdListUserFilesRss => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "Gallery/ListUserFilesRss",
            label           => $i18n->get("templateIdListUserFilesRss label"),
            hoverHelp       => $i18n->get("templateIdListUserFilesRss description"),
        },
        templateIdMakeShortcut => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryFile/MakeShortcut",
            label           => $i18n->get("templateIdMakeShortcut label"),
            hoverHelp       => $i18n->get("templateIdMakeShortcut description"),
        },
        templateIdSearch => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "Gallery/Search",
            label           => $i18n->get("templateIdSearch label"),
            hoverHelp       => $i18n->get("templateIdSearch description"),
        },
        templateIdSlideshow => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryAlbum/Slideshow",
            label           => $i18n->get("templateIdSlideshow label"),
            hoverHelp       => $i18n->get("templateIdSlideshow description"),
        },
        templateIdThumbnails => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryAlbum/Thumbnails",
            label           => $i18n->get("templateIdThumbnails label"),
            hoverHelp       => $i18n->get("templateIdThumbnails description"),
        },
        templateIdViewAlbum => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryAlbum/View",
            label           => $i18n->get("templateIdViewAlbum label"),
            hoverHelp       => $i18n->get("templateIdViewAlbum description"),
        },
        templateIdViewAlbumRss => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryAlbum/ViewRss",
            label           => $i18n->get("templateIdViewAlbumRss label"),
            hoverHelp       => $i18n->get("templateIdViewAlbumRss description"),
        },
        templateIdViewFile  => {
            tab             => "display",
            fieldType       => "template",
            defaultValue    => "",
            namespace       => "GalleryFile/View",
            label           => $i18n->get("templateIdViewFile label"),
            hoverHelp       => $i18n->get("templateIdViewFile description"),
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
        icon                => 'newWobject.gif',
        autoGenerateForms   => 1,
        tableName           => 'Gallery',
        className           => __PACKAGE__,
        properties          => \%properties,
    };

    return $class->SUPER::definition($session, $definition);
}

#----------------------------------------------------------------------------

=head2 getTemplateEditFile ( )

Returns an instance of a WebGUI::Asset::Template for the template to edit 
files in this gallery

NOTE: This may need to change in the future to take into account different
classes of files inside of a Gallery.

=cut

sub getTemplateEditFile {
    my $self        = shift;
    return WebGUI::Asset::Template->new($self->session, $self->get("templateIdEditFile"));
}

#----------------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    $template->prepare;
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;	
    my $var     = $self->get;

    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

1;
