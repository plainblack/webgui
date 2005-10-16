package WebGUI::Form::Submit;

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
use base 'WebGUI::Form::Button';
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::Submit

=head1 DESCRIPTION

Creates a submit form button.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Button.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("submit","WebGUI");
}


#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a button.

=cut

sub toHtml {
	my $self = shift;
	my $value = $self->fixQuotes($self->{value});
	$self->{extras} ||= 'onclick="this.value=\''.WebGUI::International::get(452).'\'"';
	my $html = '<input type="submit" ';
	$html .= 'name="'.$self->{name}.'" ' if ($self->{name});
	$html .= 'id="'.$self->{id}.'" ' unless ($self->{id} eq "_formId");
	$html .= 'value="'.$value.'" '.$self->{extras}.' />';
	return $html;
}

1;

