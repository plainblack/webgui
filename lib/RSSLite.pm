package RSSLite;
##
## Copyright (c) 2000 Scott Thomason. All rights reserved.
## This program is free software; you can redistribute it 
## and/or modify it under the same terms as Perl itself.
##

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
use Exporter;
@ISA = ('Exporter');
@EXPORT = qw/parseXML usableXML/;
@EXPORT_OK = qw/parseXML usableXML 
                isRSS    isRDF    isSN    isWL
                xml_content_string xml_content_array/;
$VERSION = '0.06';

use Carp;
use Data::Dumper;


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
  $$cr =~ s/\r\n?/\n/g;
  $$cr =~ s/&(?!([a-zA-Z0-9]+|#\d+);)/&amp;/g;
  $$cr =~ s/[^\s\d\w!@#\$%^&\*i\(\)\-\+=:;"'<>,\.\/\?]/ /g;

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
        if ($i->{'title'} =~ /^http:/) {
          $i->{'link'} = $i->{'title'};
        } elsif ($i->{'title'} =~ /"(http.*?)"/) {
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

