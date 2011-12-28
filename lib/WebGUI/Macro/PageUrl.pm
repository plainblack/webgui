package WebGUI::Macro::PageUrl;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use URI;

=head1 NAME

Package WebGUI::Macro::Page

=head1 DESCRIPTION

Macro for displaying the url for the current asset.

=head2 process ( $session, $url, $query )

process is really a wrapper around $session->url->page();

=head3 $session

The current WebGUI session object.

=head3 $url

A URL to safely append to the end of the page URL.

=head3 $query

The post query (?) parameters you'd like to add to the URL.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my $url = shift;
    my $query = shift;
	my $pageUrl = $session->url->page($query);
	if ($url) {
		my $uri = URI->new($pageUrl);
		##Append the requested URL to the path part of the URL
		$uri->path(join "/", $uri->path, $url);
		$pageUrl = $uri->as_string;
	}
	$pageUrl =~ tr{/}{/}s; ##Remove duplicate slashes.
	return $pageUrl;
}


1;

