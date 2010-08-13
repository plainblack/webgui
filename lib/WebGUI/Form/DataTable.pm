package WebGUI::Form::DataTable;

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

=head1 NAME

Package WebGUI::Form::DataTable

=head1 DESCRIPTION

Create an editable table. Users can add columns and rows to the table.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 ajaxDataUrl

This is the URL to get the data from, AJAX-style.

=head4 ajaxSaveUrl

This is the URL to send AJAX requests to. If this exists, will send 
updates to the table asyncronously. 

=head4 ajaxSaveFunc

This is the ?func= to send AJAX requests to.

=head4 ajaxSaveExtras

Any extra name=value pairs needed to save the data successfully

=head4 showEdit

If true, will enable the table for editing. This is only necessary when 
displaying the table with getValueAsHtml().

=head4 dateFormat

A strftime string describing the proper date format

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift || [];

    push @{$definition}, {
        showEdit       => { defaultValue => 0, },
        ajaxDataUrl    => { defaultValue => undef, },
        ajaxSaveUrl    => { defaultValue => undef, },
        ajaxSaveFunc   => { defaultValue => "view", },
        ajaxSaveExtras => { defaultValue => undef, },
        dateFormat     => { defaultValue => '%y-%m-%d', },
        };

    return $class->SUPER::definition( $session, $definition );
}

#-------------------------------------------------------------------

=head2 getDataTableHtml ( )

Render the DataTable

=cut

sub getDataTableHtml {
    my $self = shift;

    $self->prepare unless $self->{_prepared};

    my $data = JSON->new->decode( $self->getOriginalValue );
    my $id   = $self->get('id');

    # Get the HTML for the table
    my $html = $self->getTableHtml($data);

    ### Prepare the columns data
    my %parsers = (
        date   => "YAHOO.lang.JSON.stringToDate",
        number => "YAHOO.util.DataSource.parseNumber",
    );

    my %editors = (
        date    => "date",
        textbox => "textbox",
    );

    my $dateFormat  = $self->get('dateFormat') || '%y-%m-%d';

    my @columnsJson = ();
    for my $column ( @{ $data->{columns} } ) {

        # Not using a datastructure and JSON.pm because of function references for "parser"
        my $columnDef
            = '{'
            . qq["key" : "$column->{ key }", ]
            . qq["abbr" : "$column->{ key }", ]
            . qq["formatter" : "$column->{ formatter }", ]
            . ( $column->{formatter} eq "Date" ? qq["dateOptions" : { "format" : "$dateFormat" },] : "" )
            . qq["resizable" : 1, ]
            . qq["sortable" : 1];

        # Automatically determine the parser to use
        if ( $parsers{ $column->{formatter} } ) {
            $columnDef .= qq{, "parser" : $parsers{ $column->{ formatter } }};
        }

        # If we can edit
        if ( $self->get('showEdit') ) {

            # Set the editor
            my $editor = $editors{ $column->{formatter} }
                || $editors{"textbox"};
            $columnDef .= qq{, "editor" : "$editor"};
        }
        $columnDef .= '}';

        push @columnsJson, $columnDef;
    } ## end for my $column ( @{ $data...
    my $columnsJson = "[" . join( ",", @columnsJson ) . "]";

    ### Prepare any options
    my $options = {
        "showEdit"     => $self->get('showEdit'),
        "inputName"    => $self->get('name'),
        "ajaxDataUrl"  => $self->get('ajaxDataUrl'),
        "ajaxDataFunc" => $self->get('ajaxDataFunc'),
        "ajaxSaveUrl"  => $self->get('ajaxSaveUrl'),
        "ajaxSaveFunc" => $self->get('ajaxSaveFunc'),
        "dateFormat"   => $dateFormat,
    };
    my $optionsJson = JSON->new->encode($options);

    # Progressively enhance the bejesus out of it
    $html .= <<"ENDJS";
        <script type="text/javascript">
            new WebGUI.Form.DataTable( "$id-container", $columnsJson, $optionsJson );
        </script>
ENDJS

    return $html;
} ## end sub getDataTableHtml

#-------------------------------------------------------------------

=head2 getDefaultValue ( )

Get the default value. If none exists, return at least an appropriate
data structure.

=cut

sub getDefaultValue {
    my $self  = shift;
    my $value = $self->SUPER::getDefaultValue(@_);

    my $i18n = WebGUI::International->new($self->session, 'Form_DataTable');
    if ( !$value ) {
        $value = JSON->new->encode( {
                columns => [ {
                        key       => $i18n->get('New Column'),
                        formatter => "text",
                    },
                ],
                rows => [ { $i18n->get('New Column') => $i18n->get("Value"), }, ],
            }
        );
    }

    return $value;
} ## end sub getDefaultValue

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the name of the form control.

=cut

sub getName {
    my ( $class, $session ) = @_;
    return WebGUI::International->new( $session, "Form_DataTable" )->get("topicName");
}

#-------------------------------------------------------------------

=head2 getOriginalValue ( )

Get the original value, or the default value.

=cut

sub getOriginalValue {
    my $self  = shift;
    my $value = $self->SUPER::getOriginalValue(@_);

    if ( !$value ) {
        $value = $self->getDefaultValue;
    }

    return $value;
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Return the data for the table in a serialized JSON object with the following
structure.

 $VAR1 = {
     columns => [ 
         {
             key             => column name,
             formatter       => "", one of "button", "checkbox", "currency", "date", "dropdown",
                             "email", "link", "number", "radio", "text", "textarea", "textbox"
             // FUTURE ENHANCEMENTS
             editor          => "", one of "text", "date", "dropdown", "radio", "check"
             editorOptions   => [ ... ], needed for "dropdown", "radio", "check"
             resizable       => 1, 
             sortable        => 1, 
         },
     ],
     rows => [
         {
             column name => value,
             column name => value,
             ...
         },
     ]
 }

=cut

sub getValue {
    my $self  = shift;
    my $value = $self->SUPER::getValue(@_);

    # If passing in a data structure, encode to JSON
    if ( ref $value eq "HASH" ) {
        $value = JSON->new->encode($value);
    }

    return $value;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Get the value as HTML. Render the datatable in a non-editable form.

=cut

sub getValueAsHtml {
    my $self = shift;
    return $self->getDataTableHtml;
}

#-------------------------------------------------------------------

=head2 getTableHtml ( data )

Get the HTML to render the table. C<data> is the data structure with
columns and rows to render. 

=cut

sub getTableHtml {
    my $self = shift;
    my $data = shift;

    my $html = '<div id="' . $self->get('id') . '-container" class="yui-skin-sam">';

    # Only insert the table if we're not getting AJAX Data
    if ( !$self->get("ajaxDataUrl") ) {
        $html .= '<table id="' . $self->get('id') . '-container-table"><thead><tr>';

        for my $column ( @{ $data->{columns} } ) {
            $html .= '<th>' . $column->{key} . '</th>';
        }

        # TODO: Add table footer
        $html .= '</tr></thead><tbody>';

        for my $row ( @{ $data->{rows} } ) {
            $html .= '<tr>';

            for my $column ( @{ $data->{columns} } ) {
                $html .= '<td>' . $row->{ $column->{key} } . '</td>';
            }

            $html .= '</tr>';
        }

        $html .= '</tbody></table>';
    } ## end if ( !$self->get("ajaxDataUrl"...

    $html .= '</div>';

    # Add hidden form element to hold JSON
    if ( $self->get('showEdit') ) {
        $html .= '<input type="hidden" name="' . $self->get('name') . '" />';
    }

    return $html;
} ## end sub getTableHtml

#-------------------------------------------------------------------

=head2 prepare ( )

Load all the script and css files we need. Call this in prepareView() if needed.
Otherwise, is called automatically.

=cut

sub prepare {
    my $self = shift;

    # Source in the scripts
    my $style = $self->session->style;
    my $url   = $self->session->url;
    $style->setLink( $url->extras('yui/build/datatable/assets/skins/sam/datatable.css'),
        { rel => "stylesheet", type => "text/css" } );
    $style->setScript( $url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js') );
    $style->setScript( $url->extras('yui/build/element/element-min.js') );
    $style->setScript( $url->extras('yui/build/dragdrop/dragdrop-min.js') );
    $style->setScript( $url->extras('yui/build/connection/connection-min.js') );
    $style->setScript( $url->extras('yui/build/json/json-min.js') );

    # Prepare the editors
    if ( $self->get('showEdit') ) {
        $style->setLink(
            $url->extras( 'yui/build/button/assets/skins/sam/button.css', { rel => "stylesheet", type => "text/css" } )
        );
        $style->setLink(
            $url->extras(
                'yui/build/calendar/assets/skins/sam/calendar.css',
                { rel => "stylesheet", type => "text/css" }
            )
        );
        $style->setLink( $url->extras('yui/build/container/assets/skins/sam/container.css'),
            { rel => "stylesheet", type => "text/css" } );
        $style->setScript( $url->extras('yui/build/container/container-min.js') );
        $style->setScript( $url->extras('yui/build/button/button-min.js') );
        $style->setScript( $url->extras('yui/build/calendar/calendar-min.js') );
    } ## end if ( $self->get('showEdit'...

    $style->setScript( $url->extras('yui-webgui/build/i18n/i18n.js') );
    $style->setScript( $url->extras('yui/build/datasource/datasource.js') );
    $style->setScript( $url->extras('yui/build/datatable/datatable.js') );
    $style->setScript( $url->extras('yui-webgui/build/form/datatable.js') );

    $self->{_prepared} = 1;
    return;
} ## end sub prepare

#-------------------------------------------------------------------

=head2 toHtml ( )

Render the DataTable in an editable format.

=cut

sub toHtml {
    my $self = shift;
    $self->set( 'showEdit', 1 );
    return $self->getDataTableHtml;
}

1;

