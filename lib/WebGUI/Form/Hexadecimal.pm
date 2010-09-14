package WebGUI::Form::Hexadecimal;

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
use base 'WebGUI::Form::Text';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Integer

=head1 DESCRIPTION

Creates an input field that accepts positive and negative integer.

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

Defaults to 11. Determines the maximum number of characters allowed in this field.

=head4 defaultValue

Defaults to 0. Used if no value is specified.

=head4 size

Defaults to 11. The number of characters that will be displayed at once in this field. Usually no need to override the default.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		maxlength=>{
			defaultValue=> 11
			},
		defaultValue=>{
			defaultValue=>0
			},
		size=>{
			defaultValue=>11
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('hexadecimal');
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns the integer from the form post, or returns 0 if the post result is invalid.

=cut

sub getValue {
	my $self = shift;
	my $value = $self->SUPER::getValue(@_);
	if ($value =~ /^[0-9a-f]+$/i) {
		return $value;
	}
	return 0;
}

#-------------------------------------------------------------------

=head2 headTags ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub headTags {
    my $self = shift;
	$self->session->style->setScript($self->session->url->extras('inputCheck.js'),{ type=>'text/javascript' });
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

Renders an integer field.

=cut

sub toHtml {
        my $self = shift;
	$self->set("extras", $self->get('extras') . ' onkeyup="doInputCheck(document.getElementById(\''.$self->get("id").'\'),\'0123456789abcdef\')"');
	return $self->SUPER::toHtml;
}

1;

