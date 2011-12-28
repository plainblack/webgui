package WebGUI::Content::AssetDiscovery;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use JSON;
use WebGUI::Asset;
use XML::Simple;

=head1 NAME

Package WebGUI::Content::AssetDiscovery

=head1 DESCRIPTION

Allows web services to find a list of assets of a given type. 

=head1 SYNOPSIS

 use WebGUI::Content::AssetDiscovery;
 my $output = WebGUI::Content::AssetDiscovery::handler($session);
 
From the web call any WebGUI URL. The discovery asset will limit your query to the assets below that URL in the asset tree. Here's an example:

 http://admin:123qwe@www.example.com/some-page?op=findAssets;className=WebGUI::Asset::Wobject::Article
 
Only the assets that you can view according to your user's privileges will be returned. The following are the parameters you can pass along the URL:

=head2 op

Required. Its value must be 'findAssets'.

=head2 className

Required. Its value must be a valid WebGUI asset classname.

=head2 as

Defaults to 'json'. You may override it by setting its value to 'xml'. This setting determines how the result set will come back. If it is 'json' it will look like:

    {
       "assets" : [
          {
             "lastUpdated" : "2006-05-14 16:35:15",
             "synopsis" : null,
             "menuTitle" : "Getting Started (part 2)",
             "url" : "http://dev.localhost.localdomain/getting_started/getting-started-part2",
             "title" : "Getting Started (part 2)",
             "dateCreated" : "2006-05-14 16:35:15"
          }
       ],
       "className" : "WebGUI::Asset::Wobject::Article",
       "pageNumber" : 1
    }

If it is 'xml' it will look like:

    <opt>
      <assets>
        <dateCreated>2006-05-14 16:35:15</dateCreated>
        <lastUpdated>2006-05-14 16:35:15</lastUpdated>
        <menuTitle>Getting Started (part 2)</menuTitle>
        <synopsis></synopsis>
        <title>Getting Started (part 2)</title>
        <url>http://dev.localhost.localdomain/getting_started/getting-started-part2</url>
      </assets>
      <className>WebGUI::Asset::Wobject::Article</className>
      <pageNumber>1</pageNumber>
    </opt>

=head2 pn

Defaults to 1. pn stands for Page Number. The result set from this service returns up to 100 assets at a time. If you need more than that you can set pn to the next page number and so on. B<Caveat:> Due to the calculations based upon branch and user privileges this service does not know the maximum number of pages of data there will be.

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    my $form = $session->form;
    if ($form->get('op') eq 'findAssets') {
        my @assets;
        my $as = $form->get('as') || 'json';
        my $pageNumber = $form->get('pn') || 1;
        my $class = $form->get('className');
        if ($class ne '') {
            my $start = WebGUI::Asset->newByUrl($session);
            my $limit = ($pageNumber * 100 - 100).','.($pageNumber * 100 - 1);
            my $siteUrl = $session->url->getSiteURL;
            my $date = $session->datetime;
            my $matchingAssets = $session->db->read("select assetId from asset where lineage like ? and className=? limit ".$limit, [$start->lineage.'%', $class]);
            while (my ($id) = $matchingAssets->array) {
                my $asset = eval { WebGUI::Asset->newById($session, $id); };
                if (! Exception::Class->caught() ) {
                    if ($asset->canView && $asset->state eq 'published' && $asset->status ~~ ['approved', 'archived']) {
                        push @assets, {
                            title       => $asset->getTitle,
                            menuTitle   => $asset->menuTitle,
                            synopsis    => $asset->synopsis,
                            url         => $siteUrl.$asset->getUrl,
                            dateCreated => $date->epochToHuman($asset->creationDate, '%y-%m-%d %j:%n:%s'),
                            lastUpdated => $date->epochToHuman($asset->revisionDate, '%y-%m-%d %j:%n:%s'),
                        };
                    }
                }
            }
        }
        my $document = {
            pageNumber  => $pageNumber,
            className   => $class,
            assets      => \@assets
        };
        if ($as eq "xml") {
            $session->response->content_type('text/xml');
            return XML::Simple::XMLout($document, NoAttr => 1);
        }
        $session->response->content_type('application/json');
        return JSON->new->encode($document);
    }
    return undef;
}

1;
#vim:ft=perl
