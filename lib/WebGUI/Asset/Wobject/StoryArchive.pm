package WebGUI::Asset::Wobject::StoryArchive;

our $VERSION = "1.0.0";

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
use WebGUI::Paginator;
use WebGUI::Keyword;
use WebGUI::Search;
use base 'WebGUI::Asset::Wobject';

use constant DATE_FORMAT => '%c_%D_%y';

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
            label        => $i18n->get('stories per page'),
            hoverHelp    => $i18n->get('stories per page help'),
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
            namespace    => 'StoryArchive',
            defaultValue => 'yxD5ka7XHebPLD-LXBwJqw',
        },
        storyTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('story template'),
            hoverHelp    => $i18n->get('story template help'),
            namespace    => 'Story',
            defaultValue => '3QpYtHrq_jmAk1FNutQM5A',
        },
        editStoryTemplateId => {
            tab          => 'display',
            fieldType    => 'template',
            label        => $i18n->get('edit story template'),
            hoverHelp    => $i18n->get('edit story template help'),
            namespace    => 'Story/Edit',
            defaultValue => 'E3tzZjzhmYoNlAyP2VW33Q',
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
    my $folderName = $session->datetime->epochToHuman($date, DATE_FORMAT);
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
    ##Restore the old one, if it exists
    $oldVersionTag->setWorking() if $oldVersionTag;

    ##Get a new version of the asset from the db with the correct state
    $folder = WebGUI::Asset->newByUrl($session, $folderUrl);
    return $folder;
}

#-------------------------------------------------------------------

=head2 folderDateFormat ( $epoch )

Returns the date in the format for folders.  Encapsulated in this method
so that it can be used everywhere in the sa

=head $epoch


=cut

sub prepareView {
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
    my $self    = shift;
    my $session = $self->session;    

    #This automatically creates template variables for all of your wobject's properties.
    my $mode = $session->form->hasParam('keyword') 
             ? 'keyword'
             : $session->form->hasParam('search')
             ? 'search'
             : 'view';

    my $var = $self->viewTemplateVariables($mode);

    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 viewTemplateVars ( $mode )

Make template variables for the view template.

=head3 $mode

Whether to get assets in view mode, by time, or search mode, by keywords.

=cut

sub viewTemplateVariables {
    my ($self, $mode)   = @_;
    my $session         = $self->session;    
    my $keywords        = $session->form->get('keyword');
    my $query           = $session->form->get('query'); 
    my $p;
    my $var = $self->get();
    if ($mode eq 'keyword') {
        $var->{mode} = 'keyword';
        my $wordList = WebGUI::Keyword::string2list($keywords);
        my $key      = WebGUI::Keyword->new($session);
        $p           = $key->getMatchingAssets({
            startAsset   => $self,
            keywords     => $wordList,
            isa          => 'WebGUI::Asset::Story',
            usePaginator => 1,
            rowsPerPage  => $self->get('storiesPerPage'),
        });
    }
    elsif ($mode eq 'search') {
        $var->{mode} = 'search';
        my $search   = WebGUI::Search->new($session);
        $search->search({
            keywords => $query,
            lineage  => [ $self->get('lineage'),    ],
            classes  => [ qw/WebGUI::Asset::Story/, ],
        });
        $p = $search->getPaginatorResultSet($self->getUrl, $self->get('storiesPerPage'));
    }
    else {
        $var->{mode} = 'view';
        ##Only return assetIds,  we'll build data for the things that are actually displayed.
        my $storySql = $self->getLineageSql(['descendants'],{
            excludeClasses => ['WebGUI::Asset::Wobject::Folder'],
            orderByClause  => 'creationDate desc, lineage',
        });
        $p = WebGUI::Paginator->new($session, $self->getUrl, $self->get('storiesPerPage'));
        $p->setDataByQuery($storySql);
    }
    my $storyIds = $p->getPageData();
    $p->appendTemplateVars($var);
    $var->{date_loop} = [];
    my $lastStoryDate = '';
    my $datePointer = undef;
    ##Only build objects for the assets that we need
    STORY: foreach my $storyId (@{ $storyIds }) {
        my $story = WebGUI::Asset->new($session, $storyId->{assetId}, $storyId->{className}, $storyId->{revisionDate});
        next STORY unless $story;
        my $creationDate = $story->get('creationDate');
        my ($creationDay,undef) = $session->datetime->dayStartEnd($creationDate);
        my $storyDate = $session->datetime->epochToHuman($creationDay, DATE_FORMAT);
        if ($storyDate ne $lastStoryDate) {
            push @{ $var->{date_loop} }, {};
            $datePointer = $var->{date_loop}->[-1];
            $datePointer->{epochDate} = $creationDay;
            $datePointer->{story_loop} = [];
            $lastStoryDate = $storyDate;
        }
        push @{$datePointer->{story_loop}}, {
            url           => $story->getUrl,
            title         => $story->getTitle,
            creationDate  => $creationDate,
        }
    }

    $var->{addStoryUrl}    = $self->getUrl('func=add;class=WebGUI::Asset::Story');
    $var->{canPostStories} = $self->canPostStories;
    $var->{keywordCloud}   = WebGUI::Keyword->new($session)->generateCloud({
        startAsset  => $self,
        displayFunc => 'view',
    });
    my $i18n = WebGUI::International->new($session, 'Asset');
    $var->{searchHeader} = WebGUI::Form::formHeader($session, { action => $self->getUrl })
                         . WebGUI::Form::hidden($session, { name   => 'func',   value => 'view' });
    $var->{searchFooter} = WebGUI::Form::formFooter($session);
    $var->{searchButton} = WebGUI::Form::submit($session, { name => 'search',   value => $i18n->get('search')});
    $var->{searchForm}   = WebGUI::Form::text($session,   { name => 'query',    value => $query});
    return $var;
}

#-------------------------------------------------------------------

=head2 www_add ( )

The only real children of StoryArchive are Folders, which then hold Stories.  So we intercept
www_add, find the right folder to use, then allow that folder to continue on.

=cut


sub www_add {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    if ($form->get('class') ne 'WebGUI::Asset::Story') {
        $session->log->warn('Refusing to add '. $form->get('class'). ' to StoryArchive');
        return undef;
    }
    my $todayFolder = $self->getFolder;
    if (!$todayFolder) {
        $session->log->warn('Unable to get folder for today.  Not adding Story');
        return undef;
    }
    $todayFolder->www_add;
}

1;
#vim:ft=perl
