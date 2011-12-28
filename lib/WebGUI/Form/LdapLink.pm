package WebGUI::Form::LdapLink;

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
use base 'WebGUI::Form::SelectList';
use WebGUI::LDAPLink;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::LdapLink

=head1 DESCRIPTION

Creates an LDAP connection chooser control.

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

=head4 name

The identifier for this field. Defaults to "ldapLinkId".

=head4 size 

The number of characters tall this list should be. Defaults to '1'.

=head4 multiple 

Boolean indicating whether the user can select multiple items from this list like a checkList. Defaults to "0".

=head4 defaultValue

An LDAP link id. Defaults to "0", which is nothing.

=head4 afterEdit

A URL that will be acted upon after editing an LDAP link. 

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
			defaultValue=>$i18n->get("LDAPLink_1075","AuthLDAP")
			},
		size=>{
			defaultValue=>1
			},
		multiple=>{
			defaultValue=>0
			},
		name=>{
			defaultValue=>"ldapLinkId"
			},
		defaultValue=>{
			defaultValue=>[0]
			},
		afterEdit=>{
			defaultValue=>undef
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
    return WebGUI::International->new($session, 'AuthLDAP')->get('LDAPLink_1075');
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
	$self->set("options", WebGUI::LDAPLink->getList($self->session));
    return $self;
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds manage and edit icons next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
	if ($self->session->user->isAdmin) {
		my $subtext;
		if ($self->get("afterEdit")) {
			$subtext = $self->session->icon->edit("op=editLDAPLink;llid=".$self->getOriginalValue.";afterEdit=".$self->session->url->escape($self->get("afterEdit")));
		}
         	$subtext .= $self->session->icon->manage("op=listLDAPLinks");
		$self->set("subtext", $subtext . $self->get("subtext"));
	}
	return $self->SUPER::toHtmlWithWrapper;
}



1;

