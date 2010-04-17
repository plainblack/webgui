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

use strict;
use Getopt::Long;
use Pod::Usage;
use File::Find ();
use WebGUI::Paths -inc;
use WebGUI::Config;

local $| = 1; #disable output buffering
GetOptions(
    'configFile=s' => \(my $configFile),
    'help'         => \(my $help),
);

pod2usage( verbose => 2 ) if $help;
pod2usage() if $configFile eq '';

my $config = WebGUI::Config->new($configFile);

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

__END__

=head1 NAME

purgeWGAccess - Clean up unneeded .wgaccess files from WebGUI repository

=head1 SYNOPSIS

 purgeWGAccess --configFile config.conf

 purgeWGAccess --help

=head1 DESCRIPTION

This WebGUI utility script removes unneeded .wgaccess files from
a specific site's upload directory. The script finds all the
.wgaccess files recursively starting from the upload path for
the WebGUI site specified in the given configuration file and
removes it.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
