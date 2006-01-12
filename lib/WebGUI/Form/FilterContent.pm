package WebGUI::Form::FilterContent;

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
use base 'WebGUI::Form::SelectBox';
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::FilterContent

=head1 DESCRIPTION

Creates a select list containing the content filter options. This is for use with WebGUI::HTML::filter().

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

=head4 name

The name of this field to be passed through the URI. Defaults to "filterContent".

=head4 defaultValue

Defaults to "most". Possible values are "none", "macros", "javascript", "most" and "all".

=head4 hoverHelp

A tooltip for what to do with this field. Defaults to a general explaination of content filters.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("418")
			},
		name=>{
			defaultValue=>"filterContent"
			},
		hoverHelp=>{
			defaultValue=>$i18n->get('418 description')
			},
		defaultValue=>{
			defaultValue=>"most",
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns either what's posted or if nothing comes back it returns "most".

=cut

sub getValueFromPost {
	my $self = shift;
	return $self->session->request->param($self->get("name")) || "most";
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
	$self->get("options") = \%filter;
	return $self->SUPER::toHtml();
}

1;
