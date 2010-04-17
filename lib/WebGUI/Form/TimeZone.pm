package WebGUI::Form::TimeZone;

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
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::TimeZone

=head1 DESCRIPTION

Creates a time zone chooser control.

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

=head2 definition ( )

See the super class for additional details.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		value=>{
			defaultValue=>undef
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
    return WebGUI::International->new($session, 'DateTime')->get('timezone');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 new ( )

Extend the base method to handle spaces in the value and/or default value.

=cut

sub new {
	my $class = shift;
    my $self  = $class->SUPER::new(@_);
    my $value = $self->get('value');
    $value =~ tr/ /_/;
    $self->set('value', $value);
    my $defaultValue = $self->get('defaultValue');
    $defaultValue =~ tr/ /_/;
    $self->set('defaultValue', $defaultValue);
    return $self;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a database connection picker control.

=cut

sub toHtml {
	my $self = shift;
	$self->set("options", $self->session->datetime->getTimeZones());
	return $self->SUPER::toHtml();
}



1;

