package WebGUI::Asset::WikiPage;

# -------------------------------------------------------------------
#  WebGUI is Copyright 2001-2009 Plain Black Corporation.
# -------------------------------------------------------------------
#  Please read the legal notices (docs/legal.txt) and the license
#  (docs/license.txt) that came with this distribution before using
#  this software.
# -------------------------------------------------------------------
#  http://www.plainblack.com                     info@plainblack.com
# -------------------------------------------------------------------

use strict;
use Class::C3;
use base qw(
    WebGUI::AssetAspect::Subscribable
    WebGUI::AssetAspect::Comments 
    WebGUI::Asset
);
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
        my $newSelf = $self->next::method(@_);
	my $now = time();
	$newSelf->update({
		isHidden => 1,
		});
        return $newSelf;
}

#-------------------------------------------------------------------

=head2 canAdd ($session)

This functions as a class or an object method.  It sets the subclassGroupId to 7
instead of the default of 12.

=cut

sub canAdd {
    my $class = shift;
    my $session = shift;
    return $class->next::method($session, undef, '7');
}

#-------------------------------------------------------------------

=head2 canEdit 

Returns true if the current user can administer the wiki containing this WikiPage, or
if the current user can edit wiki pages and is trying to add or edit pages, or the page
is not protected.

=cut

sub canEdit {
	my $self = shift;
    my $wiki = $self->getWiki;
    return undef unless defined $wiki;

	my $form      = $self->session->form;
    my $addNew    = $form->process("func"              ) eq "add";
    my $editSave  = $form->process("assetId"           ) eq "new"
                 && $form->process("func"              ) eq "editSave"
                 && $form->process("class","className" ) eq "WebGUI::Asset::WikiPage";
    return $wiki->canAdminister
        || ( $wiki->canEditPages && ( $addNew || $editSave || !$self->isProtected) );
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
			defaultValue => '',
			noFormPost => 1,
			},
		actionTakenBy => {
			fieldType => "user",
			defaultValue => '',
			noFormPost => 1,
			},
                isFeatured => {
                    fieldType       => "yesNo",
                    defaultValue    => 0,
                    noFormPost      => 1,
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

	return $class->next::method($session, $definition);
}


#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId 

Overrides the master class to handle spam prevention.  If the content matches any of
the spamStopWords, then the commit is canceled and the content is rolled back to the
previous version.  Otherwise, it returns the autoCommitWorkflowId for the regular asset
commit flow to handle.

=cut

sub getAutoCommitWorkflowId {
	my $self = shift;
    my $wiki = $self->getWiki;
    if ($wiki->hasBeenCommitted) {

        # delete spam
        my $spamStopWords = $self->session->config->get('spamStopWords');
        if (ref $spamStopWords eq 'ARRAY') {
            my $spamRegex = join('|',@{$spamStopWords});
            $spamRegex =~ s/\s/\\ /g;
            if ($self->get('content') =~ m{$spamRegex}xmsi) {
                my $tag = WebGUI::VersionTag->new($self->session, $self->get('tagId'));
                $self->purgeRevision;
                if ($tag->getAssetCount == 0) {
                    $tag->rollback;
                }
                return undef;
            }
        }

        return $wiki->get('approvalWorkflow')
            || $self->session->setting->get('defaultVersionTagWorkflow');
    }
    return undef;
}


#-------------------------------------------------------------------

=head2 getEditForm 

Renders a templated edit form for adding or editing a wiki page.

=cut

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
                formFeatured => WebGUI::Form::yesNo( $session, { name => 'isFeatured', value=>$self->getValue('isFeatured')}),
        formKeywords => WebGUI::Form::keywords($session, {
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

=head2 getSubscriptionTemplate ( )

=cut

sub getSubscriptionTemplate { 
    my ( $self ) = @_;
    return $self->getParent->getSubscriptionTemplate;
}

#-------------------------------------------------------------------

=head2 getTemplateVars ( )

Get the common template vars for this asset

=cut

sub getTemplateVars {
    my ( $self ) = @_;
    my $i18n        = WebGUI::International->new($self->session, "Asset_WikiPage");
    my $wiki        = $self->getWiki;
    my $owner       = WebGUI::User->new( $self->session, $self->get('ownerUserId') );
    my $keywords    = WebGUI::Keyword->new($self->session)->getKeywordsForAsset({
        asset       => $self,
        asArrayRef  => 1,
    });
    my @keywordsLoop = ();
    foreach my $word (@{$keywords}) {
        push @keywordsLoop, {
            keyword => $word,
            url     => $wiki->getUrl("func=byKeyword;keyword=".$word),
        };
    }
    my $var = {
        %{ $self->get },
        url                 => $self->getUrl,
        keywordsLoop        => \@keywordsLoop,
        viewLabel           => $i18n->get("viewLabel"),
        editLabel           => $i18n->get("editLabel"),
        historyLabel        => $i18n->get("historyLabel"),
        wikiHomeLabel       => $i18n->get("wikiHomeLabel", "Asset_WikiMaster"),
        searchLabel         => $i18n->get("searchLabel", "Asset_WikiMaster"),	
        searchUrl           => $wiki->getUrl("func=search"),
        recentChangesUrl    => $wiki->getUrl("func=recentChanges"),
        recentChangesLabel  => $i18n->get("recentChangesLabel", "Asset_WikiMaster"),
        mostPopularUrl      => $wiki->getUrl("func=mostPopular"),
        mostPopularLabel    => $i18n->get("mostPopularLabel", "Asset_WikiMaster"),
        wikiHomeUrl         => $wiki->getUrl,
        historyUrl          => $self->getUrl("func=getHistory"),
        editContent         => $self->getEditForm,
        allowsAttachments   => $wiki->get("allowAttachments"),
        comments	    => $self->getFormattedComments(),
        canEdit             => $self->canEdit,
		isProtected         => $self->isProtected,
        content             => $wiki->autolinkHtml(
            $self->scrubContent,
            {skipTitles => [$self->get('title')]},
        ),	
        isSubscribed        => $self->isSubscribed,
        subscribeUrl        => $self->getSubscribeUrl,
        unsubscribeUrl      => $self->getUnsubscribeUrl,
        owner               => $owner->get('alias'),
    };
    return $var;
}

#-------------------------------------------------------------------

=head2 getWiki 

Returns an object referring to the wiki that contains this page.  If it is not a WikiMaster,
or the parent is undefined, it returns undef.

=cut

sub getWiki {
	my $self = shift;
	my $parent = $self->getParent;
	return undef unless defined $parent and $parent->isa('WebGUI::Asset::Wobject::WikiMaster');
	return $parent;
}

#-------------------------------------------------------------------

=head2 indexContent 

Extends the master class to handle indexing the wiki content.

=cut

sub indexContent {
	my $self = shift;
	my $indexer = $self->next::method;
	$indexer->addKeywords($self->get('content'));
	return $indexer;
}

#-------------------------------------------------------------------

=head2 isProtected 

Returns a boolean indicating whether or not this WikiPage is protected.

=cut

sub isProtected {
	my $self = shift;
	return $self->get("isProtected");
}

#-------------------------------------------------------------------

=head2 preparePageTemplate 

This is essentially prepareView, but is smart and will only do the template
preparation once.  Returns the preparted page template.

=cut

sub preparePageTemplate {
	my $self = shift;
	return $self->{_pageTemplate} if $self->{_pageTemplate};
	$self->{_pageTemplate} =
	    WebGUI::Asset::Template->new($self->session, $self->getWiki->get('pageTemplateId'));
	$self->{_pageTemplate}->prepare;
	return $self->{_pageTemplate};
}

#-------------------------------------------------------------------

=head2 prepareView 

Extends the master class to handle preparing the main view template for the page.

=cut

sub prepareView {
	my $self = shift;
	$self->next::method;
	$self->preparePageTemplate;
}


#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost 

Extends the master method to handle properties and attachments.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	$self->next::method(@_);
	my $actionTaken = ($self->session->form->process("assetId") eq "new") ? "Created" : "Edited";
    my $wiki = $self->getWiki;
	my $properties = {
		groupIdView 	=> $wiki->get('groupIdView'),
		groupIdEdit 	=> $wiki->get('groupToAdminister'),
		actionTakenBy 	=> $self->session->user->userId,
		actionTaken 	=> $actionTaken,
	};

	if ($wiki->canAdminister) {
		$properties->{isProtected} = $self->session->form->get("isProtected");
		$properties->{isFeatured} = $self->session->form->get("isFeatured");
	}

	$self->update($properties);

    # deal with attachments from the attachments form control
    my $options = {
        maxImageSize    => $wiki->get('maxImageSize'),
        thumbnailSize   => $wiki->get('thumbnailSize'),
    };
    my @attachments = $self->session->form->param("attachments");
    my @tags = ();
    foreach my $assetId (@attachments) {
        my $asset = WebGUI::Asset->newById($self->session, $assetId);
        if (defined $asset) {
            unless ($asset->get("parentId") eq $self->getId) {
                $asset->setParent($self);
                $asset->update({
                    ownerUserId => $self->get("ownerUserId"),
                    groupIdEdit => $self->get("groupIdEdit"),
                    groupIdView => $self->get("groupIdView"),
                    });
            }
            $asset->applyConstraints($options);
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
    return $self->next::method($properties);
}

#-------------------------------------------------------------------

=head2 validParent

Make sure that the current session asset is a WikiMaster for pasting and adding checks.

This is a class method.

=cut

sub validParent {
    my $class   = shift;
    my $session = shift;
    return $session->asset->isa('WebGUI::Asset::Wobject::WikiMaster');
}

#-------------------------------------------------------------------

=head2 view 

Renders this asset.

=cut

sub view {
	my $self = shift;
	return $self->processTemplate($self->getTemplateVars, $self->getWiki->get("pageTemplateId"));
}

#-------------------------------------------------------------------

=head2 www_delete 

Overrides the master method so that privileges are checked on the parent wiki instead
of the page.  Returns the user to viewing the wiki.

=cut

sub www_delete {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->getWiki->canAdminister;
	$self->trash;
	$self->session->asset($self->getParent);
	return $self->getParent->www_view;
}

#-------------------------------------------------------------------

=head2 www_edit 

Overrides the master class to render the edit form in the parent wiki's style.

=cut

sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canEdit;
	return $self->session->privilege->locked unless $self->canEditIfLocked;
	return $self->getWiki->processStyle($self->getEditForm);
}

#-------------------------------------------------------------------

=head2 www_getHistory 

Returns the version history of this wiki page.  The output is templated.

=cut

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
			username => $user->profileField('alias') || $user->username,
			actionTaken => $revision->get("actionTaken"),
			interval => join(" ", $date->secondsToInterval(time() - $revision->get("revisionDate")))
			});		
	}
	return $self->processTemplate($var, $self->getWiki->get('pageHistoryTemplateId'));
}

#-------------------------------------------------------------------

=head2 www_restoreWikiPage 

Publishes a wiki page that has been put into the trash or the clipboard.

=cut

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

=head2 www_view 

Override the master method to count the number of times this page has been viewed,
and to render it with the parent's style.

=cut

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess unless $self->canView;
	$self->update({ views => $self->get('views')+1 });
	# TODO: This should probably exist, as the CS has one.
#	$self->session->http->setCacheControl($self->getWiki->get('visitorCacheTimeout'))
#	    if ($self->session->user->isVisitor);
	$self->session->http->sendHeader;
	$self->prepareView;
	return $self->getWiki->processStyle($self->view);
}



1;
