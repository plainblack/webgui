package WebGUI::Form::List;

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
use base 'WebGUI::Form::Control';
use WebGUI::Form::Hidden;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::List

=head1 DESCRIPTION

Master class for all list type form elements.  Not useful by itself.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 alignmentSeparator ( )

Return an HTML separator to generate either horizontal or vertical lists
of radio/check boxes.

=cut

sub alignmentSeparator {
	my ($self) = @_;
	if ($self->get("vertical")) {
		return "<br />\n";
	}
	else {
		return " &nbsp; &nbsp;\n";
	}
}

#-------------------------------------------------------------------

=head2 correctOptions ( )

Parse a string for a list of options to present to the user.  This method
will mainly be called from WebGUI::Form::DynamicField.
=cut

sub correctOptions {
	my ($self, $possibleValues) = @_;
	my %options;
	tie %options, 'Tie::IxHash';
	foreach (split(/\n/, $possibleValues)) {
		s/\s+$//; # remove trailing spaces
		$options{$_} = $_;
	}
	if ($self->get('options') && ref($self->get('options')) eq "HASH") {
		%options = (%{$self->get('options')} , %options);
	}
	$self->set('options', \%options);
}


##-------------------------------------------------------------------

=head2 correctValues ( )

Parse a string for a list of values that should be selected.  This method
will mainly be called from WebGUI::Form::DynamicField.  Form types that
don't have multiple select, like RadioLists, need to override this
method.

=cut

sub correctValues {
	my ($self, $value) = @_;
	return unless defined $value;
	my @defaultValues;
	if (ref $value eq "ARRAY") {
		@defaultValues = @{ $value };
	}
	else {
		foreach (split(/\n/, $value)) {
				s/\s+$//; # remove trailing spaces
				push(@defaultValues, $_);
		}
	}
	$self->set("value", \@defaultValues);
}


#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 options

A hash reference containing key values that will be returned with the form post and displayable text pairs. Defaults to an empty hash reference.

=head4 defaultValue

An array reference of the items to be checked if no value is specified. Defaults to an empty array reference.

=head4 size

The number of characters tall this list should be. Defaults to '1'.

=head4 multiple

A boolean indicating whether the user can select multiple items from this list like a checkList. Defaults to "0".

=head4 sortByValue

A boolean value for whether or not the values in the options hash should be sorted. Defaults to "0".

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
			defaultValue=>$i18n->get("486"),
			},
		options=>{
			defaultValue=>{}
			},
		defaultValue=>{
			defaultValue=>[],
			},
		multiple=>{
			defaultValue=>0
			},
		sortByValue=>{
			defaultValue=>0
			},
		size=>{
			defaultValue=>1
			},
		profileEnabled=>{
			defaultValue=>0
			},
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 displayValue ( )

Return all the options

=cut

sub displayValue {
	my ($self) = @_;
	return join ", ", $self->getValues();
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=cut

sub getValueFromPost {
	my $self = shift;
	my @data = $self->session->request->param($self->get("name"));
        return wantarray ? @data : join("\n",@data);
}

#-------------------------------------------------------------------

=head2 getValues ( )

Safely handle returning values whether the stored data is scalar or an array
ref.

=cut

sub getValues {
	my $self = shift;
	my @values = ();
	if (ref $self->get("value") eq 'ARRAY') {
		@values = @{ $self->get("value") };
	}
	else {
		push @values, $self->get("value");
	}
        return @values;
}

#-------------------------------------------------------------------

=head2 orderedHash ( )

Based on whether the sortByValue flag is set, return the options hash
for List type Forms sorted by values.  The sort is done without regard
to the case of the values.

=cut

sub orderedHash {
	my ($self) = @_;
        my %options;
        tie %options, 'Tie::IxHash';
        if ($self->get("sortByValue")) {
                foreach my $optionKey (sort {"\L${$self->get('options')}{$a}" cmp "\L${$self->get('options')}{$b}" } keys %{$self->get('options')}) {
                         $options{$optionKey} = $self->get('options')->{$optionKey};
                }
        } else {
                %options = %{$self->get('options')};
        }
        return %options;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
	my $self = shift;
        my %options;
        tie %options, 'Tie::IxHash';
	%options = $self->orderedHash();
	my $output;
	my @values = $self->getValues();
        foreach my $key (keys %options) {
                foreach my $item (@values) {
                        if ($item eq $key) {
                                $output .= WebGUI::Form::Hidden->new($self->session,
                                        name=>$self->get("name"),
                                        value=>$key
                                        )->toHtmlAsHidden;
                        }
                }
        }
	return $output;
}

1;

