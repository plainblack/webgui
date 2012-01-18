#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use Test::More;
use Pod::Coverage;
use File::Find;
use File::Spec;

my $threshold = $ENV{POD_COVERAGE} == 2 ? 0.9999
              : $ENV{POD_COVERAGE}      ? 0.75
              : 0;

my @modules = ();
my $lib_path = WebGUI::Test->lib;
find(\&countModules, $lib_path );
my $moduleCount = scalar(@modules);
plan tests => $moduleCount;
foreach my $package (sort @modules) {
	my $pc = Pod::Coverage->new(
        package       => $package,
        also_private  => [ qr/definition/ ],
        nonwhitespace => ($ENV{POD_COVERAGE} == 3 ? 1 : 0),
    );
    my $coverage   = $pc->coverage > $threshold;
    my $goodReason = $pc->why_unrated() eq 'no public symbols defined';
    SKIP: {
        skip "No subroutines found by Devel::Symdump for $package", 1 if $goodReason;
        ok($coverage, sprintf "%s has %d%% POD coverage", $package, $pc->coverage*100);
        if (!$coverage && $ENV{POD_COVERAGE}) {
            diag explain [$pc->naked];
            diag $pc->why_unrated;
        }
    }
}


sub countModules {
	my $filename = $File::Find::dir."/".$_;
	return unless $filename =~ m/\.pm$/;
	return if $filename =~ m/WebGUI\/i18n/;
	return if $filename =~ m/WebGUI\/Help/;
    my $package = File::Spec->abs2rel($filename, $lib_path);
	$package =~ s/\//::/g;
    $package =~ s/\.pm$//;
	push(@modules,$package);
}
