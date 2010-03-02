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
use feature ();

use Moose::Exporter;
use WebGUI::Definition ();
use WebGUI::Definition::Meta::Asset;
use Moose::Util;
use Moose::Util::MetaRole;

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
    install          => [ 'unimport' ],
    also             => 'WebGUI::Definition',
);

#-------------------------------------------------------------------

=head2 import ( )

A custom import method is provided so that uninitialized properties do not
generate warnings.

=cut

sub import {
    my $class = shift;
    my $caller = caller;
    $class->$import({ into_level => 1 });
    warnings->unimport('uninitialized');
    feature->import(':5.10');
    namespace::autoclean->import( -cleanee => $caller );
    return 1;
}

sub init_meta {
    my $class = shift;
    my %args = @_;

    Moose::Util::MetaRole::apply_base_class_roles(
        for   => $args{for_class},
        roles => [ 'WebGUI::Definition::Role::Asset' ],
    );
    Moose::Util::MetaRole::apply_metaroles(
        for              => $args{for_class},
        class_metaroles  => {
            class           => ['WebGUI::Definition::Meta::Asset'],
        },
    );
    return $args{for_class}->meta;
}

1;
