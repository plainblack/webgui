package WebGUI::Form::YesNo;

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
use base 'WebGUI::Form::RadioList';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::YesNo

=head1 DESCRIPTION

Creates a yes/no question field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Options are predefined for a Yes/No.

=cut

sub areOptionsSettable {
    return 0;
}

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 defaultValue

Can be a 1 or 0. Defaults to 0 if no value is specified.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		defaultValue=>{
			defaultValue=>0
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "BOOLEAN".

=cut 

sub getDatabaseFieldType {
    return "BOOLEAN";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('483');
}

#-------------------------------------------------------------------

=head2 getOptions

Return the options, set to defaults for the Yes/No.  These options are not overridable.

=cut

sub getOptions {
    my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
    $self->set('options',{
        1 => $i18n->get(138),
        0 => $i18n->get(139),
    });
    return $self->SUPER::getOptions;
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

If value is present, we will process it, otherwise the superclass will handle the request.

=head3 value

An optional value to process, instead of POST input. This should be in the form 1, 0, 'Y' or 'N'. 1 or 0 is returned.

=cut

sub getValue {
	my $self = shift;
    my $value = $self->SUPER::getValue(@_);
	return ($value =~ /^y/i || $value eq '1') ? 1 : 0;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ()

Shows either Yes or No.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $i18n = WebGUI::International->new($self->session);
    if ($self->getOriginalValue) {
        return $i18n->get(138);
    }
    return $i18n->get(139);
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}


1;
