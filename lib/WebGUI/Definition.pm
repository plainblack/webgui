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

use strict;
use warnings;
no warnings qw(uninitialized);
use 5.010;

our $VERSION = '0.0.1';
use Sub::Name ();
use Clone ();
use mro ();

sub import {
    my $class = shift;
    if (! @_) {
        return;
    }
    my $definition = (@_ == 1 && ref $_[0]) ? $_[0] : { @_ };
    my $caller = caller;
    # ensure we are using c3 method resolution
    mro::set_mro($caller, 'c3');

    # construct an ordered list and hash of the properties
    my @propertyList;
    my %properties;
    if ( my $properties = delete $definition->{properties} ) {
        # accept a hash and alphabetize it
        if (ref $properties eq 'HASH') {
            $properties = [ map { $_ => $properties->{$_} } sort keys %{ $properties } ];
        }
        for (my $i = 0; $i < @{ $properties }; $i += 2) {
            my $property = $properties->[$i];
            push @propertyList, $property;
            $properties{ $property } = $properties->[$i + 1];
        }
    }

    # accessors for properties
    for my $property ( @propertyList ) {
        no strict 'refs';
        $class->_install($caller, $property, sub {
            if (@_ > 1) {
                my $value = $_[1];
                # call _set_$property with set value and use return value for actual value
                if (my $set = $_[0]->can('_set_' . $property)) {
                    $value = $_[0]->$set($value);
                }
                return $_[0]{properties}{$property} = $value;
            }
            else {
                # call _get_$property and use return
                if (my $get = $_[0]->can('_get_' . $property)) {
                    return $_[0]->$get($_[1]);
                }
                return $_[0]{properties}{$property};
            }
        });
    }

    $class->_install($caller, 'getProperty', sub {
        my $self = shift;
        my $property = shift;
        if (exists $properties{$property}) {
            my $subattributes = Clone::clone $properties{$property};
            if ( ref $self ) {
                for my $subattribute ( keys %{ $subattributes } ) {
                    my $attrValue = $subattributes->{$subattribute};
                    if ( ref $attrValue && ref $attrValue eq 'CODE' ) {
                        $subattributes->{$subattribute} = $self->$attrValue($property, $subattribute);
                    }
                }
            }
            return $subattributes;
        }
        return $self->maybe::next::method($property);
    });

    $class->_install($caller, 'getProperties', sub {
        my $self = shift;
        my %props = map { $_ => 1 } @propertyList;
        # remove any properties from superclass list that exist in this class
        my @allProperties = grep { ! $props{$_} } $self->maybe::next::method(@_);
        push @allProperties, @propertyList;
        return @allProperties;
    });

    $class->_install($caller, 'getAttribute', sub {
        my $self = shift;
        my $attribute = shift;
        if ( exists $definition->{$attribute} ) {
            return $definition->{$attribute};
        }
        return $self->maybe::next::method($attribute);
    });

    no strict 'refs';
    *{$caller . '::get'} = \&_get;
    *{$caller . '::set'} = \&_set;
    *{$caller . '::update'} = \&_update;
    *{$caller . '::instantiate'} = \&_instantiate;
}

sub _install {
    my ($class, $package, $subname, $sub) = @_;
    my $full_sub = $package . '::' . $subname;
    no strict 'refs';
    *{$full_sub} = Sub::Name::subname( $full_sub, $sub );
    return $sub;
}

sub _set {
    my $self = shift;
    my $properties = ( @_ == 1 && ref $_[0] ) ? $_[0] : { @_ };
    my %availProperties = map { $_ => 1 } $self->getProperties;
    for my $property ( keys %{ $properties } ) {
        if ( $availProperties{$property} ) {
            $self->$property( $properties->{$property} );
        }
    }
}

sub _get {
    my $self = shift;
    if (@_) {
        my $prop = shift;
        return $self->$prop;
    }
    my @all_properties = $self->getProperties;
    my %props;
    for my $property ( @all_properties ) {
        $props{$property} = $self->$property;
    }
    return \%props;
}

sub _update {
    my $self = shift;
    $self->set(@_);
    if ($self->can('write')) {
        $self->write;
    }
}

sub _instantiate {
    my $class = shift;
    my $self = bless {
        properties => {},
    }, $class;
    $self->set(@_);
    return $self;
};

1;

__END__

=head1 NAME

WebGUI::Definition - Define properties for a class

=head1 SYNOPSIS

    package MyClass;
    use WebGUI::Definition (
        name => 'My Class',
        properties => [
            'myProperty' => {
                label => "Class Property",
            },
        ],
    );
    my $object = MyClass->instantiate;

    # property list
    $object->getProperties;

    # property attributes
    $object->getProperty('myProperty');

    # attribute value
    $object->getAttribute('name');

    # generated accessor
    $object->myProperty('value');

=head1 DESCRIPTION

Define properties and attributes for a class.

All information about the class is provided as a hash to WebGUI::Definition
by the import method.  This is usually called when 'use'ing the
module.

=head1 ATTRIBUTES

The top level values given the WebGUI::Definition are attributes.  Your class will make them available using the getAttribute method.  One exception to this is the 'properties' attribute.  It is not available through getAttribute but instead creates its own methods.

=head1 PROPERTIES

For each property, an accessor is created using the property name.

=head1 METHODS

=head2 import

Defines the class.

=head1 METHODS CREATED

=head2 getAttribute ( $attribute )

Returns the value of the given attribute the class or any of its superclasses.

=head2 getProperties ( )

Returns a list of all of the properties for the class.

=head2 getProperty ( $property )

Returns the attributes for the given property.

=head2 get ( [ $property ] )

Retrieves the value of the given property.  If no property is
specified, returns all of the properties as a hash reference.

=head2 set ( $properties )

Accepts a hash reference and sets all of the given properties.

=head2 update ( $properties )

Sets properties just as L</set> does, then calls the C<write> method if it is available in the class.

=head2 instantiate ( $properties )

Creates a new object instance, setting the given properties.

=head2 $property

An accessor is created for each property.

=cut


