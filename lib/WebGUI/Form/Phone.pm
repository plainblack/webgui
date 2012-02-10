package WebGUI::Form::Phone;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('481');
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Returns a string filtered to allow only digits, spaces, and these special characters: + - ( ) or it will return undef it the number doesn't validate to those.

=head3 value

An input value to use instead of POST input.

=cut

sub getValue {
	my $self = shift;
	my $value = $self->SUPER::getValue(@_);
	if ($value =~ /^[x\d \.\-\+\(\)]+$/ and $value =~ /\d/) {
		return $value;
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 headTags ( )

Set the head tags for this form plugin

=cut

sub headTags {
    my $self = shift;
	$self->session->style->setScript($self->session->url->extras('inputCheck.js'));
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

Renders a phone number field.

=cut

sub toHtml {
        my $self = shift;
        $self->set("extras", $self->get('extras') . ' onkeyup="doInputCheck(document.getElementById(\''.$self->get("id").'\'),\'x.0123456789-()+ \')" ');
	return $self->SUPER::toHtml;
}

1;

