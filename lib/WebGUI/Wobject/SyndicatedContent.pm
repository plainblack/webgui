package WebGUI::Wobject::SyndicatedContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use HTML::Entities;
use strict;
use Storable;
use Tie::CPHash;
use WebGUI::Cache;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::HTML;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Wobject;
use XML::RSSLite;
use LWP::UserAgent;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(2,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			rssUrl=>{},
                        maxHeadlines=>{},
			},
		-useTemplate=>1
                );
        bless $self, $class;
}


#-------------------------------------------------------------------
sub uiLevel {
        return 6;
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	$properties->url(
		-name=>"rssUrl",
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("rssUrl")
		);
        my $layout = WebGUI::HTMLForm->new;
	$layout->integer(
		-name=>"maxHeadlines",
		-label=>WebGUI::International::get(3,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("maxHeadlines")
		);
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
                -layout=>$layout->printRowsOnly,
		-headingId=>4,
		-helpId=>1
		);
}


# strip all html tags from the given data structure.  This is important to
# prevent cross site scripting attacks
my $_stripped_html = {};
sub _strip_html {
        #my ($data) = @_;
        
        if (ref($_[0]) eq 'HASH') {
                keys(%{$_[0]});
                while (my ($name, $val) = each (%{$_[0]})) {
                        $_[0]->{$name} = _strip_html($val);
                }
        } elsif (ref($_[0]) eq 'ARRAY') {
                for (my $i = 0; $i < @{$_[0]}; $i++) {
                        $_[0]->[$i] = _strip_html($_[0]->[$i]);
                }
        } else {
                if ($_[0]) {
                        $_[0] =~ s/\&lt;/</g;
                        $_[0] =~ s/\&gt;/>/g;
                        $_[0] = WebGUI::HTML::filter($_[0], 'all');
                }
        }
        
        return $_[0];
}

# horrible kludge to find the channel or item record
# in the varying kinds of rss structures returned by RSSLite
sub _find_record {
        my ($data, $regex) = @_;
        
        if (ref($data) eq 'HASH') {
                # reset the hash before calling each()
                keys(%{$data});
                while (my ($name, $val) = each(%{$data})) {
                        if ($name =~ $_[1]) {
                                if ((((ref($val) eq 'HASH') && 
                                      ($val->{link} || $val->{title} || 
                                       $val->{description})) ||
                                     ((ref($val) eq 'ARRAY') && @{$val} && 
                                      (ref($val->[0]) eq 'HASH') &&
                                      ($val->[0]->{link} || 
                                       $val->[0]->{title} ||
                                       $val->[0]->{description})))) {
                                        return $val;
                                }
                        }
                        if (my $record = _find_record($val, $regex)) {
                                return $record;
                        }
                }
        }
        
        return undef;
}

# Copy the guid field to the link field if the guid looks like a link.
# This is a kludge that gets around the fact that some folks use the link
# field as the link to the story while others use it as the link
# to the story about which the story is written.  The webuig templates seem
# to assume the former, so we should use the guid instead of the link, b/c
# the guid, if it is a link, always means the former.
# Also copy the first few words of the description into the title if 
# there is no title
sub _normalize_items {
        #my ($items) = @_;
        
        # max number of words to take from description to fill in an empty 
        # title
        my $max_words = 10;
        
        for my $item (@{$_[0]}) {
                if ($item->{guid} && ($item->{guid} =~ /^http:\/\//i)) {
                        $item->{link} = $item->{guid};
                }
                if (!$item->{title}) {
                        my @description_words = split(/\s/, $item->{description});
                        if (@description_words <= $max_words) {
                                $item->{title} = $item->{description};
                        } else {
                                $item->{title} = join(" ", @description_words[0..$max_words-1]) . 
                                  " ...";
                        }
                }
                
                # IE doesn't recognize &apos;
                $item->{title} =~ s/&apos;/\'/;
                $item->{description} =~ s/&apos;/\'/;
        }
}

sub _get_rss_data {
        my ($url) = @_;
        
        my $cache = WebGUI::Cache->new("url:" . $url, "RSS");
        my $rss_serial = $cache->get;
        my $rss = {};
        if ($rss_serial) {
                $rss = Storable::thaw($rss_serial);
        } else {
                my $ua = LWP::UserAgent->new(timeout => 5);
                my $response = $ua->get($url);
                if (!$response->is_success()) {
                        warn("Error retrieving url '$url': " . 
                             $response->status_line());
                        return undef;
                }
                my $xml = $response->content();
                
                # there is no encode_entities_numeric that I can find, so I am 
                # commenting this out. -hal
                #    $xml =~ s#(<title>)(.*?)(</title>)#$1.encode_entities_numeric(decode_entities($2)).$3#ges;
                #    $xml =~ s#(<description>)(.*?)(</description>)#$1.encode_entities_numeric(decode_entities($2)).$3#ges; 
                
                my $rss_lite = {};
                eval {
                        XML::RSSLite::parseXML($rss_lite, \$xml);
                };
                if ($@) {
                        warn("error parsing rss for url $url");
                }
                
                # make sure that the {channel} points to the channel 
                # description record and that {items} points to the list 
                # of items.  without this voodoo, different versions of 
                # rss return the data in different places in the data 
                # structure.
                $rss_lite = {channel => $rss_lite};
                if (!($rss->{channel} = 
                      _find_record($rss_lite, qr/^channel$/))) {
                        warn("unable to find channel info for url $url");
                }
                if (!($rss->{items} = _find_record($rss_lite, qr/^items?$/))) {
                        warn("unable to find item info for url $url");
                        $rss->{items} = [];
                }
                
                _strip_html($rss);
                 $rss->{items} = [ $rss->{items} ] unless (ref $rss->{items} eq 'ARRAY');

                _normalize_items($rss->{items});
                
                $cache->set(Storable::freeze($rss), 3600);
        }
        
        return $rss;
}

# rss items don't have a standard date, so timestamp them the first time
# we see them and use that timestamp as the date.  Periodically nuke the
# whole database to keep the thing from growing too large
sub _assign_rss_dates {
        my ($items) = @_;
        
        for my $item (@{$items}) {
                my $key = 'dates:' . ($item->{guid} || $item->{title} || 
                                      $item->{description} || $item->{link});
                my $cache = WebGUI::Cache->new($key, "RSS");
                if (my $date = $cache->get()) {
                        $item->{date} = $date;
                } else {
                        $item->{date} = time();
                        $cache->set($item->{date}, '1 year');
                }
        }
  }

sub _get_aggregate_items {
        my ($urls, $obj, $maxHeadlines) = @_;
        
        my $cache = WebGUI::Cache->new("aggregate:" . 
                                       $obj->get("rssUrl"), "RSS");
        my $items = Storable::thaw($cache->get());
        if (!$items) {
                $items = [];
                my $items_remain = 1;
                
                my @rsss;
                for my $url (@{$urls}) {
                        push(@rsss, _get_rss_data($url));
                }
                
                while ((@{$items} < $maxHeadlines) && $items_remain) {
                        $items_remain = 0;
                        for my $rss (@rsss) {
                                if ($rss->{items} && 
                                    (my $item = shift(@{$rss->{items}}))) {
                                        push(@{$items}, 
                                             {site_title => $rss->{channel}->{title},
                                              site_link => $rss->{channel}->{link},
                                              link => $item->{link},
                                              title => $item->{title},
                                              description => $item->{description},
                                             });
                                        if (@{$rss->{items}}) {
                                                $items_remain = 1;
                                        }
                                }
                        }
                }
                
                _assign_rss_dates($items);
                
                @{$items} = sort { $b->{date} <=> $a->{date} } @{$items};
                
                #if (@{$items} > $_aggregate_size) {
                #  @{$items} = @{$items}[0..($_aggregate_size-1)];
                #}
                
                $cache->set(Storable::freeze($items), 3600);
        }
        
        return $items;
}  

# interleave stories from each feed, up to a total of $_aggregate_size
sub _view_aggregate_feed {
        my ($urls, $obj, $maxHeadlines) = @_;
        
        my %var;
        $var{'channel.title'} = $obj->get("title");
        $var{'channel.description'} = $obj->get("description");
        $var{item_loop} = _get_aggregate_items($urls, $obj, $maxHeadlines);
        
        return $obj->processTemplate($obj->get("templateId"),\%var);
}


#-------------------------------------------------------------------
sub _view_single_feed {
        my $maxHeadlines = $_[1];
        my $rss = _get_rss_data($_[0]->get("rssUrl"));
        my %var;
        $var{"channel.title"} = $rss->{channel}->{title};
        $var{"channel.link"} = $rss->{channel}->{link};
        $var{"channel.description"} = $rss->{description};
        my @items;
        $rss->{items} ||= [];
        for (my $i = 0; ($i < @{$rss->{items}}) && ($i < $maxHeadlines);$i++) {
                my $item = $rss->{items}->[$i];
                push (@items,{
                              link=>$item->{link},
                              title=>$item->{title},
                              description=>$item->{description}
                             });
        }
        $var{item_loop} = \@items;
        return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

sub www_view {
        my $maxHeadlines = $_[0]->get("maxHeadlines") || 1000000;

        my @urls = split(/\s+/,$_[0]->get("rssUrl"));        
        if (@urls == 1) {
                return _view_single_feed($_[0], $maxHeadlines);
        } else {
                return _view_aggregate_feed(\@urls, $_[0], $maxHeadlines);
        }
}


1;

