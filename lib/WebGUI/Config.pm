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
use Class::InsideOut qw(readonly id register);
use Cwd ();
use base 'Config::JSON';

my %config = ();

=head1 NAME

Package WebGUI::Config

=head1 DESCRIPTION

This package parses the WebGUI config file.

=head1 SYNOPSIS

 use WebGUI::Config;

 WebGUI::Config->loadAllConfigs($webguiRoot);
 
 my $configs = WebGUI::Config->readAllConfigs($webguiRoot);

 my $config = WebGUI::Config->new($webguiRoot, $configFileName);

 my $value = $config->get($param);
 $config->set($param,$value);

 $config->delete($param);
 $config->deleteFromHash($name, $key);
 $config->deleteFromArray($name, $value);

 $config->addToHash($name, $key, $value);
 $config->addToArray($name, $value);

 my $configFileName = $config->getFilename;
 my $webguiRoot = $config->getWebguiRoot;

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

=head2 getWebguiRoot ( )

Returns the path to the WebGUI installation.

=cut

readonly getWebguiRoot => my %webguiRoot;


#-------------------------------------------------------------------

=head2 loadAllConfigs ( webguiRoot )

Reads all the config file data for all defined sites into an in-memory cache. This is a class method.

=head3 webguiRoot

The path to the WebGUI installation.

=cut

sub loadAllConfigs {
	my $class = shift;
	my $webguiPath = shift;
	my $configs = $class->readAllConfigs($webguiPath);
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
	my $webguiPath = Cwd::realpath(shift);
	my $filename = shift;
	my $noCache = shift;
    my $fullPath = Cwd::realpath($webguiPath.'/etc/'.$filename);
	if ($config{$fullPath}) {
		return $config{$fullPath};
	} else {
        my $self = Config::JSON->new($fullPath);
        register($self, $class);
        $webguiRoot{id $self} = $webguiPath;
		$config{$filename} = $self unless $noCache;
		return $self;
	}
}


#-------------------------------------------------------------------

=head2 readAllConfigs ( webguiRoot )

Reads all the config file data for all defined sites and returns a hash reference containing WebGUI::Config objects keyed by filename. This is a class method.

Example: $configs->{$filename};

=head3 webguiRoot

The path to the WebGUI installation.

=cut

sub readAllConfigs {
	my $class = shift;
	my $webguiPath = shift;
    opendir my $dh, $webguiPath."/etc";
    my @files = readdir $dh;
    closedir $dh;
	my %configs;
	foreach my $file (@files) {
        next
            if $file !~ /\.conf$/
            || $file =~ /^\./
            || $file eq 'log.conf'
            || $file eq 'spectre.conf';
        eval {
            $configs{$file} = WebGUI::Config->new($webguiPath,$file)
        };
        if ($@) {
            warn "Config file ".$file." looks to be corrupt or have a syntax error.";
        }
    }
    return \%configs;
}


1;

