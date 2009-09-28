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
use WebGUI::Exception;
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );



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
 my ($val1, $val2) = @{$cache->mget([$name1, $name2])};

 $cache->delete($name);

 $cache->flush;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 delete ( name )

Delete a key from the cache.

Throws WebGUI::Error::InvalidParam, WebGUI::Error::Connection and WebGUI::Error.

=head3 name

The key to delete.

=cut

sub delete {
    my $self = shift;
    my $debug = $self->withDebug;
    my ($name) = ($debug) ? validate_pos(@_, { type => SCALAR | ARRAYREF }) : @_;
    my $key = $self->parseKey($name);
    if ($debug) {
        $self->session->log->debug("Called delete() on cache key $key.");
    }
    my $memcached = $self->getMemcached;
    Memcached::libmemcached::memcached_delete($memcached, $key);
    if ($debug) {
        my $log = $self->session->log;
        if ($memcached->errstr eq 'SYSTEM ERROR Unknown error: 0') {
            $log->debug("Cannot connect to memcached server.");
            WebGUI::Error::Connection->throw(
                error   => "Cannot connect to memcached server."
                );
        }
        elsif ($memcached->errstr eq 'NO SERVERS DEFINED') {
            $log->warn("No memcached servers specified in config file.");
            WebGUI::Error->throw(
                error   => "No memcached servers specified in config file."
                );
        }
        elsif ($memcached->errstr ne 'SUCCESS' # deleted
            && $memcached->errstr ne 'PROTOCOL ERROR' # doesn't exist to delete
            ) {
            $log->debug("Couldn't delete $key from cache because ".$memcached->errstr);
            WebGUI::Error->throw(
                error   => "Couldn't delete $key from cache because ".$memcached->errstr
                );
        }
    }
}

#-------------------------------------------------------------------

=head2 flush ( )

Empties the caching system.

Throws WebGUI::Error::Connection and WebGUI::Error.

=cut

sub flush {
    my ($self) = @_;
    my $debug = $self->withDebug;
    if ($debug) {
        $self->session->log->debug("Called flush() on cache.");
    }
    my $memcached = $self->getMemcached;
    Memcached::libmemcached::memcached_flush($memcached);
    if ($debug) {
        my $log = $self->session->log;
        if ($memcached->errstr eq 'SYSTEM ERROR Unknown error: 0') {
            $log->debug("Cannot connect to memcached server.");
            WebGUI::Error::Connection->throw(
                error   => "Cannot connect to memcached server."
                );
        }
        elsif ($memcached->errstr eq 'NO SERVERS DEFINED') {
            $log->warn("No memcached servers specified in config file.");
            WebGUI::Error->throw(
                error   => "No memcached servers specified in config file."
                );
        }
        elsif ($memcached->errstr ne 'SUCCESS') {
            $log->debug("Couldn't flush cache because ".$memcached->errstr);
            WebGUI::Error->throw(
                error   => "Couldn't flush cache because ".$memcached->errstr
                );
        }
    }
}

#-------------------------------------------------------------------

=head2 get ( name )

Retrieves a key value from the cache.

Throws WebGUI::Error::InvalidObject, WebGUI::Error::InvalidParam, WebGUI::Error::ObjectNotFound, WebGUI::Error::Connection and WebGUI::Error.

=head3 name

The key to retrieve.

=cut

sub get {
    my $self = shift;
    my $debug = $self->withDebug;
    my ($name) = ($debug) ? validate_pos(@_, { type => SCALAR | ARRAYREF }) : @_;
    my $key = $self->parseKey($name);
    if ($debug) {
        $self->session->log->debug("Called get() on cache key $key.");
    }
    my $memcached = $self->getMemcached;
    my $content = Memcached::libmemcached::memcached_get($memcached, $key);
    $content = Storable::thaw($content);
    if ($debug) {
        my $log = $self->session->log;
        if ($memcached->errstr eq 'SUCCESS') {
            unless (ref $content) {
                $log->debug("Couldn't thaw value for $key.");
                WebGUI::Error::InvalidObject->throw(
                    error   => "Couldn't thaw value for $key."
                    );
            }
            return ${$content};
        }
        elsif ($memcached->errstr eq 'NOT FOUND' ) {
            $log->debug("The cache key $key has no value.");
            WebGUI::Error::ObjectNotFound->throw(
                error   => "The cache key $key has no value.",
                id      => $key,
                );
        }
        elsif ($memcached->errstr eq 'NO SERVERS DEFINED') {
            $log->warn("No memcached servers specified in config file.");
            WebGUI::Error->throw(
                error   => "No memcached servers specified in config file."
                );
        }
        elsif ($memcached->errstr eq 'SYSTEM ERROR Unknown error: 0') {
            $log->debug("Cannot connect to memcached server.");
            WebGUI::Error::Connection->throw(
                error   => "Cannot connect to memcached server."
                );
        }
        $log->debug("Couldn't get $key from cache because ".$memcached->errstr);
        WebGUI::Error->throw(
            error   => "Couldn't get $key from cache because ".$memcached->errstr
        );
        return undef;
    }
    return (ref $content) ? ${$content} : undef;
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

Throws WebGUI::Error::InvalidParam, WebGUI::Error::Connection and WebGUI::Error.

=head3 names

An array reference of keys to retrieve.

=cut

sub mget {
    my $self = shift;
    my $debug = $self->withDebug;
    my ($names) = ($debug) ? validate_pos(@_, { type => ARRAYREF }) : @_;
    my @keys = map { $self->parseKey($_) } @{ $names };
    my $log = $self->session->log;
    if ($debug) {
        $log->debug("Called mget() for keys (".join(", ",@keys).") on cache.");
    }
    my %result;
    my $memcached = $self->getMemcached;
    $memcached->mget_into_hashref(\@keys, \%result);
    if ($debug) {
        if ($memcached->errstr eq 'SYSTEM ERROR Unknown error: 0') {
            $log->debug("Cannot connect to memcached server.");
            WebGUI::Error::Connection->throw(
                error   => "Cannot connect to memcached server."
                );
        }
        elsif ($memcached->errstr eq 'NO SERVERS DEFINED') {
            $log->warn("No memcached servers specified in config file.");
            WebGUI::Error->throw(
                error   => "No memcached servers specified in config file."
                );
        }
    }
    # no other useful status messages are returned
    my @values;
    foreach my $key (@keys) {
        my $content = Storable::thaw($result{$key});
        unless (ref $content) {
            $log->debug("Cannot thaw key $key.") if ($debug);
            next;
        }
        push @values, ${$content};
    }
    return \@values;
}

#-------------------------------------------------------------------

=head2 new ( session, withDebug )

Constructor. Will return a handler for the configured caching mechanism.  Defaults to WebGUI::Cache::FileCache. You must override this method when building your own cache plug-in.

Throws WebGUI::Error::InvalidParam.

=head3 session

A reference to the current session.

=head3 withDebug

A boolean indicating you want to enable parameter validation, exception handling, and debug logging. Note that this will make the cahe system up to 3 times slower. It will still be very fast, but not production fast.

=cut

sub new {
    my ($class, $session, $withDebug) = validate_pos(@_, 
        1,
        { isa => 'WebGUI::Session' },
        { type => SCALAR | UNDEF, optional=>1, default=>0 },
        );
    if ($withDebug) {
        my $log = $session->log;
        $log->debug("Instanciated cache object.");
        $log->debug("Cache debugging ".($withDebug ? "enabled" : "disabled").".");
    }
    my $config = $session->config;
    my $namespace = $config->getFilename;
    my $memcached = Memcached::libmemcached::memcached_create(); # no exception because always returns success
    foreach my $server (@{$config->get('cacheServers')}) {
        if (exists $server->{socket}) {
            Memcached::libmemcached::memcached_server_add_unix_socket($memcached, $server->{socket}); # no exception because always returns success
        }
        else {
            Memcached::libmemcached::memcached_server_add($memcached, $server->{host}, $server->{port}); # no exception because always returns success
        }
    }
    bless {_memcached => $memcached, _namespace => $namespace, _session => $session, _withDebug=>$withDebug}, $class;
}

#-------------------------------------------------------------------

=head2 parseKey ( name ) 

Returns a formatted string version of the key.

Throws WebGUI::Error::InvalidParam.

=head3 name

Can either be a text key, or a composite key. If it's a composite key, it will be an array reference of strings that can be joined together to create a key. You might want to use a composite key in order to be able to delete large portions of cache all at once. For instance, if you have a key of ["asset","abc","def"] you can delete all cache matching ["asset","abc"].

=cut

sub parseKey {
    my $self = shift;
    my ($name) = ($self->withDebug) ? validate_pos(@_, { type => SCALAR | ARRAYREF }) : @_;

    # prepend namespace to the key
    my @key = ($self->{_namespace});

    # check for composite or simple key, make array from either
    if (ref $name eq 'ARRAY') {
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

Throws WebGUI::Error::InvalidParam, WebGUI::Error::Connection, and WebGUI::Error.

=head3 name

The name of the key to set.

=head3 value

A scalar value to store. You can also pass a hash reference or an array reference. 

=head3 ttl

A time in seconds for the cache to exist. When you override default it to 60 seconds.

=cut

sub set {
    my $self = shift;
    my $debug = $self->withDebug;
    my ($name, $value, $ttl) = ($debug) ? validate_pos(@_, { type => SCALAR | ARRAYREF }, { type => SCALAR }, { type => SCALAR | UNDEF, optional => 1 }) : @_;
    $ttl ||= 60;
    my $key = $self->parseKey($name);
    if ($debug) {
        $self->session->log->debug("Called set() on cache key $key with $value as the value.");
    }
    my $frozenValue = Storable::nfreeze(\(scalar $value)); # Storable doesn't like non-reference arguments, so we wrap it in a scalar ref.
    my $memcached = $self->getMemcached;
    Memcached::libmemcached::memcached_set($memcached, $key, $frozenValue, $ttl);
    if ($debug) {
        my $log = $self->session->log;
        if ($memcached->errstr eq 'SUCCESS') {
            return $value;
        }
        elsif ($memcached->errstr eq 'SYSTEM ERROR Unknown error: 0') {
            $log->debug("Cannot connect to memcached server.");
            WebGUI::Error::Connection->throw(
                error   => "Cannot connect to memcached server."
                );
        }
        elsif ($memcached->errstr eq 'NO SERVERS DEFINED') {
            $log->warn("No memcached servers specified in config file.");
            WebGUI::Error->throw(
                error   => "No memcached servers specified in config file."
                );
        }
        $log->debug("Couldn't set $key to cache because ".$memcached->errstr);
        WebGUI::Error->throw(
            error   => "Couldn't set $key to cache because ".$memcached->errstr
            );
    }
    return $value;
}


#-------------------------------------------------------------------

=head2 setByHttp ( name, url [, ttl ] )

Retrieves a document via HTTP and stores it in the cache and returns the content as a string. No need to override.

Throws WebGUI::Error::InvalidParam, WebGUI::Error::Connection, and WebGUI::Error.

=head3 url

The URL of the document to retrieve. It must begin with the standard "http://". This will be used as the key for this cache entry.

=head3 ttl

The time to live for this content. This is the amount of time (in seconds) that the content will remain in the cache. Defaults to "60".

=cut

sub setByHttp {
    my $self = shift;
    my $debug = $self->withDebug;
    my ($url, $ttl) = ($debug) ? validate_pos(@_, { type => SCALAR }, { type => SCALAR, optional => 1 }) : @_;
    if ($debug) {
        $self->session->log->debug("Called setByHttp() with URL $url.");
    }
    my $userAgent = new LWP::UserAgent;
	$userAgent->env_proxy;
    $userAgent->agent("WebGUI/".$WebGUI::VERSION);
    $userAgent->timeout(30);
    my $request = HTTP::Request->new(GET => $url);
    my $response = $userAgent->request($request);
    if ($response->is_error) {
        $self->session->log->error("$url could not be retrieved.");
        if ($debug) {
            WebGUI::Error::Connection->throw(
                error       => "Couldn't fetch $url because ".$response->message,
                resource    => $url,
                );
        }
    }
    return $self->set($url, $response->decoded_content, $ttl);
}


#-------------------------------------------------------------------

=head2 withDebug () 

Returns a boolean indicating whether the cache system should log debug, validate parameters, and throw exceptions.

=cut

sub withDebug {
    my $self = shift;
    return $self->{_withDebug};
}



=head1 EXCEPTIONS

This class throws a lot of inconvenient exceptions. However, because cache should be treated as optional, none of them matter except for testing, debugging, or in very specific use cases. Therefore the best practice is to simply call each method with an eval wrapper, and then not even bother testing for specific exceptions like this:

 my $value = eval { $session->cache->get($key) };
 unless (defined $value) {
    $value = $db->fetchValueFromTheDatabase;
 }

If you want to see what exceptions are being thrown, or anything else about the internal operations of the cache system, simply turn on DEBUG mode in your log. Everything you want will be there.

NOTE: In order for exceptions to be thrown and logged with debug must be passed into the constructor. 

The exceptions that can be thrown are:

=head2 WebGUI::Error

When an uknown exception happens, or there are no configured memcahed servers in the cacheServers directive in your config file.

=head2 WebGUI::Error::Connection

When it can't connect to the memcached servers that are configured, or to the http server in the case of the setByHttp method.

=head2 WebGUI::Error::InvalidParam

When you pass in the wrong arguments.

=head2 WebGUI::Error::ObjectNotFound

When you request a cache key that doesn't exist on any configured memcached server.

=head2 WebGUI::Error::InvalidObject

When an object can't be thawed from cache due to corruption of some sort.

=cut


1;


