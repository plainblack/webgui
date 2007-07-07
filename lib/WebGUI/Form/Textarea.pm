package WebGUI::Form::Textarea;

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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=head4 resizable 

A boolean indicating whether the text area can be reized by users. Defaults to 1.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("476")
			},
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
		profileEnabled=>{
			defaultValue=>1
			},
        dbDataType  => {
            defaultValue    => "LONGTEXT",
        },
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
	my $self = shift;
 	my $value = $self->fixMacros($self->fixTags($self->fixSpecialCharacters($self->get("value"))));
	my $width = $self->get('width') || 400;
	my $height = $self->get('height') || 150;
	my $style = "width: ".$width."px; height: ".$height."px; ".$self->get("style");
	my $out = '<textarea id="'.$self->get('id').'" name="'.$self->get("name").'" style="'.$style.'" '.$self->get("extras").'>'.$value.'</textarea>';
	if ($self->get("resizable")) {
		$out = '<div style="border: 0px; width: '.$width.'px; height: '.$height.'px;" class="yresizable-pinned" id="'.$self->get('id').'_wrapper">'.$out.'</div>';
		my ($style, $url) = $self->session->quick(qw(style url));
		$style->setScript($url->extras("yui/build/yahoo/yahoo-min.js"), {type=>"text/javascript"});
		$style->setScript($url->extras("yui/build/event/event-min.js"), {type=>"text/javascript"});
		$style->setScript($url->extras("yui/build/dom/dom-min.js"), {type=>"text/javascript"});
		$style->setScript($url->extras("yui/build/dragdrop/dragdrop-min.js"), {type=>"text/javascript"});
		$style->setLink($url->extras("yui-ext/resources/css/ext-all.css"), {type=>"text/css", rel=>"stylesheet"});
		$style->setScript($url->extras("yui-ext/adapter/yui/ext-yui-adapter.js"), {type=>"text/javascript"});
		$style->setScript($url->extras("yui-ext/ext-all.js"), {type=>"text/javascript"});
		$out .= qq|
		<script type="text/javascript">
			YAHOO.util.Event.addListener(window, 'load', function () {
                    var resizableTextarea = new Ext.Resizable('|.$self->get('id').qq|_wrapper', {minWidth:300, minHeight:150, wrap:false, resizeChild:true, disableTrackOver:true, multiDirectional:false, pinned:true, width:|.$width.qq|, height:|.$height.qq|, dynamic:false });
				});
		</script>
		|;
	}
	return $out;
}



1;

