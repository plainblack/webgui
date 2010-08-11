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
use WebGUI::Asset::WikiPage;
use WebGUI::Shop::AddressBook;
use WebGUI::Shop::Pay;
use WebGUI::Workflow;
use WebGUI::Utility;


my $toVersion = "7.9.11"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
##7.9.1-.2
addSortItemsSCColumn($session);
addExtensionWorkflow($session);

##7.9.2-.3
reindexSiteForDefaultSynopsis( $session );
addTopLevelWikiKeywords( $session );

##7.9.3-.4
addWikiSubKeywords($session);
addSynopsistoEachWikiPage($session);
dropVisitorAddressBooks($session);
alterCartTable($session);
alterAddressBookTable($session);
addWizardHandler( $session );
addTemplateExampleImage( $session );
addPayDriverTemplates( $session );

##7.9.4-.5
modifySortItems( $session );
addRejectNoticeSetting($session);
installNewCSUnsubscribeTemplate($session);

##7.9.5-.6
addIndexForInbox($session);

##7.9.7-.8
addTwitterAuth( $session );

##7.9.8-.9
migrateAttachmentsToJson( $session );

##7.9.9-.10
alterStoryArchiveTable($session);

##7.9.10-.11
alterStoryTopicTable($session);
addAssetReport($session);

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
sub addExtensionWorkflow {
    print "\tAdding calendar event extension to weekly maintenence..."
        unless $quiet;
    my $workflow = WebGUI::Workflow->new($session, 'pbworkflow000000000002');
    my $activity = $workflow->addActivity('WebGUI::Workflow::Activity::ExtendCalendarRecurrences');
    $activity->set(title => 'Extend Calendar Recurrences');
    $activity->set(description => 'Create events for live recurrences up to two years from the current date');
    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSortItemsSCColumn {
    my $session = shift;
    print "\tAdding sort items switch to Syndicated Content... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `SyndicatedContent`');
    while (my ($col) = $sth->array) {
        if ($col eq 'sortItems') {
            print "Skipped.\n" unless $quiet;
            return;
        }
    }
    $session->db->write('ALTER TABLE SyndicatedContent ADD COLUMN sortItems BOOL DEFAULT 1');

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTopLevelWikiKeywords {
    my $session = shift;
    print "\tAdding top level keywords page to WikiMaster... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `WikiMaster`');
    while (my ($col) = $sth->array) {
        if ($col eq 'topLevelKeywords') {
            print "Skipped.\n" unless $quiet;
            return;
        }
    }
    $session->db->write('ALTER TABLE WikiMaster ADD COLUMN topLevelKeywords LONGTEXT');

    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Reindex the site to clear out default synopsis
sub reindexSiteForDefaultSynopsis {
    my $session = shift;
    print "\tRe-indexing site to clear out default synopses... " unless $quiet;

    my $rs = $session->db->read("select assetId, className from asset where state='published'");
    my @searchableAssetIds;
    while (my ($id, $class) = $rs->array) {
        my $asset = WebGUI::Asset->new($session,$id,$class);
        if (defined $asset && $asset->get("state") eq "published" && ($asset->get("status") eq "approved" || $asset->get("status") eq "archived")) {
            $asset->indexContent;
            push (@searchableAssetIds, $id);
        }
    }

    # delete indexes of assets that are no longer searchable
    my $list = $session->db->quoteAndJoin(\@searchableAssetIds) if scalar(@searchableAssetIds);
    $session->db->write("delete from assetIndex where assetId not in (".$list.")") if $list;

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add example images to templates
sub addTemplateExampleImage {
    my $session = shift;
    print "\tAdding example image field to template... " unless $quiet;

    $session->db->write( q{
        ALTER TABLE template ADD storageIdExample CHAR(22)
    } );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------

sub addWizardHandler {
    my ( $sesssion ) = @_;
    print "\tAdding WebGUI::Wizard... " unless $quiet;

    if ( !grep { $_ eq 'WebGUI::Content::Wizard' } @{$session->config->get('contentHandlers')} ) {
        # Find the place of Operation and add before
        my @handlers = ();
        for my $handler ( @{$session->config->get('contentHandlers')} ) {
            if ( $handler eq 'WebGUI::Content::Operation' ) {
                push @handlers, 'WebGUI::Content::Wizard';
            }
            push @handlers, $handler;
        }
        $session->config->set('contentHandlers',\@handlers);
    }

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addWikiSubKeywords {
    my $session = shift;
    print "\tAdd the WikiMaster sub-keywords table... " unless $quiet;
    # and here's our code
    $session->db->write(<<EOSQL);
CREATE TABLE IF NOT EXISTS WikiMasterKeywords (
    assetId CHAR(22) binary not null,
    keyword CHAR(64) not null,
    subKeyword CHAR(64),
    PRIMARY KEY (`assetId`,`keyword`, `subKeyword`),
    KEY `assetId` (`assetId`),
    KEY `keyword` (`keyword`),
    KEY `subKeyword` (`subKeyword`)
)
EOSQL
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSynopsistoEachWikiPage {
    my $session = shift;
    print "\tAdd a synopsis to each wiki page this may take a while... " unless $quiet;
    my $pager = WebGUI::Asset::WikiPage->getIsa($session);
    PAGE: while (1) {
       my $page = eval {$pager->()};
       next PAGE if Exception::Class->caught();
       last PAGE unless $page;
       my ($synopsis) = $page->getSynopsisAndContent(undef, $page->get('content'));
       $page->update({synopsis => $synopsis});
    }
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub dropVisitorAddressBooks {
    my $session = shift;
    print "\tDrop AddressBooks owned by Visitor... " unless $quiet;
    my $sth = $session->db->read(q|SELECT addressBookId FROM addressBook where userId='1'|);
    BOOK: while (my ($addressBookId) = $sth->array) {
        my $book = eval { WebGUI::Shop::AddressBook->new($session, $addressBookId); };
        next BOOK if Exception::Class->caught();
        $book->delete;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub alterAddressBookTable {
    my $session = shift;
    print "\tDrop sessionId from the Address Book database table... " unless $quiet;
    # and here's our code
    $session->db->write("ALTER TABLE addressBook DROP COLUMN sessionId");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub alterCartTable {
    my $session = shift;
    print "\tAdd billing address column to the Cart table... " unless $quiet;
    # and here's our code
    $session->db->write("ALTER TABLE cart ADD COLUMN billingAddressId CHAR(22)");
    $session->db->write("ALTER TABLE cart ADD COLUMN gatewayId        CHAR(22)");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addPayDriverTemplates {
    my $session = shift;
    print "\tAdd templates to the Payment Drivers that need them... " unless $quiet;
    # and here's our code
    my $pay = WebGUI::Shop::Pay->new($session);
    my @gateways = @{ $pay->getPaymentGateways };
    GATEWAY: foreach my $gateway (@gateways) {
        next GATEWAY unless $gateway;
        my $properties = $gateway->get;
        if ($gateway->isa('WebGUI::Shop::PayDriver::Cash')) {
            $properties->{summaryTemplateId} = '30h5rHxzE_Q0CyI3Gg7EJw';
        }
        elsif ($gateway->isa('WebGUI::Shop::PayDriver::ITransact')) {
            ##Nothing to do.  This template was only changed, not added.
        }
        elsif ($gateway->isa('WebGUI::Shop::PayDriver::Ogone')) {
            $properties->{summaryTemplateId} = 'jysVZeUR0Bx2NfrKs5sulg';
        }
        elsif ($gateway->isa('WebGUI::Shop::PayDriver::PayPal::PayPalStd')) {
            $properties->{summaryTemplateId} = '300AozDaeveAjB_KN0ljlQ';
        }
        elsif ($gateway->isa('WebGUI::Shop::PayDriver::PayPal::ExpressCheckout')) {
            $properties->{summaryTemplateId} = 'GqnZPB0gLoZmqQzYFaq7bg';
        }
        else {
            die "Unknown payment driver type found.  Unable to automatically upgrade.\n";
        }
        $gateway->update($properties);
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
sub addIndexForInbox {
    my $session = shift;
    print "\tAdding index to inbox_messageState... " unless $quiet;
    my $sth = $session->db->read('show create table inbox_messageState');
    my ($field,$stmt) = $sth->array;
    $sth->finish;
    unless ($stmt =~ m/KEY `userId_deleted_isRead`/i) {
        $session->db->write("alter table inbox_messageState add index userId_deleted_isRead (userId,deleted,isRead)");
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add twitter auth and macro
sub addTwitterAuth {
    my $session = shift;
    print "\tAdding twitter auth method... " unless $quiet;

    $session->config->addToArray( 'authMethods', 'Twitter' );
    $session->config->addToHash( 'macros', "TwitterLogin" => "TwitterLogin" );
    $session->setting->set( 'twitterEnabled', 0 );
    $session->setting->set( 'twitterTemplateIdChooseUsername', 'mfHGkp6t9gdclmzN33OEnw' );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Move Template attachments to JSON collateral
sub migrateAttachmentsToJson {
    my $session = shift;
    print "\tMoving template attachments to JSON... " unless $quiet;
    # and here's our code
    $session->db->write(
        "ALTER TABLE template ADD attachmentsJson LONGTEXT"
    );

    my $attach;     # hashref (template) of hashrefs (revisionDate)
                    # of arrayrefs (attachments) of hashrefs (attachment)
    my $sth = $session->db->read( "SELECT * FROM template_attachments" );
    while ( my $row = $sth->hashRef ) {
        push @{ $attach->{ $row->{templateId} }{ $row->{revisionDate} } }, {
            url         => $row->{url},
            type        => $row->{type},
        };
    }

    for my $templateId ( keys %{ $attach } ) {
        for my $revisionDate ( keys %{ $attach->{$templateId} } ) {
            my $data    = $attach->{$templateId}{$revisionDate};
            my $asset   = WebGUI::Asset->newByDynamicClass( $session, $templateId, $revisionDate );
            $asset->update({ attachmentsJson => JSON->new->encode( $data ) });
        }
    }

    $session->db->write(
        "DROP TABLE template_attachments"
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub alterStoryArchiveTable { 
    my $session = shift;
    print "\tAdd story sort order column to the StoryAcrhive table... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `StoryArchive`');
    while (my ($col) = $sth->array) {  
        if ($col eq 'storySortOrder') {
            print "Skipped.\n" unless $quiet;
            return;
        }
    }

    $session->db->write("ALTER TABLE StoryArchive ADD COLUMN storySortOrder CHAR(22)");
    print "DONE!\n" unless $quiet;
}
 
#----------------------------------------------------------------------------
# Describe what our function does
sub alterStoryTopicTable {
    my $session = shift;
    print "\tAdd story sort order column to the StoryTopic table... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `StoryTopic`');
    while (my ($col) = $sth->array) {  
        if ($col eq 'storySortOrder') {
            print "Skipped.\n" unless $quiet;
            return;
        }
    }

    $session->db->write("ALTER TABLE StoryTopic ADD COLUMN storySortOrder CHAR(22)");
    $session->db->write("UPDATE StoryTopic SET storySortOrder = 'Chronologically' WHERE storySortOrder IS NULL");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addAssetReport {
    my $session = shift;
    print "\tAdding Asset Report Asset ... " unless $quiet;

    #Add the database table
    $session->db->write(q{
        CREATE TABLE `AssetReport` (
            `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
            `revisionDate` bigint(20) NOT NULL,
            `settings` mediumtext,
            `templateId` char(22) character set utf8 collate utf8_bin default NULL,
            `paginateAfter` bigint(20) default NULL,
            PRIMARY KEY  (`assetId`,`revisionDate`)
        )
    });

    #Add the asset to the config file
    $session->config->addToHash( "assets", "WebGUI::Asset::Wobject::AssetReport", { category => "utilities" } );
    
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
    print "\tUpdating packages.\n" unless ($quiet);
    addPackage( $session, 'packages-7.8.24-7.9.11/merged.wgpkg' );
}

#vim:ft=perl
