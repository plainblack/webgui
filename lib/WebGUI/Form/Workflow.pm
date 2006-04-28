package WebGUI::Form::Workflow;

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
use WebGUI::Workflow;
use WebGUI::International;

=head1 NAME

Package WebGUI::Workflow

=head1 DESCRIPTION

Creates a workflow chooser control.

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

The identifier for this field. Defaults to "workflowId".

=head4 type
                
The type of workflows to list based upon the object type that will be passed to them "none", "WebGUI::VersionTag", etc. If this is omitted, the entire list of workflows will be returned.
                
=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=head4 none

If set to 1 then a "None" option will appear in the list of workflows, which will store a null value in the field. Defaults to 0.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, 'Workflow');
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("topicName")
			},
		label=>{
			defaultValue=>$i18n->get("topicName")
			},
		name=>{
			defaultValue=>"workflowId"
			},
		type=>{
			defaultValue=>undef
			},
		none=>{
			defaulValue=>0
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a template picker control.

=cut

sub toHtml {
	my $self = shift;
	my $workflowList = WebGUI::Workflow->getList($self->session, $self->get("type"));
	$workflowList->{""} = "None" if ($self->get("none"));
	$self->set("options", $workflowList);
	return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds manage and edit icons next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
        my $returnUrl = ";proceed=goBackToPage;returnUrl=".$self->session->url->escape($self->session->asset->getUrl) if $self->session->asset;
        my $buttons = $self->session->icon->edit("op=editWorkflow;workflowId=".$self->get("value").$returnUrl) if ($self->get("value"));
        $buttons .= $self->session->icon->manage("op=manageWorkflows".$returnUrl);
	$self->set("subtext",$buttons . $self->get("subtext"));
	return $self->SUPER::toHtmlWithWrapper;
}


1;
