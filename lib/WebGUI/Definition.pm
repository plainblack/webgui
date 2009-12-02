package WebGUI::Definition;

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
use namespace::autoclean;
use WebGUI::Definition::Meta::Class;
use WebGUI::Definition::Meta::Property;
no warnings qw(uninitialized);

our $VERSION = '0.0.1';

my ($import, $unimport, $init_meta) = Moose::Exporter->build_import_methods(
    install         => [ 'unimport' ],
    with_meta       => [ 'property', 'attribute' ],
    also            => 'Moose',
    roles           => [ 'WebGUI::Definition::Role::Object' ],
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
    $options{metaclass} = 'WebGUI::Definition::Meta::Class';
    return Moose->init_meta(%options);
}

sub attribute {
    my ($meta, $name, $value) = @_;
    if ($meta->can($name)) {
        $meta->$name($value);
        $meta->add_method( $name, sub { $meta->$name } );
    }
    else {
        $meta->add_method( $name, sub { $value } );
    }
    return 1;
}

sub property {
    my ($meta, $name, %options) = @_;
    my %form_options;
    my $prop_meta = 
    $meta->property_meta;
    #'WebGUI::Definition::Meta::Property';
    for my $key ( keys %options ) {
        if ( ! $prop_meta->meta->find_attribute_by_name($key) ) {
            $form_options{$key} = delete $options{$key};
        }
    }
    $meta->add_attribute(
        $name,
        is => 'rw',
        metaclass => $prop_meta,
        form => \%form_options,
        %options,
    );
    return 1;
}

1;

