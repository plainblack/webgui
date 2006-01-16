package WebGUI::Form::DatabaseLink;

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
use base 'WebGUI::Form::SelectBox';
use WebGUI::DatabaseLink;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::DatabaseLink

=head1 DESCRIPTION

Creates a database connection chooser control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::SelectBox.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

The identifier for this field. Defaults to "databaseLinkId".

=head4 defaultValue

A database link id. Defaults to "0", which is the WebGUI database.

=head4 afterEdit

A URL that will be acted upon after editing a database link. 

=head4 hoverHelp

A tooltip to tell the user what to do with the field. Defaults a standard piece of help for Database Links.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("1075")
			},
		label=>{
			defaultValue=>$i18n->get("1075")
			},
		name=>{
			defaultValue=>"databaseLinkId"
			},
		defaultValue=>{
			defaultValue=>0
			},
		afterEdit=>{
			defaultValue=>undef
			},
		hoverHelp=>{
			defaultValue=>$i18n->get('1075 description')
			},
		});
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a database connection picker control.

=cut

sub toHtml {
	my $self = shift;
	$self->set("options",  WebGUI::DatabaseLink->getList($self->session));
	return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds manage and edit icons next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
	if ($self->session->user->isInGroup(3)) {
		my $subtext;
		if ($self->get("afterEdit")) {
			$subtext = $self->session->icon->edit("op=editDatabaseLink;lid=".$self->get("value").";afterEdit=".$self->session->url->escape($self->get("afterEdit")));
		}
		$subtext .= $self->session->icon->manage("op=listDatabaseLinks");
		$self->get("subtext") = $subtext . $self->get("subtext");
	}
	return $self->SUPER::toHtmlWithWrapper;
}




1;

