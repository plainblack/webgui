package WebGUI::Cache;

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

use strict;
use Digest::MD5;
use HTTP::Headers;
use HTTP::Request;
use LWP::UserAgent;
use Memcached::libmemcached;
use Storable ();


=head1 NAME

Package WebGUI::Cache

=head1 DESCRIPTION

An API that allows you to cache items to a memcached server.

=head1 SYNOPSIS

 use WebGUI::Cache;
 
 my $cache = WebGUI::Cache->new($session);

 $cache->set($name, $value);
 $cache->set(\@nameSegments, $value);
 $cache->setByHttp($name, "http://www.google.com/");

 my $value = $cache->get($name);

 $cache->delete($name);

 $cache->flush;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 delete ( name )

Delete a key from the cache.

=head3 name

The key to delete.

=cut

sub delete {
    my ($self, $name) = @_;
    Memcached::libmemcached::memcached_delete($self->getMemcached, $self->parseKey($name));
}

#-------------------------------------------------------------------

=head2 flush ( )

Empties the caching system.

=cut

sub flush {
    my ($self) = @_;
    Memcached::libmemcached::memcached_flush($self->getMemcached);
}

#-------------------------------------------------------------------

=head2 get ( name )

Retrieves a key value from the cache.

=head3 name

The key to retrieve.

=cut

sub get {
    my ($self, $name) = @_;
    my $content = Memcached::libmemcached::memcached_get($self->getMemcached, $self->parseKey($name));
    $content = Storable::thaw($content);
    return undef unless $content && ref $content;
    return ${$content};
}

#-------------------------------------------------------------------

=head2 getMemcached ( )

Returns a reference to the Memcached::libmemcached object.

=cut

sub getMemcached {
    my ($self) = @_;
    return $self->{_memcached};
}


#-------------------------------------------------------------------

=head2 mget ( names )

Retrieves multiple values from cache at once, which is much faster than retrieving one at a time. Returns an array reference containing the values in the order they were requested.

=head3 names

An array reference of keys to retrieve.

=cut

sub mget {
    my ($self, $names) = @_;
    my @parsedNames = ();
    foreach my $name (@{$names}) {
        push @parsedNames, $self->parseKey($name);
    }
    $self->getMemcached->mget_into_hashref($self->getMemcached, \@parsedNames, my $result);
    my @values = ();
    foreach my $name (@{$names}) {
        my $parsedName = shift @parsedNames;
        push @values, ${$result->{$parsedName}};
    }
    return \@values;
}

#-------------------------------------------------------------------

=head2 new ( session, [ namespace ] )

The new method will return a handler for the configured caching mechanism.  Defaults to WebGUI::Cache::FileCache. You must override this method when building your own cache plug-in.

=head3 session

A reference to the current session.

=head3 namespace

A subdivider to store this cache under. When building your own cache plug-in default this to the WebGUI config file.

=cut

sub new {
    my ($class, $session, $namespace) = @_;
    my $config = $session->config;
    $namespace ||= $config->getFilename;
    my $memcached = Memcached::libmemcached::memcached_create();
    foreach my $server (@{$config->get('cacheServers')}) {
        if (exists $server->{socket}) {
            Memcached::libmemcached::memcached_server_add_unix_socket($memcached, $server->{socket});
        }
        else {
            Memcached::libmemcached::memcached_server_add($memcached, $server->{host}, $server->{port});
        }
    }
    bless {_memcached => $memcached, _namespace => $namespace, _sesssion => $session}, $class;
}

#-------------------------------------------------------------------

=head2 parseKey ( name ) 

Returns a formatted string version of the key.

=head3 name

Can either be a text key, or a composite key. If it's a composite key, it will be an array reference of strings that can be joined together to create a key. You might want to use a composite key in order to be able to delete large portions of cache all at once. For instance, if you have a key of ["asset","abc","def"] you can delete all cache matching ["asset","abc"].

=cut

sub parseKey {
    my ($self, $name) = @_;

    # prepend namespace to the key
    my @key = ($self->{_namespace});

    # check for composite or simple key, make array from either
    if (! $name) {
        # throw exception because no key was specified
    }
    elsif (ref $name eq 'ARRAY') {
        push @key, @{ $name };
    }
    else {
        push @key, $name;
    }

    # merge key parts
    return join(':', @key);
}

#-------------------------------------------------------------------

=head2 session ( ) 

Returns a reference to the current session.

=cut

sub session {
    my ($self) = @_;
    $self->{_session};
}

#-------------------------------------------------------------------

=head2 set ( name, value [, ttl] )

Sets a key value to the cache.

=head3 name

The name of the key to set.

=head3 value

A scalar value to store. You can also pass a hash reference or an array reference. 

=head3 ttl

A time in seconds for the cache to exist. When you override default it to 60 seconds.

=cut

sub set {
    my ($self, $name, $value, $ttl) = @_;
    $ttl ||= 60;
    $value = Storable::nfreeze(\(scalar $value)); # Storable doesn't like non-reference arguments, so we wrap it in a scalar ref.
    Memcached::libmemcached::memcached_set($self->getMemcached, $self->parseKey($name), $value, $ttl);
    return $value;
}


#-------------------------------------------------------------------

=head2 setByHttp ( name, url [, ttl ] )

Retrieves a document via HTTP and stores it in the cache and returns the content as a string. No need to override.

=head3 name

The name of the key to store the request under.

=head3 url

The URL of the document to retrieve. It must begin with the standard "http://".

=head3 ttl

The time to live for this content. This is the amount of time (in seconds) that the content will remain in the cache. Defaults to "60".

=cut

sub setByHttp {
    my ($self, $name, $url, $ttl) = @_;
    my $userAgent = new LWP::UserAgent;
	$userAgent->env_proxy;
    $userAgent->agent("WebGUI/".$WebGUI::VERSION);
    $userAgent->timeout(30);
    my $request = HTTP::Request->new(GET => $url);
    my $response = $userAgent->request($request);
    if ($response->is_error) {
        $self->session->log->error($url." could not be retrieved.");
        # show throw exception
        return undef;
    }
    return $self->set($response->decoded_content, $ttl);
}

#-------------------------------------------------------------------

=head2 stats ( )

Return a formatted text string describing cache usage. Must be overridden.

=cut

sub stats {

}


1;


