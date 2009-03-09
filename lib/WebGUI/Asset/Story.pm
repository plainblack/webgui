package WebGUI::Asset::Story;

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
use Class::C3;
use base 'WebGUI::Asset';
use Tie::IxHash;
use WebGUI::Utility;
use WebGUI::International;
use JSON qw/from_json to_json/;
use Storable qw/dclone/;

=head1 NAME

Package WebGUI::Asset::Story

=head1 DESCRIPTION

The Story Asset is like a Thread for the Collaboration.

=head1 SYNOPSIS

use WebGUI::Asset::Story;


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addChild ( )

You can't add children to a Story.

=cut

sub addChild {
    return undef;
}

#-------------------------------------------------------------------

=head2 addRevision

Copy storage locations so that purging individual revisions works correctly.

Request autocommit.

=cut

sub addRevision {
    my $self = shift;
    my $newSelf = $self->next::method(@_);

    my $newProperties = {
        isHidden => 1,
    };

    if ($newSelf->get("storageId") && $newSelf->get("storageId") eq $self->get('storageId')) {
        my $newStorage = $self->getStorageClass->get($self->session,$self->get("storageId"))->copy;
        $newProperties->{storageId} = $newStorage->getId;
    }

    $newSelf->update($newProperties);
    $newSelf->requestAutoCommit;

    return $newSelf;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for New Asset instances.  You absolutely need 
this method in your new Assets. 

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my %properties;
    tie %properties, 'Tie::IxHash';
    my $i18n = WebGUI::International->new($session, 'Asset_Story');
    %properties = (
        headline => {
            fieldType    => 'text',  
            #label        => $i18n->get('headline'),
            #hoverHelp    => $i18n->get('headline help'),
            defaultValue => '',
        },
        subtitle => {
            fieldType    => 'textarea',  
            #label        => $i18n->get('subtitle'),
            #hoverHelp    => $i18n->get('subtitle help'),
            defaultValue => '',
        },
        byline => {
            fieldType    => 'text',  
            #label        => $i18n->get('byline'),
            #hoverHelp    => $i18n->get('byline help'),
            defaultValue => '',
        },
        location => {
            fieldType    => 'text',  
            #label        => $i18n->get('location'),
            #hoverHelp    => $i18n->get('location help'),
            defaultValue => '',
        },
        highlights => {
            fieldType    => 'textarea',  
            #label        => $i18n->get('highlights'),
            #hoverHelp    => $i18n->get('highlights help'),
            defaultValue => '',
        },
        story => {
            fieldType    => 'HTMLArea',  
            #label        => $i18n->get('highlights'),
            #hoverHelp    => $i18n->get('highlights help'),
            #richEditId  => $self->parent->getStoryRichEdit,
            defaultValue => '',
        },
        photo => {
            fieldType    => 'text',
            defaultValue => '{}',
        },
        storageId => {
            fieldType    => 'hidden',
            defaultValue => '',
            noFormPost   => 1,
        },
    );
    push(@{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'assets.gif',
        tableName         => 'Story',
        className         => 'WebGUI::Asset::Story',
        properties        => \%properties,
        autoGenerateForms => 0,
    });
    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 exportAssetData ( )

See WebGUI::AssetPackage::exportAssetData() for details.
Add the storage location to the export data.

=cut

sub exportAssetData {
	my $self = shift;
	my $data = $self->SUPER::exportAssetData;
	push(@{$data->{storage}}, $self->get("storageId")) if ($self->get("storageId") ne "");
	return $data;
}

#-------------------------------------------------------------------

=head2 formatDuration ( $lastUpdated )

Format the time since this story was last updated.  If it is longer than 1 week, then
return the date.

=head3 $lastUpdated

The date this was last updated.  If left blank, it uses the revisionDate.

=cut

sub formatDuration {
    my ($self, $lastUpdated) = @_;
    $lastUpdated = defined $lastUpdated ? $lastUpdated : $self->get('revisionDate');
    my $session = $self->session;
    my $datetime = $session->datetime;
    my $duration = time() - $lastUpdated;
    if ($duration > 86400) { ##1 day
        return join ' ', $datetime->secondsToInterval($duration);
    }
    else {
        my $formattedDuration = '';
        my $hours = int($duration/3600) * 3600;
        my @hours = $datetime->secondsToInterval($hours);
        if ($hours[0]) {
            $formattedDuration = join ' ', @hours;
        }
        my $minutes = round(($duration - $hours)/60)*60;
        my @minutes = $datetime->secondsToInterval($minutes);
        if ($minutes[0]) {
            $formattedDuration .= ', ', if $formattedDuration;
            $formattedDuration .= join ' ', @minutes;
        }
        return $formattedDuration;
    }
}

#-------------------------------------------------------------------

=head2 getArchive (  )

Returns the parent archive for this Story.  Cache the entry for speed.

=cut

sub getArchive {
    my $self = shift;
    if (!$self->{_archive}) {
        $self->{_archive} = $self->getParent->getParent;
    }
    return $self->{_archive};
}

#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId (  )

Get the autocommit workflow from the archive containing this Story and
use it.

=cut

sub getAutoCommitWorkflowId {
	my $self    = shift;
    my $archive = $self->getArchive;
    if ($archive->hasBeenCommitted) {
        $self->session->log->warn($archive->get('approvalWorkflowId'));
        return $archive->get('approvalWorkflowId')
            || $self->session->setting->get('defaultVersionTagWorkflow');
    }
    return undef;
}


#-------------------------------------------------------------------

=head2 getEditForm (  )

Returns a templated form for adding or editing Stories.

=cut

sub getEditForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_Story');
    my $form    = $session->form;
    my $archive = $self->getArchive;
    my $isNew   = $self->getId eq 'new';
    my $url     = $isNew ? $archive->getUrl : $self->getUrl;
    my $title   = $self->getTitle;
    my $var     = {
        formHeader     => WebGUI::Form::formHeader($session, {action => $url})
                        . WebGUI::Form::hidden($session, { name => 'func',    value => 'editSave' })
                        . WebGUI::Form::hidden($session, { name => 'proceed', value => 'showConfirmation' }),
        formFooter     => WebGUI::Form::formFooter($session),
        formTitle      => $isNew
                        ? $i18n->get('add a story','Asset_StoryArchive')
                        : $i18n->get('editing','Asset_WikiPage').' '.$title,
        titleForm      => WebGUI::Form::text($session, {
                             name  => 'title',
                             value => $form->get('title')    || $self->get('title'),
                          } ),
        subTitleForm   => WebGUI::Form::textarea($session, {
                             name  => 'subtitle',
                             value => $form->get('subtitle') || $self->get('subtitle')
                          } ),
        bylineForm     => WebGUI::Form::text($session, {
                             name  => 'byline',
                             value => $form->get('byline')   || $self->get('byline')
                          } ),
        locationForm   => WebGUI::Form::text($session, {
                             name  => 'location',
                             value => $form->get('location') || $self->get('location')
                          } ),
        keywordsForm   => WebGUI::Form::text($session, {
                            name  => 'keywords',
                            value => $form->get('keywords') || WebGUI::Keyword->new($session)->getKeywordsForAsset({ asset => $self })
                         } ),
        highlightsForm => WebGUI::Form::textarea($session, {
                            name  => 'highlights',
                            value => $form->get('highlights')  || $self->get('highlights')
                          } ),
        storyForm      => WebGUI::Form::HTMLArea($session, {
                            name  => 'story',
                            value => $form->get('story')       || $self->get('story'),
                            richEditId => $archive->get('richEditorId')
                          }),
        saveButton     => WebGUI::Form::submit($session, {
                            name  => 'saveStory',
                            value => $i18n->get('save story'),
                          }),
        previewButton  => WebGUI::Form::submit($session, {
                            name  => 'saveAndPreview',
                            value => $i18n->get('save and preview'),
                          }),
        cancelButton   => WebGUI::Form::button($session, {
                            name   => 'cancel',
                            value  => $i18n->get('cancel','WebGUI'),
                            extras => q|onclick="history.go(-1);" class="backwardButton"|,
                          }),
        saveAndAddButton  => WebGUI::Form::submit($session, {
                            name  => 'saveAndAddPhoto',
                            value => $i18n->get('save and add another photo'),
                          }),
    };
    if ($isNew) {
        $var->{formHeader} .= WebGUI::Form::hidden($session, { name => 'assetId', value => 'new' })
                           .  WebGUI::Form::hidden($session, { name => 'class',   value => $form->process('class', 'className') });
    }
    return $self->processTemplate($var, $archive->get('editStoryTemplateId'));

}

#-------------------------------------------------------------------

=head2 getPhotoData (  )

Returns the photo hash formatted as perl data.  See also L<setPhotoData>.

=cut

sub getPhotoData {
	my $self     = shift;
	if (!exists $self->{_photoData}) {
        $self->{_photoData} = from_json($self->get('photo'));
	}
	return dclone($self->{_photoData});
}

#-------------------------------------------------------------------

=head2 getStorageLocation ( [$noCreate] )

Returns the storage location for this Story.  If it does not exist,
then it creates it via setStorageLocation.  Subsequent lookups return
an internally cached Storage object to save time.

=head3 $noCreate

If $noCreate is true, then no storage location will be created, even
if it does not exist.

=cut

sub getStorageLocation {
	my $self     = shift;
    my $noCreate = shift;
	if (!exists $self->{_storageLocation} && !$noCreate) {
		$self->setStorageLocation;
	}
	return $self->{_storageLocation};
}

#-------------------------------------------------------------------

=head2 prepareView ( $templateId )

See WebGUI::Asset::prepareView() for details.

=head3 $templateId

By default, the Story looks in its parent Story Archive to get a template.  If $templateId
is passed, it will use that template instead.

=cut

sub prepareView {
    my $self       = shift;
    my $templateId = shift || $self->getArchive->get('storyTemplateId');
    $self->SUPER::prepareView();
    $self->session->log->warn("storyTemplateId: $templateId");
    my $template = WebGUI::Asset::Template->new($self->session, $templateId);
    $template->prepare;
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  Do custom things with
noFormPost fields here, or do whatever you want.  This method is called
when /yourAssetUrl?func=editSave is requested/posted.

=cut

sub processPropertiesFromFormPost {
    my $self = shift;
    $self->SUPER::processPropertiesFromFormPost;
}


#-------------------------------------------------------------------

=head2 purge ( )

Cleaning up storage objects in all revisions.

=cut

sub purge {
    my $self = shift;
    my $sth = $self->session->db->read("select storageId from Story where assetId=".$self->session->db->quote($self->getId));
    STORAGE: while (my ($storageId) = $sth->array) {
        next STORAGE unless $storageId;
        WebGUI::Storage->get($self->session,$storageId)->delete;
	}
    $sth->finish;
    return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeRevision

Remove the storage location for this revision of the Asset.

=cut

sub purgeRevision {
	my $self = shift;
	$self->getStorageLocation->delete;
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------

=head2 setPhotoData ( $perlStructure )

Returns the storage location for this Story.  If it does not exist,
then it creates it via setStorageLocation.  Subsequent lookups return
an internally cached Storage object to save time.

=head3 $perlStructure

This should be a hash of hashes.  The keys will be names of photos in the
storage location for this Story.  The values in the subhash will be
metadata about the Photo.

=item *

caption

=item *

byLine

=item *

alt

=item *

title

=item *

url

=back

subhash keys can be empty, or missing altogether.  Shoot, you can really put anything you
want in there so there's no valid content checking.

=cut

sub setPhotoData {
	my $self      = shift;
    my $photoData = shift || {};
    my $photo     = to_json($photoData);
    $self->update({photo => $photo});
    delete $self->{_photoData};
    return;
}

#-------------------------------------------------------------------

=head2 setSize ( fileSize )

Set the size of this asset by including all the files in its storage
location. C<fileSize> is an integer of additional bytes to include in
the asset size.

=cut

sub setSize {
    my $self        = shift;
    my $fileSize    = shift || 0;
    my $storage     = $self->getStorageLocation('noCreate');
    if (defined $storage) {	
        foreach my $file (@{$storage->getFiles}) {
            $fileSize += $storage->getFileSize($file);
        }
    }
    return $self->SUPER::setSize($fileSize);
}

#-------------------------------------------------------------------

=head2 setStorageLocation ( [ $storage] )

=head3 $storage

A storage location to use for this Story.

=cut

sub setStorageLocation {
    my $self    = shift;
    my $storage = shift;
    if (defined $storage) {
        $self->{_storageLocation} = $storage;
    }
    elsif ($self->get("storageId") eq "") {
        $self->{_storageLocation} = WebGUI::Storage->create($self->session);
        $self->update({storageId=>$self->{_storageLocation}->getId});
    }
    else {
        $self->{_storageLocation} = WebGUI::Storage->get($self->session,$self->get("storageId"));
    }
}

#-------------------------------------------------------------------

=head2 update

Extend the superclass to make sure that the asset always stays hidden from navigation.

=cut

sub update {
    my $self   = shift;
    my $properties = shift;
    return $self->SUPER::update({%$properties, isHidden => 1});
}

#-------------------------------------------------------------------

=head2 validParent

Make sure that the current session asset is a StoryArchive for pasting and adding checks.

This is a class method.

=cut

sub validParent {
    my $class   = shift;
    my $session = shift;
    return $session->asset && $session->asset->isa('WebGUI::Asset::Wobject::StoryArchive');
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

=cut

##Keyword cloud generated by WebGUI::Keyword

sub view {
    my $self    = shift;
    my $session = $self->session;    
    my $var = $self->viewTemplateVariables();
    return $self->processTemplate($var,undef, $self->{_viewTemplate});
}

#-------------------------------------------------------------------

=head2 viewTemplateVars ( $var )

Add template variables to the existing template variables.  This includes asset level variables.

=head3 $var

Template variables will be added onto this hash ref.

=cut

sub viewTemplateVariables {
    my ($self)  = @_;
    my $session = $self->session;    
    my $archive = $self->getArchive;
    my $var     = $self->get;

    if ($var->{highlights}) {
        my @highlights = split "\n+", $var->{highlights};
        foreach my $highlight (@highlights) {
            push @{ $var->{highlights_loop} }, { highlight => $highlight };
        }
    }

    my $key = WebGUI::Keyword->new($session);
    my $keywords = $key->getKeywordsForAsset( { asArrayRef => 1, asset => $self  });
    $var->{keyword_loop} = [];
    foreach my $keyword (@{ $keywords }) {
        push @{ $var->{keyword_loop} }, {
            keyword => $keyword,
            url     => $archive->getUrl("func=search;submit=1;keywords=".$session->url->escape($keyword)),
        };
    }
    ##TODO: publish time, calculated from revisionDate
    $var->{updatedTime}      = $self->formatDuration();
    $var->{updatedTimeEpoch} = $self->get('revisionDate');
    return $var;
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page.  Unless the method needs
special handling or formatting, it does not need to be included in
the module.

=cut

sub www_edit {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;
    return $session->privilege->locked() unless $self->canEditIfLocked;
    return $self->getArchive->processStyle($self->getEditForm);
}

#-------------------------------------------------------------------

=head2 www_showConfirmation ( )

Shows a confirmation message letting the user know their page has been submitted.

=cut

sub www_showConfirmation {
    my $self = shift;
    my $i18n = WebGUI::International->new($self->session, 'Asset_Story');
    return $self->getArchive->processStyle('<p>'.$i18n->get('story received').'</p><p><a href="'.$self->getArchive->getUrl.'">'.$i18n->get('493','WebGUI').'</a></p>');
}

#-------------------------------------------------------------------

=head2 www_view

Override www_view from asset because assets (vs wobjects) do not have style templates.

=cut

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess unless $self->canView;
	$self->session->http->sendHeader;
	$self->prepareView;
	return $self->getArchive->processStyle($self->view);
}


1;

#vim:ft=perl
