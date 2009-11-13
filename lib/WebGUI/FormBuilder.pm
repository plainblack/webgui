package WebGUI::FormBuilder;

use strict;
use Moose;
use MooseX::Storage;

has 'action' => ( is => 'rw' );
has 'enctype' => ( is => 'rw', default => 'multipart/form-data' );
has 'method' => ( is => 'rw', default => 'POST' );
has 'name' => ( is => 'rw' );
has 'session' => ( 
    is => 'ro', 
    isa => 'WebGUI::Session', 
    required => 1, 
    weak_ref => 1,
    traits => [ 'DoNotSerialize' ],
);

with Storage( format => 'JSON' );
with 'WebGUI::FormBuilder::Role::HasFields';
with 'WebGUI::FormBuilder::Role::HasFieldsets'; 
with 'WebGUI::FormBuilder::Role::HasTabs';

=head1 METHODS

#----------------------------------------------------------------------------

=head2 new ( session, properties )

Create a new FormBuilder object. C<properties> is a list of name => value pairs

=over 4

=item name

The name of the form. Optional, but recommended.

=item action

The URL to submit the form to.

=item method

The HTTP method to submit the form with. Defaults to POST. 

=item enctype

The encoding type to use for the form. Defaults to "multipart/form-data". The 
other possible value is "application/x-www-form-urlencoded".

=back

=cut

sub new {
    my ( $class, $session, %properties ) = @_;
    $properties{ session    } = $session;
    return $class->SUPER::new( %properties );
}

#----------------------------------------------------------------------------

=head2 action ( [ newAction ] )

Get or set the action property / HTML attribute.

=cut

#----------------------------------------------------------------------------

=head2 clone ( )

Create a clone of this Form

=cut

sub clone {
    my ( $self ) = @_;
    return (ref $self)->newFromHashRef( $self->toHashRef );
}

#----------------------------------------------------------------------------

=head2 enctype ( [ newEnctype ] )

Get or set the enctype property / HTML attribute.

=cut

#----------------------------------------------------------------------------

=head2 method ( [ newMethod ] )

Get or set the method property / HTML attribute.

=cut

#----------------------------------------------------------------------------

=head2 name ( [ newName ] )

Get or set the name property / HTML attribute.

=cut

#----------------------------------------------------------------------------

=head2 session ( )

Get the WebGUI::Session attached to this object

=cut

#----------------------------------------------------------------------------

=head2 toHtml ( )

Return the HTML for the form

=cut

sub toHtml {
    my ( $self ) = @_;
    
    my @attrs   = qw{ action method name enctype };
    my $attrs   = join " ", map { qq{$_="} . $self->get($_) . qq{"} } @attrs;

    my $html    = sprintf '<form %s>', $attrs;
    $html   .= $self->maybe::next::method;
    $html   .= '</form>';

    return $html;
}

#----------------------------------------------------------------------------

=head2 toTemplateVars ( prefix, [var] )

Get the template variables for the form's controls with the given prefix. 
C<var> is an optional hashref to add the variables to.

=cut

sub toTemplateVars {
    my ( $self, $prefix, $var ) = @_;
    $prefix ||= "form";
    $var ||= {};

    # TODO
    # $prefix_header
    # $prefix_footer
    # $prefix_field_loop
    #   name    -- for comparisons
    #   field
    #   label   -- includes hoverhelp
    #   label_nohover
    #   pretext
    #   subtext
    #   hoverhelp   -- The text. For use with label_nohover
    # $prefix_field_$fieldName
    # $prefix_label_$fieldName
    # $prefix_fieldset_loop
    #   name
    #   legend
    #   label       -- same as legend
    #   $prefix_field_loop
    #       ...
    #   $prefix_fieldset_loop
    #       ...
    #   $prefix_tab_loop
    #       ...
    # $prefix_fieldset_$fieldsetName
    #   ...
    # $prefix_tab_loop
    #   name
    #   label
    #   $prefix_field_loop
    #       ...
    #   $prefix_fieldset_loop
    #       ...
    #   $prefix_tab_loop
    #       ...
    # $prefix_tab_$tabName
    #   ...
    return $var;
}

=head1 TEMPLATES

=head2 Default View

This is a Template Toolkit template that will recreate the default toHtml() view
of a form.

 # TODO

=cut

1;
