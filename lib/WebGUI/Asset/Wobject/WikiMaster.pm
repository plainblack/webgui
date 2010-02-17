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

#use Class::C3;
#use base qw(
#    WebGUI::AssetAspect::Subscribable 
#    WebGUI::AssetAspect::RssFeed 
#    WebGUI::Asset::Wobject
#);
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
aspect assetName => ['assetName', 'Asset_RichEdit'];
aspect icon      => 'wikiMaster.gif';
aspect tableName => 'WikiMaster';

property groupToEditPages => (
            fieldType => 'group',
            default   => ['2'],
            tab       => 'security',
            hoverHelp => ['groupToEditPages hoverHelp', 'Asset_WikiMaster'],
            label     => ['groupToEditPages label', 'Asset_WikiMaster'],
       );

property groupToAdminister => (
            fieldType => 'group',
            default   => ['3'],
            tab       => 'security',
            hoverHelp => ['groupToAdminister hoverHelp', 'Asset_WikiMaster'],
            label     => ['groupToAdminister label', 'Asset_WikiMaster'],
       );

property richEditor => (
            fieldType => 'selectRichEditor',
            default   => 'PBrichedit000000000001',
            tab       => 'display',
            hoverHelp => ['richEditor hoverHelp', 'Asset_WikiMaster'],
            label     => ['richEditor label', 'Asset_WikiMaster'],
       );

property frontPageTemplateId => (
            fieldType => 'template',
            namespace => 'WikiMaster_front',
            default   => 'WikiFrontTmpl000000001',
            tab       => 'display',
            hoverHelp => ['frontPageTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['frontPageTemplateId label', 'Asset_WikiMaster'],
       );

property pageTemplateId => (
            fieldType => 'template',
            namespace => 'WikiPage',
            default   => 'WikiPageTmpl0000000001',
            tab       => 'display',
            hoverHelp => ['pageTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['pageTemplateId label', 'Asset_WikiMaster'],
       );

property pageHistoryTemplateId => (
            fieldType => 'template',
            namespace => 'WikiPage_pageHistory',
            default   => 'WikiPHTmpl000000000001',
            tab       => 'display',
            hoverHelp => ['pageHistoryTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['pageHistoryTemplateId label', 'Asset_WikiMaster'],
       );

property mostPopularTemplateId => (
            fieldType => 'template',
            namespace => 'WikiMaster_mostPopular',
            default   => 'WikiMPTmpl000000000001',
            tab       => 'display',
            hoverHelp => ['mostPopularTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['mostPopularTemplateId label', 'Asset_WikiMaster'],
       );
property recentChangesTemplateId => (
            fieldType => 'template',
            namespace => 'WikiMaster_recentChanges',
            default   => 'WikiRCTmpl000000000001',
            tab       => 'display',
            hoverHelp => ['recentChangesTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['recentChangesTemplateId label', 'Asset_WikiMaster'],
       );
property byKeywordTemplateId => (
            fieldType => 'template',
            namespace => 'WikiMaster_byKeyword',
            default   => 'WikiKeyword00000000001',
            tab       => 'display',
            hoverHelp => ['byKeywordTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['byKeywordTemplateId label', 'Asset_WikiMaster'],
       );
property searchTemplateId => (
            fieldType => 'template',
            namespace => 'WikiMaster_search',
            default   => 'WikiSearchTmpl00000001',
            tab       => 'display',
            hoverHelp => ['searchTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['searchTemplateId label', 'Asset_WikiMaster'],
       );

property pageEditTemplateId => ( fieldType => 'template',
            namespace => 'WikiPage_edit',
            default   => 'WikiPageEditTmpl000001',
            tab       => 'display',
            hoverHelp => ['pageEditTemplateId hoverHelp', 'Asset_WikiMaster'],
            label     => ['pageEditTemplateId label', 'Asset_WikiMaster'],
       );

property recentChangesCount => (
            fieldType => 'integer',
            default   => 50,
            tab       => 'display',
            hoverHelp => ['recentChangesCount hoverHelp', 'Asset_WikiMaster'],
            label     => ['recentChangesCount label', 'Asset_WikiMaster']
       );
property recentChangesCountFront => (
            fieldType => 'integer',
            default   => 10,
            tab       => 'display',
            hoverHelp => ['recentChangesCountFront hoverHelp', 'Asset_WikiMaster'],
            label     => ['recentChangesCountFront label', 'Asset_WikiMaster'],
       );
property mostPopularCount => (
            fieldType => 'integer',
            default   => 50,
            tab       => 'display',
            hoverHelp => ['mostPopularCount hoverHelp', 'Asset_WikiMaster'],
            label     => ['mostPopularCount label', 'Asset_WikiMaster'],
       );

property mostPopularCountFront => (
            fieldType => 'integer',
            default   => 10,
            tab       => 'display',
            hoverHelp => ['mostPopularCountFront hoverHelp', 'Asset_WikiMaster'],
            label     => ['mostPopularCountFront label', 'Asset_WikiMaster'],
       );
property approvalWorkflow => (
            fieldType => "workflow",
            default   => "pbworkflow000000000003",
            type      => 'WebGUI::VersionTag',
            tab       => 'security',
            label     => ['approval workflow', 'Asset_WikiMaster'],
            hoverHelp => ['approval workflow description', 'Asset_WikiMaster'],
         );    
property thumbnailSize => (
            fieldType => "integer",
            default   => 0,
            tab       => "display",
            label     => ["thumbnail size", 'Asset_WikiMaster'],
            hoverHelp => ["thumbnail size help", 'Asset_WikiMaster']
         );
property maxImageSize => (
            fieldType => "integer",
            default   => 0,
            tab       => "display",
            label     => ["max image size", 'Asset_WikiMaster'],
            hoverHelp => ["max image size help", 'Asset_WikiMaster']
         );
property allowAttachments => (
            fieldType  => "integer",
            default    => 0,
            tab        => "security",
            label      => ["allow attachments", 'Asset_WikiMaster'],
            hoverHelp  => ["allow attachments help", 'Asset_WikiMaster'],
         );
property useContentFilter => (
            fieldType => "yesNo",
            default   => 1,
            tab       => 'display',
            label     => ['content filter', 'Asset_WikiMaster'],
            hoverHelp => ['content filter description', 'Asset_WikiMaster'],
         );
property filterCode => (
            fieldType => "filterContent",
            default   => 'javascript',
            tab       => 'security',
            label     => ['filter code', 'Asset_WikiMaster'],
            hoverHelp => ['filter code description', 'Asset_WikiMaster'],
         );

use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use HTML::Parser;
use URI::Escape;

#-------------------------------------------------------------------

=head2 appendFeaturedPageVars ( var, asset )

Append the template variables to C<var> for the featured page C<asset>. Returns
the C<var> for convenience.

=cut

sub appendFeaturedPageVars {
    my ( $self, $var, $asset ) = @_;
    my $assetVar = $asset->getTemplateVars;
    for my $key ( keys %{$assetVar} ) {
        $var->{ 'featured_' . $key } = $assetVar->{$key};
    }
    return $var;
}

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
	my $limit = shift || $self->mostPopularCount;
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
	my $limit = shift || $self->recentChangesCount || 50;
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
		my $user = WebGUI::User->new($self->session, $asset->actionTakenBy);
		my $specialAction = '';
		my $isAvailable = 1;
		# no need to i18n cuz the other actions aren't
		if ($asset->state =~ m/trash/) {
			$isAvailable = 0;
			$specialAction = 'Deleted';
		}
		elsif ($asset->state =~ m/clipboard/) {
			$isAvailable = 0;
			$specialAction = 'Cut';
		}
		push(@{$var->{recentChanges}}, {
			title=>$asset->getTitle,
			url=>$asset->getUrl,
			restoreUrl=>$asset->getUrl("func=restoreWikiPage"),
			actionTaken=>$specialAction || $asset->actionTaken,
			username=>$user->username,
			date=>$self->session->datetime->epochToHuman($asset->revisionDate),
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
	    (WebGUI::Form::formHeader($self->session, { action => $self->getUrl}),
	     WebGUI::Form::hidden($self->session, { name => 'func', value => 'search' }));
	$var->{'searchQuery'} = WebGUI::Form::text($self->session, { name => 'query', value => $queryText });
	$var->{'searchSubmit'} = WebGUI::Form::submit($self->session, { value => $submitText });
	$var->{'searchFormFooter'} = WebGUI::Form::formFooter($self->session);
	$var->{'canAddPages'} = $self->canEditPages();
	return $self;
}

#-------------------------------------------------------------------

=head2 autolinkHtml ($html)

Scan HTML for words and phrases that match wiki titles, and automatically
link them to those wiki pages.  Returns the modified HTML.

=head3 $html

The HTML to scan.

=cut

sub autolinkHtml {
	my $self = shift;
	my $html = shift;
    # opts is always the last parameter, and a hash ref
    my %opts = ref $_[-1] eq 'HASH' ? %{pop @_} : ();
    my $skipTitles = $opts{skipTitles} || [];
    # TODO: ignore caching for now, but maybe do it later.
	my %mapping = $self->session->db->buildHash("SELECT LOWER(d.title), d.url FROM asset AS i INNER JOIN assetData AS d ON i.assetId = d.assetId WHERE i.parentId = ? and className='WebGUI::Asset::WikiPage' and i.state='published' and d.status='approved'", [$self->getId]);
	foreach my $key (keys %mapping) {
        if (grep {lc $_ eq $key} @$skipTitles) {
            delete $mapping{$key};
            next;
        }
        $key =~ s{\(}{\\\(}gxms; # escape parens
        $key =~ s{\)}{\\\)}gxms; # escape parens
		$mapping{$key} = $self->session->url->gateway($mapping{$key});
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
this WikiMaster.

=cut

sub canAdminister {
	my $self = shift;
	return $self->session->user->isInGroup($self->groupToAdminister) || $self->WebGUI::Asset::Wobject::canEdit;
}

#-------------------------------------------------------------------

=head2 canEdit ( )

Overriding canEdit method to check permissions correctly when someone is adding a wikipage

=cut

sub canEdit {
        my $self = shift;
        return (
                (
                        (
                                $self->session->form->process("func") eq "add" ||
                                (
                                        $self->session->form->process("assetId") eq "new" &&
                                        $self->session->form->process("func") eq "editSave" &&
                                        $self->session->form->process("class") eq "WebGUI::Asset::WikiPage"
                                )
                        ) &&
                        $self->canEditPages
                ) || # account for new posts
                $self->next::method()
        );
}

#-------------------------------------------------------------------

=head2 canEditPages 

Returns true is the current user is in the group that can edit page, or if
they can administer the wiki (canAdminister).

=cut

sub canEditPages {
	my $self = shift;
	return $self->session->user->isInGroup($self->groupToEditPages) || $self->canAdminister;
}

#-------------------------------------------------------------------

=head2 getFeaturedPageIds ( )

Get the asset IDs of the pages that are marked as Featured.

=cut

sub getFeaturedPageIds {
    my ( $self ) = @_;

    my $assetIds    = $self->getLineage( ['children'], {
        joinClass       => 'WebGUI::Asset::WikiPage',
        whereClause     => 'isFeatured = 1',
    } );
    
    return $assetIds;
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
    $self->appendRecentChanges( $vars, $self->itemsPerFeed );
    my $var = [];
    foreach my $item ( @{ $vars->{recentChanges} } ) {
        my $asset       = WebGUI::Asset->newById( $self->session, $item->{assetId} );
        push @{ $var }, {
            'link'          => $asset->getUrl,
            'guid'          => $item->{ 'assetId' } . $asset->revisionDate,
            'title'         => $asset->getTitle,
            'description'   => $item->{ 'actionTaken' },
            'date'          => $item->{ 'date' },
            'author'        => $item->{ 'username' },
        };
    }
    
    return $var;
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Get the common template variables for all views of the wiki.

=cut

sub getTemplateVars {
    my ( $self ) = @_;
    my $i18n    = WebGUI::International->new($self->session, "Asset_WikiMaster");
    my $var     = { %{$self->get},
        url                 => $self->getUrl,
        searchLabel         => $i18n->get("searchLabel"),	
        mostPopularUrl      => $self->getUrl("func=mostPopular"),
        mostPopularLabel    => $i18n->get("mostPopularLabel"),
        addPageLabel        => $i18n->get("addPageLabel"),
        addPageUrl          => $self->getUrl("func=add;class=WebGUI::Asset::WikiPage"),
        recentChangesUrl    => $self->getUrl("func=recentChanges"),
        recentChangesLabel  => $i18n->get("recentChangesLabel"),
        restoreLabel        => $i18n->get("restoreLabel"),
        canAdminister       => $self->canAdminister,
        isSubscribed        => $self->isSubscribed,
        subscribeUrl        => $self->getSubscribeUrl,
        unsubscribeUrl      => $self->getUnsubscribeUrl,
    };
    
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
	    WebGUI::Asset::Template->new($self->session, $self->frontPageTemplateId);
    if (!$self->{_frontPageTemplate}) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->frontPageTemplateId,
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
	    (($self->session->form->process('groupIdView') ne $self->groupIdView)
	     or ($self->session->form->process('groupIdEdit') ne $self->groupIdEdit));
	my $ret = $self->next::method(@_);
	if ($groupsChanged) {
		foreach my $child (@{$self->getLineage(['children'], {returnObjects => 1})}) {
			$child->update({ groupIdView => $self->groupIdView,
					 groupIdEdit => $self->groupIdEdit });
		}
	}
	return $ret;
}

#-------------------------------------------------------------------

=head2 shouldSkipNotification ( )

WikiMasters do not send notification

=cut

sub shouldSkipNotification {
    my ( $self ) = @_;
    return 1;
}

#-------------------------------------------------------------------

=head2 view 

Render the front page of the wiki.

=cut

sub view {
	my $self = shift;
    my $session = $self->session;
        my $var = $self->getTemplateVars;
        $var->{ description     } = $self->autolinkHtml( $var->{ description } );
        $var->{ keywordCloud } 
            = WebGUI::Keyword->new($self->session)->generateCloud({
                startAsset=>$self,
                displayFunc=>"byKeyword",
            });
	my $template = $self->{_frontPageTemplate};

    # Get a random featured page
    my $featuredIds = $self->getFeaturedPageIds;
    my $featuredId  = $featuredIds->[ int( rand @$featuredIds ) - 1 ]; 
    my $featured    = WebGUI::Asset->newById( $session, $featuredId );
    if ( $featured ) {
        $self->appendFeaturedPageVars( $var, $featured );
    }

	$self->appendSearchBoxVars($var);
	$self->appendRecentChanges($var, $self->recentChangesCountFront);
	$self->appendMostPopular($var, $self->mostPopularCountFront);
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
        my $asset = WebGUI::Asset->newById($self->session, $assetData->{assetId});
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
	return $self->processStyle($self->processTemplate($var, $self->byKeywordTemplateId));
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
	return $self->processStyle($self->processTemplate($var, $self->mostPopularTemplateId));
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
	return $self->processStyle($self->processTemplate($var, $self->recentChangesTemplateId));
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
				  lineage => [$self->lineage],
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
	return $self->processStyle($self->processTemplate($var, $self->searchTemplateId));
}

1;
