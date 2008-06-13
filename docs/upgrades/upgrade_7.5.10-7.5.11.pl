#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::DateTime;
use WebGUI::Asset::Sku::Product;
use WebGUI::Asset::Wobject::EventManagementSystem;
use WebGUI::Workflow;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Pluggable;
use File::Find;
use File::Spec;
use File::Path;
use JSON;

my $toVersion = '7.5.11';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
changeRealtimeWorkflows($session);
addReferralHandler( $session );
addCalendarEventWorkflow( $session );
addPurgeOldInboxActivity( $session );
addingInStoreCredit($session);
insertCommerceTaxTable($session);
migrateOldTaxTable($session);
insertCommerceShipDriverTable($session);
migrateToNewCart($session);
createSkuAsset($session);
createDonationAsset($session);
addShippingDrivers($session);
addShoppingHandler($session);
addAddressBook($session);
insertCommercePayDriverTable($session);
addPaymentDrivers($session);
convertTransactionLog($session);
upgradeEMS($session);
migrateOldProduct($session);
mergeProductsWithCommerce($session);
deleteOldProductTemplates($session);
addCaptchaToDataForm( $session );
addArchiveEnabledToCollaboration( $session );
addShelf( $session );
addCoupon( $session );
addVendors($session);
modifyThingyPossibleValues( $session );
removeLegacyTable($session);
addVersionStartEndDates($session);
migrateSubscriptions( $session );
updateUsersOfCommerceMacros($session);
addDBLinkAccessToSQLMacro($session);
addAssetManager( $session );
removeSqlForm($session);
migratePaymentPlugins( $session );
removeRecurringPaymentActivity( $session );
addLoginMessage( $session );
addNewApprovalActivities( $session );
addUserListWobject( $session );
addInheritUrlFromParent( $session );
addDefaultFilesPerPage( $session );
fixAdminConsoleTemplateTitles( $session );
makeLongerAssetMetadataValues( $session );
removeOldCommerceCode($session);
convertDataForm( $session );
ensureCorrectDefaults( $session );

finish($session); # this line required

#----------------------------------------------------------------------------
sub convertDataForm {
    my $session = shift;
    print "\tConverting DataForm configuration and data to JSON..." unless $quiet;
    $session->db->write(
        q{ ALTER TABLE `DataForm` ADD COLUMN storeData INT(1) DEFAULT 1 },
    );
    $session->db->write(
        q{ ALTER TABLE `DataForm` ADD COLUMN fieldConfiguration TEXT },
    );
    $session->db->write(
        q{ ALTER TABLE `DataForm` ADD COLUMN tabConfiguration TEXT },
    );
    $session->db->write(
        q{ ALTER TABLE `DataForm_entry` ADD COLUMN entryData TEXT },
    );
    my @dataforms = $session->db->buildArray("SELECT `assetId` FROM `asset` WHERE className='WebGUI::Asset::Wobject::DataForm'");
    for my $assetId (@dataforms) {
        my $dataForm = WebGUI::Asset->newPending($session, $assetId);
        my @tabConfigs;
        my $tabs = $session->db->read("SELECT * FROM DataForm_tab WHERE assetId=? ORDER BY sequenceNumber", [$assetId]);
        while (my $tabData = $tabs->hashRef) {
            my $newConfig = {
                label   => $tabData->{label},
                subtext => $tabData->{subtext},
                tabId   => $tabData->{DataForm_tabId},
            };
            push @tabConfigs, $newConfig;
        }
        $tabs->finish;
        my $tabJSON = encode_json( \@tabConfigs );

        my @fieldConfigs;
        my %fieldMapping;

        my $fields = $session->db->read("SELECT * FROM `DataForm_field` WHERE assetId=? ORDER BY sequenceNumber", [$assetId]);
        while (my $fieldData = $fields->hashRef) {
            my $newConfig = {
                name            => $fieldData->{name},
                status          => $fieldData->{status},
                type            => "\u$fieldData->{type}",
                options         => $fieldData->{possibleValues},
                defaultValue    => $fieldData->{defaultValue},
                width           => $fieldData->{width},
                subtext         => $fieldData->{subtext},
                rows            => $fieldData->{rows},
                isMailField     => $fieldData->{isMailField},
                label           => $fieldData->{label},
                tabId           => $fieldData->{DataForm_tabId} || undef,
                vertical        => $fieldData->{vertical},
                extras          => $fieldData->{extras},
            };
            $fieldMapping{ $fieldData->{DataForm_fieldId} } = $newConfig->{name};
            push @fieldConfigs, $newConfig;
        }
        $fields->finish;
        my $fieldJSON = encode_json( \@fieldConfigs );
        my $entries = $session->db->read("SELECT * FROM `DataForm_entry` WHERE assetId=?", [$assetId]);
        while (my $entryData = $entries->hashRef) {
            my $newEntryFieldData = {};
            my $entryFields = $session->db->read("SELECT * FROM `DataForm_entryData` WHERE assetId=? AND DataForm_entryId=?", [$assetId, $entryData->{DataForm_entryId}]);
            while (my $entryFieldData = $entryFields->hashRef) {
                $newEntryFieldData->{ $fieldMapping{ $entryFieldData->{DataForm_fieldId} } } = $entryData->{value};
            }
            $entryFields->finish;
            my $entryJSON = encode_json($newEntryFieldData);
            $session->db->write("UPDATE `DataForm_entry` SET entryData=? WHERE assetId=? AND DataForm_entryId=?", [$entryJSON, $assetId, $entryData->{DataForm_entryId}]);
        }
        $entries->finish;
        $dataForm->addRevision({fieldConfiguration => $fieldJSON, tabConfiguration => $tabJSON});
    }
    $session->db->write(
        q{ ALTER TABLE `DataForm_entry` ADD COLUMN newDate DATETIME },
    );
    $session->db->write(
        q{ UPDATE `DataForm_entry` SET newDate = FROM_UNIXTIME(submissionDate) },
    );
    $session->db->write(
        q{ ALTER TABLE `DataForm_entry` DROP COLUMN submissionDate },
    );
    $session->db->write(
        q{ ALTER TABLE `DataForm_entry` CHANGE COLUMN newDate submissionDate DATETIME },
    );
    $session->db->write(
        q{ DROP TABLE `DataForm_tab` },
    );
    $session->db->write(
        q{ DROP TABLE `DataForm_field` },
    );
    $session->db->write(
        q{ DROP TABLE `DataForm_entryData` },
    );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add default files per page to the Gallery
sub addDefaultFilesPerPage {
    my $session     = shift;
    print "\tAdding Default Files Per Page to Gallery... " unless $quiet;
    $session->db->write( 
        "ALTER TABLE Gallery ADD COLUMN defaultFilesPerPage INT"
    );
    $session->db->write(
        "UPDATE Gallery SET defaultFilesPerPage=24"
    );
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add two new approval activities
sub addNewApprovalActivities {
    my $session     = shift;
    print "\tAdding new approval activities... " unless $quiet;

    my $activities  = $session->config->get( "workflowActivities" );
    push @{ $activities->{ 'WebGUI::VersionTag' } }, 
        'WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByCommitterGroup',
        'WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByLineage',
        ;

    $session->config->set( "workflowActivities", $activities );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the necessary settings and profile fields for the new login message
sub addLoginMessage {
    my $session     = shift;
    print "\tAdding Login Message... " unless $quiet;

    # Add some settings
    my %settings    = ( 
        showMessageOnLogin      => '0',
        showMessageOnLoginTimes => '0',
        showMessageOnLoginBody  => '',
    );
    for my $setting ( keys %settings ) {
        $session->setting->add( $setting, $settings{ $setting } );
    }

    # Add a profile field
    WebGUI::ProfileField->create( $session, 
        'showMessageOnLoginSeen',
        {
            fieldType       => 'integer',
            dataDefault     => '0',
            visible         => '0',
            editable        => '0',
            protected       => '1',
            required        => '0',
            label           => 'WebGUI::International::get("showMessageOnLoginSeen","Auth");',
        },
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeSqlForm {
    my $session = shift;
    print "\tOptionally removing SQL Form...\n" unless $quiet;
    my $db = $session->db;
    unless ($db->quickScalar("select count(*) from asset where className='WebGUI::Asset::Wobject::SQLForm'")) {
        print "\t\tNot using it, so we're uninstalling it.\n" unless $quiet;
        $session->config->deleteFromArray("assets","WebGUI::Asset::Wobject::SQLForm");
        my @ids = $db->buildArray("select distinct assetId from template where namespace like 'SQLForm%'");
        push @ids, qw(GnrXtoFFeXia3vDQuSHojw k8vxD4fuKKf5cGwNTw0sLw);
        foreach my $id (@ids) {
            my $asset = WebGUI::Asset->newByDynamicClass($session, $id);
            if (defined $asset) {
                $asset->purge;
            }
        }
        foreach my $table (qw(SQLForm_fieldDefinitions SQLForm SQLForm_fieldTypes SQLForm_regexes)) {
            $db->write("drop table $table");
        }
        unlink ( $webguiRoot . '/lib/WebGUI/Asset/Wobject/SQLForm.pm' );
        unlink ( $webguiRoot . '/lib/WebGUI/Help/Asset_SQLForm.pm' );
        unlink ( $webguiRoot . '/lib/WebGUI/i18n/English/Asset_SQLForm.pm' );
        unlink ( $webguiRoot . '/t/Asset/Wobject/SQLForm.t' );
    } 
    else {
        print "\t\tThis site uses SQL Form, so we won't uninstall it.\n" unless $quiet;
    }
}
   
#----------------------------------------------------------------------------
sub changeRealtimeWorkflows {
    my $session = shift;
    print "\tMaking realtime workflows seamless... " unless $quiet;
    $session->db->write(q{update WorkflowInstance set workflowId='pbworkflow000000000003' where workflowId='realtimeworkflow-00001'});
    $session->db->write(q{update Workflow set mode='parallel' where mode='realtime'});
    if ($session->setting->get('defaultVersionTagWorkflow') eq 'realtimeworkflow-00001') {
        $session->setting->set("defaultVersionTagWorkflow","pbworkflow000000000003");
    }
    my $realtime = WebGUI::Workflow->new($session,'realtimeworkflow-00001');
    if (defined $realtime) {
        $realtime->delete;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the Asset Manager content handler to the list
# Must go before the Operation content handler (since we use ?op=assetManager)
sub addAssetManager {
    my $session     = shift;
    print "\tAdding new Asset Manager ..." unless $quiet;

    my $config = $session->config;
    my @handlers = ();
    foreach my $element (@{$config->get("contentHandlers")}) {
        if ($element eq "WebGUI::Content::Operation") {
            push @handlers, "WebGUI::Content::AssetManager";
        }
        push @handlers, $element;
    }
    $config->set("contentHandlers", \@handlers);

    print "DONE! \n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCoupon {
    my $session = shift;
    print "\tAdding Coupons... " unless $quiet;

    $session->db->write(q{
        create table FlatDiscount (
            assetId varchar(22) binary not null,
            revisionDate bigint,
            templateId varchar(22) binary not null default '63ix2-hU0FchXGIWkG3tow',
            mustSpend float not null default 0,
            percentageDiscount int(3) not null default 0,
            priceDiscount float not null default 0,
            primary key (assetId,revisionDate)
            )
        });
    $session->config->addToArray("assets","WebGUI::Asset::Sku::FlatDiscount");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addVendors {
    my $session = shift;
    print "\tAdding vendors... " unless $quiet;

    $session->db->write(q{
        create table vendor (
            vendorId varchar(22) binary not null primary key,
            dateCreated datetime,
            name varchar(255),
            userId varchar(22) binary not null default '3',
            preferredPaymentType varchar(255),
            paymentInformation text,
            paymentAddressId varchar(22) binary,
            index userId (userId)
        )
        });
    $session->db->write(q{
        insert into vendor (vendorId,name,dateCreated) values ('defaultvendor000000000','Default Vendor',now())
        });
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the archiveEnabled field to Collaboration assets
sub addArchiveEnabledToCollaboration {
    my $session = shift;
    print "\tAdding archiveEnabled to Collaboration... " unless $quiet;

    $session->db->write( 
        q{ ALTER TABLE Collaboration ADD COLUMN archiveEnabled INT(1) DEFAULT 1 }
    );

    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub addShelf {
    my $session = shift;
    print "\tAdding Shelves... " unless $quiet;

    $session->db->write(q{
        create table Shelf (
            assetId varchar(22) binary not null,
            revisionDate bigint,
            templateId varchar(22) binary not null default 'nFen0xjkZn8WkpM93C9ceQ',
            primary key (assetId,revisionDate)
            )
        });
    $session->config->addToArray("assetContainers","WebGUI::Asset::Wobject::Shelf");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the useCaptcha field to DataForm assets
sub addCaptchaToDataForm {
    my $session = shift;
    print "\tAdding CAPTCHA to DataForm... " unless $quiet;

    $session->db->write( 
        q{ ALTER TABLE DataForm ADD COLUMN useCaptcha INT(1) DEFAULT 0 }
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addReferralHandler {
    my $session = shift;
    print "\tAdding a referral handler." unless $quiet;
    my $config = $session->config;
    my @handlers = ();
    foreach my $element (@{$config->get("contentHandlers")}) {
        if ($element eq "WebGUI::Content::Operation") {
            push @handlers, "WebGUI::Content::Referral";
        }
        push @handlers, $element;
    }
    $config->set("contentHandlers", \@handlers);
    print "DONE!\n" unless $quiet;
}

    
#----------------------------------------------------------------------------
# Add the database column to select the workflow to approve Calendar Events
sub addCalendarEventWorkflow {
    my $session = shift;
    print "\tAdding Calendar Event Workflow field..." unless $quiet;
    
    $session->db->write(
        qq{ ALTER TABLE Calendar ADD COLUMN workflowIdCommit VARCHAR(22) BINARY },
    );

    # Add a nice default value
    $session->db->write(
        qq{ UPDATE Calendar SET workflowIdCommit = ? },
        [ $session->setting->get('defaultVersionTagWorkflow') ],
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the new PurgeOldInboxMessages activity to the config file
sub addPurgeOldInboxActivity {
    my $session = shift;
    print "\tAdding Purge Old Inbox Messages workflow activity... " unless $quiet;

    my $activity    = $session->config->get( "workflowActivities" );
    push @{ $activity->{"None"} }, 'WebGUI::Workflow::Activity::PurgeOldInboxMessages';
    $session->config->set( "workflowActivities", $activity );

    print "DONE!\n" unless $quiet;
}

#-------------------------------------------------
sub addingInStoreCredit {
	my $session = shift;
	print "\tAdding refunds and in-store credit.\n" unless ($quiet);
	$session->db->write("create table shopCredit (
		creditId varchar(22) binary not null primary key,
		userId varchar(22) binary not null,
		amount float not null default 0.00,
		comment text,
		dateOfAdjustment datetime,
		index userId (userId)
		)");
}

#-------------------------------------------------
sub upgradeEMS {
	my $session = shift;
	print "\tUpgrading Event Manager\n" unless ($quiet);
	my $db = $session->db;
	print "\t\tDeleting unused files in the extras directory.\n" unless ($quiet);
    rmtree ( $webguiRoot . '/www/extras/wobject/EventManagementSystem' );

	print "\t\tGetting rid of old templates.\n" unless ($quiet);
	foreach my $namespace (qw(EventManagementSystem EventManagementSystem_checkout EventManagementSystem_managePurchas EventManagementSystem_product EventManagementSystem_viewPurchase EventManagementSystem_search emsbadgeprint emsticketprint)) {
		my $templates = $db->read("select assetId from template where namespace=?",[$namespace]);
		while (my ($id) = $templates->array) {
			my $asset = WebGUI::Asset->new($session, $id,'WebGUI::Asset::Template');
			if (defined $asset) {
					$asset->purge;
			}
		}
	}
	print "\t\tAltering table structures.\n" unless ($quiet);
	$db->write("alter table EventManagementSystem drop column globalMetadata");
	$db->write("alter table EventManagementSystem drop column globalPrerequisites");
	$db->write("alter table EventManagementSystem drop column displayTemplateId");
	$db->write("alter table EventManagementSystem drop column checkoutTemplateId");
	$db->write("alter table EventManagementSystem drop column managePurchasesTemplateId");
	$db->write("alter table EventManagementSystem drop column viewPurchaseTemplateId");
	$db->write("alter table EventManagementSystem drop column searchTemplateId");
	$db->write("alter table EventManagementSystem drop column paginateAfter");
	$db->write("alter table EventManagementSystem drop column groupToAddEvents");
	$db->write("alter table EventManagementSystem drop column badgePrinterTemplateId");
	$db->write("alter table EventManagementSystem drop column ticketPrinterTemplateId");
	$db->write("alter table EventManagementSystem add column timezone varchar(30) not null default 'America/Chicago'");
	$db->write("alter table EventManagementSystem add column templateId varchar(22) binary not null default '2rC4ErZ3c77OJzJm7O5s3w'");
	$db->write("alter table EventManagementSystem add column badgeBuilderTemplateId varchar(22) binary not null default 'BMybD3cEnmXVk2wQ_qEsRQ'");
	$db->write("alter table EventManagementSystem add column lookupRegistrantTemplateId varchar(22) binary not null default 'OOyMH33plAy6oCj_QWrxtg'");
	$db->write("alter table EventManagementSystem add column printBadgeTemplateId varchar(22) binary not null default 'PsFn7dJt4wMwBa8hiE3hOA'");
	$db->write("alter table EventManagementSystem add column printTicketTemplateId varchar(22) binary not null default 'yBwydfooiLvhEFawJb0VTQ'");
	$db->write("alter table EventManagementSystem add column badgeInstructions mediumtext");
	$db->write("alter table EventManagementSystem add column ribbonInstructions mediumtext");
	$db->write("alter table EventManagementSystem add column ticketInstructions mediumtext");
	$db->write("alter table EventManagementSystem add column tokenInstructions mediumtext");
	$db->write("alter table EventManagementSystem add column registrationStaffGroupId varchar(22) binary not null");
	$db->write("alter table EventManagementSystem_metaField rename EMSEventMetaField");
	$db->write("alter table EMSEventMetaField drop column autoSearch");
	$db->write("alter table EMSEventMetaField drop column name");

	print "\t\tCreating new tables.\n" unless ($quiet);
	$db->write("create table EMSRegistrant (
		badgeId varchar(22) binary not null primary key,
		userId varchar(22) binary,
		badgeNumber int not null auto_increment unique,
		badgeAssetId varchar(22) binary not null,
		emsAssetId varchar(22) binary not null,
		name varchar(35) binary not null,
		address1 varchar(35),
		address2 varchar(35),
		address3 varchar(35),
		city varchar(35),
		state varchar(35),
		zipcode varchar(35),
		country varchar(35),
		phoneNumber varchar(35),
		organization varchar(35),
		email varchar(255),
		notes mediumtext,
		purchaseComplete boolean,
		hasCheckedIn boolean,
		transactionItemId varchar(22) binary,
		index badgeAssetId_purchaseComplete (badgeAssetId,purchaseComplete)
		)");
	$db->write("create table EMSRegistrantTicket (
		badgeId varchar(22) binary not null,
		ticketAssetId varchar(22) binary not null,
		purchaseComplete boolean,
		transactionItemId varchar(22) binary,
		primary key (badgeId, ticketAssetId),
		index ticketAssetId_purchaseComplete (ticketAssetId,purchaseComplete)
		)");
	$db->write("create table EMSRegistrantToken (
		badgeId varchar(22) binary not null,
		tokenAssetId varchar(22) binary not null,
		quantity int,
		transactionItemIds text binary,
		primary key (badgeId,tokenAssetId)
		)");
	$db->write("create table EMSRegistrantRibbon (
		badgeId varchar(22) binary not null,
		ribbonAssetId varchar(22) binary not null,
		transactionItemId varchar(22) binary,
		primary key (badgeId,ribbonAssetId)
		)");
	$db->write("create table EMSBadgeGroup (
		badgeGroupId varchar(22) binary not null primary key,
		emsAssetId varchar(22) binary not null,
		name varchar(100)
		)");
	$db->write("create table EMSBadge (
		assetId varchar(22) binary not null,
		revisionDate bigint not null,
		price float not null default 0.00,
		seatsAvailable int not null default 100,
		relatedBadgeGroups mediumtext,
		primary key (assetId, revisionDate)
		)");
	$db->write("create table EMSTicket (
		assetId varchar(22) binary not null,
		revisionDate bigint not null,
		price float not null default 0.00,
		seatsAvailable int not null default 100,
		startDate datetime,
		duration float not null default 1.0,
		eventNumber int,
		location varchar(100),
		relatedBadgeGroups mediumtext,
		relatedRibbons mediumtext,
		eventMetaData mediumtext,
		primary key (assetId, revisionDate)
		)");
	$db->write("create table EMSToken (
		assetId varchar(22) binary not null,
		revisionDate bigint not null,
		price float not null default 0.00,
		primary key (assetId, revisionDate)
		)");
	$db->write("create table EMSRibbon (
		assetId varchar(22) binary not null,
		revisionDate bigint not null,
		percentageDiscount float not null default 10.0,
		price float not null default 0.00,
		primary key (assetId, revisionDate)
		)");
    
    print "\t\tMigrating workflow activities.\n" unless ($quiet);
	$session->config->addToArray("workflowActivities/None","WebGUI::Workflow::Activity::ExpireEmsCartItems");
    $db->write("delete from WorkflowActivity where workflowId=?",['EMSworkflow00000000001']); # file no longer exists so must get rid of this entry manually
    my $workflow = WebGUI::Workflow->new($session, 'EMSworkflow00000000001');
    if (defined $workflow) {
        $workflow->delete;
    }
	unlink($session->config->getWebguiRoot.'/lib/WebGUI/Workflow/Activity/CacheEMSPrereqs.pm');
    
    print "\t\tMigrating old EMS data.\n" unless ($quiet);
    my (%oldRibbons, %newRibbons, %oldBadges, %newBadges, %oldTickets, %newTickets) = ();
    my $emsResults = $db->read("select assetId from asset where className='WebGUI::Asset::Wobject::EventManagementSystem'");
    while (my ($emsId) = $emsResults->array) {
        my $ems = WebGUI::Asset::Wobject::EventManagementSystem->new($session, $emsId);
    	print "\t\t\tMigrating old ribbons for $emsId.\n" unless ($quiet);
        my $ribbonResults = $db->read("select * from EventManagementSystem_discountPasses left join EventManagementSystem_products using (passId) left join products using (productId) where assetId=?",[$emsId]);
        while (my $ribbonData = $ribbonResults->hashRef) {
            my $ribbon = $ems->addChild({
                className           => 'WebGUI::Asset::Sku::EMSRibbon',
                title               => $ribbonData->{title},
                url                 => $ribbonData->{title},
                description         => $ribbonData->{description},
                sku                 => $ribbonData->{sku},
                price               => $ribbonData->{price},
                seatsAvailable      => $ribbonData->{maximumAttendees},
                });
            $oldRibbons{$ribbonData->{passId}} = $ribbon->getId;
            $newRibbons{$ribbon->getId} = $ribbonData->{passId};
        }
    	print "\t\t\tMigrating old badges for $emsId.\n" unless ($quiet);
        my $badgeResults = $db->read("select * from EventManagementSystem_products left join products using (productId) where assetId=? and prerequisiteId=''",[$emsId]);
        while (my $badgeData = $badgeResults->hashRef) {
            my $badge = $ems->addChild({
                className           => 'WebGUI::Asset::Sku::EMSBadge',
                title               => $badgeData->{title},
                url                 => $badgeData->{title},
                description         => $badgeData->{description},
                sku                 => $badgeData->{sku},
                price               => $badgeData->{price},
                seatsAvailable      => $badgeData->{maximumAttendees},
                });
            $oldBadges{$badgeData->{productId}} = $badge->getId;
            $newBadges{$badge->getId} = $badgeData->{productId};
        }
    	print "\t\t\tMigrating old tickets for $emsId.\n" unless ($quiet);
        my %metaFields = $db->buildHash("select fieldId,label from EMSEventMetaField where assetId=? order by sequenceNumber",[$emsId]);
        my $ticketResults = $db->read("select * from EventManagementSystem_products left join products using (productId) where assetId=? and prerequisiteId<>''",[$emsId]);
        while (my $ticketData = $ticketResults->hashRef) {
            my %oldMetaData = $db->buildHash("select fieldId,fieldData from EventManagementSystem_metaData where productId=?",[$ticketData->{productId}]);
            my %metaData = ();
            foreach my $fieldId (keys %oldMetaData) {
                $metaData{$metaFields{$fieldId}} = $oldMetaData{$fieldId};
            }
            my $start =  WebGUI::DateTime->new($session, $ticketData->{startDate});
            my $end =  WebGUI::DateTime->new($session, $ticketData->{endDate});
            my $duration = $end - $start;
            my $ticket = $ems->addChild({
                className           => 'WebGUI::Asset::Sku::EMSBadge',
                title               => $ticketData->{title},
                url                 => $ticketData->{title},
                description         => $ticketData->{description},
                sku                 => $ticketData->{sku},
                price               => $ticketData->{price},
                seatsAvailable      => $ticketData->{maximumAttendees},
                startDate           => $start->toDatabase,
                duration            => $duration->in_units('seconds'),
                eventNumber         => $ticketData->{sku},
                eventMetaData       => \%metaData,
                });
            $oldTickets{$ticketData->{productId}} = $ticket->getId;
            $newTickets{$ticket->getId} = $ticketData->{productId};
        }
    	print "\t\t\tMigrating old registrant tickets and registrant ribbons for $emsId.\n" unless ($quiet);
        my %oldBadgeRegistrants = ();
        my $regticResults = $db->read("select * from EventManagementSystem_registrations left join EventManagementSystem_products using (productId) where EventManagementSystem_registrations.assetId=?",[$emsId]);
        while (my $registrantData = $regticResults->hashRef) {
            my $id = $oldTickets{$registrantData->{productId}};
            if ( $registrantData->{prerequisiteId} eq "") {
                $oldBadgeRegistrants{$registrantData->{badgeId}} = $registrantData->{productId};
            }
            elsif ($id ne "") {
                $db->write("replace into EMSRegistrantTicket (badgeId,ticketAssetId,purchaseComplete) values (?,?,1)",
                    [$registrantData->{badgeId}, $id]);
            }
            else {
                my $id = $oldRibbons{$registrantData->{productId}};
                if ($id ne "") {
                    $db->write("replace into EMSRegistrantRibbon (badgeId,ribbonAssetId) values (?,?)",
                        [$registrantData->{badgeId}, $id]);
                }
            }
        }
    	print "\t\t\tMigrating old registrants for $emsId.\n" unless ($quiet);
        my $registrantResults = $db->read("select * from EventManagementSystem_badges where assetId=?",[$emsId]);
        while (my $registrantData = $registrantResults->hashRef) {
            $db->setRow("EMSRegistrant","badgeId",{
                badgeId             => "new",
                userId              => $registrantData->{userId},
                badgeAssetId        => $oldBadges{$oldBadgeRegistrants{$registrantData->{badgeId}}},
                emsAssetId          => $emsId,
                name                => $registrantData->{firstName}.' '.$registrantData->{lastName},
                address1            => $registrantData->{address},
                city                => $registrantData->{city},
                state               => $registrantData->{state},
                zipcode             => $registrantData->{zipCode},
                country             => $registrantData->{country},
                phoneNumber         => $registrantData->{phone},
                email               => $registrantData->{email},
                purchaseComplete    => 1,
                },$registrantData->{badgeId});
        }
    }
    $db->write("drop table EventManagementSystem_badges");
    $db->write("drop table EventManagementSystem_discountPasses");
    $db->write("drop table EventManagementSystem_metaData");
    $db->write("drop table EventManagementSystem_prerequisiteEvents");
    $db->write("drop table EventManagementSystem_prerequisites");
    $db->write("drop table EventManagementSystem_products");
    $db->write("drop table EventManagementSystem_purchases");
    $db->write("drop table EventManagementSystem_registrations");
    $db->write("drop table EventManagementSystem_sessionPurchaseRef");
}

#-------------------------------------------------
sub convertTransactionLog {
	my $session = shift;
	print "\tInstalling transaction log.\n" unless ($quiet);
    my $db = $session->db;
	$db->write("alter table transaction rename oldtransaction");
	$db->write("alter table transactionItem rename oldtransactionitem");
    $db->write("create table transaction (
        transactionId varchar(22) binary not null primary key,
        originatingTransactionId varchar(22) binary,
        isSuccessful bool not null default 0,
		orderNumber int not null auto_increment unique,
		transactionCode varchar(100),
		statusCode varchar(35),
		statusMessage varchar(255),
		userId varchar(22) binary not null,
		username varchar(35) not null,
		amount float,
        shopCreditDeduction float,
		shippingAddressId varchar(22) binary,
        shippingAddressName varchar(35),
        shippingAddress1 varchar(35),
        shippingAddress2 varchar(35),
        shippingAddress3 varchar(35),
        shippingCity varchar(35),
        shippingState varchar(35),
        shippingCountry varchar(35),
        shippingCode varchar(35),
        shippingPhoneNumber varchar(35),
		shippingDriverId varchar(22) binary,
		shippingDriverLabel varchar(35),
		shippingPrice float,
		paymentAddressId varchar(22) binary,
        paymentAddressName varchar(35),
        paymentAddress1 varchar(35),
        paymentAddress2 varchar(35),
        paymentAddress3 varchar(35),
        paymentCity varchar(35),
        paymentState varchar(35),
        paymentCountry varchar(35),
        paymentCode varchar(35),
        paymentPhoneNumber varchar(35),
		paymentDriverId varchar(22) binary,
		paymentDriverLabel varchar(35),
		taxes float,
		dateOfPurchase datetime,
        isRecurring boolean,
        notes mediumtext
    )");
	$db->write("create table transactionItem (
		itemId varchar(22) binary not null primary key,
		transactionId varchar(22) binary not null,
		assetId varchar(22),
		configuredTitle varchar(255),
		options mediumText,
		shippingAddressId varchar(22) binary,
        shippingName varchar(35),
        shippingAddress1 varchar(35),
        shippingAddress2 varchar(35),
        shippingAddress3 varchar(35),
        shippingCity varchar(35),
        shippingState varchar(35),
        shippingCountry varchar(35),
        shippingCode varchar(35),
        shippingPhoneNumber varchar(35),
		shippingTrackingNumber varchar(255),
		orderStatus varchar(35) not null default 'NotShipped',
		lastUpdated datetime,
		quantity int not null default 1,
		price float,
        vendorId varchar(22) binary not null default 'defaultvendor000000000',
		index transactionId (transactionId),
        index vendorId (vendorId)
	)");
    $session->setting->add('shopMyPurchasesTemplateId','2gtFt7c0qAFNU3BG_uvNvg');
    $session->setting->add('shopMyPurchasesDetailTemplateId','g8W53Pd71uHB9pxaXhWf_A');
    my $transactionResults = $db->read("select * from oldtransaction order by initDate");
    while (my $oldTranny = $transactionResults->hashRef) {
        my $date = WebGUI::DateTime->new($session, $oldTranny->{initDate});
        my $u = WebGUI::User->new($session, $oldTranny->{userId});
        $db->setRow("transaction","transactionId",{
            transactionId       => "new",
            isSuccessful        => (($oldTranny->{status} eq "Completed") ? 1 : 0),
            transactionCode     => $oldTranny->{XID},
            statusCode          => $oldTranny->{authcode},
            statusMessage       => $oldTranny->{message},
            userId              => $oldTranny->{userId},
            username            => WebGUI::User->new($session, $oldTranny->{userId})->username,
            amount              => $oldTranny->{amount},
            shippingPrice       => $oldTranny->{shippingCost},
            shippingAddress1    => $u->profileField('homeAddress'),
            shippingCity        => $u->profileField('homeCity'),
            shippingState       => $u->profileField('homeState'),
            shippingCode        => $u->profileField('homeZip'),
            shippingCountry     => $u->profileField('homeCountry'),
            shippingAddressName => $u->profileField('firstName').' '.$u->profileField('lastName'),
            shippingPhoneNumber => $u->profileField('homePhone'),
            paymentAddress1     => $u->profileField('homeAddress'),
            paymentCity         => $u->profileField('homeCity'),
            paymentState        => $u->profileField('homeState'),
            paymentCode         => $u->profileField('homeZip'),
            paymentCountry      => $u->profileField('homeCountry'),
            paymentAddressName  => $u->profileField('firstName').' '.$u->profileField('lastName'),
            paymentPhoneNumber  => $u->profileField('homePhone'),
            dateOfPurchase      => $date->toDatabase,
            isRecurring         => $oldTranny->{recurring},
            }, $oldTranny->{transactionId});
            my $itemResults = $db->read("select * from oldtransactionitem where transactionId=?",[$oldTranny->{transactionId}]);
            while (my $oldItem = $itemResults->hashRef) {
                my $status = $oldItem->{shippingStatus};
                $status = 'NotShipped' if $status eq 'NotSent';
                $db->setRow("transactionItem","itemId",{
                    itemId                  => "new",
                    transactionId           => $oldItem->{transactionId},
                    configuredTitle         => $oldItem->{itemName},
                    options                 => '{}',
                    shippingTrackingNumber  => $oldTranny->{trackingNumber},
                    orderStatus             => $oldTranny->{shippingStatus},
                    lastUpdated             => $date->toDatabase,
                    quantity                => $oldItem->{quantity},
                    price                   => $oldItem->{amount},
                    vendorId                => "defaultvendor000000000",
                    }, $oldItem->{itemId});
            }
    }
    $db->write("drop table oldtransaction");
    $db->write("drop table oldtransactionitem");
}

#-------------------------------------------------
sub addAddressBook {
	my $session = shift;
	print "\tInstalling address book.\n" unless ($quiet);
    $session->db->write("create table addressBook (
        addressBookId varchar(22) binary not null primary key,
        sessionId varchar(22) binary,
        userId varchar(22) binary,
        index userId (sessionId),
        index sessionId (sessionId)
    )");
    $session->db->write("create table address (
        addressId varchar(22) binary not null primary key,
        addressBookId varchar(22) binary not null,
        label varchar(35),
        name varchar(35),
        address1 varchar(35),
        address2 varchar(35),
        address3 varchar(35),
        city varchar(35),
        state varchar(35),
        country varchar(35),
        code varchar(35),
        phoneNumber varchar(35),
        index addressBookId_addressId (addressBookId,addressId)
    )");
    $session->setting->add('shopAddressBookTemplateId','3womoo7Teyy2YKFa25-MZg');
    $session->setting->add('shopAddressTemplateId','XNd7a_g_cTvJVYrVHcx2Mw');
}

#-------------------------------------------------
sub addShoppingHandler {
	my $session = shift;
	print "\tInstalling shopping handler.\n" unless ($quiet);
    my @changed = ();
    foreach my $handler (@{$session->config->get("contentHandlers")}) {
        if ($handler eq "WebGUI::Content::Asset") {
            push(@changed, "WebGUI::Content::Shop");
        }
        push(@changed, $handler);   
    }
    $session->config->set("contentHandlers", \@changed);
}

#-------------------------------------------------
sub createDonationAsset {
	my $session = shift;
	print "\tInstall Donation asset.\n" unless ($quiet);
    $session->db->write("create table donation (
        assetId varchar(22) binary not null,
        revisionDate bigint not null,
        defaultPrice float not null default 100.00,
        thankYouMessage mediumtext,
        templateId varchar(22) binary not null,
        primary key (assetId, revisionDate)
    )"); 
    $session->config->addToArray("assets","WebGUI::Asset::Sku::Donation");
}

#-------------------------------------------------
sub createSkuAsset {
	my $session = shift;
	print "\tInstall SKU asset.\n" unless ($quiet);
    $session->db->write("create table sku (
        assetId varchar(22) binary not null,
        revisionDate bigint not null,
        description mediumtext,
        sku varchar(35) binary not null,
        vendorId varchar(22) binary not null default 'defaultvendor000000000',
        displayTitle bool not null default 1,
        overrideTaxRate bool not null default 0,
        taxRateOverride float not null default 0.00,
        primary key (assetId, revisionDate),
        index sku (sku),
        index vendorId (vendorId)
    )"); 
}

#-------------------------------------------------
sub migrateToNewCart {
	my $session = shift;
	print "\tInstall new shopping cart.\n" unless ($quiet);
    $session->db->write("create table cart (
        cartId varchar(22) binary not null primary key,
        sessionId varchar(22) binary not null,
        shippingAddressId varchar(22) binary,
        shipperId varchar(22) binary,
        couponId varchar(22) binary,
        index sessionId (sessionId)
    )");
    $session->db->write("create table cartItem (
        itemId varchar(22) binary not null primary key,
        cartId varchar(22) binary not null,
        assetId varchar(22) binary not null,
		dateAdded datetime not null,
        options mediumtext,
        configuredTitle varchar(255),
        shippingAddressId varchar(22) binary,
        quantity integer not null default 1,
        index cartId_assetId_dateAdded (cartId,assetId,dateAdded)
    )");
    $session->db->write("drop table shoppingCart");
    $session->setting->add('shopCartTemplateId','aIpCmr9Hi__vgdZnDTz1jw');
	$session->config->addToHash("macros","ViewCart","ViewCart");
	$session->config->addToHash("macros","CartItemCount","CartItemCount");
	$session->config->addToHash("macros","MiniCart","MiniCart");
}

#-------------------------------------------------
sub insertCommerceTaxTable {
	my $session = shift;
	print "\tInstall the Commerce Tax Table.\n" unless ($quiet);
	# and here's our code
    $session->db->write(<<EOSQL);

CREATE TABLE tax (
    taxId    VARCHAR(22)  binary NOT NULL,
    country  VARCHAR(100) NOT NULL,
    state    VARCHAR(100),
    city     VARCHAR(100),
    code     VARCHAR(100),
    taxRate  FLOAT        NOT NULL DEFAULT 0.0,
    PRIMARY KEY (taxId)
)
EOSQL

}

#-------------------------------------------------
sub migrateOldTaxTable {
	my $session = shift;
	print "\tMigrate old tax data into the new tax table.\n" unless ($quiet);
	# and here's our code
    my $oldTax = $session->db->prepare('select * from commerceSalesTax');
    my $newTax = $session->db->prepare('insert into tax (taxId, country, state, city, code, taxRate) VALUES (?,?,?,?,?,?)');
    $oldTax->execute();
    while (my $oldTaxData = $oldTax->hashRef()) {
        $newTax->execute([$oldTaxData->{commerceSalesTaxId}, 'USA', $oldTaxData->{regionIdentifier}, '', '', $oldTaxData->{salesTax}]);
    }
    $oldTax->finish;
    $newTax->finish;
    $session->db->write('drop table commerceSalesTax');
}

#-------------------------------------------------
sub insertCommerceShipDriverTable {
	my $session = shift;
	print "\tInstall the Commerce ShipperDriver Table.\n" unless ($quiet);
	# and here's our code
    $session->db->write(<<EOSQL);

CREATE TABLE shipper (
    shipperId  VARCHAR(22)  binary NOT NULL,
    className  VARCHAR(255),
    options    mediumtext,
    PRIMARY KEY (shipperId)
)
EOSQL

}

#-------------------------------------------------
sub addPaymentDrivers {
	my $session = shift;
	print "\tSet up the default payment drivers.\n" unless ($quiet);
	# and here's our code
    $session->config->delete('paymentPlugins');
    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::Cash');
    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::ITransact');

}

#-------------------------------------------------
sub addShippingDrivers {
	my $session = shift;
	print "\tSet up the default shipping.\n" unless ($quiet);
	# and here's our code
    $session->config->delete('shippingPlugins');
    $session->config->addToArray('shippingDrivers', 'WebGUI::Shop::ShipDriver::FlatRate');
	$session->db->write("insert into shipper (shipperId, className,options) values ('defaultfreeshipping000','WebGUI::Shop::ShipDriver::FlatRate',?)",[q|{"label":"Free Shipping","enabled":1}|]);
}

#-------------------------------------------------
sub migrateOldProduct {
    my $session = shift;
    print "\tMigrate old Product to new SKU based Products.\n" unless ($quiet);
    # and here's our code
    ##Grab data from Wobject table, and move it into Sku and Product, as appropriate.
    ##Have to change the className's in the db, too
    ## Wobject description   -> Sku description
    ## Wobject displayTitle  -> Sku displayTitle
    ## Product productNumber -> Sku sku
    ## asset className WebGUI::Asset::Wobject::Product -> WebGUI::Asset::Sku::Product
    my $fromWobject   = $session->db->read('select w.assetId, w.revisionDate, w.description, w.displayTitle, p.productNumber from Product as p JOIN wobject as w on p.assetId=w.assetId and p.revisionDate=w.revisionDate');
    my $toSku         = $session->db->prepare('insert into sku (assetId, revisionDate, sku, description, displayTitle) VALUES (?,?,?,?,?)');
    my $rmWobject     = $session->db->prepare('delete from wobject where assetId=? and revisionDate=?');
    while (my $product = $fromWobject->hashRef()) {
        $toSku->execute([
            $product->{assetId},
            $product->{revisionDate},
            ($product->{productNumber} || $session->id->generate),
            $product->{description},
            $product->{displayTitle},
        ]);
        $rmWobject->execute([$product->{assetId}, $product->{revisionDate}]);
    }
    $fromWobject->finish;
    $toSku->finish;
    $rmWobject->finish;
    $session->db->write(q!update asset set className='WebGUI::Asset::Sku::Product' where className='WebGUI::Asset::Wobject::Product'!);

    ## Add variants collateral column to Sku/Product
    $session->db->write('alter table Product add column   thankYouMessage mediumtext');
    $session->db->write('alter table Product add column     accessoryJSON mediumtext');
    $session->db->write('alter table Product add column       benefitJSON mediumtext');
    $session->db->write('alter table Product add column       featureJSON mediumtext');
    $session->db->write('alter table Product add column       relatedJSON mediumtext');
    $session->db->write('alter table Product add column specificationJSON mediumtext');
    $session->db->write('alter table Product add column      variantsJSON mediumtext');
    ##Build a variant for each Product.
    my $productQuery = $session->db->read(<<EOSQL1);
SELECT p.assetId, p.price, p.productNumber, p.revisionDate, a.title, s.sku
    FROM Product   AS p
    JOIN assetData AS a
        on p.assetId=a.assetId and p.revisionDate=a.revisionDate
    JOIN sku       AS s
        on p.assetId=s.assetId and p.revisionDate=s.revisionDate
    WHERE p.revisionDate=(SELECT MAX(revisionDate) FROM Product where Product.assetId=a.assetId)
EOSQL1
    while (my $productData = $productQuery->hashRef()) {
        ##Truncate title to 30 chars for short desc
        #printf "\t\tAdding variant to %s\n", $productData->{title} unless $quiet;
        my $product = WebGUI::Asset::Sku::Product->new($session, $productData->{assetId}, 'WebGUI::Asset::Sku::Product', $productData->{revisionDate});
        $product->setCollateral('variantsJSON', 'variantId', 'new', {
            varSku    => ($productData->{productNumber} || $session->id->generate),
            shortdesc => substr($productData->{title}, 0, 30),
            price     => $productData->{price},
            weight    => 0,
            quantity  => 0,
        });
        my $json = $product->get('variantsJSON');
        #printf "\t\t\t$json\n";
        $session->db->write('update Product set variantsJSON=? where assetId=?',[$json, $product->getId]);
    }
    $productQuery->finish;

    ##Get all Product assetIds
    my $assetSth = $session->db->read('select distinct(assetId) from Product');
    my $accessorySth     = $session->db->read('select accessoryAssetId from Product_accessory where assetId=? order by sequenceNumber');
    my $relatedSth       = $session->db->read('select relatedAssetId from Product_related where assetId=? order by sequenceNumber');
    my $specificationSth = $session->db->read('select Product_specificationId as specificationId, name, value, units from Product_specification where assetId=? order by sequenceNumber');
    my $featureSth       = $session->db->read('select Product_featureId as featureId, feature from Product_feature where assetId=? order by sequenceNumber');
    my $benefitSth       = $session->db->read('select Product_benefitId as benefitId, benefit from Product_benefit where assetId=? order by sequenceNumber');
    while (my ($assetId) = $assetSth->array) {
        ##For each assetId, get each type of collateral
        ##Convert the data to JSON and store it in Product with setCollateral (update)
        ##To duplicate across all revisions, do a get and SQL update (with no revisionDate)

        ##Accessories
        $accessorySth->execute([$assetId]);
        my @accessories = ();
        while (my $acc = $accessorySth->hashRef()) {
            push @accessories, $acc;
        }
        my $accJson = to_json(\@accessories);
        $session->db->write('update Product set accessoryJSON=? where assetId=?',[$accJson, $assetId]);

        ##Related
        $relatedSth->execute([$assetId]);
        my @related = ();
        while (my $acc = $relatedSth->hashRef()) {
            push @related, $acc;
        }
        my $relJson = to_json(\@related);
        $session->db->write('update Product set relatedJSON=? where assetId=?',[$relJson, $assetId]);

        ##Specification
        $specificationSth->execute([$assetId]);
        my @specification = ();
        while (my $spec = $specificationSth->hashRef()) {
            push @specification, $spec;
        }
        my $specJson = to_json(\@specification);
        $session->db->write('update Product set specificationJSON=? where assetId=?',[$specJson, $assetId]);

        ##Feature
        $featureSth->execute([$assetId]);
        my @features = ();
        while (my $feature = $featureSth->hashRef()) {
            push @features, $feature;
        }
        my $featJson = to_json(\@features);
        $session->db->write('update Product set featureJSON=? where assetId=?',[$featJson, $assetId]);

        ##Benefit
        $benefitSth->execute([$assetId]);
        my @benefits = ();
        while (my $benefit = $benefitSth->hashRef()) {
            push @benefits, $benefit;
        }
        my $beneJson = to_json(\@benefits);
        $session->db->write('update Product set benefitJSON=? where assetId=?',[$beneJson, $assetId]);

    }
    $assetSth->finish;

    ##Drop collateral tables
    $session->db->write('drop table Product_accessory');
    $session->db->write('drop table Product_benefit');
    $session->db->write('drop table Product_feature');
    $session->db->write('drop table Product_related');
    $session->db->write('drop table Product_specification');

    ## Remove productNumber from Product;
    $session->db->write('alter table Product drop column productNumber');
    ## Remove price from Product since prices are now stored in variants
    $session->db->write('alter table Product drop column price');

    ## Update config file, deleting Wobject::Product and adding Sku::Product
    $session->config->deleteFromArray('assets', 'WebGUI::Asset::Wobject::Product');
    $session->config->addToArray('assets', 'WebGUI::Asset::Sku::Product');

    return;
}

#-------------------------------------------------
sub mergeProductsWithCommerce {
	my $session = shift;
	print "\tMerge old Commerce Products to new SKU based Products.\n" unless ($quiet);
    my $productSth = $session->db->read('select * from products order by title');
    my $variantSth = $session->db->prepare('select * from productVariants where productId=?');
    my $productFolder = WebGUI::Asset->getImportNode($session)->addChild({
        className   => 'WebGUI::Asset::Wobject::Folder',
        title       => 'Products',
        url         => 'import/products',
        isHidden    => 1,
        groupIdView => 14,
        groupIdEdit => 14,
    },'PBproductimportnode001');
    $session->db->write("update asset set isSystem=1 where assetId=?",[$productFolder->getId]);
    while (my $productData = $productSth->hashRef) {
        my $sku = $productFolder->addChild({
            className   => 'WebGUI::Asset::Sku::Product',
            title       => $productData->{title},
            url         => $productData->{title},
            sku         => $productData->{sku},
            description => $productData->{description},
        }, $productData->{productId});

        ##Get the parameter and options for this product
        my $parameterSth = $session->db->read('select opt.*, param.* from productParameters as param left join productParameterOptions as opt on param.parameterId=opt.parameterId where param.productId=?', [$productData->{productId}]);
        my $parameters; my $options;
        while (my %row = $parameterSth->hash) {
            $parameters->{$row{parameterId}} = {
                name        => $row{name},
                parameterId => $row{parameterId},
                options     => [],
            } unless (defined $parameters->{$row{parameterId}});
            if ($row{value}) {
                my $option = {
                    value       => $row{value},
                    optionId    => $row{optionId},
                    parameterId => $row{parameterId},
                    priceModifier   => $row{priceModifier},
                    weightModifier  => $row{weightModifier},
                    skuModifier => $row{skuModifier}
                };
                push(@{$parameters->{$row{parameterId}}->{options}}, $row{optionId});
                $options->{$row{optionId}} = $option;
            }
        }
        $parameterSth->finish;

        ##Get the variants
        $variantSth->execute([$productData->{productId}]);
        while (my $variantData = $variantSth->hashRef) {
            my $shortdesc = '';
            foreach (split(/,/,$variantData->{composition})) {
                my ($parameterId, $optionId) = split(/\./, $_);
                my $parameter = $parameters->{$parameterId}->{name};
                my $value     = $options->{$optionId}->{value};
                $shortdesc .= sprintf('%s:%s,', $parameter, $value);
            }
            $shortdesc =~ s/,$//; ##tidy up and clip to 30 chars
            $shortdesc = $productData->{title} unless $shortdesc;
            $shortdesc = substr $shortdesc, 0, 30;

            my $variant;
            $variant->{varSku}    = $variantData->{sku};
            $variant->{price}     = $variantData->{price};
            $variant->{weight}    = $variantData->{weight};
            $variant->{quantity}  = $variantData->{available};
            $variant->{shortdesc} = $shortdesc;
            $sku->setCollateral('variantsJSON', 'variantId', 'new', $variant);
        }
    }
    $productSth->finish;
    $variantSth->finish;
    ##Clean up tables
    $session->db->write('drop table products');
    $session->db->write('drop table productParameters');
    $session->db->write('drop table productParameterOptions');
    $session->db->write('drop table productVariants');
    return 1;
}

#-------------------------------------------------
sub removeOldCommerceCode {
	my $session = shift;
    	print "\tRemoving old commerce code.\n" unless ($quiet);

    my $setting = $session->setting;
    $setting->remove('groupIdAdminProductManager'); 
    $setting->remove('groupIdAdminSubscription'); 
    $setting->remove('groupIdAdminTransactionLog'); 
    my $config = $session->config;
    unlink ($webguiRoot . '/lib/WebGUI/Asset/Wobject/Product.pm') ;

    rmtree ($webguiRoot . '/lib/WebGUI/Commerce') ;
    unlink ($webguiRoot . '/lib/WebGUI/Commerce.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Product.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Subscription.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Operation/TransactionLog.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/CommercePaymentCash.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/CommercePaymentCheck.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/CommercePaymentITransact.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/CommerceShippingByPrice.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/CommerceShippingByWeight.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/CommerceShippingPerTransaction.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/Workflow_Activity_CacheEMSPrereqs.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/Workflow_Activity_ProcessRecurringPayments.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Workflow/Activity/ProcessRecurringPayments.pm') ;
    $session->db->write("delete from WorkflowActivity where className='WebGUI::Workflow::Activity::ProcessRecurringPayments'");
    unlink ($webguiRoot . '/lib/WebGUI/Macro/Product.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Help/Macro_Product.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/Macro_Product.pm') ;
    unlink ($webguiRoot . '/t/Macro/Product.t') ;

    unlink ($webguiRoot . '/lib/WebGUI/Macro/SubscriptionItem.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Macro/SubscriptionItemPurchaseUrl.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Help/Macro_SubscriptionItem.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/Macro_SubscriptionItem.pm') ;
    unlink ($webguiRoot . '/t/Macro/SubscriptionItem.t') ;
    unlink ($webguiRoot . '/t/Macro/SubscriptionItemPurchaseUrl.t') ;

    unlink ($webguiRoot . '/lib/WebGUI/Operation/ProductManager.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Help/ProductManager.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/ProductManager.pm') ;

    unlink ($webguiRoot . '/lib/WebGUI/Operation/Commerce.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Help/Commerce.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/Commerce.pm') ;

    unlink ($webguiRoot . '/lib/WebGUI/Operation/Subscription.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/Help/Subscription.pm') ;
    unlink ($webguiRoot . '/lib/WebGUI/i18n/English/Subscription.pm') ;

    unlink ($webguiRoot . '/www/extras/adminConsole/subscriptions.gif') ;
    unlink ($webguiRoot . '/www/extras/adminConsole/small/subscriptions.gif') ;
    unlink ($webguiRoot . '/www/extras/adminConsole/productManager.gif') ;
    unlink ($webguiRoot . '/www/extras/adminConsole/small/productManager.gif') ;

    ##Delete unused templates
    my $templates = $session->db->read("select distinct(assetId) from template where namespace like 'Commerce%'",[]);
    while (my $hash = $templates->hashRef) {
        my $template = WebGUI::Asset->newByDynamicClass($session, $hash->{assetId});
        $template->purge;
    }

    ##Drop commerce specific tables;
    $session->db->write('drop table commerceSettings');

    #Disable the Product macro in the config file.  You can't use the convenience method
    #deleteFromHash since the macro name is in the value, not the key.
    my %macros = %{ $config->get('macros') };
    foreach (my ($key, $value) = each %macros) {
        delete $macros{$key} if $value eq 'Product';
        delete $macros{$key} if $value eq 'SubscriptionItem';
        delete $macros{$key} if $value eq 'SubscriptionItemPurchaseUrl';
    }
    $config->set('macros', \%macros);
    $config->deleteFromArray('assets','WebGUI::Asset::Wobject::Product');
    return 1;
}


#-------------------------------------------------
sub updateUsersOfCommerceMacros {
	my $session = shift;
	print "\tUpdate assets which might be using the Product and SubscriptionItem macros.\n" unless ($quiet);
    my $db = $session->db;
    my %tables = (
        wobject     => 'description',
        snippet     => 'snippet',
        template    => 'template',
        Post        => 'content',
        );

    foreach my $table (keys %tables) {
        print "\t\tUpdating ".$table."s.\n" unless ($quiet);
        my $sth = $db->read('select assetId, revisionDate, '.$tables{$table}.' from '.$table.' order by assetId, revisionDate');
        while (my ($id, $rev, $content) = $sth->array) {
            my $fixed = $content;
            # handle normal subscription item
            $fixed =~ s{\^SubscriptionItem\(([A-Za-z0-9_-]{22})\);}{^AssetProxy($1,assetId);}xg;
            # handle one with an optional template id attached
            $fixed =~ s{\^SubscriptionItem\(([A-Za-z0-9_-]{22}),[A-Za-z0-9_-]{22}\);}{^AssetProxy($1,assetId);}xg;
            # handle product macros
            while ($fixed =~ m/\^Product\('? ([^),']+) /xg) {
                #printf "\t\tWorking on %s\n", $id;
                my $identifier = $1;  ##If this is a product sku, need to look up by productId;
                #printf "\t\t\tFound argument of %s\n", $identifier;
                my $assetId = $db->quickScalar('select distinct(assetId) from sku where sku=?',[$identifier]);
                #printf "\t\t\tsku assetId: %s\n", $id;
                my $productAssetId = $assetId ? $assetId : $identifier;
                $fixed =~ s/\^Product\( [^)]+ \)/^AssetProxy($productAssetId,assetId)/x;
                #printf "\t\t\tUpdated ".$tables{$table}." to%s\n", $fixed;
            }
            if ($fixed ne $content) {
                $db->write('update '.$table.' set '.$tables{$table}.'=? where  assetId=? and revisionDate=?', [$fixed, $id, $rev]);
            }
        }
    }

    return 1;
}


#-------------------------------------------------
sub deleteOldProductTemplates {
	my $session = shift;
	print "\tDeleting all Product Templates, except for the Default Product Template.\n" unless ($quiet);
    $session->db->write("update Product set templateId='PBtmpl0000000000000056.tmpl'");
    foreach my $templateId (qw/PBtmpl0000000000000095 PBtmpl0000000000000110 PBtmpl0000000000000119/) {
        my $template = WebGUI::Asset->newByDynamicClass($session, $templateId);
        $template->purge;
    }
    return 1;
}


#-------------------------------------------------
sub insertCommercePayDriverTable {
	my $session = shift;
	print "\tInstall the Commerce PayDriver Table.\n" unless ($quiet);
	# and here's our code
    $session->db->write(<<EOSQL);
CREATE TABLE paymentGateway (
    paymentGatewayId    VARCHAR(22) binary NOT NULL primary key,
    label               VARCHAR(255),           
    className           VARCHAR(255),
    options             mediumtext
)
EOSQL
}

#-------------------------------------------------
sub modifyThingyPossibleValues {
    my $session = shift;
    print "\tModify data type of Thingy field's possible Values property.\n" unless ($quiet);
    $session->db->write("alter table Thingy_fields modify possibleValues text");
}

#-------------------------------------------------
sub removeLegacyTable {
    my $session = shift;
    print "\tRemoving legacy field table..." unless ($quiet);
    $session->db->write("DROP TABLE `wgFieldUserData`");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addVersionStartEndDates {
    my $session = shift;
    print "\tAdding Start and End times to Version Tags..." unless ($quiet);
    $session->db->write("alter table assetVersionTag add startTime datetime default NULL");
    $session->db->write("alter table assetVersionTag add endTime datetime default NULL");
    
    #Add default start and end times to existing version tags
    my $now        = $session->datetime->time();
    my $startTime  = WebGUI::DateTime->new($session,$now)->toDatabase;
    my $endTime    = WebGUI::DateTime->new($session,'2036-01-01 00:00:00')->toDatabase;
    $session->db->write("update assetVersionTag set startTime=?, endTime=?",[$startTime,$endTime]);
    
    my $activity    = $session->config->get( "workflowActivities" );
    push @{ $activity->{"WebGUI::VersionTag"} }, 'WebGUI::Workflow::Activity::WaitUntil';
    $session->config->set( "workflowActivities", $activity );
    
    #Update the Workflows
    tie my %commitWithApproval, 'Tie::IxHash';
    %commitWithApproval = (
        pbwfactivity0000000017 => {
        	className  =>"WebGUI::Workflow::Activity::RequestApprovalForVersionTag",
                properties => {
                groupToApprove => '4',
                message        => 'A new version tag awaits your approval.',
                doOnDeny       => 'pbworkflow000000000006',
                title          => 'Get Approval from Content Managers'
            },
        },
        vtagactivity0000000001 => {
            className  =>"WebGUI::Workflow::Activity::WaitUntil",
            properties => {
                type        => 'startTime',
                title       => 'Wait Until',
            	description => 'This workflow waits until the value chosen in the "Wait Until" field has passed and then continues'
            }
        },
        pbwfactivity0000000016 => {
            className  => "WebGUI::Workflow::Activity::CommitVersionTag",
            properties => {
                title  => 'Commit Assets'
            }
        },
        pbwfactivity0000000018 => {
            className  => "WebGUI::Workflow::Activity::NotifyAboutVersionTag",
            properties => {
                title   => 'Notify Committer of Approval',
                message => 'Your version tag was approved.',
                who     => 'committer',
            }
        }
    );

    #Commit without approval workflow
    tie my %commitWithoutApproval, 'Tie::IxHash';
    %commitWithoutApproval = (
        vtagactivity0000000002 => {
            className  =>"WebGUI::Workflow::Activity::WaitUntil",
            properties => {
                type        => 'startTime',
                title       => 'Wait Until',
                description => 'This workflow waits until the value chosen in the "Wait Until" field has passed and then continues'
            }
        },
        pbwfactivity0000000006 => {
        	className  => "WebGUI::Workflow::Activity::CommitVersionTag",
            properties => {
                title      => 'Commit Assets',
                trashAfter => '2592000',
            }
        },
    );

    #Build a hash of the two workflows - kinda ugly but insures we preserve order
    my $workflows = {
        "pbworkflow000000000005"=>\%commitWithApproval,
        "pbworkflow000000000003"=>\%commitWithoutApproval
    };


    foreach my $workflowId (keys %{$workflows}) {
       #instantiate the workflow
        my $workflow = WebGUI::Workflow->new($session, $workflowId);
    
        #Skip it if the workflow activity doesn't exist for some reason
        next unless (defined $workflow);
	
        #delete all the existing activities in the workflow
        my $activities = $workflow->getActivities;
        foreach my $activity (@{$activities}) {
            $workflow->deleteActivity ($activity->get("activityId"));
        }
	
        #Re-add the activities in the proper order
        my $activityHashRef = $workflows->{$workflowId};
        foreach my $activityId (keys %{$activityHashRef}) {
            my $activity = $workflow->addActivity($activityHashRef->{$activityId}->{className},$activityId);
        	my $properties = $activityHashRef->{$activityId}->{properties};
            foreach my $property (keys %{$properties}) {
                $activity->set($property,$properties->{$property});
            }
        }
    }
    
    print "Done.\n" unless $quiet;
    
}

#-------------------------------------------------
sub migrateSubscriptions {
    my $session = shift;
    print "\tMigrating subscriptions to the new commerce system...\n" unless ($quiet);

    # Check if codes are tied to multiple subscriptions.
    my ($hasDoubles) = $session->db->buildArray(
        'select count(*) as cnt from subscriptionCodeSubscriptions group by code order by cnt desc'
    );
    print "\n\t\t!!WARNING: There are subscription codes that link to multiple subscriptions!!"
        ." Please refer to gotcha.txt!\n" if $hasDoubles > 1 && !$quiet;

    # Rename old subscription table so we can reuse it for the Sku
    $session->db->write('alter table subscription rename to Subscription_OLD');

    # Create the new subscription table
    $session->db->write(<<EOSQL);
        create table Subscription (
            assetId                 varchar(22) binary  not null,
            revisionDate            bigint(20)          not null,
            templateId              varchar(22)         not null    default '',
            thankYouMessage         mediumtext,
            price                   float               not null    default 0.00,
            subscriptionGroup       varchar(22)         not null    default 2,
            duration                varchar(12)         not null    default 'Monthly',
            executeOnSubscription   varchar(255),
            karma                   int(6)                          default 0,

            PRIMARY KEY (assetId, revisionDate)
        );
EOSQL

    # Create the new subsction code table
    $session->db->write(<<EOSQL2);
        create table Subscription_code (
            code                    varchar(64)         not null,
            batchId                 varchar(22)         not null,
            status                  varchar(10)         not null    default 'Unused',
            dateUsed                bigint(20),
            usedBy                  varchar(22),

            PRIMARY KEY (code)
        );
EOSQL2

    # Create the new subscription code batch table
    $session->db->write(<<EOSQL3);
        create table Subscription_codeBatch (
            batchId                 varchar(22)         not null,
            name                    varchar(255),
            description             mediumtext,
            subscriptionId          varchar(22)         not null,
            expirationDate          bigint(20)          not null,
            dateCreated             bigint(20)          not null,

            PRIMARY KEY (batchId)
        );
EOSQL3

    # Add a folder to the import node for the migrated subscriptions
    my $subscriptionsFolder = WebGUI::Asset->getImportNode( $session )->addChild({
        className   => 'WebGUI::Asset::Wobject::Folder',
        menuTitle   => 'Migrated subscriptions',
        title       => 'Migrated subscriptions',
        ownerUserId => 3,
    });

    # Migrate all subscriptions
    print "\t\tConverting subscriptions to assets:\n" unless $quiet;
    my $subscriptions = $session->db->read( 'select * from Subscription_OLD' );
    while (my $subscription = $subscriptions->hashRef) {
        # Don't migrate deleted subscriptions
        next if $subscription->{ deleted };

        # Add a new subscription sku
        my $sku = $subscriptionsFolder->addChild(
            {
                className               => 'WebGUI::Asset::Sku::Subscription',
                ownerUserId             => 3,
                url                     => 'subscriptions/'.$subscription->{ description },
                menuTitle               => $subscription->{ description             },
                title                   => $subscription->{ description             },
                price                   => $subscription->{ price                   },
                description             => $subscription->{ description             },
                subscriptionGroup       => $subscription->{ subscriptionGroup       },
                duration                => $subscription->{ duration                },
                executeOnSubscription   => $subscription->{ executeOnSubscription   },
                karma                   => $subscription->{ karma                   },
                templateId              => 'eqb9sWjFEVq0yHunGV8IGw',
                overrideTaxRate         => $subscription->{ useSalesTax } ? 0 : 1,
                taxRateOverride         => 0,
            },
            $subscription->{ subscriptionId },
        );

        # Log and print migration data
        my $message = "Migrated subscription '$subscription->{ description }' ($subscription->{ subscriptionId }) "
            . " to '" . $sku->getUrl . "' (" . $sku->getId . ")";
        $session->errorHandler->warn( $message );
        print "\t\t--> $message\n";
    }
    $subscriptions->finish;

    # Subscriptions are migrated, now migrate the subscription codes
    # First find batches with multiple subscriptions per code
    my @multiBatches = $session->db->buildArray(
        'select distinct batchId from subscriptionCode where code in '
        .' (select code from subscriptionCodeSubscriptions group by code having count(subscriptionId) > 1)'
    );

    # Migrate subscription codes batch by batch
    print "\t\tMigrating subscription codes.\n" unless $quiet;
    my @batches = $session->db->buildArray('select distinct batchId from subscriptionCodeBatch');
    foreach my $batchId ( @batches ) {
        my $subscriptionId;

        # Fetch batch properties and the number of code. Discard used or expired codes.
        my ($numberOfCodes, $codeLength, $expirationDate, $dateCreated, $name, $description) =
            $session->db->quickArray( 
                'select count(*), length(t1.code), (t1.dateCreated + t1.expires), '
                .' t1.dateCreated, t2.name, t2.description '
                .' from subscriptionCode as t1, subscriptionCodeBatch as t2 '
                .' where t1.batchId=t2.batchId and t1.batchId=? '
                .' and t1.status=\'Unused\' '
                .' and from_unixtime(t1.dateCreated + t1.expires) > now() '
                .' group by t1.batchId',
                [
                    $batchId,
                ]
            );

        # Skip expired or fully used batches;
        next unless $numberOfCodes;

        # Check if the codes in this batch link to multiple subscriptions
        if ( isIn( $batchId, @multiBatches ) ) {
            my $message = "\t\tBatch $batchId has codes linking to multiple subscriptions:\n";

            # Find the subscriptions the code in this batch are attached to
            my @subscriptions = $session->db->buildArray(
                'select distinct subscriptionId from subscriptionCodeSubscriptions where code in '
                .' (select distinct code from subscriptionCode where batchId=?)', 
                [
                    $batchId,
                ]
            );
        
            # Migrate the codes for the first subscription in the list (this is done below)
            $subscriptionId = shift @subscriptions;

            my $subscription = WebGUI::Asset::Sku::Subscription->new($session, $subscriptionId);
            $message .= "\t\t--> Keeping codes for subscription "
                . "'" . $subscription->get('title') . "' (" . $subscription->getUrl . ") \n";

            # And generate new codes for the remaining subscriptions
            foreach my $assetId ( @subscriptions ) { 
                my $subscription = WebGUI::Asset::Sku::Subscription->new($session, $assetId);

                $message .= "\t\t--> Generating new codes for subscription "
                    . "'" . $subscription->get('title') . "' (" . $subscription->getUrl . "): \n";

                my $batchId = $subscription->generateSubscriptionCodeBatch(
                    $numberOfCodes,
                    $codeLength,
                    $expirationDate,
                    $name,
                    $description
                );
                
                $message .= "\t\t\t" . join( "\n\t\t\t", keys %{ $subscription->getCodesInBatch( $batchId ) } ). "\n";
            }

            # Log and print migration info
            $session->errorHandler->warn( $message );
            print $message unless $quiet;
        }
        else {
            $subscriptionId = $session->db->quickScalar(
                'select distinct subscriptionId from subscriptionCodeSubscriptions '
                .' where code in (select code from subscriptionCode where batchId=?)',
                [
                    $batchId,
                ]
            );
        }

        # Migrate the batch itself
        $session->db->write(
            'insert into Subscription_codeBatch '
            . '         (batchId, name, description, subscriptionId, expirationDate, dateCreated) '
            . ' values  (?      , ?   , ?          , ?             , ?             , ?          ) ',
            [
                $batchId,
                $name,
                $description,
                $subscriptionId,
                $expirationDate,
                $dateCreated,
            ]
        );

        # Migrate the codes
        $session->db->write(
            'insert into Subscription_code (batchId, code, status, dateUsed, usedBy) '
            .' select batchId, code, status, dateUsed, usedBy from subscriptionCode where batchId=?',
            [
                $batchId,
            ]
        );
    }
    print "\t\tAdding subscriptions to the config file:\n" unless $quiet;
    $session->config->addToArray('assets', 'WebGUI::Asset::Sku::Subscription');

    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addDBLinkAccessToSQLMacro {
    my $session = shift;
    print "\tAdding DBLink access to SQL Macro ..." unless ($quiet);
    $session->db->write("insert into databaseLink (databaseLinkId, allowMacroAccess) values ('0','1')");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub migratePaymentPlugins {
    my $session = shift;
    print "\tMigrating WebGUI default commerce plugins..." unless $quiet;

    foreach my $namespace (qw{ Cash ITransact }) {
        # Get properties from old plugin
        my $properties = $session->db->buildHashRef(
            'select fieldName, fieldValue from commerceSettings where type=\'Payment\' and namespace=?',
            [
                $namespace,
            ]
        );

        # And set new properties
        $properties->{ groupToUse               } = $properties->{ whoCanUse };
        $properties->{ receiptEmailTemplateId   } = 'BMzuE91-XB8E-XGll1zpvA';

        # Create paydriver instance
        my $plugin =  
         WebGUI::Pluggable::instanciate("WebGUI::Shop::PayDriver::$namespace", 'create', [ 
                $session, 
                $properties->{ label } || $namespace || 'Credit Card',
                $properties
            ])
        ;

        # Print warning message for ITransact users that they must change their postback url
        if ( $namespace eq 'ITransact' && $properties->{ vendorId } ) {
            print "\n\t\t!!CAUTION!!: The postback url for ITransact has changed. Please log in to your virtual "
                ."terminal and change the postback url to:\n\n\t\t"
                .'https://'.$session->config->get("sitename")->[0]
                .'/?shop=pay;method=do;do=processRecurringTransactionPostback;paymentGatewayId='.$plugin->getId."\n\t";
        }
    }

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeRecurringPaymentActivity {
    my $session = shift;
    print "\tRemoving the recurring payment workflow activity..." unless $quiet;

    my $activities = $session->config->get( 'workflowActivities' );

    my $none = $activities->{ None };
    $activities->{ None } = [ grep { !/^WebGUI::Workflow::Activity::ProcessRecurringPayments$/ } @{ $none } ];
    
    $session->config->set( 'workflowActivities', $activities );

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------

sub addUserListWobject {
    my $session = shift;
    print "\tInstall UserList wobject.\n" unless ($quiet);
    $session->db->write("create table UserList (
            assetId varchar(22) not null,
            revisionDate bigint(20),
            templateId varchar(22),
            showGroupId varchar(22),
            hideGroupId varchar(22),
            usersPerPage int(11),
            alphabet text,
            alphabetSearchField varchar(128),
            showOnlyVisibleAsNamed int(11),
            sortBy varchar(128),
            sortOrder varchar(4),
            overridePublicEmail int(11),
            overridePublicProfile int(11),
        PRIMARY KEY  (`assetId`,`revisionDate`)
    )");
    $session->config->addToArray("assets","WebGUI::Asset::Wobject::UserList");

}

#----------------------------------------------------------------------------
# Add the inheritUrlFromParent property for all assets
sub addInheritUrlFromParent {
    my $session = shift;
    print "\tAdding inheritUrlFromParent flag for all assets..." unless $quiet;
    $session->db->write('alter table assetData add column inheritUrlFromParent int(11) not null default 0');
    print "DONE!\n" unless $quiet;
}
   
#----------------------------------------------------------------------------
sub fixAdminConsoleTemplateTitles {
    my $session = shift;
    print "\tMaking unique title for admin console templates... " unless $quiet;
    my $ac = WebGUI::Asset->newByDynamicClass($session, 'PBtmpl0000000000000137');
    $ac->update({title => 'Admin Console Style'});
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Make longer asset metadata values
sub makeLongerAssetMetadataValues {
    my $session     = shift;
    print "\tLengthening asset metadata values to 255 characters... " unless $quiet;
    $session->db->write(
        q{ ALTER TABLE `metaData_properties` CHANGE COLUMN defaultValue defaultValue VARCHAR(255) },
    );
    $session->db->write(
        q{ ALTER TABLE `metaData_values` CHANGE COLUMN value value VARCHAR(255) },
    );
    print "DONE!\n" unless $quiet;
}

sub ensureCorrectDefaults {
    my $session = shift;
    print "\tEnsuring correct database defaults..." unless $quiet;
    my $sql = <<'END_SQL';

ALTER TABLE `Article`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '3600',
  MODIFY `storageId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `Calendar`
  MODIFY `revisionDate` bigint(20) unsigned NOT NULL DEFAULT '0',
  MODIFY `visitorCacheTimeout` int(11) unsigned DEFAULT NULL,
  MODIFY `workflowIdCommit` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `Collaboration`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `postGroupId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `canStartThreadGroupId` varchar(22) NOT NULL DEFAULT '2',
  MODIFY `karmaPerPost` int(11) NOT NULL DEFAULT '0',
  MODIFY `collaborationTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `threadTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `postFormTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `searchTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `notificationTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `sortBy` varchar(35) NOT NULL DEFAULT 'assetData.revisionDate',
  MODIFY `sortOrder` varchar(4) NOT NULL DEFAULT 'desc',
  MODIFY `usePreview` int(11) NOT NULL DEFAULT '1',
  MODIFY `addEditStampToPosts` int(11) NOT NULL DEFAULT '0',
  MODIFY `editTimeout` int(11) NOT NULL DEFAULT '3600',
  MODIFY `attachmentsPerPost` int(11) NOT NULL DEFAULT '0',
  MODIFY `filterCode` varchar(30) NOT NULL DEFAULT 'javascript',
  MODIFY `useContentFilter` int(11) NOT NULL DEFAULT '1',
  MODIFY `threads` int(11) NOT NULL DEFAULT '0',
  MODIFY `views` int(11) NOT NULL DEFAULT '0',
  MODIFY `replies` int(11) NOT NULL DEFAULT '0',
  MODIFY `rating` int(11) NOT NULL DEFAULT '0',
  MODIFY `lastPostId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `archiveAfter` int(11) NOT NULL DEFAULT '31536000',
  MODIFY `postsPerPage` int(11) NOT NULL DEFAULT '10',
  MODIFY `threadsPerPage` int(11) NOT NULL DEFAULT '30',
  MODIFY `subscriptionGroupId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `allowReplies` int(11) NOT NULL DEFAULT '0',
  MODIFY `displayLastReply` int(11) NOT NULL DEFAULT '0',
  MODIFY `richEditor` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'PBrichedit000000000002',
  MODIFY `karmaRatingMultiplier` int(11) NOT NULL DEFAULT '0',
  MODIFY `karmaSpentToRate` int(11) NOT NULL DEFAULT '0',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `avatarsEnabled` int(11) NOT NULL DEFAULT '0',
  MODIFY `approvalWorkflow` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'pbworkflow000000000003',
  MODIFY `threadApprovalWorkflow` varchar(22) NOT NULL DEFAULT 'pbworkflow000000000003',
  MODIFY `defaultKarmaScale` int(11) NOT NULL DEFAULT '1',
  MODIFY `getMail` int(11) NOT NULL DEFAULT '0',
  MODIFY `getMailInterval` int(11) NOT NULL DEFAULT '300',
  MODIFY `getMailCronId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `visitorCacheTimeout` int(11) NOT NULL DEFAULT '3600',
  MODIFY `autoSubscribeToThread` int(11) NOT NULL DEFAULT '1',
  MODIFY `requireSubscriptionForEmailPosting` int(11) NOT NULL DEFAULT '1',
  MODIFY `thumbnailSize` int(11) NOT NULL DEFAULT '0',
  MODIFY `maxImageSize` int(11) NOT NULL DEFAULT '0',
  MODIFY `enablePostMetaData` int(11) NOT NULL DEFAULT '0',
  MODIFY `useCaptcha` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Dashboard`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `adminsGroupId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '4',
  MODIFY `usersGroupId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'DashboardViewTmpl00001',
  MODIFY `isInitialized` tinyint(3) unsigned NOT NULL DEFAULT '0'
;

ALTER TABLE `DataForm`
  MODIFY `mailData` int(11) NOT NULL DEFAULT '1',
  MODIFY `emailTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `acknowlegementTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `listTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `defaultView` int(11) NOT NULL DEFAULT '0',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `groupToViewEntries` varchar(22) NOT NULL DEFAULT '7'
;

ALTER TABLE `DataForm_entry`
  MODIFY `DataForm_entryId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `EMSBadge`
  MODIFY `price` float NOT NULL DEFAULT '0',
  MODIFY `seatsAvailable` int(11) NOT NULL DEFAULT '100'
;

ALTER TABLE `EMSEventMetaField`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `EMSRegistrant`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `transactionItemId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `EMSRegistrantRibbon`
  MODIFY `transactionItemId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `EMSRegistrantTicket`
  MODIFY `transactionItemId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `EMSRibbon`
  MODIFY `percentageDiscount` float NOT NULL DEFAULT '10',
  MODIFY `price` float NOT NULL DEFAULT '0'
;

ALTER TABLE `EMSTicket`
  MODIFY `price` float NOT NULL DEFAULT '0',
  MODIFY `seatsAvailable` int(11) NOT NULL DEFAULT '100',
  MODIFY `duration` float NOT NULL DEFAULT '1'
;

ALTER TABLE `EMSToken`
  MODIFY `price` float NOT NULL DEFAULT '0'
;

ALTER TABLE `Event`
  MODIFY `timeZone` varchar(255) character set utf8 collate utf8_bin DEFAULT 'America/Chicago'
;

ALTER TABLE `EventManagementSystem`
  MODIFY `groupToApproveEvents` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `timezone` varchar(30) NOT NULL DEFAULT 'America/Chicago',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2rC4ErZ3c77OJzJm7O5s3w',
  MODIFY `badgeBuilderTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'BMybD3cEnmXVk2wQ_qEsRQ',
  MODIFY `lookupRegistrantTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'OOyMH33plAy6oCj_QWrxtg',
  MODIFY `printBadgeTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'PsFn7dJt4wMwBa8hiE3hOA',
  MODIFY `printTicketTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'yBwydfooiLvhEFawJb0VTQ'
;

ALTER TABLE `FileAsset`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `storageId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `filename` varchar(255) NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '3600'
;

ALTER TABLE `FlatDiscount`
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '63ix2-hU0FchXGIWkG3tow',
  MODIFY `mustSpend` float NOT NULL DEFAULT '0',
  MODIFY `percentageDiscount` int(3) NOT NULL DEFAULT '0',
  MODIFY `priceDiscount` float NOT NULL DEFAULT '0'
;

ALTER TABLE `Folder`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `visitorCacheTimeout` int(11) NOT NULL DEFAULT '3600',
  MODIFY `sortAlphabetically` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Gallery`
  MODIFY `groupIdAddComment` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `groupIdAddFile` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `richEditIdComment` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdAddArchive` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdDeleteAlbum` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdDeleteFile` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdEditAlbum` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdEditFile` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdListAlbums` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdListAlbumsRss` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdListFilesForUser` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdListFilesForUserRss` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdMakeShortcut` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdSearch` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdViewSlideshow` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdViewThumbnails` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdViewAlbum` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdViewAlbumRss` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdViewFile` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `workflowIdCommit` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `templateIdEditComment` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `richEditIdAlbum` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `richEditIdFile` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `GalleryAlbum`
  MODIFY `assetIdThumbnail` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `GalleryFile_comment`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `HttpProxy`
  MODIFY `cookieJarStorageId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '0',
  MODIFY `useAmpersand` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `ITransact_recurringStatus`
  MODIFY `gatewayId` varchar(128) NOT NULL DEFAULT '',
  MODIFY `initDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `lastTransaction` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `status` varchar(10) NOT NULL DEFAULT '',
  MODIFY `recipe` varchar(15) NOT NULL DEFAULT ''
;

ALTER TABLE `ImageAsset`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `thumbnailSize` int(11) NOT NULL DEFAULT '50',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `InOutBoard`
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `reportViewerGroup` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3',
  MODIFY `inOutGroup` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `inOutTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'IOB0000000000000000001',
  MODIFY `reportTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'IOB0000000000000000002',
  MODIFY `paginateAfter` int(11) NOT NULL DEFAULT '50',
  MODIFY `reportPaginateAfter` int(11) NOT NULL DEFAULT '50'
;

ALTER TABLE `Layout`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `Matrix`
  MODIFY `detailTemplateId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `compareTemplateId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `searchTemplateId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `ratingDetailTemplateId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `maxComparisons` int(11) NOT NULL DEFAULT '10',
  MODIFY `maxComparisonsPrivileged` int(11) NOT NULL DEFAULT '10',
  MODIFY `privilegedGroup` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `groupToRate` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `ratingTimeout` int(11) NOT NULL DEFAULT '31536000',
  MODIFY `ratingTimeoutPrivileged` int(11) NOT NULL DEFAULT '31536000',
  MODIFY `groupToAdd` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `visitorCacheTimeout` int(11) NOT NULL DEFAULT '3600'
;

ALTER TABLE `Matrix_field`
  MODIFY `fieldId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `category` varchar(255) NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `Matrix_listing`
  MODIFY `listingId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `maintainerId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `forumId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `views` int(11) NOT NULL DEFAULT '0',
  MODIFY `compares` int(11) NOT NULL DEFAULT '0',
  MODIFY `clicks` int(11) NOT NULL DEFAULT '0',
  MODIFY `status` varchar(30) NOT NULL DEFAULT 'pending',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `approvalMessageId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `storageId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `Matrix_listingData`
  MODIFY `listingId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `fieldId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `Matrix_rating`
  MODIFY `timeStamp` int(11) NOT NULL DEFAULT '0',
  MODIFY `rating` int(11) NOT NULL DEFAULT '1',
  MODIFY `listingId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `Matrix_ratingSummary`
  MODIFY `listingId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `category` varchar(255) NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `MessageBoard`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `visitorCacheTimeout` int(11) NOT NULL DEFAULT '3600'
;

ALTER TABLE `MultiSearch`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) unsigned NOT NULL DEFAULT '0',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'MultiSearchTmpl0000001',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '3600'
;

ALTER TABLE `Navigation`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `descendantEndPoint` int(11) NOT NULL DEFAULT '55',
  MODIFY `showSystemPages` int(11) NOT NULL DEFAULT '0',
  MODIFY `showHiddenPages` int(11) NOT NULL DEFAULT '0',
  MODIFY `showUnprivilegedPages` int(11) NOT NULL DEFAULT '0',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `ancestorEndPoint` int(11) NOT NULL DEFAULT '55',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `Newsletter`
  MODIFY `newsletterTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'newsletter000000000001',
  MODIFY `mySubscriptionsTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'newslettersubscrip0001'
;

ALTER TABLE `Newsletter_subscriptions`
  MODIFY `lastTimeSent` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `PM_project`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `projectManager` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `percentComplete` float NOT NULL DEFAULT '0',
  MODIFY `parentId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `projectObserver` varchar(22) character set utf8 collate utf8_bin DEFAULT '7'
;

ALTER TABLE `PM_task`
  MODIFY `parentId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `sequenceNumber` int(11) NOT NULL DEFAULT '1',
  MODIFY `taskType` enum('timed','progressive','milestone') NOT NULL DEFAULT 'timed'
;

ALTER TABLE `PM_wobject`
  MODIFY `projectDashboardTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'ProjectManagerTMPL0001',
  MODIFY `projectDisplayTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'ProjectManagerTMPL0002',
  MODIFY `ganttChartTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'ProjectManagerTMPL0003',
  MODIFY `editTaskTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'ProjectManagerTMPL0004',
  MODIFY `groupToAdd` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3',
  MODIFY `resourcePopupTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'ProjectManagerTMPL0005',
  MODIFY `resourceListTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'ProjectManagerTMPL0006'
;

ALTER TABLE `Photo_rating`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `Poll`
  MODIFY `active` int(11) NOT NULL DEFAULT '1',
  MODIFY `graphWidth` int(11) NOT NULL DEFAULT '150',
  MODIFY `karmaPerVote` int(11) NOT NULL DEFAULT '0',
  MODIFY `randomizeAnswers` int(11) NOT NULL DEFAULT '0',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `Poll_answer`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `Post`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `threadId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `views` int(11) NOT NULL DEFAULT '0',
  MODIFY `contentType` varchar(35) NOT NULL DEFAULT 'mixed',
  MODIFY `storageId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `rating` int(11) NOT NULL DEFAULT '0',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `Post_rating`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `ipAddress` varchar(15) NOT NULL DEFAULT '',
  MODIFY `rating` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Product`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '3600'
;

ALTER TABLE `RSSCapable`
  MODIFY `rssCapableRssEnabled` int(11) NOT NULL DEFAULT '1',
  MODIFY `rssCapableRssTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'PBtmpl0000000000000142',
  MODIFY `rssCapableRssFromParentId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `RichEdit`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `askAboutRichEdit` int(11) NOT NULL DEFAULT '0',
  MODIFY `preformatted` int(11) NOT NULL DEFAULT '0',
  MODIFY `editorWidth` int(11) NOT NULL DEFAULT '0',
  MODIFY `editorHeight` int(11) NOT NULL DEFAULT '0',
  MODIFY `sourceEditorWidth` int(11) NOT NULL DEFAULT '0',
  MODIFY `sourceEditorHeight` int(11) NOT NULL DEFAULT '0',
  MODIFY `useBr` int(11) NOT NULL DEFAULT '0',
  MODIFY `nowrap` int(11) NOT NULL DEFAULT '0',
  MODIFY `removeLineBreaks` int(11) NOT NULL DEFAULT '0',
  MODIFY `npwrap` int(11) NOT NULL DEFAULT '0',
  MODIFY `directionality` char(3) NOT NULL DEFAULT 'ltr',
  MODIFY `toolbarLocation` varchar(6) NOT NULL DEFAULT 'bottom',
  MODIFY `enableContextMenu` int(11) NOT NULL DEFAULT '0',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `inlinePopups` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `SQLForm_fieldOrder`
  MODIFY `assetId` varchar(22) NOT NULL DEFAULT '',
  MODIFY `fieldId` varchar(22) NOT NULL DEFAULT ''
;

ALTER TABLE `SQLReport`
  MODIFY `paginateAfter` int(11) NOT NULL DEFAULT '50',
  MODIFY `debugMode` int(11) NOT NULL DEFAULT '0',
  MODIFY `databaseLinkId1` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `databaseLinkId2` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `databaseLinkId3` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `databaseLinkId4` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `databaseLinkId5` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Shelf`
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'nFen0xjkZn8WkpM93C9ceQ'
;

ALTER TABLE `Shortcut`
  MODIFY `overrideTitle` int(11) NOT NULL DEFAULT '0',
  MODIFY `overrideDescription` int(11) NOT NULL DEFAULT '0',
  MODIFY `overrideTemplate` int(11) NOT NULL DEFAULT '0',
  MODIFY `overrideDisplayTitle` int(11) NOT NULL DEFAULT '0',
  MODIFY `overrideTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `shortcutByCriteria` int(11) NOT NULL DEFAULT '0',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `shortcutToAssetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `disableContentLock` int(11) NOT NULL DEFAULT '0',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `showReloadIcon` tinyint(3) unsigned NOT NULL DEFAULT '0'
;

ALTER TABLE `Shortcut_overrides`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `fieldName` varchar(255) NOT NULL DEFAULT ''
;

ALTER TABLE `StockData`
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'StockListTMPL000000001',
  MODIFY `displayTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'StockListTMPL000000002'
;

ALTER TABLE `Subscription`
  MODIFY `templateId` varchar(22) NOT NULL DEFAULT '',
  MODIFY `price` float NOT NULL DEFAULT '0',
  MODIFY `subscriptionGroup` varchar(22) NOT NULL DEFAULT '2',
  MODIFY `duration` varchar(12) NOT NULL DEFAULT 'Monthly'
;

ALTER TABLE `Subscription_OLD`
  MODIFY `subscriptionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `subscriptionGroup` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `duration` varchar(12) NOT NULL DEFAULT 'Monthly'
;

ALTER TABLE `Subscription_code`
  MODIFY `status` varchar(10) NOT NULL DEFAULT 'Unused'
;

ALTER TABLE `Survey`
  MODIFY `groupToTakeSurvey` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `groupToViewReports` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3',
  MODIFY `Survey_id` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `anonymous` char(1) NOT NULL DEFAULT '0',
  MODIFY `questionsPerPage` int(11) NOT NULL DEFAULT '1',
  MODIFY `responseTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `overviewTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `maxResponsesPerUser` int(11) NOT NULL DEFAULT '1',
  MODIFY `questionsPerResponse` int(11) NOT NULL DEFAULT '9999999',
  MODIFY `gradebookTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `Survey_answer`
  MODIFY `Survey_id` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_questionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_answerId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `sequenceNumber` int(11) NOT NULL DEFAULT '1',
  MODIFY `gotoQuestion` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `isCorrect` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Survey_question`
  MODIFY `Survey_id` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_questionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `sequenceNumber` int(11) NOT NULL DEFAULT '1',
  MODIFY `allowComment` int(11) NOT NULL DEFAULT '0',
  MODIFY `randomizeAnswers` int(11) NOT NULL DEFAULT '0',
  MODIFY `Survey_sectionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `Survey_questionResponse`
  MODIFY `Survey_id` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_questionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_answerId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_responseId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `dateOfResponse` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `Survey_response`
  MODIFY `Survey_id` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_responseId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `startDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `endDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `isComplete` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Survey_section`
  MODIFY `Survey_id` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `Survey_sectionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `sequenceNumber` int(11) NOT NULL DEFAULT '1'
;

ALTER TABLE `SyndicatedContent`
  MODIFY `maxHeadlines` int(11) NOT NULL DEFAULT '0',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `displayMode` varchar(20) NOT NULL DEFAULT 'interleaved',
  MODIFY `hasTerms` varchar(255) NOT NULL DEFAULT '',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '3600'
;

ALTER TABLE `TT_projectList`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `TT_projectResourceList`
  MODIFY `resourceId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `TT_report`
  MODIFY `reportComplete` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `TT_wobject`
  MODIFY `userViewTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'TimeTrackingTMPL000001',
  MODIFY `managerViewTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'TimeTrackingTMPL000002',
  MODIFY `timeRowTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'TimeTrackingTMPL000003',
  MODIFY `pmAssetId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `groupToManage` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3',
  MODIFY `pmIntegration` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Thingy_things`
  MODIFY `thingsPerPage` int(11) NOT NULL DEFAULT '25'
;

ALTER TABLE `Thread`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `replies` int(11) NOT NULL DEFAULT '0',
  MODIFY `lastPostId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `isLocked` int(11) NOT NULL DEFAULT '0',
  MODIFY `isSticky` int(11) NOT NULL DEFAULT '0',
  MODIFY `subscriptionGroupId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `karma` int(11) NOT NULL DEFAULT '0',
  MODIFY `karmaScale` int(11) NOT NULL DEFAULT '1'
;

ALTER TABLE `Thread_read`
  MODIFY `threadId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `UserList`
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `WSClient`
  MODIFY `uri` varchar(255) NOT NULL DEFAULT '',
  MODIFY `proxy` varchar(255) NOT NULL DEFAULT '',
  MODIFY `preprocessMacros` int(11) NOT NULL DEFAULT '0',
  MODIFY `paginateAfter` int(11) NOT NULL DEFAULT '50',
  MODIFY `debugMode` int(11) NOT NULL DEFAULT '0',
  MODIFY `execute_by_default` tinyint(4) NOT NULL DEFAULT '1',
  MODIFY `decodeUtf8` tinyint(3) unsigned NOT NULL DEFAULT '0',
  MODIFY `sharedCache` tinyint(3) unsigned NOT NULL DEFAULT '0',
  MODIFY `cacheTTL` smallint(5) unsigned NOT NULL DEFAULT '60',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `WeatherData`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) unsigned NOT NULL DEFAULT '0',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WeatherDataTmpl0000001'
;

ALTER TABLE `WikiMaster`
  MODIFY `groupToEditPages` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '2',
  MODIFY `groupToAdminister` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3',
  MODIFY `richEditor` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'PBrichedit000000000002',
  MODIFY `frontPageTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiFrontTmpl000000001',
  MODIFY `pageTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiPageTmpl0000000001',
  MODIFY `pageEditTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiPageEditTmpl000001',
  MODIFY `recentChangesTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiRCTmpl000000000001',
  MODIFY `mostPopularTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiMPTmpl000000000001',
  MODIFY `pageHistoryTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiPHTmpl000000000001',
  MODIFY `searchTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiSearchTmpl00000001',
  MODIFY `recentChangesCount` int(11) NOT NULL DEFAULT '50',
  MODIFY `recentChangesCountFront` int(11) NOT NULL DEFAULT '10',
  MODIFY `mostPopularCount` int(11) NOT NULL DEFAULT '50',
  MODIFY `mostPopularCountFront` int(11) NOT NULL DEFAULT '10',
  MODIFY `thumbnailSize` int(11) NOT NULL DEFAULT '0',
  MODIFY `maxImageSize` int(11) NOT NULL DEFAULT '0',
  MODIFY `approvalWorkflow` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'pbworkflow000000000003',
  MODIFY `byKeywordTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'WikiKeyword00000000001',
  MODIFY `allowAttachments` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `WikiPage`
  MODIFY `views` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `isProtected` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `Workflow`
  MODIFY `title` varchar(255) NOT NULL DEFAULT 'Untitled',
  MODIFY `enabled` int(11) NOT NULL DEFAULT '0',
  MODIFY `type` varchar(255) NOT NULL DEFAULT 'None',
  MODIFY `mode` varchar(20) NOT NULL DEFAULT 'parallel'
;

ALTER TABLE `WorkflowActivity`
  MODIFY `title` varchar(255) NOT NULL DEFAULT 'Untitled',
  MODIFY `sequenceNumber` int(11) NOT NULL DEFAULT '1'
;

ALTER TABLE `WorkflowInstance`
  MODIFY `priority` int(11) NOT NULL DEFAULT '2'
;

ALTER TABLE `WorkflowSchedule`
  MODIFY `title` varchar(255) NOT NULL DEFAULT 'Untitled',
  MODIFY `enabled` int(11) NOT NULL DEFAULT '0',
  MODIFY `runOnce` int(11) NOT NULL DEFAULT '0',
  MODIFY `minuteOfHour` varchar(25) NOT NULL DEFAULT '0',
  MODIFY `hourOfDay` varchar(25) NOT NULL DEFAULT '*',
  MODIFY `dayOfMonth` varchar(25) NOT NULL DEFAULT '*',
  MODIFY `monthOfYear` varchar(25) NOT NULL DEFAULT '*',
  MODIFY `dayOfWeek` varchar(25) NOT NULL DEFAULT '*',
  MODIFY `priority` int(11) NOT NULL DEFAULT '2'
;

ALTER TABLE `ZipArchiveAsset`
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `showPage` varchar(255) NOT NULL DEFAULT 'index.html'
;

ALTER TABLE `adSpace`
  MODIFY `costPerImpression` decimal(11,2) NOT NULL DEFAULT '0.00',
  MODIFY `minimumImpressions` int(11) NOT NULL DEFAULT '1000',
  MODIFY `costPerClick` decimal(11,2) NOT NULL DEFAULT '0.00',
  MODIFY `minimumClicks` int(11) NOT NULL DEFAULT '1000',
  MODIFY `width` int(11) NOT NULL DEFAULT '468',
  MODIFY `height` int(11) NOT NULL DEFAULT '60',
  MODIFY `groupToPurchase` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3'
;

ALTER TABLE `addressBook`
  MODIFY `sessionId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `advertisement`
  MODIFY `isActive` int(11) NOT NULL DEFAULT '0',
  MODIFY `type` varchar(15) NOT NULL DEFAULT 'text',
  MODIFY `storageId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `borderColor` varchar(7) NOT NULL DEFAULT '#000000',
  MODIFY `textColor` varchar(7) NOT NULL DEFAULT '#000000',
  MODIFY `backgroundColor` varchar(7) NOT NULL DEFAULT '#ffffff',
  MODIFY `clicks` int(11) NOT NULL DEFAULT '0',
  MODIFY `clicksBought` int(11) NOT NULL DEFAULT '0',
  MODIFY `impressions` int(11) NOT NULL DEFAULT '0',
  MODIFY `impressionsBought` int(11) NOT NULL DEFAULT '0',
  MODIFY `priority` int(11) NOT NULL DEFAULT '0',
  MODIFY `nextInPriority` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `asset`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `parentId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `lineage` varchar(255) NOT NULL DEFAULT '',
  MODIFY `state` varchar(35) NOT NULL DEFAULT '',
  MODIFY `className` varchar(255) NOT NULL DEFAULT '',
  MODIFY `creationDate` bigint(20) NOT NULL DEFAULT '997995720',
  MODIFY `createdBy` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3',
  MODIFY `stateChanged` varchar(22) NOT NULL DEFAULT '997995720',
  MODIFY `stateChangedBy` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '3',
  MODIFY `isLockedBy` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `isSystem` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `assetData`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `revisedBy` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `tagId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `status` varchar(35) NOT NULL DEFAULT 'pending',
  MODIFY `title` varchar(255) NOT NULL DEFAULT 'untitled',
  MODIFY `menuTitle` varchar(255) NOT NULL DEFAULT 'untitled',
  MODIFY `url` varchar(255) NOT NULL DEFAULT '',
  MODIFY `ownerUserId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `groupIdView` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `groupIdEdit` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `newWindow` int(11) NOT NULL DEFAULT '0',
  MODIFY `isHidden` int(11) NOT NULL DEFAULT '0',
  MODIFY `isPackage` int(11) NOT NULL DEFAULT '0',
  MODIFY `isPrototype` int(11) NOT NULL DEFAULT '0',
  MODIFY `encryptPage` int(11) NOT NULL DEFAULT '0',
  MODIFY `assetSize` int(11) NOT NULL DEFAULT '0',
  MODIFY `skipNotification` int(11) NOT NULL DEFAULT '0',
  MODIFY `isExportable` int(11) NOT NULL DEFAULT '1',
  MODIFY `inheritUrlFromParent` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `assetHistory`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `dateStamp` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `assetIndex`
  MODIFY `ownerUserId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `groupIdView` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `groupIdEdit` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `isPublic` int(11) NOT NULL DEFAULT '1'
;

ALTER TABLE `assetVersionTag`
  MODIFY `tagId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `name` varchar(255) NOT NULL DEFAULT '',
  MODIFY `isCommitted` int(11) NOT NULL DEFAULT '0',
  MODIFY `creationDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `createdBy` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `commitDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `committedBy` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `isLocked` int(11) NOT NULL DEFAULT '0',
  MODIFY `lockedBy` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `groupToUse` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `workflowId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `workflowInstanceId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `authentication`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `authMethod` varchar(30) NOT NULL DEFAULT '',
  MODIFY `fieldName` varchar(128) NOT NULL DEFAULT ''
;

ALTER TABLE `cart`
  MODIFY `shippingAddressId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `shipperId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `couponId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `cartItem`
  MODIFY `shippingAddressId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `quantity` int(11) NOT NULL DEFAULT '1'
;

ALTER TABLE `databaseLink`
  MODIFY `databaseLinkId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `allowMacroAccess` int(11) NOT NULL DEFAULT '0',
  MODIFY `additionalParameters` varchar(255) NOT NULL DEFAULT ''
;

ALTER TABLE `donation`
  MODIFY `defaultPrice` float NOT NULL DEFAULT '100'
;

ALTER TABLE `groupGroupings`
  MODIFY `groupId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `groupings`
  MODIFY `groupId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `expireDate` bigint(20) NOT NULL DEFAULT '2114402400',
  MODIFY `groupAdmin` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `groups`
  MODIFY `groupId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `expireOffset` int(11) NOT NULL DEFAULT '314496000',
  MODIFY `karmaThreshold` int(11) NOT NULL DEFAULT '1000000000',
  MODIFY `dateCreated` int(11) NOT NULL DEFAULT '997938000',
  MODIFY `lastUpdated` int(11) NOT NULL DEFAULT '997938000',
  MODIFY `deleteOffset` int(11) NOT NULL DEFAULT '14',
  MODIFY `expireNotifyOffset` int(11) NOT NULL DEFAULT '-14',
  MODIFY `expireNotify` int(11) NOT NULL DEFAULT '0',
  MODIFY `autoAdd` int(11) NOT NULL DEFAULT '0',
  MODIFY `autoDelete` int(11) NOT NULL DEFAULT '0',
  MODIFY `databaseLinkId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `groupCacheTimeout` int(11) NOT NULL DEFAULT '3600',
  MODIFY `isEditable` int(11) NOT NULL DEFAULT '1',
  MODIFY `showInForms` int(11) NOT NULL DEFAULT '1',
  MODIFY `ldapLinkId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `imageColor`
  MODIFY `name` varchar(255) NOT NULL DEFAULT 'untitled',
  MODIFY `fillTriplet` char(7) NOT NULL DEFAULT '#000000',
  MODIFY `fillAlpha` char(2) NOT NULL DEFAULT '00',
  MODIFY `strokeTriplet` char(7) NOT NULL DEFAULT '#000000',
  MODIFY `strokeAlpha` char(2) NOT NULL DEFAULT '00'
;

ALTER TABLE `imagePalette`
  MODIFY `name` varchar(255) NOT NULL DEFAULT 'untitled'
;

ALTER TABLE `inbox`
  MODIFY `status` varchar(15) NOT NULL DEFAULT 'pending',
  MODIFY `completedBy` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `groupId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `subject` varchar(255) NOT NULL DEFAULT 'No Subject',
  MODIFY `sentBy` varchar(22) NOT NULL DEFAULT '3'
;

ALTER TABLE `incrementer`
  MODIFY `incrementerId` varchar(50) NOT NULL DEFAULT '',
  MODIFY `nextValue` int(11) NOT NULL DEFAULT '1'
;

ALTER TABLE `karmaLog`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `amount` int(11) NOT NULL DEFAULT '1'
;

ALTER TABLE `ldapLink`
  MODIFY `ldapLinkId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `ldapLinkName` varchar(255) NOT NULL DEFAULT '',
  MODIFY `ldapUrl` varchar(255) NOT NULL DEFAULT '',
  MODIFY `connectDn` varchar(255) NOT NULL DEFAULT '',
  MODIFY `identifier` varchar(255) NOT NULL DEFAULT '',
  MODIFY `ldapAccountTemplate` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `ldapCreateAccountTemplate` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `ldapLoginTemplate` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `mailQueue`
  MODIFY `toGroup` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `metaData_properties`
  MODIFY `fieldId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `fieldName` varchar(100) NOT NULL DEFAULT ''
;

ALTER TABLE `metaData_values`
  MODIFY `fieldId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `passiveProfileAOI`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `fieldId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `value` varchar(100) NOT NULL DEFAULT ''
;

ALTER TABLE `passiveProfileLog`
  MODIFY `passiveProfileLogId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `sessionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `dateOfEntry` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `redirect`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;

ALTER TABLE `replacements`
  MODIFY `replacementId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `search`
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `searchRoot` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'PBasset000000000000001',
  MODIFY `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'PBtmpl0000000000000200',
  MODIFY `useContainers` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `settings`
  MODIFY `name` varchar(255) NOT NULL DEFAULT ''
;

ALTER TABLE `shopCredit`
  MODIFY `amount` float NOT NULL DEFAULT '0'
;

ALTER TABLE `sku`
  MODIFY `vendorId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'defaultvendor000000000',
  MODIFY `displayTitle` tinyint(1) NOT NULL DEFAULT '1',
  MODIFY `overrideTaxRate` tinyint(1) NOT NULL DEFAULT '0',
  MODIFY `taxRateOverride` float NOT NULL DEFAULT '0'
;

ALTER TABLE `snippet`
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `processAsTemplate` int(11) NOT NULL DEFAULT '0',
  MODIFY `mimeType` varchar(50) NOT NULL DEFAULT 'text/html',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `cacheTimeout` int(11) NOT NULL DEFAULT '3600'
;

ALTER TABLE `storageTranslation`
  MODIFY `guidValue` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `hexValue` varchar(32) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `subscriptionCode`
  MODIFY `batchId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `code` varchar(64) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `status` varchar(10) NOT NULL DEFAULT 'Unused',
  MODIFY `dateCreated` int(11) NOT NULL DEFAULT '0',
  MODIFY `dateUsed` int(11) NOT NULL DEFAULT '0',
  MODIFY `expires` int(11) NOT NULL DEFAULT '0',
  MODIFY `usedBy` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `subscriptionCodeBatch`
  MODIFY `batchId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `subscriptionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `subscriptionCodeSubscriptions`
  MODIFY `code` varchar(64) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `subscriptionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `tax`
  MODIFY `taxRate` float NOT NULL DEFAULT '0'
;

ALTER TABLE `template`
  MODIFY `namespace` varchar(35) NOT NULL DEFAULT 'Page',
  MODIFY `isEditable` int(11) NOT NULL DEFAULT '1',
  MODIFY `showInForms` int(11) NOT NULL DEFAULT '1',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0',
  MODIFY `parser` varchar(255) NOT NULL DEFAULT 'WebGUI::Asset::Template::HTMLTemplate'
;

ALTER TABLE `transaction`
  MODIFY `originatingTransactionId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `isSuccessful` tinyint(1) NOT NULL DEFAULT '0',
  MODIFY `shippingAddressId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `shippingDriverId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `paymentAddressId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `paymentDriverId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `transactionItem`
  MODIFY `shippingAddressId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `orderStatus` varchar(35) NOT NULL DEFAULT 'NotShipped',
  MODIFY `quantity` int(11) NOT NULL DEFAULT '1',
  MODIFY `vendorId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT 'defaultvendor000000000'
;

ALTER TABLE `userInvitations`
  MODIFY `newUserId` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `userLoginLog`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `userProfileCategory`
  MODIFY `profileCategoryId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `label` varchar(255) NOT NULL DEFAULT 'Undefined',
  MODIFY `sequenceNumber` int(11) NOT NULL DEFAULT '1',
  MODIFY `visible` int(11) NOT NULL DEFAULT '1',
  MODIFY `editable` int(11) NOT NULL DEFAULT '1',
  MODIFY `protected` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `userProfileData`
  MODIFY `photo` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL,
  MODIFY `avatar` varchar(22) character set utf8 collate utf8_bin DEFAULT NULL
;

ALTER TABLE `userProfileField`
  MODIFY `fieldName` varchar(128) NOT NULL DEFAULT '',
  MODIFY `label` varchar(255) NOT NULL DEFAULT 'Undefined',
  MODIFY `visible` int(11) NOT NULL DEFAULT '0',
  MODIFY `required` int(11) NOT NULL DEFAULT '0',
  MODIFY `fieldType` varchar(128) NOT NULL DEFAULT 'text',
  MODIFY `sequenceNumber` int(11) NOT NULL DEFAULT '1',
  MODIFY `profileCategoryId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `protected` int(11) NOT NULL DEFAULT '0',
  MODIFY `editable` int(11) NOT NULL DEFAULT '1',
  MODIFY `showAtRegistration` int(11) NOT NULL DEFAULT '0',
  MODIFY `requiredForPasswordRecovery` int(11) NOT NULL DEFAULT '0'
;

ALTER TABLE `userSession`
  MODIFY `sessionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `adminOn` int(11) NOT NULL DEFAULT '0',
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `userSessionScratch`
  MODIFY `sessionId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `name` varchar(255) NOT NULL DEFAULT ''
;

ALTER TABLE `users`
  MODIFY `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `authMethod` varchar(30) NOT NULL DEFAULT 'WebGUI',
  MODIFY `dateCreated` int(11) NOT NULL DEFAULT '1019867418',
  MODIFY `lastUpdated` int(11) NOT NULL DEFAULT '1019867418',
  MODIFY `karma` int(11) NOT NULL DEFAULT '0',
  MODIFY `status` varchar(35) NOT NULL DEFAULT 'Active',
  MODIFY `referringAffiliate` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `friendsGroup` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT ''
;

ALTER TABLE `wobject`
  MODIFY `displayTitle` int(11) NOT NULL DEFAULT '1',
  MODIFY `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `styleTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `printableStyleTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL DEFAULT '',
  MODIFY `revisionDate` bigint(20) NOT NULL DEFAULT '0'
;
END_SQL
    my @stmts = split /;/, $sql; # this isn't safe in general, but I know it will be fine here.
    for my $stmt (@stmts) {
        $stmt =~ s/^\s+//;
        $stmt =~ s/\s+$//;
        next unless $stmt;
        $session->db->write($stmt);
    }
    print " Done.\n" unless $quiet;
}

# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    print "Importing package: $file..." unless $quiet;
    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage );

    # Make the package not a package anymore
    $package->update({ isPackage => 0 });

    print "Done\n" unless $quiet;
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
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
    updateTemplates($session);
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
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


