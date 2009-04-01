#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use Test::More;
use Pod::Coverage;
use File::Find;
use File::Spec;

plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};

my $threshold = $ENV{POD_COVERAGE}      ? 0.75
              : $ENV{POD_COVERAGE} == 2 ? 0.9999
              : 0;

my @modules = ();
find(\&countModules, File::Spec->catdir( WebGUI::Test->lib, 'WebGUI' ) );
my $moduleCount = scalar(@modules);
plan tests => $moduleCount;
use Data::Dumper;
foreach my $package (sort @modules) {
	my $pc = Pod::Coverage->new(
        package=>$package,
        also_private => [ qr/definition/ ],
    );
    my $coverage   = $pc->coverage > $threshold;
    my $goodReason = $pc->why_unrated() eq 'no public symbols defined';
    SKIP: {
        skip "No subroutines found by Devel::Symdump for $package", 1 if $goodReason;
        ok($coverage, sprintf "%s has %d%% POD coverage", $package, $pc->coverage*100);
        if (!$coverage && $ENV{POD_COVERAGE} ==2) {
            diag Dumper [$pc->naked];
        }
    }
}


sub countModules {
	my $filename = $File::Find::dir."/".$_;
	return unless $filename =~ m/\.pm$/;
	return if $filename =~ m/WebGUI\/i18n/;
	return if $filename =~ m/WebGUI\/Help/;
	my $package = $filename;
	$package =~ s/^.*(WebGUI.*)\.pm$/$1/;
	$package =~ s/\//::/g;
	push(@modules,$package);
}
