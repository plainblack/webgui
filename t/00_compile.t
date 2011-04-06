#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use warnings;

# We don't load WebGUI::Test, because we want to test the
# loading of WebGUI::Session ourselves

use Test::More;
use File::Find;
use File::Spec;
use File::Spec::Functions;
use File::Basename;
use Cwd qw(realpath);

my $wgRoot = realpath catdir(dirname(__FILE__), updir);
my $wgLib = catdir($wgRoot, 'lib');
unshift @INC, $wgLib;

my @modules = findModules($wgLib);
my @scripts = findScripts(catdir($wgRoot, 'docs', 'upgrades'), catdir($wgRoot, 'sbin'));

plan tests => 2 * (scalar @modules + scalar @scripts);
my $failed_compile = 0;

foreach my $library (@modules) {
    my $warnings = '';
    local $^W = 1;
    local $SIG{__WARN__} = sub {
        my $warn = shift;
        # file the warning occurred in
        my $caller = caller;
        my $warning_file = realpath( (caller(0))[1] );
        # only care about it if it is within the WebGUI lib directory or is an explicit warning
        if ($warning_file =~ /^\Q$wgLib/ || $caller eq 'Carp') {
            $warnings .= $warn;
        }
    };
    eval {
        require $library;
    };
    chomp $warnings;
    is($@, '', "$library compiles successfully")
        || $failed_compile++;
    is($warnings, '', "$library compiles without warnings");
}

my $script_compiler = <<'END_SCRIPT';
return 1;
package WebGUI::Test::ScriptTest::%s;
use warnings;
# line 1 "%s"
%s
END_SCRIPT

for my $script (@scripts) {
    open my $fh, '<', $script;
    my $script_content = do { local $/; <$fh> };
    close $fh;
    my $short_name = File::Spec->abs2rel($script, $wgRoot);
    my $package_name = $script;
    $package_name =~ s{.*/}{}msx;
    $package_name =~ s/\W//msxg;
    my $to_compile = sprintf $script_compiler, $package_name, $short_name, $script_content;

    my $warnings = '';
    local $SIG{__WARN__} = sub {
        $warnings .= shift;
    };
    eval $to_compile;
    chomp $warnings;
    is($@, '', "$short_name compiles successfully");
    is($warnings, '', "$short_name compiles without warnings");
}

if ($failed_compile) {
    BAIL_OUT("Failed to compile $failed_compile modules!");
}

#----------------------------------------
sub findModules {
    my $libDir = shift;
    my @modules;
    File::Find::find( {
        no_chdir => 1,
        wanted => sub {
            return unless $File::Find::name =~ /\.pm$/;
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

