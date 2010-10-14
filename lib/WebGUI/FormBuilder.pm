package WebGUI::FormBuilder;

use strict;
use Moose;
use MooseX::Storage;

=head1 NAME

WebGUI::FormBuilder - Build a form. Really.

=head1 SYNOPSIS

 my $f  = WebGUI::FormBuilder->new( $session, action => "/save", method => "GET" );
 $f->addField( 'Button',        # See WebGUI::Form::Button
    name    => 'Submit',
    label   => 'Submit',
 );

 my $tab = $f->addTab( "properties", "Properties" ); # "default" tabset
 $tab->addField( 'Text', name => "title" );
 $tab->addField( 'Text', name => "url" );

 my $html   = $f->toHtml;
 my $var    = $f->toTemplateVars;

=head1 DESCRIPTION

FormBuilder is used to build forms. Forms are made up of fields, tabsets, and fieldsets.

Forms can be exported directly to HTML, or they can be exported to template variables.

=head1 SEE ALSO

 WebGUI::FormBuilder::Tabset
 WebGUI::FormBuilder::Fieldset
 WebGUI::FormBuilder::Role::HasFields

=head1 ATTRIBUTES

=head2 action

The URL to submit the form to

=cut

has 'action' => ( is => 'rw' );

=head2 enctype

The encoding type to use for the form. Defaults to "multipart/form-data". The 
other possible value is "application/x-www-form-urlencoded".

=cut

has 'enctype' => ( is => 'rw', default => 'multipart/form-data' );

=head2 method

The HTTP method for the form. Defaults to POST.

=cut

has 'method' => ( is => 'rw', default => 'POST' );

=head2 name

The name of the form. Not required, but recommended.

=cut

has 'name' => ( is => 'rw' );

=head2 session

A WebGUI::Session object. Required.

=cut

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

Create a new FormBuilder object. C<properties> is a list of name => value pairs of
attributes.

=cut

sub BUILDARGS {
    my ( $class, $session, %properties ) = @_;
    $properties{ session    } = $session;
    return \%properties;
}

#----------------------------------------------------------------------------

=head2 clone ( )

Create a clone of this Form

=cut

sub clone {
    # TODO
}

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

=head2 toHtml ( )

Return the HTML for the form

=cut

sub toHtml {
    my ( $self ) = @_;
    my ( $style, $url ) = $self->session->quick(qw{ style url });

    $style->setCss( $url->extras('hoverhelp.css'));
    $style->setScript( $url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js') );
    $style->setScript( $url->extras('yui/build/container/container-min.js') );
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
