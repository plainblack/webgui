package WebGUI::Form::Combo;

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
use base 'WebGUI::Form::SelectBox';
use WebGUI::Form::Text;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Combo

=head1 DESCRIPTION

Creates a select list merged with a text box form control.  The text box form control can
be used to enter data apart from the list options or to add new options to the list of
available options.  The last function is dependent on the caller of the Form field
appending the new value to the list of options.

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

=head4 optionsSettable

A boolean indicating whether the options are settable using an options hashref or not settable because this form
type generates its own options.

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
			},
        dbDataType  => {
            defaultValue    => "TEXT",
            },
		optionsSettable=>{
            defaultValue=>1
            },
        });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( [ value ] )

Returns an array or a carriage return ("\n") separated scalar depending
upon whether you're returning the values into an array or a scalar.  If
any data is in the Text form, it is returned before a selected value from
the list.

=head3 value

Optional values to process, instead of POST input.

=cut

sub getValueFromPost {
	my $self = shift;

	if (@_) {
		return $self->SUPER::getValueFromPost(@_);
	}
	elsif ($self->session->form->param($self->get("name")."_new")) {
		my $formValue = $self->session->form->param($self->get("name")."_new");
		$formValue =~ tr/\r\n//d;
		return $formValue;
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
		.WebGUI::Form::Text->new($self->session,
			size=>$self->session->setting->get("textBoxSize")-5,
			name=>$self->get("name")."_new",
			id=>$self->get('id')."_new"
			)->toHtml;
}



1;

