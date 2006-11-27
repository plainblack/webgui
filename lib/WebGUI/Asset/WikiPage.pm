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
use WebGUI::Utility;

#-------------------------------------------------------------------
# Buggo, semi-duplication with WikiMaster; move this into a common utility routine somewhere
sub _appendFuncTemplateVars {
	my $self = shift;
	my $var = shift;
	my @funcs = @_;
	my $i18n = WebGUI::International->new($self->session, 'Asset_WikiPage');
	my %specialFuncs = ();
	my $revision = $self->session->form->process('revision');
	my $revisionSuffix = defined($revision)? ";revision=$revision" : '';
	@funcs = (qw/view edit pageHistory protect unprotect delete wikiPurgeRevision/) unless @funcs;

	foreach my $func (@funcs) {
		$var->{$func.'.url'} = $self->getUrl($specialFuncs{$func}
						     || "func=$func$revisionSuffix");
		$var->{$func.'.text'} = $i18n->get("func $func link text");
		my $confirmation = $i18n->get("func $func link confirm");
		if (length $confirmation) {
			$confirmation =~ s/\'/\\\'/g;
			$var->{$func.'.confirm'} = "return confirm('$confirmation')";
		}
	}
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
sub purge {
	my $self = shift;
	$self->getWiki->updateTitleIndex([$self], from => 'purge');
	$self->session->db->write("DELETE FROM WikiPage_protected WHERE assetId = ?", [$self->getId]);
	$self->session->db->write("DELETE FROM WikiPage_extraHistory WHERE assetId = ?", [$self->getId]);
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------
sub purgeRevision {
	my $self = shift;
	$self->getWiki->updateTitleIndex([$self], from => 'purgeRevision');
	return $self->SUPER::purgeRevision;
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
sub processPageTemplate {
	my $self = shift;
	my $content = shift;
	my $func = shift || $self->session->form->process('func');
	my $var = {};
	my $template = $self->preparePageTemplate;

	$var->{content} = $content;
	$var->{canEdit} = $self->canEdit;
	$var->{couldEdit} = $self->couldEdit;
	$var->{canProtect} = $self->canProtect;
	$var->{canDelete} = $self->canDelete;
	$var->{isProtected} = $self->isProtected;
	$var->{inEdit} = isIn($func, qw/edit add/);
	$var->{inView} = isIn($func, qw/view/) || !defined $func;
	$var->{inHistory} = isIn($func, qw/pageHistory/);
	$self->_appendFuncTemplateVars($var);

	return $self->processTemplate($var, undef, $template);
}

#-------------------------------------------------------------------
sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView;
	$self->preparePageTemplate;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $var = {};
	my $title = $self->get('title');
	my $content = $self->getWiki->autolinkHtml($self->get('content'));
	return $self->getWiki->processMasterTemplate($title, $self->processPageTemplate($content, 'view'));
}

#-------------------------------------------------------------------
sub isProtected {
	my $self = shift;
	return $self->{_isProtected} if exists $self->{_isProtected};
	($self->{_isProtected}) = $self->session->db->quickArray("SELECT COUNT(assetId) FROM WikiPage_protected WHERE assetId = ?", [$self->getId]);
	return $self->{_isProtected};
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	my $ret = $self->SUPER::processPropertiesFromFormPost(@_);
	$self->update({ groupIdView => $self->getWiki->get('groupIdView'),
			groupIdEdit => $self->getWiki->get('groupIdEdit') });
	$self->getWiki->updateTitleIndex([$self], from => 'edit');
	return $ret;
}	

#-------------------------------------------------------------------
sub updateWikiHistory {
	my $self = shift;
	my $action = shift;
	my $userId = shift || $self->session->user->userId;
	$self->session->db->write("INSERT INTO WikiPage_extraHistory (assetId, userId, dateStamp, actionTaken, url, title) VALUES (?, ?, ?, ?, ?, ?)", [$self->getId, $userId, $self->session->datetime->time, $action, $self->getUrl, $self->get('title')]);
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
sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canEdit;

	my $template = WebGUI::Asset::Template->new($self->session, $self->getWiki->get('pageEditTemplateId'));
	my $var = {};
	my $newPage = 0;
	$template->prepare;

	if ($self->session->form->process('func') eq 'add') {
		# New page.
		$newPage = 1;
		$var->{'form.header'} = join '',
		    (WebGUI::Form::formHeader($self->session,
					      { action => $self->getWiki->getUrl('func=addPageSave') }),
		     WebGUI::Form::hidden($self->session, { name => 'class', value => ref $self }));
	} else {
		# Editing a page.
		$newPage = 0;
		$var->{'form.header'} = join '',
		    (WebGUI::Form::formHeader($self->session,
					      { action => $self->getUrl('func=editSave') }));
	}

	$var->{'form.title'} = WebGUI::Form::text
	    ($self->session, { name => 'title', maxlength => 255,
			       size => 40, value => $self->get('title') });
	$var->{'form.content'} = WebGUI::Form::HTMLArea
	    ($self->session, { name => 'content', richEditId => $self->getWiki->get('richEditor'),
			       value => $self->get('content') });
	$var->{'form.submit'} = WebGUI::Form::submit
	    ($self->session, { value => 'Save' });
	$var->{'form.footer'} = WebGUI::Form::formFooter($self->session);
	$self->_appendFuncTemplateVars($var);

	my $title = "Editing ".(defined($self->get('title'))? $self->get('title') : 'new page');

	return $self->getWiki->processStyle($self->getWiki->processMasterTemplate($title, $self->processPageTemplate($self->processTemplate($var, undef, $template), 'edit')));
}

#-------------------------------------------------------------------
sub www_editSave {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canEdit;

	# TODO: refactor: duplication with A::W::Matrix::www_editListingSave
	my $oldTag = WebGUI::VersionTag->getWorking($self->session, 1);
	my $newTag = WebGUI::VersionTag->create
	    ($self->session, { name => (sprintf "%s edit of %s - %s",
					$self->getWiki->get('title'), $self->get('title'),
					$self->session->user->username),
			       workflowId => 'pbworkflow000000000003' });
	$newTag->setWorking;

	my $newSelf = $self->addRevision;
	my $error = $newSelf->processPropertiesFromFormPost;
	if (ref $error eq 'ARRAY') {
		$self->session->stow->set('editFormErrors', $error);
		$newTag->rollback;
		$oldTag->setWorking if defined $oldTag;
		return $self->www_edit;
	}

	$newSelf->updateHistory('edited');
	$newTag->requestCommit;
	$newTag->clearWorking;
	$oldTag->setWorking if defined $oldTag;

	return $newSelf->www_view;
}

#-------------------------------------------------------------------
sub www_pageHistory {
	my $self = shift;
	my $title = sprintf(WebGUI::International->new($self->session, 'Asset_WikiPage')->get('pageHistory title'),
			    $self->get('title'));
	my $template = WebGUI::Asset::Template->new($self->session, $self->getWiki->get('pageHistoryTemplateId'));
	$template->prepare;

	# Buggo: hardcoded count
	my $var = {};
	$self->getWiki->_appendPageHistoryVars($var, [0, 50], $self);

	return $self->getWiki->processStyle($self->getWiki->processMasterTemplate($title, $self->processPageTemplate($self->processTemplate($var, undef, $template), 'pageHistory')));
}

#-------------------------------------------------------------------
sub www_protect {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canProtect;
	return $self->www_view if $self->isProtected;

	$self->session->db->write("DELETE FROM WikiPage_protected WHERE assetId = ?", [$self->getId]);
	$self->session->db->write("INSERT INTO WikiPage_protected (assetId) VALUES (?)", [$self->getId]);
	$self->{_isProtected} = 1;
	$self->updateWikiHistory('protected');
	return $self->www_view;
}

#-------------------------------------------------------------------
sub www_unprotect {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canProtect;
	return $self->www_view if !$self->isProtected;

	$self->session->db->write("DELETE FROM WikiPage_protected WHERE assetId = ?", [$self->getId]);
	$self->{_isProtected} = 0;
	$self->updateWikiHistory('unprotected');
	return $self->www_view;
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


#-------------------------------------------------------------------
sub www_wikiPurgeRevision {
	my $self = shift;
	return $self->session->privilege->insufficient unless $self->canDelete;
	$self->purgeRevision;
	$self->session->asset($self->getParent);
	return $self->getParent->www_view;
}

1;
