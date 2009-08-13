#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

$|=1;

use strict;
use FindBin;
use File::Spec qw[];
use Getopt::Long;
use Pod::Usage;

my $configFile;
my $help;
my $verbose;
my $perlBase;
my $noLongTests;
my $coverage;

GetOptions(
	'verbose'=>\$verbose,
	'configFile=s'=>\$configFile,
	'perlBase=s'=>\$perlBase,
	'noLongTests'=>\$noLongTests,
	'help'=>\$help,
	'coverage'=>\$coverage,
	);

##Defaults to command-line switch
$configFile ||= $ENV{WEBGUI_CONFIG};

pod2usage( verbose => 2 ) if $help;
pod2usage() unless $configFile ne '';

my $verboseFlag = "-v" if ($verbose);

$perlBase .= '/bin/' if ($perlBase);

if (! -e $configFile) {
	##Probably given the name of the config file with no path,
	##attempt to prepend the path to it.
    warn "Config file $configFile does not exist, assuming that you supplied a bare config and are running from inside the sbin directory\n";
	$configFile = File::Spec->canonpath($FindBin::Bin.'/../etc/'.$configFile);
}

die "Unable to use $configFile as a WebGUI config file\n"
	unless(-e $configFile and -f _);

my (undef, $directories, $file) = File::Spec->splitpath($configFile);
my $webguiRoot = File::Spec->canonpath(File::Spec->catdir($directories, File::Spec->updir));
my $webguiTest = File::Spec->catdir($webguiRoot, 't');

my $prefix = "WEBGUI_CONFIG=".$configFile;

##Run all tests unless explicitly forbidden
$prefix .= " CODE_COP=1" unless $noLongTests;

# Add coverage tests
$prefix .= " HARNESS_PERL_SWITCHES='-MDevel::Cover=-db,/tmp/coverdb'" if $coverage;

print(join ' ', $prefix, $perlBase."prove", $verboseFlag, '-r', $webguiTest); print "\n";
system(join ' ', $prefix, $perlBase."prove", $verboseFlag, '-r', $webguiTest);

__END__

=head1 NAME

testCodebase - Test WebGUI's code base.

=head1 SYNOPSIS

 testCodebase --configFile /data/WebGUI/etc/config.conf
              [--coverage]
              [--noLongTests]
              [--perlBase path]
              [--verbose]

 testCodebase --help

=head1 DESCRIPTION

This WebGUI utility script tests all of WebGUI's installed code base
using a particular confiuration file. It uses B<prove> to run all
the WebGUI supplied test routines, located in the B<t> subdirectory
of the WebGUI root.

You should B<NOT> use a production config file for testing, since some
of the test may be destructive.

=over

=item B<--configFile /data/WebGUI/etc/config.conf>

A WebGUI config file is required for testing.  If one cannot be
found based on input from the user, then the script aborts
without running any tests.

Config files can be supplied on the command line, or via the environment
variable, WEBGUI_CONFIG being used as a fallback.  If the config file
cannot be found, the script assumes that a bare filename was provided and
that it is being from from the WebGUI sbin directory.  It then looks in
the parallel directory, '../etc', for the config file.

Be aware that some of the tests are destructive, and running tests
on production sites is not recommended.

=item B<--coverage>

Turns on additional L<Devel::Cover> based coverage tests. Note that
this can take a long time to run.

=item B<--noLongTests>

Prevent long tests from being run

=item B<--perlBase path>

Specify a path to an alternative Perl installation you wish to use for the
tests. If left unspecified, it defaults to the Perl installation in the
current PATH.

=item B<--verbose>

Turns on additional information during tests.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
