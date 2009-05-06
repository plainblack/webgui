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
use WebGUI::Asset::Sku::Product;
use WebGUI::Utility qw(isIn);


my $toVersion = '7.6.0';
my $quiet; # this line required


my $session = start(); # this line required

addUrlToAssetHistory ( $session ); ##This sub MUST GO FIRST
removeDoNothingOnDelete( $session );
fixIsPublicOnTemplates ( $session );
addSortOrderToFolder( $session );
addLoginTimeStats( $session );
addEMSBadgeTemplate ( $session );
addCSPostReceivedTemplate ( $session );
redirectChoice ($session);
badgePriceDates ($session);
addIsDefaultTemplates( $session );
addAdHocMailGroups( $session );
makeAdminConsolePluggable( $session );
migrateAssetsToNewConfigFormat($session);
deleteAdminBarTemplates($session);
repairBrokenProductSkus($session);
removeUnusedTemplates($session);

finish($session); # this line required


#----------------------------------------------------------------------------
sub removeUnusedTemplates {
    my $session     = shift;
    print "\tDeleting old unused templates... " unless $quiet;
    foreach my $id (qw(PBtmpl0000000000000046 e-WvgcKROPCoHwiiHLktCg PBtmpl0000000000000034 AFdXZZmGnSKalNSobQMB5w)) {
        my $asset = WebGUI::Asset->new($session, $id);
        if (defined $asset && $asset->getChildCount == 0) {
            $asset->purge;
        }
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub deleteAdminBarTemplates {
    my $session     = shift;
    print "\tDeleting AdminBar templates... " unless $quiet;
    foreach my $id (qw(PBtmpl0000000000000090 Ov2ssJHwp_1eEWKlDyUKmg)) {
        my $asset = WebGUI::Asset->newByDynamicClass($session, $id);
        if (defined $asset) {
            $asset->trash;
        }
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub repairBrokenProductSkus {
    my $session     = shift;
    print "\tRepairing broken Products that were imported... " unless $quiet;
    my $getAProduct = WebGUI::Asset::Sku::Product->getIsa($session);
    while (my $product = $getAProduct->()) {
        COLLATERAL: foreach my $collateral (@{ $product->getAllCollateral('variantsJSON') }) {
            next COLLATERAL unless exists $collateral->{sku};
            $collateral->{varSku} = $collateral->{sku};
            delete $collateral->{sku};
            $product->setCollateral('variantsJSON', 'variantId', $collateral->{variantId}, $collateral);
        }
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub migrateAssetsToNewConfigFormat {
    my $session     = shift;
    print "\tRestructuring asset configuration... " unless $quiet;
    my $config = $session->config;
    
    # devs doing multiple upgrades
    # the list has already been updated by a previous run
    my $assetList = $config->get("assets");
    unless (ref $assetList eq "ARRAY") {
        warn "ERROR: Looks like you've already run this upgrade.\n";
        return undef;
    }
    
    # add categories
    $config->set('assetCategories', {
        basic => {
            title   => "^International(basic,Macro_AdminBar);",
            uiLevel => 1,
        },
        intranet => {
            title   => "^International(intranet,Macro_AdminBar);",
            uiLevel => 5,
        },
        shop => {
            title   => "^International(shop,Shop);",
            uiLevel => 5,
        },
        utilities => {
            title   => "^International(utilities,Macro_AdminBar);",
            uiLevel => 9,
        },
        community => {
            title   => "^International(community,Macro_AdminBar);",
            uiLevel => 5,
        },
    });

    # deal with the old asset list
    my $assetContainers = $config->get("assetContainers");
    $assetContainers = [] unless (ref $assetContainers eq "ARRAY");
    my $utilityAssets = $config->get("utilityAssets");
    $utilityAssets = [] unless (ref $utilityAssets eq "ARRAY");
    my @oldAssetList = (@$assetList, @$utilityAssets, @$assetContainers);
    my %assets = (
        'WebGUI::Asset::Wobject::Collaboration::Newsletter' => {
            category    => "community",    
            }
        );
    foreach my $class (@oldAssetList) {
        my %properties;
        if (isIn($class, qw(
            WebGUI::Asset::Wobject::Article
            WebGUI::Asset::Wobject::Layout
            WebGUI::Asset::Wobject::Folder
            WebGUI::Asset::Wobject::Calendar
            WebGUI::Asset::Wobject::Poll
            WebGUI::Asset::Wobject::Search
            WebGUI::Asset::FilePile
            WebGUI::Asset::Snippet
            WebGUI::Asset::Wobject::DataForm
            ))) {
            $properties{category} = 'basic';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::Collaboration::Newsletter
            WebGUI::Asset::Wobject::WikiMaster
            WebGUI::Asset::Wobject::Collaboration
            WebGUI::Asset::Wobject::Survey
            WebGUI::Asset::Wobject::Gallery
            WebGUI::Asset::Wobject::MessageBoard
            WebGUI::Asset::Wobject::Matrix
            ))) {
            $properties{category} = 'community';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::StockData
            WebGUI::Asset::Wobject::Dashboard
            WebGUI::Asset::Wobject::InOutBoard
            WebGUI::Asset::Wobject::MultiSearch
            WebGUI::Asset::Wobject::ProjectManager
            WebGUI::Asset::Wobject::TimeTracking
            WebGUI::Asset::Wobject::UserList
            WebGUI::Asset::Wobject::WeatherData
            WebGUI::Asset::Wobject::Thingy
            ))) {
            $properties{category} = 'intranet';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::Bazaar
            WebGUI::Asset::Wobject::EventManagementSystem
            WebGUI::Asset::Wobject::Shelf
            WebGUI::Asset::Sku::Product
            WebGUI::Asset::Sku::FlatDiscount
            WebGUI::Asset::Sku::Donation
            WebGUI::Asset::Sku::Subscription
            ))) {
            $properties{category} = 'shop';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::WSClient
            WebGUI::Asset::Wobject::SQLReport
            WebGUI::Asset::Wobject::SyndicatedContent
            WebGUI::Asset::Redirect
            WebGUI::Asset::Template
            WebGUI::Asset::Wobject::Navigation
            WebGUI::Asset::File
            WebGUI::Asset::Wobject::HttpProxy
            WebGUI::Asset::File::Image
            WebGUI::Asset::File::ZipArchive
            WebGUI::Asset::RichEdit
            ))) {
            $properties{category} = 'utilities';
        }
        else {
            # other assets listed but not in the core
            $properties{category} = 'utilities';
        }       
        $assets{$class} = \%properties;
    }
    
    # deal with containers
    foreach my $class (@$assetContainers) {
        $assets{$class}{isContainer} = 1;
    }
    
    # deal with custom add privileges
    my $addGroups = $config->get("assetAddPrivilege");
    if (ref $addGroups eq "HASH") {
        foreach my $class (keys %{$addGroups}) {
            $assets{$class}{addGroup} = $addGroups->{$class};
        }
    }
    
    # deal with custom ui levels
    my $uiLevels = $config->get("assetUiLevel");
    if (ref $uiLevels eq "HASH") {
        foreach my $class (keys %{$addGroups}) {
            $assets{$class}{uiLevel} = $uiLevels->{$class};
        }
    }

    # deal with custom field ui levels
    foreach my $class (keys %assets) {
        my $directive =~ s/::/_/g;
        $directive .= '_uiLevel';
        my $value = $config->get($directive);
        if (ref $value eq "HASH") {
            foreach my $field (keys %{$value}) {
                $assets{$class}{fields}{$field}{uiLevel} = $value->{$field};
            }
            $config->delete($directive);
        }
    }
    
    # write the file
    $config->delete('assetContainers');
    $config->delete('utilityAssets');
    $config->delete("assetUiLevel");
    $config->delete("assetAddPrivilege");
    $config->set("assets",\%assets);
        
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub makeAdminConsolePluggable {
    my $session     = shift;
    print "\tMaking admin console pluggable... " unless $quiet;
    $session->config->set("adminConsole",{
		"spectre" => {
			title => "^International(spectre,Spectre);",
			icon    => "spectre.gif",
            url     => "^PageUrl(\"\",op=spectreStatus);",
            uiLevel => 9,
			groupSetting   => "groupIdAdminSpectre"
		},
		"assets" => {
			title   => "^International(assets,Asset);",
			icon    => "assets.gif",
			url      => "^PageUrl(\"\",op=assetManager);",
            uiLevel => 5,
			group   => "12"
		},
		"versions" => {
			title => "^International(version tags,VersionTag);",
			icon    => "versionTags.gif",
			url      => "^PageUrl(\"\",op=manageVersions);",
            uiLevel => 7,
			groupSetting   => "groupIdAdminVersionTag"
		},
		"workflow" => {
			title => "^International(topicName,Workflow);",
			icon    => "workflow.gif",
			url      => "^PageUrl(\"\",manageWorkflows);",
            uiLevel => 7,
			groupSetting   => "groupIdAdminWorkflow"
		},
		"adSpace" => {
			title => "^International(topicName,AdSpace);",
			icon    => "advertising.gif",
			url      => "^PageUrl(\"\",op=manageAdSpaces);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminAdSpace"
		},
		"cron" => {
			title => "^International(topicName,Workflow_Cron);",
			icon    => "cron.gif",
			url      => "^PageUrl(\"\",op=manageCron);",
            uiLevel => 9,
			groupSetting   => "groupIdAdminCron"
		},
		"users" => {
			title => "^International(149,WebGUI);",
			icon    => "users.gif",
			url      => "^PageUrl(\"\",op=listUsers);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminUser"
		},
		"clipboard" => {
			title => "^International(948,WebGUI);",
			icon    => "clipboard.gif",
			url    => "^PageUrl(\"\",func=manageClipboard);",
            uiLevel => 5,
			group   => "12"
		},
		"trash" => {
			title => "^International(trash,WebGUI);",
			icon    => "trash.gif",
			url    => "^PageUrl(\"\",func=manageTrash);",
            uiLevel => 5,
			group   => "12"
		},
		"databases" => {
			title => "^International(databases,WebGUI);",
			icon    => "databases.gif",
			url      => "^PageUrl(\"\",op=listDatabaseLinks);",
            uiLevel => 9,
			groupSetting   => "groupIdAdminDatabaseLink"
		},
		"ldapconnections" => {
			title => "^International(ldapconnections,AuthLDAP);",
			icon    => "ldap.gif",
			url      => "^PageUrl(\"\",op=listLDAPLinks);",
            uiLevel => 9,
			groupSetting   => "groupIdAdminLDAPLink"
		},
		"groups" => {
			title => "^International(89,WebGUI);",
			icon    => "groups.gif",
			url      => "^PageUrl(\"\",op=listGroups);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminGroup"
		},
		"settings" => {
			title => "^International(settings,WebGUI);",
			icon    => "settings.gif",
			url      => "^PageUrl(\"\",op=editSettings);",
            uiLevel => 5,
			group   => "3"
		},
		"help" => {
			title => "^International(help,WebGUI);",
			icon    => "help.gif",
			url      => "^PageUrl(\"\",op=viewHelpIndex);",
            uiLevel => 1,
			groupSetting   => "groupIdAdminHelp"
 		},
		"statistics" => {
			title => "^International(437,WebGUI);",
			icon    => "statistics.gif",
			url      => "^PageUrl(\"\",op=viewStatistics);",
            uiLevel => 1,
			groupSetting   => "groupIdAdminStatistics"
		},
		"contentProfiling" => {
			title => "^International(content profiling,Asset);",
			icon    => "contentProfiling.gif",
			url    => "^PageUrl(\"\",func=manageMetaData);",
            uiLevel => 5,
			group   => "4"
		},
		"contentFilters" => {
			title => "^International(content filters,WebGUI);",
			icon    => "contentFilters.gif",
			url      => "^PageUrl(\"\",op=listReplacements);",
            uiLevel => 3,
			groupSetting   => "groupIdAdminReplacements"
		},
		"userProfiling" => {
			title => "^International(user profiling,WebGUIProfile);",
			icon    => "userProfiling.gif",
			url      => "^PageUrl(\"\",op=editProfileSettings);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminProfileSettings"
		},
		"loginHistory" => {
			title => "^International(426,WebGUI);",
			icon    => "loginHistory.gif",
			url      => "^PageUrl(\"\",op=viewLoginHistory);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminLoginHistory"
		},
		"inbox" => {
			title => "^International(159,WebGUI);",
			icon    => "inbox.gif",
			url      => "^PageUrl(\"\",op=viewInbox);",
            uiLevel => 1,
			group   => "2"
		},
		"activeSessions" => {
			title => "^International(425,WebGUI);",
			icon    => "activeSessions.gif",
			url      => "^PageUrl(\"\",op=viewActiveSessions);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminActiveSessions"
		},
		"shop" => {
			title => "^International(shop,Shop);",
			icon    => "shop.gif",
			url      => "^PageUrl(\"\",shop=admin);",
            uiLevel => 5,
            groupSetting   => 'groupIdAdminCommerce'
		},
		"cache" => {
            title => "^International(manage cache,WebGUI);",
            icon    => "cache.gif",
            url      => "^PageUrl(\"\",op=manageCache);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminCache"
        },
		"graphics" => {
			title => "^International(manage graphics,Graphics);",
			icon    => "graphics.gif",
			url      => "^PageUrl(\"\",op=listGraphicsOptions);",
            uiLevel => 5,
			groupSetting   => "groupIdAdminGraphics"
		},                                          
        });
    print "DONE!\n" unless $quiet;
}


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
          'OxJWQgnGsgyGohP2L3zJPQ','PBnav00000000000bullet','PBnav00000000indentnav',
          'PBnav000000style01lvl2','PBtmpl0000000000000001','PBtmpl0000000000000002',
          'PBtmpl0000000000000004','PBtmpl0000000000000005','PBtmpl0000000000000006',
          'PBtmpl0000000000000010','PBtmpl0000000000000011','PBtmpl0000000000000012',
          'PBtmpl0000000000000013','PBtmpl0000000000000014','PBtmpl0000000000000020',
          'PBtmpl0000000000000021','PBtmpl0000000000000024','PBtmpl0000000000000026',
          'PBtmpl0000000000000027','PBtmpl0000000000000029','PBtmpl0000000000000031',
          'PBtmpl0000000000000032','PBtmpl0000000000000033','PBtmpl0000000000000036',
          'PBtmpl0000000000000037','PBtmpl0000000000000038','PBtmpl0000000000000039',
          'PBtmpl0000000000000040','PBtmpl0000000000000041','PBtmpl0000000000000042',
          'PBtmpl0000000000000043','PBtmpl0000000000000044','PBtmpl0000000000000045',
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
sub addCSPostReceivedTemplate {
    my $session = shift;
    print "\tAdding Post Received Template ID field for CS..." unless $quiet;
    $session->db->write("ALTER TABLE Collaboration ADD COLUMN postReceivedTemplateId VARCHAR(22) DEFAULT 'default_post_received';");
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

