package WebGUI::Form::Zipcode;

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
use base 'WebGUI::Form::Text';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Zipcode

=head1 DESCRIPTION

Creates a zip code form field. 

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the superclass for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 maxlength

Defaults to 10. Determines the maximum number of characters allowed in this field.

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
			defaultValue=> $i18n->get("944")
			},
		maxlength=>{
			defaultValue=> 10
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( [ value ] )

Returns a validated form post result. If the result does not pass validation, it returns undef instead.

=head3 value

An optional value to use instead of POST input.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = @_ ? shift : $self->session->form->param($self->get("name"));
	$value =~ tr/\r\n//d;
   	if ($value =~ /^[A-Z\d\s\-]+$/) {
		return $value;
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a zip code field.

=cut

sub toHtml {
	my $self = shift;
	$self->session->style->setScript($self->session->url->extras('inputCheck.js'),{ type=>'text/javascript' });
	$self->set("extras", $self->get('extras') . ' onkeyup="doInputCheck(document.getElementById(\''.$self->get("id").'\'),\'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- \')"');
	return $self->SUPER::toHtml;
}

1;

