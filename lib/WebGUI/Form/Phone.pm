package WebGUI::Form::Phone;

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

Package WebGUI::Form::Phone

=head1 DESCRIPTION

Creates a telephone number field.

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
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("481")
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a string filtered to allow only digits, spaces, and these special characters: + - ( ) or it will return undef it the number doesn't validate to those.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $self->session->request->param($self->get("name"));
   	if ($value =~ /^[\d\s\-\+\(\)]+$/) {
                return $value;
        }
        return undef;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a phone number field.

=cut

sub toHtml {
        my $self = shift;
	$self->session->style->setScript($self->session->config->get("extrasURL").'/inputCheck.js',{ type=>'text/javascript' });
        $self->set("extras", $self->get('extras') . ' onkeyup="doInputCheck(this.form.'.$self->get("name").',\'0123456789-()+ \')" ');
	return $self->SUPER::toHtml;
}

1;

