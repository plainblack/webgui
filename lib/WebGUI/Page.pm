package WebGUI::Page;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use HTML::Template;
use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::HTMLForm;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;



=head1 NAME

Package WebGUI::Page

=head1 DESCRIPTION

This package provides utility functions for WebGUI's page system.

=head1 SYNOPSIS

 use WebGUI::Page;
 $integer = WebGUI::Page::countTemplatePositions($templateId);
 $html = WebGUI::Page::drawTemplate($templateId);
 $hashRef = WebGUI::Page::getTemplateList();
 $template = WebGUI::Page::getTemplate($templateId);
 $hashRef = WebGUI::Page::getTemplatePositions($templateId);
 $url = WebGUI::Page::makeUnique($url,$pageId);

=head1 METHODS

These functions are available from this package:

=cut


#-------------------------------------------------------------------
sub _newPositionFormat {
	return "<tmpl_var page.position".($_[0]+1).">";
}

#-------------------------------------------------------------------

=head2 countTemplatePositions ( templateId ) 

Returns the number of template positions in the specified page template.

=over

=item templateId

The id of the page template you wish to count.

=back

=cut

sub countTemplatePositions {
        my ($template, $i);
        $template = getTemplate($_[0]);
        $i = 1;
        while ($template =~ m/page\.position$i/) {
                $i++;
        }
        return $i-1;
}

#-------------------------------------------------------------------

=head2 drawTemplate ( templateId )

Returns an HTML string containing a small representation of the page template.

=over

=item templateId

The id of the page template you wish to draw.

=back

=cut

sub drawTemplate {
	my $template = getTemplate($_[0]);
	$template =~ s/\n//g;
	$template =~ s/\r//g;
	$template =~ s/\'/\\\'/g;
	$template =~ s/\<table.*?\>/\<table cellspacing=0 cellpadding=3 width=100 height=80 border=1\>/ig;
	$template =~ s/\<tmpl_var\s+page\.position(\d+)\>/$1/ig;
	return $template;
}

#-------------------------------------------------------------------

=head2 getTemplateList

Returns a hash reference containing template ids and template titles for all the page templates available in the system. 

=cut

sub getTemplateList {
	return WebGUI::Template::getList("Page");
}

#-------------------------------------------------------------------

=head2 getTemplate ( templateId )

Returns an HTML template.

=over

=item templateId

The id of the page template you wish to retrieve.

=back

=cut

sub getTemplate {
	my $template = WebGUI::Template::get($_[0],"Page");
	$template =~ s/\^(\d+)\;/_newPositionFormat($1)/eg; #compatibility with old-style templates
        return $template;
}

#-------------------------------------------------------------------

=head2 getTemplatePositions ( templateId ) 

Returns a hash reference containing the positions available in the specified page template.

=over

=item templateId

The id of the page template you wish to retrieve the positions from.

=back

=cut

sub getTemplatePositions {
	my (%hash, $template, $i);
	tie %hash, "Tie::IxHash";
	for ($i=1; $i<=countTemplatePositions($_[0]); $i++) {
		$hash{$i} = $i;
	}
	return \%hash;
}

#-------------------------------------------------------------------

=head2 makeUnique ( pageURL, pageId )

Returns a unique page URL.

=over

=item url

The URL you're hoping for.

=item pageId

The page id of the page you're creating a URL for.

=back

=cut

sub makeUnique {
        my ($url, $test, $pageId);
        $url = $_[0];
        $pageId = $_[1] || "new";
        while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$url' and pageId<>'$pageId'")) {
                if ($url =~ /(.*)(\d+$)/) {
                        $url = $1.($2+1);
                } elsif ($test ne "") {
                        $url .= "2";
                }
        }
        return $url;
}


1;

