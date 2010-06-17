package WebGUI::Form::AdSpace;

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
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::AdSpace

=head1 DESCRIPTION

Creates a group chooser field for AdSpace values.

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

=head4 size

How many rows should be displayed at once? Defaults to 1.

=head4 defaultValue

This will be used if no value is specified. Should be passed as an array reference. Defaults to 1.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		size=>{
			defaultValue=>1
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
    return WebGUI::International->new($session, 'WebGUI')->get('Ad Space control name');
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a name.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $item = WebGUI::AdSpace->new($self->session, $self->getOriginalValue);
    if (defined $item) {
        return $item->name;
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

=head2 toHtml ( )

Returns a group pull-down field. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.  

=cut

sub toHtml {
	my $self = shift;
	my $options = { map { $_->getId => $_->get('name') } ( @{ WebGUI::AdSpace->getAdSpaces($self->session) } ) };
	$self->set('defaultValue', ( keys %{$options} )[0] );
	$self->set('options', $options );
	return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
        my $self = shift;
	my $options = { map { $_->getId => $_->get('name') } ( @{ WebGUI::AdSpace->getAdSpaces($self->session) } ) };
	$self->set('defaultValue', ( keys %{$options} )[0] );
	$self->set('options', $options );
        return $self->SUPER::toHtmlAsHidden();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds a manage icon next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
        my $self = shift;
        if ($self->session->user->isAdmin) {
                my $subtext = $self->session->icon->manage("op=manageAdSpaces");
                $self->set("subtext",$subtext . $self->get("subtext"));
        }
        return $self->SUPER::toHtmlWithWrapper;
}


1;

