package WebGUI::Form::User;

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
use base 'WebGUI::Form::Control';
use WebGUI::User;
use WebGUI::Form::Button;
use WebGUI::Form::Hidden;
use WebGUI::Form::Text;

=head1 NAME

Package WebGUI::Form::User

=head1 DESCRIPTION

Creates a user selector field.

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

The name of the field. Defaults to "userId".

=head4 label

Defaults to "User".

=head4 readOnly

Defaults to 0.  Use for displaying a read-only user field.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, "WebGUI");
	push(@{$definition}, {
		label=>{
			defaultValue=>$i18n->get("user"),
			},
		name=>{
			defaultValue=>"userId",
			},
		readOnly=>{
			defaultValue=>0,
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
    return WebGUI::International->new($session, 'WebGUI')->get('user');
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as a name.

=cut

sub getValueAsHtml {
    my $self = shift;
    my $user = WebGUI::User->new($self->session, $self->getOriginalValue);
    if (defined $user) {
        return $user->username;
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

Renders a user selector.

=cut

sub toHtml {
	my $self = shift;
        my $user = WebGUI::User->new($self->session, $self->getOriginalValue);
	my $manage = undef;
        if ($self->session->user->isAdmin) {
                 $manage = " ".$self->session->icon->manage('op=listUsers');
        }
        return WebGUI::Form::Hidden->new($self->session,
                        name=>$self->get("name"),
                        extras=>$self->get("extras"),
                        value=>$user->userId,
			id=>$self->get("id"),
                        )->toHtml
                .WebGUI::Form::Text->new($self->session,
                        name=>$self->get("name")."_display",
                        extras=>' readonly="1" ',
                        value=>$user->username,
			id=>$self->get('id')."_display"
                        )->toHtml
                .($self->get('readOnly')?'':WebGUI::Form::Button->new($self->session,
                        value=>"...",
                        extras=>'onclick="window.open(\''.$self->session->url->page("op=formUsers;formId=".$self->get('id')).'\',\'userPicker\',\'toolbar=no, location=no, status=no, directories=no, width=400, height=400, scrollbars=yes\');"'
                        )->toHtml).$manage;
}

#-------------------------------------------------------------------

=head2 www_searchUsers

Returns users that match the supplied username.  Username is specified via the form
variable C<search>.  A list of usernames will be returned of up to 15 names and userIds.

=cut

sub www_searchUsers {
    my $session = shift;
    return '{"results":[]}' unless $session->user->isInGroup($session->setting->get('groupIdAdminUser'));
    my $search = $session->form->param('query');

    my $results = $session->db->buildArrayRefOfHashRefs(q|select userId, username from users where username like CONCAT(?, '%') LIMIT 15|, [ $search ]);

    return JSON::to_json({ results => $results });
}


1;

