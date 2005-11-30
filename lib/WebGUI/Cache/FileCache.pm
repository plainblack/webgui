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


use Storable qw(nstore retrieve);
use WebGUI::Session;
use File::Path;
use File::Find;

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
	my $folder = $self->getFolder;
	if (-e $folder) {
		rmtree($folder);
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
		rmtree($folder);
	}
}

#-------------------------------------------------------------------

=head2 flush ( )

Remove all objects from the filecache system.

=cut

sub flush {
	my $self = shift;
	$self->SUPER::flush();
	my $folder = $self->getNamespaceRoot;
	if (-e $folder) {
		rmtree($folder);
	}
}

#-------------------------------------------------------------------

=head2 get ( )

Retrieve content from the filesystem cache.

=cut

sub get {
	my $self = shift;
	return undef if ($WebGUI::Session::session{config}{disableCache});
	my $folder = $self->getFolder;
	if (-e $folder."/expires" && -e $folder."/cache" && open(FILE,"<".$folder."/expires")) {
		my $expires = <FILE>;
		close(FILE);
		return undef if ($expires < time());
		my $value;
		eval {$value = retrieve($folder."/cache")};
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

=head2 getNamepsaceRoot ( )

Figures out what the cache root for this namespace should be. A class method.

=cut

sub getNamespaceRoot {
	my $self = shift;
	my $root = $WebGUI::Session::session{config}{fileCacheRoot};
	unless ($root) {
		if ($WebGUI::Session::session{os}{windowsish}) {
			$root = $WebGUI::Session::session{env}{TEMP} || $WebGUI::Session::session{env}{TMP} || "/temp";
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

#-------------------------------------------------------------------

=head2 getNamespaceSize ( )

Returns the size (in bytes) of the current cache under this namespace. Consequently it also cleans up expired cache items.

=cut

sub getNamespaceSize {
        my $self = shift;
        my $expiresModifier = shift || 0;
        $session{cacheSize} = 0;
        File::Find::find({no_chdir=>1, wanted=> sub {
                                return unless $File::Find::name =~ m/^(.*)expires$/;
                                my $dir = $1;
                                if (open(FILE,"<".$dir."/expires")) {
                                        my $expires = <FILE>;
                                        close(FILE);
                                        if ($expires < time()+$expiresModifier) {
                                                rmtree($dir);
                                        } else {
                                                $session{cacheSize} += -s $dir.'cache';
                                        }
                                }
                        }
                }, $self->getNamespaceRoot);
        return $session{cacheSize};
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
	my $key = $class->parseKey(shift);
	my $namespace = shift || $WebGUI::Session::session{config}{configFile};
	bless {_key=>$key, _namespace=>$namespace}, $class;
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
	my $content = shift;
	my $ttl = shift || 60;
	my $oldumask = umask();
	umask(0000);
	my $path = $self->getFolder();
	unless (-e $path) {
		eval {mkpath($path,0)};
		if ($@) {
			WebGUI::ErrorHandler::error("Couldn't create cache folder: ".$path." : ".$@);
			return;
		}
	}
	my $value;
	unless (ref $content) {
		$value = \$content;
	} else {
		$value = $content;
	}
	nstore($value, $path."/cache");
	open(FILE,">".$path."/expires");
	print FILE time()+$ttl;
	close(FILE);
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


