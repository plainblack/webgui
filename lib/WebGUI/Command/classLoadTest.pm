package WebGUI::Command::classLoadTest;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use WebGUI::Command -command;
use strict;
use warnings;

use File::Spec;
use Time::HiRes;

sub opt_spec {
    return (
        [ 'configFile=s', 'The WebGUI config file to use.' ],
        [ 'class=s', 'The full class name of the asset to test.'],
    );
}

sub run {
    my ($self, $opt, $args) = @_;

    my ($configFile, $class) = @{$opt}{qw(configfile class)};

    my $session = WebGUI::Session->open($configFile);
    open my $null, ">:utf8", File::Spec->devnull;
    $session->output->setHandle($null);

    printf "%22s\t\%18s\t%12s\t%s\n", 'Asset ID', 'Instanciate Time', 'Render Time','URL';

my $count = 0;
my $sth = $session->db->read("select assetId from asset where className=? and state='published'",[$class]);
while (my ($id) = $sth->array) {
    $count++;
    print $id;
    
    # check instanciation time
    my $t = [Time::HiRes::gettimeofday];
    my $asset = eval { WebGUI::Asset->newById($session, $id)};
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
    my $url =  $asset->url;
    
    # output the results
    printf "\t%18.4f\t%12.4f\t%s\n", $instanciation, $rendering ,$url; 
}

    $session->var->end;
    $session->close;
    close $null;

    print "Total assets: $count\n";
}

1;

__END__

=head1 NAME

WebGUI::Command::classLoadTest - Test a single class performance

=head1 SYNOPSIS

    webgui.pl classLoadTest --configFile config.conf --class=<>

=head1 DESCRIPTION

This script will test the time it takes to instanciate and view all the
assets of a particular class from the given site.

=head1 OPTIONS

=over 4

=item C<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item C<--class>

The full class name of the asset to test. Something like WebGUI::Asset::Wobject::Layout
or WebGUI::Asset::Wobject::Navigation.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

