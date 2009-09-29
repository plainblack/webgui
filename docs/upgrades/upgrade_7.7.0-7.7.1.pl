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


my $toVersion = '7.7.1';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
adSkuInstall($session);
addWelcomeMessageTemplateToSettings( $session );
addStatisticsCacheTimeoutToMatrix( $session );
removeOldSettings( $session );

#add Survey table
addSurveyQuestionTypes($session);

# image mods
addImageAnnotation($session);

# rss mods
addRssLimit($session);

finish($session); # this line required

# remove old settings that aren't used any more
sub removeOldSettings {
    my $session = shift;
    print "\tRemoving old, unused settings... " unless $quiet;
    my $setting = $session->setting;

    $setting->remove('commerceCheckoutCanceledTemplateId');
    $setting->remove('commerceConfirmCheckoutTemplateId');
    $setting->remove('commerceEnableSalesTax');
    $setting->remove('commercePaymentPlugin');
    $setting->remove('commercePurchaseHistoryTemplateId');
    $setting->remove('commerceSelectPaymentGatewayTemplateId');
    $setting->remove('commerceSelectShippingMethodTemplateId');
    $setting->remove('commerceSendDailyReportTo');
    $setting->remove('commerceViewShoppingCartTemplateId');

    print "Done.\n" unless $quiet;
}

sub addSurveyQuestionTypes{
    my $session = shift;
    print "\tAdding new survey table Survey_questionTypes... " unless $quiet;
    $session->db->write("
	CREATE TABLE `Survey_questionTypes` (
          `questionType` varchar(56) NOT NULL,
          `answers` text NOT NULL,
          PRIMARY KEY  (`questionType`))
	");
    $session->db->write(q{
    INSERT INTO `Survey_questionTypes` VALUES ('Scale',''),('Gender','Male,Female'),('Education','Elementary or some high school,High school/GED,Some college/vocational school,College graduate,Some graduate work,Master\\'s degree,Doctorate (of any type),Other degree (verbatim)'),('Importance','Not at all important,,,,,,,,,,Extremely important'),('Yes/No','Yes,No'),('Confidence','Not at all confident,,,,,,,,,,Extremely confident'),('Effectiveness','Not at all effective,,,,,,,,,,Extremely effective'),('Oppose/Support','Strongly oppose,,,,,,Strongly support'),('Certainty','Not at all certain,,,,,,,,,,Extremely certain'),('True/False','True,False'),('Concern','Not at all concerned,,,,,,,,,,Extremely concerned'),('Ideology','Strongly liberal,Liberal,Somewhat liberal,Middle of the road,Slightly conservative,Conservative,Strongly conservative'),('Security','Not at all secure,,,,,,,,,,Extremely secure'),('Risk','No risk,,,,,,,,,,Extreme risk'),('Agree/Disagree','Strongly disagree,,,,,,Strongly agree'),('Race','American Indian,Asian,Black,Hispanic,White non-Hispanic,Something else (verbatim)'),('Threat','No threat,,,,,,,,,,Extreme threat'),('Party','Democratic party,Republican party (or GOP),Independent party,Other party (verbatim)'),('Likelihood','Not at all likely,,,,,,,,,,Extremely likely'),('Multiple Choice',''),('Satisfaction','Not at all satisfied,,,,,,,,,,Extremely satisfied')
	});
    print "Done.\n" unless $quiet;
}

sub addWelcomeMessageTemplateToSettings {
    my $session = shift;
    print "\tAdding welcome message template to settings... " unless $quiet;

    $session->db->write("insert into settings values ('webguiWelcomeMessageTemplate', 'PBtmpl0000000000000015');");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRssLimit {
    my $session = shift;
    print "\tAdding rssLimit to RSSCapable table, if needed... " unless $quiet;
    my $sth = $session->db->read('describe RSSCapable rssCapableRssLimit');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table RSSCapable add column rssCapableRssLimit integer");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addImageAnnotation {
    my $session = shift;
    print "\tAdding annotations to ImageAsset table, if needed... " unless $quiet;
    my $sth = $session->db->read('describe ImageAsset annotations');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table ImageAsset add column annotations mediumtext");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addStatisticsCacheTimeoutToMatrix{
    my $session = shift;
    print "\tAdding statisticsCacheTimeout setting to Matrix table... " unless $quiet;
    $session->db->write("alter table Matrix add statisticsCacheTimeout int(11) not null default 3600");
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Describe what our function does
sub adSkuInstall {
    my $session = shift;
    print "\tInstalling the AdSku Asset...\n" unless $quiet;
    print "\t\tCreate AdSku database table.\n" unless $quiet;
    $session->db->write("CREATE TABLE AdSku (
	assetId VARCHAR(22) BINARY NOT NULL,
	revisionDate BIGINT NOT NULL,
	purchaseTemplate VARCHAR(22) BINARY NOT NULL,
	manageTemplate VARCHAR(22) BINARY NOT NULL,
	adSpace VARCHAR(22) BINARY NOT NULL,
	priority INTEGER DEFAULT '1',
	pricePerClick Float DEFAULT '0',
	pricePerImpression Float DEFAULT '0',
	clickDiscounts VARCHAR(1024) default '',
	impressionDiscounts VARCHAR(1024) default '',
	PRIMARY KEY (assetId,revisionDate)
    )");
    print "\t\tCreate Adsku crud table.\n" unless $quiet;
    use WebGUI::AssetCollateral::Sku::Ad::Ad;
    WebGUI::AssetCollateral::Sku::Ad::Ad->crud_createTable($session);
    print "\t\tAdding to config file.\n" unless $quiet;
    $session->config->addToHash("assets", 'WebGUI::Asset::Sku::Ad' => { category => 'shop' } );
    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}


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

    # Make the package not a package anymore
    $package->update({ isPackage => 0 });
    
    # Set the default flag for templates added
    my $assetIds
        = $package->getLineage( ['self','descendants'], {
            includeOnlyClasses  => [ 'WebGUI::Asset::Template' ],
        } );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        $asset->update( { isDefault => 1 } );
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
