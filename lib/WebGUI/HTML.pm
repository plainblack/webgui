package WebGUI::HTML;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use HTML::Parser;

=head1 NAME

Package WebGUI::HTML

=head1 DESCRIPTION

A package for manipulating and massaging HTML.

=head1 SYNOPSIS

 use WebGUI::HTML;
 $html = WebGUI::HTML::cleanSegment($html);
 $html = WebGUI::HTML::filter($html);
 $html = WebGUI::HTML::format($content, $contentType);
 $html = WebGUI::HTML::html2text($html);
 $html = WebGUI::HTML::makeAbsolute($session, $html);
 $html = WebGUI::HTML::processReplacements($session, $html);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 cleanSegment ( html )

Returns an HTML segment that has been stripped of the <BODY> tag and anything before it, as well as the </BODY> tag and anything after it. It's main purpose is to get rid of META tags and other garbage from an HTML page that will be used as a segment inside of another page.

B<NOTE:> This filter does have one exception, it leaves anything before the <BODY> tag that is enclosed in <STYLE></STYLE> or <SCRIPT></SCRIPT> tags.

=head3 html

The HTML segment you want cleaned.

=cut

sub cleanSegment {
	my $html = shift;
	# remove windows carriage returns
	if ($html =~ s/\r/\n/g) {
		$html =~ s/\n\n/\n/g
	}
	# remove meta tags
	$html =~ s/\<meta.*?\>//ixsg;
	# remove link tags
	$html =~ s/\<link.*?\>//ixsg;
	# remove title tags
	$html =~ s/\<title\>.*?\<\/title\>//ixsg;
	# remove head tags
	$html =~ s/\<head.*?\>//ixsg;
	$html =~ s/\<\/head>//ixsg;
	# remove body tags
	$html =~ s/\<body.*?\>//ixsg;
	$html =~ s/\<\/body>//ixsg;
	# remove html tags
	$html =~ s/\<html>//ixsg;
	$html =~ s/\<\/html>//ixsg;
	return $html;
}

#-------------------------------------------------------------------

=head2 filter ( html [, filter ] )

Returns HTML with unwanted tags filtered out.

=head3 html

The HTML content you want filtered.

=head3 filter

Choose from "all", "none", "macros", "javascript", or "most". Defaults to "most". "all" removes all HTML tags and macros; "none" removes no HTML tags; "javascript" removes all references to javacript and macros; "macros" removes all macros, but nothing else; and "most" removes all but simple formatting tags like bold and italics.

=cut

sub filter {
	my $html = shift;
	my $type = shift;
	if ($type eq "all") {
		my $filter = HTML::TagFilter->new(allow=>{'none'},strip_comments=>1);
		$html = $filter->filter($html);
		WebGUI::Macro::negate(\$html);
	} elsif ($type eq "javascript") {
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
		WebGUI::Macro::negate(\$html);
	} elsif ($type eq "macros") {
		WebGUI::Macro::negate(\$html);
	} elsif ($type eq "none") {
		# do nothing
	} else {
		my $filter = HTML::TagFilter->new; # defaultly strips almost everything
		$html = $filter->filter($html);
		WebGUI::Macro::filter(\$html);
	}
	return $html;
}

#-------------------------------------------------------------------

=head2 format ( content [ , contentType ] )

Formats various text types into HTML.

=head3 content

The text content to be formatted.

=head3 contentType

The content type to use as formatting. Valid types are 'html', 'text', 'code', and 'mixed'. Defaults to mixed. See also the contentType method in WebGUI::Form, WebGUI::HTMLForm, and WebGUI::FormProcessor.

=cut

sub format {
	my ($content, $contentType) = @_;
	$contentType = 'mixed' unless ($contentType);
	if ($contentType eq "text" || $contentType eq "code") {
                $content =~ s/&/&amp;/g;
                $content =~ s/\</&lt;/g;
                $content =~ s/\>/&gt;/g;
                $content =~ s/\n/\<br \/\>\n/g;
                $content =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
	}
	if ($contentType eq "mixed") {
                unless ($content =~ /\<div/ig || $content =~ /\<br/ig || $content =~ /\<p/ig) {
                        $content =~ s/\n/\<br \/\>\n/g;
                }
        } elsif ($contentType eq "text") {
                $content =~ s/  / &nbsp;/g;
        } elsif ($contentType eq "code") {
                $content =~ s/ /&nbsp;/g;
                $content = '<div style="font-family: monospace;">'.$content.'</div>';
        }
	return $content;
}

#-------------------------------------------------------------------

=head2 html2text ( html )

Converts html to text. It currently handles only text, so tables
or forms are not converted.

=head3 html

The html segment you want to convert to text.

=cut

# for recursive function
my $text = "";
my $inside = {};

sub html2text {
	my $html = shift;
	$text = "";
	$inside = {};
	my $tagHandler = sub {
		my($tag, $num) = @_;
		$inside->{$tag} += $num;
		if($tag eq "br" || $tag eq "p") {
			$text .= "\n";
		}
	};
	my $textHandler = sub {
		return if $inside->{script} || $inside->{style};
		if ($_[0] =~ /\S+/) {
			$text .= $_[0];
		}
	};

	HTML::Parser->new(api_version => 3,
		  handlers    => [start => [$tagHandler, "tagname, '+1'"],
				  end   => [$tagHandler, "tagname, '-1'"],
				  text  => [$textHandler, "dtext"],
				 ],
		  marked_sections => 1,
	)->parse($html);

	return $text;
}

#-------------------------------------------------------------------

=head2 makeAbsolute ( session, html , [ baseURL ] )

Returns html with all relative links converted to absolute.

=head3 session

A reference to the current session.

=head3 html

The html to be made absolute.

=head3 baseURL

The base URL to use. Defaults to current page's url.

=cut

my $absolute = "";

sub makeAbsolute {
	my $session = shift;
	my $html = shift;
	my $baseURL = shift;

	$absolute = "";

	my $linkParser = sub {
		my ($tagname, $attr, $text) = @_;
		my %linkElements =            # from HTML::Element.pm
		(
			body   => 'background',
			base   => 'href',
			a      => 'href',
			img    => [qw(src lowsrc usemap)], # lowsrc is a Netscape invention
			form   => 'action',
			input  => 'src',
			'link'  => 'href',         # need quoting since link is a perl builtin
			frame  => 'src',
			iframe => 'src',
			applet => 'codebase',
			area   => 'href',
			script   => 'src',
			iframe  => 'src',
		);

		if(not exists $linkElements{$tagname}) {	# no need to touch this tag
			$absolute .= $text;
			return;
		}
		
		# Build a hash with tag attributes
		my %tag_attr;
		for my $tag (keys %linkElements) {
			my $tagval = $linkElements{$tag};
			for my $attr (ref $tagval ? @$tagval : $tagval) {
			$tag_attr{"$tag $attr"}++;
			}
		}

		$absolute .= "<".$tagname;

		foreach (keys %$attr) {
			if($_ eq '/') {
				$absolute .= '/';
				next;
			}
			if ($tag_attr{"$tagname $_"}) {	# make this absolute
				$attr->{$_} = $session->url->makeAbsolute($attr->{$_}, $baseURL);
			}
			$absolute .= qq' $_="$attr->{$_}"';
		}
	
		$absolute .= '>';
	};
	HTML::Parser->new(
			default_h => [ sub { $absolute .= shift }, 'text' ],
			start_h   => [ $linkParser , 'tagname, attr, text' ],
		)->parse($html);

	return $absolute;
}

#-------------------------------------------------------------------

=head2 processReplacements ( session, content )

Processes text using the WebGUI replacements system.

=head3 session

A reference to the current session.

=head3 content

The content to be processed through the replacements filter.

=cut

sub processReplacements {
	my $session = shift;
	my ($content) = @_;
	my $replacements = $session->stow->get("replacements");
	if (defined $replacements) {
		foreach my $searchFor (keys %{$replacements}) {
			my $replaceWith = $replacements->{$searchFor};
			$content =~ s/\Q$searchFor/$replaceWith/gs;
		}
	} else {
		my $sth = $session->dbSlave->read("select searchFor,replaceWith from replacements");
        	while (my ($searchFor,$replaceWith) = $sth->array) {
			$replacements->{$searchFor} = $replaceWith;
        		$content =~ s/\Q$searchFor/$replaceWith/gs;
        	}
        	$sth->finish;
		$session->stow->set("replacements",$replacements);
	}
	return $content;
}

1;

