#!/usr/bin/perl
package XML::RSSLite;
use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
use Exporter;
@ISA = ('Exporter');
@EXPORT = qw/parseXML usableXML/;
@EXPORT_OK = qw/parseXML usableXML 
                isRSS    isRDF    isSN    isWL
                xml_content_string xml_content_array/;
$VERSION = '0.08';


sub parseXML {
  my ($rr, $cr) = @_;

  die "Parms to 'parse' must be refs to a hash and XML content!"
    unless (ref($rr) and ref($cr));

  return unless $$cr; ## Gotta have some content to parse

  my $type = usableXML($cr) 
    or die "Content must be RSS/RDF/ScriptingNews/Weblog XML " .
           "(or something pretty close)";

  preprocess($cr);

  if ($type == 1  or  $type == 2) {
    parseRSS($rr, $cr);
  } elsif ($type == 3) {
    parseSN($rr, $cr);
  } elsif ($type == 4) {
    parseWL($rr, $cr);
  } else {
    die "Screwed up XML type-checking somehow!";
  }
  
  postprocess($rr);  
}

sub preprocess {
  my $cr = shift;

  ##
  ## Help create "well-formed" XML so parser doesn't puke by
  ## 1. Making unix-style line endings
  ## 2. Using &amp; for & (this screws up urls, but we fix it later)
  ## 3. Removing objectionable characters
  ##
  $$cr =~ s|<(/*)rss\d+:(.*?)>|<$1$2>|g;
  $$cr =~ s|<([^<> ]+)\s+(.+?)\s+/>|<$1 $2></$1>|g;
  $$cr =~ s/[\012\015]{1,2}/\n/g;
  $$cr =~ s/&(?!([a-zA-Z0-9]+|#\d+);)/&amp;/g;
  $$cr =~ y/\~\[\n 0-9a-zA-Z_\!\@\#\$\%\^\&\*\(\)\-\+\=\:\;\"\'\<\>\,\.\/?\]/ /c;

  ## Tidy up for debugging by starting open tags on new line
# $content =~ s|(?!\n)<(?!/)|\n<|gs;
}

sub postprocess {
  my $rr = shift;

  $rr->{'link'} =~ s/&amp;/&/gi;

  if (defined($rr->{'items'})) {
    my $i;

    foreach $i (@{$rr->{'items'}}) {
      $i->{'link'} = trim($i->{'link'});

      # Put stuff into the right name if necessary
      if (defined($i->{'url'}) and not $i->{'link'})             {
        $i->{'link'} = $i->{'url'};
      }

      # Fix pre-process munging
      $i->{'link'} =~ s/&amp;/&/gi;

      # See if you can use misplaced url in title for empty links
      if (not $i->{'link'}) {
        if ($i->{'title'} =~ /^(?:ht)|ftp:/) {
          $i->{'link'} = $i->{'title'};
        } elsif ($i->{'title'} =~ /"((?:ht)|ftp.*?)"/) {
          $i->{'link'} = $1;
          $i->{'title'} =~ s/<.*?>//;
        } else {
          next;
        }
      }

      # Make sure you've got an http/ftp link
      if ($i->{'link'} !~ m{^(http|ftp)://}i) {
        ## Rip link out of anchor tag
        $i->{'link'} =~ m{a\s+href=("|&quot;)?(.*?)("|>|&quot;|&gt;)?}i;
        if ($2) {
          $i->{'link'} = $2;

        } elsif ($i->{'link'}  =~ m{[\.#/]}i  and
                 $rr->{'link'} =~ m{^http://})            { 
          ## Smells like a relative url
          if (substr($i->{'link'}, 0, 1) ne '/') {
            $i->{'link'} = '/' . $i->{'link'};
          }
          $i->{'link'} = $rr->{'link'} . $i->{'link'};

        } else {
          next;
        }
      }

      #If we don't have a title, use the link
      if (not $i->{'title'}) {
	$i->{'title'} = $i->{'link'};
      }
      $i->{'link'} =~ s/ //g;
    }
  }
}

sub parseRSS {
  my ($rr, $cr) = @_;
  
  my $channel = xml_content_string('channel', $cr);
  $channel =~ s|<item.*?</item>||gis;
  clean(\$channel);
  
  my $ca; 
  my @channel_attrs = ($channel =~ m|(<.*?>.*?</.*?>)|gi);
  foreach $ca (@channel_attrs) {
    $ca =~ m|^<(.*?)>(.*?)</.*?>$|;
    $rr->{$1} = trim($2);
  }

  $rr->{'items'} = ();
  my $item; 
  foreach $item (xml_content_array('item', $cr)) {
    clean(\$item);
    my @item_attrs = ($item =~ m|(<.*?>.*?</.*?>)|gi);
    my $ia;
    my %ia;
    foreach $ia (@item_attrs) {
      $ia =~ m|^<(.*?)>(.*?)</.*?>$|;
      $ia{$1} = trim($2);
    }
    push(@{$rr->{'items'}}, \%ia); 
#XXX test blanks here
  }
}

sub parseSN {
  my ($rr, $cr) = @_;
  
  my $channel = xml_content_string('header', $cr);
  $channel =~ s|<item.*?</item>||gis;
  clean(\$channel);
  
  my $ca; 
  my @channel_attrs = ($channel =~ m|(<.*?>.*?</.*?>)|gi);
  foreach $ca (@channel_attrs) {
    $ca =~ m|^<(.*?)>(.*?)</.*?>$|;
    $rr->{$1} = trim($2);
  }

##
## Alias SN to RSS terms
##
  if (exists $rr->{'channelDescription'}) {
    $rr->{'description'} = $rr->{'channelDescription'};
  }  
  if (exists $rr->{'channelTitle'}) {
    $rr->{'title'} = $rr->{'channelTitle'};
  }  
  if (exists $rr->{'channelLink'}) {
    $rr->{'link'} = $rr->{'channelLink'};
  }  

  $rr->{'items'} = ();
  my $item; 
  foreach $item (xml_content_array('item', $cr)) {
    clean(\$item);
    my @item_attrs = ($item =~ m|(<.*?>.*?</.*?>)|gi);
    my $ia;
    my %ia;
    foreach $ia (@item_attrs) {
      $ia =~ m|^<(.*?)>(.*?)</.*?>$|;
      $ia{$1} = trim($2);
    }

    # Links are nested, kill prev {'link'} and rebuild attrs inside it
    undef $ia{'link'};
    my @linkitems = xml_content_array('link', \$item)
      or next;

    my $linkitem = $linkitems[0]; ## Usually first one is most relevant
    @item_attrs = ($linkitem =~ m|(<.*?>.*?</.*?>)|gi);
    foreach $ia (@item_attrs) {
      $ia =~ m|^<(.*?)>(.*?)</.*?>$|;
      $ia{$1} = trim($2);
    }
    
    # Alias SN to RSS
    if (exists $ia{'text'}) {
      $ia{'description'} = $ia{'text'};
    }  
    if (exists $ia{'linetext'}) {
      $ia{'title'} = $ia{'linetext'};
    }  
    if (exists $ia{'url'}) {
      $ia{'link'} = $ia{'url'};
    }  
    push(@{$rr->{'items'}}, \%ia); 
  }
}


sub parseWL {
  my ($rr, $cr) = @_;
  
# my $channel = xml_content_string('header', $cr);
# $channel =~ s|<item.*?</item>||gis;
# clean(\$channel);
  
# my $ca; 
# my @channel_attrs = ($channel =~ m|(<.*?>.*?</.*?>)|gi);
# foreach $ca (@channel_attrs) {
#   $ca =~ m|^<(.*?)>(.*?)</.*?>$|;
#   $rr->{$1} = trim($2);
# }

##
## Alias SN to RSS terms
##
# if (exists $rr->{'channelDescription'}) {
#   $rr->{'description'} = $rr->{'channelDescription'};
# }  
# if (exists $rr->{'channelTitle'}) {
#   $rr->{'title'} = $rr->{'channelTitle'};
# }  
# if (exists $rr->{'channelLink'}) {
#   $rr->{'link'} = $rr->{'channelLink'};
# }  

  $rr->{'items'} = ();
  my $item; 
  foreach $item (xml_content_array('link', $cr)) {
    clean(\$item);
    my @item_attrs = ($item =~ m|(<.*?>.*?</.*?>)|gi);
    my $ia;
    my %ia;
    foreach $ia (@item_attrs) {
      $ia =~ m|^<(.*?)>(.*?)</.*?>$|;
      $ia{$1} = trim($2);
    }
    # Alias WL to RSS
    if (exists $ia{'url'}) {
      $ia{'link'} = $ia{'url'};
    }  

    push(@{$rr->{'items'}}, \%ia); 
  }
}

sub usableXML {
  my $cref = shift;
  my $content = $$cref; ## Don't change caller's content just for usability check
 
  preprocess(\$content);

  return 1 if isRSS(\$content);
  return 2 if isRDF(\$content);
  return 3 if isSN(\$content);
  return 4 if isWL(\$content);

  return 0;
}

sub isRSS {
  my $cref = shift;
  return scalar($$cref =~ /<rss.*>.*<\/rss>/is);
}

sub isRDF {
  my $cref = shift;
  return scalar($$cref =~ /<rdf:RDF.*>.*<\/rdf:RDF>/is);
}

sub isSN {
  my $cref = shift;
  return scalar($$cref =~ /<scriptingnews.*>.*<\/scriptingnews>/is);
}

sub isWL {
  my $cref = shift;
  return scalar($$cref =~ /<weblog.*>.*<\/weblog>/is);
}

sub xml_content_string {
  my $tag = shift;
  my $cref = shift;

  $$cref =~ /<${tag}.*?>(.*)<\/${tag}>/is;
  return $1;
} 

sub xml_content_array {
  my $tag = shift;
  my $cref = shift;
  my $keeptags = shift;
  $keeptags = 0 unless $keeptags;
  my @result;

  if ($keeptags) {
    @result = ($$cref =~ /(<${tag}.*?>.*?<\/${tag}>)/gis);
  } else {
    @result = ($$cref =~ /<${tag}.*?>(.*?)<\/${tag}>/gis);
  }

  return @result;
}

sub clean {
  my $cref = shift;

  $$cref =~ s{(\n|<p>|</p>|<b>|</b>|<i>|</i>|<h\d>|</h\d>|<strong>|</strong>|<center>|</center>|<quote>|</quote>)}{ }gsi;
}

sub trim {
  my $s = shift;

  $s =~ s/^\s*(.*?)\s*$/$1/;
  return $s;
}

1;
__END__

=pod

=head1 NAME

XML::RSSLite - Perl extension for "relaxed" RSS parsing

=head1 SYNOPSIS

  use XML::RSSLite;

  . . .

  parseXML(\%result, \$content);

  print "=== Channel ===\n",
        "Title: $result{'title'}\n",
        "Desc:  $result{'description'}\n",
        "Link:  $result{'link'}\n\n";

  foreach $item (@{$result{'items'}}) {
  print "  --- Item ---\n",
        "  Title: $item->{'title'}\n",
        "  Desc:  $item->{'description'}\n",
        "  Link:  $item->{'link'}\n\n";
  }

=head1 DESCRIPTION

This module attempts to extract the maximum amount of content from
available documents, and is less concerned with XML compliance than
alternatives. Rather than rely on XML::Parser, it uses heuristics and good
old-fashioned Perl regular expressions. It stores the data in a simple
hash structure, and "aliases" certain tags so that when done, you can
count on having the minimal data necessary for re-constructing a valid
RSS file. This means you get the basic title, description, and link for a
channel and its items. Anything else present in the hash is a bonus :)

This module extracts more usable links by parsing "scriptingNews" and
"weblog" formats in addition to RDF & RSS. It also "sanitizes" the
output for best results. The munging includes:

=over

=item Remove html tags to leave plain text

=item Remove characters other than 0-9~!@#$%^&*()-+=a-zA-Z[];',.:"<>?\s

=item Use <url> tags when <link> is empty

=item Use misplaced urls in <title> when <link> is empty 

=item Exract links from <a href=...> if required   

=item Limit links to ftp and http

=item Join relative urls to the site base

=back

=head2 EXPORT

=over

=item parseXML($outHashRef, $inScalarRef)

I<$inScalarRef> is a reference to a scalar containing the document to be
parsed, the contents will effectively be destroyed. I<$outHashRef> is a
reference to the hash within which to store the parsed content.

=item usableXML($inScalarRef)

Test whether or not B<XML::RSSLite> understands the content of the referenced
document.

=back

=head2 EXPORTABLE

=over

=item isRDF($inScalarRef)

Tests if a referenced document is RDF.

=item isRSS($inScalarRef)

Tests if a referenced document is RSS.

=item isSN($inScalarRef)

Tests if a referenced document is scriptingNews.

=item isWL($inScalarRef)

Tests if a referenced document is weblog.

=back

=head1 BUGS

Sometimes the title of an item will be missed,
the condition will presist until additional items have been added
to the document. As a stop gap, when this happens the item title
is set equal to the item link.

It may take awhile for the tuits to fix this to accumulate.
feel free to submit a patch.

=head1 SEE ALSO

perl(1), C<XML::RSS>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>.

Scott Thomason <scott@industrial-linux.org>

=head1 LICENSE

Portions Copyright (c) 2002 Jerrad Pierce, (c) 2000 Scott Thomason.
All rights reserved. This program is free software; you can redistribute it 
and/or modify it under the same terms as Perl itself.

=cut
