package WebGUI::AssetHelper::Revisions;

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

Package WebGUI::AssetHelper::Revisions

=head1 DESCRIPTION

Displays the revisions for this asset.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Opens a new tab for displaying revisions of this asset.

=cut

sub process {
    my ($class, $asset) = @_;

    return {
        open_tab => $asset->getUrl('func=manageRevisions'),
    };
}

1;
