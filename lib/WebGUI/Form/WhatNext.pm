package WebGUI::Form::WhatNext;

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
use WebGUI::Form::SelectList;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::WhatNext

=head1 DESCRIPTION

Creates a what next question field. This is used to allow users direct the flow of forms from one page to another.

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

=head4 name

The identifier for this field. Defaults to "proceed".

=head4 defaultValue

A database link id. Defaults to "0", which is the WebGUI database.

=head4 afterEdit

A URL that will be acted upon after editing a database link. 

=head4 hoverHelp

A tooltip to tell the user what to do with the field. Defaults a standard piece of help for Database Links.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		label=>{
			defaultValue=>$class->getName()
			},
		name=>{
			defaultValue=>"proceed"
			},
		options=>{
			defaultValue=>{}
			}
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("744","WebGUI");
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a question selector asking the user where they want to go.

=cut

sub toHtml {
	my $self = shift;
	return WebGUI::Form::SelectList->new(
		id=>$self->{id},
		name=>$self->{name},
		options=>$self->{options},
		value=>[$self->{value}],
		extras=>$self->{extras}
		)->toHtml;
}



1;

