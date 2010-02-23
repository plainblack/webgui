package WebGUI::Config;

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
use WebGUI::Paths;
use Cwd ();
use File::Spec;
use base 'Config::JSON';

my %config = ();

=head1 NAME

Package WebGUI::Config

=head1 DESCRIPTION

This package parses the WebGUI config file.

=head1 SYNOPSIS

 use WebGUI::Config;

 WebGUI::Config->loadAllConfigs($webguiRoot);
 
 my $configs = WebGUI::Config->readAllConfigs;

 my $config = WebGUI::Config->new($configFileName);

 my $value = $config->get($param);
 $config->set($param,$value);

 $config->delete($param);
 $config->deleteFromHash($name, $key);
 $config->deleteFromArray($name, $value);

 $config->addToHash($name, $key, $value);
 $config->addToArray($name, $value);

 my $configFileName = $config->getFilename;

=head1 ISA

Config::JSON

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 clearCache ( ) 

Clear the cache of in-memory configuration files.  This is required by the upgrade script, which
forks to run each upgrade.  When the child is reaped, the original is untouched, so that the
next script in the line recieves an old, in-memory config, essentially undoing any config
changes in the first upgrade script.

This is a class method.

=cut

sub clearCache {
	my $class = shift;
    %config = ();
}

#-------------------------------------------------------------------

=head2 getCookieName ( ) 

Returns the cookie name defined in the config file. Returns "wgSession" if one isn't defined.

=cut

sub getCookieName {
	my $self = shift;
	return $self->get("cookieName") || "wgSession";	
}

#-------------------------------------------------------------------

=head2 getCookieTTL ( ) 

Returns the cookie time to live defined in the config file. Returns "+10y" if one isn't defined.
This may also be "session" to indicate that the cookie should only live for the current browser
session.

=cut

sub getCookieTTL {
	my $self = shift;
	my $configTTL = $self->get("cookieTTL");
	return defined($configTTL)? $configTTL : "+10y";
}

#-------------------------------------------------------------------

=head2 loadAllConfigs ( webguiRoot )

Reads all the config file data for all defined sites into an in-memory cache. This is a class method.

=head3 webguiRoot

The path to the WebGUI installation.

=cut

sub loadAllConfigs {
	my $class = shift;
	my $configs = $class->readAllConfigs;
	foreach my $filename (keys %{$configs}) {
		unless ($filename =~ /^demo\d/) {
			print "\tLoading ".$filename."\n";	
			$config{$filename} = $configs->{$filename};
		}
	}
}


#-------------------------------------------------------------------

=head2 new ( webguiRoot , configFile [ , noCache ] )

Returns a hash reference containing the configuration data. It tries to get the data out of the memory cache first, but reads the config file directly if necessary.

=head3 webguiRoot

The path to the WebGUI installation.

=head3 configFile

The filename of the config file to read.

=head3 noCache

A boolean value that when set to true tells the config system not to store the config in an in memory cache, in case it's loaded again later. This is mostly used when loading utility configs, like spectre.conf.

=cut

sub new {
    my $class = shift;
    my $filename = shift;
    my $noCache = shift;
    if (!File::Spec->file_name_is_absolute($filename)) {
        Cwd::realpath($filename = File::Spec->catfile(WebGUI::Paths->configBase, $filename));
    }
    if (exists $config{$filename}) {
        return $config{$filename};
    }
    else {
        my $self = $class->SUPER::new($fullPath);
        $config{$filename} = $self unless $noCache;
        return $self;
    }
}


#-------------------------------------------------------------------

=head2 readAllConfigs ( )

Reads all the config file data for all defined sites and returns a hash reference containing WebGUI::Config objects keyed by filename. This is a class method.

Example: $configs->{$filename};

=cut

sub readAllConfigs {
	my $class = shift;
    my @configs = WebGUI::Paths->siteConfigs;
    my %configs = map {
        $_ => $class->new($_);
    } @configs
    return \%configs;
}


1;

