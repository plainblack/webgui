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
use WebGUI::Inbox;


my $toVersion = '7.9.16';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
pruneInboxMessagesFromDeletedUsers($session);
addTemplateToNotifyAboutVersionTag($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
sub pruneInboxMessagesFromDeletedUsers {
    my $session = shift;
    print "\tPruning inbox messages from deleted users.  This may take a while... " unless $quiet;
    my $sth = $session->db->prepare(<<EOSQL);
select messageId, inbox.userId
    from inbox_messageState
    join inbox using (messageId)
    left outer join users on inbox.userId=users.userId
    where users.userId IS NULL
EOSQL
    $sth->execute([]);
    my $inbox = WebGUI::Inbox->new($session);
    while (my ($messageId, $userId) = $sth->array) {
        my $message = $inbox->getMessage($messageId, $userId);
        if ($message) {
            $message->delete;
        }
    }
    print "...DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Describe what our function does
sub addTemplateToNotifyAboutVersionTag {
    my $session = shift;
    print "\tAdd template to Notify About Version Tag workflow activities." unless $quiet;
    use WebGUI::Workflow::Activity;
    use WebGUI::Workflow::Activity::NotifyAboutVersionTag;
    my $templateId = WebGUI::Workflow::Activity::NotifyAboutVersionTag->definition($session)->[0]->{properties}->{templateId}->{defaultValue};
    my $activityList = $session->db->read(q|select activityId from WorkflowActivity|);
    while (my ($activityId) = $activityList->array) {
        my $activity = WebGUI::Workflow::Activity->new($session, $activityId);
        next unless $activity;
        next unless $activity->isa('WebGUI::Workflow::Activity::NotifyAboutVersionTag')
                 || $activity->isa('WebGUI::Workflow::Activity::RequestApprovalForVersionTag')
                  ;
        $activity->set('templateId', $templateId);
    }
    print "...DONE!\n" unless $quiet;
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
