#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::Grouping;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

#--------------------------------------------
print "\tMaking admins part of product managers.\n" unless ($quiet);
WebGUI::Grouping::addGroupsToGroups(['3'],['14']);


WebGUI::Session::close();


