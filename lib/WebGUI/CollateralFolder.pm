package WebGUI::CollateralFolder;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use warnings;

use WebGUI::Collateral;
use WebGUI::Persistent::Tree;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Persistent::Tree);

=head1 NAME 

Package WebGUI::CollateralFolder

=head1 DESCRIPTION

This is a management package for the collateral folder system.

=head2 SYNOPSIS

 use WebGUI::CollateralFolder;
 $collateralFolder->recursiveDelete;

=head1 METHODS

For inherited methods see L<WebGUI::Persistent::Tree>.

=cut

#-------------------------------------------------------------------

sub classSettings {
  return {
    properties => {
      name               => { quote        => 1 },
      parentId           => { defaultValue => 0 },
      collateralFolderId => { key          => 1 },
      description        => { quote        => 1 }
    },
    table => 'collateralFolder'
  }  
}

#-------------------------------------------------------------------

=head2 recursiveDelete ()

Recursively delete a folder, sub folders and contents

=cut

sub recursiveDelete {
  my ($self) = @_;
  my @ids = $self->SUPER::recursiveDelete();
  return unless @ids;

  # If WebGUI::Collateral inherited from WebGUI::Persistent then we would only
  # need the following line:
  # WebGUI::Collateral->multiDelete(collateralFolderId => \@ids);

  my @collateralIds = WebGUI::SQL->buildArray("select collateralId from collateral where collateralFolderId in (".quoteAndJoin(\@ids).")");
  WebGUI::Collateral->multiDelete(@collateralIds);
}

1;
