package WebGUI::Cache;

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

use WebGUI::Cache::FileCache;
use WebGUI::Session;
use File::Path;

=head1 NAME

Package WebGUI::Cache

=head1 DESCRIPTION

A base class for all Cache modules to extend.

=head1 SYNOPSIS

 use WebGUI::Cache;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 flush ( )

Flushes the caching system.

=cut

sub flush {
	rmtree($session{config}{uploadsPath}.$session{os}{slash}."temp");
}


#-------------------------------------------------------------------

=head2 new ( otions )

The new method will return a handler for the configured caching mechanism.
Defaults to WebGUI::Cache::FileCache.

=head3 options 

Options to pass to the new constructor. See the caching methods in WebGUI/Cache/*
for documentation of the options.

=cut

sub new {
	my $cache;
	my $class = shift;
	if($session{config}{memcached_servers}) {
		use WebGUI::Cache::Memcached;
		return WebGUI::Cache::Memcached->new(@_);
	} else {
		return WebGUI::Cache::FileCache->new(@_);
	}
}

1;


