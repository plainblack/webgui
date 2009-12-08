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

use Benchmark ':hireswallclock', 'cmpthese', 'timethis';
use WebGUI::CHI;
use WebGUI::Cache;
use WebGUI::Cache::Database;
use WebGUI::Cache::FileCache;

my $userIds = $session->db->buildArrayRef(
    "SELECT userId FROM users GROUP BY userId ORDER BY RAND() LIMIT 100"
);

my $groupIds = $session->db->buildArrayRef(
    "select distinct(groupId) FROM groupings order by rand() LIMIT 10"
);

my $count   = 0;
my $repeats = 100;
my $total   = scalar( @$userIds ) * scalar( @$groupIds ) * $repeats;
my $test_cache1 = sub {
    my $session = shift;
    for my $userId ( @$userIds ) {
        for my $groupId ( @$groupIds ) {
            if ( !$session->cache->get( "$userId/$groupId" ) ) {
                $session->cache->set( "$userId/$groupId", $groupId );
            }
            $count++;
        }
        printf '%9i/%9i' . "\r", $count, $total;
    }
};
my $test_cache2 = sub {
    my $session = shift;
    for my $userId ( @$userIds ) {
        my $user = WebGUI::User->new( $session, $userId );
        for my $groupId ( @$groupIds ) {
            $user->isInGroup( $groupId );
            $count++;
        }
        printf '%9i/%9i' . "\r", $count, $total;
    }
};

print "Starting...\n";
my %test;
my %results;

$test{ 'CHI Memcached' } = sub {
    my ( $test ) = @_;
    finish($session);
    $session = start( $webguiRoot, $configFile );
    my $cMemcached      = WebGUI::CHI->new( $session, 
        driver      => 'Memcached::libmemcached',
        servers     => [ '127.0.0.1:11211' ],
    );
    $session->{_cache} = $cMemcached;
    my $cWebGUI = WebGUI::Cache->new( $session );
    $cWebGUI->flush;
    $count = 0;
    my %results;
    return timethis( $repeats, sub { $test->($session) },undef,  'none'  );
};

$test{ 'WebGUI Memcached' } = sub {
    my ( $test ) = @_;
    finish($session);
    $session = start( $webguiRoot, $configFile );
    my $cWebGUI = WebGUI::Cache->new( $session );
    $session->{_cache} = $cWebGUI;
    $cWebGUI->flush;
    $count = 0;
    return timethis( $repeats, sub { $test->($session) },undef,  'none'  );
};

$test{ 'CHI FastMmap' } = sub {
    my ( $test ) = @_;
    finish($session);
    $session = start( $webguiRoot, $configFile );
    my $cFastmmap       = WebGUI::CHI->new( $session,
        driver      => 'FastMmap',
        root_dir    => '/tmp',
        cache_size  => '50m',
    );
    $session->{_cache} = $cFastmmap;
    $cFastmmap->{chi}->remove_multi( [$cFastmmap->{chi}->get_keys] );
    $count = 0;
    return timethis( $repeats, sub { $test->($session) },undef,  'none'  );
};

$test{ 'CHI Null' } = sub {
    my ( $test ) = @_;
    finish($session);
    $session = start( $webguiRoot, $configFile );
    my $cNull   = WebGUI::CHI->new( $session,
        driver      => 'Null',
    );
    $session->{_cache} = $cNull;
    $count = 0;
    return timethis( $repeats, sub { $test->($session) }, undef, 'none'  );
};

$test{ 'WebGUI DB' } = sub {
    my ( $test ) = @_;
    finish($session);
    $session = start( $webguiRoot, $configFile );
    my $c = WebGUI::Cache::Database->new( $session );
    $session->{_cache} = $c;
    $c->flush;
    $count = 0;
    return timethis( $repeats, sub { $test->($session) },undef,  'none' );
};

$test{ 'WebGUI File' } = sub {
    my ( $test ) = @_;
    finish($session);
    $session = start( $webguiRoot, $configFile );
    my $c = WebGUI::Cache::FileCache->new( $session );
    $session->{_cache} = $c;
    $c->flush;
    $count = 0;
    return timethis( $repeats, sub { $test->($session) }, undef, 'none'  );
};


for my $test ( keys %test ) {
    printf "1:\%17s\n", "$test";
    $results{ $test } = $test{ $test }->($test_cache1);
}
cmpthese( \%results );

for my $test ( keys %test ) {
    printf "2: \%17s\n", "$test";
    $results{ $test } = $test{ $test }->($test_cache2);
}
cmpthese( \%results );

finish($session);

#----------------------------------------------------------------------------
# Your sub here

#----------------------------------------------------------------------------
sub start {
    my $webguiRoot  = shift;
    my $configFile  = shift;
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->set({name => 'Name Your Tag'});
    #
    ##
    
    return $session;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->commit;
    ##
    
    $session->var->end;
    $session->close;
}

__END__


=head1 NAME

utility - A template for WebGUI utility scripts

=head1 SYNOPSIS

 utility --configFile config.conf ...

 utility --help

=head1 DESCRIPTION

This WebGUI utility script helps you...

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
