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
use Tie::IxHash;
use WebGUI::Cache;
use WebGUI::Exception;
use WebGUI::HTML;
use WebGUI::International;
use Class::C3;
use base qw(WebGUI::AssetAspect::RssFeed WebGUI::Asset::Wobject);
use WebGUI::Macro;
use XML::FeedPP;


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
				tab=>"display",
				fieldType=>'integer',
				defaultValue=>10,
				label=>$i18n->get(3),
                		hoverHelp=>$i18n->get('3 description')
				},
			hasTerms=>{
				tab=>"properties",
				fieldType=>'text',
				defaultValue=>'',
				label=>$i18n->get('hasTermsLabel'),
                		hoverHelp=>$i18n->get('hasTermsLabel description'),
                		maxlength=>255
				},
            sortItems => {
                tab             => 'properties',
                fieldType       => 'yesNo',
                defaultValue    => 1,
                label           => $i18n->get('sortItemsLabel'),
                hoverHelp       => $i18n->get('sortItemsLabel description'),
            },
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
        return $class->next::method($session, $definition);
}

#-------------------------------------------------------------------

=head2 generateFeed ()

Combines all feeds into a single XML::FeedPP object.

=cut

sub generateFeed {
	my $self = shift;
    my $limit = shift || $self->get('maxHeadlines');
	my $feed = XML::FeedPP::Atom->new();
	my $log = $self->session->log;

	# build one feed out of many
    my $newlyCached = 0;
	foreach my $url (split(/\s+/, $self->get('rssUrl'))) {
		$log->info("Processing FEED: ".$url);
		$url =~ s/^feed:/http:/;
		if ($self->get('processMacroInRssUrl')) {
			WebGUI::Macro::process($self->session, \$url);
		}
		my $cache = WebGUI::Cache->new($self->session, $url, "RSS");
		my $value = $cache->get;
		unless ($value) {
            $value = $cache->setByHTTP($url, $self->get("cacheTimeout"));
            $newlyCached = 1;
        }
        # if the content can be downgraded, it is either valid latin1 or didn't have
        # an HTTP Content-Encoding header.  In the second case, XML::FeedPP will take
        # care of any encoding specified in the XML prolog
        utf8::downgrade($value, 1);
        eval {
            my $singleFeed = XML::FeedPP->new($value, utf8_flag => 1, -type => 'string');
            $feed->merge_channel($singleFeed);
            $feed->merge_item($singleFeed);
        };
        if ($@) {
            $log->error("Syndicated Content asset (".$self->getId.") has a bad feed URL (".$url."). Failed with ".$@);
        }
	}


	# build a new feed that matches the term the user is interested in
	if ($self->get('hasTerms') ne '') {
		my @terms = split /,\s*/, $self->get('hasTerms'); # get the list of terms
		my $termRegex = join("|", map quotemeta($_), @terms); # turn the terms into a regex string
		my @items =  $feed->match_item(title       => qr/$termRegex/msi);
		push @items, $feed->match_item(description => qr/$termRegex/msi);
        $feed->clear_item;
        ITEM: foreach my $item (@items) {
            $feed->add_item($item);
        }
	}

    my %seen = {};
    my @items = $feed->get_item;
    $feed->clear_item;
    ITEM: foreach my $item (@items) {
        my $key = join "\n", $item->link, $item->pubDate, $item->description, $item->title;
        next ITEM if $seen{$key}++;
        $feed->add_item($item);
    }

	# sort them by date and remove any duplicate from the OR based term matching above
    if ($self->get('sortItems')) {
        $feed->sort_item();
    }

	# limit the feed to the maximum number of headlines (or the feed generator limit).
	$feed->limit_item($limit);

	# mark this asset as updated
	$self->update({}) if ($newlyCached);

	return $feed;
}

#-------------------------------------------------------------------

=head2 getFeed ()

Override the one in the parent...

=cut

sub getFeed {
    my $self = shift;
    my $feed = shift;
    foreach my $item ($self->generateFeed( $self->get('itemsPerFeed') )->get_item) {
        my $set_permalink_false = 0;
        my $new_item = $feed->add_item( $item );
        if (!$new_item->guid) {
            if ($new_item->link) {
                $new_item->guid( $new_item->link );
            } else {
                $new_item->guid( $self->session->id->generate );
                $set_permalink_false = 1;
            }
        }
        $new_item->guid( $new_item->guid, isPermaLink => 0 ) if $set_permalink_false;
    }
    $feed->title( $self->get('feedTitle') || $self->get('title') );
    $feed->description( $self->get('feedDescription') || $self->get('synopsis') );
    $feed->pubDate( $self->getContentLastModified );
    $feed->copyright( $self->get('feedCopyright') );
    $feed->link( $self->getUrl );
    # $feed->language( $lang );
    if ($self->get('feedImage')) {
        my $storage = WebGUI::Storage->get($self->session, $self->get('feedImage'));
        my @files = @{ $storage->getFiles };
        if (scalar @files) {
            $feed->image(
                $storage->getUrl( $files[0] ),
                $self->get('feedImageDescription') || $self->getTitle,
                $self->get('feedImageUrl') || $self->getUrl,
                $self->get('feedImageDescription') || $self->getTitle,
                ( $storage->getSizeInPixels( $files[0] ) ) # expands to width and height
            );
        }
    }
    return $feed;
}

#-------------------------------------------------------------------

=head2 getTemplateVariables

Returns a hash reference of template variables.

=head3 feed

A reference to an XML::FeedPP object.

=cut

sub getTemplateVariables {
	my ($self, $feed) = @_;
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
        $item{title} = WebGUI::HTML::filter(scalar $object->title, 'javascript');
        $item{date} = WebGUI::HTML::filter(scalar $object->get_pubDate_epoch, 'javascript');
        $item{category} = WebGUI::HTML::filter(scalar $object->category, 'javascript');
        $item{author} = WebGUI::HTML::filter(scalar $object->author, 'javascript');
        $item{guid} = WebGUI::HTML::filter(scalar $object->guid, 'javascript');
        $item{link} = WebGUI::HTML::filter(scalar $object->link, 'javascript');
        my $description = WebGUI::HTML::filter(scalar($object->description), 'javascript');
        $item{description} = defined $description ? $description : '';
        $item{descriptionFirst100words} = $item{description};
        $item{descriptionFirst100words} =~ s/(((\S+)\s+){100}).*/$1/s;
        $item{descriptionFirst75words} = $item{descriptionFirst100words};
        $item{descriptionFirst75words} =~ s/(((\S+)\s+){75}).*/$1/s;
        $item{descriptionFirst50words} = $item{descriptionFirst75words};
        $item{descriptionFirst50words} =~ s/(((\S+)\s+){50}).*/$1/s;
        $item{descriptionFirst25words} = $item{descriptionFirst50words};
        $item{descriptionFirst25words} =~ s/(((\S+)\s+){25}).*/$1/s;
        $item{descriptionFirst10words} = $item{descriptionFirst25words};
        $item{descriptionFirst10words} =~ s/(((\S+)\s+){10}).*/$1/s;
        $item{descriptionFirst2paragraphs} = $item{description};
        $item{descriptionFirst2paragraphs} =~ s/^((.*?\n){2}).*/$1/s;
        $item{descriptionFirstParagraph} = $item{descriptionFirst2paragraphs};
        $item{descriptionFirstParagraph} =~ s/^(.*?\n).*/$1/s;
        $item{descriptionFirst4sentences} = $item{description};
        $item{descriptionFirst4sentences} =~ s/^((.*?\.){4}).*/$1/s;
        $item{descriptionFirst3sentences} = $item{descriptionFirst4sentences};
        $item{descriptionFirst3sentences} =~ s/^((.*?\.){3}).*/$1/s;
        $item{descriptionFirst2sentences} = $item{descriptionFirst3sentences};
        $item{descriptionFirst2sentences} =~ s/^((.*?\.){2}).*/$1/s;
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

sub prepareView {
    my $self = shift;
    $self->next::method;
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->next::method;
}

#-------------------------------------------------------------------

=head2 view ( )

Returns the rendered output of the wobject.

=cut

sub view {
	my $self    = shift;
    my $session = $self->session;

	# try the cached version
	my $cache = WebGUI::Cache->new($session,"view_".$self->getId);
	my $out = $cache->get;
	return $out if ($out ne "" && !$session->var->isAdminOn);
    #return $out if $out;

	# generate from scratch
	my $feed = $self->generateFeed;
	$out = $self->processTemplate($self->getTemplateVariables($feed),undef,$self->{_viewTemplate});
	if (!$session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		$cache->set($out,$self->get("cacheTimeout"));
	}
	return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->get("cacheTimeout"));
	$self->next::method(@_);
}

#-------------------------------------------------------------------

=head2 www_viewRSS090 ( )

Deprecated. Use www_viewRss() instead.

=cut

sub www_viewRSS090 {
	my $self = shift;
	return $self->www_viewRss;
}

#-------------------------------------------------------------------

=head2 www_viewRSS091 ( )

Deprecated. Use www_viewRss() instead.

=cut

sub www_viewRSS091 {
	my $self = shift;
	return $self->www_viewRss;
}

#-------------------------------------------------------------------

=head2 www_viewRSS10 ( )

Deprecated. Use www_viewRdf() instead.

=cut

sub www_viewRSS10 {
	my $self = shift;
	return $self->www_viewRdf;
}

#-------------------------------------------------------------------

=head2 www_viewRSS20 ( )

Deprecated. Use www_viewRss() instead.

=cut

sub www_viewRSS20 {
	my $self = shift;
	return $self->www_viewRss;
}

1;

