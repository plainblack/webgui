package WebGUI::Form::Codearea;

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
use base 'WebGUI::Form::Textarea';
use HTML::Entities qw(encode_entities decode_entities);
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Codearea

=head1 DESCRIPTION

Creates a code area form field, which is just like a text area except stretches to fit it's space and allows tabs in it's content.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Textarea.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

=head4 width

The width of this control in pixels. Defaults to 550 pixels.

=head4 height

The height of this control in pixels.  Defaults to 450 pixels.

=head4 style

Style attributes besides width and height which should be specified using the above parameters. Be sure to escape quotes if you use any.

The following additional parameters have been added via this sub class.

=head4 syntax

The type of syntax highlighting to use by default. The types available are located at
$WEBGUI_ROOT/www/extras/editarea/edit_area/reg_syntax

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		height=>{
			defaultValue=> 450 
			},
		width=>{
			defaultValue=> 550 
			},
		style=>{
			defaultValue => undef,
			},
        syntax => {
            defaultValue    => "html",
        },
    });
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "MEDIUMTEXT".

=cut 

sub getDatabaseFieldType {
    return "MEDIUMTEXT";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('codearea');
}

#-------------------------------------------------------------------

=head2 getValue ( [value] )

Return the value, HTML decoded

=cut

sub getValue {
    my ( $self, @args ) = @_;
    my $value = $self->SUPER::getValue( @args );
    return decode_entities( $value );
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

Renders a code area field.

=cut

sub toHtml {
    my $self = shift;
    my ($style, $url, $stow) = $self->session->quick(qw(style url stow));

    my $value = encode_entities( $self->fixMacros($self->fixTags($self->fixSpecialCharacters(scalar $self->getOriginalValue))) );
    my $width = $self->get('width') || 400;
    my $height = $self->get('height') || 150;
    my $id = $self->get('id');
    my $name = $self->get('name');
    my $extras = $self->get('extras');
    my $syntax = $self->get('syntax');
    my $styleAttr = $self->get('style');

    $style->setLink($url->extras("yui/build/resize/assets/skins/sam/resize.css"), {type=>"text/css", rel=>"stylesheet"});
    $style->setLink($url->extras("yui/build/assets/skins/sam/skin.css"), {type=>"text/css", rel=>"stylesheet"});
    $style->setScript($url->extras("yui/build/utilities/utilities.js"),{type=>"text/javascript"});
    $style->setScript($url->extras("yui/build/container/container_core-min.js"),{type=>"text/javascript"});
    $style->setScript($url->extras("yui/build/menu/menu-min.js"),{type=>"text/javascript"});
    $style->setScript($url->extras("yui/build/button/button-min.js"),{type=>"text/javascript"});
    $style->setScript($url->extras("yui/build/resize/resize-min.js"),{type=>"text/javascript"});
    $style->setScript($url->extras("yui/build/editor/editor-min.js"),{type=>"text/javascript"});
    $style->setScript($url->extras("yui-webgui/build/code-editor/code-editor.js"),{type=>"text/javascript"});
    #$style->setLink($url->extras("yui/build/logger/assets/logger.css"), {type=>"text/css", rel=>"stylesheet"});
    #$style->setLink($url->extras("yui/build/logger/assets/skins/sam/logger.css"), {type=>"text/css", rel=>"stylesheet"});
    #$style->setScript($url->extras("yui/build/logger/logger.js"),{type=>"text/javascript"});
    my $codeCss = $url->extras("yui-webgui/build/code-editor/code.css");
    my $out = <<"END_HTML";
<textarea id="$id" name="$name" $extras rows="10" cols="60" style="font-family: monospace; $styleAttr; height: 100%; width: 100%; resize: none;">$value</textarea>
<script type="text/javascript">
(function(){
    YAHOO.util.Event.onDOMReady( function () {
        var myeditor = new YAHOO.widget.CodeEditor('${id}', { toggleButton: true, handleSubmit: true, css_url: '${codeCss}', height: '${height}px', width: '${width}px', status: true, resize: true });
        myeditor.render();

        //var myLogReader = new YAHOO.widget.LogReader();
    } );
}());
</script>
END_HTML
    return $out;
}

1;

