package WebGUI::HTML;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black Software.
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
use WebGUI::Session;

=head1 NAME

 Package WebGUI::HTML

=head1 SYNOPSIS

 use WebGUI::HTML;
 $html = WebGUI::HTML::cleanSegment($html);
 $html = WebGUI::HTML::filter($html);

=head1 DESCRIPTION

 A package for manipulating and massaging HTML.

=head1 METHODS

 These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 cleanSegment ( html )

 Returns an HTML segment that has been stripped of the <BODY> tag
 and anything before it, as well as the </BODY> tag and anything
 after it. 

 NOTE: This filter does have one exception, it leaves anything before
 the <BODY> tag that is enclosed in <STYLE></STYLE> tags.

=item html

 The HTML segment you want cleaned.

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

=item html

 The HTML content you want filtered.

=item filter

 Choose from all, none, javascript, or most. Defaults to most. 
 All removes all HTML tags; none removes no HTML tags; javascript
 removes all references to javacript; and most removes all but 
 simple formatting tags like bold and italics.

=cut

sub filter {
	my ($filter, $html, $type);
	$type = $_[1] || $session{setting}{filterContributedHTML};
	if ($type eq "all") {
		$filter = HTML::TagFilter->new(allow=>{'none'},strip_comments=>1);
		$html = $filter->filter($_[0]);
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
	} elsif ($type eq "none") {
		$html = $_[0];
	} else {
		$filter = HTML::TagFilter->new; # defaultly strips almost everything
		$html = $filter->filter($_[0]);
	}
	return $html;
}



1;

