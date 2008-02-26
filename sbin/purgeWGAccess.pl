use lib "../lib";
use strict;
use Getopt::Long;
use WebGUI::Config;

local $| = 1; #disable output buffering
GetOptions(
    'configFile=s' => \(my $configFile),
    'configFile=s' => \(my $configFile),
);
my $config = WebGUI::Config->new("..",$configFile);
use File::Find;

print "\tRemoving unnecessary .wgaccess files.\n";
my $uploadsPath = $config->get('uploadsPath');
File::Find::find({wanted => sub {
    my $filename = $_;
    return
        if -d $filename;                    # Skip directories
    return
        if $filename ne '.wgaccess';        # skip anything other than .wgaccess
    open my $fh, '<', $filename or return;  # skip files we can't open
    chomp (my ($user, $viewGroup, $editGroup) = <$fh>); # slurp file as lines
    close $fh;
    # 
    if ($user eq '1' || $viewGroup eq '1' || $viewGroup eq '7' || $editGroup eq '1' || $editGroup eq '7') {
        unlink $filename;
    }
}}, $uploadsPath);

