package WebGUI::HTML;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use HTML::TokeParser;
use HTML::TagFilter;
use strict;
use WebGUI::Macro;
use HTML::Parser;
use HTML::Entities;

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
 $html = WebGUI::HTML::splitTag([$tag,]$html[,$count]);    # defaults to ( 'p', $html, 1 )
 $html = WebGUI::HTML::arrayToRow(@columnData);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 arrayToRow ( @columnData )

Wraps each element of @columnData in a table cell tag, concatenates them all together,
and then wraps that in table row tags.

=head3 @columnData

An array of strings to wrap.

=cut

sub arrayToRow {
    my @columnData = @_;
    my $output = '<tr><td>';
    $output .= join '</td><td>', @columnData;
    $output .= '</td></tr>';
    return $output;
}

#-------------------------------------------------------------------

=head2 cleanSegment ( html , preserveStyleScript )

Returns an HTML segment that has been stripped of the <BODY> tag and anything before it, as well as the </BODY> tag and anything after it. It's main purpose is to get rid of META tags and other garbage from an HTML page that will be used as a segment inside of another page.

=head3 html

The HTML segment you want cleaned.

=head3 preserveStyleScript

With this option set, <style> and <script> tags will be preserved in the output.

=cut

sub cleanSegment {
    my $html = shift;
    my $preserveStyleScript = shift;
    my $headers = "";
    if ($html =~ s{^(.*)<body\b[^>]*>}{}is && $preserveStyleScript) {
        my $head = $1;
        # extract every link tag
        while ( $head =~ m{(<link\b[^>]+>)}isg ) {
            $headers .= $1;
        }
        # extract every script or style tag
        while ($head =~ m{(<(script|style)\b.*?</\2>)}isg) {
            $headers .= $1;
        }
    }
    $html =~ s{</body>.*}{}is;
    # remove windows carriage returns
    $html =~ s/\r\n/\n/g;
    $html =~ s/\r/\n/g;
    return $headers . $html;
}

#-------------------------------------------------------------------

=head2 filter ( html [, filter ] )

Returns HTML with unwanted tags filtered out.

=head3 html

The HTML content you want filtered.

=head3 filter

Choose from "all", "none", "macros", "javascript", "xml", or "most". Defaults to "most". "all" removes all HTML tags and macros; "none" removes no HTML tags; "javascript" removes all references to javacript and macros; "macros" removes all macros, but nothing else; and "most" removes all but simple formatting tags like bold and italics.

"xml" will enocde XML entities.

=cut

sub filter {
	my $html = shift;
	my $type = shift;
	if ($type eq "all") {
		#Hash used to keep track of depth within tags
		my %html_parser_inside_tag; 
		#String containing text output from HTML::Parser
		my $html_parser_text = "" ;
		#Hash containing HTML tags (as keys) that create whitespace when rendered by the browser
		my %html_parser_whitespace_tags = ('p'=>1, 'br'=>1, 'hr'=>1, 'td'=>1, 'th'=>1, 
													  'tr'=>1, 'table'=>1, 'ul'=>1, 'li'=>1, 'div'=>1) ;
		#HTML::Parser event handler called at the start and end of each HTML tag, adds whitespace (if necessary) 
		#to output if the tag creates whitespace.  This was done to keep text from running together inappropriately.
		my $html_parser_tag_sub = sub {
			my($tag, $num) = @_;
			$html_parser_inside_tag{$tag} += $num;
			if ($html_parser_whitespace_tags{$tag} && 
			    ($html_parser_text =~ /\S$/)) { #add space only if no preceeding space
				$html_parser_text .= " "  ;
   		}
		} ;
		#HTML::Parser event handler called with non-tag text (no tags)
		my $html_parser_text_sub = sub {
			return undef if $html_parser_inside_tag{script} || $html_parser_inside_tag{style}; # do not output text
			$html_parser_text .= $_[0] ;
		} ;
		my $parser = HTML::Parser->new(api_version => 3,
		  handlers => [start => [$html_parser_tag_sub, 
   					 "tagname, '+1'"],
			       end   => [$html_parser_tag_sub, 
   					 "tagname, '-1'"],
			       text  => [$html_parser_text_sub, 
					 "text"]
			      ],
		  marked_sections => 1,
		) ;
		$parser->parse($html) ;
		$parser->eof() ;
		$html = $html_parser_text ;
		$html =~ s/&nbsp;/ /ixsg ;
		WebGUI::Macro::negate(\$html);
	} elsif ($type eq "javascript") {
		$html =~ s/\<\s*script.*?\/script\s*\>//ixsg;
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
	} elsif ($type eq "xml") {
        return HTML::Entities::encode_numeric($html)
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

The content type to use as formatting. Valid types are 'text', 'code', and 'mixed'. The default contentType is 'mixed'.
See also the contentType method in WebGUI::Form, WebGUI::HTMLForm, and WebGUI::FormProcessor.

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
	my $html = shift() . " ";
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
		return undef if $inside->{script} || $inside->{style};
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
		my %linkElements =            # from HTML::Element
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
			return undef;
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

		my $foundClosingSlash;

		foreach (keys %$attr) {
			if($_ eq '/') {
				$foundClosingSlash = '1';
				next;
			}
			if ($tag_attr{"$tagname $_"}) {	# make this absolute
				$attr->{$_} = $session->url->makeAbsolute($attr->{$_}, $baseURL);
			}
			$absolute .= qq' $_="$attr->{$_}"';
		}
		$absolute .= '/' if ($foundClosingSlash);
		$absolute .= '>';
	};
	HTML::Parser->new(
			default_h => [ sub { $absolute .= shift }, 'text' ],
			start_h   => [ $linkParser , 'tagname, attr, text' ],
		)->parse($html);

	return $absolute;
}

#-------------------------------------------------------------------

=head2 makeParameterSafe ( text )

Encodes text to make it safe to embed in a macro by HTML encoding commas and quotes.

=head3 html

A reference to the text to be encoded.

=cut

sub makeParameterSafe {
	my $text = shift;
	${ $text } =~ s/,/&#44;/g;
	${ $text } =~ s/'/&#39;/g;
	return undef;
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
	if (! defined $replacements) {
		my $sth = $session->dbSlave->read("select searchFor,replaceWith from replacements");
        while (my ($searchFor,$replaceWith) = $sth->array) {
			$replacements->{$searchFor} = $replaceWith;
        }
        $sth->finish;
        $session->stow->set("replacements",$replacements);
	}
    foreach my $searchFor (keys %{$replacements}) {
        my $replaceWith = $replacements->{$searchFor};
        $content =~ s/\b\Q$searchFor\E\b/$replaceWith/gs;
    }
	return $content;
}

#-------------------------------------------------------------------

=head2 splitSeparator ( $content )

Splits the supplied content on the separator macro, ^-;.  Returns an array
of content.  If the content contains HTML, and splitting the content would
result in sections of content missing start or end HTML tags, these are filled
in.  Unary tags, like br, img, and hr are ignored, whether they are proper XHTML
or not.

In the special case of the separator macro inside bare paragraph tags,

    <p>^-;</p>,
    
no empty paragraph tags are generated.

=head3 content

The content to split.

=cut

sub splitSeparator {
	my $content = shift;
    return $content unless $content =~ /\^-;/;
    $content =~ s{<p>\s*\^-;\s*</p>}{\^-;}g;
    my @tagStack = ();
    my $parser = HTML::Parser->new(
        api_version      => 3,
        ignore_elements  => [ qw/br img hr/ ],
        start_h     => [ sub { push @tagStack, $_[0]; }, 'tag'],
        end_h       => [ sub { pop  @tagStack;        }, 'tag'], 
    );
    my @sections = ();
    CHUNK: while (my ($leader, $trailer) = split /\^-;/, $content, 2) {
        if (! defined $trailer) {
            push @sections, $leader;
            last CHUNK;
        }
        $parser->parse($leader);
        while( my $tag = pop @tagStack) {
            my $endTag = '</'.$tag.'>';
            $tag       = '<'.$tag.'>';
            $leader  .= $endTag;
            $trailer  = $tag . $trailer;
        }
        push @sections, $leader;
        $content = $trailer;
    }
	return @sections;
}

#-------------------------------------------------------------------

=head2 splitTag([$tag,]$html[,$count]);

splits an block of HTML into an array based on the contents of a single tag

=head3 tag

The HTML tag top extract from the text.  this defaults to 'p' giving a list of paragraphs

=head3 html

The block of HTML text that will be disected

=head3 count

How many items do we want?  defaults to 1; returns 1 non-blank item; -1 returns all items

=cut

sub splitTag {

    my $tag = shift;
    my $html = shift;
    my $count = shift || 1;
    if( not defined $html or $html =~ /^(-?\d+)$/ ) {
        $count = $html if $1;
        $html = $tag;
        $tag = 'p';                 # the default tag is 'p' -- grabs a paragraph
    }
    my @result;

    my $p = HTML::TokeParser->new(\$html);

    while (my $token = $p->get_tag($tag)) {
        my $text = $p->get_trimmed_text("/$tag");
        utf8::upgrade($text);  ##PATCH to work around HTML::Entities and DBD::mysql
        next if $text =~ /^([[:space:]]|[[:^print:]])*$/;    # skip whitespace
        push @result, $text;          # add the text between the tags to the result array
        last if @result == $count;    # if we have a full count then quit
    }

    return @result if wantarray;
    return $result[0];
}
#-------------------------------------------------------------------

=head2 WebGUI::HTML::splitHeadBody($html);

splits an block of HTML into a HEAD and a BODY section 

=head3 html

The block of HTML text that will be disected

=cut


sub splitHeadBody {
    my $html = shift;

    my $parser = HTML::Parser->new(api_version => 3);

    my $head = '';
    my $body = '';
    my $accum;
    $parser->handler(start => sub {
        my ($tag, $text) = @_;
        if ($tag eq 'head') {
            $accum = \$head;
        }
        elsif ($tag eq 'body') {
            $accum = \$body;
        }
        elsif ($accum) {
            $$accum .= $text;
        }
    }, 'tagname, text');
    $parser->handler(end => sub {
        my ($tag, $text) = @_;
        if ($tag eq 'head' || $tag eq 'body') {
            $accum = undef;
        }
        elsif ($accum) {
            $$accum .= $text;
        }
    }, 'tagname, text');
    $parser->handler(default => sub {
        my ($tag, $text) = @_;
        if ($accum) {
            $$accum .= $text;
        }
    }, 'tagname, text');
    $parser->parse($html);
    return ($head, $body);
}

1;

