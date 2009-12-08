package WebGUI::Cache::FileCache;

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
use Storable ();
use File::Path ();
use File::Find ();

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
	my $self = shift;
        $self->{_key} = shift;
	my $folder = $self->getFolder;
	if (-e $folder) {
		File::Path::rmtree($folder);
	}
}

#-------------------------------------------------------------------

=head2 deleteChunk ( key )

Remove a partial composite key from the cache.

=head3 key

A partial composite key to remove.

=cut

sub deleteChunk {
	my $self = shift;
	my $folder = $self->getNamespaceRoot."/".$self->parseKey(shift);
	if (-e $folder) {
		File::Path::rmtree($folder);
	}
}

#-------------------------------------------------------------------

=head2 flush ( )

Remove all objects from the filecache system.

=cut

sub flush {
	my $self = shift;
	my $folder = $self->getNamespaceRoot;
	if (-e $folder) {
		File::Path::rmtree($folder);
	}
}

#-------------------------------------------------------------------

=head2 get ( )

Retrieve content from the filesystem cache.

=cut

sub get {
	my $self = shift;
	return undef if ($self->session->config->get("disableCache"));
        $self->{_key} = shift;
	my $folder = $self->getFolder;
	if (-e $folder."/expires" && -e $folder."/cache" && open(my $FILE,"<",$folder."/expires")) {
		my $expires = <$FILE>;
		close($FILE);
		return undef if ($expires < time);
		my $value;
		eval {$value = Storable::retrieve($folder."/cache")};
		if (ref $value eq "SCALAR") {
			return $$value;
		} else {
			return $value;
		}
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 getFolder ( )

Returns the path to the cache folder for this key.

=cut

sub getFolder {
	my $self = shift;
	return $self->getNamespaceRoot()."/".$self->{_key};
}

#-------------------------------------------------------------------

=head2 getNamespaceRoot ( )

Figures out what the cache root for this namespace should be. A class method.

=cut

sub getNamespaceRoot {
	my $self = shift;
	my $root = $self->session->config->get("fileCacheRoot");
	unless ($root) {
		if ($self->session->os->get("windowsish")) {
			$root = $self->session->env->get("TEMP") || $self->session->env->get("TMP") || "/temp";
		} else {
			$root = "/tmp";
		}
		$root .= "/WebGUICache";
	}
	$root .= "/".$self->{_namespace};
	return $root;
}

#-------------------------------------------------------------------

=head2 getNamespaceSize ( )

Returns the size (in bytes) of the current cache under this namespace. Consequently it also cleans up expired cache items.

=cut

sub getNamespaceSize {
    my $self = shift;
    my $expiresModifier = shift || 0;
    my $cacheSize = 0;
    File::Find::find({
        no_chdir => 1,
        wanted => sub {
            return
                unless $File::Find::name =~ m/expires$/;
            if ( open my $FILE, "<", $File::Find::name ) {
                my $expires = <$FILE>;
                close $FILE;
                if ($expires < time + $expiresModifier) {
                    File::Path::rmtree($File::Find::dir);
                    $File::Find::prune = 1;
                    return
                }
                else {
                    $cacheSize += -s $File::Find::dir.'/cache';
                }
            }
        },
    }, $self->getNamespaceRoot);
    return $cacheSize;
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
	my $content = shift;
	my $ttl = shift || 60;
	my $oldumask = umask();
	umask(0000);
	my $path = $self->getFolder();
	unless (-e $path) {
		eval {File::Path::mkpath($path,0)};
		if ($@) {
			$self->session->errorHandler->error("Couldn't create cache folder: ".$path." : ".$@);
			return undef;
		}
	}
	my $value;
	unless (ref $content) {
		$value = \$content;
	} else {
		$value = $content;
	}
	Storable::nstore($value, $path."/cache");
	open my $FILE, ">", $path."/expires";
	print $FILE time + $ttl;
	close $FILE;
	umask($oldumask);
}


#-------------------------------------------------------------------

=head2 stats ( )

Returns statistic information about the caching system.

=cut

sub stats {
	my $self = shift;
	return $self->getNamespaceSize." bytes";
}

1;


