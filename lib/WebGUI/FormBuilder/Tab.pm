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

sub new {
    my ( $class, $session, %properties ) = @_;
    $properties{ session } = $session;
    return $class->SUPER::new( %properties );
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

Render this Tab.

=cut

sub toHtml {
    my ( $self ) = @_;
    
    # Whatever YUI Tabs wants
    my $html    = '<div class="yui-tab">'
                . '<div class="yui-tab-label">' . $self->label . '</div>'
                ;
    $html   .= $self->maybe::next::method;
    $html   .= '</div>';

    return $html;
}

1;
