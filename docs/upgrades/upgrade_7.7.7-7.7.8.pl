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


my $toVersion = '7.7.8';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
messageStateCleanup($session);
addOgoneToConfig( $session );
addSurveyExpressionEngineConfigFlag($session);
addMobileStyleConfig($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#----------------------------------------------------------------------------

sub messageStateCleanup {
    my $session = shift;
    my $db      = $session->db;

    # Acquire messageIds to fine orphans (no inbox message associated) and those with group delivered system messages marked as completed
    #
    my $messageListRef = $db->buildArrayRef("SELECT distinct messageId FROM inbox_messageState WHERE isRead=0 AND deleted = 0");
    my $sth            = $db->read("SELECT status,groupId FROM inbox WHERE messageId=?");
    for my $messageId (@$messageListRef) {
        $sth->execute([$messageId]);
        my $rows = $sth->rows;

        # No reference to any current message in the inbox
        #
        if ( !$rows ) {
            $db->write( "DELETE FROM inbox_messageState WHERE messageId=?", [$messageId] );
        }
        else {
            # test messages for values of completed status and group delivery
            #
            while ( my ( $status, $groupId ) = $sth->array ) {
                next if $status ne "completed" || !$groupId;
                $db->write( "UPDATE inbox_messageState SET isRead=1 WHERE messageId=?", [$messageId] );
            }
        }
    } ## end for my $messageId (@$messageListRef)
    $sth->finish;
} ## end sub messageStateCleanup

#----------------------------------------------------------------------------
sub addOgoneToConfig {
    my $session = shift;
    print "\tAdding Ogone payment plugin..." unless $quiet;

    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::Ogone');
    
    print "Done\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub addSurveyExpressionEngineConfigFlag{
    my $session = shift;
    print "\tAdding enableSurveyExpressionEngine config option... " unless $quiet;
    $session->config->set('enableSurveyExpressionEngine', 0);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addMobileStyleConfig {
    my $session = shift;
    print "\tAdding mobile style user agents to config file... " unless $quiet;
    $session->config->set('mobileUserAgents', [
        'AvantGo',
        'DoCoMo',
        'Vodafone',
        'EudoraWeb',
        'Minimo',
        'UP\.Browser',
        'PLink',
        'Plucker',
        'NetFront',
        '^WM5 PIE$',
        'Xiino',
        'iPhone',
        'Opera Mobi',
        'BlackBerry',
        'Opera Mini',
        'HP iPAQ',
        'IEMobile',
        'Profile/MIDP',
        'Smartphone',
        'Symbian ?OS',
        'J2ME/MIDP',
        'PalmSource',
        'PalmOS',
        'Windows CE',
        'Opera Mini',
    ]);
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
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage, { overwriteLatest => 1 } );

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
