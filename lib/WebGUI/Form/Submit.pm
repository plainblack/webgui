package WebGUI::Form::Submit;

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
use base 'WebGUI::Form::Button';
use WebGUI::International;

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

=head2 definition ( )

See the super class for additional details.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("submit")
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a button.

=cut

sub toHtml {
	my $self = shift;
	my $value = $self->fixQuotes($self->get("value"));
	my $i18n = WebGUI::International->new($self->session);
	$self->get("extras") ||= 'onclick="this.value=\''.$i18n->get(452).'\'"';
	my $html = '<input type="submit" ';
	$html .= 'name="'.$self->get("name").'" ' if ($self->get("name"));
	$html .= 'id="'.$self->{id}.'" ' unless ($self->{id} eq "_formId");
	$html .= 'value="'.$value.'" '.$self->get("extras").' />';
	return $html;
}

1;

