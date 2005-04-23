#!/usr/bin/perl

use lib "../../lib";
use File::Path;
use Getopt::Long;
use strict;
use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::SQL;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

#--------------------------------------------
print "\tDeleting old templates\n" unless ($quiet);
my $asset = WebGUI::Asset->newByDynamicClass("PBtmpl0000000000000035");
$asset->purge;

#--------------------------------------------
print "\tUpdating config file.\n" unless ($quiet);
my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig, 'PURGE'=>1);
my %newConfig;
foreach my $key ($conf->directives) {
	unless ($key eq "logfile" || $key eq "passwordChangeLoggingEnabled" || $key eq "emailRecoveryLoggingEnabled") {
		$newConfig{$key} = $conf->get($key);
	}
}
my @newAssetList;
foreach my $asset (@{$newConfig{assets}}) {
	push(@newAssetList, $asset) unless ($asset eq "WebGUI::Asset::Template");
}
$newConfig{utilityAssets} = ["WebGUI::Asset::Template"];
$newConfig{assets} = \@newAssetList;
$conf->purge;
$conf->set(%newConfig);
$conf->write;


WebGUI::Session::close();


