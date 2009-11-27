package WebGUI::AssetHelper::Copy::WithChildren;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper::Copy/;

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

Package WebGUI::AssetHelper::Copy::WithChildren

=head1 DESCRIPTION

Copy an Asset to the Clipboard, with children only.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 duplicate ( $class, $asset )

Duplicates the asset.  Extracted out so that it can be subclassed by copy with children,
and copy with descendants.

=cut

sub duplicate {
    my ($class, $asset) = @_;
    return $asset->duplicateBranch(1);
}

#-------------------------------------------------------------------

=head2 getMessage ( )

Returns the name of the i18n message to use

=cut

sub getMessage {
    return 'copied asset with children';
}

1;
