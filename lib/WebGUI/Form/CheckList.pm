package WebGUI::Form::CheckList;

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
use base 'WebGUI::Form::List';
use WebGUI::Form::Checkbox;
use WebGUI::Form::Button;
use WebGUI::Form::Hidden;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::CheckList

=head1 DESCRIPTION

Creates a series of check box form fields.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::List. Also take a look at WebGUI::Form::Checkbox as this class creates a list of checkboxes.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 vertical

Boolean representing whether the checklist should be represented vertically or horizontally. If set to "1" will be displayed vertically. Defaults to "0".

=head4 showSelectAll

Flag that toggles a "Select All" toggle button on or off.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift || [];
    push @{$definition}, {
        vertical => {
            defaultValue    => 0,
        },
        showSelectAll => {
            defaultValue    => 0,
        },
    };
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('941');
}

#-------------------------------------------------------------------

=head2 getSelectAllButton ( )

Returns the HTML / Script for the Select All button

=cut

sub getSelectAllButton {
    my $self        = shift;
    my $formName    = $self->get('name');
    my $i18n        = WebGUI::International->new($self->session, "Form_CheckList");

    return WebGUI::Form::Button->new($self->session, {
        name        => $self->privateName('selectAllButton'),
        value       => $i18n->get("selectAll label"),
        extras      => q{onclick="WebGUI.Form.toggleAllCheckboxesInForm(this.form,'}
                    . $formName
                    . q{')"}
                    . q{ class="selectAllButton" },
        })->toHtml
        . q{<br />}
        ;   
}

#-------------------------------------------------------------------

=head2 headTags ( )

Set the head tags for this form plugin

=cut

sub headTags {
    my $self = shift;
    $self->session->style->setScript( $self->session->url->extras("yui-webgui/build/form/form.js"));
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 isInRequest ( )

=cut

sub isInRequest {
    my $self = shift;
    my $form = $self->session->form;
    return $form->hasParam($self->privateName('isIn'));
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a series of checkboxes.

=cut

sub toHtml {
	my $self    = shift;
    $self->headTags;
    my $session = $self->session;
    my $output = '<fieldset style="border:none;margin:0;padding:0">';
    $output .= WebGUI::Form::Hidden->new($session, { name => $self->privateName('isIn'), value => 1, })->toHtml;
	my $alignment   = $self->alignmentSeparator;

    # Add the select all button
    if ($self->get("showSelectAll")) {
        $output .= $self->getSelectAllButton;
    }
    my $i=0;
    my $options = $self->getOptions;
	foreach my $key (keys %{$options}) {
	    $i++;
        my @values = $self->getOriginalValue;
        my $checked = (grep { $_ eq $key } @values)
                    ? 1
                    : 0
                    ;
        $output .= WebGUI::Form::Checkbox->new($session, {
                name    => $self->get('name'),
                value   => $key,
                extras  => $self->get('extras'),
                checked => $checked,
                id => $self->get('name').$i,
            })->toHtml
            . '<label for="'.$self->get('name').$i.'">'.$options->{$key}."</label>" 
            . $alignment
            ;
    }
    $output .= "</fieldset>";
    return $output;
}

1;

