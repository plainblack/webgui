package WebGUI::AssetHelper::CreateShortcut;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;

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

=head1 NAME

Package WebGUI::AssetHelper::CreateShortcut

=head1 DESCRIPTION

Create a shortcut to the asset and put it on the clipboard

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $asset )

Create a shortcut to the asset on the clipboard.

=cut

sub process {
    my ($self, $asset) = @_;
    my $session = $asset->session;
    my $i18n = WebGUI::International->new( $session, 'WebGUI' );

    return { error => $i18n->get('39') } if !$asset->canView;
    my $import = WebGUI::Asset->getImportNode( $session );
    my $tag = WebGUI::VersionTag->getWorking( $session );
    my $child = $import->addChild({
        tagId       => $tag->getId,
        status      => 'pending',
        className   => 'WebGUI::Asset::Shortcut',
        shortcutToAssetId => $asset->getId,
        title       => $asset->getTitle,
        menuTitle   => $asset->getMenuTitle,
        isHidden    => $asset->isHidden,
        newWindow   => $asset->newWindow,
        ownerUserId => $asset->ownerUserId,
        groupIdEdit => $asset->groupIdEdit,
        groupIdView => $asset->groupIdView,
        url         => $asset->title,
        templateId  => 'PBtmpl0000000000000140',
    });

    $child->cut;

    if (WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        allowComments   => 1,
        returnUrl       => $asset->getUrl,
    }) eq 'redirect') {
        return {
            message => $i18n->get('shortcut created'),
            redirect => $session->request->location,
        };
    };

    return {
        message => $i18n->get('shortcut created'),
    };
}

1;
