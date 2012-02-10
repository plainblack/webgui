package WebGUI::Form::List;

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
use base 'WebGUI::Form::Control';
use WebGUI::Form::Hidden;
use WebGUI::International;
use Tie::IxHash;

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
		return "&nbsp;&nbsp;";
	}
}

#-------------------------------------------------------------------

=head2 areOptionsSettable ( )

Returns a boolean indicating whether the options of the list are settable. Some have a predefined set of options. This is useful in generating dynamic forms. Returns 1.

=cut

sub areOptionsSettable {
    return 1;
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

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
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
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "LONGTEXT".

=cut 

sub getDatabaseFieldType {
    return "LONGTEXT";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('486');
}

#-------------------------------------------------------------------

=head2 getOptions ( )

Options are passed in for many list types. Those options can come in as a hash ref, or a \n separated string, or a key|value\n separated string. This method returns a hash ref regardless of what's passed in.

=cut

sub getOptions {
    my ($self) = @_;
    my $possibleValues = $self->get('options');
    my %options = ();
    tie %options, 'Tie::IxHash';
    if (ref $possibleValues eq "HASH") {
        %options = %{$possibleValues};
    }
    elsif (ref $possibleValues eq 'ARRAY') {
        %options = @$possibleValues;
    }
    else {
        foreach my $line (split "\n", $possibleValues) {
            $line =~ s/^(.*)\r|\s*$/$1/;
            if ($line =~ m/(.*)\|(.*)/) {
                $options{$1} = $2;
            }
            else {
                $options{$line} = $line;
            }
        }
    } 
    if ($self->get('sortByValue')) {
        my %ordered = ();
        tie %ordered, 'Tie::IxHash';
        foreach my $optionKey (sort {"\L$options{$a}" cmp "\L$options{$b}" } keys %options) {
            $ordered{$optionKey} = $options{$optionKey};
        }
        return \%ordered;
    }
    return \%options;
}


#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar. Also parses the input values (wherever they come from) to see if it's a scalar then it splits on \n.

=head3 value

Optional values to process, instead of POST input.

=cut

sub getValue {
	my ($self, $value) = @_;
    
    my @values = ();
    if (defined $value) {
        if (ref $value eq "ARRAY") {
            @values = @{$value};
        }
        else {
			$value =~ s/\r//g;
            @values = split "\n", $value;
        }
    }
    if (scalar @values < 1 && $self->session->request) {
        my $value = $self->session->form->param($self->get("name"));
        if (defined $value) {
            @values = $self->session->form->param($self->get("name"));
        }
    }
    if (scalar @values < 1 && ! $self->get('allowEmpty')) {
        @values = $self->getDefaultValue;
    }
	return wantarray ? @values : join("\n",@values);
}

#-------------------------------------------------------------------

=head2 getDefaultValue ( )

Returns the either the "value" or "defaultValue" passed in to the object in that order, and doesn't take into account form processing.

=cut

sub getDefaultValue {
    my $self = shift;
    my @values = ();
    
    foreach my $value ($self->get('defaultValue')) {
        if (scalar @values < 1 && defined $value) {
            if (ref $value eq "ARRAY") {
                @values = @{$value};
            }
            else {
				$value =~ s/\r//g;
                @values = split /\n/, $value;
            }
        }
    }
	return wantarray ? @values : join("\n",@values);
}


=head2 getOriginalValue ( )

Returns the either the "value" or "defaultValue" passed in to the object in that order, and doesn't take into account form processing.

=cut

sub getOriginalValue {
    my $self = shift;
    my @values = ();
    my $value = $self->get("value");
    if (defined $value) {
        if (ref $value eq "ARRAY") {
            @values = @{$value};
        }
        else {
            $value =~ s/\r//g;
            @values = split "\n", $value;
        }
    }
    if (@values || ($self->get('allowEmpty') && defined $value) ) {
        return wantarray ? @values : join("\n",@values);
    }

    return $self->getDefaultValue;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Return all the options

=cut

sub getValueAsHtml {
	my ($self) = @_;
    my $options = $self->getOptions;
    return join ", ", map { $options->{$_} } $self->getOriginalValue;
}

#-------------------------------------------------------------------

=head2 getValues ( )

Depricated. See getValue().

=cut

sub getValues {
	my $self = shift;
    return $self->getValue(@_);
}


#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
	my $self = shift;
	my $options = $self->getOptions();
	my $output;
	my @values = $self->getOriginalValue();
    foreach my $key (keys %{$options}) {
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

