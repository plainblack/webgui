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

=head2 headTags ( )

Set the head tags for this form plugin

=cut

sub headTags {
    my $self = shift;
    my $style = $self->session->style;
    my $url   = $self->session->url;
	$style->setLink($url->extras('yui/build/container/assets/skins/sam/container.css'), { rel => 'stylesheet', type => 'text/css' });
	$style->setLink($url->extras('yui/build/button/assets/skins/sam/button.css'),       { rel => 'stylesheet', type => 'text/css' });
	$style->setScript($url->extras('yui/build/yahoo/yahoo-min.js'),           { type=>'text/javascript' });
	$style->setScript($url->extras('yui/build/event/event-min.js'),           { type=>'text/javascript' });
	$style->setScript($url->extras('yui/build/connection/connection-min.js'), { type=>'text/javascript' });
	$style->setScript($url->extras('yui/build/element/element-min.js'),       { type=>'text/javascript' });
	$style->setScript($url->extras('yui/build/button/button-min.js'),         { type=>'text/javascript' });
	$style->setScript($url->extras('yui/build/container/container-min.js'),   { type=>'text/javascript' });
	$style->setScript($url->extras('yui-webgui/build/form/form.js'),          { type=>'text/javascript' });
    $style->setScript($url->extras('yui/build/json/json-min.js'),             {type => 'text/javascript'});
    $style->setScript($url->extras('yui-webgui/build/i18n/i18n.js'),          {type => 'text/javascript'} );
	$style->setScript($url->extras('yui-webgui/build/form/groupManager.js'),  { type=>'text/javascript' });
	$style->setLink($url->extras('yui-webgui/build/form/groupManager.css'),   { rel => 'stylesheet', type => 'text/css' });
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
	my $where = '';
	if (($self->get('excludeGroups')->[0]||'') ne "") {
		$where = "and groupId not in (".$self->session->db->quoteAndJoin($self->get("excludeGroups")).")";
	}
	$self->set('options', $self->session->db->buildHashRef("select groupId,groupName from groups where showInForms=1 $where order by groupName"));
	return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
    my $self = shift;
    $self->set("options", $self->session->db->buildHashRef("select groupId,groupName from groups"));
    return $self->SUPER::toHtmlAsHidden();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds a manage icon next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
    my $self = shift;
    my $session = $self->session;
    my $user    = $session->user;
    if ($user->isAdmin) {
        my $subtext = $session->icon->manage("op=listGroups");
        $self->set("subtext", $subtext . $self->get("subtext"));
    }
    my $dialog = $self->get('name') . '_groupDialog';
    my $group_manager = $user->isInGroup($session->setting->get('groupIdAdminGroup'));
    my $form;
    if ($group_manager) {
        my $i18n = WebGUI::International->new($self->session,'Icon');
        my $name    = $self->get('name');
        my $groupId = $self->getOriginalValue;
        my $extra_subtext = qq!<span class="toolbarIcon" style="vertical-align:middle;"><a href="#" onClick="WebGUI.Form.GroupManager.show_dialog('$name'); return false;"><img src="!. $session->icon->getBaseURL().qq!edit.gif" alt="!. $i18n->get('Edit') .qq!"style="vertical-align:middle;border: 0px;" /></a></span>!;
        $extra_subtext .= qq!<span class="toolbarIcon" style="vertical-align:middle;"><a href="#" onClick="WebGUI.Form.GroupManager.show_dialog('$name', 'new'); return false;"><img src="!. $session->icon->getBaseURL().qq!add.gif" alt="!. $i18n->get('Add') .qq!" style="vertical-align:middle;border: 0px;" /></a></span>!;
        $self->set("subtext", $self->get('subtext').$extra_subtext);
    }
    $self->headTags;
    $form .= $self->SUPER::toHtmlWithWrapper;
    return $form;
}

#-------------------------------------------------------------------

=head2 www_groupMembers ($session)

Returns a list of users that are in the sub-group specified by the form variable
variable C<groupId>.  Data returned is in JSON format.

This is a class method.

=head3 $session

A WebGUI::Session object.

=cut

sub www_groupMembers {
    my $session = shift;
    return '{}' unless $session->user->isInGroup($session->setting->get('groupIdAdminGroup'));
    my $groupId = $session->form->param('groupId');
    return '{}' unless $groupId;

    my $group = WebGUI::Group->new($session, $groupId);
    return '{}' unless $group;

    my $results = {
        groupName => $group->name,
        users     => [],
        groups    => [],
    };
    my $userIds = $group->getUsers('withoutExpired');
    USER: foreach my $userId (@{ $userIds }) {
        my $user = WebGUI::User->new($session, $userId);
        next USER unless $user;
        push @{$results->{users}},
        {
            username => $user->username,
            userId   => $userId,
        };
    }
    my $groupIds = $group->getGroupsIn(0); ##Without recursion
    GROUP: foreach my $groupId (@{ $groupIds }) {
        my $group = WebGUI::Group->new($session, $groupId);
        next GROUP unless $group;
        push @{$results->{groups}},
        {
            groupName => $group->name,
            groupId   => $groupId,
        };
    }

    return JSON::to_json($results);
}


#-------------------------------------------------------------------

=head2 www_saveGroup ($session) 

Save new information about the membership of a group, which users have
been added and deleted, and which groups have been added and deleted.

This is a subroutine, not a class method, not an object method.

=head3 $session

A WebGUI::Session object.

=head3 Expected form variables

=head4 groupId

The GUID for the group to modify.

=head4 groupName

The name of the group.  This is always set, so it should always be included.

=head4 usersAdded

A list of userId's for users who were added.

=head4 usersDeleted

A list of userId's for users who were deleted.  Deleting happens after adding.

=head4 groupsAdded

A list of groupId's for groups who were added.

=head4 groupsDeleted

A list of groupId's for groups who were deleted.  Deleting happens after adding.

=cut

sub www_saveGroup {
    my $session = shift;
    $session->log->warn("hit the group plugin");
    return '{}' unless $session->user->isInGroup($session->setting->get('groupIdAdminGroup'));
    my $form    = $session->form;
    my $groupId = $form->get('groupId');
    my $group   = WebGUI::Group->new($session, $groupId);
    $session->log->warn("got groupId: $groupId");
    return '{}' unless $group;

    $session->log->warn("updating group data, name = ".$form->get('groupName'));
    $group->name($form->get('groupName'));
    my @usersAdded    = $form->get('usersAdded');
    use Data::Dumper;
    $session->log->warn("users added ".Dumper(\@usersAdded));
    $group->addUsers(\@usersAdded);
    my @usersDeleted  = $form->get('usersDeleted');
    $group->deleteUsers(\@usersDeleted);
    my @groupsAdded   = $form->get('groupsAdded');
    $session->log->warn("groups added ".Dumper(\@groupsAdded));
    $group->addGroups(\@groupsAdded);
    my @groupsDeleted = $form->get('groupsDeleted');
    $group->deleteGroups(\@groupsDeleted);

    return JSON::to_json({ groupId => $group->getId, groupName => $group->name, originalGroupId => $groupId });
}

#-------------------------------------------------------------------

=head2 www_searchGroups ($session) 

Returns groups that match the supplied group name.  Group name is specified via the form
variable C<search>.  A list of groups will be returned of up to 15 names and groupIds.

This is a subroutine, not a class method, not an object method.

=head3 $session

A WebGUI::Session object.

=head3 Sample JSON

{
    'results' : [
        {
            'groupId': 'someGroupId',
            'groupName' : 'Great Group'
        }
        //Other hashes may be in the list, or it could be completely empty
    ]
}

=cut

sub www_searchGroups {
    my $session = shift;
    return '{"results":[]}' unless $session->user->isInGroup($session->setting->get('groupIdAdminGroup'));
    my $search = $session->form->param('query');

    my $results = $session->db->buildArrayRefOfHashRefs(q|select groupId, groupName from groups where groupName like CONCAT(?, '%') and showInForms=1 LIMIT 15|, [ $search ]);

    return JSON::to_json({ results => $results });
}


1;
