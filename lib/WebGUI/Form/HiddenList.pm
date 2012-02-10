package WebGUI::Form::HiddenList;

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

=head2  getDatabaseFieldType ( )

Returns "TEXT".

=cut 

sub getDatabaseFieldType {
    return "TEXT";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('hidden list');
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

