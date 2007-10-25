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
    my $i18n        = WebGUI::International->new($session, 'Asset_GalleryAlbum');

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

=head2 canEdit ( [userId] )

Returns true if the user can edit this asset. C<userId> is a WebGUI user ID. 
If no userId is passed, check the current user.

Users can edit this GalleryAlbum if they are the owner, or if they can edit
the Gallery parent.

=cut

sub canEdit {
    my $self        = shift;
    my $userId      = shift || $self->session->user->userId;
    my $gallery     = $self->getParent;

    return 1 if $userId eq $self->get("ownerUserId");
    return $gallery->canEdit($userId);
}

#-------------------------------------------------------------------

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
