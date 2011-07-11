package WebGUI::Form::Vendor;

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
use base 'WebGUI::Form::SelectList';
use WebGUI::International;
use WebGUI::Shop::Admin;
use WebGUI::Shop::Vendor;

=head1 NAME

Package WebGUI::Form::Vendor

=head1 DESCRIPTION

Creates a vendor chooser field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectList.

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

=head4 defaultValue

This will be used if no value is specified. Defaults to 'defaultvendor000000000' which is "Default Vendor".

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		size=>{
			defaultValue=>1
			},
		multiple=>{
			defaultValue=>0
			},
		defaultValue=>{
			defaultValue=>'defaultvendor000000000'
			},
        });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(22) BINARY".

=cut 

sub getDatabaseFieldType {
    return "CHAR(22) BINARY";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'Shop')->get('vendors');
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a name.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $vendor = eval{WebGUI::Shop::Vendor->new($self->session, $self->getOriginalValue)};
    if (!$@ && defined $vendor) {
        return $vendor->get('name');
    }
    return undef;
}


#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 new ( )

Extend the base "new" to set options.

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
	$self->set('options', WebGUI::Shop::Vendor->getVendors($self->session, {asHashRef=>1}));
    return $self;
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds a manage icon next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
        my $self = shift;
        if (WebGUI::Shop::Admin->new($self->session)->canManage) {
                my $subtext = $self->session->icon->manage("shop=vendor;method=manage");
                $self->set("subtext",$subtext . $self->get("subtext"));
        }
        return $self->SUPER::toHtmlWithWrapper;
}


1;

