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
use WebGUI::Workflow::Instance;


my $toVersion = '7.9.5';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
modifySortItems( $session );
fixRequestForApprovalScratch($session);
addRejectNoticeSetting($session);
updateGroupGroupingsTable($session);
installNewCSUnsubscribeTemplate($session);

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
# Adds setting which allows users to set whether or not to send reject notices
sub addRejectNoticeSetting {
    my $session = shift;
    print "\tAdding reject notice setting... " unless $quiet;
    $session->setting->add('sendRejectNotice',1);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub installNewCSUnsubscribeTemplate {
    my $session = shift;
    print "\tAdding new unsubscribe template to the CS... " unless $quiet;
    $session->db->write(q|ALTER TABLE Collaboration ADD COLUMN unsubscribeTemplateId CHAR(22) NOT NULL|);
    $session->db->write(q|UPDATE Collaboration set unsubscribeTemplateId='default_CS_unsubscribe'|);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add keys and indicies to groupGroupings to help speed up group queries
sub updateGroupGroupingsTable {
    my $session = shift;
    print "\tAdding primary key and indicies to groupGroupings table... " unless $quiet;
    my $sth = $session->db->read('show create table groupGroupings');
    my ($field,$stmt) = $sth->array;
    $sth->finish;
    unless ($stmt =~ m/PRIMARY KEY/i) {
        # clean up duplicates that would prevent applying a primary key
        my $rs = $session->db->read(q{ 
            select count(*) as num, groupId, inGroup
            from groupGroupings
            group by groupId, inGroup 
            having num > 1
        });
        my $dupSth = $session->db->prepare("delete from groupGroupings where groupId = ? and inGroup = ? limit ?");
        while (my ($num, $groupId, $inGroup) = $rs->array) {
            $dupSth->execute([$groupId, $inGroup, $num-1]);
        }
        $dupSth->finish;
        # add the primary key 
        $session->db->write("alter table groupGroupings add primary key (groupId,inGroup)");
    }
    unless ($stmt =~ m/KEY `inGroup`/i) {
        $session->db->write("alter table groupGroupings add index inGroup (inGroup)");
    }
    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Describe what our function does
sub fixRequestForApprovalScratch {
    my $session = shift;
    print "\tCorrect RequestApprovalForVersionTag workflow instance data with leading commas... " unless $quiet;
    # and here's our code
    my $instances = WebGUI::Workflow::Instance->getAllInstances($session);
    INSTANCE: foreach my $instance (@{ $instances }) {
        my $messageId = $instance->getScratch('messageId');
        next INSTANCE unless $messageId;
        $messageId =~ s/^,//;
        $instance->setScratch('messageId', $messageId);
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Changes sortItems to a SelectBox
sub modifySortItems {
    my $session = shift;
    print "\tUpdating SyndicatedContent...\n" unless $quiet;

    require WebGUI::Form::SelectBox;

    print "\t\tModifying table...\n" unless $quiet;
    my $type = WebGUI::Form::SelectBox->getDatabaseFieldType;
    $session->db->write("ALTER TABLE SyndicatedContent MODIFY sortItems $type");

    print "\t\tConverting old values..." unless $quiet;
    $session->db->write(q{
        UPDATE SyndicatedContent
        SET    sortItems = 'none'
        WHERE  sortItems <> '1'
    });
    $session->db->write(q{
        UPDATE SyndicatedContent
        SET    sortItems = 'pubDate_des'
        WHERE  sortItems = '1'
    });

    # and here's our code
    print "DONE!\n" unless $quiet;
}

# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    print "\tUpgrading package $file\n" unless $quiet;
    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = eval {
        my $node = WebGUI::Asset->getImportNode($session);
        $node->importPackage( $storage, {
            overwriteLatest    => 1,
            clearPackageFlag   => 1,
            setDefaultTemplate => 1,
        } );
    };

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.  Stopping upgrade.\n";
    }
    if ($@ || !defined $package) {
        die "Error during package import on $file: $@\nStopping upgrade\n.";
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
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".time().")");
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
