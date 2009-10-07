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

our ($webguiRoot);

BEGIN {
    $webguiRoot = "../..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = '7.7.22';
my $quiet; # this line required


my $session = start(); # this line required
removeOldITransactTables( $session );
removeImportCruft( $session );
removeAdminFromVisitorGroup( $session );
fixPackageFlagOnOlder( $session );

fixTableDefaultCharsets($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
sub fixPackageFlagOnOlder {
    my $session = shift;
    print "\tFixing isPackage flag on folders from 7.6.35 to 7.7.17 upgrade... " unless $quiet;

    my @assetIds = qw( TvOZs8U1kRXLtwtmyW75pg
    tXwf1zaOXTvsqPn6yu-GSw
    tPagC0AQErZXjLFZQ6OI1g
    brxm_faNdZX5tRo3p50g3g
    BFfNj5wA9bDw8H3cnr8pTw
    VZK3CRgiMb8r4dBjUmCTgQ
    2c4RcwsUfQMup_WNujoTGg
    f_tn9FfoSfKWX43F83v_3w
    oGfxez5sksyB_PcaAsEm_Q
    GaBAW-2iVhLMJaZQzVLE5A
    7-0-style0000000000049
    GYaFxnMu9UsEG8oanwB6TA
    );

    for my $assetId ( @assetIds ) {
        my $asset = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        next unless $asset;
        next unless $asset->get('isPackage');
        $asset->addRevision({ isPackage => 0 });
    }

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub removeOldITransactTables {
    my $session = shift;
    print "\tRemoving tables leftover from the old 7.5 ITransact Plugin... " unless $quiet;
    $session->db->write('DROP TABLE IF EXISTS ITransact_recurringStatus');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixTableDefaultCharsets {
    my $session = shift;
    my $db = $session->db;
    print "\tFixing default character set on tables... " unless $quiet;
    my @tables = qw(
        Carousel Collaboration DataTable Map MapPoint MatrixListing
        MatrixListing_attribute Story StoryArchive StoryTopic
        Survey_questionTypes Survey_test ThingyRecord ThingyRecord_record
        adSkuPurchase assetAspectComments assetAspectRssFeed
        filePumpBundle inbox_messageState taxDriver tax_eu_vatNumbers
        template_attachments
    );
    for my $table (@tables) {
        $db->write(
            sprintf('ALTER TABLE %s DEFAULT CHARACTER SET = ?', $db->dbh->quote_identifier($table)),
            ['utf8'],
        );
    }
    my $db_name = $db->dbh->{Name};
    my $database = (split /[;:]/, $db_name)[0];
    while ( $db_name =~ /([^=;:]+)=([^;:]+)/msxg ) {
        if ( $1 eq 'db' || $1 eq 'database' || $1 eq 'dbname' ) {
            $database = $2;
            last;
        }
    }
    $session->db->write(sprintf 'ALTER DATABASE %s DEFAULT CHARACTER SET utf8', $db->dbh->quote_identifier($database));

    print "Done.\n" unless $quiet;
}

# Describe what our function does
sub removeImportCruft {
    my $session = shift;
    print "\tRemoving cruft from the import node... " unless $quiet;
    my $propFolder = WebGUI::Asset->newByDynamicClass($session, '2c4RcwsUfQMup_WNujoTGg');
    if ($propFolder) {
        $propFolder->purge;
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub removeAdminFromVisitorGroup {
    my $session = shift;
    print "\tRemoving Admin group from Visitor group... " unless $quiet;
    $session->db->write("delete from groupGroupings where groupId='3' and inGroup='1'");
    print "Done.\n" unless $quiet;
}

# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = eval { WebGUI::Asset->getImportNode($session)->importPackage( $storage, { overwriteLatest => 1 } ); };

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.  Stopping upgrade.\n";
    }
    if ($@ || !defined $package) {
        die "Error during package import on $file: $@\nStopping upgrade\n.";
    }

    # Turn off the package flag, and set the default flag for templates added
    my $assetIds = $package->getLineage( ['self','descendants'] );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        my $properties = { isPackage => 0 };
        if ($asset->isa('WebGUI::Asset::Template')) {
            $properties->{isDefault} = 1;
        }
        $asset->update( $properties );
    }

    return;
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Upgrade to ".$toVersion});
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

#vim:ft=perl
