#!/usr/bin/perl

use lib "../../lib";
use Data::Config;
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
my $dataconfig = new Data::Config $pathToConfig;
my $plainconfig = Parse::PlainConfig->new('DELIM' => '=', 'PURGE' => 1);

my ($excludeWobject, $excludeMacro, $excludeAuthentication);
foreach my $key ($dataconfig->param) {
	if ($key eq "excludeWobject") {
		$excludeWobject = $dataconfig->param($key);
	} elsif ($key eq "excludeMacro") {
		$excludeMacro = $dataconfig->param($key);
	} elsif ($key eq "excludeAuthentication") {
		$excludeAuthentication = $dataconfig->param($key);
	} elsif ($key eq "cachePages" || $key eq "cacheInternational") {
		#do nothing
	} else {
		$plainconfig->set($key=>$dataconfig->param($key));
	}
}


opendir (DIR,"../../lib/WebGUI/Wobject") or die "Can't find Wobjects.";
my @wobjectList = readdir(DIR);
closedir(DIR);

$excludeWobject =~ s/ //g;
my @excludeList = split(/,/,$excludeWobject);

my @wobjects;

foreach my $wobject (@wobjectList) {
	if ($wobject =~ /(.*?)\.pm$/) {
		$wobject = $1;
		unless (isIn($wobject, @excludeList)) {
			push(@wobjects,$wobject);
		}
	}
}

$plainconfig->set("wobjects"=>\@wobjects);



opendir (DIR,"../../lib/WebGUI/Macro") or die "Can't find Macros.";
my @macroList = readdir(DIR);
closedir(DIR);

$excludeMacro =~ s/ //g;
@excludeList = split(/,/,$excludeMacro);

my %macros;

foreach my $macro (@macroList) {
	if ($macro =~ /(.*?)\.pm$/) {
		$macro = $1;
	        unless (isIn($macro, @excludeList)) {
			my @alias = split(/_/,$macro);
			if ($alias[0] eq "Splat") {
				$alias[0] = "*";
			} elsif ($alias[0] eq "Slash") {
				$alias[0] = "/";
	                } elsif ($alias[0] eq "Backslash") {
        	                $alias[0] = '\\\\';
                	} elsif ($alias[0] eq "Question") {
	                        $alias[0] = "?";
        	        } elsif ($alias[0] eq "At") {
                	        $alias[0] = "\@";
	                } elsif ($alias[0] eq "rootmenuHorizontal") {
        	                $alias[0] = "rootmenu";
	                } elsif ($alias[0] eq "Hash") {
        	                $alias[0] = "#";
			}
			$macros{$alias[0]} = $macro;
        	}
	}
}

$plainconfig->set("macros"=>\%macros);



opendir (DIR,"../../lib/WebGUI/Authentication") or die "Can't find Auth Methods.";
my @authMethodList = readdir(DIR);
closedir(DIR);

$excludeAuthentication =~ s/ //g;
@excludeList = split(/,/,$excludeAuthentication);
push (@excludeList,"SMB");

my @authMethods;

foreach my $authMethod (@authMethodList) {
	if ($authMethod =~ /(.*?)\.pm$/) {
		$authMethod = $1;
        	unless (isIn($authMethod, @excludeList)) {
                	push(@authMethods,$authMethod);
        	}
	}
}

$plainconfig->set("authMethods"=>\@authMethods);

$plainconfig->write($pathToConfig,3);


print "\tRemoving unneeded files.\n" unless ($quiet);

unlink("../../sbin/Hourly/SyndicatedContent.pm");
unlink("../../sbin/imageCollateralImport.pl");
unlink("../../lib/WebGUI/ProxyParse.pm");

