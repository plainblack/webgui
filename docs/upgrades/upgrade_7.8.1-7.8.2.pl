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
use WebGUI::Shop::Pay;
use WebGUI::Shop::PayDriver;

my $toVersion = '7.8.2';
my $quiet; # this line required


my $session = start(); # this line required

fixTableDefaultCharsets($session);
correctWikiAttachmentPermissions( $session );
transactionsNotifications( $session );
fixBadVarCharColumns ( $session );
addVendorPayouts($session);

finish($session); # this line required


#----------------------------------------------------------------------------
sub addVendorPayouts {
    my $session = shift;
    print "\tAdding vendor payouts... " unless $quiet;
    my $db = $session->db;
    $db->write(" create table if not exists vendorPayoutLog (
        payoutId        char(22) binary not null primary key,
            isSuccessful    tinyint(1) not null,
                errorCode       char(10),
                    errorMessage    char(255),
                        paypalTimestamp char(20) not null,
                            amount          decimal(7,2) not null,
                                currency        char(3) not null,
                                    correlationId   char(13) not null,
                                        paymentInformation  char(255) not null
                                        )");
    $db->write(" create table if not exists vendorPayoutLog_items (
        payoutId            char(22) binary not null,
            transactionItemId   char(22) binary not null,
                amount              decimal(7,2) not null,
                    primary key( payoutId, transactionItemId )
                    )");

    print "DONE!\n" unless $quiet;
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

#----------------------------------------------------------------------------
# Describe what our function does
sub correctWikiAttachmentPermissions {
    my $session = shift;
    print "\tCorrect group edit permission on wiki page attachments... " unless $quiet;
    my $root         = WebGUI::Asset->getRoot($session);
    my $pageIterator = $root->getLineageIterator(
        ['descendants'],
        {
            includeOnlyClasses => ['WebGUI::Asset::WikiPage'],
        }
    );
    PAGE: while (my $wikiPage = $pageIterator->()) {
        my $wiki = $wikiPage->getWiki;
        next PAGE unless $wiki && $wiki->get('allowAttachments') && $wikiPage->getChildCount;
        ATTACHMENT: foreach my $attachment (@{ $wikiPage->getLineage(['children'], { returnObjects => 1, })}) {
            next ATTACHMENT unless $attachment;
            $attachment->update({ groupIdEdit => $wiki->get('groupToEditPages') });
        }
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub transactionsNotifications {
    my $session = shift;
    print "\tMove Shop notifications from PayDriver to Transactions... " unless $quiet;
    my $pay = WebGUI::Shop::Pay->new($session);
    my $gateways = $pay->getPaymentGateways;
    my $defaultNotificationGroup = '3';
    my $defaultTemplate          = 'bPz1yk6Y9uwMDMBcmMsSCg';
    if (@{ $gateways }) {
        my $firstGateway = $gateways->[0];
        $defaultNotificationGroup ||= $firstGateway->get('saleNotificationGroupId');
        $defaultTemplate          ||= $firstGateway->get('receiptEmailTemplateId' );
        foreach my $gateway (@{ $gateways }) {
            my $properties = $gateway->get();
            delete $properties->{ saleNotificationGroupId };
            delete $properties->{ receiptEmailTemplateId  };
            $gateway->update($properties);
        }
    }
    $session->setting->add('shopSaleNotificationGroupId', $defaultNotificationGroup);
    $session->setting->add('shopReceiptEmailTemplateId',  $defaultTemplate);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub fixBadVarCharColumns {
    my $session = shift;
    print "\tGive all revisionDate columns the correct definition... " unless $quiet;
    my @dataSets = (
        [ 'AdSku',                  'assetId',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'purchaseTemplate',     "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'manageTemplate',       "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'adSpace',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'clickDiscounts',       "CHAR(22)  DEFAULT NULL"                            ],
        [ 'AdSku',                  'impressionDiscounts',  "CHAR(22)  DEFAULT NULL"                            ],
        [ 'Collaboration',          'replyRichEditor',      "CHAR(22)  BINARY DEFAULT 'PBrichedit000000000002'" ],
        [ 'Collaboration',          'replyFilterCode',      "CHAR(30)  BINARY DEFAULT 'javascript'"             ],
        [ 'DataForm',               'htmlAreaRichEditor',   "CHAR(22)  BINARY DEFAULT '**Use_Default_Editor**'" ],
        [ 'MapPoint',               'website',              "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'address1',             "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'address2',             "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'city',                 "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'state',                "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'zipCode',              "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'country',              "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'phone',                "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'fax',                  "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'email',                "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'Survey',                 'onSurveyEndWorkflowId',"CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'Survey_questionTypes',   'questionType',         "CHAR(56)  NOT NULL"                                ],
        [ 'bucketLog',              'userId',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'bucketLog',              'Bucket',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'deltaLog',               'userId',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'deltaLog',               'assetId',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'deltaLog',               'url',                  "CHAR(255) NOT NULL"                                ],
        [ 'passiveAnalyticsStatus', 'userId',               "CHAR(255) NOT NULL"                                ],
        [ 'passiveLog',             'url',                  "CHAR(255) NOT NULL"                                ],
        [ 'passiveLog',             'userId',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'passiveLog',             'assetId',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'passiveLog',             'sessionId',            "CHAR(22)  BINARY NOT NULL"                         ],
    );
    foreach my $dataSet (@dataSets) {
        $session->db->write(sprintf "ALTER TABLE `%s` MODIFY COLUMN `%s` %s", @{ $dataSet });
    }
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
