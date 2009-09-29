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
use JSON;

my $toVersion = '7.7.4';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
updateSurveyQuestionTypes($session);
extendSchedulerFields($session);
allMaintenanceSingleton($session);
unsetPackageFlags($session);
installThingyRecord( $session );
installPluggableTax( $session );
addMatrixMaxScreenshotWidthHeight($session);
addSurveyBackButtonColumn( $session );

finish($session); # this line required

#----------------------------------------------------------------------------
sub addMatrixMaxScreenshotWidthHeight {
    my $session = shift;
    print "\tAdding maximum screenshot width and height property to the Matrix." unless $quiet;
    $session->db->write("alter table Matrix add maxScreenshotWidth int(11), add maxScreenshotHeight int(11);");
    $session->db->write("update Matrix set maxScreenshotWidth = 800, maxScreenshotHeight = 600;");
    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub unsetPackageFlags {
    my $session = shift;
    print "\tTurning off package flag on default assets...\n" unless $quiet;
    my @assetIds = qw(
        PBtmpl0000000000000004 PBtmpl0000000000000010
        TEId5V-jEvUULsZA0wuRuA _9_eiaPgxzF_x_upt6-PNQ
        LdiozcIUciWuvt3Z-na5Ww PBtmpl0000000000000011
        PBtmpl0000000000000063 PBtmpl0000000000000062
        1oBRscNIcFOI-pETrCOspA wAc4azJViVTpo-2NYOXWvg
        AjhlNO3wZvN5k4i4qioWcg GRUNFctldUgop-qRLuo_DA
        ThingyTmpl000000000004 UserListTmpl0000000001
        UserListTmpl0000000002 UserListTmpl0000000003
        WikiPageTmpl0000000001 QHn6T9rU7KsnS3Y70KCNTg
        THQhn1C-ooj-TLlEP7aIJQ ThingyTmpl000000000003
        stevestyle000000000003 UL-ItI4L1Z6-WSuhuXVvsQ
        QpmlAiYZz6VsKBM-_0wXaw
    );
    for my $assetId (@assetIds) {
        my $asset = WebGUI::Asset->new($session, $assetId);
        if (!$asset) {
            warn "\tUnable to instantiate default asset $assetId.\n";
            next;
        }
        $asset->update({isPackage => 0});
    }
    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub allMaintenanceSingleton {
    my $session = shift;
    print "\tMaking all maintenance workflows singletons." unless $quiet;
    $session->db->write("update Workflow set mode='singleton' where workflowId in ('pbworkflow000000000001','pbworkflow000000000002','pbworkflow000000000004','AuthLDAPworkflow000001')");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub extendSchedulerFields {
    my $session = shift;
    print "\tExtending scheduler fields" unless $quiet;
    my $db = $session->db;
    $db->write("alter table WorkflowSchedule change minuteOfHour minuteOfHour char(255) not null default '0'");
    $db->write("alter table WorkflowSchedule change hourOfDay hourOfDay char(255) not null default '*'");
    $db->write("alter table WorkflowSchedule change dayOfMonth dayOfMonth char(255) not null default '*'");
    $db->write("alter table WorkflowSchedule change monthOfYear monthOfYear char(255) not null default '*'");
    $db->write("alter table WorkflowSchedule change dayOfWeek dayOfWeek char(255) not null default '*'");
    print "DONE!\n" unless $quiet;
}

sub updateSurveyQuestionTypes{
    my $session = shift;
    my $refs = $session->db->buildArrayRefOfHashRefs("SELECT * FROM Survey_questionTypes");
    for my $ref(@$refs){
        my $name = $ref->{questionType};
        my $params;
        my @texts = split/,/,$ref->{answers};
        #next if(@texts == 0);
        my $count = 0;
        for my $text(@texts){
            my $verbatim = 0;
            $verbatim = 1 if($text =~ /verbatim/);
            push(@$params,[$text,$count++,$verbatim]);
        }
        _loadValues($name,$params,$session);
    }
}

sub _loadValues{
    my $name = shift;
    my $values = shift;
    my $session = shift;
    my $answers = [];
    for my $value(@$values){
        my $answer = _getAnswer();
        $answer->{text} = $value->[0];
        if($answer->{text} eq 'No'){
            $answer->{recordedAnswer} = 0;
        }elsif($answer->{text} eq 'Yes'){
            $answer->{recordedAnswer} = 1;
        }elsif($answer->{text} eq 'True'){
            $answer->{recordedAnswer} = 1;
        }elsif($answer->{text} eq 'False'){
            $answer->{recordedAnswer} = 0;
        }else{
            $answer->{recordedAnswer} = $value->[1];
        }
        $answer->{verbatim} = $value->[2];
        push @$answers,$answer;
    }
    my $json = to_json($answers);
    $session->db->write("UPDATE Survey_questionTypes SET answers = ? WHERE questionType = ?",[$json,$name]);
}

sub _getAnswer{
    my $answer = {
            text           => q{},
            verbatim       => 0,
            textCols       => 10,
            textRows       => 5,
            goto           => q{},
            gotoExpression => q{},
            recordedAnswer => q{},
            isCorrect      => 1,
            min            => 1,
            max            => 10,
            step           => 1,
            value          => 1,
            terminal       => 0,
            terminalUrl    => q{},
            type           => 'answer'
    };
    return $answer;
}

#----------------------------------------------------------------------------
sub installPluggableTax {
    my $session = shift;
    my $db      = $session->db;
    print "\tInstall tables for pluggable tax system..." unless $quiet;

    # Rename table for the Generic tax plugin
    $db->write( 'alter table tax rename tax_generic_rates' );

    # Create tax driver table
    $db->write( 'create table taxDriver (className char(255) not null primary key, options mediumtext)' );

    # Table for storing EU VAT numbers.
    $db->write( <<EOSQL2 );
        create table tax_eu_vatNumbers (
            userId      char(22)    binary  not null, 
            countryCode char(3)             not null, 
            vatNumber   char(20)            not null, 
            approved    tinyint(1)          not null default 0, 
            primary key( userId, vatNumber )
        );
EOSQL2

    # Add the Generic and EU taxdrivers to the config file.
    $session->config->set( 'taxDrivers', [
        'WebGUI::Shop::TaxDriver::Generic',
        'WebGUI::Shop::TaxDriver::EU',
    ] );

    # Add a setting to store the active tax plugin.
    $session->setting->add( 'activeTaxPlugin', 'WebGUI::Shop::TaxDriver::Generic' );

    # Add column to sku for storing each sku's tax configuration.
    $db->write( "alter table sku add column taxConfiguration mediumtext " );

    # Migrate the tax overrides of skus into the tax configuration column.
    # Don't use getLineage because this has to be done for each revision.
    my $sth = $db->read( "select assetId, revisionDate, overrideTaxRate, taxRateOverride from sku" );
    while (my $row = $sth->hashRef) {
        my $config = {
            overrideTaxRate => $row->{ overrideTaxRate } || 0,
            taxRateOverride => $row->{ taxRateOverride } || 0,
        };

        $db->write( 'update sku set taxConfiguration=? where assetId=? and revisionDate=?', [
            to_json( $config ),
            $row->{ assetId },
            $row->{ revisionDate },
        ]);
    }
    $sth->finish;

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the ThingyRecord sku
sub installThingyRecord {
    my ( $session ) = shift;
    print "\tInstalling ThingyRecord sku... " unless $quiet;
    
    $session->config->addToHash('assets','WebGUI::Asset::Sku::ThingyRecord', {
        category        => "shop",
    });
    
    # Install ThingyRecord
    $session->db->write( <<'ENDSQL' );
    CREATE TABLE IF NOT EXISTS ThingyRecord (
        assetId CHAR(22) BINARY NOT NULL,
        revisionDate BIGINT NOT NULL,
        templateIdView CHAR(22) BINARY,
        thingId CHAR(22) BINARY,
        thingFields LONGTEXT,
        thankYouText LONGTEXT,
        price FLOAT,
        duration BIGINT,
        PRIMARY KEY (assetId, revisionDate)
    );
ENDSQL

    # Install collateral
    use WebGUI::AssetCollateral::Sku::ThingyRecord::Record;
    WebGUI::AssetCollateral::Sku::ThingyRecord::Record->crud_createTable($session);

    # Update workflow
    my $activityClass   = 'WebGUI::Workflow::Activity::ExpirePurchasedThingyRecords';
    $session->config->addToArray( 'workflow/None', $activityClass );
    my $workflow    = WebGUI::Workflow->new( $session, 'pbworkflow000000000004' );
    my $activity    = $workflow->addActivity( $activityClass );
    $activity->set('title', "Expire Purchased Thingy Records");
    $activity->set('description', "Expire any expired thingy records. Send notifications of imminent expiration.");

    print "DONE!\n" unless $quiet;
}

sub addSurveyBackButtonColumn{
    my $session = shift;
    print "\tAdding allowBackBtn column to Survey table... " unless $quiet;
    $session->db->write("alter table Survey add column `allowBackBtn` TINYINT(3)");
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
