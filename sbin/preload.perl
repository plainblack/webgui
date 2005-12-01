my $webguiRoot;

BEGIN {
        $webguiRoot = "/data/WebGUI";
        unshift (@INC, $webguiRoot."/lib");
}

$|=1;

use strict;
print "\nStarting WebGUI ".$WebGUI::VERSION."\n";


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
my @excludes = ();
open(FILE,"<".$webguiRoot."/sbin/preload.exclude");
while (<FILE>) {
	chomp;
	push(@excludes,$_);
}
close(FILE);
File::Find::find(\&getWebGUIModules, $webguiRoot."/lib/WebGUI");
foreach my $package (@modules) {
	next if (WebGUI::Utility::isIn($package,@excludes));
	my $use = "use ".$package." ()";
	eval($use);
}


#----------------------------------------
# Preload all site configs.
#----------------------------------------
WebGUI::Config::loadAllConfigs($webguiRoot);


print "WebGUI Started!\n";


#----------------------------------------
sub getWebGUIModules {
        my $filename = $File::Find::dir."/".$_;
        return unless $filename =~ m/\.pm$/;
        my $package = $filename;
        $package =~ s/^\/data\/WebGUI\/lib\/(.*)\.pm$/$1/;
        $package =~ s/\//::/g;
        push(@modules,$package);
}

1;


