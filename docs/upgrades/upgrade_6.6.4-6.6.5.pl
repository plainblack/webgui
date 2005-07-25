#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use File::Path;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);


#--------------------------------------------
print "\tRemoving old HTML::Template if it exists. Check gotcha.txt for details.\n" unless ($quiet);
rmtree("../../lib/HTML/Template");
unlink("../../lib/HTML/Template.pm");



