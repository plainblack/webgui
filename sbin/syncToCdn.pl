#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our $webguiRoot;

BEGIN {
    $webguiRoot = "..";
    unshift( @INC, $webguiRoot . "/lib" );
}

use strict;
use Fcntl ':flock';
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use Pod::Usage;

my $configFile;
my $help;
my $migrate;
my $override;
my $quiet;

GetOptions(
    'configFile=s' => \$configFile,
    'override'     => \$override,
    'migrate'      => \$migrate,
    'quiet'        => \$quiet,
    'h|help'       => \$help,
);

pod2usage( { verbose => 2, exitval => 2, } ) if $help;
pod2usage( { exitval => 4, } ) unless $configFile;

# don't want two copies of this to run simultaneously
unless ( flock( DATA, LOCK_EX | LOCK_NB ) ) {
    print "$0 is already running. Exiting.\n";
    exit 3;
}

if ( !( $^O =~ /^Win/i ) && $> != 0 && !$override ) {
    print "You must be the super user to use this utility.\n";
    exit 1;
}

print "Starting..." unless ($quiet);
my $session = WebGUI::Session->open( $webguiRoot, $configFile );
$session->user( { userId => 3 } );
print "OK\n" unless ($quiet);

my $cdnCfg = $session->config->get('cdn');
unless ( $cdnCfg and $cdnCfg->{'enabled'} and $cdnCfg->{'queuePath'} ) {
    print "Content delivery network (CDN) is not enabled in $configFile.\n";
    exit 5;
}

# Here is the core of the script
if ($migrate) {
    syncUploads($session);
}
else {
    syncQueue( $session, $cdnCfg );
}

print "Cleaning up..." unless ($quiet);
$session->var->end();
$session->close();

print "OK\n" unless ($quiet);
exit 0;

#-----------------------------------------
# syncQueue(session, cdnConfig)
#-----------------------------------------

sub syncQueue {
    my $session = shift;
    my $cdnCfg  = shift;
    my $locIter = WebGUI::Storage->getCdnFileIterator($session);
    while ( my $store = $locIter->() ) {
        my $ctrlFile = $cdnCfg->{'queuePath'} . '/' . $store->getDirectoryId;
        if ( -r $ctrlFile and -s $ctrlFile < 12 ) {
            if ( !-s $ctrlFile ) {    # Empty means sync/add/update
                $store->syncToCdn;
            }
            else {                    # expect "deleted" but be careful.
                if ( open my $ctrlFH, "<$ctrlFile" ) {
                    my $directive = <$ctrlFH>;
                    chomp $directive;
                    close $ctrlFH;
                    if ( $directive =~ m/^deleted$/i ) {
                        $store->deleteFromCdn;
                    }                 # else unknown - ignore
                }
                else {
                    warn "Cannot read CDN control file $ctrlFile.";
                    $session->errorHandler->warn("Cannot read CDN control file $ctrlFile.");
                }
            }
        } ## end if ( -r $ctrlFile and ...
        else {                        # missing or invalid
		    warn "No recognizable CDN control file $ctrlFile.";
		    $session->errorHandler->warn("No recognizable CDN control file $ctrlFile.");
        }
    } ## end while ( my $store = $locIter...
}    # end syncQueue

#-----------------------------------------
# syncUploads(session)
#-----------------------------------------

sub syncUploads {
    my $session = shift;

    # Alternate approach would be touch queue files, then run queue.
    my $uDir = $session->config->get('uploadsPath');
    if ( opendir my $DH, $uDir ) {
        my @part1 = grep { !/^\.+$/ } readdir($DH);
        foreach my $subdir (@part1) {
            if ( opendir my $SD, "$uDir/$subdir" ) {
                my @part2 = grep { !/^\.+$/ } readdir($SD);
                foreach my $sub2 (@part2) {
                    if ( opendir my $S2, "$uDir/$subdir/$sub2" ) {
                        my @fileId = grep { !/^\.+$/ } readdir($S2);
                        foreach my $fileId (@fileId) {
 			    my $storageId = $fileId;
			    if (length($storageId) > 22) {
			        # need to convert from hex
				$storageId = $session->id->fromHex($storageId);
			    }
                            my $store = WebGUI::Storage->get( $session, $storageId );
                            $store->syncToCdn;    # here is the meat
                        }
                        close $S2;
                    }
                    else {
                        $session->errorHandler->warn("Unable to open $sub2 for directory reading");
                    }
                }
                close $SD;
            } ## end if ( opendir my $SD, "$uDir/$subdir")
            else {
                $session->errorHandler->warn("Unable to open $subdir for directory reading");
            }
        } ## end foreach my $subdir (@part1)
        close $DH;
    } ## end if ( opendir my $DH, $uDir)
    else {
        $session->errorHandler->warn("Unable to open $uDir for directory reading");
    }
}    # end syncUploads

__DATA__
This exists so flock() code above works.
DO NOT REMOVE THIS DATA SECTION.

__END__

=head1 NAME

syncToCdn - WebGUI interface to a Content Delivery Network.

=head1 SYNOPSIS

 syncToCdn.pl --configFile config.conf
             [--override]
             [--migrate]
             [--quiet]

 syncToCdn.pl --help

=head1 DESCRIPTION

This WebGUI utility script displays the amount of disk space used by
an asset and it's descendants. It has been modeled after the *nix 'du'
utility.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--override>

This utility is designed to be run as a privileged user on Linux style
systems.  If you wish to run this utility without being the super user,
then use this flag, but note that it may not work as intended.

=item B<--migrate>

Migrate entirety of uploads directory to CDN.  Ignore the CDN queue and
sync everything.

=item B<--quiet>

Disable output unless there is an error.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 EXIT CODES

The following exit values are returned:

=over 4

=item 0

Successful execution.

=item 1

Only super user may run the script.

=item 2

Help requested.

=item 3

Only one instance of this script can run at a time.

=item 4

Error during invocation of the command.

=item 5

Content Delivery Network (CDN) is not enabled.

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut
