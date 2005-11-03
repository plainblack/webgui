package WebGUI::Form::Phone;

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
use base 'WebGUI::Form::Text';
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Style;

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

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("944","WebGUI");
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a string filtered to allow only digits, spaces, and these special characters: + - ( ) or it will return undef it the number doesn't validate to those.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $session{req}->param($self->{name});
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
	WebGUI::Style::setScript($session{config}{extrasURL}.'/inputCheck.js',{ type=>'text/javascript' });
        $self->{extras} .= ' onkeyup="doInputCheck(this.form.'.$self->{name}.',\'0123456789-()+ \')" ';
	return $self->SUPER::toHtml;
}

1;

