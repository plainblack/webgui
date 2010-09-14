package WebGUI::Form::JsonTable;

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
use base 'WebGUI::Form::Control';
use WebGUI::International;
use JSON;

=head1 NAME

Package WebGUI::Form::JsonTable

=head1 DESCRIPTION

Creates a table to edit a JSON blob

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 fields

An array of hashrefs defining the fields in this JsonTable. 

 {
     type       => "text",                      # One of "text", "select", or "readonly"
     name       => "name",                      # The name of the field
     label      => "Name",                      # an i18n label
     options    => [ option => "label", ... ]   # Options for select fields
 }


=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
    push @{$definition}, {
        fields      => {
            defaultValue        => [],
        },
    };
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the name of the form control.

=cut

sub getName {
    my ($class, $session) = @_;
    return WebGUI::International->new($session, "Form_JsonTable")->get("topicName");
}

#-------------------------------------------------------------------

=head2 getOriginalValue ( )

Get the original value, encoding to JSON if necessary

=cut

sub getOriginalValue {
    my ( $self ) = @_;
    my $value   = $self->SUPER::getOriginalValue;
    if ( ref $value eq "ARRAY" ) {
        return JSON->new->encode( $value );
    }
    return $value;
}

#-------------------------------------------------------------------

=head2 getValue ( value )

Get the value of the field. Substitute id fields with GUIDs.

=cut

sub getValue {
    my ( $self, $value ) = @_;
    $value ||= $self->SUPER::getValue;

    $self->session->log->info( "JsonTable Got $value from form" );
    $value  = JSON->new->decode( $value );

    for my $row ( @{$value} ) {
        for my $field ( @{$self->get('fields')} ) {
            if ( $field->{type} eq 'id' && $row->{ $field->{name} } eq "new" ) {
                $row->{ $field->{name} } = $self->session->id->generate;
            }
        }
    }

    return JSON->new->encode( $value );
}

#-------------------------------------------------------------------

=head2 headTags ( )

Send JS required for this plugin.

=cut

sub headTags {
    my $self = shift;
    my ( $url, $style ) = $self->session->quick(qw( url style ));
    $style->setScript(
        $url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'),
        { type => 'text/javascript' },
    );
    $style->setScript(
        $url->extras('yui/build/json/json-min.js'),
        { type => 'text/javascript' },
    );
    $style->setScript(
        $url->extras('yui-webgui/build/form/jsontable.js'),
        { type => 'text/javascript' },
    );
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
    my $self    = shift;
    my $session = $self->session;
    my ( $url, $style ) = $session->quick(qw( url style ));
    my $value   = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters($self->getOriginalValue)));
    my $output  = '';

    # Table headers
    $output     .= '<table id="' . $self->get( 'id' ) . '"><thead><tr>';
    for my $field ( @{ $self->get('fields') } ) {
        $output .= '<th>' . $field->{label} . '</th>';
    }
    $output .= '<th>&nbsp;</th>'; # Extra column for buttons

    # Buttons to add rows in the table footer
    my $cols    = scalar @{ $self->get('fields') } + 1; # Extra column for buttons
    $output .= '</thead><tfoot><tr><td colspan="' . $cols . '">'
            . '<button id="' . $self->get('id') . '_add">' . "Add" . '</button>'
            . '</td></tr></tfoot>'
            ;

    # Build a hidden row to copy for new rows
    $output .= '<tbody><tr class="new_row" style="display: none">';
    for my $field ( @{ $self->get('fields') } ) {
        my $fieldName   = join "_", $self->get('name'), $field->{name};
        # Drawing using raw HTML to sanitize field HTML and allow future merging with DataTable
        my $fieldHtml;

        if ( $field->{type} eq "text" ) {
            $fieldHtml  = '<input type="text" name="' . $fieldName . '" size="' . $field->{size} . '" />';
        }
        elsif ( $field->{type} eq "select" ) {
            $fieldHtml  = '<select name="' . $fieldName . '" size="' . $field->{size} . '">';
            my $opts    = @{$field->{options}} / 2;     # options is arrayref of name => label
            for my $i ( 0 .. $opts-1 ) {
                my $optValue    = $field->{options}[$i*2];
                my $optLabel    = $field->{options}[$i*2+1];
                $fieldHtml  .= '<option value="' . $optValue . '">' . $optLabel . '</option>';
            }
            $fieldHtml  .= '</select>';
        }
        elsif ( $field->{type} eq "id" ) {
            $fieldHtml  .= '<input type="hidden" class="jsontable_id" name="' . $fieldName . '" value="new" />';
        }
        else {  # Readonly or unknown
            $fieldHtml  = '&nbsp;';
        }

        $output .= '<td>' . $fieldHtml . '</td>';
    }

    $output .= '<td></td>'      # Extra cell for buttons
            . '</tr></tbody></table>';

    # Build the existing rows
    $output .= '<input type="hidden" name="' . $self->get('name') . '" value="' . $value . '" />';

    # Existing rows are entirely built in javascript from the JSON in the hidden field
    $output .= '<script type="text/javascript">'
            . q{new WebGUI.Form.JsonTable("} . $self->get('name') . q{","} . $self->get( 'id' ) . q{", }
            . JSON->new->encode( $self->get('fields') ) . q{ );}
            . '</script>';

    $self->headTags;
    return $output;
}

1;
#vim:ft=perl
