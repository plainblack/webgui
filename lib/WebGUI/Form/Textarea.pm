package WebGUI::Form::Textarea;

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
use base 'WebGUI::Form::Control';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Textarea

=head1 DESCRIPTION

Creates a text area form field.

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

=head4 width

The width of this control in pixels. Defaults to 400 pixels.

=head4 height

The height of this control in pixels.  Defaults to 150 pixels.

=head4 style

Style attributes besides width and height which should be specified using the above parameters. Be sure to escape quotes if you use any.

=head4 resizable 

A boolean indicating whether the text area can be reized by users. Defaults to 1.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		height=>{
			defaultValue=> 150
			},
		width=>{
			defaultValue=> 400
			},
		style=>{
			defaultValue => undef,
			},
		resizable => {
			defaultValue => 1,
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "LONGTEXT".

=cut 

sub getDatabaseFieldType {
    return "LONGTEXT";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('476');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
	my $self = shift;
 	my $value = $self->fixMacros($self->fixTags($self->fixSpecialCharacters($self->getDefaultValue)));
	my $width = $self->get('width') || 400;
	my $height = $self->get('height') || 150;
	my ($style, $url) = $self->session->quick(qw(style url));
	my $styleAttribute = "width: ".$width."px; height: ".$height."px; ".$self->get("style");
    $style->setRawHeadTags(qq|<style type="text/css">\ntextarea#|.$self->get('id').qq|{ $styleAttribute }\n</style>|);
	my $out = '<textarea id="'.$self->get('id').'" name="'.$self->get("name").'" '.$self->get("extras").' rows="#" cols="#" style="width: '.$width.'px; height: '.$height.'px;">'.$value.'</textarea>';
	if ($self->get("resizable")) {
        $style->setLink($url->extras("resize.css"), {type=>"text/css", rel=>"stylesheet"});
        $style->setLink($url->extras("resize-skin.css"), {type=>"text/css", rel=>"stylesheet"});
        $style->setScript($url->extras("yui/build/yahoo-dom-event/yahoo-dom-event.js"), {type=>"text/javascript"});
        $style->setScript($url->extras("yui/build/dragdrop/dragdrop.js"), {type=>"text/javascript"});
        $style->setScript($url->extras("yui/build/element/element-beta.js"), {type=>"text/javascript"});
        $style->setScript($url->extras("yui/build/resize/resize-beta.js"), {type=>"text/javascript"});
        $out = qq|
            <div id="resize_| . $self->get('id'). qq|" style="width: | . ($width + 10) . qq|px; height: | . ($height + 10) . qq|px; overflow: hidden">
            $out
            </div>

            <script type="text/javascript">

            YAHOO.util.Event.onDOMReady(function() {
                var Dom = YAHOO.util.Dom,
                    Event = YAHOO.util.Event,
                    textAreaElement = document.getElementById('| . $self->get('id') . qq|');

                var resize = new YAHOO.util.Resize('resize_| . $self->get('id'). qq|');
                resize.on('resize', function(ev) {
                    var w = ev.width;
                    var h = ev.height;
                    textAreaElement.style.width = (w - 6) + "px";
                    textAreaElement.style.height = (h - 6) + "px";
                });
            });
            </script>
        |;
	}
	return $out;
}



1;

