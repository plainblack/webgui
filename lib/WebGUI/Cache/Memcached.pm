package WebGUI::Cache::Memcached;

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

use WebGUI::Cache::Memcached;
use Digest::MD5;

our @ISA = qw(WebGUI::Cache);

=head1 NAME

Package WebGUI::Cache::Memcached

=head1 DESCRIPTION

This package provides an interface to the memcached distributed caching system.
See http://www.danga.com/memcached/ for more details on memcached.

=head1 SYNOPSIS

 use WebGUI::Cache::Memcached;

=head1 METHODS

These methods are available from this class:

=cut




#-------------------------------------------------------------------

=head2 delete ( )

Deletes a key of the Memcached system.

=cut

sub delete {
	$_[0]->{_cache}->delete($_[0]->{_key});
}


#-------------------------------------------------------------------

=head2 flush ( )

Flushes the Memcached system.

=cut

sub flush {
	my $self = shift;
        $self->SUPER::flush();
        my $memd = $self->{_cache};
	my $succes = 1;
        $memd->init_buckets() unless $memd->{'buckets'};
        my @hosts = @{$memd->{'buckets'}};
        foreach my $host (@hosts) {
                my $sock = $memd->sock_to_host($host);
                my @res = $memd->run_command($sock, "flush_all\r\n");
                $success = 0 unless (@res);
		# Reset stats
                $memd->run_command($sock, "stats reset\r\n");
        }
	return $success;
}

#-------------------------------------------------------------------

=head2 get ( )

Retrieve content from the filesystem cache.

=cut

sub get {
		return undef if ($_[0]->session->get("disableCache"));
                return $_[0]->{_cache}->get($_[0]->{_key});
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
	my $key = $class->parseKey(shift);
	my $namespace = shift || $session->config->getFilename;

	# Overcome maximum key length of 255 characters 
	if(length($key.$namespace) > 255) {
		$key = Digest::MD5::md5_base64($key); 
	}

	my $servers = $session->config->get("memcached_servers");
	$servers = [ $servers ] unless (ref $servers);

	my %options = (
		namespace=>$namespace,
		servers=>$servers
		);

	$cache = new Cache::Memcached(\%options);
	bless {_session=>$session, _cache => $cache, _key => $key}, $class;
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

=head2 stats ( )

Returns statistic information about the caching system.

=cut

sub stats {
        my $self = shift;
	my $output;
        my $memd = $self->{_cache};
	# There's a bug in the Cache::Memcached->stats function that
	# only returns the first row of statistic data.
	# That's why we issue the stats command ourselve.
        $memd->init_buckets() unless $memd->{'buckets'};
        my @hosts = @{$memd->{'buckets'}};
        foreach my $host (@hosts) {
		$output .= "HOST: $host\n";
                my $sock = $memd->sock_to_host($host);
                my @res = $memd->run_command($sock, "stats\r\n");
		$output .= join("",@res)."\n\n";
		$output =~ s/STAT/    /g;
		$output =~ s/END*//g;
        }
        return $output;
}



1;


