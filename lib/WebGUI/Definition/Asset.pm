package WebGUI::Definition::Asset;

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

use 5.010;
use Moose;
use Moose::Exporter;
use WebGUI::Definition ();
use WebGUI::Definition::Meta::Asset;
use namespace::autoclean;
no warnings qw(uninitialized);

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition::Asset

=head1 DESCRIPTION

Moose-based meta class for all Asset definitions in WebGUI.

=head1 SYNOPSIS

A definition contains all the information needed to build an object.
Information required to build forms are added as optional roles and
sub metaclasses.  Database persistance is handled similarly.

=head1 METHODS

These methods are available from this class:

=cut

my ($import, $unimport, $init_meta) = Moose::Exporter->build_import_methods(
    install         => [ 'unimport' ],
    also            => 'WebGUI::Definition',
    with_meta       => [ 'property' ],
    roles           => [ 'WebGUI::Definition::Role::Asset' ],
);

sub import {
    my $class = shift;
    my $caller = caller;
    $class->$import({ into_level => 1 });
    warnings->unimport('uninitialized');
    namespace::autoclean->import( -cleanee => $caller );
    return 1;
}

sub init_meta {
    my $class = shift;
    my %options = @_;
    $options{metaclass} = 'WebGUI::Definition::Meta::Asset';
    return Moose->init_meta(%options);
}

#-------------------------------------------------------------------

=head2 property ( $name, %options )

Extends WebGUI::Definition::property to copy the table attribute from the
meta class into the options for each property.

=head3 $name

=head3 %options

=cut


sub property {
    my ($meta, $name, %options) = @_;
    $options{table} //= $meta->table;
    return WebGUI::Definition::property($meta, $name, %options);
}

1;

