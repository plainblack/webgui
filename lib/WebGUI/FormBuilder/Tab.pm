package WebGUI::FormBuilder::Tab;

use strict;
use Moose;
use MooseX::Storage;

has 'label' => (
    is      => 'rw',
    isa     => 'Str',
);

has 'name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has 'session' => ( 
    is          => 'ro', 
    isa         => 'WebGUI::Session', 
    required    => 1, 
    weak_ref    => 1,
    traits      => [ 'DoNotSerialize' ],
);

with Storage( format => 'JSON' );
with 'WebGUI::FormBuilder::Role::HasFields';
with 'WebGUI::FormBuilder::Role::HasFieldsets';
with 'WebGUI::FormBuilder::Role::HasTabs';

=head1 METHODS

=cut

#----------------------------------------------------------------------------

=head2 new ( session, properties )

Create a new Tab object. C<session> is a WebGUI Session. C<properties> is a 
list of name => value pairs.

=over 4

=item name

Required. A name for the tab. 

=item label

Optional. A label for the tab.

=back

=cut

sub BUILDARGS {
    my ( $class, $session, %properties ) = @_;
    $properties{ session } = $session;
    return \%properties;
}

#----------------------------------------------------------------------------

=head2 label ( newLabel )

A label to show the user

=cut

#----------------------------------------------------------------------------

=head2 name ( )

The name of the fieldset.

=cut

#----------------------------------------------------------------------------

=head2 session ( )

Get the WebGUI::Session attached to this object

=cut

#----------------------------------------------------------------------------

=head2 toHtml ( )

Render the objects in this tab

=cut

sub toHtml {
    my ( $self ) = @_;
    my $html;
    for my $obj ( @{ $self->objects } ) {
        if ( $obj->isa('WebGUI::Form::Control') ) {
            $html .= $obj->toHtmlWithWrapper;
        }
        else {
            $html .= $obj->toHtml;
        }
    }
    return $html;
}

#----------------------------------------------------------------------------

=head2 toTemplateVars ( )

Get the template vars for this tab

=cut

around toTemplateVars => sub {
    my ( $orig, $self ) = @_;
    my $var = $self->$orig();
    $var->{ name } = $self->name;
    $var->{ label } = $self->label;
    return $var;
};

1;
