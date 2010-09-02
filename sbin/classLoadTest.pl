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
use File::Basename ();
use File::Spec;

my $webguiRoot;
BEGIN {
    $webguiRoot = File::Spec->rel2abs(File::Spec->catdir(File::Basename::dirname(__FILE__), File::Spec->updir));
    unshift @INC, File::Spec->catdir($webguiRoot, 'lib');
}

$|++; # disable output buffering

our ($configFile, $help, $man, $class);
use Pod::Usage;
use Getopt::Long;
use WebGUI::Session;

# Get parameters here, including $help
GetOptions(
    'configFile=s'  => \$configFile,
    'help'          => \$help,
    'man'           => \$man,
    'class=s'       => \$class,
);

pod2usage( verbose => 1 ) if $help;
pod2usage( verbose => 2 ) if $man;
pod2usage( msg => "Must specify a config file!" ) unless $configFile;  

foreach my $libDir ( readLines( "preload.custom" ) ) {
    if ( !-d $libDir ) {
        warn "WARNING: Not adding lib directory '$libDir' from preload.custom: Directory does not exist.\n";
        next;
    }
    unshift @INC, $libDir;
}

my $session = start( $webguiRoot, $configFile );

open(my $null, ">:utf8","/dev/null");
$session->output->setHandle($null);

printf "%22s\t\%18s\t%12s\t%s\n", 'Asset ID', 'Instanciate Time', 'Render Time','URL'; 

my $count = 0;
my $sth = $session->db->read("select assetId from asset where className=? and state='published'",[$class]);
while (my ($id) = $sth->array) {
    $count++;
    print $id;
    
    # check instanciation time
    my $t = [Time::HiRes::gettimeofday];
    my $asset = eval { WebGUI::Asset->new($session, $id, $class)};
    if (!defined $asset || $@) {
	my $url = $session->db->quickScalar("select url from assetData where assetId=? order by revisionDate desc",[$id]); 
        print "\tbad asset: $@ \t url: $url \n"; 
        next;
    }
    my $instanciation = Time::HiRes::tv_interval($t);
    
    # set the default asset for those things that need it
    $session->asset($asset);

    # check render time
    $t = [Time::HiRes::gettimeofday];
    eval {my $junk = $asset->www_view};
    my $rendering = Time::HiRes::tv_interval($t);
    if ($@) {
        $rendering = $@;
    }

    # get the url
    my $url =  $asset->getValue("url"); 
    
    # output the results
    printf "\t%18.4f\t%12.4f\t%s\n", $instanciation, $rendering ,$url; 
}

close($null);

print "Total assets: $count\n";


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

#-------------------------------------------------
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

__END__

=head1 NAME

classLoadTest.pl -- Test a single class performance

=head1 SYNOPSIS

 classLoadTest.pl --configFile config.conf --class=<>

 classLoadTest.pl --help

=head1 DESCRIPTION

This script will test the time it takes to instanciate and view all the 
assets of a particular class from the given site.

=head1 OPTIONS

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--class>

The full class name of the asset to test. Something like WebGUI::Asset::Wobject::Layout
or WebGUI::Asset::Wobject::Navigation.

=item B<--help>

Shows a short summary and usage

=item B<--man>

Shows this document

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

#vim:ft=perl

