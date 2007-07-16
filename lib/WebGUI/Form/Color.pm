package WebGUI::Form::Color;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
        dbDataType  => {
            defaultValue    => "VARCHAR(7)",
        },
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( [ value ] )

Returns a hex color like "#000000". Returns undef if the return value is not a valid color.

=head2 value

An optional value to use instead of POST input.

=cut

sub getValueFromPost {
	my $self = shift;
	my $color = @_ ? shift : $self->session->form->param($self->get("name"));
	return undef unless $color =~ /\#\w{6}/;
	return $color;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a color picker control.

=cut

sub toHtml {
	my $self = shift;
    my $url = $self->session->url;
    my $style = $self->session->style;
	$style->setScript($url->extras('/yui/build/yahoo/yahoo-min.js'),{ type=>'text/javascript' });
	$style->setScript($url->extras('/yui/build/event/event-min.js'),{ type=>'text/javascript' });
	$style->setScript($url->extras('/yui/build/dom/dom-min.js'),{ type=>'text/javascript' });
	$style->setScript($url->extras('/yui/build/dragdrop/dragdrop-min.js'),{ type=>'text/javascript' });
	$style->setScript($url->extras('/yui/build/animation/animation-min.js'),{ type=>'text/javascript' });
	$style->setLink($url->extras('/colorpicker/colorpicker.css'),{ type=>'text/css', rel=>"stylesheet" });
	$style->setScript($url->extras('/colorpicker/color.js'),{ type=>'text/javascript' });
	$style->setScript($url->extras('/colorpicker/key.js'),{ type=>'text/javascript' });
	$style->setScript($url->extras('/yui/build/slider/slider-min.js'),{ type=>'text/javascript' });
	$style->setScript($url->extras('/colorpicker/colorpicker.js'),{ type=>'text/javascript' });
    my $id = $self->get("id");
    my $value = $self->get("value");
    return q| <a href="javascript:WebguiColorPicker.display('|. $id. q|');" id="|. $id.q|_swatch"
    class="colorPickerFormSwatch" style="background-color: |.$value.q|;"></a>
   <input onchange="document.getElementById('|.$id.q|_swatch').style.backgroundColor=this.value;" 
   maxlength="7" name="|.$self->get("name").q|" type="text" size="8" value="|.$value.q|" id="|.$id.q|" />|;

}

1;

