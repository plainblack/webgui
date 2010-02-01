package WebGUI::Asset::Wobject::WikiMaster;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Class::C3;
use base qw(WebGUI::AssetAspect::RssFeed WebGUI::Asset::Wobject);
use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use HTML::Parser;
use URI::Escape;

#-------------------------------------------------------------------

=head2 appendMostPopular ($var, [ $limit ])

=head3 $var

A hash reference of template variables.  An array reference containing the most popular wiki pages
in order of popularity.

=head3 $limit

If passed in, this will override the mostPopularCount set in the object.

=cut

sub appendMostPopular {
	my $self = shift;
	my $var = shift;
	my $limit = shift || $self->get("mostPopularCount");
	foreach my $asset (@{$self->getLineage(["children"],{returnObjects=>1, limit=>$limit, includeOnlyClasses=>["WebGUI::Asset::WikiPage"]})}) { 
		if (defined $asset) {
			push(@{$var->{mostPopular}}, {
				title=>$asset->getTitle,
				url=>$asset->getUrl,
				});
		} else {
			$self->session->errorHandler->error("Couldn't instanciate wikipage for master ".$self->getId);
		}
	}
}

#-------------------------------------------------------------------

=head2 appendRecentChanges ( $var [, $limit ] )

=head3 $var

A hash reference of template variables.  Template variables will be appended
to the hash ref.

=head3 $limit

If passed in, this will override the mostChangesCount set in the object.

=cut

sub appendRecentChanges {
	my $self = shift;
	my $var = shift;
	my $limit = shift || $self->get("recentChangesCount") || 50;
	my $revisions = $self->session->db->read("select asset.assetId, assetData.revisionDate, asset.className 
		from asset left join assetData using (assetId) where asset.parentId=? and asset.className
		like ? and status='approved' order by assetData.revisionDate desc limit ?", [$self->getId, 
		"WebGUI::Asset::WikiPage%", $limit]);
	while (my ($id, $version, $class) = $revisions->array) {
		my $asset = WebGUI::Asset->new($self->session, $id, $class, $version);
		unless (defined $asset) {
			$self->session->errorHandler->error("Asset $id $class $version could not be instanciated.");
			next;
		}
		my $user = WebGUI::User->new($self->session, $asset->get("actionTakenBy"));
		my $specialAction = '';
		my $isAvailable = 1;
		# no need to i18n cuz the other actions aren't
		if ($asset->get('state') =~ m/trash/) {
			$isAvailable = 0;
			$specialAction = 'Deleted';
		}
		elsif ($asset->get('state') =~ m/clipboard/) {
			$isAvailable = 0;
			$specialAction = 'Cut';
		}
		push(@{$var->{recentChanges}}, {
			title=>$asset->getTitle,
			url=>$asset->getUrl,
			restoreUrl=>$asset->getUrl("func=restoreWikiPage"),
			actionTaken=>$specialAction || $asset->get("actionTaken"),
			username=>$user->username,
			date=>$self->session->datetime->epochToHuman($asset->get("revisionDate")),
			isAvailable=>$isAvailable,
            assetId=>$id,
			});
	}
}

#-------------------------------------------------------------------

=head2 appendSearchBoxVars  ($var, $queryText)

Appends template variables for creating a search box to search the wiki.

=head3 $var

A hash reference of template variables.  The search box variables will be appended to this.

=head3 $queryText

Default value for the search box.

=cut

sub appendSearchBoxVars {
	my $self = shift;
	my $var = shift;
	my $queryText = shift;
	my $submitText = WebGUI::International->new($self->session, 'Asset_WikiMaster')->get('searchLabel');
	$var->{'searchFormHeader'} = join '',
	    (WebGUI::Form::formHeader($self->session, { action => $self->getUrl, method => 'GET', }),
	     WebGUI::Form::hidden($self->session, { name => 'func', value => 'search' }));
	$var->{'searchQuery'} = WebGUI::Form::text($self->session, { name => 'query', value => $queryText });
	$var->{'searchSubmit'} = WebGUI::Form::submit($self->session, { value => $submitText });
	$var->{'searchFormFooter'} = WebGUI::Form::formFooter($self->session);
	$var->{'canAddPages'} = $self->canEditPages();
	return $self;
}

#-------------------------------------------------------------------

=head2 autolinkHtml ($html, [options])

Scan HTML for words and phrases that match wiki titles, and automatically
link them to those wiki pages.  Returns the modified HTML.

=head3 $html

The HTML to scan.

=head3 options

Either a hashref, or a hash of options.

=head4 skipTitles

An array reference of titles that should not be autolinked.

=cut

sub autolinkHtml {
	my $self = shift;
	my $html = shift;
    # opts is always the last parameter, and a hash ref
    my %opts = ref $_[-1] eq 'HASH' ? %{pop @_} : ();
    $opts{skipTitles} ||= [];

    # LC all the skip titles once, for efficiency
    my @skipTitles = map { lc $_ } @{ $opts{skipTitles} };
    # TODO: ignore caching for now, but maybe do it later.
    # This query returns multiple entries for each asset, so we order by revisionDate and count on the hash to only have the
    # latest version.
    my %mapping = $self->session->db->buildHash("SELECT LOWER(d.title), d.url FROM asset AS i INNER JOIN assetData AS d ON i.assetId = d.assetId WHERE i.parentId = ? and className='WebGUI::Asset::WikiPage' and i.state='published' and d.status='approved' order by d.revisionDate ASC", [$self->getId]);
    TITLE: foreach my $title (keys %mapping) {
        my $url = delete $mapping{$title};
        ##isIn short circuits and is faster than grep and/or first
        next TITLE if isIn($title, @skipTitles);
        $mapping{$title} = $self->session->url->gateway($url);
    }   

	return $html unless %mapping;
    # sort by length so it prefers matching longer titles 
	my $matchString = join('|', map{quotemeta} sort {length($b) <=> length($a)} keys %mapping);
    my $regexp = qr/($matchString)/i;
	my @acc = ();
	my $in_a = 0;
	my $p = HTML::Parser->new;
	$p->case_sensitive(1);
	$p->marked_sections(1);
	$p->unbroken_text(1);
	$p->handler(start => sub { push @acc, $_[2]; if ($_[0] eq 'a') { $in_a++ } },
		    'tagname, attr, text');
	$p->handler(end => sub { push @acc, $_[2]; if ($_[0] eq 'a') { $in_a-- } },
		    'tagname, attr, text');
	$p->handler(text => sub {
			    my $text = $_[0];
			    unless ($in_a) {
                    $text =~ s{\&\#39\;}{\'}xms; # html entities for ' created by rich editor
                    $text =~ s{$regexp}{'<a href="' . $mapping{lc $1} . '">' . $1 . '</a>'}xmseg;
			    }
			    push @acc, $text;
		    }, 'text');
	$p->handler(default => sub { push @acc, $_[0] }, 'text');
	$p->parse($html);
	$p->eof;
	return join '', @acc;
}

#-------------------------------------------------------------------

=head2 canAdminister 

Returns true if the current user is in the groupToAdminister group, or the user can edit
this WikiMaster due to groupIdEdit or ownerUserId.

=cut

sub canAdminister {
	my $self = shift;
	return $self->session->user->isInGroup($self->get('groupToAdminister')) || $self->WebGUI::Asset::Wobject::canEdit;
}

#-------------------------------------------------------------------

=head2 canEdit ( )

Overriding canEdit method to check permissions correctly when someone is adding a wikipage.

=cut

sub canEdit {
    my $self = shift;
    my $form      = $self->session->form;
    my $addNew    = $form->process("func"              ) eq "add";
    my $editSave  = $form->process("assetId"           ) eq "new"
                 && $form->process("func"              ) eq "editSave"
                 && $form->process("class","className" ) eq "WebGUI::Asset::WikiPage";
    my $canEdit = ( ($addNew || $editSave) && $self->canEditPages )
               || $self->next::method();
    return $canEdit;
}

#-------------------------------------------------------------------

=head2 canEditPages 

Returns true is the current user is in the group that can edit pages, or if
they can administer the wiki (canAdminister).

=cut

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

	     richEditor => { fieldType => 'selectRichEditor',
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

	     byKeywordTemplateId => { fieldType => 'template',
					  namespace => 'WikiMaster_byKeyword',
					  defaultValue => 'WikiKeyword00000000001',
					  tab => 'display',
					  hoverHelp => $i18n->get('byKeywordTemplateId hoverHelp'),
					  label => $i18n->get('byKeywordTemplateId label') },

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
        allowAttachments => {
            fieldType       => "integer",
            defaultValue    => 0,
            tab             => "security",
            label           => $i18n->get("allow attachments"),
            hoverHelp       => $i18n->get("allow attachments help"),
            },
		useContentFilter =>{
                        fieldType=>"yesNo",
                        defaultValue=>1,
                        tab=>'display',
                        label=>$i18n->get('content filter'),
                        hoverHelp=>$i18n->get('content filter description'),
                        },
                filterCode =>{
                        fieldType=>"filterContent",
                        defaultValue=>'javascript',
                        tab=>'security',
                        label=>$i18n->get('filter code'),
                        hoverHelp=>$i18n->get('filter code description'),
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

        return $class->next::method($session, $definition);
}

#-------------------------------------------------------------------

=head2 getRssFeedItems ()

Returns an array reference of hash references. Each hash reference has a title,
description, link, and date field. The date field can be either an epoch date, an RFC 1123
date, or a ISO date in the format of YYYY-MM-DD HH:MM::SS. Optionally specify an
author, and a guid field.

=cut

sub getRssFeedItems {
    my $self        = shift;
    my $vars = {};
    $self->appendRecentChanges( $vars, $self->get('itemsPerFeed') );
    my $var = [];
    foreach my $item ( @{ $vars->{recentChanges} } ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $self->session, $item->{assetId} );
        push @{ $var }, {
            'link'          => $asset->getUrl,
            'guid'          => $item->{ 'assetId' } . $asset->get( 'revisionDate' ),
            'title'         => $asset->getTitle,
            'description'   => $item->{ 'actionTaken' },
            'date'          => $item->{ 'date' },
            'author'        => $item->{ 'username' },
        };
    }
    
    return $var;
}

#-------------------------------------------------------------------

=head2 prepareView 

Prepare the front page template.

=cut

sub prepareView {
	my $self = shift;
	$self->next::method;
	$self->{_frontPageTemplate} =
	    WebGUI::Asset::Template->new($self->session, $self->get('frontPageTemplateId'));
    if (!$self->{_frontPageTemplate}) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get('frontPageTemplateId'),
            assetId    => $self->getId,
        );
    }
	$self->{_frontPageTemplate}->prepare;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost 

Extend the master method to propagate view and edit permissions down to the wiki pages.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	my $groupsChanged =
	    (($self->session->form->process('groupIdView') ne $self->get('groupIdView'))
	     or ($self->session->form->process('groupIdEdit') ne $self->get('groupIdEdit')));
	my $ret = $self->next::method(@_);
	if ($groupsChanged) {
		foreach my $child (@{$self->getLineage(['children'], {returnObjects => 1})}) {
			$child->update({ groupIdView => $self->get('groupIdView'),
					 groupIdEdit => $self->get('groupIdEdit') });
		}
	}
	return $ret;
}

#-------------------------------------------------------------------

=head2 view 

Render the front page of the wiki.

=cut

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
		restoreLabel => $i18n->get("restoreLabel"),
		canAdminister => $self->canAdminister,
        keywordCloud => WebGUI::Keyword->new($self->session)->generateCloud({
            startAsset=>$self,
            displayFunc=>"byKeyword",
            }),
		};
	my $template = $self->{_frontPageTemplate};
	$self->appendSearchBoxVars($var);
	$self->appendRecentChanges($var, $self->get('recentChangesCountFront'));
	$self->appendMostPopular($var, $self->get('mostPopularCountFront'));
	return $self->processTemplate($var, undef, $template);
}


#-------------------------------------------------------------------

=head2 www_byKeyword 

Return search results that match the keyword from the form variable C<keyword>.

=cut

sub www_byKeyword {
    my $self = shift;
    my $keyword = $self->session->form->process("keyword");
    my @pages = ();
    my $p = WebGUI::Keyword->new($self->session)->getMatchingAssets({
        startAsset      => $self,
        keyword         => $keyword,   
        usePaginator    => 1,
        });
    $p->setBaseUrl($self->getUrl("func=byKeyword;keyword=".$keyword));
    foreach my $assetData (@{$p->getPageData}) {
        my $asset = WebGUI::Asset->newByDynamicClass($self->session, $assetData->{assetId});
        next unless defined $asset;
        push(@pages, {
            title   => $asset->getTitle,
            url     => $asset->getUrl,
            });
    }
    @pages = sort { lc($a->{title}) cmp lc($b->{title}) } @pages;
    my $var = {
        keyword => $keyword,
        pagesLoop => \@pages,
        };
    $p->appendTemplateVars($var);
	return $self->processStyle($self->processTemplate($var, $self->get('byKeywordTemplateId')));
}


#-------------------------------------------------------------------

=head2 www_mostPopular 

Render a templated page that lists the most popular wiki pages.

=cut

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

=head2 www_recentChanges 

Render a templated page that shows the most recently changed wiki pages.

=cut

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
		restoreLabel => $i18n->get("restoreLabel"),
		canAdminister => $self->canAdminister,
		wikiHomeUrl=>$self->getUrl,
		};
	$self->appendRecentChanges($var);
	return $self->processStyle($self->processTemplate($var, $self->get('recentChangesTemplateId')));
}

#-------------------------------------------------------------------

=head2 www_search 

Render a search form and process the contents, returning the results.

=cut

sub www_search {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_WikiMaster");
	my $queryString = $self->session->form->process('query', 'text');
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
		addPageUrl=>$self->getUrl("func=add;class=WebGUI::Asset::WikiPage;title=".$queryString),
		};
    if (defined $queryString) {
        $self->session->scratch->set('wikiSearchQueryString', $queryString);
    }
    else {
        $queryString = $self->session->scratch->get('wikiSearchQueryString');
    }
	$self->appendSearchBoxVars($var, $queryString);
	if (length $queryString) {
		my $search = WebGUI::Search->new($self->session);
		$search->search({ keywords => $queryString,
				  lineage => [$self->get('lineage')],
				  classes => ['WebGUI::Asset::WikiPage'] });
		my $rs = $search->getPaginatorResultSet($self->getUrl("func=search"));
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
