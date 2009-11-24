package WebGUI::AssetHelper::Cut;

use Class::C3;
use base qw/WebGUI::AssetHelper/;
use WebGUI::Asset;

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

Package WebGUI::AssetHelper::Cut

=head1 DESCRIPTION

Cuts an Asset to the Clipboard.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Cuts the asset to the clipboard.  If the user cannot edit the asset, or the asset is a
system asset, it returns an error message.

=cut

sub process {
    my ($class, $asset) = @_;
    my $session = $asset->session;

    my $i18n = WebGUI::International->new($session, 'WebGUI');
    if (! $asset->canEdit) {
        return { error => $i18n->get('38'), };
    }
    elsif ( $asset->get('isSystem') ) {
        return { error => $i18n->get('41'), };
    }

    my $success = $asset->cut();
    if (! $success) {
        return { error => $i18n->get('41'), };
    }

    my $parent = $asset->getContainer;
    if ($asset->getId eq $parent->getId) {
        $parent = $asset->getParent;
    }
    return {
        message         => sprintf($i18n->get('cut asset', 'Asset'), $asset->getTitle),
        redirect        => $parent->getUrl,
    };
}

1;
