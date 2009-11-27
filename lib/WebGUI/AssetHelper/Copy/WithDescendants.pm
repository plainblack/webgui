package WebGUI::AssetHelper::Copy::WithDescendants;

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

Package WebGUI::AssetHelper::Copy::WithDescendants

=head1 DESCRIPTION

Copy an Asset to the Clipboard, with all descendants.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 duplicate ( $class, $asset )

Duplicates the asset with descendants.

=cut

sub duplicate {
    my ($class, $asset) = @_;
    return $asset->duplicateBranch();
}

#-------------------------------------------------------------------

=head2 getMessage ( )

Returns the name of the i18n message to use

=cut

sub getMessage {
    return 'copied asset with descendants';
}

1;
