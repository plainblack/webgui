package WebGUI::Form::Codearea;

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
use base 'WebGUI::Form::Textarea';
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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("codearea")
			},
		height=>{
			defaultValue=> 450 
			},
		width=>{
			defaultValue=> 550 
			},
		style=>{
			defaultValue => undef,
			},
		profileEnabled=>{
			defaultValue=>1
			},
        dbDataType  => {
            defaultValue    => "TEXT",
        },
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a code area field.

=cut

sub toHtml {
	my $self = shift;
	$self->session->style->setScript($self->session->url->extras('TabFix.js'),{type=>"text/javascript"});
	$self->set("extras", $self->get('extras').' onkeypress="return TabFix_keyPress(event)" onkeydown="return TabFix_keyDown(event)"');	
	return $self->SUPER::toHtml;
}


1;

