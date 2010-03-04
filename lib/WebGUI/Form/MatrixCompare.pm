package WebGUI::Form::MatrixCompare;

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
use base 'WebGUI::Form::SelectBox';
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Pluggable;

=head1 NAME

Package WebGUI::Form::MatrixCompare

=head1 DESCRIPTION

Creates a form control that will allow you to select a field type that can be used by the Matrix wobject. 
It's meant to be used in conjunction with the DynamicField form control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Returns 0.

=cut

sub areOptionsSettable {
    return 0;
}

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 types

An array reference containing the form control types to be selectable. Defaults to all available dynamic types.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		label=>{
			defaultValue=>$i18n->get("matrix compare","Form_MatrixCompare")
			},
        });
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'Form_MatrixCompare')->get('matrix compare');
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns either what's posted or if nothing comes back it returns "text".

=cut

sub getValue {
	my $self = shift;
	my $compareValue = $self->SUPER::getValue(@_);
	$compareValue =~ s/[^\w]//g;
	return $compareValue || 0;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ()

Shows either Yes or No.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $i18n = WebGUI::International->new($self->session,'Form_MatrixCompare');
    my %options = (
        0 => $i18n->get('no'),
        1 => $i18n->get('limited'),
        2 => $i18n->get('costs extra'),
        3 => $i18n->get('free add on'),
        4 => $i18n->get('yes'),
    );
    return $options{$self->getOriginalValue};
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

Returns 0.

=cut

sub isDynamicCompatible {
    return 0;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a fieldType selector.

=cut

sub toHtml {
	my $self = shift;
    my $i18n = WebGUI::International->new($self->session,'Form_MatrixCompare'); 
	my %options;
	tie %options, "Tie::IxHash";
    %options = (
        0 => $i18n->get('no'),
        1 => $i18n->get('limited'),
        2 => $i18n->get('costs extra'),
        3 => $i18n->get('free add on'),
        4 => $i18n->get('yes'),
    );
    $self->set('options', \%options);
    $self->set('defaultValue',0);
	return $self->SUPER::toHtml();
}



1;

