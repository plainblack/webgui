#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

our $webguiRoot;

BEGIN {
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

my $language='English';
my $namespace;
my $help;
my $test;

GetOptions(
	   'language=s'=>\$language,
	   'namespace=s'=>\$namespace,
	   'help'=>\$help,
	   'test'=>\$test
	  );

if ((!$help && !$namespace) or $help){
        print <<STOP;

Usage: perl $0 

This script helps you add keys and entries to the appropriate 
WebGUI/i18n/<Language>/ translation files. It sorts the entries
by key value and takes care of escaping automatically.

Options:

	--language	The language you're adding an entry for.
			Defaults to English

        --help          Display this help message and exit.

	--namespace	The name of the file you want to manipulate
			in "lib/WebGUI/i18n/<language>" WITHOUT the .pm 
			extension. So, if you're editing the "Macro_GroupAdd.pm"
			file, it's "Macro_GroupAdd".

	--test		Don't edit the actual file, but create a copy with ".test"
			appended to the name.

STOP
        exit;    
}

die('You need to give us a namespace to edit') if (!$namespace);

my $tranmodule=join('::',('WebGUI','i18n',$language,$namespace));
eval "use $tranmodule;";

if (($@)) {
    die('Either that namespace does not exist or you spelled it incorrectly. Please try again');
}

my $variable='$'.$tranmodule.'::I18N';
my $i18n=eval "$variable";

print "\nEnter a new key value to create a new entry.\nCurrent Keys:\n\n";
foreach ((keys %$i18n)) {
    print "$_\n";
}

my $key='';
while (lc($key) ne 'quit') {
    print "\n\nNew Key, or quit to stop:\n";
    $key=<STDIN>;
    chomp($key);
    next if(!$key);
    last if(lc($key) eq 'quit');
    if (! defined $i18n->{$key}) {
	print "\nNew key. Ok?\n";
	my $input=<STDIN>;
	chomp($input);
	if (lc(substr($input,0,1)) eq 'y') {
	    get_info($key,$i18n);
	}
    } else {
	print "\nErm. . . That key's already in use. Please try again.\n";
    }
}


################################################################################
sub save_file{
    open(OUTPUT,">","../lib/WebGUI/i18n/$language/$namespace.pm".(($test) ? '.test' : '')) or die($!);
    $Data::Dumper::Varname='I18N';
    $Data::Dumper::Sortkeys=1;

    print OUTPUT "package $tranmodule;\n\n";
    my $output=Dumper($i18n);
    $output =~ s/^\$I18N1/\$I18N/i;
    print OUTPUT "our ".$output;
    print OUTPUT "1;";
    close OUTPUT;
    print "Saved!!\n";
}
########################################


################################################################################
sub get_info{
    my $key=shift;
    my $i18n=shift;
    print "\nEnter the new information for this key. Press Ctrl-D to save\n";
    my @info=<STDIN>;
    print "\n\nOk? \n";
    my $input=<STDIN>;
    chomp($input);
    if (lc(substr($input,0,1)) eq 'y') {
	my $string=join("",@info);
	chomp($string);
	$i18n->{$key}->{message}=$string;
	$i18n->{$key}->{lastUpdated}=time;
	save_file();
    }
}
########################################
