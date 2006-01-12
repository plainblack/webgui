package WebGUI::Form::Color;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

Package WebGUI::Form::Color

=head1 DESCRIPTION

Creates a color picker which returns hex colors like #000000.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( )

See the super class for additional details.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("color")
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a hex color like "#000000". Returns undef if the return value is not a valid color.

=cut

sub getValueFromPost {
	my $self = shift;
	my $color = $self->session->request->param($self->get("name"));
        return undef unless $color =~ /\#\w{6}/;
        return $color;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a color picker control.

=cut

sub toHtml {
	my $self = shift;
	$self->session->style->setScript($self->session->config->get("extrasURL").'/colorPicker.js',{ type=>'text/javascript' });
        return '<script type="text/javascript">initColorPicker("'.$self->get("name").'","'.($self->get("value")).'");</script>';
}

1;

