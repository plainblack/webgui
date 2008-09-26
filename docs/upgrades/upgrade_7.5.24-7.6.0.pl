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


my $toVersion = '7.6.0';
my $quiet; # this line required


my $session = start(); # this line required

addUrlToAssetHistory ( $session ); ##This sub MUST GO FIRST
removeDoNothingOnDelete( $session );
fixIsPublicOnTemplates ( $session );
addSortOrderToFolder( $session );
addLoginTimeStats( $session );
addEMSBadgeTemplate ( $session );
redirectChoice ($session);
badgePriceDates ($session);
addIsDefaultTemplates( $session );
addAdHocMailGroups( $session );

finish($session); # this line required

#----------------------------------------------------------------------------
# Add the "isDefault" flag and set it for the right templates
sub addIsDefaultTemplates {
    my $session     = shift;
    print "\tAdding warning when editing default templates... " unless $quiet;
    $session->db->write( "ALTER TABLE template ADD COLUMN isDefault INT(1) DEFAULT 0" );
    print "DONE!\n" unless $quiet;
}

sub setDefaultTemplates {
    my $session     = shift;
    print "\tUpdating default templates to show warning... " unless $quiet; 
    my $defaultTemplates    =[
          '-ANLpoTEP-n4POAdRxCzRw','05FpjceLYhq4csF1Kww1KQ','0X4Q3tBWUb_thsVbsYz9xQ',
          '2gtFt7c0qAFNU3BG_uvNvg','2rC4ErZ3c77OJzJm7O5s3w','3womoo7Teyy2YKFa25-MZg',
          '63ix2-hU0FchXGIWkG3tow','6X-7Twabn5KKO_AbgK3PEw','7JCTAiu1U_bT9ldr655Blw',
          'BMybD3cEnmXVk2wQ_qEsRQ','CalendarDay00000000001','CalendarEvent000000001',
          'CalendarEventEdit00001','CalendarMonth000000001','CalendarPrintDay000001',
          'CalendarPrintEvent0001','CalendarPrintMonth0001','CalendarPrintWeek00001',
          'CalendarSearch00000001','CalendarWeek0000000001','DPUROtmpl0000000000001',
          'DashboardViewTmpl00001','EBlxJpZQ9o-8VBOaGQbChA','GNvjCFQWjY2AF2uf0aCM8Q',
          'IOB0000000000000000001','IOB0000000000000000002','KAMdiUdJykjN02CPHpyZOw',
          'MultiSearchTmpl0000001','OOyMH33plAy6oCj_QWrxtg','OkphOEdaSGTXnFGhK4GT5A',
          'OxJWQgnGsgyGohP2L3zJPQ','PBnav00000000000bullet',
          'PBnav00000000indentnav','PBnav000000style01lvl2','PBtmpl0000000000000001',
          'PBtmpl0000000000000002','PBtmpl0000000000000004','PBtmpl0000000000000005',
          'PBtmpl0000000000000006','PBtmpl0000000000000010','PBtmpl0000000000000011',
          'PBtmpl0000000000000012','PBtmpl0000000000000013','PBtmpl0000000000000014',
          'PBtmpl0000000000000020','PBtmpl0000000000000021','PBtmpl0000000000000024',
          'PBtmpl0000000000000026','PBtmpl0000000000000027','PBtmpl0000000000000029',
          'PBtmpl0000000000000031','PBtmpl0000000000000032','PBtmpl0000000000000033',
          'PBtmpl0000000000000034','PBtmpl0000000000000036','PBtmpl0000000000000037',
          'PBtmpl0000000000000038','PBtmpl0000000000000039','PBtmpl0000000000000040',
          'PBtmpl0000000000000041','PBtmpl0000000000000042','PBtmpl0000000000000043',
          'PBtmpl0000000000000044','PBtmpl0000000000000045','PBtmpl0000000000000046',
          'PBtmpl0000000000000047','PBtmpl0000000000000048','PBtmpl0000000000000051',
          'PBtmpl0000000000000052','PBtmpl0000000000000053','PBtmpl0000000000000054',
          'PBtmpl0000000000000055','PBtmpl0000000000000056','PBtmpl0000000000000057',
          'PBtmpl0000000000000059','PBtmpl0000000000000060','PBtmpl0000000000000061',
          'PBtmpl0000000000000062','PBtmpl0000000000000063','PBtmpl0000000000000064',
          'PBtmpl0000000000000065','PBtmpl0000000000000066','PBtmpl0000000000000067',
          'PBtmpl0000000000000068','PBtmpl0000000000000069','PBtmpl0000000000000077',
          'PBtmpl0000000000000078','PBtmpl0000000000000079','PBtmpl0000000000000080',
          'PBtmpl0000000000000081','PBtmpl0000000000000082','PBtmpl0000000000000083',
          'PBtmpl0000000000000084','PBtmpl0000000000000085','PBtmpl0000000000000088',
          'PBtmpl0000000000000090','PBtmpl0000000000000091','PBtmpl0000000000000092',
          'PBtmpl0000000000000093','PBtmpl0000000000000094','PBtmpl0000000000000097',
          'PBtmpl0000000000000098','PBtmpl0000000000000099','PBtmpl0000000000000100',
          'PBtmpl0000000000000101','PBtmpl0000000000000103','PBtmpl0000000000000104',
          'PBtmpl0000000000000107','PBtmpl0000000000000108','PBtmpl0000000000000109',
          'PBtmpl0000000000000111','PBtmpl0000000000000112','PBtmpl0000000000000113',
          'PBtmpl0000000000000114','PBtmpl0000000000000115','PBtmpl0000000000000116',
          'PBtmpl0000000000000117','PBtmpl0000000000000118','PBtmpl0000000000000121',
          'PBtmpl0000000000000122','PBtmpl0000000000000123','PBtmpl0000000000000124',
          'PBtmpl0000000000000125','PBtmpl0000000000000128','PBtmpl0000000000000129',
          'PBtmpl0000000000000130','PBtmpl0000000000000131','PBtmpl0000000000000132',
          'PBtmpl0000000000000133','PBtmpl0000000000000134','PBtmpl0000000000000135',
          'PBtmpl0000000000000136','PBtmpl0000000000000137','PBtmpl0000000000000140',
          'PBtmpl0000000000000141','PBtmpl0000000000000142','PBtmpl0000000000000200',
          'PBtmpl0000000000000205','PBtmpl0000000000000206','PBtmpl0000000000000207',
          'PBtmpl0000000000000208','PBtmpl0000000000000209','PBtmpl0000000000000210',
          'PBtmpl000000000table54','PBtmpl00000000table094','PBtmpl00000000table109',
          'PBtmpl00000000table118','PBtmpl00000000table125','PBtmpl00000000table131',
          'PBtmpl00000000table135','PBtmpl00000userInvite1','PBtmpl0userInviteEmail',
          'PBtmplBlankStyle000001','PBtmplHelp000000000001','PBtmplPrivateMessage01',
          'ProjectManagerTMPL0001','ProjectManagerTMPL0002','ProjectManagerTMPL0003',
          'ProjectManagerTMPL0004','ProjectManagerTMPL0005','ProjectManagerTMPL0006',
          'PsFn7dJt4wMwBa8hiE3hOA','SQLReportDownload0001','StockDataTMPL000000001',
          'StockDataTMPL000000002','TEId5V-jEvUULsZA0wuRuA','ThingyTmpl000000000001',
          'ThingyTmpl000000000002','ThingyTmpl000000000003','ThingyTmpl000000000004',
          'TimeTrackingTMPL000001','TimeTrackingTMPL000002','TimeTrackingTMPL000003',
          'UTNFeV7B_aSCRmmaFCq4Vw','UserListTmpl0000001','UserListTmpl0000002',
          'UserListTmpl0000003','WVtmpl0000000000000001','WeatherDataTmpl0000001',
          'WikiFrontTmpl000000001','WikiKeyword00000000001','WikiMPTmpl000000000001',
          'WikiPHTmpl000000000001','WikiPageEditTmpl000001','WikiPageTmpl0000000001',
          'WikiRCTmpl000000000001','WikiSearchTmpl00000001','XNd7a_g_cTvJVYrVHcx2Mw',
          'ZipArchiveTMPL00000001','aIpCmr9Hi__vgdZnDTz1jw','azCqD0IjdQSlM3ar29k5Sg',
          'bPz1yk6Y9uwMDMBcmMsSCg','eqb9sWjFEVq0yHunGV8IGw','g8W53Pd71uHB9pxaXhWf_A',
          'ilu5BrM-VGaOsec9Lm7M6Q','jME5BEDYVDlBZ8jIQA9-jQ','kj3b-X3i6zRKnhLb4ZiCLw',
          'm3IbBavqzuKDd2PGGhKPlA','mM3bjP_iG9sv5nQb4S17tQ','managefriends_________',
          'matrixtmpl000000000001','matrixtmpl000000000002','matrixtmpl000000000003',
          'matrixtmpl000000000004','matrixtmpl000000000005','nFen0xjkZn8WkpM93C9ceQ',
          'newsletter000000000001','newslettercs0000000001','newslettersubscrip0001',
          'pbtmpl0000000000000220','pbtmpl0000000000000221','q5O62aH4pjUXsrQR3Pq4lw',
          'stevecoolmenu000000001','stevenav00000000000001','stevestyle000000000001',
          'stevestyle000000000002','stevestyle000000000003','uRL9qtk7Rb0YRJ41LmHOJw',
          'vrKXEtluIhbmAS9xmPukDA','yBwydfooiLvhEFawJb0VTQ','zcX-wIUct0S_np14xxOA-A'
        ];
    
    for my $assetId ( @{ $defaultTemplates } ) {
        my $asset   = WebGUI::Asset::Template->new( $session, $assetId );
        if ( !$asset ) {
            print "\n\t\tCouldn't instanciate default asset '$assetId', skipping...";
            next;
        }
        else {
            $asset->update( { isDefault => 1 } );
        }
    } 

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub badgePriceDates {
    my $session = shift;
    print "\tAllowing badges to have multiple prices set by date." unless $quiet;
    my $db = $session->db;
    $db->write("alter table EMSBadge add column earlyBirdPrice float not null default 0.0");
    $db->write("alter table EMSBadge add column earlyBirdPriceEndDate bigint");
    $db->write("alter table EMSBadge add column preRegistrationPrice float not null default 0.0");
    $db->write("alter table EMSBadge add column preRegistrationPriceEndDate bigint");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixIsPublicOnTemplates {
    my $session = shift;
    print "\tFixing 'is public' on templates" unless $quiet;
    $session->db->write('UPDATE `assetIndex` SET `isPublic` = 0 WHERE assetId IN (SELECT assetId FROM asset WHERE className IN ("WebGUI::Asset::RichEdit", "WebGUI::Asset::Snippet", "WebGUI::Asset::Template") )');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addEMSBadgeTemplate {
    my $session = shift;
    print "\tAdding EMS Badge Template... " unless $quiet;
    $session->db->write('ALTER TABLE EMSBadge ADD COLUMN templateId VARCHAR(22) BINARY NOT NULL');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addUrlToAssetHistory {
    my $session = shift;
    print "\tAdding URL column to assetHistory" unless $quiet;
    $session->db->write('ALTER TABLE assetHistory ADD COLUMN url VARCHAR(255)');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSortOrderToFolder {
    my $session = shift;
    print "\tAdding Sort Order to Folder... " unless $quiet;
    $session->db->write( 'alter table Folder add column sortOrder ENUM("ASC","DESC") DEFAULT "ASC"' );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addLoginTimeStats {
    my $session     = shift;
    print "\tAdding login time statistics... " unless $quiet;
    $session->db->write( "alter table userLoginLog add column sessionId varchar(22)" );
    $session->db->write( "alter table userLoginLog add column lastPageViewed int(11)" );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeDoNothingOnDelete {
    my $session = shift;
    print "\tRemoving 'Do Nothing On Delete workflow if not customized... " unless $quiet;
    my $workflow = WebGUI::Workflow->new($session, 'DPWwf20061030000000001');
    if ($workflow) {
        my $activities = $workflow->getActivities;
        if (@$activities == 0) {
            # safe to delete.
            for my $setting (qw(trashWorkflow purgeWorkflow changeUrlWorkflow)) {
                my $setValue = $session->setting->get($setting);
                if ($setValue eq 'DPWwf20061030000000001') {
                    $session->setting->set($setting, undef);
                }
            }
            $workflow->delete;
        }
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub redirectChoice {
    my $session = shift;
    print "\tGiving a user choice about which type of redirect they'd like to perform... " unless $quiet;
    $session->db->write("alter table redirect add column redirectType int not null default 302");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addAdHocMailGroups {
    my $session = shift;
    print "\tAdding AdHocMailGroups to Groups.. " unless $quiet;
    $session->db->write("alter table groups add column isAdHocMailGroup tinyint(4) not null default 0");
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
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage );

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
    setDefaultTemplates( $session );
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

