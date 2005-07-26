package WebGUI::Form::hidden;

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

Package WebGUI::Form::hidden

=head1 DESCRIPTION

Creates a hidden field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("hidden","WebGUI");
}


#-------------------------------------------------------------------

=head2 toHtml ( )

A synonym for toHtmlAsHidden.

=cut

sub toHtml {
	my $self = shift;
	$self->toHtmlAsHidden;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders an input tag of type hidden.

=cut

sub toHtmlAsHidden {
	my $self = shift;
 	my $value = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters($self->{value})));
	return '<input type="hidden" name="'.$self->{name}.'" value="'.$value.'" '.$self->{extras}.' />'."\n";
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

A synonym for toHtmlAsHidden.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
	return $self->toHtmlAsHidden;
}


1;

