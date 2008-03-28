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


my $toVersion = '7.5.9';
my $quiet; # this line required


my $session = start(); # this line required

ensureUTF8($session);
addRichEditInlinePopup($session);
updateRichEditorButtons($session);
setPMFloatingDuration($session);

finish($session); # this line required


#----------------------------------------------------------------------------
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#----------------------------------------------------------------------------
sub setPMFloatingDuration {
    my $session = shift;
    print "\tChanging Project manager to use floating numbers for duration... " unless $quiet;
    $session->db->write('ALTER TABLE `PM_task` MODIFY `duration` FLOAT');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRichEditInlinePopup {
    my $session = shift;
    print "\tAdding inline popup column to Rich editor... " unless $quiet;
    $session->db->write("ALTER TABLE `RichEdit` ADD COLUMN `inlinePopups` INT(11) NOT NULL DEFAULT 0");
    print "Done!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updateRichEditorButtons {
    my $session = shift;
    print "\tUpdate Rich Editor buttons... " unless $quiet;
    my $editors = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], {
        includeOnlyClasses  => ['WebGUI::Asset::RichEdit'],
        returnObjects       => 1,
    });
    for my $editor (@$editors) {
        my %prop;
        for my $toolbar (qw(toolbarRow1 toolbarRow2 toolbarRow3)) {
            my $current = $editor->get($toolbar);
            $current =~ s/^insertImage$/wginsertimage/m;
            $current =~ s/^pagetree$/wgpagetree/m;
            $current =~ s/^collateral$/wgmacro/m;
            if ($current ne $editor->get($toolbar)) {
                $prop{$toolbar} = $current;
            }
        }
        if (%prop) {
            $editor->addRevision(\%prop);
        }
    }
    print "Done.\n" unless $quiet;

}

#----------------------------------------------------------------------------
sub ensureUTF8 {
    my $session = shift;
    print "\tConverting all tables to UTF-8... " unless $quiet;
    my @tables = qw(
        Article
        Calendar Calendar_feeds
        Collaboration
        Dashboard
        DataForm DataForm_entry DataForm_entryData DataForm_field DataForm_tab
        Event
        EventManagementSystem EventManagementSystem_badges EventManagementSystem_discountPasses
        EventManagementSystem_metaData EventManagementSystem_metaField EventManagementSystem_prerequisiteEvents
        EventManagementSystem_prerequisites EventManagementSystem_products EventManagementSystem_purchases
        EventManagementSystem_registrations EventManagementSystem_sessionPurchaseRef
        Event_recur Event_relatedlink
        FileAsset
        Folder
        Gallery GalleryAlbum GalleryFile GalleryFile_comment
        HttpProxy
        ITransact_recurringStatus
        ImageAsset
        InOutBoard InOutBoard_delegates InOutBoard_status InOutBoard_statusLog
        Layout
        Matrix Matrix_field Matrix_listing Matrix_listingData Matrix_rating Matrix_ratingSummary
        MessageBoard
        MultiSearch
        Navigation
        Newsletter Newsletter_subscriptions
        PM_project PM_task PM_taskResource PM_wobject
        Photo Photo_rating
        Poll Poll_answer
        Post Post_rating
        Product Product_accessory Product_benefit Product_feature Product_related Product_specification
        RSSCapable RSSFromParent
        RichEdit
        SQLForm SQLForm_fieldDefinitions SQLForm_fieldOrder SQLForm_fieldTypes SQLForm_regexes
        SQLReport
        Shortcut Shortcut_overrides
        StockData
        Survey Survey_answer Survey_question Survey_questionResponse Survey_response Survey_section
        SyndicatedContent
        TT_projectList TT_projectResourceList TT_projectTasks TT_report TT_timeEntry TT_wobject
        Thingy Thingy_fields Thingy_things
        Thread Thread_read
        WSClient
        WeatherData
        WikiMaster WikiPage
        Workflow WorkflowActivity WorkflowActivityData WorkflowInstance WorkflowInstanceScratch WorkflowSchedule
        ZipArchiveAsset
        adSpace
        advertisement
        asset assetData assetHistory assetIndex assetKeyword assetVersionTag
        authentication
        cache
        commerceSalesTax commerceSettings
        databaseLink
        friendInvitations
        groupGroupings groupings groups
        imageColor imageFont imagePalette imagePaletteColors
        inbox
        incrementer
        karmaLog
        ldapLink
        mailQueue
        metaData_properties metaData_values
        passiveProfileAOI passiveProfileLog
        productParameterOptions productParameters productVariants products
        redirect
        replacements
        search
        settings
        shoppingCart
        snippet
        storageTranslation
        subscription subscriptionCode subscriptionCodeBatch subscriptionCodeSubscriptions
        template
        transaction transactionItem
        userInvitations
        userLoginLog
        userProfileCategory userProfileData userProfileField
        userSession userSessionScratch
        users
        webguiVersion
        wgFieldUserData
        wobject
    );
    for my $table (@tables) {
        $session->db->write(
            "ALTER TABLE `$table` CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin"
        );
    }
    # and here's our code
    print "Done!\n" unless $quiet;
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

