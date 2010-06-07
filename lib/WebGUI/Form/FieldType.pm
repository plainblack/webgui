package WebGUI::Form::FieldType;

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
use Module::Find qw(findallmod);

=head1 NAME

Package WebGUI::Form::FieldType

=head1 DESCRIPTION

Creates a form control that will allow you to select a form control type. It's meant to be used in conjunction with the DynamicField form control.

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
			defaultValue=>$i18n->get("fieldtype","WebGUI")
			},
		types=>{
			defaultValue=>[],
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
    return WebGUI::International->new($session, 'WebGUI')->get('fieldType');
}

#-------------------------------------------------------------------

=head2 getTypes (  )

Returns a hash reference of field types and human readable names. Defaultly returns all that have isDynamicCompatible() set to 1, but if types is specified in the constructor, will return the ones from that list.

=cut

sub getTypes {
    my $self = shift;
    my @types = @{$self->get('types')};
    unless (scalar(@types)) {
        my @classes = findallmod 'WebGUI::Form';
        for my $class (@classes) {
            if ($class =~ /^WebGUI::Form::(.*)/) {
                my $type = $1;
                if (WebGUI::Pluggable::instanciate($class, 'isDynamicCompatible')) {
                    push @types, $type;
                }
            }
        }
    }
    my %fields = ();
    foreach my $type (@types) {
        my $name = WebGUI::Pluggable::instanciate('WebGUI::Form::'.ucfirst($type), 'getName', [$self->session]);
        $self->session->log->warn("type: $type; name: $name");
        $fields{$type} = $name;
    }
    return \%fields;
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns either what's posted or if nothing comes back it returns "text".

=cut

sub getValue {
	my $self = shift;
	my $fieldType = $self->SUPER::getValue(@_);
	$fieldType =~ s/[^\w:]//g;
	return $fieldType || "text";
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
	my %options;
	tie %options, "Tie::IxHash";
    $self->set('options', $self->getTypes);
    $self->set('sortByValue', 1);
	return $self->SUPER::toHtml();
}



1;

