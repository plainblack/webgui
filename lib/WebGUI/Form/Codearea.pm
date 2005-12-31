package WebGUI::Form::Codearea;

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
use base 'WebGUI::Form::Textarea';
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Style;

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

The following additional parameters have been added via this sub class.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
			defaultValue=>WebGUI::International::get("codearea","WebGUI")
			},
		profileEnabled=>{
			defaultValue=>1
			}
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a code area field.

=cut

sub toHtml {
	my $self = shift;
	WebGUI::Style::setScript($self->session->config->get("extrasURL").'/TabFix.js',{type=>"text/javascript"});
	$self->get("extras") .= ' style="width: 99%; min-width: 440px; height: 400px" onkeypress="return TabFix_keyPress(event)" onkeydown="return TabFix_keyDown(event)"';	
	return $self->SUPER::toHtml;
}


1;

