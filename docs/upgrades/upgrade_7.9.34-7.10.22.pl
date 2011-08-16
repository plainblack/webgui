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


my $toVersion = "0.0.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
i18nForAddonsTitle($session);
addForkTable($session);
installForkCleanup($session);
addVersioningToMetadata($session);
installNewDashboardTables($session);
addStockDataCacheColumn($session);
addWeatherDataCacheColumn($session);
addLastModifiedByMacro($session);
addAutoPlayToCarousel( $session );
addProcessorDropdownToSnippet( $session );
addRichEditToCarousel($session);
alterAssetIndexTable($session);
reindexAllThingys($session);
WebGUI::AssetAspect::Installable::upgrade("WebGUI::Asset::MapPoint",$session);
addRenderThingDataMacro($session);
addAssetPropertyMacro($session);
createThingyDBColumns($session);
addAssetManagerSortPreferences($session);
addTicketLimitToBadgeGroup( $session );
addFormFieldMacroToConfig();
addWaitForConfirmationWorkflow($session);
addCreateUsersEnabledSetting($session);
addAuthorizePaymentDriver($session);
createAddressField($session);
addLinkedProfileAddress($session);

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
# This internationalizes the link text of the addons link in the adminconsole
sub i18nForAddonsTitle {
    my $session = shift;
    print "\tInternationalize the text of the addons link in the adminconsole... " unless $quiet;
    $session->config->set('adminConsole/addons',
        {
            icon    => "addons.png",
            uiLevel => 1,
            group   => "12",
            url     => "http://www.webgui.org/addons",
            title   => "^International(Addons title,WebGUI);"	
        }
    );
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Creates a new table for tracking background processes
sub addForkTable {
    my $session = shift;
    my $db      = $session->db;
    my $sth     = $db->dbh->table_info('', '', 'Fork', 'TABLE');
    return if ($sth->fetch);
    print "\tAdding Fork table..." unless $quiet;
    my $sql = q{
        CREATE TABLE Fork (
            id        CHAR(22),
            userId    CHAR(22),
            groupId   CHAR(22),
            status    LONGTEXT,
            error     TEXT,
            startTime BIGINT(20),
            endTime   BIGINT(20),
            finished  BOOLEAN DEFAULT FALSE,
            latch     BOOLEAN DEFAULT FALSE,

            PRIMARY KEY(id)
        );
    };
    $db->write($sql);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# install a workflow to clean up old background processes
sub installForkCleanup {
    my $session = shift;
    print "\tInstalling Fork Cleanup workflow..." unless $quiet;
    my $class = 'WebGUI::Workflow::Activity::RemoveOldForks';
    $session->config->addToArray('workflowActivities/None', $class);
    my $wf = WebGUI::Workflow->new($session, 'pbworkflow000000000001');
    my $a  = first { ref $_ eq $class } @{ $wf->getActivities };
    unless ($a) {
        $a = $wf->addActivity($class);
        $a->set(title => 'Remove Old Forks');
    };
    print "DONE!\n" unless $quiet;
}

sub addVersioningToMetadata {
    my $session = shift;
    print "\tAltering metadata tables for versioning..." unless $quiet;
    my $db = $session->db;
    $db->write(q{
        alter table metaData_values
            add column revisionDate bigint,
            drop primary key,
            add primary key (fieldId, assetId, revisionDate);
    });
    $db->write(q{
        create table metaData_classes (
            className char(255),
            fieldId   char(22)
        );
    });
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addLastModifiedByMacro {
    my $session = shift;
    print "\tAdd LastModifiedBy macro to the config file... " unless $quiet;
    # and here's our code
    $session->config->addToHash('macros', 'LastModifiedBy', 'LastModifiedBy');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub installNewDashboardTables {
    my $session = shift;
    print "\tInstall new Dashboard tables... " unless $quiet;
    $session->db->write(<<EOSQL);
CREATE TABLE IF NOT EXISTS Dashboard_dashlets (
    dashboardAssetId CHAR(22) BINARY,
    dashletAssetId   CHAR(22) BINARY,
    isStatic    BOOLEAN,
    isRequired  BOOLEAN,
    PRIMARY KEY (dashboardAssetId, dashletAssetId)
) TYPE=MyISAM CHARSET=utf8;
EOSQL
    $session->db->write(<<EOSQL);
CREATE TABLE IF NOT EXISTS Dashboard_userPrefs (
    dashboardAssetId CHAR(22) BINARY,
    dashletAssetId   CHAR(22) BINARY,
    userId           CHAR(22) BINARY,
    isMinimized    BOOLEAN,
    properties     LONGTEXT,
    PRIMARY KEY (dashboardAssetId, dashletAssetId, userId)
) TYPE=MyISAM CHARSET=utf8;
EOSQL
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addStockDataCacheColumn {
    my $session = shift;
    print "\tAdd cache column for the StockData asset... " unless $quiet;
    $session->db->write(<<EOSQL);
ALTER TABLE StockData ADD COLUMN cacheTimeout BIGINT
EOSQL
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addWeatherDataCacheColumn {
    my $session = shift;
    print "\tAdd cache column for the WeatherData asset... " unless $quiet;
    $session->db->write(<<EOSQL);
ALTER TABLE WeatherData ADD COLUMN cacheTimeout BIGINT
EOSQL
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add AutoPlay fields to the Carousel
sub addAutoPlayToCarousel {
    my $session = shift;
    print "\tAdding Auto Play to Carousel... " unless $quiet;
    $session->db->write(
        "ALTER TABLE Carousel ADD COLUMN autoPlay INT, ADD COLUMN autoPlayInterval INT"
    );
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addProcessorDropdownToSnippet {
    my $session = shift;
    my $db      = $session->db;
    print "\tUpdating the Snippet table to add templateProcessor option..."
        unless $quiet;

    my $rows = $db->buildArrayRefOfHashRefs(q{
        select assetId, revisionDate from snippet where processAsTemplate = 1
    });

    $db->write(q{
        alter table snippet
        drop column processAsTemplate,
        add column templateParser char(255)
    });

    my $default = $session->config->get('defaultTemplateParser');

    for my $row (@$rows) {
        $db->write(q{
            update snippet
            set templateParser = ?
            where assetId = ? and revisionDate = ?
        }, [ $default, $row->{assetId}, $row->{revisionDate} ]);
    }

    print "Done!\n";
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addRichEditToCarousel {
    my $session = shift;
    print "\tAdd RichEdit option to the Carousel... " unless $quiet;
    # and here's our code
    $session->db->write('ALTER TABLE Carousel ADD COLUMN richEditor CHAR(22) BINARY');
    $session->db->write(q!update Carousel set richEditor='PBrichedit000000000001'!);
    print "DONE!\n" unless $quiet;
}

sub addRenderThingDataMacro {
    my $session = shift;
    print "\tAdd the new RenderThingData macro to the site config... " unless $quiet;
    $session->config->addToHash('macros', 'RenderThingData', 'RenderThingData');
    print "DONE!\n" unless $quiet;
}

sub alterAssetIndexTable {
    my $session = shift;
    print "\tExtend the assetIndex table so we can search things other than assets... " unless $quiet;
    $session->db->write(<<EOSQL);
alter table assetIndex
    drop primary key,
    add column subId char(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
    add primary key (assetId, url)
EOSQL
    print "DONE!\n" unless $quiet;
}

sub reindexAllThingys {
    my $session = shift;
    print "\tReindex all Thingys... " unless $quiet;
    my $get_thingy = WebGUI::Asset::Wobject::Thingy->getIsa($session);
    THINGY: while (1) {
        my $thingy = eval { $get_thingy->() };
        next THINGY if Exception::Class->caught();
        last THINGY unless $thingy;
        $thingy->indexContent;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addAssetPropertyMacro {
    my $session = shift;
    my $c       = $session->config;
    my $hash    = $c->get('macros');
    unless (grep { $_ eq 'AssetProperty' } values %$hash) {
        print "\tAdding AssetProperty macro... " unless $quiet;
        $c->set('macros/AssetProperty' => 'AssetProperty');
        print "DONE!\n" unless $quiet;
    }
}

#----------------------------------------------------------------------------
# Creates new column in tables for Thingy_fields and Thingy_things
sub createThingyDBColumns {
    my $session = shift;
    print "\tAdding db. columns Thingy_fields.isUnique and Thingy_things.maxEntriesTotal.." unless $quiet;
    # and here's our code

    my %tfHash =  $session->db->quickHash("show columns from Thingy_fields where Field='isUnique'");
    my %ttHash =  $session->db->quickHash("show columns from Thingy_things where Field='maxEntriesTotal'");

    unless ( $tfHash{'Field'}) { $session->db->write("alter table Thingy_fields add isUnique int(1) default 0"); }
    unless ( $ttHash{'Field'}) { $session->db->write("alter table Thingy_things add maxEntriesTotal int default null"); }

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addAssetManagerSortPreferences {
    my $cn   = 'assetManagerSortColumn';
    my $on   = 'assetManagerSortDirection';
    unless (WebGUI::ProfileField->new($session, $cn)) {
        print 'Adding Asset Manager Sort Column profile field...'
            unless $quiet;

        WebGUI::ProfileField->create($session, $cn => {
            label =>
                "WebGUI::International::get('$cn label', 'Account_Profile')",
            protected      => 1,
            fieldType      => 'selectBox',
            dataDefault    => 'lineage',
            possibleValues => <<'VALUES',
{
    lineage      => WebGUI::International::get('rank',          'Asset'),
    title        => WebGUI::International::get(99,              'Asset'),
    className    => WebGUI::International::get('type',          'Asset'),
    revisionDate => WebGUI::International::get('revision date', 'Asset'),
    assetSize    => WebGUI::International::get('size',          'Asset'),
    lockedBy     => WebGUI::International::get('locked',        'Asset'),
}
VALUES
        }, 4);
        print "Done!\n" unless $quiet;
    }
    unless (WebGUI::ProfileField->new($session, $on)) {
        print 'Adding Asset Manager Sort Direction profile field...'
            unless $quiet;

        WebGUI::ProfileField->create($session, $on => {
            label =>
                "WebGUI::International::get('$on label', 'Account_Profile')",
            protected      => 1,
            fieldType      => 'selectBox',
            dataDefault    => 'asc',
            possibleValues => <<'VALUES',
{
    asc  => WebGUI::International::get('ascending',  'Account_Profile'),
    desc => WebGUI::International::get('descending', 'Account_Profile'),
}
VALUES
        }, 4);
        print "Done!\n" unless $quiet;
    }
}

#----------------------------------------------------------------------------
# Add a ticket limit to badges in a badge group
sub addTicketLimitToBadgeGroup {
    my $session = shift;
    print "\tAdd ticket limit to badge groups... " unless $quiet;
    # Make sure it hasn't been done already...
    my $columns = $session->db->buildHashRef('describe EMSBadgeGroup');
    use List::MoreUtils qw(any);
    if(! grep { /ticketsPerBadge/ } keys %{$columns}) {
        $session->db->write(q{
            ALTER TABLE EMSBadgeGroup ADD COLUMN `ticketsPerBadge` INTEGER
        });
    }
    print "DONE!\n" unless $quiet;
}

sub addFormFieldMacroToConfig {
    print "\tAdd FormField macro to config... " unless $quiet;
    $session->config->addToHash( 'macros', FormField => 'FormField' );
    print "DONE!\n" unless $quiet;
}    

#----------------------------------------------------------------------------
sub addWaitForConfirmationWorkflow {
    my $session = shift;
    my $c       = $session->config;
    my $exists  = $c->get('workflowActivities/WebGUI::User');
    my $class   = 'WebGUI::Workflow::Activity::WaitForUserConfirmation';
    unless (grep { $_ eq $class } @$exists) {
        print "Adding WaitForUserConfirmation workflow..." unless $quiet;
        $c->addToArray('workflowActivities/WebGUI::User' => $class);
        print "Done!\n" unless $quiet;
    }
}

#----------------------------------------------------------------------------
sub addCreateUsersEnabledSetting {
    my $session = shift;
    my $s       = $session->setting;
    my $name    = 'enableUsersAfterAnonymousRegistration';
    return if $s->has($name);
    print "Adding $name setting..." unless $quiet;
    $s->add($name => 1);
    print "Done!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the Authorize.net payment driver to each config file
sub addAuthorizePaymentDriver {
    my $session = shift;
    print "\tAdd the Authorize.net payment driver... " unless $quiet;
    # and here's our code
    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::CreditCard::AuthorizeNet');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addLinkedProfileAddress {
    my $session = shift;
    print "\tAdding linked profile addresses for existing users... " unless $quiet;

    my $users = $session->db->buildArrayRef( q{
        select userId from users where userId not in ('1','3')
    } );

    foreach my $userId (@$users) {
        #check to see if there is user profile information available
        my $u = WebGUI::User->new($session,$userId);
        #skip if user does not have any homeAddress fields filled in
        next unless (
            $u->profileField("homeAddress")
            || $u->profileField("homeCity")
            || $u->profileField("homeState")
            || $u->profileField("homeZip")
            || $u->profileField("homeCountry")
            || $u->profileField("homePhone")
        );

        #Get the address book for the user (one is created if it does not exist)
        my $addressBook = WebGUI::Shop::AddressBook->newByUserId($session,$userId);
        
        #Add the profile address for the user
        $addressBook->addAddress({
            label       => "Profile Address",
            firstName   => $u->profileField("firstName"),
            lastName    => $u->profileField("lastName"),
            address1    => $u->profileField("homeAddress"),
            city        => $u->profileField("homeCity"),
            state       => $u->profileField("homeState"),
            country     => $u->profileField("homeCountry"),
            code        => $u->profileField("homeZip"),
            phoneNumber => $u->profileField("homePhone"),
            email       => $u->profileField("email"),
            isProfile   => 1,
        });
    }

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub createAddressField {
    my $session = shift;

    #skip if field exists
    my $columns  = $session->db->buildArrayRef("show columns from address where Field='isProfile'");
    return if(scalar(@$columns));

    print "\tAdding profile link to Address... " unless $quiet;

    $session->db->write( q{
        alter table address add isProfile tinyint default 0
    } );

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
