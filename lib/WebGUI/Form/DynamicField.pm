package WebGUI::Form::DynamicField;

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
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Form::DynamicField

=head1 DESCRIPTION

Creates the appropriate form field type given the inputs.

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

=head4 fieldType

Defaults to "Text". Should be any valid field type.

=cut

sub definition {
        my $class = shift;
        my $definition = shift || [];
        push(@{$definition}, {
                formName=>{
                        defaultValue=>WebGUI::International::get("475","WebGUI"),
                        },
                fieldType=>{
                        defaultValue=> "Text"
                        },
                });
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 new ( params)

Creates the object for the appropriate field type.

=head3 params

The normal params you'd pass in to the field. Included in this list must be one element called "fieldType" which specifies what type of field to dynamically render.

=cut

sub new {
	my $class = shift;
	my %raw = @_;
	my $param = \%raw;
        my $fieldType = ucfirst($param->{fieldType});
	delete $param->{fieldType};
	my $size;
	if (exists $param->{size}) {
		$size = $param->{size};
		delete $param->{size};
	}
        # Return the appropriate field object.
	if ($fieldType eq "") {
		WebGUI::ErrorHandler::warn("Something is trying to create a dynamic field called ".$param->{name}.", but didn't pass in a field type.");
		$fieldType = "Text";
	}
	##No infinite loops, please
	elsif ($fieldType eq 'DynamicField') {
		WebGUI::ErrorHandler::warn("Something is trying to create a DynamicField via DynamicField.");
		$fieldType = "Text";
	}
        no strict 'refs';
	my $cmd = "WebGUI::Form::".$fieldType;
	my $load = "use ".$cmd;
	eval ($load);
	if ($@) {
                WebGUI::ErrorHandler::error("Couldn't compile form control: ".$fieldType.". Root cause: ".$@);
                return undef;
        }
	my $formObj = $cmd->new($param);
	##Fix up methods for List type forms and restore the size to all Forms *except*
	##List type forms
	if ($formObj->isa('WebGUI::Form::List')) {
		$formObj->correctValues($param->{value});
		$formObj->correctOptions($param->{possibleValues});
	}
	elsif ($size) {
		$formObj->{size} = $size;
	}
        return $formObj;
}


1;

