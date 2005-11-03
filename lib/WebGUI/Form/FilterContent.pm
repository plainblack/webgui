package WebGUI::Form::FilterContent;

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
use Tie::IxHash;
use WebGUI::Form::SelectList;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::FilterContent

=head1 DESCRIPTION

Creates a select list containing the content filter options. This is for use with WebGUI::HTML::filter().

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

=head4 name

The name of this field to be passed through the URI. Defaults to "filterContent".

=head4 hoverHelp

A tooltip for what to do with this field. Defaults to a general explaination of content filters.

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
		name=>{
			defaultValue=>"filterContent"
			},
		hoverHelp=>{
			defaultValue=>WebGUI::International::get('418 description')
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("418","WebGUI");
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns either what's posted or if nothing comes back it returns "most".

=cut

sub getValueFromPost {
	my $self = shift;
	return $session{req}->param($self->{name}) || "most";
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Returns a select list containing the content filter options. This is for use with WebGUI::HTML::filter().

=cut

sub toHtml {
	my $self = shift;
        my %filter;
        tie %filter, 'Tie::IxHash';
        %filter = (
                'none'=>WebGUI::International::get(420),
                'macros'=>WebGUI::International::get(891),
                'javascript'=>WebGUI::International::get(526),
                'most'=>WebGUI::International::get(421),
                'all'=>WebGUI::International::get(419)
                );
	return WebGUI::Form::SelectList->new(
		id=>$self->{id},
		options=>\%filter,
		name=>$self->{name},
		value=>[$self->{value}],
		extras=>$self->{extras},
		defaultValue=>[$self->{defaultValue}]
		)->toHtml;

}


1;

