#!/usr/bin/perl

use lib "../../lib";
use FileHandle;
use File::Path;
use File::Copy;
use Getopt::Long;
use strict;
use WebGUI::Group;
use WebGUI::HTML;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;


my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

#--------------------------------------------
print "\tUpdating config file.\n" unless ($quiet);
my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
$macros->{"International"} = "International";
$conf->set("macros"=>$macros);
$conf->write;




WebGUI::Session::close();


