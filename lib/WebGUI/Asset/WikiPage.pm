package WebGUI::Asset::WikiPage;

# -------------------------------------------------------------------
#  WebGUI is Copyright 2001-2007 Plain Black Corporation.
# -------------------------------------------------------------------
#  Please read the legal notices (docs/legal.txt) and the license
#  (docs/license.txt) that came with this distribution before using
#  this software.
# -------------------------------------------------------------------
#  http://www.plainblack.com                     info@plainblack.com
# -------------------------------------------------------------------

use base 'WebGUI::Asset';
use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use WebGUI::VersionTag;


#-------------------------------------------------------------------

=head2 addChild ( )

You can't add children to a wiki page.

=cut

sub addChild {
	return undef;
}

#-------------------------------------------------------------------

=head2 addRevision ( )

Override the default method in order to deal with attachments.

=cut

sub addRevision {
        my $self = shift;
        my $newSelf = $self->SUPER::addRevision(@_);
	my $now = time();
	$newSelf->update({
		isHidden => 1,
		dateUpdated=>$now,
		});
        return $newSelf;
}

#-------------------------------------------------------------------
sub canAdd {
	my $class = shift;
	my $session = shift;
	$class->SUPER::canAdd($session, undef, '7');
}

#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;
	my $form = $self->session->form;
	return (($form->process("func") eq "add" || ($form->process("assetId") eq "new" && $form->process("func") eq "editSave" && $form->process("class","className") eq "WebGUI::Asset::WikiPage")) && $self->getWiki->canEditPages) # account for new pages
		|| (!$self->isProtected && $self->getWiki->canEditPages)  # account for normal editing
		|| $self->getWiki->canAdminister; # account for admins
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Asset_WikiPage");

	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties =
	    (
	     content => { fieldType => "HTMLArea",
			  defaultValue => undef },
		views => {
			fieldType => "integer",
			defaultValue => 0,
			noFormPost => 1
			},
		isProtected => {
			fieldType => "yesNo",
			defaultValue => 0,
			noFormPost => 1
			},
		actionTaken => {
			fieldType => "text",
			defaultValue => undef,
			noFormPost => 1
			},
		actionTakenBy => {
			fieldType => "user",
			defaultValue => undef,
			noFormPost => 1
			},
	    );

	push @$definition,
	     {
	      assetName => $i18n->get('assetName'),
	      icon => 'wikiPage.gif',
	      autoGenerateForms => 1,
	      tableName => 'WikiPage',
	      className => 'WebGUI::Asset::WikiPage',
	      properties => \%properties,
	     };

	return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------
# BUGGO: how to handle this?
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(@_);
	return $newAsset;
}


#-------------------------------------------------------------------
sub getAutoCommitWorkflowId {
	my $self = shift;
	return $self->getWiki->get("approvalWorkflow");
}


#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $session = $self->session;
	my $form = $session->form;
	my $i18n = WebGUI::International->new($session, "Asset_WikiPage");
	my $newPage = 0;
	my $wiki = $self->getWiki;
	my $url = ($self->getId eq "new") ? $wiki->getUrl : $self->getUrl;
	my $var = {
		title=> $i18n->get("editing")." ".(defined($self->get('title'))? $self->get('title') : $i18n->get("assetName")),
		formHeader => WebGUI::Form::formHeader($session, { action => $url}) 
			.WebGUI::Form::hidden($session, { name => 'func', value => 'editSave' }) 
			.WebGUI::Form::hidden($session, { name=>"proceed", value=>"showConfirmation" }),
	 	formTitle => WebGUI::Form::text($session, { name => 'title', maxlength => 255, size => 40, 
                value => $self->get('title'), defaultValue=>$form->get("title","text") }),
		formContent => WebGUI::Form::HTMLArea($session, { name => 'content', richEditId => $wiki->get('richEditor'), value => $self->get('content') }) ,
		formSubmit => WebGUI::Form::submit($session, { value => 'Save' }),
		formProtect => WebGUI::Form::yesNo($session, { name => "isProtected", value=>$self->getValue("isProtected")}),
        formKeywords => WebGUI::Form::text($session, {
            name    => "keywords",
            value   => WebGUI::Keyword->new($session)->getKeywordsForAsset({asset=>$self}),
            }),
		allowsAttachments => $wiki->get("allowAttachments"),
		formFooter => WebGUI::Form::formFooter($session),
		isNew => ($self->getId eq "new"),
		canAdminister => $wiki->canAdminister,
		deleteConfirm => $i18n->get("delete page confirmation"),
		deleteLabel => $i18n->get("deleteLabel"),
		deleteUrl => $self->getUrl("func=delete"),
		titleLabel => $i18n->get("titleLabel"),
		contentLabel => $i18n->get("contentLabel"),
		attachmentLabel => $i18n->get("attachmentLabel"),
		protectQuestionLabel => $i18n->get("protectQuestionLabel"),
		isProtected => $self->isProtected
		};
    my $children = [];
	if ($self->getId eq "new") {
		$var->{formHeader} .= WebGUI::Form::hidden($session, { name=>"assetId", value=>"new" }) 
			.WebGUI::Form::hidden($session, { name=>"class", value=>$form->process("class","className") });
	} else {
        $children = $self->getLineage(["children"]);
    }
    $var->{formAttachment} = WebGUI::Form::Attachments($session, { 
        value           => $children,
        maxAttachments  => $wiki->get("allowAttachments"),
        maxImageSize    => $wiki->get("maxImageSize"),
        thumbnailSize   => $wiki->get("thumbnailSize"),
        });
	return $self->processTemplate($var, $wiki->getValue('pageEditTemplateId'));
}

#-------------------------------------------------------------------
sub getWiki {
	my $self = shift;
	my $parent = $self->getParent;
	return undef unless defined $parent and $parent->isa('WebGUI::Asset::Wobject::WikiMaster');
	return $parent;
}

#-------------------------------------------------------------------
sub indexContent {
	my $self = shift;
	my $indexer = $self->SUPER::indexContent;
	$indexer->addKeywords($self->get('content'));
	return $indexer;
}

#-------------------------------------------------------------------
sub isProtected {
	my $self = shift;
	return $self->get("isProtected");
}

#-------------------------------------------------------------------
sub preparePageTemplate {
	my $self = shift;
	return $self->{_pageTemplate} if $self->{_pageTemplate};
	$self->{_pageTemplate} =
	    WebGUI::Asset::Template->new($self->session, $self->getWiki->get('pageTemplateId'));
	$self->{_pageTemplate}->prepare;
	return $self->{_pageTemplate};
}

#-------------------------------------------------------------------
sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView;
	$self->preparePageTemplate;
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost(@_);
	my $actionTaken = ($self->session->form->process("assetId") eq "new") ? "Created" : "Edited";

	$self->update({ groupIdView => $self->getWiki->get('groupIdView'),
			groupIdEdit => $self->getWiki->get('groupToAdminister'),
			actionTakenBy => $self->session->user->userId,
			actionTaken => $actionTaken,
	});

	if ($self->getWiki->canAdminister) {
		$self->update({isProtected => $self->session->form("isProtected")});
	}

    # deal with attachments from the attachments form control
    my @attachments = $self->session->form->param("attachments");
    my @tags = ();
    foreach my $assetId (@attachments) {
        my $asset = WebGUI::Asset->newByDynamicClass($self->session, $assetId);
        if (defined $asset) {
            unless ($asset->get("parentId") eq $self->getId) {
                $asset->setParent($self);
                $asset->update({
                    ownerUserId => $self->get("ownerUserId"),
                    groupIdEdit => $self->get("groupIdEdit"),
                    groupIdView => $self->get("groupIdView"),
                    });
            }
            push(@tags, $asset->get("tagId"));
            $asset->setVersionTag($self->get("tagId"));
        }
    }

    # clean up empty tags
    foreach my $tag (@tags) {
        my $version = WebGUI::VersionTag->new($self->session, $tag);
        if (defined $version) {
            if ($version->getAssetCount == 0) {
                $version->rollback;
            }
        }
    }

    # wiki pages are auto committed
	$self->requestAutoCommit;
}	

#-------------------------------------------------------------------

=head2 scrubContent ( [ content ] )

Uses WikiMaster settings to remove unwanted markup and apply site wide replacements.

=head3 content

Optionally pass the ontent that we want to run the filters on.  Otherwise we get it from self.

=cut

sub scrubContent {
        my $self = shift;
        my $content = shift || $self->get("content");

        my $scrubbedContent = WebGUI::HTML::filter($content, $self->getWiki->get("filterCode"));

        if ($self->getWiki->get("useContentFilter")) {
                $scrubbedContent = WebGUI::HTML::processReplacements($self->session, $scrubbedContent);
        }

        return $scrubbedContent;
}

#-------------------------------------------------------------------

=head2 update

Wrap update to force isHidden to be on, all the time.

=cut

sub update {
    my $self = shift;
    my $properties = shift;
    $properties->{isHidden} = 1;
    $self->SUPER::update($properties, @_);
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiPage");
    my $keywords = WebGUI::Keyword->new($self->session)->getKeywordsForAsset({
        asset=>$self,
        asArrayRef=>1,
        });
    my $wiki = $self->getWiki;
    my @keywordsLoop = ();
    foreach my $word (@{$keywords}) {
        push(@keywordsLoop, {
            keyword=>$word,
            url=>$wiki->getUrl("func=byKeyword;keyword=".$word),
            });
    }
	my $var = {
        keywordsLoop        => \@keywordsLoop,
		viewLabel           => $i18n->get("viewLabel"),
		editLabel           => $i18n->get("editLabel"),
		historyLabel        => $i18n->get("historyLabel"),
		wikiHomeLabel       => $i18n->get("wikiHomeLabel", "Asset_WikiMaster"),
		searchLabel         => $i18n->get("searchLabel", "Asset_WikiMaster"),	
		searchUrl           => $self->getParent->getUrl("func=search"),
		recentChangesUrl    => $self->getParent->getUrl("func=recentChanges"),
		recentChangesLabel  => $i18n->get("recentChangesLabel", "Asset_WikiMaster"),
		mostPopularUrl      => $self->getParent->getUrl("func=mostPopular"),
		mostPopularLabel    => $i18n->get("mostPopularLabel", "Asset_WikiMaster"),
		wikiHomeUrl         => $self->getParent->getUrl,
		historyUrl          => $self->getUrl("func=getHistory"),
		editContent         => $self->getEditForm,
        allowsAttachments   => $self->getWiki->get("allowAttachments"),
		content             => $self->getWiki->autolinkHtml(
            $self->scrubContent,
            {skipTitles => [$self->get('title')]},
        ),	
		};
	return $self->processTemplate($var, $self->getWiki->get("pageTemplateId"));
}

#-------------------------------------------------------------------
sub www_delete {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->getWiki->canAdminister;
	$self->trash;
	$self->session->asset($self->getParent);
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canEdit;
	return $self->session->privilege->locked unless $self->canEditIfLocked;
	return $self->getWiki->processStyle($self->getEditForm);
}

#-------------------------------------------------------------------
sub www_getHistory {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canEdit;
	my $var = {};
	my ($icon, $date) = $self->session->quick(qw(icon datetime));
	my $i18n = WebGUI::International->new($self->session, 'Asset_WikiPage');
	foreach my $revision (@{$self->getRevisions}) {
		my $user = WebGUI::User->new($self->session, $revision->get("actionTakenBy"));
		push(@{$var->{pageHistoryEntries}}, {
			toolbar => $icon->delete("func=purgeRevision;revisionDate=".$revision->get("revisionDate"), $revision->get("url"), $i18n->get("delete confirmation"))
                        	.$icon->edit('func=edit;revision='.$revision->get("revisionDate"), $revision->get("url"))
                        	.$icon->view('func=view;revision='.$revision->get("revisionDate"), $revision->get("url")),
			date => $date->epochToHuman($revision->get("revisionDate")),
			username => $user->username,
			actionTaken => $revision->get("actionTaken"),
			interval => join(" ", $date->secondsToInterval(time() - $revision->get("revisionDate")))
			});		
	}
	return $self->processTemplate($var, $self->getWiki->get('pageHistoryTemplateId'));
}

#-------------------------------------------------------------------

sub www_restoreWikiPage {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->getWiki->canAdminister;
	$self->publish;	
	return $self->www_view;
}


#-------------------------------------------------------------------

=head2 www_showConfirmation ( )

Shows a confirmation message letting the user know their page has been submitted.

=cut

sub www_showConfirmation {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiPage");
	return $self->getWiki->processStyle('<p>'.$i18n->get("page received").'</p><p><a href="'.$self->getWiki->getUrl.'">'.$i18n->get("493","WebGUI").'</a></p>');
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess unless $self->canView;
	$self->update({ views => $self->get('views')+1 });
	# TODO: This should probably exist, as the CS has one.
#	$self->session->http->setCacheControl($self->getWiki->get('visitorCacheTimeout'))
#	    if ($self->session->user->userId eq '1');
	$self->session->http->sendHeader;
	$self->prepareView;
	return $self->getWiki->processStyle($self->view);
}



1;
