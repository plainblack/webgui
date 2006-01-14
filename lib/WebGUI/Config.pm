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
use Parse::PlainConfig;
use WebGUI::Utility;

our %config;

=head1 NAME

Package WebGUI::Config

=head1 DESCRIPTION

This package parses the WebGUI config file.

=head1 SYNOPSIS

 use WebGUI::Config;

 $hashRef = WebGUI::Config::getConfig($webguiRoot, $configFile);
 $hashRef = WebGUI::Config::readConfig($webguiRoot, $configFile);

 WebGUI::Config::loadAllConfigs($webguiRoot);

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 get ( param ) 

Returns the value of a particular parameter from the config file.

=head3 param

The name of the parameter to return.

=cut

sub get {
	my $self = shift;
	my $param = shift;
	my $value = $self->{_config}->get($param);
	if (isIn($param, qw(sitename assets utilityAssets assetContainers authMethods shippingPlugins paymentPlugins))) {
		if (ref $value ne "ARRAY") {
                        $value = [$value];
                }
	} elsif (isIn($param, qw(assetAddPrivilege macros))) {
		if (ref $value ne "HASH") {
                        $value = {};
                }
	}
	return $value;
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
	my $configs = readAllConfigs($webguiPath);
	foreach my $filename (keys %{$configs}) {
		unless ($filename =~ /^demo\d/) {
			print "\tLoading ".$filename."\n";	
			$config{$filename} = $configs->{$filename};
		}
	}
}


#-------------------------------------------------------------------

=head2 new ( webguiRoot , configFile )

Returns a hash reference containing the configuration data. It tries to get the data out of the memory cache first, but reads the config file directly if necessary.

=head3 webguiRoot

The path to the WebGUI installation.

=head3 configFile

The filename of the config file to read.

=cut

sub new {
	my $class = shift;
	my $webguiPath = shift;
	my $filename = shift;
	if (exists $config{$filename}) {
		return $config{$filename};
	} else {
		my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $webguiPath.'/etc/'.$filename, 'PURGE' => 1);
		my $self = {_webguiRoot=>$webguiPath, _configFile=>$filename, _config=>$config};
		bless $self, $class;
		$config{$filename} = $self;
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

sub DESTROY {
	my ($self) = @_;
	undef $self;
}

1;

