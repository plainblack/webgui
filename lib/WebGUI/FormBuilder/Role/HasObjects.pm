package WebGUI::FormBuilder::Role::HasObjects;

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

use WebGUI::BestPractices;
use Moose::Role;

has 'objects' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

# Objects combines "fields", "fieldsets", and "tabsets"

=head1 NAME

Package WebGUI::FormBuilder::Role::HasObjects

=head1 DESCRIPTION

Role that provides an attribute for holding a set of objects.

=head1 SYNOPSIS

This method is used by several FormBuilder packages that need to nest objects.  For example, a FormBuilder object
can have multiple tabs, each of which can contain multiple form fields.  The role provides an objects attribute,
and an addObject method for pushing an object onto the list of objects.

    with 'WebGUI::FormBuilder::Role::HasObjects';

=head1 METHODS

=head2 addObject ($object)

Adds $object to the list of objects for the consumer.

=head3 $object

Some variable, or data.  It really can be anything.

=cut

sub addObject {
    my ( $self, $object ) = @_;
    push @{$self->objects}, $object;
    return $object;
}

=head2 addObjectAt ( $object, $position )

Adds $object to the list of objects at a certain position, pushing all other
objects down.

=head3 $object

Some object

=head3 $position

The numeric index. 0 is the first object.

=cut

sub addObjectAt {
    my ( $self, $object, $position ) = @_;
    splice @{$self->objects}, $position, 0, $object;
    return $object;
}

=head2 toTemplateVars ( prefix, var )

Get all the objects as a set of template vars with the given prefix. $var is 
an optional hashref to add the variables to.

=cut

sub toTemplateVars {
    my ( $self, $prefix, $var ) = @_;
    $prefix ||= "";
    $var ||= {};

    # Loop over all objects, adding to appropriate template loops
    for my $obj ( @{ $self->objects } ) {
        # Prepare our object's variables and add to object type loop
        my $props = {};

        given ( blessed $obj ) {
            when ( undef ) {
                # Treat as raw template properties
                $props = $obj;
            }
            when ( $_->isa( 'WebGUI::FormBuilder::Tabset' ) ) {
                my $name = $obj->name;
                $props   = $obj->toTemplateVars;
                $props->{ isTabset } = 1;
                for my $key ( keys %{$props} ) {
                    $var->{ "${prefix}tabset_${name}_${key}" } = $props->{$key};
                }
                push @{$var->{ "${prefix}tabsetloop" }}, $props;
            }
            when ( $_->isa( 'WebGUI::FormBuilder::Fieldset' ) ) {
                my $name = $obj->name;
                $props   = $obj->toTemplateVars;
                $props->{ isFieldset } = 1;
                for my $key ( keys %{$props} ) {
                    $var->{ "${prefix}fieldset_${name}_${key}" } = $props->{$key};
                }
                push @{$var->{ "${prefix}fieldsetloop" }}, $props;
            }
            # Form field objects
            when ( $_->isa( 'WebGUI::Form::Control' ) ) {
                my $name    = $obj->get('name');
                $props      = $obj->toTemplateVars;
                # Add the whole field to the vars
                $props->{ field } = $obj->toHtmlWithWrapper;
                $props->{ field_input } = $obj->toHtml;
                $var->{ "${prefix}field_${name}" } = $props->{ field };
                # Add to fieldloop
                push @{$var->{"${prefix}fieldloop"}}, $props;
                # Individual accessors
                for my $key ( keys %{$props} ) {
                    $var->{ "${prefix}field_${name}_${key}" } = $props->{$key};
                }
                # Loop accessor
                push @{$var->{ "${prefix}field_${name}_loop" }}, $props;
            }
        }

        # Add to the global object loop
        push @{ $var->{ "${prefix}objects" } }, $props;
    }

    return $var;
}

1;

