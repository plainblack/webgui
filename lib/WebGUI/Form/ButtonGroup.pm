package WebGUI::Form::ButtonGroup;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Pluggable;

=head1 NAME

Package WebGUI::Form::ButtonGroup

=head1 DESCRIPTION

Creates a series of buttons

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

=head4 buttons 

The buttons in this button group

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
    push @{$definition}, {
        buttons => {
            defaultValue=>[],
        },
    };
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 addButton ( type, params )

Add a new button to the button group.

=cut

sub addButton {
    my ( $self, $type, $params ) = @_;
    my $buttons = $self->get('buttons');

    my $button = WebGUI::Pluggable::instanciate("WebGUI::Form::".ucfirst($type), "new", [$self->session, $params]);

    push @{$buttons}, $button;
    $self->set('buttons', $buttons);
    return $button;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a button group

=cut

sub toHtml {
    my $self    = shift;
    my $html    = '';

    for my $button ( @{ $self->get('buttons') } ) {
        $html .= $button->toHtml; # Inline as toHtml
    }
    return $html;
}

1;
#vim:ft=perl
