package WebGUI::Content::SiteIndex;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset;
use XML::Simple;

=head1 NAME

Package WebGUI::Content::SiteIndex

=head1 DESCRIPTION

A content handler that displays a google site index making it easier and faster
for search engines to index a website.

=head1 SYNOPSIS

 use WebGUI::Content::SiteIndex;
 my $output = WebGUI::Content::SiteIndex::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my $session = shift;
    
    my $p = $session->url->page();
    unless ($p =~ m/sitemap\.xml$/i) {
        return undef;
    }
    
    my $pages  = WebGUI::Asset->getRoot($session)->getLineage(["self","descendants"],{
        returnObjects      => 1,
        includeOnlyClasses => ["WebGUI::Asset::Wobject::Layout"],
        whereClause        => "assetData.groupIdView = 7",
        limit              => 20000
    });
    
    
    my $url          = [];
    foreach my $page (@{$pages}) {
        push(@{$url},{
            loc     => $session->url->getSiteURL().formatXML($page->getUrl),
            lastmod => $session->datetime->epochToSet($page->get("revisionDate")),
        });
    }
 
    my $xmlStructure = { url => $url };
    my $xml = 
        '<?xml version="1.0" encoding="UTF-8"?>'
        .'<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        . XMLout( $xmlStructure,
            NoAttr      => 1,
            KeepRoot    => 1,
            KeyAttr     => ["url"],
        )
        .'</urlset>';

    
    $session->http->setMimeType('text/xml');    
    
    return $xml;
}
    
#-------------------------------------------------------------------    
sub formatXML {
	my $content = shift;
	$content =~ s/&/&amp;/g;
    $content =~ s/\</&lt;/g;
    $content =~ s/\>/&gt;/g;
    $content =~ s/'/&apos;/g;
    $content =~ s/"/&quot;/g;
    
	return $content;
}


1;

