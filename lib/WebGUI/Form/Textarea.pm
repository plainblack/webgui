package WebGUI::Form::Textarea;

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
use base 'WebGUI::Form::Control';
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::Textarea

=head1 DESCRIPTION

Creates a text area form field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 rows

The number of rows (in characters) tall the box should be. Defaults to the setting textAreaRows or 5 if that's not specified.

=head4 columns

The number of columns (in characters) wide the box should be. Defaults to the setting textAreaCols or 50 if that's not specified.

=head4 wrap

The style of wrapping this form should use. Defaults to "virtual". Other possible values are "off" and "physical".

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		rows=>{
			defaultValue=> $session{setting}{textAreaRows} || 5
			},
		columns=>{
			defaultValue=> $session{setting}{textAreaCols} || 50
			},
		wrap=>{
			defaultValue=>"virtual"
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("476","WebGUI");
}



#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
	my $self = shift;
 	my $value = $self->fixMacros($self->fixTags($self->fixSpecialCharacters($self->{value})));
	return '<textarea id="'.$self->{id}.'" name="'.$self->{name}.'" cols="'.$self->{columns}.'" rows="'.$self->{rows}.'" wrap="'.
                $self->{wrap}.'" '.$self->{extras}.'>'.$value.'</textarea>';
}


1;

