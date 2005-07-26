package WebGUI::Form::Control;

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
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::Control

=head1 DESCRIPTION

Base class for all form field objects. Never use this class directly.

=head1 SYNOPSIS

 use base 'WebGUI::Form::Control';

 ...your methods here...

Subclasses will look like this:

 use WebGUI::Form::subclass;
 my $obj = WebGUI::Form::subclass->new(%params);

 my $html = $obj->toHtml;
 my $html = $obj->toHtmlAsHidden;
 my $tableRows = $obj->toHtmlWithWrapper;

=head1 METHODS 

The following methods are available via this package.

=cut


#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

Defines the schema or parameters for a form field.

=head3 additionalTerms

An array reference containing a hash of hashes of parameter names and their definitions.

Example: 

  [{
     myParam=>{
	defaultValue=>undef
    	}
	}]

By default all form fields have the following parameters:

=head4 name

The field name.

=head4 value

The starting value for the field.

=head4 defaultValue

If no starting value is specified, this will be used instead.

=head4 extras

Add extra attributes to the form tag like 

  onmouseover='doSomething()'

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called.

=head4 uiLevel

The UI Level that the user must meet or exceed if this field should be displayed with toHtmlWithWrapper() is called.

=head4 uiLevelOverride

An identifier that will be grabbed from the config file to determine the uiLevel. If the uiLevelOverride is "Article" and the name is "title" then the entry in the config file would look like:

 Article_uiLevel = title => 5

=head4 subtext

A text string that will be appended after the field when toHtmlWithWrapper() is called.

=head4 labelClass

A stylesheet class assigned to the label with toHtmlWithWrapper() is called. Defaults to "formDescription".

=head4 fieldClass

A stylesheet class assigned to wrapper the field when toHtmlWithWrapper() is called. Defaults to "tableData".

=head4 rowClass

A stylesheet class assigned to each label/field pair.

=head4 hoverHelp

A text string that will pop up when the user hovers over the label when toHtmlWithWrapper() is called. This string should indicate how to use the field and is usually tied into the help system.

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		name=>{
			defaultValue=>undef
			},
		value=>{
			defaultValue=>undef
			},
		extras=>{
			defaultValue=>undef
			},
		defaultValue=>{
			defaultValue=>undef
			},
		label=>{
			defaultValue=>undef
			},
		uiLevel=>{
			defaultValue=>1
			},
		uiLevelOverride=>{
			defaultValue=>undef
			},
		labelClass=>{
			defaultValue=>"formDescription"
			},
		fieldClass=>{
			defaultValue=>"tableData"
			},
		rowClass=>{
			defaultValue=>undef
			},
		hoverHelp=>{
			defaultValue=>undef
			},
		subtext=>{
			defaultValue=>undef
			}
		});
	return $definition;
}

#-------------------------------------------------------------------

=head2 fixMacros ( string ) 

Returns the string having converted all macros in the string to HTML entities so that they won't be processed my the macro engine, but instead will be displayed.

=head3 string

The string to search for macros in.

=cut

sub fixMacros {
	my $self = shift;
        my $value = shift;
        $value =~ s/\^/\&\#94\;/g;
        return $value;
}

#-------------------------------------------------------------------

=head2 fixQuotes ( string )

Returns the string having replaced quotes with HTML entities. This is important so not to screw up HTML attributes which use quotes as delimiters.

=head3 string

The string to search for quotes in.

=cut

sub fixQuotes {
	my $self = shift;
        my $value = shift;
        $value =~ s/\"/\&quot\;/g;
        return $value;
}

#-------------------------------------------------------------------

=head2 fixSpecialCharacters ( string )

Returns a string having converted any characters that have special meaning in HTML to HTML entities. Currently the only character is ampersand.

=head3 string

The string to search for special characters in.

=cut

sub fixSpecialCharacters {
	my $self = shift;
        my $value = shift;
        $value =~ s/\&/\&amp\;/g;
        return $value;
}

#-------------------------------------------------------------------

=head2 fixTags ( string )

Returns a string having converted HTML tags into HTML entities. This is useful when you have HTML that you need to render inside of a <textarea> for instance.

=head3 string

The string to search for HTML tags in.

=cut

sub fixTags {
	my $self = shift;
        my $value = shift;
        $value =~ s/\</\&lt\;/g;
        $value =~ s/\>/\&gt\;/g;
        return $value;
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Retrieves a value from a form GET or POST and returns it. If the value comes back as undef, this method will return the defaultValue instead.

=cut

sub getValueFromPost {
	my $self = shift;
	my $formValue = $session{cgi}->param($self->{name});
	if (defined $formValue) {
		return $formValue;
	} else {
		return $self->{defaultValue};
	}
}

#-------------------------------------------------------------------

=head2 new ( parameters )

Constructor. Creates a new form field object.

=head3 parameters

Accepts any parameters specified by the definition() method. This parameter set can be specified by either a hash or hash reference, and can be tagged or not. Here are examples:

 my $obj = $class->new({ name=>"this", value=>"that"});
 my $obj = $class->new({ -name=>"this", -value=>"that"});
 my $obj = $class->new(name=>"this", value=>"that");
 my $obj = $class->new(-name=>"this", -value=>"that");

=cut

sub new {
	my $class = shift;
	my %raw;
	# deal with a hash reference full of properties
	if (ref $_[0] eq "HASH") {
		%raw = %{$_[0]};
	} else {
		%raw = @_;
	}
	my %params;
	# Ensure that overrides overwrite the previously defined definition of a field
	my @reversedDefinitions = reverse @{$class->definition};
	foreach my $definition (@reversedDefinitions) {
		foreach my $fieldName (keys %{$definition}) {
			$params{$fieldName} = $raw{$fieldName} || $raw{"-".$fieldName} || $definition->{$fieldName}{defaultValue};
		}
	}
	unless (exists $params{value}) {
		$params{value} = $params{defaultValue};
	}
WebGUI::ErrorHandler::debug($class);
	bless \%params, $class;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders the form field to HTML. This method should be overridden by all subclasses.

=cut

sub toHtml {
	my $self = shift;
	return $self->{value};
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders the form field to HTML as a hidden field rather than whatever field type it was supposed to be.

=cut

sub toHtmlAsHidden {
	my $self = shift;
        return '<input type="hidden" name="'.$self->{name}.'" value="'.$self->fixQuotes($self->fixMacros($self->fixSpecialCharacters($self->{value}))).'" />'."\n";
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
	if ($self->{uiLevel} <= $session{user}{uiLevel} 
		|| ( $session{config}{$self->{uiLevelOverride}}{$self->{name}} 
		&& $session{config}{$self->{uiLevelOverride}}{$self->{name}} <= $session{user}{uiLevel})) 
		{
		my $rowClass = $self->{rowClass};
        	$rowClass = qq| class="$rowClass" | if($self->{rowClass});
		my $labelClass = $self->{labelClass};
       	 	$labelClass = qq| class="$labelClass" | if($self->{labelClass});
		my $fieldClass = $self->{fieldClass};
	        $fieldClass = qq| class="$fieldClass" | if($self->{fieldClass});
		my $hoverHelp = $self->{hoverHelp};
        	$hoverHelp =~ s/\r/ /g;
        	$hoverHelp =~ s/\n/ /g;
        	$hoverHelp =~ s/&amp;/& amp;/g;
        	$hoverHelp =~ s/&gt;/& gt;/g;
        	$hoverHelp =~ s/&lt;/& lt;/g;
        	$hoverHelp =~ s/&/&amp;/g;
        	$hoverHelp =~ s/>/&gt;/g;
        	$hoverHelp =~ s/</&lt;/g;
        	$hoverHelp =~ s/"/&quot;/g;
        	$hoverHelp =~ s/'/\\'/g;
        	$hoverHelp =~ s/^\s+//;
        	$hoverHelp = qq| onmouseover="return escape('$hoverHelp')"| if ($hoverHelp);
		my $subtext = $self->{subtext};
		$subtext = qq| <span class="formSubtext">$subtext</span>| if ($subtext);
		return '<tr'.$rowClass.'><td'.$labelClass.$hoverHelp.' valign="top" style="width: 25%;">'.$self->{label}.'</td><td valign="top"'.$fieldClass.' style="width: 75%;">'.$self->toHtml.$subtext."</td></tr>\n";
	} else {
		return $self->toHtmlAsHidden;
	}
}

1;

