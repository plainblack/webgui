package WebGUI::Role::Asset::SetStoragePermissions;

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

=cut

=head1 NAME

Package WebGUI::Role::Asset::SetStoragePermissions

=head1 DESCRIPTION

Provide methods for the triggers on ownerUserId, groupIdEdit and groupIdView that update
the file permissions on storage locations for an Asset.

=head1 SYNOPSIS

with WebGUI::Role::Asset::SetStoragePermissions;

=cut

use Moose::Role;

sub _set_ownerUserId {
    my ($self, $new, $old) = @_;
    if ($new ne $old) {
		$self->getStorageLocation->setPrivileges($self->ownerUserId, $self->groupIdView, $self->groupIdEdit);
    }
}

sub _set_groupIdView {
    my ($self, $new, $old) = @_;
    if ($new ne $old) {
		$self->getStorageLocation->setPrivileges($self->ownerUserId, $self->groupIdView, $self->groupIdEdit);
    }
}

sub _set_groupIdEdit {
    my ($self, $new, $old) = @_;
    if ($new ne $old) {
		$self->getStorageLocation->setPrivileges($self->ownerUserId, $self->groupIdView, $self->groupIdEdit);
    }
}



1;
