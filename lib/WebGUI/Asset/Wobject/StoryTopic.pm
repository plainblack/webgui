package WebGUI::Asset::Wobject::StoryTopic;

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
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_StoryTopic'];
define icon      => 'storytopic.gif';
define tableName => 'StoryTopic';
property storiesPer => (
            tab          => 'display',  
            fieldType    => 'integer',  
            label        => ['stories per topic', 'Asset_StoryTopic'],
            hoverHelp    => ['stories per topic help', 'Asset_StoryTopic'],
            default      => 15,
         );
property storiesShort => (
            tab          => 'display',  
            fieldType    => 'integer',  
            label        => ['stories short', 'Asset_StoryTopic'],
            hoverHelp    => ['stories short help', 'Asset_StoryTopic'],
            default      => 5,
         );
property templateId => (
            tab          => 'display',
            fieldType    => 'template',
            label        => ['template', 'Asset_StoryTopic'],
            hoverHelp    => ['template help', 'Asset_StoryTopic'],
            namespace    => 'StoryTopic',
            default      => 'A16v-YjWAShXWvSACsraeg',
         );
property storyTemplateId => (
            tab          => 'display',
            fieldType    => 'template',
            label        => ['story template', 'Asset_StoryTopic'],
            hoverHelp    => ['story template help', 'Asset_StoryTopic'],
            namespace    => 'Story',
            default      => 'TbDcVLbbznPi0I0rxQf2CQ',
         );
with 'WebGUI::Role::Asset::RssFeed';


use WebGUI::International;
use WebGUI::Asset::Story;

use constant DATE_FORMAT => '%c_%D_%y';

#-------------------------------------------------------------------

=head2 getRssFeedItems ( )

Returns an arrayref of hashrefs, containing information on stories
for generating an RSS and Atom feeds.

=cut

sub getRssFeedItems {
    my ($self)   = @_;
    my $session  = $self->session;    
    my $wordList = WebGUI::Keyword::string2list($self->keywords);
    my $key      = WebGUI::Keyword->new($session);
    my $storyIds = $key->getMatchingAssets({
        keywords     => $wordList,
        isa          => 'WebGUI::Asset::Story',
        rowsPerPage  => $self->storiesPer,
    });
    my $storyData = [];
    STORY: foreach my $storyId (@{ $storyIds }) {
        my $story = WebGUI::Asset->newById($session, $storyId);
        next STORY unless $story;
        push @{ $storyData }, $story->getRssData;
    }
    return $storyData;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 view ( )

Method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self = shift;
    my $session = $self->session;    

    #This automatically creates template variables for all of your wobject's properties.
    my $var = $self->viewTemplateVariables;

    return $self->processTemplate($var, undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 viewTemplateVariables ( )

Make template variables for the view template.

=cut

sub viewTemplateVariables {
    my ($self)          = @_;
    my $session         = $self->session;    
    my $exporting       = $session->scratch->get('isExporting');
    my $numberOfStories = $self->{_standAlone}
                        ? $self->storiesPer
                        : $self->storiesShort;
    my $var = $self->get();
    my $wordList = WebGUI::Keyword::string2list($self->keywords);
    my $key      = WebGUI::Keyword->new($session);
    my $p        = $key->getMatchingAssets({
        keywords     => $wordList,
        isa          => 'WebGUI::Asset::Story',
        usePaginator => 1,
        rowsPerPage  => $numberOfStories,
    });
    my $storyIds = $p->getPageData();
    $var->{story_loop} = [];

    my $icon          = $session->icon;
    my $userUiLevel   = $session->user->profileField("uiLevel");
    my $uiLevels      = $session->config->get('assetToolbarUiLevel');
    my $i18n          = WebGUI::International->new($session);

    ##Only build objects for the assets that we need
    STORY: foreach my $storyId (@{ $storyIds }) {
        my $story = WebGUI::Asset->newById($session, $storyId->{assetId}, $storyId->{revisionDate});
        next STORY unless $story;
        my $storyVars = {
            url           => ( $exporting
                               ? $story->getUrl
                               : $session->url->append($self->getUrl, 'func=viewStory;assetId='.$storyId->{assetId}) ),
            title         => $story->getTitle,
            creationDate  => $story->creationDate,
        };
        if ($story->canEdit && $userUiLevel >= $uiLevels->{delete} && !$exporting) {
            $storyVars->{deleteIcon} = $icon->delete('func=delete', $story->url, $i18n->get(43));
        }
        if ($story->canEdit && $userUiLevel >= $uiLevels->{edit}   && !$exporting) {
            $storyVars->{editIcon}   = $icon->edit('func=edit', $story->url);
        }
        push @{$var->{story_loop}}, $storyVars;
    }

    if ($self->{_standAlone}) {
        my $topStoryData = $storyIds->[0];
        shift @{ $var->{story_loop} };
        ##Note, this could have saved from the loop above, but this looks more clean and encapsulated to me.
        my $topStory   = WebGUI::Asset->newById($session, $topStoryData->{assetId}, $topStoryData->{revisionDate});
        $var->{topStoryTitle}          = $topStory->getTitle;
        $var->{topStorySubtitle}       = $topStory->subtitle;
        $var->{topStoryUrl}            = $session->url->append($self->getUrl, 'func=viewStory;assetId='.$topStoryData->{assetId}),
        $var->{topStoryCreationDate}   = $topStory->creationDate;
        ##TODO: Photo variables
        my $photoData = $topStory->getPhotoData;
        PHOTO: foreach my $photo (@{ $photoData }) {
            next PHOTO unless $photo->{storageId};
            my $storage  = WebGUI::Storage->get($session, $photo->{storageId});
            my $file     = $storage->getFiles->[0];
            next PHOTO unless $file;
            my $imageUrl = $storage->getUrl($file);
            $var->{topStoryImageUrl}     = $imageUrl;
            $var->{topStoryImageCaption} = $photo->{caption};
            $var->{topStoryImageByline}  = $photo->{byLine};
            $var->{topStoryImageAlt}     = $photo->{alt};
            $var->{topStoryImageTitle}   = $photo->{title};
            $var->{topStoryImageLink}    = $photo->{url};
            last PHOTO;
        }
    }
    $var->{standAlone} = $self->{_standAlone};
    $var->{rssUrl}     = $self->getRssFeedUrl;
    $var->{atomUrl}    = $self->getAtomFeedUrl;

    return $var;
}

#-------------------------------------------------------------------

=head2 www_view ( )

Overside the method inherited from Wobject to set the mode so template
variables are set correctly in viewTemplateVars.

=cut


override www_view => sub {
    my $self = shift;
    $self->{_standAlone} = 1;
    return super();
};

#-------------------------------------------------------------------

=head2 www_viewStory ( )

Display a story, set in the form variable assetId

=cut


sub www_viewStory {
    my $self    = shift;
    my $session = $self->session;
    my $storyId = $session->form->get('assetId');
    my $story;
    if ($storyId) {
        $story = WebGUI::Asset->newById($session, $storyId);
    }
    if (! $story) {
        my $notFound = WebGUI::Asset->getNotFound($session);
        $session->asset($notFound);
        return $notFound->www_view;
    }
    $story->topic($self);
    return $story->www_view;
}


1;
#vim:ft=perl
