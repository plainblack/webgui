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


WebGUI::Session::close();


