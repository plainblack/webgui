#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::Utility;


my $configFile;
my $quiet;

GetOptions(
        'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

print "\tUpdating config file.\n" unless ($quiet);

my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
$macros->{RootTab} = "RootTab";
$macros->{RandomSnippet} = "RandomSnippet";
$macros->{RandomImage} = "RandomImage";
$macros->{CanEditText} = "CanEditText";
$macros->{If} = "If";
$macros->{Spacer} = "Spacer";
$macros->{SpecificDropMenu} = "SpecificDropMenu";
$macros->{LastModified} = "LastModified";
$macros->{PreviousDropMenu} = "PreviousDropMenu";
$macros->{TopDropMenu} = "TopDropMenu";
$macros->{SI} = "SI_scaledImage";
$conf->set("macros"=>$macros);
$conf->write;
