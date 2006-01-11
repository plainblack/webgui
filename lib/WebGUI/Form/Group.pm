package WebGUI::Form::Group;

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
use base 'WebGUI::Form::SelectList';
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Session;
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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
			defaultValue=>WebGUI::International::get("group","WebGUI")
			},
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
		profileEnabled=>{
			defaultValue=>1
			},
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Returns a group pull-down field. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.  

=cut

sub toHtml {
	my $self = shift;
	my $where;
	if ($self->get("excludeGroups")[0] ne "") {
		$where = "and groupId not in (".$self->session->db->quoteAndJoin($self->get("excludeGroups")).")";
	}
	$self->get("options") = $self->session->db->buildHashRef("select groupId,groupName from groups where showInForms=1 $where order by groupName");
	return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
        my $self = shift;
	$self->get("options") = $self->session->db->buildHashRef("select groupId,groupName from groups");
        return $self->SUPER::toHtmlAsHidden();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds a manage icon next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
        my $self = shift;
        if ($self->session->user->isInGroup(3)) {
                my $subtext = manageIcon("op=listGroups");
                $self->get("subtext") = $subtext . $self->get("subtext");
        }
        return $self->SUPER::toHtmlWithWrapper;
}


1;

