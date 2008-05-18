#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;
use WebGUI::DateTime;
use WebGUI::Asset::Sku::Product;
use WebGUI::Workflow;
use WebGUI::User;
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
updateUsersOfProductMacro($session);
addCaptchaToDataForm( $session );
addArchiveEnabledToCollaboration( $session );
addShelf( $session );
addCoupon( $session );
addVendors($session);
modifyThingyPossibleValues( $session );
removeLegacyTable($session);

finish($session); # this line required

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
            name varchar(255)
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

    my $activity    = $session->config->get( "workflowActivities" );
    push @{ $activity->{"None"} }, 'WebGUI::Workflow::Activity::PurgeOldInboxMessages';
    $session->config->set( "workflowActivities", $activity );

    print "DONE!\n" unless $quiet;
}

#-------------------------------------------------
sub upgradeEMS {
	my $session = shift;
	print "\tUpgrading Event Manager\n" unless ($quiet);
	my $db = $session->db;
	print "\t\tGetting rid of old templates.\n" unless ($quiet);
	foreach my $namespace (qw(EventManagementSystem EventManagementSystem_checkout EventManagementSystem_managePurchas EventManagementSystem_viewPurchase EventManagementSystem_search emsbadgeprint emsticketprint)) {
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
                description         => $badgeData->{description},
                sku                 => $badgeData->{sku},
                price               => $badgeData->{price},
                seatsAvailable      => $badgeData->{maximumAttendees},
                });
            $oldBadges{$badgeData->{productId}} = $badge->getId;
            $newBadges{$badge->getId} = $badgeData->{productId};
        }
    	print "\t\t\tMigrating old tickets for $emsId.\n" unless ($quiet);
        my %metaFields = $db->buildHash("select fieldId,label from EventManagementSystem_metaField where assetId=? order by sequenceNumber",[$emsId]);
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
    	print "\t\t\tMigrating old registrants for $emsId.\n" unless ($quiet);
        my $registrantResults = $db->read("select * from EventManagementSystem_badges where assetId=?",[$emsId]);
        while (my $registrantData = $registrantResults->hashRef) {
            $db->setRow("EMSRegistrant","badgeId",{
                badgeId             => "new",
                userId              => $registrantData->{userId},
                badgeNumber         => $registrantData->{badgeId},
                badgeAssetId        => $oldBadges{$registrantData->{badgeId}},
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
    	print "\t\t\tMigrating old registrant tickets and registrant ribbons for $emsId.\n" unless ($quiet);
        my $regticResults = $db->read("select * from EventManagementSystem_registrations where assetId=?",[$emsId]);
        while (my $registrantData = $regticResults->hashRef) {
            my $id = $oldTickets{$registrantData->{productId}};
            if ($id ne "") {
                $db->write("insert into EMSRegistrantTicket (badgeId,ticketAssetId,purchaseComplete) values (?,?,1)",
                    [$registrantData->{badgeId}, $id]);
            }
            else {
                my $id = $oldRibbons{$registrantData->{productId}};
                if ($id ne "") {
                    $db->write("insert into EMSRegistrantRibbon (badgeId,ribbonAssetId) values (?,?)",
                        [$registrantData->{badgeId}, $id]);
                }
            }
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
		statusMessage varchar(100),
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
        isRecurring boolean
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
		shippingStatus varchar(35) not null default 'NotShipped',
		shippingDate datetime,
		quantity int not null default 1,
		price float,
        vendorId varchar(22) binary not null default 'defaultvendor000000000',
		index transactionId (transactionId),
        index vendorId (vendorId)
	)");
    $session->setting->add('shopMyPurchasesTemplateId','');
    $session->setting->add('shopMyPurchaseDetailTemplateId','');
    my $transactionResults = $db->read("select * from oldtransaction order by initDate");
    while (my $oldTranny = $transactionResults->hashRef) {
        my $date = WebGUI::DateTime->new($session, $oldTranny->{initDate});
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
            dateOfPurchase      => $date->toDatabase,
            isRecurring         => $oldTranny->{recurring},
            }, $oldTranny->{transactionId});
            my $itemResults = $db->read("select * from oldtransactionitem where transactionId=?",[$oldTranny->{transactionId}]);
            while (my $oldItem = $itemResults->hashRef) {
                $db->setRow("transactionItem","itemId",{
                    itemId                  => "new",
                    transactionId           => $oldItem->{transactionId},
                    configuredTitle         => $oldItem->{itemName},
                    options                 => '{}',
                    shippingTrackingNumber  => $oldTranny->{trackingNumber},
                    shippingStatus          => $oldTranny->{shippingStatus},
                    shippingDate            => $oldTranny->{completionDate},
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
        $product->setCollateral('variantsJSON', 'new', {
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
    my $productFolder = WebGUI::Asset->getRoot($session)->addChild({
        className   => 'WebGUI::Asset::Wobject::Folder',
        title       => 'Converted products from Commerce',
        url         => 'converted_products',
        isHidden    => 1,
        groupIdView => 14,
        groupIdEdit => 14,
    });
    while (my $productData = $productSth->hashRef) {
        my $sku = $productFolder->addChild({
            className   => 'WebGUI::Asset::Sku::Product',
            title       => $productData->{title},
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
            $shortdesc = substr $shortdesc, 0, 30;

            my $variant;
            $variant->{varSku}    = $variantData->{sku};
            $variant->{price}     = $variantData->{price};
            $variant->{weight}    = $variantData->{weight};
            $variant->{quantity}  = $variantData->{available};
            $variant->{shortdesc} = $shortdesc;
            $sku->setCollateral('variantsJSON', 'new', $variant);
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
    unlink '../../lib/WebGUI/Asset/Wobject/Product.pm';

    rmtree '../../lib/WebGUI/Commerce.pm';
    unlink '../../lib/WebGUI/Product.pm';
    unlink '../../lib/WebGUI/Subscription.pm';

    unlink '../../lib/WebGUI/Macro/Product.pm';
    unlink '../../lib/WebGUI/Help/Macro_Product.pm';
    unlink '../../lib/WebGUI/i18n/English/Macro_Product.pm';

    unlink '../../lib/WebGUI/Operation/ProductManager.pm';
    unlink '../../lib/WebGUI/Help/ProductManager.pm';
    unlink '../../lib/WebGUI/i18n/English/ProductManager.pm';

    unlink '../../lib/WebGUI/Operation/Commerce.pm';
    unlink '../../lib/WebGUI/Help/Commerce.pm';
    unlink '../../lib/WebGUI/i18n/English/Commerce.pm';

    unlink '../../lib/WebGUI/Operation/Subscription.pm';
    unlink '../../lib/WebGUI/Help/Subscription.pm';
    unlink '../../lib/WebGUI/i18n/English/Subscription.pm';

    #Disable the Product macro in the config file.  You can't use the convenience method
    #deleteFromHash since the macro name is in the value, not the key.
    my %macros = %{ $session->config->get('macros') };
    foreach (my ($key, $value) = each %macros) {
        delete $macros{$key} if $value eq 'Product';
    }
    $session->config->set('macros', \%macros);
    return 1;
}


#-------------------------------------------------
sub updateUsersOfProductMacro {
	my $session = shift;
	print "\tUpdate assets which might be using the Product macro.\n" unless ($quiet);
    my $wobjSth = $session->db->read('select assetId, revisionDate, description from wobject order by assetId, revisionDate');
    my $fixed   = $session->db->prepare('update wobject set description=? where  assetId=? and revisionDate=?');
    while (my $wobject = $wobjSth->hashRef) {
        while ($wobject->{description} =~ m/\^Product\('? ([^),']+) /xg) {
            #printf "\t\tWorking on %s\n", $wobject->{assetId};
            my $identifier = $1;  ##If this is a product sku, need to look up by productId;
            #printf "\t\t\tFound argument of %s\n", $identifier;
            my $assetId = $session->db->quickScalar('select distinct(assetId) from sku where sku=?',[$identifier]);
            #printf "\t\t\tsku assetId: %s\n", $assetId;
            my $productAssetId = $assetId ? $assetId : $identifier;
            $wobject->{description} =~ s/\^Product\( [^)]+ \)/^AssetProxy($productAssetId)/x;
            #printf "\t\t\tUpdated description to%s\n", $wobject->{description};
            $fixed->execute([ $wobject->{description}, $wobject->{assetId}, $wobject->{revisionDate}, ]);
        }
    }
    $wobjSth->finish;
    $fixed->finish;

    my $snipSth = $session->db->read('select assetId, revisionDate, snippet from snippet order by assetId, revisionDate');
       $fixed   = $session->db->prepare('update snippet set snippet=? where  assetId=? and revisionDate=?');
    while (my $snippet = $snipSth->hashRef) {
        while ($snippet->{snippet} =~ m/\^Product\('? ([^),']+) /xg) {
            #printf "\t\tWorking on %s\n", $snippet->{assetId};
            my $identifier = $1;  ##If this is a product sku, need to look up by productId;
            #printf "\t\t\tFound argument of %s\n", $identifier;
            my $assetId = $session->db->quickScalar('select distinct(assetId) from sku where sku=?',[$identifier]);
            #printf "\t\t\tsku assetId: %s\n", $assetId;
            my $productAssetId = $assetId ? $assetId : $identifier;
            $snippet->{snippet} =~ s/\^Product\( [^)]+ \)/^AssetProxy($productAssetId)/x;
            #printf "\t\t\tUpdated snippet to%s\n", $snippet->{snippet};
            $fixed->execute([ $snippet->{snippet}, $snippet->{assetId}, $snippet->{revisionDate}, ]);
        }
    }
    $snipSth->finish;
    $fixed->finish;

    my $tempSth = $session->db->read('select assetId, revisionDate, template from template order by assetId, revisionDate');
       $fixed   = $session->db->prepare('update template set template=? where  assetId=? and revisionDate=?');
    while (my $template = $tempSth->hashRef) {
        while ($template->{template} =~ m/\^Product\('? ([^),']+) /xg) {
            #printf "\t\tWorking on %s\n", $template->{assetId};
            my $identifier = $1;  ##If this is a product sku, need to look up by productId;
            #printf "\t\t\tFound argument of %s\n", $identifier;
            my $assetId = $session->db->quickScalar('select distinct(assetId) from sku where sku=?',[$identifier]);
            #printf "\t\t\tsku assetId: %s\n", $assetId;
            my $productAssetId = $assetId ? $assetId : $identifier;
            $template->{template} =~ s/\^Product\( [^)]+ \)/^AssetProxy($productAssetId)/x;
            #printf "\t\t\tUpdated template to%s\n", $template->{template};
            $fixed->execute([ $template->{template}, $template->{assetId}, $template->{revisionDate}, ]);
        }
    }
    $tempSth->finish;
    $fixed->finish;

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
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage );

    # Make the package not a package anymore
    $package->update({ isPackage => 0 });
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open("../..",$configFile);
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


