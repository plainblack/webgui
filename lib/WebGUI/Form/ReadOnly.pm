package WebGUI::Form::ReadOnly;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

=head1 NAME

Package WebGUI::Form::ReadOnly

=head1 DESCRIPTION

Prints out the value directly with no form control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
    push(@{$definition}, {
        # Should we show the hidden field too?
        addHidden    => {
            defaultValue    => 1,
        },
    });
    return $class->SUPER::definition( $session, $definition );
}
#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('read only');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 0;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders the value and a hidden input type if a "name" attribute was specified.

=cut

sub toHtml {
	my $self = shift;
    my $out = $self->getOriginalValue;
    if ($self->get('addHidden') && $self->get('name') ne '') {
        $out .= $self->toHtmlAsHidden;
    }
    return $out;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Outputs nothing unless a "name" attribute was specified.

=cut

sub toHtmlAsHidden {
    my $self = shift;
    if ($self->get('addHidden') && $self->get('name') ne '') {
        return $self->SUPER::toHtmlAsHidden;
    }
	return undef;
}	


1;

