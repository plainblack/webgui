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
use WebGUI::Workflow;
use WebGUI::Utility;

my $toVersion = "7.7.6"; 
my $quiet; 

my $session = start(); 

# upgrade functions go here
addTemplateAttachmentsTable($session);
addMobileStyleTemplate( $session );
revertUsePacked( $session );
fixDefaultPostReceived($session);
addEuVatDbColumns( $session );
addShippingDrivers( $session );
addTransactionTaxColumns( $session );
sendWebguiStats($session);
addDataFormColumns($session);
addListingsCacheTimeoutToMatrix( $session );
addSurveyFeedbackTemplateColumn( $session );
installCopySender($session);
installNotificationsSettings($session);
installSMSUserProfileFields($session);
installSMSSettings($session);
upgradeSMSMailQueue($session);
addPayDrivers($session);
addCollaborationColumns($session);
installSurveyTest($session);
installFriendManagerSettings($session);
installFriendManagerConfig($session);

finish($session); 


#----------------------------------------------------------------------------
sub sendWebguiStats {
    my $session = shift;
    print "\tAdding a workflow to allow users to take part in the WebGUI stats project..." unless $quiet;
    my $wf = WebGUI::Workflow->create($session, {
        type        => 'None',
        mode        => 'singleton',
        enabled     => 1,
        title       => 'Send WebGUI Stats',
        description => 'This workflow sends some information about your site to the central WebGUI statistics repository. No personal information is sent. The information is used to help determine the future direction WebGUI should take.',
        }, 'send_webgui_statistics');
    my $act = $wf->addActivity('WebGUI::Workflow::Activity::SendWebguiStats','send_webgui_statistics');
    $act->set('title', 'Send WebGUI Stats');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addMobileStyleTemplate {
    my $session = shift;
    print "\tAdding mobile style template field... " unless $quiet;
    $session->db->write(q{
        ALTER TABLE wobject ADD COLUMN mobileStyleTemplateId CHAR(22) BINARY DEFAULT 'PBtmpl0000000000000060'
    });
    $session->db->write(q{
        UPDATE wobject SET mobileStyleTemplateId = styleTemplateId
    });
    $session->db->write(q{
        ALTER TABLE Layout ADD COLUMN mobileTemplateId CHAR(22) BINARY DEFAULT 'PBtmpl0000000000000054'
    });
    $session->setting->add('useMobileStyle', 0);
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


#----------------------------------------------------------------------------
sub addSurveyTestResultsTemplateColumn {
    my $session = shift;
    print "\tAdding columns for Survey Test Results Template..." unless $quiet;
    $session->db->write("alter table Survey add column `testResultsTemplateId` char(22)");

    print "Done\n" unless $quiet;

}
#----------------------------------------------------------------------------
sub addListingsCacheTimeoutToMatrix{
    my $session = shift;
    print "\tAdding listingsCacheTimeout setting to Matrix table... " unless $quiet;
    $session->db->write("alter table Matrix add listingsCacheTimeout int(11) not null default 3600;");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTemplateAttachmentsTable {
    my $session = shift;
    print "\tAdding template attachments table... " unless $quiet;
    my $create = q{
        CREATE TABLE template_attachments (
            templateId   CHAR(22) BINARY,
            revisionDate bigint(20),
            url          varchar(256),
            type         varchar(20),
            sequence     int(11),

            PRIMARY KEY (templateId, revisionDate, url)
        )
    };
    $session->db->write($create);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Rollback usePacked. It should be carefully applied manually for now
sub revertUsePacked {
    my $session = shift;
    print "\tReverting use packed... " unless $quiet;
    my $iter    = WebGUI::Asset->getIsa( $session, 0, { returnAll => 1 } );
    while ( my $asset = $iter->() ) {
        $asset->update({ usePackedHeadTags => 0 });
        if ( $asset->isa('WebGUI::Asset::Template') || $asset->isa('WebGUI::Asset::Snippet') ) {
            $asset->update({ usePacked => 0 });
        }
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub fixDefaultPostReceived {
    my $session = shift;
    print "\tFixing post received template setting... " unless $quiet;
    $session->db->write(<<EOSQL);
UPDATE Collaboration SET postReceivedTemplateId='default_post_received1' WHERE postReceivedTemplateId='default-post-received'
EOSQL
    $session->db->write(<<EOSQL);
ALTER TABLE Collaboration ALTER COLUMN postReceivedTemplateId SET DEFAULT 'default_post_received1'
EOSQL
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addShippingDrivers {
    my $session = shift;
    print "\tAdding columns for improved VAT number checking..." unless $quiet;
    $session->config->addToArray('shippingDrivers', 'WebGUI::Shop::ShipDriver::USPS');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addEuVatDbColumns {
    my $session = shift;
    print "\tAdding columns for improved VAT number checking..." unless $quiet;
    
    $session->db->write( 'alter table tax_eu_vatNumbers add column viesErrorCode int(3) default NULL' );

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTransactionTaxColumns {
    my $session = shift;
    print "\tAdding columns for storing tax data in the transaction log..." unless $quiet;

    $session->db->write( 'alter table transactionItem add column taxRate decimal(6,3)' );
    $session->db->write( 'alter table transactionItem add column taxConfiguration mediumtext' );
    $session->db->write( 'alter table transactionItem change vendorPayoutAmount vendorPayoutAmount decimal (8,2) default 0.00' );

    print "Done\n" unless $quiet;

}

sub addDataFormColumns {
    my $session = shift;
    print "\tAdding column to store htmlArea Rich Editor in DataForm Table ..." unless $quiet;

    my $sth = $session->db->read( 'show columns in DataForm  where field = "htmlAreaRichEditor"' );
    if ($sth->rows() == 0) { # only add column if it is not already there
       $session->db->write( 'alter TABLE `DataForm` add column `htmlAreaRichEditor` varchar(22) default "**Use_Default_Editor**"' );
    }

    print "Done\n" unless $quiet;

}

#----------------------------------------------------------------------------
sub addSurveyFeedbackTemplateColumn {
    my $session = shift;
    print "\tAdding columns for Survey Feedback Template..." unless $quiet;
    $session->db->write("alter table Survey add column `feedbackTemplateId` char(22)");

    print "Done\n" unless $quiet;

}

#----------------------------------------------------------------------------
# Your sub here
sub installCopySender {
    my $session = shift;
    return if $session->setting->has('inboxCopySender');
    $session->setting->add('inboxCopySender',0);
}

sub installNotificationsSettings {
    my $session = shift;
    $session->setting->add('sendInboxNotificationsOnly', 0);
    $session->setting->add('inboxNotificationTemplateId', 'b1316COmd9xRv4fCI3LLGA');
}

sub installSMSUserProfileFields {
    my $session = shift;
    WebGUI::ProfileField->create(
        $session,
        'receiveInboxEmailNotifications',
        {
            label          => q!WebGUI::International::get('receive inbox emails','Message_Center')!,
            visible        => 1,
            required       => 0,
            protected      => 1,
            editable       => 1,
            fieldType      => 'yesNo',
            dataDefault    => 1,
        },
        4,
    );
    WebGUI::ProfileField->create(
        $session,
        'receiveInboxSmsNotifications',
        {
            label          => q!WebGUI::International::get('receive inbox sms','Message_Center')!,
            visible        => 1,
            required       => 0,
            protected      => 1,
            editable       => 1,
            fieldType      => 'yesNo',
            dataDefault    => 0,
        },
        4,
    );
}

sub installSMSSettings {
    my $session = shift;
    $session->setting->add('smsGateway', '');
}

sub upgradeSMSMailQueue {
    my $session = shift;
    $session->db->write('alter table mailQueue add column isInbox TINYINT(4) default 0');
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addPayDrivers {
    my $session = shift;
    print "\tAdding PayPal driver checking..." unless $quiet;
    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::PayPal::PayPalStd');
    print "DONE!\n" unless $quiet;
}

sub installSurveyTest {
    my $session = shift;
    print "\tInstall Survey test table, via Crud... " unless $quiet;
    use WebGUI::Asset::Wobject::Survey::Test;
    WebGUI::Asset::Wobject::Survey::Test->crud_createTable($session);
    print "DONE!\n" unless $quiet;
}

sub addCollaborationColumns {
    my $session = shift;
    print "\tAdding columns to store htmlArea Rich Editor and Filter Code for Replies in Collaboration Table ..." unless $quiet;

    my $sth = $session->db->read( 'show columns in Collaboration where field = "replyRichEditor"' );
    if ($sth->rows() == 0) { # only add columns if it hasn't been added already
       $session->db->write( 'alter TABLE `Collaboration` add column `replyRichEditor` varchar(22) default "PBrichedit000000000002"') ;
       $session->db->write( 'update `Collaboration` set `replyRichEditor` = `richEditor` ') ;
    }

   $sth = $session->db->read( 'show columns in Collaboration where field = "replyFilterCode"' );
    if ($sth->rows() == 0) { # only add columns if it hasn't been added already
       $session->db->write( 'alter TABLE `Collaboration` add column `replyFilterCode` varchar(30) default "javascript"') ;
       $session->db->write( 'update `Collaboration` set `replyFilterCode` = `filterCode` ') ;
    }

    print "Done\n" unless $quiet;

}

sub installFriendManagerSettings {
    my $session = shift;
    print "\tInstalling FriendManager into settings...";
    $session->setting->add('groupIdAdminFriends',         '3');
    $session->setting->add('fmViewTemplateId', '64tqS80D53Z0JoAs2cX2VQ');
    $session->setting->add('fmEditTemplateId', 'lG2exkH9FeYvn4pA63idNg');
    $session->setting->add('groupsToManageFriends',       '2');
    $session->setting->add('overrideAbleToBeFriend',       0);
    print "\tDone\n";
}

sub installFriendManagerConfig {
    my $session = shift;
    my $config  = $session->config;
    my $account = $config->get('account');
    my @classes = map { $_->{className} } @{ $account };
    return if isIn('WebGUI::Account::FriendManager', @classes);
    print "\tInstalling FriendManager into config file...";
    push @{ $account },
        {
            identifier => 'friendManager',
            title      => '^International(title,Account_FriendManager);',
            className  => 'WebGUI::Account::FriendManager',
        }
    ;
    $config->set('account', $account);
    print "\tDone\n";
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
