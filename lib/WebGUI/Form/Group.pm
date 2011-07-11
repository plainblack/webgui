package WebGUI::Form::Group;

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
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Form::Group

=head1 DESCRIPTION

Creates a group chooser field.

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

=head4 multiple

Set to "1" if multiple groups should be selectable. Defaults to 0.

=head4 excludeGroups

An array reference containing a list of groups to exclude from the list. Defaults to an empty array reference.

=head4 defaultValue

This will be used if no value is specified. Should be passed as an array reference. Defaults to 7 (Everyone).

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
			defaultValue=>[7]
			},
		excludeGroups=>{
			defaultValue=>[]
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
    return WebGUI::International->new($session, 'WebGUI')->get('group');
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a name.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $group = WebGUI::Group->new($self->session, $self->getOriginalValue);
    if (defined $group) {
        return $group->name;
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
	my $where = '';
	if (($self->get('excludeGroups')->[0]||'') ne "") {
		$where = "and groupId not in (".$self->session->db->quoteAndJoin($self->get("excludeGroups")).")";
	}
	$self->set('options', $self->session->db->buildHashRef("select groupId,groupName from groups where showInForms=1 $where order by groupName"));
    return $self;
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds a manage icon next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
        my $self = shift;
        if ($self->session->user->isAdmin) {
                my $subtext = $self->session->icon->manage("op=listGroups");
                $self->set("subtext",$subtext . $self->get("subtext"));
        }
        return $self->SUPER::toHtmlWithWrapper;
}


1;

