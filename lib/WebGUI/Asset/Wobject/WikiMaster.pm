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

use base 'WebGUI::Asset::Wobject';
use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use HTML::Parser;
use URI::Escape;

#-------------------------------------------------------------------
sub _appendFuncTemplateVars {
	my $self = shift;
	my $var = shift;
	my @funcs = @_;
	my $i18n = WebGUI::International->new($self->session, 'Asset_WikiMaster');
	my %specialFuncs =
	    (addPage => 'func=add;class=WebGUI::Asset::WikiPage');

	foreach my $func (@funcs) {
		$var->{$func.'Url'} = $self->getUrl($specialFuncs{$func} || "func=$func");
		$var->{$func.'Text'} = $i18n->get("func $func link text");
	}
}

#-------------------------------------------------------------------
sub _appendPageHistoryVars {
	my $self = shift;
	my $var = shift;
	my $limit = shift;
	my $page = shift;
	my $time = $self->session->datetime->time;
	my $entries = $self->_templateSubvarsRefOfEdits($self->_editsRefOfPageHistory($page, $limit), $time);
	my $days = $self->_daysRefOfTemplateSubvars($entries);

	$var->{'pageHistoryEntries'} = $entries;
	$var->{'pageHistoryDays'} = $days;
	return $self;
}

#-------------------------------------------------------------------
sub _appendRecentChangesVars {
	my $self = shift;
	my $var = shift;
	my $limit = shift;
	my $time = $self->session->datetime->time;
	my $entries = $self->_templateSubvarsRefOfEdits($self->_editsRefOfRecentChanges($limit), $time);
	my $days = $self->_daysRefOfTemplateSubvars($entries);

	$var->{'recentChangesEntries'} = $entries;
	$var->{'recentChangesDays'} = $days;
	return $self;
}

#-------------------------------------------------------------------
sub _appendSearchBoxVars {
	my $self = shift;
	my $var = shift;
	my $queryText = shift;
	my $submitText = WebGUI::International->new($self->session, 'Asset_WikiMaster')->get('search submit');

	$var->{'searchFormHeader'} = join '',
	    (WebGUI::Form::formHeader($self->session, { action => $self->getUrl, method => 'GET' }),
	     WebGUI::Form::hidden($self->session, { name => 'func', value => 'search' }));
	$var->{'searchQuery'} = WebGUI::Form::text($self->session, { name => 'query', value => $queryText });
	$var->{'searchSubmit'} = WebGUI::Form::submit($self->session, { value => $submitText });
	$var->{'searchFormFooter'} = WebGUI::Form::formFooter($self->session);
	return $self;
}

#-------------------------------------------------------------------
sub _appendSearchResultVars {
	my $self = shift;
	my $var = shift;
	my $rs = shift;
	my @results = ();
	my $dt = $self->session->datetime;

	while (defined(my $row = $rs->hashRef)) {
		push @results, $self->_templateSubvarOfPage($row->{assetId});
	}

	$var->{'searchResults'} = \@results;

	return $self;
}

#-------------------------------------------------------------------
sub _appendVarsOfDate {
	my $self = shift;
	my $var = shift;
	my $date = shift;
	my $prefix = shift;
	my $relativeTo = shift;
	my $dt = $self->session->datetime;

	$var->{$prefix . (length($prefix)? 'Date':'date')} = $dt->epochToHuman($date, '%z');
	$var->{$prefix . (length($prefix)? 'Time':'time')} = $dt->epochToHuman($date, '%Z');
	if (defined $relativeTo) {
		my $ago = WebGUI::International->new($self->session, 'Asset')->get('ago');
		$var->{$prefix . (length($prefix)? 'Interval':'interval')} = sprintf '%s %s %s',
		    ($dt->secondsToInterval($relativeTo - $date), $ago);
	}

	return $self;
}

#-------------------------------------------------------------------
sub _daysRefOfTemplateSubvars {
	my $self = shift;
	my $subvars = shift;
	my @days = ();

	foreach my $subvar (@$subvars) {
		if (!@days or $subvar->{date} ne $days[-1][0]{date}) {
			push @days, [$subvar];
		} else {
			push @{$days[-1]}, $subvar;
		}
	}

	return [map { {'dayDate' => $$_[0]{date}, 'dayEntries' => $_} } @days];
}

#-------------------------------------------------------------------
sub _editsRefOfPageHistory {
	my $self = shift;
	my $page = shift;
	my $limit = shift;
	$self->_editsRefOfQuery("a.assetId = ?", [$page->getId], undef, $limit);
}

#-------------------------------------------------------------------
sub _editsRefOfQuery {
	my $self = shift;
	my $queryPiece = shift || 'true';
	my $placeholders = shift || [];
	my $allowedActions = shift || [qw/edited trashed protected unprotected/];
	my $allowedActionsPredicate = "IN (".join(', ', ('?') x @$allowedActions).")";
	my $limit = shift;
	my $limitClause = $limit? sprintf("LIMIT %d,%d", @$limit[0..1]) : "";

	# Ick.  Apparently assetHistory.dateStamp isn't always equivalent to assetData.revisionDate.
	# It looks like the relationship between them is in fact semi-arbitrary.  Then there's also that
	# it doesn't seem to be safe to add extra possible values to assetHistory.  So we have to do this.
	# Bleagh.
	$self->session->db->buildArrayRefOfHashRefs(<<"EOT", [(@$placeholders, @$allowedActions) x 3]);
SELECT h.userId AS userId, u.username AS username, h.dateStamp AS dateStamp,
       h.actionTaken AS action, CONCAT('/', d.url) AS url, d.title AS title, a.assetId AS assetId
  FROM assetHistory AS h LEFT JOIN users AS u ON h.userId = u.userId
                         INNER JOIN asset AS a ON h.assetId = a.assetId
                         INNER JOIN assetData AS d ON a.assetId = d.assetId AND h.dateStamp = d.revisionDate
 WHERE $queryPiece AND h.actionTaken $allowedActionsPredicate
       UNION
SELECT eh.userId AS userId, u.username AS username, eh.dateStamp AS dateStamp,
       eh.actionTaken AS action, CONCAT('/', eh.url) AS url, eh.title AS title, a.assetId AS assetId
  FROM WikiPage_extraHistory AS eh LEFT JOIN users AS u ON eh.userId = u.userId
                                   INNER JOIN asset AS a ON eh.assetId = a.assetId
 WHERE $queryPiece AND eh.actionTaken $allowedActionsPredicate
       UNION
SELECT d.revisedBy AS userId, u.username AS username, d.revisionDate AS dateStamp,
       'edited' AS action, CONCAT('/', d.url) AS url, d.title AS title, a.assetId AS assetId
  FROM assetData AS d LEFT JOIN users AS u on d.revisedBy = u.userId
                      INNER JOIN asset AS a ON d.assetId = a.assetId
 WHERE $queryPiece AND 'edited' $allowedActionsPredicate
       ORDER BY dateStamp DESC
       $limitClause
EOT
}

#-------------------------------------------------------------------
sub _editsRefOfRecentChanges {
	my $self = shift;
	my $limit = shift;
	$self->_editsRefOfQuery("a.lineage LIKE CONCAT(?, '%') AND a.assetId <> ?", [$self->get('lineage'), $self->getId], [qw/edited trashed/], $limit);
}

#-------------------------------------------------------------------
sub _templateSubvarOfEdit {
	my $self = shift;
	my $edit = shift;
	my $time = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_WikiMaster');
	my $subvar = +{%$edit};

	$self->_appendVarsOfDate($subvar, $subvar->{dateStamp}, '', $time);

	# If only HTML::Template::Expr were standard.
	$subvar->{isDelete} = ($subvar->{action} eq 'trashed');
	$subvar->{isEdit} = ($subvar->{action} eq 'edited');
	$subvar->{isProtect} = ($subvar->{action} eq 'protected');
	$subvar->{isUnprotect} = ($subvar->{action} eq 'unprotected');
	$subvar->{isCreateOrEdit} = $subvar->{isEdit};

	$subvar->{viewLatest} = $subvar->{url};
	$subvar->{editLatest} = $subvar->{url}.'?func=edit';

	if ($subvar->{isEdit}) {
		$subvar->{viewRevision} = $subvar->{url}.'?func=view;revision='.$subvar->{dateStamp};
		$subvar->{editRevision} = $subvar->{url}.'?func=edit;revision='.$subvar->{dateStamp};
	}

	if ($subvar->{isEdit} and ($self->session->db->quickArray("SELECT MIN(revisionDate) FROM assetData WHERE assetId = ?", [$subvar->{assetId}]))[0] == $subvar->{dateStamp}) {
		$subvar->{action} = 'created';
		$subvar->{isEdit} = 0;
		$subvar->{isCreate} = 1;
	}

	$subvar->{actionTaken} = $i18n->get('actionN '.$subvar->{action});
	$subvar->{actionTakenLowerCase} = lc $subvar->{actionN};

	return $subvar;
}

#-------------------------------------------------------------------
sub _templateSubvarOfPage {
	my $self = shift;
	my $page = shift;
	my $subvar = {};
	$page = WebGUI::Asset->newByDynamicClass($self->session, $page) unless ref $page;

	$subvar->{title} = $page->get('title');
	$subvar->{assetId} = $page->getId;
	$subvar->{viewLatest} = $page->getUrl;
	$subvar->{editLatest} = $page->getUrl('func=edit');
	return $subvar;
}

#-------------------------------------------------------------------
sub _templateSubvarsRefOfEdits {
	my $self = shift;
	my $edits = shift;
	my $time = shift;
	return [map { $self->_templateSubvarOfEdit($_, $time) } @$edits];
}

#-------------------------------------------------------------------
sub _templateSubvarsRefOfPages {
	my $self = shift;
	my $pages = shift;
	return [map { $self->_templateSubvarOfPage($_) } @$pages];
}

#-------------------------------------------------------------------
sub autolinkHtml {
	my $self = shift;
	my $html = shift;

	# TODO: ignore caching for now, but maybe do it later.
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
sub canAdminister {
	my $self = shift;
	my $userId = shift || $self->session->user->userId;
	my $user = WebGUI::User->new($self->session, $userId);
	return $self->canView($userId) && $user->isInGroup($self->get('groupToAdminister'));
}

#-------------------------------------------------------------------
sub canEditPages {
	my $self = shift;
	return $self->session->user->isInGroup($self->get("groupToEditPages")) || $self->canAdminister;
}

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

	     frontPageTemplateId => { fieldType => 'template',
				   namespace => 'WikiMaster_front',
				      defaultValue => 'WikiFrontTmpl000000001',
				      tab => 'display',
				      hoverHelp => $i18n->get('frontPageTemplateId hoverHelp'),
				      label => $i18n->get('frontPageTemplateId label') },

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

	     searchTemplateId => { fieldType => 'template',
				   namespace => 'WikiMaster_search',
				   defaultValue => 'WikiSearchTmpl00000001',
				   tab => 'display',
				   hoverHelp => $i18n->get('searchTemplateId hoverHelp'),
				   label => $i18n->get('searchTemplateId label') },

	     recentChangesCount => { fieldType => 'integer',
				     defaultValue => 50,
				     tab => 'display',
				     hoverHelp => $i18n->get('recentChangesCount hoverHelp'),
				     label => $i18n->get('recentChangesCount label') },

	     recentChangesCountFront => { fieldType => 'integer',
					  defaultValue => 10,
					  tab => 'display',
					  hoverHelp => $i18n->get('recentChangesCountFront hoverHelp'),
					  label => $i18n->get('recentChangesCountFront label') },
                approvalWorkflow =>{
                        fieldType=>"workflow",
                        defaultValue=>"pbworkflow000000000003",
                        type=>'WebGUI::VersionTag',
                        tab=>'security',
                        label=>$i18n->get('approval workflow'),
                        hoverHelp=>$i18n->get('approval workflow description'),
                        },    
		thumbnailSize => {
			fieldType => "integer",
			defaultValue => 0,
			tab => "display",
			label => $i18n->get("thumbnail size"),
			hoverHelp => $i18n->get("thumbnail size help")
			},
		maxImageSize => {
			fieldType => "integer",
			defaultValue => 0,
			tab => "display",
			label => $i18n->get("max image size"),
			hoverHelp => $i18n->get("max image size help")
			},
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
sub getContentLastModified {
	my $self = shift;
	my ($lastModified) = $self->session->db->quickArray("SELECT MAX(d.revisionDate) FROM assetData AS d INNER JOIN asset AS a ON a.assetId = d.assetId WHERE a.lineage LIKE CONCAT(?, '%')", [$self->get('lineage')]);
	return $lastModified;
}


#-------------------------------------------------------------------
sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView;
	$self->{_frontPageTemplate} =
	    WebGUI::Asset::Template->new($self->session, $self->get('frontPageTemplateId'));
	$self->{_frontPageTemplate}->prepare;
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
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
sub purge {
	my $self = shift;
	$self->session->db->write('DELETE FROM WikiMaster_titleIndex WHERE assetId = ?', [$self->getId]);
	return $self->SUPER::purge;
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

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $var = {};
	my $template = $self->{_frontPageTemplate};
	$var->{'description'} = $self->autolinkHtml($self->get('description'));
	$self->_appendSearchBoxVars($var);
	$self->_appendRecentChangesVars($var, [0, $self->get('recentChangesCountFront')]);
	$self->_appendFuncTemplateVars($var, qw/recentChanges/);
	return $self->processTemplate($var, undef, $template);
}


#-------------------------------------------------------------------
sub www_recentChanges {
	my $self = shift;
	my $template = WebGUI::Asset::Template->new($self->session, $self->get('recentChangesTemplateId'));
	$template->prepare;
	my $var = {};
	$var->{title} = WebGUI::International->new($self->session, 'Asset_WikiMaster')->get('recentChanges title');
	$self->_appendRecentChangesVars($var, [0, $self->get('recentChangesCount')]);
	return $self->processStyle($self->processTemplate($var, undef, $template));
}

#-------------------------------------------------------------------
sub www_search {
	my $self = shift;
	my $var = {};
	my $queryString = $self->session->form->process('query', 'text');
	$self->_appendSearchBoxVars($var, $queryString);
	if (length $queryString) {
		my $search = WebGUI::Search->new($self->session);
		$search->search({ keywords => $queryString,
				  lineage => [$self->get('lineage')],
				  classes => ['WebGUI::Asset::WikiPage'] });
		my $rs = $search->getResultSet;
		$self->_appendSearchResultVars($var, $rs);
	}
	$var->{title} = WebGUI::International->new($self->session, 'Asset_WikiMaster')->get('search title');
	my $template = WebGUI::Asset::Template->new($self->session, $self->get('searchTemplateId'));
	$template->prepare;
	return $self->processStyle($self->processTemplate($var, undef, $template));
}

1;
