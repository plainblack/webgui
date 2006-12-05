package WebGUI::Asset::WikiPage;

# -------------------------------------------------------------------
#  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Storage::Image;
use WebGUI::Utility;


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
        if ($self->get("storageId")) {
                my $newStorage = WebGUI::Storage->get($self->session,$self->get("storageId"))->copy;
                $newSelf->update({storageId=>$newStorage->getId});
        }
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
sub canDelete {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	return $self->getWiki->canAdminister($userId);
}

#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	return 0 if $self->isProtected and not $self->getWiki->canAdminister($userId);
	return $self->couldEdit($userId);
}

#-------------------------------------------------------------------
sub canProtect {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	return $self->getWiki->canAdminister($userId);
}

#-------------------------------------------------------------------
sub couldEdit {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	return 0 unless $self->getWiki->canEditPages($userId);
	return 1;
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
	     storageId => { fieldType => 'image',
			    defaultValue => undef },
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
			.WebGUI::Form::hidden($session, { name=>"proceed", value=>$form->process("proceed") }),
	 	formTitle => WebGUI::Form::text($session, { name => 'title', maxlength => 255, size => 40, value => $self->get('title') }),
		formContent => WebGUI::Form::HTMLArea($session, { name => 'content', richEditId => $wiki->get('richEditor'), value => $self->get('content') }),
		formSubmit => WebGUI::Form::submit($session, { value => 'Save' }),
		formProtect => WebGUI::Form::yesNo($session, { name => "isProtected", value=>$self->getValue("isProtected")}),
		formAttachment => '',
		allowsAttachments => $wiki->get("maxAttachments"),
		formFooter => WebGUI::Form::formFooter($session),
		isNew => ($self->getId eq "new"),
		canAdminister => $wiki->canAdminister,
		deleteLabel => $i18n->get("deleteLabel"),
		deleteUrl => $self->getUrl("func=delete"),
		titleLabel => $i18n->get("titleLabel"),
		contentLabel => $i18n->get("contentLabel"),
		attachmentLabel => $i18n->get("attachmentLabel"),
		protectQuestionLabel => $i18n->get("protectQuestionLabel"),
		isProtected => $self->isProtected
		};
	if ($self->getId eq "new") {
		$var->{formHeader} .= WebGUI::Form::hidden($session, { name=>"assetId", value=>"new" }) 
			.WebGUI::Form::hidden($session, { name=>"class", value=>$form->process("class","className") });
	}
	return $self->processTemplate($var, $wiki->getValue('pageEditTemplateId'));
}

#-------------------------------------------------------------------
sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->get("storageId") eq "") {
			$self->{_storageLocation} = WebGUI::Storage::Image->create($self->session);
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage::Image->get($self->session,$self->get("storageId"));
		}
	}
	return $self->{_storageLocation};
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
			 isHidden => 1,
			actionTakenBy => $self->session->user->userId,
			actionTaken => $actionTaken});
	if ($self->canAdminister) {
		$self->update({isProtected => $self->session->form("isProtected")});
	}
	delete $self->{_storageLocation};
	my $size = 0;
        my $storage = $self->getStorageLocation;
        foreach my $file (@{$storage->getFiles}) {
                if ($storage->isImage($file)) {
                        ##Use generateThumbnail to shrink size to site's max image size
                        ##We should look into using the new resize method instead.
                        $storage->generateThumbnail($file, $self->getWiki->get("maxImageSize") || $self->session->setting->get("maxImageSize"));
                        $storage->deleteFile($file);
                        $storage->renameFile('thumb-'.$file,$file);
                        $storage->generateThumbnail($file, $self->getWiki->get("thumbnailSize"));
                }
                $size += $storage->getFileSize($file);
        }
        $self->setSize($size);
	# allows us to let the cs post use it's own workflow approval process
        my $currentTag = WebGUI::VersionTag->getWorking($self->session);
        if ($currentTag->getAssetCount < 2) {
                $currentTag->set({workflowId=>$self->getWiki->get("approvalWorkflow")});
                $currentTag->requestCommit;
        } else {
                my $newTag = WebGUI::VersionTag->create($self->session, {
                        name=>$self->getTitle." / ".$self->session->user->username,
                        workflowId=>$self->getWiki->get("approvalWorkflow")
                        });
                $self->session->db->write("update assetData set tagId=? where assetId=? and tagId=?",[$newTag->getId, $self->getId, $currentTag->getId]);
                $self->purgeCache;
                $newTag->requestCommit;
        }
}	

#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->session->db->write("DELETE FROM WikiMaster_titleIndex WHERE assetId = ?", [$self->getId]);
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiPage");
	my $var = {
		viewLabel => $i18n->get("viewLabel"),
		editLabel => $i18n->get("editLabel"),
		historyLabel => $i18n->get("historyLabel"),
		wikiHomeLabel=>$i18n->get("wikiHomeLabel", "Asset_WikiMaster"),
		searchLabel=>$i18n->get("searchLabel", "Asset_WikiMaster"),	
		searchUrl=>$self->getParent->getUrl("func=search"),
		recentChangesUrl=>$self->getParent->getUrl("func=recentChanges"),
		recentChangesLabel=>$i18n->get("recentChangesLabel", "Asset_WikiMaster"),
		mostPopularUrl=>$self->getParent->getUrl("func=mostPopular"),
		mostPopularLabel=>$i18n->get("mostPopularLabel", "Asset_WikiMaster"),
		wikiHomeUrl=>$self->getParent->getUrl,
		historyUrl=>$self->getUrl("func=getHistory"),
		editUrl=>$self->getUrl("func=edit;ajax=1"),
		content => $self->getWiki->autolinkHtml($self->get('content')),	
		};
	return $self->processTemplate($var, $self->getWiki->get("pageTemplateId"));
}

#-------------------------------------------------------------------
sub www_delete {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canDelete;
	$self->trash;
	$self->session->asset($self->getParent);
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------
# here to keep backward compatibility with traditional editing
sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canEdit;
	if ($self->session->form->param("ajax")) {	
		$self->session->style->sent(1);
		return $self->getEditForm;
	}
	return $self->getWiki->processStyle($self->getEditForm);
}

#-------------------------------------------------------------------
sub www_getHistory {
	my $self = shift;
	my $var = {};
	my ($icon, $date) = $self->session->quick(qw(icon datetime));
	foreach my $revision (@{$self->getRevisions}) {
		my $user = WebGUI::User->new($self->session, $self->get("actionTakenBy"));
		push(@{$var->{pageHistoryEntries}}, {
			toolbar => $icon->delete("func=purgeRevision;revisionDate=".$self->get("revisionDate"), $self->get("url"), "Delete this revision?")
                        	.$icon->edit('func=edit;revision='.$self->get("revisionDate"), $self->get("url"))
                        	.$icon->view('func=view;revision='.$self->get("revisionDate"), $self->get("url")),
			date => $date->epochToHuman($self->get("revisionDate")),
			username => $user->username,
			actionTaken => $self->get("actionTaken"),
			interval => join(" ", $date->secondsToInterval(time() - $self->get("revisionDate")))
			});		
	}
	return $self->processTemplate($var, $self->getWiki->get('pageHistoryTemplateId'));
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
