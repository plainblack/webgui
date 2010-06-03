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
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Exception;
use WebGUI::Workflow::Cron;
use WebGUI::Utility qw/isIn/;


my $toVersion = '7.9.7';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
restoreDefaultCronJobs($session);
restoreCsCronJobs($session);

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
# Describe what our function does
sub restoreDefaultCronJobs {
    my $session = shift;
    # and here's our code
    print "\tRestore missing default cron jobs that may have been deleted... " unless $quiet;
    my $tasks = WebGUI::Workflow::Cron->getAllTasks($session);
    my @taskIds = map { $_->getId } @{ $tasks };
    if (! isIn('pbcron0000000000000001', @taskIds)) {
        print "\n\t\tRestoring Daily Maintenance Task... " unless $quiet;
        WebGUI::Workflow::Cron->create($session, {
            title        => "Daily Maintenance", dayOfMonth   => '*',
            enabled      => 1,                   monthOfYear  => '*',
            runOnce      => 0,                   dayOfWeek    => '*',
            minuteOfHour => 30,                  workflowId   => 'pbworkflow000000000001',
            hourOfDay    => 23,                  priority     => 3,
        },
        'pbcron0000000000000001');
    }
    if (! isIn('pbcron0000000000000002', @taskIds)) {
        print "\n\t\tRestoring Weekly Maintenance Task... " unless $quiet;
        WebGUI::Workflow::Cron->create($session, {
            title        => "Weekly Maintenance", dayOfMonth   => '*',
            enabled      => 1,                    monthOfYear  => '*',
            runOnce      => 0,                    dayOfWeek    => '0',
            minuteOfHour => 30,                   workflowId   => 'pbworkflow000000000002',
            hourOfDay    => 1,                    priority     => 3,
        },
        'pbcron0000000000000002');
    }
    if (! isIn('pbcron0000000000000003', @taskIds)) {
        print "\n\t\tRestoring Hourly Maintenance Task... " unless $quiet;
        WebGUI::Workflow::Cron->create($session, {
            title        => "Hourly Maintenance", dayOfMonth   => '*',
            enabled      => 1,                    monthOfYear  => '*',
            runOnce      => 0,                    dayOfWeek    => '*',
            minuteOfHour => 15,                   workflowId   => 'pbworkflow000000000004',
            hourOfDay    => '*',                  priority     => 3,
        },
        'pbcron0000000000000003');
    }
    if (! isIn('pbcron0000000000000004', @taskIds)) {
        print "\n\t\tRestoring Email Delivery Task... " unless $quiet;
        WebGUI::Workflow::Cron->create($session, {
            title        => "Send Queued Email Messages Every 5 Minutes",
                                                  dayOfMonth   => '*',
            enabled      => 1,                    monthOfYear  => '*',
            runOnce      => 0,                    dayOfWeek    => '*',
            minuteOfHour => '*/5',                workflowId   => 'pbworkflow000000000007',
            hourOfDay    => '*',                  priority     => 3,
        },
        'pbcron0000000000000004');
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub restoreCsCronJobs {
    my $session = shift;
    print "\tRestore missing Collaboration System cron jobs that may have been deleted... " unless $quiet;
    my $i18n = WebGUI::International->new($session, "Asset_Collaboration");
    my $getCs = WebGUI::Asset::Wobject::Collaboration->getIsa($session);
    CS: while (1) {
        my $cs = eval { $getCs->(); };
        if (my $e = Exception::Class->caught()) {
            $session->log->error($@);
            next CS;
        }
        last CS unless $cs;
        ##Do something useful with $product
        my $cron = undef;
        if ($cs->get("getMailCronId")) {
            $cron = WebGUI::Workflow::Cron->new($session, $cs->get("getMailCronId"));
        }
        next CS if $cron;
        $cron = WebGUI::Workflow::Cron->create($session, {
                title        => $cs->getTitle." ".$i18n->get("mail"),
                minuteOfHour => "*/".($cs->get("getMailInterval")/60),
                className    => (ref $cs),
                methodName   => "new",
                parameters   => $cs->getId,
                workflowId   => "csworkflow000000000001"
                });
        $cs->update({getMailCronId=>$cron->getId});
        if ($cs->get("getMail")) {
                $cron->set({enabled=>1,title=>$cs->getTitle." ".$i18n->get("mail"), minuteOfHour=>"*/".($cs->get("getMailInterval")/60)});
        } else {
                $cron->set({enabled=>0,title=>$cs->getTitle." ".$i18n->get("mail"), minuteOfHour=>"*/".($cs->get("getMailInterval")/60)});
        }

    }
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
