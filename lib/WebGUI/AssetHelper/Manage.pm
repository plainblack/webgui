package WebGUI::AssetHelper::Manage;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;
use WebGUI::User;
use WebGUI::HTML;

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

Package WebGUI::AssetHelper::Manage

=head1 DESCRIPTION

Displays the asset manager, starting at this Asset.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Opens a new tab for displaying the Asset Manager, starting at this Asset.

=cut

sub process {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    my $i18n = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }

    return {
        open_tab => $asset->getManagerUrl,
    };
}

1;
