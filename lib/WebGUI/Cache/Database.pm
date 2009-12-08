package WebGUI::Cache::Database;

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
use base "WebGUI::Cache";
use Storable ();

=head1 NAME

Package WebGUI::Cache::Database

=head1 DESCRIPTION

This package provides a means for WebGUI to cache data to the database.

=head1 SYNOPSIS

 use WebGUI::Cache::Database;

=head1 METHODS

These methods are available from this class:

=cut




#-------------------------------------------------------------------

=head2 delete ( )

Remove content from the filesystem cache.

=cut

sub delete {
	my $self = shift;
        $self->{_key} = shift;
	$self->session->db->write("delete from cache where namespace=? and cachekey=?",[$self->{_namespace}, $self->{_key}]);
}

#-------------------------------------------------------------------

=head2 deleteChunk ( key )

Remove a partial composite key from the cache.

=head3 key

A partial composite key to remove.

=cut

sub deleteChunk {
	my $self = shift;
	my $key = $self->parseKey(shift);
	$self->session->db->write("delete from cache where namespace=? and cachekey like ?",[$self->{_namespace}, $key.'%']);
}

#-------------------------------------------------------------------

=head2 flush ( )

Remove all objects from the filecache system.

=cut

sub flush {
	my $self = shift;
	$self->session->db->write("delete from cache where namespace=?",[$self->{_namespace}]);
}

#-------------------------------------------------------------------

=head2 get ( )

Retrieve content from the database cache.

=cut

sub get {
	my $self = shift;
    my $session = $self->session;
	return undef if ($session->config->get("disableCache"));
        $self->{_key} = shift;
    my $sth = $session->db->dbh->prepare("select content from cache where namespace=? and cachekey=? and expires>?");
	$sth->execute($self->{_namespace},$self->{_key},time());
	my $data = $sth->fetchrow_arrayref;
	$sth->finish;
	my $content = $data->[0];
	return undef unless ($content);
	# Storable doesn't like non-reference arguments, so we wrap it in a scalar ref.
    eval {
        $content = Storable::thaw($content);
    };
    return undef unless $content && ref $content;
    return $$content;
}

#-------------------------------------------------------------------

=head2 getNamespaceSize ( )

Returns the size (in bytes) of the current cache under this namespace. Consequently it also cleans up expired cache items.

=cut

sub getNamespaceSize {
        my $self = shift;
        my $expiresModifier = shift || 0;
	$self->session->db->write("delete from cache where expires < ?",[time()+$expiresModifier]);
	my ($size) = $self->session->db->quickArray("select sum(size) from cache where namespace=?",[$self->{_namespace}]);
	return $size;
}

#-------------------------------------------------------------------

=head2 new ( session, key [, namespace ]  )

Constructor.

=head3 session

A reference to the current session.

=head3 key 

A key unique to this namespace. It is used to uniquely identify the cached content.

=head3 namespace

Defaults to the config filename for the current site. The only reason to override the default is if you want the cached content to be shared among all WebGUI instances on this machine. A common alternative namespace is "URL", which is typically used when caching content using the setByHTTP method.

=cut

sub new {
	my $cache;
	my $class = shift;
	my $session = shift;
	my $namespace = shift || $session->config->getFilename;
	bless {_session=>$session, _namespace=>$namespace}, $class;
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
	my $self = shift;
        $self->{_key} = shift;
	# Storable doesn't like non-reference arguments, so we wrap it in a scalar ref.
	my $content = Storable::nfreeze(\(scalar shift));
	my $ttl = shift || 60;
	my $size = length($content);
	# getting better performance using native dbi than webgui sql
	my $dbh = $self->session->db->dbh;
	my $sth = $dbh->prepare("replace into cache (namespace,cachekey,expires,size,content) values (?,?,?,?,?)");
	$sth->execute($self->{_namespace}, $self->{_key}, time()+$ttl, $size, $content);
	$sth->finish;
}


#-------------------------------------------------------------------

=head2 stats ( )

Returns statistic information about the caching system.

=cut

sub stats {
	my $self = shift;
	my ($size) = $self->session->db->quickArray("select sum(size) from cache where namespace=?",[$self->{_namespace}]);
	return $size." bytes";
}

1;


