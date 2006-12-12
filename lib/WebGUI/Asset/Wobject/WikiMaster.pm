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
sub appendMostPopular {
	my $self = shift;
	my $var = shift;
	my $limit = shift || $self->get("mostPopularCount");
	my $rs = $self->session->db->read("select distinct(asset.assetId) from asset left join WikiPage on WikiPage.assetId=asset.assetId 
		where lineage like ? and lineage<>? and revisionDate = (select max(revisionDate) from WikiPage where assetId = asset.assetId)
		order by views desc limit ?", [$self->get("lineage").'%', $self->get("lineage"),  $limit]);
	while (my ($id) = $rs->array) {
		my $asset = WebGUI::Asset->new($self->session, $id, "WebGUI::Asset::WikiPage");
		push(@{$var->{mostPopular}}, {
			title=>$asset->getTitle,
			url=>$asset->getUrl,
			});
	}
}

#-------------------------------------------------------------------
sub appendRecentChanges {
	my $self = shift;
	my $var = shift;
	my $limit = shift || $self->get("recentChangesCount");
	my $rs = $self->session->db->read("select asset.assetId, revisionDate from assetData left join asset on assetData.assetId=asset.assetId where
		lineage like ? and lineage<>? order by revisionDate desc limit ?", [$self->get("lineage").'%', $self->get("lineage"), $self->get("recentChangesCount")]);
	while (my ($id, $version) = $rs->array) {
		my $asset = WebGUI::Asset->new($self->session, $id, "WebGUI::Asset::WikiPage", $version);
		my $user = WebGUI::User->new($self->session, $asset->get("actionTakenBy"));
		push(@{$var->{recentChanges}}, {
			title=>$asset->getTitle,
			url=>$asset->getUrl,
			actionTaken=>$asset->get("actionTaken"),
			username=>$user->username,
			date=>$self->session->datetime->epochToHuman($asset->get("revisionDate"))
			});
	}
}

#-------------------------------------------------------------------
sub appendSearchBoxVars {
	my $self = shift;
	my $var = shift;
	my $queryText = shift;
	my $submitText = WebGUI::International->new($self->session, 'Asset_WikiMaster')->get('searchLabel');
	$var->{'searchFormHeader'} = join '',
	    (WebGUI::Form::formHeader($self->session, { action => $self->getUrl}),
	     WebGUI::Form::hidden($self->session, { name => 'func', value => 'search' }));
	$var->{'searchQuery'} = WebGUI::Form::text($self->session, { name => 'query', value => $queryText });
	$var->{'searchSubmit'} = WebGUI::Form::submit($self->session, { value => $submitText });
	$var->{'searchFormFooter'} = WebGUI::Form::formFooter($self->session);
	return $self;
}

#-------------------------------------------------------------------
sub autolinkHtml {
	my $self = shift;
	my $html = shift;
	# TODO: ignore caching for now, but maybe do it later.
	my %mapping = $self->session->db->buildHash("SELECT LOWER(d.title), d.url FROM asset AS i INNER JOIN assetData AS d ON i.assetId = d.assetId WHERE i.parentId = ? and className='WebGUI::Asset::WikiPage'", [$self->getId]);
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
	return $self->session->user->isInGroup($self->get('groupToAdminister')) || $self->canEdit;
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
				   defaultValue => ['2'],
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

	     mostPopularTemplateId => { fieldType => 'template',
					  namespace => 'WikiMaster_mostPopular',
					  defaultValue => 'WikiMPTmpl000000000001',
					  tab => 'display',
					  hoverHelp => $i18n->get('mostPopularTemplateId hoverHelp'),
					  label => $i18n->get('mostPopularTemplateId label') },

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

	     pageEditTemplateId => { fieldType => 'template',
				   namespace => 'WikiPage_edit',
				   defaultValue => 'WikiPageEditTmpl000001',
				   tab => 'display',
				   hoverHelp => $i18n->get('pageEditTemplateId hoverHelp'),
				   label => $i18n->get('pageEditTemplateId label') },

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

	     mostPopularCount => { fieldType => 'integer',
				     defaultValue => 50,
				     tab => 'display',
				     hoverHelp => $i18n->get('mostPopularCount hoverHelp'),
				     label => $i18n->get('mostPopularCount label') },

	     mostPopularCountFront => { fieldType => 'integer',
					  defaultValue => 10,
					  tab => 'display',
					  hoverHelp => $i18n->get('mostPopularCountFront hoverHelp'),
					  label => $i18n->get('mostPopularCountFront label') },
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
sub view {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiMaster");
	my $var = {
		description => $self->autolinkHtml($self->get('description')),
		searchLabel=>$i18n->get("searchLabel"),	
		mostPopularUrl=>$self->getUrl("func=mostPopular"),
		mostPopularLabel=>$i18n->get("mostPopularLabel"),
		addPageLabel=>$i18n->get("addPageLabel"),
		addPageUrl=>$self->getUrl("func=add;class=WebGUI::Asset::WikiPage"),
		recentChangesUrl=>$self->getUrl("func=recentChanges"),
		recentChangesLabel=>$i18n->get("recentChangesLabel"),
		};
	my $template = $self->{_frontPageTemplate};
	$self->appendSearchBoxVars($var);
	$self->appendRecentChanges($var, $self->get('recentChangesCountFront'));
	$self->appendMostPopular($var, $self->get('mostPopularCountFront'));
	return $self->processTemplate($var, undef, $template);
}


#-------------------------------------------------------------------
sub www_mostPopular {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiMaster");
	my $var = {
		title => $i18n->get('mostPopularLabel'),
		recentChangesUrl=>$self->getUrl("func=recentChanges"),
		recentChangesLabel=>$i18n->get("recentChangesLabel"),
		wikiHomeLabel=>$i18n->get("wikiHomeLabel"),
		searchLabel=>$i18n->get("searchLabel"),	
		searchUrl=>$self->getUrl("func=search"),
		wikiHomeUrl=>$self->getUrl,
		};
	$self->appendMostPopular($var);
	return $self->processStyle($self->processTemplate($var, $self->get('mostPopularTemplateId')));
}

#-------------------------------------------------------------------
sub www_recentChanges {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiMaster");
	my $var = {
		title => $i18n->get('recentChangesLabel'),
		wikiHomeLabel=>$i18n->get("wikiHomeLabel"),
		searchLabel=>$i18n->get("searchLabel"),	
		searchUrl=>$self->getUrl("func=search"),
		mostPopularUrl=>$self->getUrl("func=mostPopular"),
		mostPopularLabel=>$i18n->get("mostPopularLabel"),
		wikiHomeUrl=>$self->getUrl,
		};
	$self->appendRecentChanges($var);
	return $self->processStyle($self->processTemplate($var, $self->get('recentChangesTemplateId')));
}

#-------------------------------------------------------------------
sub www_search {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiMaster");
	my $var = {
		resultsLabel=>$i18n->get("resultsLabel"),
		notWhatYouWanted=>$i18n->get("notWhatYouWantedLabel"),
		nothingFoundLabel=>$i18n->get("nothingFoundLabel"),
		addPageLabel=>$i18n->get("addPageLabel"),
		wikiHomeLabel=>$i18n->get("wikiHomeLabel"),
		searchLabel=>$i18n->get("searchLabel"),	
		recentChangesUrl=>$self->getUrl("func=recentChanges"),
		recentChangesLabel=>$i18n->get("recentChangesLabel"),
		mostPopularUrl=>$self->getUrl("func=mostPopular"),
		mostPopularLabel=>$i18n->get("mostPopularLabel"),
		wikiHomeUrl=>$self->getUrl,
		addPageUrl=>$self->getUrl("func=add;class=WebGUI::Asset::WikiPage"),
		};
	my $queryString = $self->session->form->process('query', 'text');
	$self->appendSearchBoxVars($var, $queryString);
	if (length $queryString) {
		my $search = WebGUI::Search->new($self->session);
		$search->search({ keywords => $queryString,
				  lineage => [$self->get('lineage')],
				  classes => ['WebGUI::Asset::WikiPage'] });
		my $rs = $search->getPaginatorResultSet;
		$rs->appendTemplateVars($var);
		my @results = ();
		foreach my $row (@{$rs->getPageData}) {
			$row->{url} = $self->session->url->gateway($row->{url});
			push @results, $row;
		}
		$var->{'searchResults'} = \@results;
		$var->{'performSearch'} = 1;
	}
	return $self->processStyle($self->processTemplate($var, $self->get('searchTemplateId')));
}

1;
