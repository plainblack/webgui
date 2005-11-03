package WebGUI::Form::ContentType;

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

=head1 NAME

Package WebGUI::Form::ContentType

=head1 DESCRIPTION

Creates a content type selector which can be used in conjunction with WebGUI::HTML::filter().

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

=head4 types

An array reference of field types to be displayed. The types are "mixed", "html", "code", and "text".  Defaults to all.

=head4 defaultValue

An array reference of the items to be checked if no value is specified. Defaults to "mixed". Possible values are "mixed", "code", "html", and "text".

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
		types=>{
			defaultValue=>[qw(mixed html code text)]
			},
		defaultValue=>{
			defaultValue=>"mixed",
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("1007","WebGUI");
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns either what's posted or if nothing comes back it returns "mixed".

=cut

sub getValueFromPost {
	my $self = shift;
	return $session{req}->param($self->{name}) || "mixed";
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a select list form control.

=cut

sub toHtml {
	my $self = shift;
	my %types;
	foreach my $type (@{$self->{types}}) {
                if ($type eq "text") {
                        $types{text} = WebGUI::International::get(1010);
                } elsif ($type eq "mixed") {
                        $types{mixed} = WebGUI::International::get(1008);
                } elsif ($type eq "code") {
                        $types{code} = WebGUI::International::get(1011);
                } elsif ($type eq "html") {
                        $types{html} = WebGUI::International::get(1009);
                }
        }
	return WebGUI::Form::SelectList->new(
		options=>\%types,
		id=>$self->{id},
		name=>$self->{name},
		value=>[$self->{value}],
		extras=>$self->{extras},
		defaultValue=>[$self->{defaultValue}]
		)->toHtml;

}



1;

