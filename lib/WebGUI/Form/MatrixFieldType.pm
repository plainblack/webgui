package WebGUI::Form::MatrixFieldType;

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
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Form::MatrixFieldType

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
			defaultValue=>$i18n->get("matrix fieldtype","Asset_Matrix")
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
    return WebGUI::International->new($session, 'Asset_Matrix')->get('matrix fieldtype');
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns either what's posted or if nothing comes back it returns "text".

=cut

sub getValue {
	my $self = shift;
	my $fieldType = $self->SUPER::getValue(@_);
	$fieldType =~ s/[^\w]//g;
	return $fieldType || "MatrixCompare";
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

Returns 0.

=cut

sub isDynamicCompatible {
    return 0;
}

#-------------------------------------------------------------------

=head2 new ( )

Extend the base "new" to set options.

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    my %options;
    tie %options, "Tie::IxHash";
    %options = (
        MatrixCompare => WebGUI::Pluggable::instanciate('WebGUI::Form::MatrixCompare', 'getName',[$self->session]),
        SelectBox     => WebGUI::Pluggable::instanciate('WebGUI::Form::SelectBox', 'getName',[$self->session]),
        Combo         => WebGUI::Pluggable::instanciate('WebGUI::Form::Combo', 'getName',[$self->session]),
    );
    $self->set('options', \%options);
    $self->set('defaultValue','MatrixCompare');
    return $self;
}

1;
