package WebGUI::Config;

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

use strict;
use Parse::PlainConfig;

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

=head2 getConfig ( webguiRoot , configFile )

Returns a hash reference containing the configuration data. It tries to get the data out of the memory cache first, but reads the config file directly if necessary.

=head3 webguiRoot

The path to the WebGUI installation.

=head3 configFile

The filename of the config file to read.

=cut

sub getConfig {
	my $webguiPath = shift;
	my $filename = shift;
	if (exists $config{$filename}) {
		return $config{$filename};
	} else {
		return readConfig($webguiPath,$filename);
	}
}


#-------------------------------------------------------------------

=head2 loadAllConfigs ( webguiRoot )

Reads all the config file data for all defined sites into an in-memory cache.

=head3 webguiRoot

The path to the WebGUI installation.

=cut

sub loadAllConfigs {
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

=head2 readAllConfigs ( webguiRoot )

Reads all the config file data for all defined sites and returns a hash reference containing the resulting data by config file name.

Example: $configs->{$filename};

=head3 webguiRoot

The path to the WebGUI installation.

=cut

sub readAllConfigs {
	my $webguiPath = shift;
	opendir(DIR,$webguiPath."/etc");
	my @files = readdir(DIR);
	closedir(DIR);
	my %configs;
	foreach my $file (@files) {
		if ($file =~ /\.conf$/ && !($file =~ /^log.conf$/)) {
			$configs{$file} = readConfig($webguiPath,$file);
		}
	}
	return \%configs;
}


#-------------------------------------------------------------------

=head2 readConfig ( webguiRoot , configFile )

Returns a hash reference containing the configuration data. It reads the config data directly from the file.

=head3 webguiRoot

The path to the WebGUI installation.

=head3 configFile

The filename of the config file to read.

=cut

sub readConfig {
	my $webguiPath = shift;
	my $filename = shift;
	my $config = Parse::PlainConfig->new('DELIM' => '=', 
                'FILE' => $webguiPath.'/etc/'.$filename,
                'PURGE' => 1);
	my %data;
        foreach my $key ($config->directives) {
                $data{$key} = $config->get($key);
        }
	foreach my $directive (qw(assets utilityAssets assetContainers authMethods paymentPlugins)) {
	        if (ref $data{$directive} ne "ARRAY") {
        	        $data{$directive} = [$data{$directive}];
        	}
	}
	foreach my $directive (qw(assetAddPrivilege macros)) {
	        if (ref $data{$directive} ne "HASH") {
        	        $data{$directive} = {};
        	}
	}
	if (ref $data{shippingPlugins} ne "ARRAY") {
		$data{shippingPlugins} = [$data{shippingPlugins}] if ($data{shippingPlugins});
	}
        if (ref $data{sitename} eq "ARRAY") {
                $data{defaultSitename} = $data{sitename}[0];
        } else {
                $data{defaultSitename} = $data{sitename};
        }
	$data{webguiRoot} = $webguiPath;
	$data{configFile} = $filename;
	return \%data;
}



1;

