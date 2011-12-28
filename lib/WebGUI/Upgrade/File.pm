=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

WebGUI::Upgrade::File - Role for upgrade file classes

=head1 SYNOPSIS

    package WebGUI::Upgrade::File::ext;
    with 'WebGUI::Upgrade::File';

    sub run {
        my $self = shift;
        print "Running " . $self->file . "\n";
    }

=head1 DESCRIPTION

To be consumed by classes for running upgrade scripts.

=cut

package WebGUI::Upgrade::File;
use 5.010;
use Moose::Role;

=head1 REQUIRED METHODS

Classes consuming this role must implement the following methods:

=head2 run

This method much be implemented and should run the actual upgrade file on the config file.

=cut

requires 'run';

=head1 ATTRIBUTES

This role includes the following attributes.

=cut

=head2 file

The upgrade file to run.

=cut

has file => (
    is       => 'ro',
    required => 1,
);

=head2 version

The version the upgrade is for.

=cut

has version => (
    is       => 'ro',
    required => 1,
);

=head2 upgrade

The WebGUI::Upgrade object to use for this upgrade.

=cut

has upgrade => (
    is       => 'ro',
    required => 1,
    handles  => [ 'quiet' ],
);

=head1 METHODS

=head2 once

A method to be overridden that controls if the upgrade file should
be run more than once per server.

=cut

sub once { 0 }

1;

