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

use WebGUI::FormBuilder::Tab;
use WebGUI::FormBuilder::Tabset;
use WebGUI::FormBuilder::Fieldset;

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

sub BUILDARGS {
    my ( $class, $session, %properties ) = @_;
    $properties{ session    } = $session;
    return \%properties;
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
    # TODO
}

#----------------------------------------------------------------------------

=head2 enctype ( [ newEnctype ] )

Get or set the enctype property / HTML attribute.

=cut

#----------------------------------------------------------------------------

=head2 getFooter ( )

Get the footer for this form.

=cut

sub getFooter {
    my ( $self ) = @_;

    my $html    = '</form>';

    return $html;
}

#----------------------------------------------------------------------------

=head2 getHeader ( )

Get the header for this form. 

=cut

sub getHeader {
    my ( $self ) = @_;

    my @attrs   = qw{ action method name enctype };
    my $attrs   = join " ", map { qq{$_="} . $self->$_ . qq{"} } grep { $self->$_ } @attrs;

    my $html    = sprintf '<form %s>', $attrs;
    
    return $html;
}

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
    my ( $style, $url ) = $self->session->quick(qw{ style url });

    $style->setLink( $url->extras('hoverhelp.css'), { rel => "stylesheet", type => "text/css" } );
    $style->setScript( $url->extras('hoverhelp.js') );

    my $html = $self->getHeader;
    # Add individual objects
    for my $obj ( @{ $self->objects } ) {
        if ( $obj->isa('WebGUI::Form::Control') ) {
            $html .= $obj->toHtmlWithWrapper;
        }
        else {
            $html .= $obj->toHtml;
        }
    }
    $html   .= $self->getFooter;

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

    # $prefix_header
    $var->{ "${prefix}_header" } = $self->getHeader;
    # $prefix_footer
    $var->{ "${prefix}_footer" } = $self->getFooter;
    # $prefix_fieldloop
    #   name    -- for comparisons
    #   field
    #   label   -- includes hoverhelp
    #   label_nohover
    #   pretext
    #   subtext
    #   hoverhelp   -- The text. For use with label_nohover
    # $prefix_field_$fieldName
    if ( @{$self->fields} ) {
        my $fieldLoop = [];
        $var->{ "${prefix}_fieldloop" } = $fieldLoop;
        for my $field ( @{$self->fields} ) {
            my $name  = $field->get('name');
            my $props = {
                name            => $name,
                field           => $field->toHtml,
                label           => $field->getLabel,
                label_nohover   => $field->get('label'),
                pretext         => $field->get('pretext'),
                subtext         => $field->get('subtext'),
                hoverhelp       => $field->get('hoverhelp'),
            };
            for my $key ( keys %{$props} ) {
                $var->{ "${prefix}_field_${name}_${key}" } = $props->{$key};
            }
            push @{$fieldLoop}, $props;
        }
    }
    # $prefix_fieldsetloop
    #   name
    #   legend
    #   label       -- same as legend
    #   fieldloop
    #       ...
    #   fieldsetloop
    #       ...
    #   tabloop
    #       ...
    # $prefix_fieldset_$fieldsetName
    if ( @{$self->fieldsets} ) {
        my $fieldsetLoop = [];
        $var->{ "${prefix}_fieldsetLoop" } = $fieldsetLoop;
        for my $fieldset ( @{$self->fieldsets} ) {
            my $name    = $fieldset->name;
            my $props   = $fieldset->toTemplateVars;
            for my $key ( keys %{$props} ) {
                $var->{ "${prefix}_fieldset_${name}_${key}" } = $props->{key};
            }
            push @{$fieldsetLoop}, $props;
        }
    }
    # $prefix_tabloop
    #   name
    #   label
    #   fieldloop
    #       ...
    #   fieldsetloop
    #       ...
    #   tabloop
    #       ...
    # $prefix_tab_$tabName
    if ( @{$self->tabs} ) {
        my $tabLoop = [];
        $var->{ "${prefix}_tabLoop" } = $tabLoop;
        for my $tab ( @{$self->tabs} ) {
            my $name    = $tab->name;
            my $props   = $tab->toTemplateVars;
            for my $key ( keys %{$props} ) {
                $var->{ "${prefix}_tab_${name}_${key}" } = $props->{key};
            }
            push @{$tabLoop}, $props;
        }
    }

    return $var;
}

=head1 TEMPLATES

=head2 Default View

This is a Template Toolkit template that will recreate the default toHtml() view
of a form.

 # TODO

=cut

1;
