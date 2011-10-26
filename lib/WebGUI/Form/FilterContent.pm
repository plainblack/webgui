package WebGUI::Form::FilterContent;

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

=head2  getDatabaseFieldType ( )

Returns "CHAR(16)".

=cut 

sub getDatabaseFieldType {
    return "CHAR(16)";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('418');
}

#-------------------------------------------------------------------

=head2 getValue ( )

Returns either what's posted or if nothing comes back it returns "most".

=cut

sub getValue {
	my $self = shift;
	return $self->SUPER::getValue(@_) || "most";
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

Returns 0.

=cut

sub isDynamicCompatible {
    return 0;
}

#-------------------------------------------------------------------

=head2 new ( )

Extend the base "new" to set options.

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
	my $i18n = WebGUI::International->new($self->session);
    my %filter;
    tie %filter, 'Tie::IxHash';
    %filter = (
        'none'       => $i18n->get(420),
        'macros'     => $i18n->get(891),
        'javascript' => $i18n->get(526),
        'most'       => $i18n->get(421),
        'all'        => $i18n->get(419),
    );
	$self->set("options", \%filter);
    return $self;
}

1;
