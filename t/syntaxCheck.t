#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use File::Find;
use WebGUI::Session;
use Test::More;
use File::Spec;

my $wgLib = WebGUI::Test->lib;
my @modules = findModules($wgLib);
my @scripts = findScripts(WebGUI::Test->root . '/docs/upgrades', WebGUI::Test->root . '/sbin');

plan tests => 2 * (scalar @modules + scalar @scripts);

foreach my $library (@modules) {
    my $warnings = '';
    local $^W = 1;
    local $SIG{__WARN__} = sub {
        $warnings .= shift;
    };
    eval {
        require $library;
    };
    chomp $warnings;
    is($@, '', "$library compiles successfully");
    is($warnings, '', "$library compiles without warnings");
}

for my $script (@scripts) {
    my $cmd = "$^X -wcI'$wgLib' $script 2>&1";
    my $output = `$cmd`;
    is($?, 0, "$script compiles successfully");
    chomp $output;
    $output =~ s/^\Q$script\E (?:had compilation errors\.|syntax OK)$//m;
    is($output, '', "$script compiles without warnings");
}

#----------------------------------------
sub findModules {
    my $libDir = shift;
    my @modules;
    File::Find::find( {
        no_chdir => 1,
        wanted => sub {
            next unless $File::Find::name =~ /\.pm$/;
            my $lib = File::Spec->abs2rel($File::Find::name, $libDir);
            push @modules, $lib;
        },
    }, $libDir);
    return @modules;
}

sub findScripts {
    my @scripts;
    for my $dir (@_) {
        push @scripts, glob("$dir/*.pl");
    }
    return @scripts;
}

