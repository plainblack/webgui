package WebGUI::Form::Color;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Style;

=head1 NAME

Package WebGUI::Form::Color

=head1 DESCRIPTION

Creates a color picker which returns hex colors like #000000.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("color","WebGUI");
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a hex color like "#000000". Returns undef if the return value is not a valid color.

=cut

sub getValueFromPost {
	my $self = shift;
	my $color = $session{req}->param($self->{name});
        return undef unless $color =~ /\#\w{6}/;
        return $color;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a color picker control.

=cut

sub toHtml {
	my $self = shift;
	WebGUI::Style::setScript($session{config}{extrasURL}.'/colorPicker.js',{ type=>'text/javascript' });
        return '<script type="text/javascript">initColorPicker("'.$self->{name}.'","'.($self->{value}).'");</script>';
}

1;

