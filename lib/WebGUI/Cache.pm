package WebGUI::Cache;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


#Test to see if Cache::FileCache will load.
my $hasCache=1;
eval " use Cache::FileCache; "; $hasCache=0 if $@;

use HTTP::Request;
use LWP::UserAgent;
use WebGUI::Session;


=head1 NAME

Package WebGUI::Cache

=head1 DESCRIPTION

This package provides a means for WebGUI to cache data to the filesystem. Caching is only enabled, however, if Cache::Filecache is installed on the system.

=head1 SYNOPSIS

 use WebGUI::Cache;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub _canCache {
	return ($hasCache);
}



#-------------------------------------------------------------------

=head2 delete ( )

Remove content from the filesystem cache.

=cut

sub delete {
        if (_canCache()) {
                $_[0]->{_cache}->remove($_[0]->{_key});
        } else {
                $_[0]->{_cache} = "";
        }
}


#-------------------------------------------------------------------

=head2 get ( )

Retrieve content from the filesystem cache.

=cut

sub get {
        if (_canCache()) {
                return $_[0]->{_cache}->get($_[0]->{_key});
        } else {
                return $_[0]->{_cache};
        }
}



#-------------------------------------------------------------------

=head2 new ( key [, namespace ]  )

Constructor.

=over

=item key 

A key unique to this namespace. It is used to uniquely identify the cached content.

=item namespace

Defaults to the database DSN for your WebGUI database. The only reason to override the default is if you want the cached content to be shared among all WebGUI instances on this machine.

=back

=cut

sub new {
	my $cache;
	my $class = shift;
	my $key = shift;
	my $namespace = shift || $session{config}{dsn};
	$cache = new Cache::FileCache({'namespace'=>$namespace}) if (_canCache());
	bless {_cache => $cache, _key => $key}, $class;
}


#-------------------------------------------------------------------

=head2 set ( content [, ttl ] )

Save content to the filesystem cache.

=over

=item content

A scalar variable containing the content to be set.

=item ttl

The time to live for this content. This is the amount of time (in seconds) that the content will remain in the cache. Defaults to "60".

=back

=cut

sub set {
	my $ttl = $_[2] || 60;
	if (_canCache()) {
		$_[0]->{_cache}->set($_[0]->{_key},$_[1],$ttl);
	} else {
		$_[0]->{_cache} = $_[1];
	}
}


#-------------------------------------------------------------------

=head2 setByHTTP ( url [, ttl ] )

Retrieves a document via HTTP and stores it in the cache.

=over

=item url

The URL of the document to retrieve. It must begin with the standard "http://".

=item ttl

The time to live for this content. This is the amount of time (in seconds) that the content will remain in the cache. Defaults to "60".

=cut

sub setByHTTP {
	my $userAgent = new LWP::UserAgent;
        $userAgent->agent("WebGUI/".$WebGUI::VERSION);
        $userAgent->timeout(30);
        my $request = new HTTP::Request (GET => $_[1]);
        my $response = $userAgent->request($request);
	$_[0]->set($response->content,$_[2]);
}



1;


