package WebGUI::Form::FieldType;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Form::SelectList;
use WebGUI::International;
use WebGUI::Session;
use Tie::IxHash;

=head1 NAME

Package WebGUI::Form::FieldType

=head1 DESCRIPTION

Creates a form control that will allow you to select a form control type.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 size

Defaults to 1. How many characters tall should this control be represented.

=head4 types

An array reference containing the form control types to be selectable. Defaults to all available types.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		label=>{
			defaultValue=>$class->getName()
			},
		size=>{
			defaultValue=>1
			},
		types=>{
			defaultValue=>$class->getTypes
			}
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("744","WebGUI");
}

#-------------------------------------------------------------------

=head2 getTypes ( )

A class method that returns an array reference of all the form control types present in the system.

=cut

sub getTypes {
	my $class = shift;
	opendir(DIR,$session{config}{webguiRoot}."/lib/WebGUI/Form/");
	my @rawTypes = readdir(DIR);
	closedir(DIR);
	my @types;
	foreach my $type (@rawTypes) {
		if ($type =~ /^(.*)\.pm$/) {
			next if ($1 eq "Control");
			push(@types,$1);
		}
	}
	return \@types;
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns either what's posted or if nothing comes back it returns "text".

=cut

sub getValueFromPost {
        my $self = shift;
        return $session{req}->param($self->{name}) || "text";
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a question selector asking the user where they want to go.

=cut

sub toHtml {
	my $self = shift;
	my %options;
	tie %options, "Tie::IxHash";
	foreach my $type (@{$self->{types}}) {
		my $class = "WebGUI::Form::".ucfirst($type);
		my $cmd = "use ".$class;
        	eval ($cmd);    
        	if ($@) { 
                	WebGUI::ErrorHandler::error("Couldn't compile form control: ".$type.". Root cause: ".$@);
			next;
        	} 
		$options{$type} = $class->getName;
	}
	return WebGUI::Form::SelectList->new(
		id=>$self->{id},
		name=>$self->{name},
		options=>\%options,
		value=>[$self->{value}],
		extras=>$self->{extras},
		size=>$self->{size}
		)->toHtml;
}



1;

