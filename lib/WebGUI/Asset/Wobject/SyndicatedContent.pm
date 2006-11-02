package WebGUI::Asset::Wobject::SyndicatedContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use HTML::Entities;
use strict;
use Storable;
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::Cache;
use WebGUI::HTMLForm;
use WebGUI::HTML;
use WebGUI::International;
use WebGUI::Asset::Wobject;
use WebGUI::Macro;
use XML::RSSLite;
use XML::RSS::Creator;
use LWP::UserAgent;
use POSIX qw/floor/;
my $hasEncode=1;
eval ' use Encode qw(from_to); '; $hasEncode=0 if $@;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 NAME

Package WebGUI::Asset::Wobject::SyndicatedContent

=head1 DESCRIPTION

Displays items and channels from RSS feeds.

=head1 SYNOPSIS

use WebGUI::Asset::Wobject::SyndicatedWobject;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
sub _constructRSS {
    my($self,$rssObject,$var)=@_;
    #They've chosen to emit this as an RSS feed, in one of the four flavors we support.
    $rssObject->channel(
			title=>$var->{'channel.title'} || $self->get('title'),
			link=>$self->session->url->page('',1),
			description=>$var->{'channel.description'} || ''
		       );
    foreach my $item (@{$var->{item_loop}}) {
	# I know this seems kludgy, but because XML::RSSLite parses
	# feeds loosely, sometimes it returns a data structure when it shouldn't.
	# So we're only pushing in attributes when they AREN'T a reference to 
	# a data structure.
	my %attributes;
	foreach my $attribute(keys %$item){
	    $attributes{$attribute}=$item->{$attribute} if (! ref($item->{$attribute}));
	}
	$rssObject->add_item(%attributes);
    }
}


#-------------------------------------------------------------------
sub _createRSSURLs {
	my $self=shift;
	my $var=shift;
	foreach({ver=>'1.0',param=>'10'},{ver=>'0.9',param=>'090'},{ver=>'0.91',param=>'091'},{ver=>'2.0',param=>'20'}){
	$var->{'rss.url.'.$_->{ver}}=$self->getUrl('func=viewRSS'.$_->{param});
	}
	$var->{'rss.url'}=$self->getUrl('func=viewRSS20');
}

#-------------------------------------------------------------------
sub _getMaxHeadlines {
	my $self = shift;
	return $self->get('maxHeadlines') || 1000000;
}

#-------------------------------------------------------------------
sub _getValidatedUrls {
	my $self = shift;
	my @urls = split(/\s+/,$self->getRssUrl);
	my @validatedUrls = ();
	foreach my $url (@urls) {
		push(@validatedUrls, $url) if ($url =~ m/^http/);
	}
	return @validatedUrls
}

#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
        my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	my $i18n = WebGUI::International->new($session,'Asset_SyndicatedContent');
	%properties = (
			cacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("cache timeout"),
				hoverHelp => $i18n->get("cache timeout help")
				},
			templateId =>{
				tab=>"display",
				fieldType=>'template',
				defaultValue=>'PBtmpl0000000000000065',
				namespace=>'SyndicatedContent',
               	 		label=>$i18n->get(72),
                		hoverHelp=>$i18n->get('72 description')
				},
			rssUrl=>{
				tab=>"properties",
				defaultValue=>undef,
				fieldType=>'textarea',
				label=>$i18n->get(1),
                		hoverHelp=>$i18n->get('1 description')
				},
			processMacroInRssUrl=>{
				tab=>"properties",
				defaultValue=>0,
				fieldType=>'yesNo',
				label=>$i18n->get('process macros in rss url'),
				hoverHelp=>$i18n->get('process macros in rss url description'),
				},
                        maxHeadlines=>{
				tab=>"properties",
				fieldType=>'integer',
				defaultValue=>10,
				label=>$i18n->get(3),
                		hoverHelp=>$i18n->get('3 description')
				},
			displayMode=>{
				tab=>"display",
				fieldType=>'selectBox',
				defaultValue=>'interleaved',
				options=>{
                        		'interleaved'=>$i18n->get('interleaved'),
                        		'grouped'=>$i18n->get('grouped'),
                         		},
                		sortByValue=>1,
                		label=>$i18n->get('displayModeLabel'),
                		hoverHelp=>$i18n->get('displayModeLabel description'),
                		subtext=>$i18n->get('displayModeSubtext')
				},
			hasTerms=>{
				tab=>"properties",
				fieldType=>'text',
				defaultValue=>'',
				label=>$i18n->get('hasTermsLabel'),
                		hoverHelp=>$i18n->get('hasTermsLabel description'),
                		maxlength=>255
				}
		);
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel=>6,
		autoGenerateForms=>1,
		icon=>'syndicatedContent.gif',
                tableName=>'SyndicatedContent',
                className=>'WebGUI::Asset::Wobject::SyndicatedContent',
                properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}





#-------------------------------------------------------------------
# strip all html tags from the given data structure.  This is important to
# prevent cross site scripting attacks
#my $_stripped_html = {};

sub _strip_html {
        #my ($data) = @_;

        if (ref($_[0]) eq 'HASH') {
                keys(%{$_[0]});
                while (my ($name, $val) = each (%{$_[0]})) {
                        $_[0]->{$name} = _strip_html($val);
                }
        } elsif (ref($_[0]) eq 'ARRAY') {
                for (my $i = 0; $i < @{$_[0]}; $i++) {
                        $_[0]->[$i] = _strip_html($_[0]->[$i]);
                }
        } else {
                if ($_[0]) {
                        $_[0] =~ s/\&lt;/</g;
                        $_[0] =~ s/\&gt;/>/g;
                        $_[0] = WebGUI::HTML::filter($_[0], 'all');
			##Unencode double encoded entities.  This is usually done
			##by passing XML::RSSLite an already encoded entity.
			$_[0] =~ s/\&amp;(?=(#[0-9]+|#x[0-9a-fA-F]+|\w+);)/&/g;
                }
        }

        return $_[0];
}

#-------------------------------------------------------------------
# horrible kludge to find the channel or item record
# in the varying kinds of rss structures returned by RSSLite

sub _find_record {
        my ($data, $regex) = @_;

        if (ref($data) eq 'HASH') {
                # reset the hash before calling each()
                keys(%{$data});
                while (my ($name, $val) = each(%{$data})) {
                        if ($name =~ $_[1]) {
                                if ((((ref($val) eq 'HASH') && 
                                      ($val->{link} || $val->{title} || 
                                       $val->{description})) ||
                                     ((ref($val) eq 'ARRAY') && @{$val} && 
                                      (ref($val->[0]) eq 'HASH') &&
                                      ($val->[0]->{link} || 
                                       $val->[0]->{title} ||
                                       $val->[0]->{description})))) {
                                        return $val;
                                }
                        }
                        if (my $record = _find_record($val, $regex)) {
                                return $record;
                        }
                }
        }
        
        return undef;
}

#-------------------------------------------------------------------
# Copy the guid field to the link field if the guid looks like a link.
# This is a kludge that gets around the fact that some folks use the link
# field as the link to the story while others use it as the link
# to the story about which the story is written.  The webuig templates seem
# to assume the former, so we should use the guid instead of the link, b/c
# the guid, if it is a link, always means the former.
# Also copy the first few words of the description into the title if 
# there is no title

sub _normalize_items {
        #my ($items) = @_;

        # max number of words to take from description to fill in an empty 
        # title
        my $max_words = 10;

        for my $item (@{$_[0]}) {
                if ($item->{guid} && ($item->{guid} =~ /^http:\/\//i)) {
                        $item->{link} = $item->{guid};
                }
                if (!$item->{title}) {
                        my @description_words = split(/\s/, $item->{description});
                        if (@description_words <= $max_words) {
                                $item->{title} = $item->{description};
                        } else {
                                $item->{title} = join(' ', @description_words[0..$max_words-1]) . 
                                  ' ...';
                        }
                }

                # IE doesn't recognize &apos;
                $item->{title} =~ s/&apos;/\'/;
                $item->{description} =~ s/&apos;/\'/;
        }
}

#-------------------------------------------------------------------
sub _get_rss_data {
	my $session = shift;
        my $url = shift;
	my $cache = WebGUI::Cache->new($session,'url:' . $url, 'RSS');
        my $rss_serial = $cache->get;
        my $rss = {};
        if ($rss_serial) {
                $rss = Storable::thaw($rss_serial);
        } else {
                my $ua = LWP::UserAgent->new(timeout => 5);
		$ua->env_proxy;
                my $response = $ua->get($url);
                if (!$response->is_success()) {
                        $session->errorHandler->warn("Error retrieving url '$url': " . 
                             $response->status_line());
                        return undef;
                }
                my $xml = $response->content();

		# Approximate with current time if we don't have a Last-Modified
		# header coming from the RSS source.
		my $http_lm = $response->last_modified;
		my $last_modified = defined($http_lm)? $http_lm : time;

		# XML::RSSLite does not handle <![CDATA[ ]]> so:
                $xml =~ s/<!\[CDATA\[(.*?)\]\]>/$1/sg;
 
		# Convert encoding if needed / Perl 5.8.0 or up required.
		if ($] >= 5.008 && $hasEncode) {
			$xml =~ /<\?xml.*?encoding=['"](\S+)['"]/i;
			my $xmlEncoding = $1 || 'utf8';
			my $encoding = 'utf8';
			if (lc($xmlEncoding) ne lc($encoding)) {
				eval {	from_to($xml, $xmlEncoding, $encoding) };
				$session->errorHandler->warn($@) if ($@);
			}
				
		}

                my $rss_lite = {};
                eval {
                        XML::RSSLite::parseXML($rss_lite, \$xml);
                };
                if ($@) {
                        $session->errorHandler->warn("error parsing rss for url $url :".$@);
			#Returning undef on a parse failure is a change from previous behaviour,
			#but it SHOULDN'T have a major effect.
			return undef;
                }

                # make sure that the {channel} points to the channel 
                # description record and that {items} points to the list 
                # of items.  without this voodoo, different versions of 
                # rss return the data in different places in the data 
                # structure.

                $rss_lite = {channel => $rss_lite};
                if (!($rss->{channel} = 
                      _find_record($rss_lite, qr/^channel$/))) {
                        $session->errorHandler->warn("unable to find channel info for url $url");
                }
                if (!($rss->{items} = _find_record($rss_lite, qr/^items?$/))) {
                        $session->errorHandler->warn("unable to find item info for url $url");
                        $rss->{items} = [];
		}

                _strip_html($rss);
                 $rss->{items} = [ $rss->{items} ] unless (ref $rss->{items} eq 'ARRAY');

                _normalize_items($rss->{items});

		#Assign dates "globally" rather than when seen in a viewed feed.
		#This is important because we can "filter" now and want to ensure we keep order
		#correctly as new items appear.
		_assign_rss_dates($session, $rss->{items});

		# Store last-modified date as well.
		$rss->{last_modified} = $last_modified;

                #Default to an hour timeout
                $cache->set(Storable::freeze($rss), 3600);
        }

        return $rss;
}

#-------------------------------------------------------------------
# rss items don't have a standard date, so timestamp them the first time
# we see them and use that timestamp as the date.  Periodically nuke the
# whole database to keep the thing from growing too large

sub _assign_rss_dates {
	my $session = shift;
        my ($items) = @_;

        for my $item (@{$items}) {
                my $key = 'dates:' . ($item->{guid} || $item->{title} || 
                                      $item->{description} || $item->{link});
                my $cache = WebGUI::Cache->new($session,$key, 'RSS');
                if (my $date = $cache->get()) {
                        $item->{date} = $date;
                } else {
                        $item->{date} =$session->datetime->time();
                        $cache->set($item->{date}, '1 year');
                }
        }
	@{$items} = sort { $b->{date} <=> $a->{date} } @{$items};
  }

#-------------------------------------------------------------------
# $items is the hashref to put items into.
# $rss_feeds is an arrayref of all the feeds in this wobject
# The only difference between an "interleaved" feed and a grouped feed
# is the order the items are output.

sub _create_grouped_items{
	my($items,$rss_feeds,$maxHeadlines,$hasTermsRegex)=@_;

	_create_interleaved_items($items,$rss_feeds,$maxHeadlines,$hasTermsRegex);

	@$items=sort{$a->{'site_title'} cmp $b->{'site_title'}} @$items;

	#Loop through the items and output the "site_
	my $siteTitleTracker;
	foreach (@$items) {
		if ($siteTitleTracker ne $_->{site_title}) {
			$_->{new_rss_site} = 1;
		}
		$siteTitleTracker = $_->{site_title};
	}
}


#-------------------------------------------------------------------
# Loop through the feeds for this wobject 
# and push in the items in "interleaved mode"
# No need to return because we're doing everything by reference.

sub _create_interleaved_items {
    my($items,$rss_feeds,$maxHeadlines,$hasTermsRegex)=@_;
    my $items_remain = 1;
    while((@$items < $maxHeadlines) && $items_remain){
	foreach my $rss(@$rss_feeds){
	    $items_remain=0;
	    if(defined $rss->{items}
	       && @$items < $maxHeadlines
	       && (my $item = shift @{$rss->{items}})
	      ){
		$item->{site_title}=$rss->{channel}->{title};
		$item->{site_link}=$rss->{channel}->{link};
		if(! $hasTermsRegex || _check_hasTerms($item,$hasTermsRegex)){
		    push @{$items},$item;
		}
		if (@{$rss->{items}}) {
		    $items_remain = 1;
		}
	    }
	}
    }
}

#-------------------------------------------------------------------
# Uses the regex constructed in _get_items (with the terms defaulting to OR)
# to see if the title or description associated with this item match the kinds
# of items we're looking for.
#

sub _check_hasTerms{
	my($item,$hasTermsRegex)=@_;
	my $to_check=$item->{title}.$item->{description};
	if ($to_check =~ /$hasTermsRegex/gism) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------
sub _make_regex{
	my $terms = shift;
	my @terms = split(/,/,$terms);
	return join('|',@terms);
}


#-------------------------------------------------------------------
# So- We're going to manage an "aggregate cache" that represents
# the rendering of the cumulative feeds in a Syndicated Wobject,
# but let each feed "fend for itself" based on URL in the cache.
#
# This means we can set up the hourly task to get and cache each
# individual feed WITHOUT having to re-request (undoubtedly the slowest
# part of every RSS parsing action is the network traffic) each feed 
# when we re-render each aggregrate representation.
#
# If, however, a feed expires between hourly tasks, it will be re-requested and
# parsed per the usual. BUT, if a feed ever goes un-requested for more than an hour,
# then it's retrieval schedule will be taken over by the hourly task, and we'll
# be pre-seeding the RSS object cache automatically.
#
# Having the caching set up this way means we can re-use the same raw feed all over the site without
# having each wobject request it separately, ASSUMING the URL is the same.
#
# All the values that may have an effect on the composition of items
# are included in the cache key for the aggregate representation.

sub _get_items {
	my $self = shift;
	my $urls = shift;
	my $maxHeadlines = shift || $self->getValue('maxHeadlines');
	my $displayMode=$self->getValue('displayMode');

	my $hasTermsRegex=_make_regex($self->getValue('hasTerms'));

	# Cache format changes:
	#   - aggregate: $items
	#   - aggregate2 (2006-08-26): [$items, \@rss_feeds]

	my $key=join(':',('aggregate2', $displayMode,$hasTermsRegex,$maxHeadlines,$self->getRssUrl));

        my $cache = WebGUI::Cache->new($self->session,$key, 'RSS');
        my $cached = Storable::thaw($cache->get());
	my ($items, @rss_feeds);

	if ($cached) {
		$items = $cached->[0];
		@rss_feeds = @{$cached->[1]};
	} else {
                $items = [];

                for my $url (@{$urls}) {
		    my $rss_info=_get_rss_data($self->session,$url);
		    push(@rss_feeds, $rss_info) if(defined $rss_info);
                }

		# deal with the fact that we may never get valid data

		if (scalar(@rss_feeds) < 1) {
			return ({}, []);
		}

		#Sort feeds in order by channel title.
		#@rss_feeds=sort{$a->{channel}->{title} cmp $b->{channel}->{title}} @rss_feeds;
				
                if ($displayMode eq 'grouped') {
		    _create_grouped_items($items,\@rss_feeds,$maxHeadlines,$hasTermsRegex);
		} else {
		    _create_interleaved_items($items,\@rss_feeds,$maxHeadlines,$hasTermsRegex);
		}

                #@{$items} = sort { $b->{date} <=> $a->{date} } @{$items};

                $cache->set(Storable::freeze([$items, \@rss_feeds]), 3600);
	}

	#So return the item loop and the first RSS feed, because 
	#when we're parsing a single feed we can use that feed's title and 
	#description for channel.title, channel.link, and channel.description
        return ($items,\@rss_feeds);
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
	my $i18n = WebGUI::International->new($self->session,'Asset_SyndicatedContent');
	my $rssFeedSuffix=$i18n->get('RSS Feed Title Suffix');
	my $title = $self->get("title")." ".$rssFeedSuffix;
	$title =~ s/\"/&quot;/g;
	$self->session->style->setLink($self->getUrl("func=viewRSS20"), { rel=>'alternate', type=>'application/rss+xml', title=>$title });
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 view ( )

Returns the rendered output of the wobject.

=cut

sub view {
	my $self = shift;
	my $rssFlavor = shift;
	if ($rssFlavor eq "" && !$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
        my $maxHeadlines = $self->_getMaxHeadlines;
	my @validatedUrls = $self->_getValidatedUrls;
	return $self->processTemplate({},$self->get('templateId')) unless (scalar(@validatedUrls));
	my $title=$self->get('title');

	#We came into this subroutine as
	my $rssObject=($rssFlavor) ? XML::RSS::Creator->new(version=>$rssFlavor) : undef;

        my %var;
	
	my($item_loop,$rss_feeds)=$self->_get_items(\@validatedUrls, $maxHeadlines);

	if (scalar(@$rss_feeds) < 1) {
		return $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	}

	if(@$rss_feeds > 1){
	    #If there is more than one (valid) feed in this wobject, put in the wobject description info.
	    $var{'channel.title'} = $title;
	    $var{'channel.description'} = $self->get('description');
	} else {
	    #One feed. Put in the info from the feed.
	    $var{'channel.title'} = $rss_feeds->[0]->{channel}->{title} || $title;
	    $var{'channel.link'} = $rss_feeds->[0]->{channel}->{link};
	    $var{'channel.description'} = $rss_feeds->[0]->{channel}->{description};
	}
	$self->_createRSSURLs(\%var);
        $var{item_loop} = $item_loop;

	if ($rssObject) {
	    $self->_constructRSS($rssObject,\%var);
	    my $rss=$rssObject->as_string;
	    $self->session->http->setMimeType('text/xml');

	    #Looks like a kludge, but what this does is put in the proper
	    #XSLT stylesheet so the RSS doesn't look like total ass.
	    my $siteURL=$self->session->url->getSiteURL().$self->session->url->gateway();
	    $rss=~s|<\?xml version="1\.0" encoding="UTF\-8"\?>|<\?xml version="1\.0" encoding="UTF\-8"\?>\n<?xml\-stylesheet type="text/xsl" href="${siteURL}xslt/rss$rssFlavor.xsl"\?>\n|;
	    return $rss;

	} else {
       		my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
		if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
			WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
		}
       		return $out;
	}

}

#-------------------------------------------------------------------
=head2 getRssUrl

Get the RSS URL and process macros if we're supposed to.

=cut

sub getRssUrl {
	my $self = shift;
	my $value = $self->get("rssUrl");
	WebGUI::Macro::process($self->session,\$value) if $self->get("processMacroInRssUrl");
	return $value;	
}

#-------------------------------------------------------------------

=head2 getContentLastModified ( )

Derive the last-modified date from the revisionDate of the object and from the dates of the RSS feeds.

=cut

sub getContentLastModified {
	# Buggo, is this too expensive?  Do we really want to do this every time?
	# But how else are we supposed to get a reasonable last-modified date?
	# Maybe just approximate... ?
	my $self = shift;

	my $maxHeadlines = $self->_getMaxHeadlines;
	my @validatedUrls = $self->_getValidatedUrls;
	my ($item_loop, $rss_feeds) = $self->_get_items(\@validatedUrls, $maxHeadlines);
	my $mtime = $self->get("revisionDate");

	foreach my $rss (@$rss_feeds) {
		next unless defined $rss->{last_modified};
		$mtime = $rss->{last_modified} if $rss->{last_modified} > $mtime;
	}

	return $mtime;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->get("cacheTimeout"));
	$self->SUPER::www_view(@_);
}

#-------------------------------------------------------------------

=head2 www_viewRSS090 ( )

Emit an RSS 0.9 feed.

=cut

sub www_viewRSS090 {
    my $self=shift;
    return $self->view('0.9');
}


#-------------------------------------------------------------------

=head2 www_viewRSS091 ( )

Emit an RSS 0.91 feed.

=cut

sub www_viewRSS091 {
	my $self=shift;
	return $self->view('0.91');
}


#-------------------------------------------------------------------

=head2 www_viewRSS10 ( )

Emit an RSS 1.0 feed.

=cut

sub www_viewRSS10 {
	my $self=shift;
	return $self->view('1.0');
}


#-------------------------------------------------------------------

=head2 www_viewRSS20 ( )

Emit an RSS 2.0 feed.

=cut

sub www_viewRSS20 {
	my $self=shift;
	return $self->view('2.0');
}


1;

