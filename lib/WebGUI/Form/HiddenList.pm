package WebGUI::Form::HiddenList;

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
use base 'WebGUI::Form::List';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::HiddenList

=head1 DESCRIPTION

Creates a list of hidden fields. 

=head1 SEE ALSO

This is a subclass of WebGUI::Form::List.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 options

A hash reference containing name value pairs. The name of each pair will be used to fill the value attribute of the hidden field. Defaults to an empty hash reference.

=head4 defaultValue

value and defaultValue are array referneces containing the names from the options list that should be stored.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
        my $class = shift;
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
        my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
        push(@{$definition}, {
                formName=>{
                        defaultValue=>$i18n->get("hidden list"),
                        },
		profileEnabled=>{
			defaultValue=>1
			},
                });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

A synonym for toHtmlAsHidden.

=cut

sub toHtml {
	my $self = shift;
	return $self->toHtmlAsHidden;
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

