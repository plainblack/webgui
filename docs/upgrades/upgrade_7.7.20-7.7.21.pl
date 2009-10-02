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


my $toVersion = '7.7.21';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
fixEmptyCalendarIcalFeeds( $session );
fixEMSTemplates( $session );
removeOldSubscriptionTables( $session );
removeSQLFormTables( $session );
fixBadRevisionDateColumns( $session );

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

# Describe what our function does
#----------------------------------------------------------------------------
sub fixBadRevisionDateColumns {
    my $session = shift;
    print "\tGive all revisionDate columns the correct definition... " unless $quiet;
    $session->db->write("ALTER TABLE Event       MODIFY COLUMN revisionDate BIGINT NOT NULL DEFAULT 0");
    $session->db->write("ALTER TABLE Calendar    MODIFY COLUMN revisionDate BIGINT NOT NULL DEFAULT 0");
    $session->db->write("ALTER TABLE MultiSearch MODIFY COLUMN revisionDate BIGINT NOT NULL DEFAULT 0");
    $session->db->write("ALTER TABLE Dashboard   MODIFY COLUMN revisionDate BIGINT NOT NULL DEFAULT 0");
    $session->db->write("ALTER TABLE StockData   MODIFY COLUMN revisionDate BIGINT NOT NULL DEFAULT 0");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub removeSQLFormTables {
    my $session = shift;
    print "\tRemoving leftover SQL Form tables if not used... " unless $quiet;
    my $tablesUsed = $session->db->quickScalar("select count(*) from asset where className='WebGUI::Asset::Wobject::SQLForm'");
    if (!$tablesUsed) {
        $session->db->write('DROP TABLE IF EXISTS SQLForm_fieldOrder');
        print "\n\t\tSQL Form not used, dropping table...";
    }
    print "Done.\n" unless $quiet;
}

# Describe what our function does
#----------------------------------------------------------------------------
sub removeOldSubscriptionTables {
    my $session = shift;
    print "\tRemoving tables leftover from the old 7.5 Commerce System... " unless $quiet;
    $session->db->write('DROP TABLE IF EXISTS subscriptionCode');
    $session->db->write('DROP TABLE IF EXISTS subscriptionCodeBatch');
    $session->db->write('DROP TABLE IF EXISTS subscriptionCodeSubscriptions');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixEmptyCalendarIcalFeeds {
    my $session = shift;
    print "\tSetting icalFeeds in the Calendar to the proper default... " unless $quiet;

    $session->db->write( 
        "UPDATE Calendar set icalFeeds='[]' where icalFeeds IS NULL",
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixEMSTemplates {
    my $session = shift;
    print "\tFixing bad usage of Event Management System templates... " unless $quiet;
    $session->db->write(q|update EventManagementSystem set templateId='2rC4ErZ3c77OJzJm7O5s3w'         where templateId='S2_LsvVa95OSqc66ITAoig'|);
    $session->db->write(q|update EventManagementSystem set scheduleTemplateId='S2_LsvVa95OSqc66ITAoig' where scheduleTemplateId='2rC4ErZ3c77OJzJm7O5s3w'|);
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
