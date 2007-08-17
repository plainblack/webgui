my $webguiRoot;
my $customLibs;

BEGIN {
    $webguiRoot = "/data/WebGUI";
    unshift (@INC, $webguiRoot."/lib");
    @{$customLibs} = ();
    open(FILE,"<".$webguiRoot."/sbin/preload.custom");
    while (my $line = <FILE>) {
        chomp $line;
        next unless $line;
        next if $line =~ /^#/;
        if (!-d $line) {
            print "WARNING: Not adding lib directory '$line' from $webguiRoot/sbin/preload.custom: Directory does not exist.\n";
            next;
        }
        push(@{$customLibs}, $line);
    }
    close(FILE);
    foreach my $lib (@{$customLibs}) {
        unshift @INC, $lib;
    }
}

$|=1;

use strict;
print "\nStarting WebGUI ".$WebGUI::VERSION."\n";

#----------------------------------------
# Logger
#----------------------------------------
use Log::Log4perl;
Log::Log4perl->init( $webguiRoot."/etc/log.conf" );   


#----------------------------------------
# Database connectivity.
#----------------------------------------
#use Apache::DBI (); # Uncomment if you want to enable connection pooling. Not recommended on servers with many sites, or those using db slaves.
use Log::Log4perl ();
use DBI ();
DBI->install_driver("mysql"); # Change to match your database driver.



#----------------------------------------
# WebGUI modules.
#----------------------------------------
use WebGUI ();

use WebGUI::Utility ();
use File::Find ();
my @modules = ();
# these modules should always be skipped
my @excludes = qw(WebGUI::i18n::English::Automated_Information WebGUI::PerformanceProfiler);
open(FILE,"<".$webguiRoot."/sbin/preload.exclude");
while (my $line = <FILE>) {
    next if $line =~ m/^#/;
	chomp $line;
	push(@excludes, $line);
}
close(FILE);
my @folders = ($webguiRoot."/lib/WebGUI");
foreach my $lib (@{$customLibs}) {
    push(@folders, $lib."/WebGUI");
}
File::Find::find(\&getWebGUIModules, @folders);
foreach my $package (@modules) {
	next if (WebGUI::Utility::isIn($package,@excludes));
	my $use = "use ".$package." ()";
	eval($use);
}

use Apache2::ServerUtil ();
{
    # Add WebGUI to Apache version tokens
    my $server = Apache2::ServerUtil->server;
    my $sub = sub {
	$server->add_version_component("WebGUI/".$WebGUI::VERSION);	
    };
    $server->push_handlers(PerlPostConfigHandler => $sub);
}


use APR::Request::Apache2 ();
use Apache2::Cookie ();

#----------------------------------------
# Preload all site configs.
#----------------------------------------
WebGUI::Config->loadAllConfigs($webguiRoot);


print "WebGUI Started!\n";


#----------------------------------------
sub getWebGUIModules {
        my $filename = $File::Find::dir."/".$_;
        return unless $filename =~ m/\.pm$/;
        my $package = $filename;
        $package =~ s/.*\/lib\/(.*)\.pm$/$1/;
        $package =~ s/\//::/g;
        push(@modules,$package);
}

1;


