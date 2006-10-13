package WebGUI::Asset::Wobject::WikiMaster;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use HTML::Parser;
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, 'Asset_WikiMaster');

	# BUGGO: duplication with Collaboration; move this into WebGUI::Asset::RichEdit
	my $richEditorOptions = $session->db->buildHashRef("select distinct(assetData.assetId), assetData.title from asset, assetData where asset.className='WebGUI::Asset::RichEdit' and asset.assetId=assetData.assetId order by assetData.title");

	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties =
	    (
	     groupToEditPages => { fieldType => 'group',
				   defaultValue => ['7'],
				   tab => 'security',
				   hoverHelp => $i18n->get('groupToEditPages hoverHelp'),
				   label => $i18n->get('groupToEditPages label') },

	     groupToAdminister => { fieldType => 'group',
				    defaultValue => ['3'],
				    tab => 'security',
				    hoverHelp => $i18n->get('groupToAdminister hoverHelp'),
				    label => $i18n->get('groupToAdminister label') },

	     richEditor => { fieldType => 'selectBox',
			     options => $richEditorOptions,
			     defaultValue => 'PBrichedit000000000001',
			     tab => 'display',
			     hoverHelp => $i18n->get('richEditor hoverHelp'),
			     label => $i18n->get('richEditor label') },

	     # BUGGO: how do we get this to only be able to specify pages underneath
	     # the asset?  There's no lineage option for this field type.
	     defaultPage => { fieldType => 'asset',
			      className => 'WebGUI::Asset::WikiPage',
			      tab => 'display',
			      hoverHelp => $i18n->get('defaultPage hoverHelp'),
			      label => $i18n->get('defaultPage label') },

	     masterTemplateId => { fieldType => 'template',
				   namespace => 'WikiMaster',
				   defaultValue => 'WikiMasterTmpl00000001',
				   tab => 'display',
				   hoverHelp => $i18n->get('masterTemplateId hoverHelp'),
				   label => $i18n->get('masterTemplateId label') },

	     pageTemplateId => { fieldType => 'template',
				 namespace => 'WikiPage',
				 defaultValue => 'WikiPageTmpl0000000001',
				 tab => 'display',
				 hoverHelp => $i18n->get('pageTemplateId hoverHelp'),
				 label => $i18n->get('pageTemplateId label') },

	     pageHistoryTemplateId => { fieldType => 'template',
					namespace => 'WikiPage_pageHistory',
					defaultValue => 'WikiPHTmpl000000000001',
					tab => 'display',
					hoverHelp => $i18n->get('pageHistoryTemplateId hoverHelp'),
					label => $i18n->get('pageHistoryTemplateId label') },

	     recentChangesTemplateId => { fieldType => 'template',
					  namespace => 'WikiMaster_recentChanges',
					  defaultValue => 'WikiRCTmpl000000000001',
					  tab => 'display',
					  hoverHelp => $i18n->get('recentChangesTemplateId hoverHelp'),
					  label => $i18n->get('recentChangesTemplateId label') },

	     pageListTemplateId => { fieldType => 'template',
				     namespace => 'WikiMaster_pageList',
				     defaultValue => 'WikiPLTmpl000000000001',
				     tab => 'display',
				     hoverHelp => $i18n->get('pageListTemplateId hoverHelp'),
				     label => $i18n->get('pageListTemplateId label') },
	    );

	push @$definition,
	     {
	      assetName => $i18n->get('assetName'),
	      icon => 'wikiMaster.gif',
	      autoGenerateForms => 1,
	      tableName => 'WikiMaster',
	      className => 'WebGUI::Asset::Wobject::WikiMaster',
	      properties => \%properties,
	     };

        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub canEditPages {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	my $user = WebGUI::User->new($self->session, $userId);
	return $self->canView($userId) && $user->isInGroup($self->get('groupToEditPages'));
}

sub canAdminister {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	my $user = WebGUI::User->new($self->session, $userId);
	return $self->canView($userId) && $user->isInGroup($self->get('groupToAdminister'));
}

#-------------------------------------------------------------------
sub getDefaultPage {
	my $self = shift;
	return $self->{_defaultPage} if $self->{_defaultPage};

	my $pageId = $self->get('defaultPage');
	if (defined $pageId) {
		my $page = WebGUI::Asset->newByDynamicClass($self->session, $pageId);
		if (defined $page and $page->isa('WebGUI::Asset::WikiPage') and $page->getParent->getId eq $self->getId) {
			$self->{_defaultPage} = $page;
			return $page;
		}
	}

	# No valid default page.  Okay, we have to synthesize it.
	my $page = WebGUI::Asset->newByPropertyHashRef
	    ($self->session, { className => 'WebGUI::Asset::WikiPage',
			       title => $self->get('title'), content => $self->get('description') });
	$page->{_parent} = $self;
	$page->{_nonexistent} = 1;
	$self->{_defaultPage} = $page;
	return $page;
}

sub prepareMasterTemplate {
	my $self = shift;
	return $self->{_masterTemplate} if $self->{_masterTemplate};
	$self->{_masterTemplate} =
	    WebGUI::Asset::Template->new($self->session, $self->get('masterTemplateId'));
	$self->{_masterTemplate}->prepare;
	return $self->{_masterTemplate};
}

sub processMasterTemplate {
	my $self = shift;
	my $title = shift;
	my $content = shift;
	my $var = {};
	my $template = $self->prepareMasterTemplate;
	
	$var->{title} = $title;
	$var->{content} = $content;
	$var->{displayTitle} = $self->get('displayTitle');
	$var->{canEdit} = $self->canEditPages;
	$self->_addFuncTemplateVars($var, qw/addPage listPages recentChanges/);

	return $self->processTemplate($var, undef, $template);
}

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView;
	$self->prepareMasterTemplate;
	$self->getDefaultPage->prepareView;
}

sub _addFuncTemplateVars {
	my $self = shift;
	my $var = shift;
	my @funcs = @_;
	my $i18n = WebGUI::International->new($self->session, 'Asset_WikiMaster');
	my %specialFuncs =
	    (addPage => 'func=add;class=WebGUI::Asset::WikiPage');

	foreach my $func (@funcs) {
		$var->{$func.'.url'} = $self->getUrl($specialFuncs{$func} || "func=$func");
		$var->{$func.'.text'} = $i18n->get("func $func link text");
	}
}

sub view {
	my $self = shift;
	return $self->getDefaultPage->view;
}

sub getContentLastModified {
	my $self = shift;
	return $self->getDefaultPage->getContentLastModified;
}

#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	$self->session->db->write('DELETE FROM WikiMaster_titleIndex WHERE assetId = ?', [$self->getId]);
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;

	# BUGGO: Duplication with A::W::Collaboration::processPropertiesFromFormPost
	my $groupsChanged =
	    (($self->session->form->process('groupIdView') ne $self->get('groupIdView'))
	     or ($self->session->form->process('groupIdEdit') ne $self->get('groupIdEdit')));
	my $ret = $self->SUPER::processPropertiesFromFormPost(@_);

	if ($groupsChanged) {
		foreach my $child (@{$self->getLineage(['children'], {returnObjects => 1})}) {
			$child->update({ groupIdView => $self->get('groupIdView'),
					 groupIdEdit => $self->get('groupIdEdit') });
		}
	}

	return $ret;
}

#-------------------------------------------------------------------
sub updateTitleIndex {
	my $self = shift;
	my @pages = @{+shift};
	my %opts = @_;
	return unless @pages;
	$self->session->db->write("DELETE FROM WikiMaster_titleIndex WHERE assetId = ? AND pageId IN (".join(', ', ('?') x @pages).")", [$self->getId, map{$_->getId} @pages]);

	foreach my $page (@pages) {
		my ($pageId, $title) = ($page->getId, $page->get('title'));
		$self->session->db->write("INSERT INTO WikiMaster_titleIndex (assetId, pageId, title) VALUES (?, ?, ?)", [$self->getId, $pageId, $title]);
	}
}

sub autolinkHtml {
	my $self = shift;
	my $html = shift;

	# TODO: caching?  Maybe in WikiPage.
	my %mapping = $self->session->db->buildHash("SELECT LOWER(i.title), d.url FROM WikiMaster_titleIndex AS i INNER JOIN assetData AS d ON i.pageId = d.assetId WHERE i.assetId = ?", [$self->getId]);
	return $html unless %mapping;

	foreach my $key (keys %mapping) {
		$mapping{$key} = WebGUI::HTML::format('/'.$mapping{$key}, 'text');
	}

	my $matchString = join('|', map{quotemeta} keys %mapping);
	my $regexp = qr/\b($matchString)\b/i;

	my @acc = ();
	my $in_a = 0;
	my $p = HTML::Parser->new;
	$p->case_sensitive(1);
	$p->marked_sections(1);
	$p->unbroken_text(1);
	$p->handler(start => sub { push @acc, $_[2]; if ($_[0] eq 'a' and exists $_[1]{href}) { $in_a++ } },
		    'tagname, attr, text');
	$p->handler(end => sub { push @acc, $_[2]; if ($_[0] eq 'a' and exists $_[1]{href}) { $in_a-- } },
		    'tagname, attr, text');
	$p->handler(text => sub {
			    my $text = $_[0];
			    unless ($in_a) {
				    while ($text =~ s#^(.*?)$regexp##i) {
					    push @acc, sprintf '%s<a href="%s">%s</a>',
						($1, $mapping{lc $2}, $2);
				    }
			    }
			    push @acc, $text;
		    }, 'text');
	$p->handler(default => sub { push @acc, $_[0] }, 'text');
	$p->parse($html);
	$p->eof;
	undef $p;		# Just in case there might be reference loops.

	return join '', @acc;
}

#-------------------------------------------------------------------
sub www_addPageSave {
	my $self = shift;
	my $pageClass = $self->session->form->process('class');
	return $self->session->privilege->insufficient unless
	    $self->canEditPages and UNIVERSAL::isa($pageClass, 'WebGUI::Asset::WikiPage');

	# Refactor: duplication with A::W::Matrix::www_editListingSave
	my $oldTag = WebGUI::VersionTag->getWorking($self->session, 1);
	my $newTag = WebGUI::VersionTag->create
	    ($self->session, { name => (sprintf "%s create of %s - %s",
					$self->get('title'), $self->session->form->process('title'),
					$self->session->user->username),
			       workflowId => 'pbworkflow000000000003' });
	$newTag->setWorking;

	# Hrm.  Duplication with Asset::www_editSave.  How to fix that?
	my $page = $self->addChild({ className => $pageClass });
	$page->{_parent} = $self;

	my $error = $page->processPropertiesFromFormPost;
	if (ref $error eq 'ARRAY') {
		$self->session->stow->set('editFormErrors', $error);
		$page->purge;
		return $self->www_add;
	}

	$page->updateHistory('edited');
	$newTag->requestCommit;
	$newTag->clearWorking;
	$oldTag->setWorking if defined $oldTag;
	return $page->www_view;
}

#-------------------------------------------------------------------
sub www_listPages {
	# TODO: template, i18n
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_WikiMaster');
	my $title = $i18n->get('listPages title');
	my @pages = @{$self->getLineage(['children'], {returnObjects => 1})};
	my $var = {};
	my $template = WebGUI::Asset::Template->new($self->session, $self->get('pageListTemplateId'));
	$template->prepare;

	$var->{'pl.entries'} = [map {
		my $page = $_;
		my $subvar = {};
		$subvar->{pageUrl} = WebGUI::HTML::format($page->getUrl, 'text');
		$subvar->{pageTitle} = WebGUI::HTML::format($page->get('title'), 'text');
		$subvar;
	} @pages];

	return $self->processStyle($self->processMasterTemplate($title, $self->processTemplate($var, undef, $template)));
}

#-------------------------------------------------------------------
sub www_recentChanges {
	my $self = shift;
	my $ago = WebGUI::International->new($self->session, 'Asset')->get('ago');
	my $dt = $self->session->datetime;

	# Buggo: hardcoded number of recent changes
	# TODO: query should have both time limit and number limit, settable by form elements...
	my @changes = @{$self->session->db->buildArrayRefOfHashRefs("SELECT h.userId AS userId, u.username AS username, h.dateStamp AS dateStamp, h.actionTaken AS action, d.url AS url, d.title AS title FROM assetHistory AS h LEFT JOIN users AS u ON h.userId = u.userId INNER JOIN asset AS a ON h.assetId = a.assetId INNER JOIN assetData AS d ON a.assetId = d.assetId AND h.dateStamp = d.revisionDate WHERE a.lineage LIKE CONCAT(?, '%') AND a.assetId <> ? AND h.actionTaken IN ('edited', 'trashed') ORDER BY dateStamp DESC LIMIT 0,50", [$self->get('lineage'), $self->getId])};

	# Buggo, duplication with WikiPage::www_pageHistory?
	my $time = $dt->time;
	my @days = ();
	foreach my $entry (@changes) {
		$entry->{date} = $dt->epochToHuman($entry->{dateStamp}, '%z');
		$entry->{time} = $dt->epochToHuman($entry->{dateStamp}, '%Z');
		$entry->{dateInterval} = sprintf '%s %s %s',
		    ($dt->secondsToInterval($time - $entry->{dateStamp}), $ago);
		$entry->{isDelete} = ($entry->{action} eq 'trashed');
		$entry->{isEdit} = ($entry->{action} eq 'edited');
		$entry->{viewUrl} = $entry->{url};

		# TODO: actionC, and also lowercased version, and change WikiPage to comply
		# with that also

		if (!@days || $entry->{date} ne $days[-1][0]{date}) {
			push @days, [$entry];
		} else {
			push @{$days[-1]}, $entry;
		}
	}

	my $template = WebGUI::Asset::Template->new($self->session, $self->get('recentChangesTemplateId'));
	$template->prepare;

	my $var = {};
	$var->{'rc.entries'} = \@changes;
	$var->{'rc.days'} = [map{{'day.date' => $$_[0]{date}, 'day.entries' => $_}} @days];

	my $title = "Recent changes";
	
	return $self->processStyle($self->processMasterTemplate($title, $self->processTemplate($var, undef, $template)));
}

1;
