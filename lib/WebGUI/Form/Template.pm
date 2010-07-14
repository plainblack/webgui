package WebGUI::Form::Template;

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

The identifier for this field. Defaults to "templateId".

=head4 namespace

The namespace for the list of templates to return. If this is omitted, all templates will be displayed.

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=head4 onlyCommitted

If true, this will limit the list of template to only include templates that are committed.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
    my $i18n = WebGUI::International->new($session, 'Asset_Template');
    push(@{$definition}, {
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
    return WebGUI::International->new($session, 'Asset_Template')->get('assetName');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

Returns 0.

=cut

sub isDynamicCompatible {
    return 0;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Returns the tempalte name of the selected template.

=cut

sub getValueAsHtml {
    my $self    = shift;

    $self->setOptions;

    return $self->SUPER::getValueAsHtml;
}

#-------------------------------------------------------------------

=head2 setOptions

Fills the options of the select list with the appropriate templates.

=cut

sub setOptions {
    my $self    = shift;
    my $session = $self->session;
    my $userId  = $session->user->userId;

    my $onlyCommitted   = $self->get( 'onlyCommitted' ) 
                        ? q{assetData.status='approved'}
                        : $self->get( 'onlyCommitted' )
                        ;
    my $templateList    = WebGUI::Asset::Template->getList( $session, $self->get( 'namespace' ), $onlyCommitted );

    #Remove entries from template list that the user does not have permission to view.
    for my $assetId ( keys %{$templateList} ) {
        my $asset = eval { WebGUI::Asset->newById($session, $assetId); };
        if (!Exception::Class->caught() && !$asset->canView($self->session->user->userId)) {
            delete $templateList->{$assetId};
        }
    }

    $self->set( 'options', $templateList );

    return;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a template picker control.

=cut

sub toHtml {
    my $self = shift;
    
    $self->setOptions;

    return $self->SUPER::toHtml();
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds manage and edit icons next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
    my $self     = shift;
    my $session  = $self->session;
    my $template = eval { WebGUI::Asset::Template->newById($session, $self->getOriginalValue()); };
        if (!Exception::Class->caught() && $template->canEdit) {
            my $returnUrl;
            if (defined $session->asset && ref $session->asset ne "WebGUI::Asset::Template") {
                $returnUrl = ";proceed=goBackToPage;returnUrl=".$session->url->escape($self->session->asset->getUrl);
            }
            my $buttons = $session->icon->edit("func=edit".$returnUrl,$template->get("url"));
            my $parent = $template->getParent();
            if (defined $parent) {
                $buttons .= $session->icon->manage("op=assetManager",$template->getParent->get("url"));
            }
        $self->set("subtext",$buttons . $self->get("subtext"));
    }
    return $self->SUPER::toHtmlWithWrapper;
}

1;
