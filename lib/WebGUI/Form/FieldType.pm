package WebGUI::Form::FieldType;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Utility;
use Tie::IxHash;

=head1 NAME

Package WebGUI::Form::FieldType

=head1 DESCRIPTION

Creates a form control that will allow you to select a form control type.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 types

An array reference containing the form control types to be selectable. Defaults to all available types.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=head4 optionsSettable

A boolean indicating whether the options are settable using an options hashref or not settable because this form
type generates its own options.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("fieldtype","WebGUI")
			},
		label=>{
			defaultValue=>$i18n->get("fieldtype","WebGUI")
			},
		types=>{
			defaultValue=>$class->getTypes($session)
			},
		optionsSettable=>{
            defaultValue=>0
            },
        });
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getTypes ( )

A class method that returns an array reference of all the valid form
control types present in the system.  Invalid form types include
Control.pm, the form master class and List, the list form master class
and DynamicField, the form class dispatcher.

=cut

sub getTypes {
	my $class = shift;
	my $session = shift;
	opendir(DIR,$session->config->getWebguiRoot."/lib/WebGUI/Form/");
	my @rawTypes = readdir(DIR);
	closedir(DIR);
	my @types;
	foreach my $type (@rawTypes) {
		if ($type =~ /^(.*)\.pm$/) {
			next if (isIn($1, qw/Control List DynamicField Slider/));
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
	my $fieldType = $self->session->form->param($self->get("name"));
	$fieldType =~ s/[^\w]//g;
	return $fieldType || "text";
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a fieldType selector.

=cut

sub toHtml {
	my $self = shift;
	my %options;
	tie %options, "Tie::IxHash";
	foreach my $type (@{ $self->get('types') }) {
		my $class = "WebGUI::Form::".ucfirst($type);
		my $cmd = "use ".$class;
        	eval ($cmd);    
        	if ($@) { 
                	$self->session->errorHandler->error("Couldn't compile form control: ".$type.". Root cause: ".$@);
			next;
        	} 
        next unless $class->isProfileEnabled($self->session);
		$options{$type} = $class->getName($self->session);
	}
	$self->set('options',\%options);

	return $self->SUPER::toHtml();
}



1;

