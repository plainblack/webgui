#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::Asset;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

#--------------------------------------------
print "\tmatt's going to do something here\n" unless ($quiet);



WebGUI::Session::close();


