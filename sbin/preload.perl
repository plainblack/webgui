use strict;

my $webguiRoot = '/data/WebGUI';

unshift @INC, $webguiRoot . "/lib";

# add custom lib directories to library search path
unshift @INC, grep {
    if (!-d $_) {
        warn "WARNING: Not adding lib directory '$_' from $webguiRoot/sbin/preload.custom: Directory does not exist.\n";
        0;
    }
    else {
        1;
    }
} readLines($webguiRoot."/sbin/preload.custom");

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
require WebGUI::Config;
require WebGUI::Pluggable;

# these modules should always be skipped
my @excludes;
push @excludes, readLines($webguiRoot."/sbin/preload.exclude");

WebGUI::Pluggable::findAndLoad( "WebGUI", 
    { 
        exclude     => \@excludes, 
        onLoadFail  => sub { warn sprintf 'Error loading %s: %s', @_ },
    }
);

require APR::Request::Apache2;
require Apache2::Cookie;
require Apache2::ServerUtil;

if ( $ENV{MOD_PERL} ) {
    # Add WebGUI to Apache version tokens
    my $server = Apache2::ServerUtil->server;
    $server->push_handlers(PerlPostConfigHandler => sub {
        $server->add_version_component("WebGUI/".$WebGUI::VERSION);
    });
}

$| = 1;

print "\nStarting WebGUI ".$WebGUI::VERSION."\n";

#----------------------------------------
# Preload all site configs.
#----------------------------------------
WebGUI::Config->loadAllConfigs($webguiRoot);


# reads lines from a file into an array, trimming white space and ignoring commented lines
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

