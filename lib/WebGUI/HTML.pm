package WebGUI::HTML;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use HTML::TagFilter;
use strict;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::HTML

=head1 DESCRIPTION

A package for manipulating and massaging HTML.

=head1 SYNOPSIS

 use WebGUI::HTML;
 $html = WebGUI::HTML::cleanSegment($html);
 $html = WebGUI::HTML::filter($html);
 $html = WebGUI::HTML::format($content, $contentType);
 $html = WebGUI::HTML::processReplacements($html);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 cleanSegment ( html )

Returns an HTML segment that has been stripped of the <BODY> tag and anything before it, as well as the </BODY> tag and anything after it. 

NOTE: This filter does have one exception, it leaves anything before the <BODY> tag that is enclosed in <STYLE></STYLE> tags.

=over

=item html

The HTML segment you want cleaned.

=back

=cut

sub cleanSegment {
	my ($style, $value);
	$value = $_[0];
	if ($value =~ s/\r/\n/g) {
		$value =~ s/\n\n/\n/g
	}
	$value =~ m/(\<style.*?\/style\>)/ixsg;
	$style = $1;
	$value =~ s/\A.*?\<body.*?\>(.*?)/$style$1/ixsg;
        $value =~ s/(.*?)\<\/body\>.*?\z/$1/ixsg;
	return $value;
}

#-------------------------------------------------------------------

=head2 filter ( html [, filter ] )

Returns HTML with unwanted tags filtered out.

=over

=item html

The HTML content you want filtered.

=item filter

Choose from "all", "none", "macros", "javascript", or "most". Defaults to "most". "all" removes all HTML tags and macros; "none" removes no HTML tags; "javascript" removes all references to javacript and macros; "macros" removes all macros, but nothing else; and "most" removes all but simple formatting tags like bold and italics.

=back

=cut

sub filter {
	my ($filter, $html, $type);
	$type = $_[1];
	if ($type eq "all") {
		$filter = HTML::TagFilter->new(allow=>{'none'},strip_comments=>1);
		$html = $filter->filter($_[0]);
		return WebGUI::Macro::negate($html);
	} elsif ($type eq "javascript") {
		$html = $_[0];
		$html =~ s/\<script.*?\/script\>//ixsg;
		$html =~ s/(href="??)javascript\:.*?\)/$1removed/ixsg;
		$html =~ s/onClick/removed/ixsg;
		$html =~ s/onDblClick/removed/ixsg;
		$html =~ s/onLoad/removed/ixsg;
		$html =~ s/onMouseOver/removed/ixsg;
		$html =~ s/onMouseOut/removed/ixsg;
		$html =~ s/onMouseMove/removed/ixsg;
		$html =~ s/onMouseUp/removed/ixsg;
		$html =~ s/onMouseDown/removed/ixsg;
		$html =~ s/onKeyPress/removed/ixsg;
		$html =~ s/onKeyUp/removed/ixsg;
		$html =~ s/onKeyDown/removed/ixsg;
		$html =~ s/onSubmit/removed/ixsg;
		$html =~ s/onReset/removed/ixsg;
		$html = WebGUI::Macro::negate($html);
	} elsif ($type eq "macros") {
		return WebGUI::Macro::negate($_[0]);
	} elsif ($type eq "none") {
		return $_[0];
	} else {
		$filter = HTML::TagFilter->new; # defaultly strips almost everything
		$html = $filter->filter($_[0]);
		return WebGUI::Macro::filter($html);
	}
}

#-------------------------------------------------------------------

=head2 format ( content [ , contentType ] )

Formats various text types into HTML.

=over

=item content

The text content to be formatted.

=item contentType

The content type to use as formatting. Valid types are 'html', 'text', 'code', and 'mixed'. Defaults to mixed. See also the contentType method in WebGUI::Form, WebGUI::HTMLForm, and WebGUI::FormProcessor.

=back

=cut

sub format {
	my ($content, $contentType) = @_;
	$contentType = 'mixed' unless ($contentType);
	if ($contentType eq "mixed") {
                unless ($content =~ /\<div/ig || $content =~ /\<br/ig || $content =~ /\<p/ig) {
                        $content =~ s/\n/\<br \/\>/g;
                }
        } elsif ($contentType eq "text") {
                $content =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
                $content =~ s/\n/\<br \/\>/g;
        } elsif ($contentType eq "code") {
                $content =~ s/&/&amp;/g;
                $content =~ s/\</&lt;/g;
                $content =~ s/\>/&gt;/g;
                $content =~ s/\n/\<br \/\>/g;
                $content =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
                $content =~ s/ /&nbsp;/g;
                $content = '<div style="font-family: fixed;">'.$content.'</div>';
        }
	return $content;
}

#-------------------------------------------------------------------

=head2 processReplacements ( content ) 

Processes text using the WebGUI replacements system.

=over

=item content

The content to be processed through the replacements filter.

=back

=cut

sub processReplacements {
	my ($content) = @_;
	if (exists $session{replacements}) {
		my $replacements = $session{replacements};
		foreach my $searchFor (keys %{$replacements}) {
			my $replaceWith = $replacements->{$searchFor};
			$content =~ s/\Q$searchFor/$replaceWith/gs;
		}
	} else {
		my $sth = WebGUI::SQL->read("select searchFor,replaceWith from replacements");
        	while (my ($searchFor,$replaceWith) = $sth->array) {
			$session{replacements}{$searchFor} = $replaceWith;
        		$content =~ s/\Q$searchFor/$replaceWith/gs;
        	}
        	$sth->finish;
	}
	return $content;
}



1;

