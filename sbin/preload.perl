use strict;

my $webguiRoot = '/data/WebGUI';

my @webguiLibs = ($webguiRoot."/lib");

# add custom lib directories to library search path
for my $libDir (readLines($webguiRoot."/sbin/preload.custom")) {
    if (!-d $libDir) {
        warn "WARNING: Not adding lib directory '$libDir' from $webguiRoot/sbin/preload.custom: Directory does not exist.\n";
        next;
    }
    push @webguiLibs, $libDir;
}
unshift @INC, @webguiLibs;

#----------------------------------------
# Logger
#----------------------------------------
require Log::Log4perl;
Log::Log4perl->init( $webguiRoot."/etc/log.conf" );

#----------------------------------------
# Database connectivity.
#----------------------------------------
#require Apache::DBI; # Uncomment if you want to enable connection pooling. Not recommended on servers with many sites, or those using db slaves.
require DBI;
DBI->install_driver("mysql"); # Change to match your database driver.

#----------------------------------------
# WebGUI modules.
#----------------------------------------
require WebGUI;

require File::Find;

# these modules should always be skipped
my @excludes = qw(WebGUI::i18n::English::Automated_Information WebGUI::PerformanceProfiler);
push @excludes, readLines($webguiRoot."/sbin/preload.exclude");

foreach my $libDir (@webguiLibs) {
    File::Find::find({
        no_chdir => 1,
        wanted => sub {
            my $module = $_;
            return
                unless $module =~ m/\.pm$/;
            # clip off library path
            $module =~ s{^\Q$libDir\E/?}{};
            my $package = $module;
            $package =~ s{\.pm$}{};
            $package =~ s{/}{::}g;
            if (grep { $package eq $_ } @excludes) {
                next;
            }
            if (!eval { require $module; 1 }) {
                warn "Error loading $package! - $@";
            }
        },
    }, "$libDir/WebGUI");
}

require APR::Request::Apache2;
require Apache2::Cookie;
require Apache2::ServerUtil;

# Add WebGUI to Apache version tokens
my $server = Apache2::ServerUtil->server;
$server->push_handlers(PerlPostConfigHandler => sub {
    $server->add_version_component("WebGUI/".$WebGUI::VERSION);
});

$| = 1;

print "\nStarting WebGUI ".$WebGUI::VERSION."\n";

#----------------------------------------
# Preload all site configs.
#----------------------------------------
WebGUI::Config->loadAllConfigs($webguiRoot);

# reads lines from into an array, trimming white space and ignoring commented lines
sub readLines {
    my $file = shift;
    my @lines;
    if (open(my $fh, '<', $file)) {
        while (my $line = <$fh>) {
            $line =~ s/#.*//;
            $line =~ s/^\s+//;
            $line =~ s/\s+$//;
            next if !$line;
            push @lines, $line;
        }
        close $fh;
    }
    return @lines;
}

1;

