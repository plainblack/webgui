package WebGUI::Form::Group;

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
use WebGUI::Form::HiddenList;
use WebGUI::Form::SelectList;
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Form::group

=head1 DESCRIPTION

Creates a group chooser field.

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

=head4 size

How many rows should be displayed at once? Defaults to 1.

=head4 multiple

Set to "1" if multiple groups should be selectable. Defaults to 0.

=head4 excludeGroups

An array reference containing a list of groups to exclude from the list. Defaults to an empty array reference.

=head4 defaultValue

This will be used if no value is specified. Should be passed as an array reference. Defaults to 7 (Everyone).

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
		size=>{
			defaultValue=>1
			},
		defaultValue=>{
			defaultValue=>[7]
			},
		multiple=>{
			defaultValue=>0
			},
		excludeGroups=>{
			defaultValue=>[]
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("group","WebGUI");
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns either what's posted or if nothing comes back it returns "2" the ID of the Registered Users group.

=cut

sub getValueFromPost {
	my $self = shift;
        my @data = $session{req}->param($self->{name});
        if (scalar(@data)) {
		return wantarray ? @data : join("\n",@data);
	}
	return wantarray ? @{[2]} : 2;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Returns a group pull-down field. A group pull down provides a select list that provides name value pairs for all the groups in the WebGUI system.  

=cut

sub toHtml {
	my $self = shift;
	my $where;
	if ($self->{excludeGroups}[0] ne "") {
		$where = "and groupId not in (".quoteAndJoin($self->{excludeGroups}).")";
	}
	return WebGUI::Form::SelectList->new(
		options=>WebGUI::SQL->buildHashRef("select groupId,groupName from groups where showInForms=1 $where order by groupName"),
		name=>$self->{name},
		id=>$self->{id},
		value=>$self->{value},
		extras=>$self->{extras},
		size=>$self->{size},
		multiple=>$self->{multiple},
		defaultValue=>$self->{defaultValue}
		)->toHtml;

}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
        my $self = shift;
        return WebGUI::Form::HiddenList->new(
                value=>$self->{value},
                defaultValue=>$self->{defaultValue},
                name=>$self->{name},
                options=>WebGUI::SQL->buildHashRef("select groupId,groupName from groups")
                )->toHtmlAsHidden;
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds a manage icon next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
        my $self = shift;
        if (WebGUI::Grouping::isInGroup(3)) {
                my $subtext = manageIcon("op=listGroups");
                $self->{subtext} = $subtext . $self->{subtext};
        }
        return $self->SUPER::toHtmlWithWrapper;
}


1;

