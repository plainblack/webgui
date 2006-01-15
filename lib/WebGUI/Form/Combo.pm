package WebGUI::Form::Combo;

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
use base 'WebGUI::Form::SelectBox';
use WebGUI::Form::Text;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Combo

=head1 DESCRIPTION

Creates a select list merged with a text box form control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

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
			defaultValue=>$i18n->get("combobox")
			},
		profileEnabled=>{
			defaultValue=>1
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=cut

sub getValueFromPost {
	my $self = shift;
	if ($self->session->request->param($self->get("name")."_new")) {
		return $self->session->request->param($self->get("name")."_new");
        }
	return $self->SUPER::getValueFromPost;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a combo box form control.

=cut

sub toHtml {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
	$self->get("options")->{''} = '['.$i18n->get(582).']';
        $self->get("options")->{_new_} = $i18n->get(581).'-&gt;';
	return $self->SUPER::toHtml
		.WebGUI::Form::Text->new(
			size=>$self->session->setting->get("textBoxSize")-5,
			name=>$self->get("name")."_new",
			id=>$self->get('id')."_new"
			)->toHtml;
}



1;

