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

$|++; # disable output buffering
our ($webguiRoot, $configFile, $help, $man);

BEGIN {
    $webguiRoot = "..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Pod::Usage;
use Getopt::Long;
use WebGUI::Session;

# Get parameters here, including $help
GetOptions(
    'configFile=s'  => \$configFile,
    'help'          => \$help,
    'man'           => \$man,
);

pod2usage( verbose => 1 ) if $help;
pod2usage( verbose => 2 ) if $man;
pod2usage( msg => "Must specify a config file!" ) unless $configFile;  

my $session = start( $webguiRoot, $configFile );

use WebGUI::Asset::File;
my $iter  = WebGUI::Asset::File->getIsa($session);
ASSET: while (1) {
    my $file = eval { $iter->() };
    if (my $e = Exception::Class->caught()) {
        $session->log->error($@);
        next ASSET;
    }
    last ASSET unless $file;
    $file->setPrivileges;
}

finish($session);

#----------------------------------------------------------------------------
sub start {
    my $webguiRoot  = shift;
    my $configFile  = shift;
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});

    return $session;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;

    $session->var->end;
    $session->close;
}

__END__


=head1 NAME

fixWgaccess.pl -- Fix .wgaccess files

=head1 SYNOPSIS

 fixWgaccess.pl --configFile config.conf ...

 utility --help

=head1 DESCRIPTION

This script will fix all the .wgaccess files that control permissions inside
the /uploads folder.

This script currently only does File assets. Not all wgaccess files are 
linked back to assets.

=head1 ARGUMENTS

=head1 OPTIONS

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--help>

Shows a short summary and usage

=item B<--man>

Shows this document

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

#vim:ft=perl

