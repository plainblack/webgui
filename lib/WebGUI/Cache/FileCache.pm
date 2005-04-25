package WebGUI::Cache::FileCache;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Cache::FileCache;

use HTTP::Headers;
use HTTP::Request;
use LWP::UserAgent;
use WebGUI::ErrorHandler;
use WebGUI::Session;

our @ISA = qw(WebGUI::Cache);

=head1 NAME

Package WebGUI::Cache::FileCache

=head1 DESCRIPTION

This package provides a means for WebGUI to cache data to the filesystem. 

=head1 SYNOPSIS

 use WebGUI::Cache::FileCache;

=head1 METHODS

These methods are available from this class:

=cut




#-------------------------------------------------------------------

=head2 delete ( )

Remove content from the filesystem cache.

=cut

sub delete {
	$_[0]->{_cache}->remove($_[0]->{_key});
}


#-------------------------------------------------------------------

=head2 deleteByRegex ( regex )

Remove content from the filesystem cache where the key meets the condition of the regular expression.

=head3 regex

A regular expression that will match keys in the current namespace. Example: m/^navigation_.*/

=cut

sub deleteByRegex {
		my @keys = $_[0]->{_cache}->get_keys();
		foreach my $key (@keys) {
			if ($key =~ $_[1]) {
                		$_[0]->{_cache}->remove($key);
			}
		}
}

#-------------------------------------------------------------------

=head2 flush ( )

Remove all objects from the filecache system.

=cut

sub flush {
		my $self = shift;
		$self->SUPER::flush();
                return $self->{_cache}->Clear;
}

#-------------------------------------------------------------------

=head2 get ( )

Retrieve content from the filesystem cache.

=cut

sub get {
                return $_[0]->{_cache}->get($_[0]->{_key});
}

#-------------------------------------------------------------------

=head2 new ( key [, namespace ]  )

Constructor.

=head3 key 

A key unique to this namespace. It is used to uniquely identify the cached content.

=head3 namespace

Defaults to the config filename for the current site. The only reason to override the default is if you want the cached content to be shared among all WebGUI instances on this machine. A common alternative namespace is "URL", which is typically used when caching content using the setByHTTP method.

=cut

sub new {
	my $cache;
	my $class = shift;
	my $key = shift;
	my $namespace = shift || $session{config}{configFile};
	my %options = (
		namespace=>$namespace, 
		auto_purge_on_set=>1
		);
	$options{cache_root} = $session{config}{fileCacheRoot} if ($session{config}{fileCacheRoot});
	$cache = new Cache::FileCache(\%options);
	bless {_cache => $cache, _key => $key}, $class;
}


#-------------------------------------------------------------------

=head2 set ( content [, ttl ] )

Save content to the filesystem cache.

=head3 content

A scalar variable containing the content to be set.

=head3 ttl

The time to live for this content. This is the amount of time (in seconds) that the content will remain in the cache. Defaults to "60".

=cut

sub set {
	my $ttl = $_[2] || 60;
		$_[0]->{_cache}->set($_[0]->{_key},$_[1],$ttl);
}


#-------------------------------------------------------------------

=head2 setByHTTP ( url [, ttl ] )

Retrieves a document via HTTP and stores it in the cache and returns the content as a string.

=head3 url

The URL of the document to retrieve. It must begin with the standard "http://".

=head3 ttl

The time to live for this content. This is the amount of time (in seconds) that the content will remain in the cache. Defaults to "60".

=cut

sub setByHTTP {
	my $userAgent = new LWP::UserAgent;
        $userAgent->agent("WebGUI/".$WebGUI::VERSION);
        $userAgent->timeout(30);
	my $header = new HTTP::Headers;
        my $referer = "http://webgui.http.request/".$session{env}{SERVER_NAME}.$session{env}{REQUEST_URI};
        chomp $referer;
        $header->referer($referer);
        my $request = new HTTP::Request (GET => $_[1], $header);
        my $response = $userAgent->request($request);
	if ($response->is_error) {
		WebGUI::ErrorHandler::warn($_[1]." could not be retrieved.");
	} else {
		$_[0]->set($response->content,$_[2]);
	}
	return $response->content;
}

#-------------------------------------------------------------------

=head2 stats ( )

Returns statistic information about the caching system.

=cut

sub stats {
        my $self = shift;
        my $output;
	$output = "Total size of file cache: ".$self->{_cache}->Size()." bytes\n";
	foreach my $namespace ($self->{_cache}->get_namespaces) {
		$self->{_cache}->set_namespace($namespace);
		$output .= "\t$namespace : ".($self->{_cache}->get_keys).
				" items / ".$self->{_cache}->size()." bytes\n";
	}
        return $output;
}


1;


