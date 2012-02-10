package WebGUI::Form::Guid;

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
use base 'WebGUI::Form::ReadOnly';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Guid

=head1 DESCRIPTION

Creates a form control for feeding WebGUI IDs (which are called GUIDs or Global Unique IDs) through forms.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::ReadOnly.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(22) BINARY"

=cut

sub getDatabaseFieldType {
    return "CHAR(22) BINARY";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return 'GUID';
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns a class name which has been taint checked.

=cut

sub getValue {
	my $self = shift;
    my $value = $self->SUPER::getValue(@_);
    if ($value =~ m/[A-Za-z0-9\-_]{1,22}/) {
        return $value;
    }
    $self->session->log->warn("Invalid GUID '$value' passed into form");
    return undef;
}


1;

