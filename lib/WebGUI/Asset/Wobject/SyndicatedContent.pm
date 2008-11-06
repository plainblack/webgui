package WebGUI::Asset::Wobject::SyndicatedContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use base 'WebGUI::Asset::Wobject';
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

=head2 appendChoppedTemplateDescriptionVars ( var ) 

Appends shorter versions of the feeds description field to template vars returned.

=cut

sub appendChoppedDescriptionTemplateVars {
	my $item = shift;

        $item->{"descriptionFull"} = $item->{description};
        $item->{"descriptionFirst100words"} = $item->{"descriptionFull"};
        $item->{"descriptionFirst100words"} =~ s/(((\S+)\s+){100}).*/$1/s;
        $item->{"descriptionFirst75words"} = $item->{"descriptionFirst100words"};
        $item->{"descriptionFirst75words"} =~ s/(((\S+)\s+){75}).*/$1/s;
        $item->{"descriptionFirst50words"} = $item->{"descriptionFirst75words"};
        $item->{"descriptionFirst50words"} =~ s/(((\S+)\s+){50}).*/$1/s;
        $item->{"descriptionFirst25words"} = $item->{"descriptionFirst50words"};
        $item->{"descriptionFirst25words"} =~ s/(((\S+)\s+){25}).*/$1/s;
        $item->{"descriptionFirst10words"} = $item->{"descriptionFirst25words"};
        $item->{"descriptionFirst10words"} =~ s/(((\S+)\s+){10}).*/$1/s;
        $item->{"descriptionFirst2paragraphs"} = $item->{"descriptionFull"};
        $item->{"descriptionFirst2paragraphs"} =~ s/^((.*?\n){2}).*/$1/s;
        $item->{"descriptionFirstParagraph"} = $item->{"descriptionFirst2paragraphs"};
        $item->{"descriptionFirstParagraph"} =~ s/^(.*?\n).*/$1/s;
        $item->{"descriptionFirst4sentences"} = $item->{"descriptionFull"};
        $item->{"descriptionFirst4sentences"} =~ s/^((.*?\.){4}).*/$1/s;
        $item->{"descriptionFirst3sentences"} = $item->{"descriptionFirst4sentences"};
        $item->{"descriptionFirst3sentences"} =~ s/^((.*?\.){3}).*/$1/s;
        $item->{"descriptionFirst2sentences"} = $item->{"descriptionFirst3sentences"};
        $item->{"descriptionFirst2sentences"} =~ s/^((.*?\.){2}).*/$1/s;
        $item->{"descriptionFirstSentence"} = $item->{"descriptionFirst2sentences"};
        $item->{"descriptionFirstSentence"} =~ s/^(.*?\.).*/$1/s;
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

=head2 generateFeed ()

Combines all feeds into a single XML::FeedPP object.

=cut

sub generateFeed {
	my $self = shift;
	my $feed = XML::FeedPP::Atom->new();
	my $log = $self->session->log;
	
	# build one feed out of many
	foreach my $url (split("\n", $self->get('rssUrl'))) {
		$log->info("Processing FEED: ".$url);
		$url =~ s/^feed:/http:/;
		if ($self->get('processMacroInRssUrl')) {
			WebGUI::Macro::process($self->session, \$url);
		}
		my $cache = WebGUI::Cache->new($self->session, $url, "RSS");
		my $value = $cache->setByHTTP($url, $self->get("cacheTimeout"));
		eval { $feed->merge($value) };
		if (my $e = WebGUI::Error->caught()) {
			$log->error("Syndicated Content asset (".$self->getId.") has a bad feed URL (".$url."). Failed with ".$e->message);
		}
	}
	
	# build a new feed that matches the term the user is interested in
	if ($self->get('hasTerms') ne '') {
		my @terms = split /,\s*/, $self->get('hasTerms'); # get the list of terms
		my $termRegex = join("|", map quotemeta($_), @terms); # turn the terms into a regex string
		my @items = $feed->match_item(title=>qr/$termRegex/msi, description=>qr/$termRegex/msi);
		$feed->clear_item;
		foreach my $item (@items) {
			$feed->add_item($item);
		}
	}
	
	# sort them by date
	$feed->sort_item();
	
	# limit the feed to the maxium number of headlines
	$feed->limit_item($self->get('maxHeadlines'));
	
	# mark this asset as updated
	$self->update({lastModified=>time});
	
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
	$var{channel_title} = WebGUI::HTML::filter($feed->title, 'javascript');
	$var{channel_description} = WebGUI::HTML::filter($feed->description, 'javascript');
	$var{channel_date} = WebGUI::HTML::filter($feed->pubDate, 'javascript');
	$var{channel_copyright} = WebGUI::HTML::filter($feed->copyright, 'javascript');
	$var{channel_link} = WebGUI::HTML::filter($feed->link, 'javascript');
	my @image = $feed->image;
	$var{channel_image_url} = WebGUI::HTML::filter($image[0], 'javascript');
	$var{channel_image_title} = WebGUI::HTML::filter($image[1], 'javascript');
	$var{channel_image_link} = WebGUI::HTML::filter($image[2], 'javascript');
	$var{channel_image_description} = WebGUI::HTML::filter($image[3], 'javascript');
	$var{channel_image_width} = WebGUI::HTML::filter($image[4], 'javascript');
	$var{channel_image_height} = WebGUI::HTML::filter($image[5], 'javascript');
	foreach my $object (@items) {
		my %item;
        $item{title} = WebGUI::HTML::filter($object->title, 'javascript');
        $item{date} = WebGUI::HTML::filter($object->pubDate, 'javascript');
        $item{category} = WebGUI::HTML::filter($object->category, 'javascript');
        $item{author} = WebGUI::HTML::filter($object->author, 'javascript');
        $item{guid} = WebGUI::HTML::filter($object->guid, 'javascript');
        $item{link} = WebGUI::HTML::filter($object->link, 'javascript');
        $item{description} = WebGUI::HTML::filter($object->description, 'javascript');
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
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
	my $title = $self->get("title");
	$title =~ s/\"/&quot;/g;
	my $style = $self->session->style;
	$style->setLink($self->getUrl("func=viewRss"), { rel=>'alternate', type=>'application/rss+xml', title=>$title.' (RSS)' });
	$style->setLink($self->getUrl("func=viewRdf"), { rel=>'alternate', type=>'application/rdf+xml', title=>$title.' (RDF)' });
	$style->setLink($self->getUrl("func=viewAtom"), { rel=>'alternate', type=>'application/atom+xml', title=>$title.' (Atom)' });
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

	# try the cached version
	my $cache = WebGUI::Cache->new($self->session,"view_".$self->getId);
	my $out = $cache->get;
	return $out if ($out ne "");

	# generate from scratch
	my $feed = $self->generateFeed;
	$out = $self->processTemplate($self->getTemplateVariables($feed),undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
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
	$self->SUPER::www_view(@_);
}


#-------------------------------------------------------------------

=head2 www_viewAtom ( )

Emit an Atom 0.3 feed.

=cut

sub www_viewAtom {
	my $self = shift;
	my $feed = $self->generateFeed;
	my $atom = XML::FeedPP::Atom->new;
	$atom->merge($feed);
	$self->session->http->setMimeType('application/atom+xml');
	return $atom->to_string;
}

#-------------------------------------------------------------------

=head2 www_viewRdf ( )

Emit an RSS 1.0 / RDF feed. 

=cut

sub www_viewRdf {
	my $self = shift;
	my $feed = $self->generateFeed;
	my $rdf = XML::FeedPP::RDF->new;
	$rdf->merge($feed);
	$self->session->http->setMimeType('application/rdf+xml');
	return $rdf->to_string;
}

#-------------------------------------------------------------------

=head2 www_viewRss ( )

Emit an RSS 2.0 feed.

=cut

sub www_viewRss {
	my $self = shift;
	my $feed = $self->generateFeed;
	my $rss = XML::FeedPP::RSS->new;
	$rss->merge($feed);
	$self->session->http->setMimeType('application/rss+xml');
	return $rss->to_string;
}

#-------------------------------------------------------------------

=head2 www_viewRSS090 ( )

Deprecated. Use www_viewRss() instead.

=cut

sub www_viewRSS10 {
	my $self = shift;
	return $self->www_viewRdf;
}

#-------------------------------------------------------------------

=head2 www_viewRSS091 ( )

Deprecated. Use www_viewRss() instead.

=cut

sub www_viewRSS10 {
	my $self = shift;
	return $self->www_viewRdf;
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

sub www_viewRSS10 {
	my $self = shift;
	return $self->www_viewRdf;
}





1;

