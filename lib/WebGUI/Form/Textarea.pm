package WebGUI::Form::Textarea;

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

=head4 maxlength

The maximum number of characters to allow in this field. If not defined, will not do any limiting.

=cut

sub definition {
	my $class       = shift;
	my $session     = shift;
	my $definition  = shift || [];
	push @{$definition}, {
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
        maxlength => {
            defaultValue    => ''
        },
    };
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
 	my $value = $self->fixMacros($self->fixTags($self->fixSpecialCharacters(scalar $self->getOriginalValue)));
	my $width = $self->get('width') || 400;
	my $height = $self->get('height') || 150;
	my ($style, $url, $stow) = $self->session->quick(qw(style url stow));
    my $sizeStyle =  ' width: ' . $width . 'px; height: ' . $height . 'px;';
    my $out
        = '<textarea id="' . $self->get('id') . '"'
        . ' name="' . $self->get("name") . '"'
        . ( $self->get("maxlength") ? ' maxlength="' . $self->get( "maxlength" ) . '"' : '' )
        . ' ' . $self->get("extras")
        . ' rows="5" cols="60"'
        . ' style="' . $self->get('style')
        . ( $self->get("resizable") ? ' height: 100%; width: 100%; resize: none;' : $sizeStyle ) . '"'
        . '>' . $value . '</textarea>';

    if ($self->get("resizable")) {
        $style->setLink($url->extras("yui/build/resize/assets/skins/sam/resize.css"), {type=>"text/css", rel=>"stylesheet"});
        $style->setScript($url->extras("yui/build/utilities/utilities.js"), {type=>"text/javascript"});
        $style->setScript($url->extras("yui/build/resize/resize-min.js"), {type=>"text/javascript"});
        $out = sprintf <<'END_HTML', $self->get('id'), $out, $sizeStyle;
<div id="%1$s_resizewrapper" style="padding-right: 6px; padding-bottom: 6px; %3$s">%2$s</div>
<script type="text/javascript">
(function() {
    var resize = new YAHOO.util.Resize('%1$s_resizewrapper');
    resize.on('resize', function(e) {
        YAHOO.util.Dom.setStyle('%1$s', 'width', resize.getStyle('width'));
        YAHOO.util.Dom.setStyle('%1$s', 'height', resize.getStyle('height'));
    });
    resize.reset();
})();
</script>
END_HTML
    }
    elsif ($self->get('maxlength')) {
        $style->setScript(
            $url->extras( 'yui/build/yahoo-dom-event/yahoo-dom-event.js' ),
            { type => 'text/javascript' },
        );
    }
    if ($self->get('maxlength')) {
        # Add the maxlength script
        $style->setScript(
            $url->extras( 'yui-webgui/build/form/textarea.js' ),
            { type => 'text/javascript' },
        );
    }
    return $out;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml

Returns the form value as text, encoding HTML entities.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $value = $self->SUPER::getValueAsHtml(@_);
    $value = WebGUI::HTML::format($value, 'text');
    return $value;
}


1;

