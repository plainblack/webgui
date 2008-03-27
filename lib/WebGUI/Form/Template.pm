package WebGUI::Form::Template;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Asset::Template;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Template

=head1 DESCRIPTION

Creates a template chooser control.

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

The identifier for this field. Defaults to "templateId".

=head4 namespace

The namespace for the list of templates to return. If this is omitted, all templates will be displayed.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=head4 onlyCommitted

If true, this will limit the list of template to only include templates that are committed.

=head4 optionsSettable

A boolean indicating whether the options are settable using an options hashref or not settable because this form
type generates its own options.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, 'Asset_Template');
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("assetName")
			},
		label=>{
			defaultValue=>$i18n->get("assetName")
			},
		name=>{
			defaultValue=>"templateId"
			},
		namespace=>{
			defaultValue=>undef
			},
		onlyCommitted=>{
			defaultValue=>''
			},
        dbDataType  => {
            defaultValue    => "VARCHAR(22) BINARY",
            },
		optionsSettable=>{
            defaultValue=>0
            },
        });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a template picker control.

=cut

sub toHtml {
	my $self = shift;
    my $onlyCommitted = $self->get('onlyCommitted') ? "assetData.status='approved'" : $self->get('onlyCommitted');
    my $templateList = WebGUI::Asset::Template->getList($self->session, $self->get("namespace"), $onlyCommitted);
    #Remove entries from template list that the user does not have permission to view.
    for my $assetId ( keys %{$templateList} ) {
        my $asset = WebGUI::Asset::Template->new($self->session, $assetId);
        if (!$asset->canView($self->session->user->userId)) {
                delete $templateList->{$assetId};
        }
    }
	$self->set("options", $templateList);
	return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds manage and edit icons next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
	my $template = WebGUI::Asset::Template->new($self->session,$self->get('value'));
        if (defined $template && $template->canEdit) {
                my $returnUrl;
                if (defined $self->session->asset && ref $self->session->asset ne "WebGUI::Asset::Template") {
                        $returnUrl = ";proceed=goBackToPage;returnUrl=".$self->session->url->escape($self->session->asset->getUrl);
                }
                my $buttons = $self->session->icon->edit("func=edit".$returnUrl,$template->get("url"));
                $buttons .= $self->session->icon->manage("func=manageAssets",$template->getParent->get("url"));
		$self->set("subtext",$buttons . $self->get("subtext"));
	}
	return $self->SUPER::toHtmlWithWrapper;
}

1;
