package WebGUI::Asset::Wobject::StoryArchive;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::Asset::Story;
use WebGUI::Asset::Wobject::Folder;
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------

=head2 definition ( )

defines wobject properties for New Wobject instances.  You absolutely need 
this method in your new Wobjects.  If you choose to "autoGenerateForms", the
getEditForm method is unnecessary/redundant/useless.  

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session, 'Asset_StoryArchive');
    my %properties;
    tie %properties, 'Tie::IxHash';
    %properties = (
        storiesPerFeed => {
            tab          => 'display',  
            fieldType    => 'integer',  
            label        => $i18n->get('stories per feed'),
            hoverHelp    => $i18n->get('stories per feed help'),
            defaultValue => 25,
        },
        storiesPerPage => {
            tab          => 'display',  
            fieldType    => 'integer',  
            label        => $i18n->get('stories per feed'),
            hoverHelp    => $i18n->get('stories per feed help'),
            defaultValue => 25,
        },
        groupToPost => {
            tab          => 'security',  
            fieldType    => 'group',  
            label        => $i18n->get('group to post'),
            hoverHelp    => $i18n->get('group to post help'),
            defaultValue => '12',
        },
        templateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('template'),
            hoverHelp    => $i18n->get('template help'),
            filter       => 'fixId',
            namespace    => 'StoryArchive',
            defaultValue => '',
        },
        storyTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('story template'),
            hoverHelp    => $i18n->get('story template help'),
            filter       => 'fixId',
            namespace    => 'Story',
            defaultValue => '',
        },
        editStoryTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('edit story template'),
            hoverHelp    => $i18n->get('edit story template help'),
            filter       => 'fixId',
            namespace    => 'Story/Edit',
            defaultValue => '',
        },
        archiveAfter => {
            tab          => 'display',  
            fieldType    => 'interval',  
            label        => $i18n->get('archive after'),
            hoverHelp    => $i18n->get('archive after help'),
            defaultValue => 31536000,
        },
        richEditorId => {
            tab          => 'display',  
            fieldType    => 'selectRichEditor',  
            label        => $i18n->get('rich editor'),
            hoverHelp    => $i18n->get('rich editor help'),
            defaultValue => 'PBrichedit000000000002',
        },
    );
    push(@{$definition}, {
        assetName=>$i18n->get('assetName'),
        icon=>'assets.gif',
        autoGenerateForms=>1,
        tableName=>'StoryArchive',
        className=>'WebGUI::Asset::Wobject::StoryArchive',
        properties=>\%properties,
    });
    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 duplicate ( )

duplicates a New Wobject.  This method is unnecessary, but if you have 
auxiliary, ancillary, or "collateral" data or files related to your 
wobject instances, you will need to duplicate them here.

=cut

sub duplicate {
    my $self = shift;
    my $newAsset = $self->SUPER::duplicate(@_);
    return $newAsset;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    $template->prepare;
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self = shift;
    my $session = $self->session;    

    #This automatically creates template variables for all of your wobject's properties.
    my $var = $self->get;
    
    #This is an example of debugging code to help you diagnose problems.
    #WebGUI::ErrorHandler::warn($self->get("templateId")); 
    
    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page.  This method is entirely
optional.  Take it out unless you specifically want to set a submenu in your
adminConsole views.

=cut

#sub www_edit {
#   my $self = shift;
#   return $self->session->privilege->insufficient() unless $self->canEdit;
#   return $self->session->privilege->locked() unless $self->canEditIfLocked;
#   my $i18n = WebGUI::International->new($self->session, "Asset_NewWobject");
#   return $self->getAdminConsole->render($self->getEditForm->print, $i18n->get("edit title"));
#}


1;
#vim:ft=perl
