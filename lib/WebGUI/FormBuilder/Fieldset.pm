package WebGUI::FormBuilder::Fieldset;

use strict;
use Moose;
use MooseX::Storage;

has 'name' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has 'label' => (
    is      => 'rw',
    isa     => 'Str',
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

Create a new Fieldset object. C<session> is a WebGUI Session. C<properties> is
a list of name => value pairs.


=over 4

=item name

Required. The name of the fieldset. Cannot be changed after initially set, 
otherwise the parent <form> may not work correctly.

=item label

Optional. A label to show the user.

=item legend

Optional. A synonym for C<label>.

=back

=cut

sub new {
    my ( $class, $session, %properties ) = @_;
    $properties{ session } = $session;
    $properties{ label } ||= delete $properties{ legend };
    return $class->SUPER::new( %properties );
}

#----------------------------------------------------------------------------

=head2 label ( newLabel )

A label to show the user

=cut

#----------------------------------------------------------------------------

=head2 legend ( newLegend )

A synonym for label.

=cut

sub legend {
    my ( $self, @args ) = @_;
    return $self->label( @args );
}

#----------------------------------------------------------------------------

=head2 name ( )

The name of the fieldset. Read-only.

=cut

#----------------------------------------------------------------------------

=head2 session ( )

Get the WebGUI::Session attached to this object

=cut

#----------------------------------------------------------------------------

=head2 toHtml ( )

Returns the HTML to render the fieldset.

=cut

sub toHtml {
    my ( $self ) = @_;

    my $html = '<fieldset><legend>' . $self->label . '</legend>';
    $html   .= inner();
    $html   .= '</fieldset>';

    return $html;
}

1;
