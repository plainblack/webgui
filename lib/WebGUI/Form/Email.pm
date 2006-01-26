package WebGUI::Form::Email;

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
use base 'WebGUI::Form::Text';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Email

=head1 DESCRIPTION

Creates an email field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

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
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("480")
			},
		profileEnabled=>{
			defaultValue=>1
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a validated email address. If the result does not pass validation, it returns undef instead.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $self->session->form->param($self->get("name"));

	if ($value =~ /^([A-Z0-9]+[._+-]?){1,}([A-Z0-9]+[_+-]?)+\@(([A-Z0-9]+[._-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i) {
		return $value;
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an email address field.

=cut

sub toHtml {
        my $self = shift;
	$self->session->style->setScript($self->session->config->get("extrasURL").'/emailCheck.js',{ type=>'text/javascript' });
	$self->{_params}{extras} .= ' onchange="emailCheck(this.value)" ';
	return $self->SUPER::toHtml;
}

1;

