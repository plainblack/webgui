package WebGUI::Form::ContentType;

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
use base 'WebGUI::Form::SelectBox';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::ContentType

=head1 DESCRIPTION

Creates a content type selector which can be used in conjunction with WebGUI::HTML::filter().

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

=head4 types

An array reference of field types to be displayed. The types are "mixed", "html", "code", and "text".  Defaults to all.

=head4 defaultValue

An array reference of the items to be checked if no value is specified. Defaults to "mixed". Possible values are "mixed", "code", "html", and "text".

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		label=>{
			defaultValue=>$i18n->get("1007")
			},
		types=>{
			defaultValue=>[qw(mixed html code text)]
			},
		defaultValue=>{
			defaultValue=>"mixed",
			},
        });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('1007');
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
    my %types;
    my $i18n = WebGUI::International->new($self->session);
    foreach my $type (@{ $self->get('types') }) {
        if ($type eq "text") {
            $types{text} = $i18n->get(1010);
        }
        elsif ($type eq "mixed") {
            $types{mixed} = $i18n->get(1008);
        }
        elsif ($type eq "code") {
            $types{code} = $i18n->get(1011);
        }
        elsif ($type eq "html") {
            $types{html} = $i18n->get(1009);
        }
    }
    $self->set("options", \%types);
    return $self;
}

1;
