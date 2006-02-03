package WebGUI::Config;

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

use strict;
use JSON;
use WebGUI::Utility;

our %config;

=head1 NAME

Package WebGUI::Config

=head1 DESCRIPTION

This package parses the WebGUI config file.

=head1 SYNOPSIS

 use WebGUI::Config;

 WebGUI::Config::loadAllConfigs($webguiRoot);
 
 my $configs = WebGUI::Config::readAllConfigs($webguiRoot);

 my $config = WebGUI::Config->new($webguiRoot, $configFileName);

 my $value = $config->get($param);
 $config->set($param,$value);
 $config->delete($param);

 my $configFileName = $config->getFilename;
 my $webguiRoot = $config->getWebguiRoot;

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 delete ( param ) 

Deletes a key from the config file.

=head3 param

The name of the parameter to delete.

=cut

sub delete {
	my $self = shift;
	my $param = shift;
	delete $self->{_config}{$param};
	open(FILE,">".$self->getWebguiRoot.'/etc/'.$self->getFilename);
	print FILE "# config-file-type: JSON 1\n".objToJson($self->{_config}, {pretty => 1, indent => 2});
	close(FILE);
}

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}

#-------------------------------------------------------------------

=head2 get ( param ) 

Returns the value of a particular parameter from the config file.

=head3 param

The name of the parameter to return.

=cut

sub get {
	my $self = shift;
	my $param = shift;
	return $self->{_config}{$param};
}


#-------------------------------------------------------------------

=head2 getFilename ( )

Returns the filename for this config.

=cut

sub getFilename {
	my $self = shift;
	return $self->{_configFile};
}

#-------------------------------------------------------------------

=head2 getWebguiRoot ( )

Returns the path to the WebGUI installation.

=cut

sub getWebguiRoot {
	my $self = shift;
	return $self->{_webguiRoot};
}


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
	my $webguiPath = shift;
	my $filename = shift;
	my $noCache = shift;
	if (exists $config{$filename}) {
		return $config{$filename};
	} else {
		my $json = "";
		open(FILE,"<".$webguiPath.'/etc/'.$filename);
		while (my $line = <FILE>) {
        		$json .= $line unless ($line =~ /^\s*#/);
		}
		close(FILE);
		my $conf = jsonToObj($json);
		my $self = {_webguiRoot=>$webguiPath, _configFile=>$filename, _config=>$conf};
		bless $self, $class;
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
	opendir(DIR,$webguiPath."/etc");
	my @files = readdir(DIR);
	closedir(DIR);
	my %configs;
	foreach my $file (@files) {
		if ($file =~ /\.conf$/ && !($file =~ /^log\.conf$/) && !($file =~ /^spectre\.conf$/)) {
			$configs{$file} = WebGUI::Config->new($webguiPath,$file);
		}
	}
	return \%configs;
}


#-------------------------------------------------------------------

=head2 set ( param, value ) 

Creates a new or updates an existing parameter in the config file.

=head3 param

A parameter name.

=head3 value

The value to set the paraemter to. Can be a scalar, hash reference, or array reference.

=cut

sub set {
	my $self = shift;
	my $param = shift;
	my $value = shift;
	$self->{_config}{$param} = $value;
	open(FILE,">".$self->getWebguiRoot.'/etc/'.$self->getFilename);
	print FILE "# config-file-type: JSON 1\n".objToJson($self->{_config}, {pretty => 1, indent => 2});
	close(FILE);
}

1;

