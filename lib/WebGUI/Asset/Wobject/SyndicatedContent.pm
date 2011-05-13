package WebGUI::Asset::Wobject::SyndicatedContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use HTML::Entities;
use WebGUI::Exception;
use WebGUI::HTML;
use WebGUI::International;
use LWP::UserAgent;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';

define assetName => ['assetName','Asset_SyndicatedContent'];
define icon      => 'syndicatedContent.gif';
define tableName => 'SyndicatedContent';
property cacheTimeout => (
                tab          => "display",
                fieldType    => "interval",
                default      => 3600,
                uiLevel      => 8,
                label        => ["cache timeout", 'Asset_SyndicatedContent'],
                hoverHelp    => ["cache timeout help", 'Asset_SyndicatedContent'],
         );
property templateId  => (
                tab          => "display",
                fieldType    => 'template',
                default      => 'PBtmpl0000000000000065',
                namespace    => 'SyndicatedContent',
                label        => [72, 'Asset_SyndicatedContent'],
                hoverHelp    => ['72 description', 'Asset_SyndicatedContent'],
         );
property rssUrl => (
                tab          => "properties",
                default      => undef,
                fieldType    => 'textarea',
                label        => [1, 'Asset_SyndicatedContent'],
                hoverHelp    => ['1 description', 'Asset_SyndicatedContent'],
         );
property processMacroInRssUrl => (
                tab          => "properties",
                default      => 0,
                fieldType    => 'yesNo',
                label        => ['process macros in rss url', 'Asset_SyndicatedContent'],
                hoverHelp    => ['process macros in rss url description', 'Asset_SyndicatedContent'],
         );
property maxHeadlines => (
                tab          => "display",
                fieldType    => 'integer',
                default      => 10,
                label        => [3, 'Asset_SyndicatedContent'],
                hoverHelp    => ['3 description', 'Asset_SyndicatedContent'],
         );
property hasTerms => (
                tab          => "properties",
                fieldType    => 'text',
                default      => '',
                label        => ['hasTermsLabel', 'Asset_SyndicatedContent'],
                hoverHelp    => ['hasTermsLabel description', 'Asset_SyndicatedContent'],
                maxlength    => 255,
         );
property sortItems => (
                tab             => 'properties',
                fieldType       => 'selectBox',
                default         => 'none',
                label           => ['sortItemsLabel', 'Asset_SyndicatedContent'],
                hoverHelp       => ['sortItemsLabel description', 'Asset_SyndicatedContent'],
                options         => \&_sortItems_options,
         );
sub _sortItems_options {
    my $session = shift->session;
	my $i18n    = WebGUI::International->new($session,'Asset_SyndicatedContent');
    tie my %o, 'Tie::IxHash', (
        none        => $i18n->get('no order'),
        feed        => $i18n->get('feed order'),
        pubDate_asc => $i18n->get('publication date ascending'),
        pubDate_des => $i18n->get('publication date descending'),
    );
    return \%o;
}
has '+uiLevel' => (
    default => 6,
);



with 'WebGUI::Role::Asset::RssFeed';
use WebGUI::Macro;
use XML::FeedPP;
use XML::FeedPP::MediaRSS;

=head1 NAME

Package WebGUI::Asset::Wobject::SyndicatedContent

=head1 DESCRIPTION

Displays items and channels from RSS/Atom/RDF feeds.

=head1 SYNOPSIS

use WebGUI::Asset::Wobject::SyndicatedWobject;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 generateFeed ()

Combines all feeds into a single XML::FeedPP object.

=cut

sub generateFeed {
	my $self    = shift;
    my $limit   = shift || $self->maxHeadlines;
    my $session = $self->session;
	my $log     = $session->log;
	my $cache   = $session->cache;
	my $sort    = $self->sortItems;

	my @opt   = (use_ixhash => 1) if $sort eq 'feed';
	my $feed  = XML::FeedPP::Atom->new(@opt);

	# build one feed out of many
    my $newlyCached = 0;
	foreach my $url (split(/\s+/, $self->rssUrl)) {
		$log->info("Processing FEED: ".$url);
		$url =~ s/^feed:/http:/;
		if ($self->processMacroInRssUrl) {
			WebGUI::Macro::process($self->session, \$url);
		}

            my $value = $cache->compute( $url, sub { 
                my $ua = LWP::UserAgent->new(
                    env_proxy       => 1,
                    agent           => "WebGUI/" . $WebGUI::VERSION,
                    timeout         => 30,
                );

                my $r = $ua->get( $url );
                if ( $r->is_error ) {
                    $session->log->warn( "Could not get syndicated content from '$url': " . $r->status_line );
                }
                else {
                    $newlyCached = 1;
                    return $r->decoded_content;
                }
            }, $self->cacheTimeout );

        eval {
            my $singleFeed = XML::FeedPP->new($value, utf8_flag => 1, -type => 'string', xml_deref => 1, @opt);
            $feed->merge_channel($singleFeed);
            $feed->merge_item($singleFeed);
        };
        if ($@) {
            $log->warn("Syndicated Content asset (".$self->getId.") has a bad feed URL (".$url."). Failed with ".$@);
        }
	}

	# build a new feed that matches the term the user is interested in
	if ($self->hasTerms ne '') {
		my @terms = split /,\s*/, $self->hasTerms; # get the list of terms
		my $termRegex = join("|", map quotemeta($_), @terms); # turn the terms into a regex string
		my @items =  $feed->match_item(title       => qr/$termRegex/msi);
		push @items, $feed->match_item(description => qr/$termRegex/msi);
        $feed->clear_item;
        ITEM: foreach my $item (@items) {
            $feed->add_item($item);
        }
	}

    my %seen = ();
    my @items = $feed->get_item;
    $feed->clear_item;
    ITEM: foreach my $item (@items) {
        my $key = join "\n", $item->link, $item->pubDate, $item->description, $item->title;
        next ITEM if $seen{$key}++;
        $feed->add_item($item);
    }

	# sort them by date and remove any duplicate from the OR based term matching above
    if ($sort =~ /^pubDate/) {
        $feed->sort_item();
    }
    if ($sort =~ /_asc$/) {
        my @items = $feed->get_item;
        $feed->clear_item;
        $feed->add_item($_) for (reverse @items);
    }

	# limit the feed to the maximum number of headlines (or the feed generator limit).
	$feed->limit_item($limit);

	# mark this asset as updated
	$self->update({}) if ($newlyCached);

	return $feed;
}

#-------------------------------------------------------------------

=head2 getRssFeedItems ()

Go through the items, and produce a new RSS feed for them so that the SC is an aggregator
and producer.

=cut

sub getRssFeedItems {
    my $self  = shift;
    my @items = ();
    foreach my $item ($self->generateFeed( $self->itemsPerFeed )->get_item) {
        my %feed_item = (
            title           => $item->title,
            description     => $item->description,
            pubDate         => $item->pubDate,
            category        => $item->category,
            author          => $item->author,
            guid            => $item->guid,
        );
        push @items, \%feed_item;
    }
    return \@items;
}

#-------------------------------------------------------------------

=head2 getTemplateVariables

Returns a hash reference of template variables.

=head3 feed

A reference to an XML::FeedPP object.

=cut

sub getTemplateVariables {
	my ($self, $feed) = @_;
	my $media = XML::FeedPP::MediaRSS->new($feed);
	my @items = $feed->get_item;
	my %var;
	$var{channel_title} = WebGUI::HTML::filter(scalar $feed->title, 'javascript');
	$var{channel_description} = WebGUI::HTML::filter(scalar($feed->description), 'javascript');
	$var{channel_date} = WebGUI::HTML::filter(scalar($feed->get_pubDate_epoch), 'javascript');
	$var{channel_copyright} = WebGUI::HTML::filter(scalar($feed->copyright), 'javascript');
	$var{channel_link} = WebGUI::HTML::filter(scalar $feed->link, 'javascript');
	my @image = $feed->image;
	$var{channel_image_url} = WebGUI::HTML::filter($image[0], 'javascript');
	$var{channel_image_title} = WebGUI::HTML::filter($image[1], 'javascript');
	$var{channel_image_link} = WebGUI::HTML::filter($image[2], 'javascript');
	$var{channel_image_description} = WebGUI::HTML::filter($image[3], 'javascript');
	$var{channel_image_width} = WebGUI::HTML::filter($image[4], 'javascript');
	$var{channel_image_height} = WebGUI::HTML::filter($image[5], 'javascript');
	foreach my $object (@items) {
		my %item;
		$item{media} = [ map { { %$_ } } $media->for_item($object) ];
        $item{title} = WebGUI::HTML::filter(scalar $object->title, 'javascript');
        $item{date} = WebGUI::HTML::filter(scalar $object->get_pubDate_epoch, 'javascript');
        $item{category} = WebGUI::HTML::filter(scalar $object->category, 'javascript');
        $item{author} = WebGUI::HTML::filter(scalar $object->author, 'javascript');
        $item{guid} = WebGUI::HTML::filter(scalar $object->guid, 'javascript');
        $item{link} = WebGUI::HTML::filter(scalar $object->link, 'javascript');
        my $description = WebGUI::HTML::filter(scalar($object->description), 'javascript');
        my $raw_description = WebGUI::HTML::filter($description, 'all');
        $raw_description =~ s/^\s+//s;
        $item{description} = defined $description ? $description : '';
        $item{descriptionFirst100words} = $raw_description;
        $item{descriptionFirst100words} =~ s/(((\S+)\s+){1,100}).*/$1/ms;
        $item{descriptionFirst75words} = $item{descriptionFirst100words};
        $item{descriptionFirst75words} =~ s/(((\S+)\s+){1,75}).*/$1/ms;
        $item{descriptionFirst50words} = $item{descriptionFirst75words};
        $item{descriptionFirst50words} =~ s/(((\S+)\s+){1,50}).*/$1/ms;
        $item{descriptionFirst25words} = $item{descriptionFirst50words};
        $item{descriptionFirst25words} =~ s/(((\S+)\s+){1,25}).*/$1/ms;
        $item{descriptionFirst10words} = $item{descriptionFirst25words};
        $item{descriptionFirst10words} =~ s/(((\S+)\s+){1,10}).*/$1/ms;
        if ($description =~ /<p>/) {
            my $html = $description;
            $html =~ tr/\n/ /s;
            my @paragraphs = map { "<p>".$_."</p>" } WebGUI::HTML::splitTag($html,3);
            $item{descriptionFirstParagraph}   = $paragraphs[0];
            $item{descriptionFirst2paragraphs} = join '', @paragraphs[0..1];
        }
        else {
            $item{descriptionFirst2paragraphs} = $item{description};
            $item{descriptionFirst2paragraphs} =~ s/^((.*?\n){2}).*/$1/s;
            $item{descriptionFirstParagraph} = $item{descriptionFirst2paragraphs};
            $item{descriptionFirstParagraph} =~ s/^(.*?\n).*/$1/s;
        }
        $item{descriptionFirst4sentences} = $raw_description;
        $item{descriptionFirst4sentences} =~ s/^((.*?\.){1,4}).*/$1/s;
        $item{descriptionFirst3sentences} = $item{descriptionFirst4sentences};
        $item{descriptionFirst3sentences} =~ s/^((.*?\.){1,3}).*/$1/s;
        $item{descriptionFirst2sentences} = $item{descriptionFirst3sentences};
        $item{descriptionFirst2sentences} =~ s/^((.*?\.){1,2}).*/$1/s;
        $item{descriptionFirstSentence} = $item{descriptionFirst2sentences};
        $item{descriptionFirstSentence} =~ s/^(.*?\.).*/$1/s;
		push @{$var{item_loop}}, \%item;
	}
	return \%var;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

around prepareView => sub {
    my $orig = shift;
    my $self = shift;
    $self->$orig();
    my $template = eval { WebGUI::Asset->newById($self->session, $self->templateId); };
    if (Exception::Class->caught()) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
};


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

override purgeCache => sub {
	my $self = shift;
    $self->session->cache->remove("view_".$self->getId);
	super();
};

#-------------------------------------------------------------------

=head2 view ( )

Returns the rendered output of the wobject.

=cut

sub view {
	my $self    = shift;
    my $session = $self->session;

	# try the cached version
	my $cache = $session->cache; 
	my $out = $cache->get("view_".$self->getId);
	return $out if ($out ne "" && !$session->isAdminOn);
    #return $out if $out;

	# generate from scratch
	my $feed = $self->generateFeed;
	$out = $self->processTemplate($self->getTemplateVariables($feed),undef,$self->{_viewTemplate});
	if (!$session->isAdminOn && $self->cacheTimeout > 10) {
		$cache->set("view_".$self->getId, $out, $self->cacheTimeout);
	}
	return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

override www_view => sub {
    my $self = shift;
    $self->session->http->setCacheControl($self->cacheTimeout);
    super();
};

__PACKAGE__->meta->make_immutable;
1;

