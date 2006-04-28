package WebGUI::Form::Textarea;

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

=head4 resizeable 

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
		resizeable => {
			defaultValue => 1,
			},
		profileEnabled=>{
			defaultValue=>1
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
	my $resize = undef;
	if ($self->get("resizeable")) {
		my $i18n = WebGUI::International->new($self->session, "Form_Textarea");
		$self->session->style->setScript($self->session->url->extras("resizeable_textarea.js"), {type=>"text/javascript"});
		$resize = '<img src="'.$self->session->icon->getBaseURL().'/drag.gif" title="'.$i18n->get("drag to resize").'" alt="'.$i18n->get("drag to resize").'" class="draggable" onmousedown="tar_drag_start(event, \''.$self->get('id').'\');" />';
	}
 	my $value = $self->fixMacros($self->fixTags($self->fixSpecialCharacters($self->get("value"))));
	my $style = "width: ".$self->get('width')."px; height: ".$self->get('height')."px; ".$self->get("style");
	return '<textarea id="'.$self->get('id').'" name="'.$self->get("name").'" style="'.$style.'" '.$self->get("extras").'>'.$value.'</textarea>'.$resize;
}


1;

