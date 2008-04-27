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
use File::Find;
use File::Spec;

my $toVersion = '7.5.11';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
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
addCaptchaToDataForm( $session );

finish($session); # this line required

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
	$session->config->addToArray("workflowActivities/None","WebGUI::Workflow::Activity::ExpireEmsCartItems");
	
	print "\t\tMigrating old EMS data.\n" unless ($quiet);
	#$db->write("alter table EventManagementSystem_metaData rename EMSEventMetaData");

}

#-------------------------------------------------
sub convertTransactionLog {
	my $session = shift;
	print "\tInstalling transaction log.\n" unless ($quiet);
	$session->db->write("alter table transaction rename oldtransaction");
	$session->db->write("alter table transactionItem rename oldtransactionitem");
    $session->db->write("create table transaction (
        transactionId varchar(22) binary not null primary key,
        isSuccessful bool not null default 0,
		orderNumber int not null auto_increment unique,
		transactionCode varchar(100),
		statusCode varchar(35),
		statusMessage varchar(100),
		userId varchar(22) binary not null,
		username varchar(35) not null,
		amount float,
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
		dateOfPurchase datetime
    )");
	$session->db->write("create table transactionItem (
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
		index transactionId (transactionId)
	)");
    $session->setting->add('shopMyPurchasesTemplateId','');
    $session->setting->add('shopMyPurchaseDetailTemplateId','');
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
        salesAgentId varchar(22) binary,
        displayTitle bool not null default 1,
        overrideTaxRate bool not null default 0,
        taxRateOverride float not null default 0.00,
        primary key (assetId, revisionDate),
        index sku (sku),
        index salesAgentId (salesAgentId)
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
	print "\tSet up the default payment dirvers.\n" unless ($quiet);
	# and here's our code
    $session->config->delete('paymentPlugins');
    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::Cash');
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
            $product->{productNumber},
            $product->{description},
            $product->{displayTitle},
        ]);
        $rmWobject->execute([$product->{assetId}, $product->{revisionDate}]);
    }
    $fromWobject->finish;
    $toSku->finish;
    $rmWobject->finish;
    $session->db->write(q!update asset set className='WebGUI::Asset::Sku::Product' where className='WebGUI::Asset::Wobject::Product'!);
    ## Remove productNumber from Product;
	$session->db->write("alter table Product drop column productNumber");
    ## Update config file, deleting Wobject::Product and adding Sku::Product
    $session->config->deleteFromArray('assets', 'WebGUI::Asset::Wobject::Product');
    $session->config->addToArray('assets', 'WebGUI::Asset::Sku::Product');
    unlink '../../lib/WebGUI/Asset/Wobject/Product.pm';
    return;
}

#-------------------------------------------------
sub mergeProductsWithCommerce {
	my $session = shift;
	print "\tMerge old Commerce Products to new SKU based Products.\n" unless ($quiet);
    ## Add the parameter and variants columns
	$session->db->write("alter table Product add column parameters mediumtext");
	$session->db->write("alter table Product add column variants   mediumtext");
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


