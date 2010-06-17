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


my $toVersion = '7.7.18';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addSmsGatewaySubjectSetting($session);
addInboxNotificationsSubjectSetting($session);
profileFieldRequiredEditable($session);
deleteOldInboxMessageStates($session);
setDefaultEMSScheduleTemplate($session);
addCarouselSlideWidth($session);
finish($session); # this line required

#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

sub addCarouselSlideWidth {
    my $session = shift;
    print "\tAdd a default width property to the Carousel... " unless $quiet;
    $session->db->write(<<EOSQL);
ALTER TABLE Carousel ADD COLUMN slideWidth int(11)
EOSQL
    $session->db->write(<<EOSQL);
UPDATE Carousel SET slideWidth=0;
EOSQL
    
    print "DONE!\n" unless $quiet;
}

sub setDefaultEMSScheduleTemplate {
    my $session = shift;
    print "\tSet the default EMS schedule template on existing EMS'es that do not have one... " unless $quiet;
    $session->db->write(<<EOSQL);
update EventManagementSystem set scheduleTemplateId='S2_LsvVa95OSqc66ITAoig' where scheduleTemplateId IS NULL;
EOSQL
    print "DONE!\n" unless $quiet;
}

sub deleteOldInboxMessageStates {
    my $session = shift;
    print "\tDelete Inbox messages states for users who have been deleted... " unless $quiet;
    $session->db->write(<<EOSQL);
DELETE FROM inbox_messageState WHERE userId NOT IN (SELECT userId FROM users)
EOSQL
    print "DONE!\n" unless $quiet;
}

sub profileFieldRequiredEditable {
    my $session = shift;
    print "\tTurn on the editable bit for all Profile Fields which are required... " unless $quiet;
    FIELD: foreach my $field (@{ WebGUI::ProfileField->getRequiredFields($session) } ) {
        my $properties = $field->get();
        next FIELD unless !$properties->{editable};
        $properties->{editable} = 1;
        $field->set($properties);
    }
    print "DONE!\n" unless $quiet;
}

sub addSmsGatewaySubjectSetting {
    my $session = shift;
    print "\tAdding smsGatewaySubject setting... " unless $quiet;
    $session->setting->add('smsGatewaySubject', '');
    print "DONE!\n" unless $quiet;
}

sub addInboxNotificationsSubjectSetting {
    my $session = shift;
    print "\tAdding inboxNotificationsSubject setting... " unless $quiet;
    $session->setting->add('inboxNotificationsSubject', '');
    print "DONE!\n" unless $quiet;
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
