package WebGUI::Form::CheckList;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=head4 showSelectAllButton

Flag that toggles a "Select All" toggle button on or off.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift || [];
    my $i18n        = WebGUI::International->new($session);
    push @{$definition}, {
        formName => {
            defaultValue    => $i18n->get("941"),
        },
        vertical => {
            defaultValue    => 0,
        },
        profileEnabled => {
            defaultValue    => 1,
        },
        showSelectAll => {
            defaultValue    => 0,
        },
    };
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getSelectAllButton ( )

Returns the HTML / Script for the Select All button

=cut

sub getSelectAllButton {
    my $self        = shift;
    my $formName    = $self->get('name');
    my $i18n        = WebGUI::International->new($self->session, "Form_CheckList");

    $self->session->style->setScript(
        $self->session->url->extras("yui-webgui/build/form/form.js")
    );

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

=head2 toHtml ( )

Renders a series of checkboxes.

=cut

sub toHtml {
	my $self        = shift;
	my $output;
	my $alignment   = $self->alignmentSeparator;

    # Add the select all button
    if ($self->get("showSelectAll")) {
        $output .= $self->getSelectAllButton;
    }
    my $i=0;
    tie my %options, 'Tie::IxHash', $self->orderedHash();
	foreach my $key (keys %options) {
	$i++;
        my $checked = (grep { $_ eq $key } @{ $self->get('value') })
                    ? 1
                    : 0
                    ;

        $output 
            .= WebGUI::Form::Checkbox->new($self->session, {
                name    => $self->get('name'),
                value   => $key,
                extras  => $self->get('extras'),
                checked => $checked,
                id => $self->get('name').$i,
            })->toHtml
            . '<label for="'.$self->get('name').$i.'">'.$self->get('options')->{$key}."</label>" 
            . $alignment
            ;
    }

    return $output;
}

1;

