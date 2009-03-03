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

=head2 addChild ( )

Story Archive really only has Folders for children.  When addChild is
called, check the date to see which folder to use.  If the correct folder
does not exist, then make it.

=cut

sub addChild {
    my $self = shift;
    my ($properties) = @_;
    ##Allow subclassing
    return undef unless $properties->{className} =~ /^WebGUI::Asset::Story/;
    my $todayFolder = $self->getFolder;
    return undef unless $todayFolder;
    my $story = $todayFolder->addChild(@_);
    return $story;
}

#-------------------------------------------------------------------

=head2 canPostStories ( )

Determines whether or not a user can post stories to this Archive.

=head3 userId

An explicit userId to check against.  If no userId is sent, then it
will use the current session user instead.

=cut

sub canPostStories {
	my ($self, $userId) = @_;
    $userId ||= $self->session->user->userId;
    my $user = WebGUI::User->new($self->session, $userId);
	return $user->isInGroup($self->get("groupToPost")) || $self->canEdit($userId);
}

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
        approvalWorkflowId =>{
            tab           => 'security',
            fieldType     => 'workflow',
            defaultValue  => 'pbworkflow000000000003',
            type          => 'WebGUI::VersionTag',
            label         => $i18n->get('approval workflow'),
            hoverHelp     => $i18n->get('approval workflow description'),
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

=head2 getFolder ( date )

Stories are stored in Folders under the Story Archive to prevent lineage issues.
Gets the correct folder for stories.   If the Folder does not exist, then it will
be created and autocommitted.  The autocommit is COMPLETELY automatic.  This is
because it's possible to gum up the Story submitting proces with a Folder under
a different version tag.

=head3 date

There is one folder for each day that Stories are submitted.  The requested date
should be an epoch.  If no date is passed, it will use the current time instead.

=cut

sub getFolder {
	my ($self, $date) = @_;
    my $session    = $self->session;
    my $folderName = $session->datetime->epochToHuman($date, '%c_%D_%y');
    my $folderUrl  = join '/', $self->getUrl, $folderName;
    my $folder     = WebGUI::Asset->newByUrl($session, $folderUrl);
    return $folder if $folder;
    ##The requested folder doesn't exist.  Make it and autocommit it.

    ##For a fully automatic commit, save the current tag, create a new one
    ##with the commit without approval workflow, commit it, then restore
    ##the original if it exists
    my $oldVersionTag = WebGUI::VersionTag->getWorking($session, 'noCreate');
    my $newVersionTag = WebGUI::VersionTag->create($session, { workflowId => 'pbworkflow00000000003', });
    $newVersionTag->setWorking;

    ##Call SUPER because my addChild calls getFolder
    $folder = $self->SUPER::addChild({
        className => 'WebGUI::Asset::Wobject::Folder',
        title     => $folderName,
        menuTitle => $folderName,
        url       => $folderUrl,
        isHidden  => 1,
    });
    $newVersionTag->commit();
    $oldVersionTag->setWorking();

    ##Get a new version of the asset from the db with the correct state
    $folder = WebGUI::Asset->newByUrl($session, $folderUrl);
    return $folder;
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

1;
#vim:ft=perl
