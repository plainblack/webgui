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

sub property {
    my ($meta, $name, %options) = @_;
    $options{table} = $meta->table;
    return WebGUI::Definition::property($meta, $name, %options);
}

1;

