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

my $toVersion = '7.7.22';
my $quiet; # this line required


my $session = start(); # this line required
removeOldITransactTables( $session );
removeImportCruft( $session );
removeAdminFromVisitorGroup( $session );
fixPackageFlagOnOlder( $session );
correctWikiAttachmentPermissions( $session );
transactionsNotifications( $session );

fixTableDefaultCharsets($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
sub fixPackageFlagOnOlder {
    my $session = shift;
    print "\tFixing isPackage flag on folders and isDefault on templates from 7.6.35 to 7.7.17 upgrade.  This may take a while.. " unless $quiet;

    my @assetIds = qw(
AldPGu0u-jm_5xK13atCSQ S3zpVitAmhy58CAioH359Q wAc4azJViVTpo-2NYOXWvg NBVSVNLp9X_bV7WrCprtCA
QHn6T9rU7KsnS3Y70KCNTg ohjyzab5i-yW6GOWTeDUHg AjhlNO3wZvN5k4i4qioWcg matrixtmpl000000000002
HPDOcsj4gBme8D4svHodBw YP9WaMPJHvCJl-YwrLVcPw qsG6B24a0SC5KrhQjmdZBw matrixtmpl000000000001
FJbUTvZ2nUTn65LpW6gjsA TvOZs8U1kRXLtwtmyW75pg kwTL1SWCk0GlpiJ5zAAEPQ matrixtmpl000000000003
75CmQgpcCSkdsL-oawdn3Q PBtmpl0000000000000103 oGfxez5sksyB_PcaAsEm_Q matrixtmpl000000000005
2CS-BErrjMmESOtGT90qOg PBtmpl0000000000000002 PBtmpl0000000000000065 hkj6WeChxFyqfP85UlRP8w
MBmWlA_YEA2I6D29OMGtRg PBtmpl0000000000000115 GNvjCFQWjY2AF2uf0aCM8Q alraubvBu-YJJ614jAHD5w
IZkrow_zwvbf4FCH-taVTQ PBtmpl0000000000000123 SynConXSLT000000000001 matrixtmpl000000000007
gfZOwaTWYjbSoVaQtHBBEw zb_OPKNqcTuIjdvvbEkRjw SynConXSLT000000000002 BFfNj5wA9bDw8H3cnr8pTw
c8xrwVuu5QE0XtF9DiVzLw i9-G00ALhJOr0gMh-vHbKA SynConXSLT000000000003 PBtmpl0000000000000093
0n4HtbXaWa_XJHkFjetnLQ PBtmpl0000000000000135 SynConXSLT000000000004 PBtmpl0000000000000108
ErEzulFiEKDkaCDVmxUavw PBtmpl0000000000000131 3n3H85BsdeRQ0I08WmvlOg PBtmpl0000000000000117
6uQEULvXFgCYlRWnYzZsuA PBtmpl0000000000000054 pbtmpl0000000000000221 PBtmpl0000000000000124
DUoxlTBXhVS-Zl3CFDpt9g PBtmpl0000000000000109 pbtmpl0000000000000220 PBtmpl0000000000000130
1Q4Je3hKCJzeo0ZBB5YB8g VyCINX2KixKYr2pzQGX9Mg b1316COmd9xRv4fCI3LLGA PBtmpl0000000000000134
5A8Hd9zXvByTDy4x-H28qw -PkdI8l1idu-8gDX3iOdcw matrixtmpl000000000006 PBtmpl0000000000000136
VBkY05f-E3WJS50WpdKd1Q VZK3CRgiMb8r4dBjUmCTgQ CarouselTmpl0000000001 PBnav00000000000bullet
XgcsoDrbC0duVla7N7JAdw PBtmpl0000000000000055 RSAMkc6WQmfRE3TOr1_3Mw PBnav00000000indentnav
cR0UFm7I1qUI2Wbpj--08Q i5kt5aodVs_oepNEkE7Okw ExpireIncResptmpl00001 FEDP3dk8J3Chw_gyr7_XEQ
SVIhz68689hwUGgcDM-gWw f_tn9FfoSfKWX43F83v_3w CarouselTmpl0000000002 PBtmpl0000000000000056
K0YjxqOqr7RupSo6sIdcAg PBtmpl0000000000000200 lo1rpxn3t8YPyKGers5eQg nFen0xjkZn8WkpM93C9ceQ
zrNpGbT3odfIkg6nFSUy8Q tXwf1zaOXTvsqPn6yu-GSw 64tqS80D53Z0JoAs2cX2VQ aIpCmr9Hi__vgdZnDTz1jw
1Yn_zE_dSiNuaBGNLPbxtw PBtmpl0000000000000024 yxD5ka7XHebPLD-LXBwJqw XNd7a_g_cTvJVYrVHcx2Mw
AZFU33p0jpPJ-E6qLSWZng MK4fCNoyrx5SE8eyDfOpxg E3tzZjzhmYoNlAyP2VW33Q g8W53Pd71uHB9pxaXhWf_A
AGJBGviWGAwjnwziiPjvDg PBtmpl0000000000000062 TbDcVLbbznPi0I0rxQf2CQ PBtmpl0000000000000137
7Ijdd8SW32lVgg2H8R-Aqw 2c4RcwsUfQMup_WNujoTGg A16v-YjWAShXWvSACsraeg PBtmpl0000000000000063
K8F0j_cq_jgo8dvWY_26Ag olxhUOpdclI-sl4Q5FYNdA 0EAJ9EYb9ap2XwfrcXfdLQ PcRRPhh-0KfvLLNIPdxJTw
G5V6neXIDiFXN05oL-U3AQ CcFIbiAykwArJrJeTPgbDg nWNVoMLrMo059mDRmfOp9g ThingyTmpl000000000001
_ilRXNR3s8F2vGJ_k9ePcg fCibAeqRifEEAhFL6-pEKg brxm_faNdZX5tRo3p50g3g PBtmpl0000000000000061
9ThW278DWLV0-Svf68ljFQ 1LiN6-Mh0rXBPoRaG8_BbQ 9j0_Z1j3Jd0QBbY2akb6qw GRUNFctldUgop-qRLuo_DA
AOjPG2NHgfL9Cq6dDJ7mew CGirMWuhmjFFXITINo9djw oHh0UqAJeY7u2n--WD-BAA d8jMMMRddSQ7twP4l1ZSIw
aUDsJ-vB9RgP-AYvPOy8FQ GaBAW-2iVhLMJaZQzVLE5A u9vfx33XDk5la1-QC5FK7g CxMpE_UPauZA3p8jdrOABw
-zxyB-O50W8YnL39Ouoc4Q TKmhv8boP3TD2xwSwUBq0g D6cJpRcey35aSkh9Q_FPUQ 1oBRscNIcFOI-pETrCOspA

qaVcU0FFzzraMX_bzELqzw hIB-z34r8Xl-vYVYCkKr-w _hELmIJfgbAyXFNqPyApxQ
b4n3VyUIsAHyIvT-W-jziA -mPUoFlYcjqjPUPRLAlxNQ _9_eiaPgxzF_x_upt6-PNQ
1IzRpX0tgW7iuCfaU2Kk0A MDpUOR-N8KMyt1J7Hh_h4w kaPRSaf8UKiskiGEgJgLAw
N716tpSna0iIQTKxS4gTWA YfXKByTwDZVituMc4h13Dg bANo8aiAPA7aY_oQZKxIWw
_XfvgNH__bY1ykMiKYSobQ esko_HSU0Gh-uJZ1h3xRmQ 2ci_v2d4x4uvyjTRlC49OA
HW-sPoDDZR8wBZ0YgFgPtg oSqpGswzpBG_ErdfYwIO8A O-EsSzKgAk1KolFT-x_KsA
hBpisL-_URyZnh9clR5ohA MXJklShZvLLB_DSnZQmXrQ fdd8tGExyVwHyrB8RBbKXg
FOBV6KkifreXa4GmEAUU4A BthxD5oJ0idmsyI3ioA2FA BpisgHl4ZDcSECJp6oib1w
PBtmpl0000000000000001 aZ-1HYQamkRHYXvzAra8WQ zshreRgPAXtnF0DtVbQ1Yg
PBtmpl0000000000000016 eRkb94OYcS5AdcrrerOP5Q POVcY79vIqAHR8OfGt36aw
PBtmpl0000000000000011 TbnkjAJQEASORXIpYqDkcA
kj3b-X3i6zRKnhLb4ZiCLw er-3faBjY-hhlDcc5aKqdQ
CalendarMonth000000001 8bFsu2FJUqHRUiHcozcVFw
PBtmpl0000000000000081 34Aayx5eA320D8VfhdfDBw
BMybD3cEnmXVk2wQ_qEsRQ TlhKOVmWblZOsAdqmhEpeg
2rC4ErZ3c77OJzJm7O5s3w Nx0ypjO3cN6QdZUBUEE0lA
GYaFxnMu9UsEG8oanwB6TA CmFZLN7iPS7XXvUEsxKPKA
PBtmpl0000000000000078 v_XBgwwZqgW1D5s4y05qfg
gI_TxK-5S4DNuv42wpImmw 4TdAkKoQbSCvI7QWcW889A
jME5BEDYVDlBZ8jIQA9-jQ SAgK6eDPCG1cgkJ59WapHQ
azCqD0IjdQSlM3ar29k5Sg XJYLuvGy9ubF7JNKyINtpA
05FpjceLYhq4csF1Kww1KQ RWj7hyv2SpZuXxwj1Wocug
q5O62aH4pjUXsrQR3Pq4lw aq8QElnlm3YufAoxRz9Pcg
KAMdiUdJykjN02CPHpyZOw mM3bjP_iG9sv5nQb4S17tQ
OkphOEdaSGTXnFGhK4GT5A ilu5BrM-VGaOsec9Lm7M6Q
TEId5V-jEvUULsZA0wuRuA -ANLpoTEP-n4POAdRxCzRw
6X-7Twabn5KKO_AbgK3PEw OxJWQgnGsgyGohP2L3zJPQ
7JCTAiu1U_bT9ldr655Blw 7fE8md51vTCcuJFOvxNaGA
0X4Q3tBWUb_thsVbsYz9xQ 1oGhfj00KkCzP1ez01AfKA
m3IbBavqzuKDd2PGGhKPlA 3qiVYhNTXMVC5hfsumVHgg
UTNFeV7B_aSCRmmaFCq4Vw THQhn1C-ooj-TLlEP7aIJQ
zcX-wIUct0S_np14xxOA-A tPagC0AQErZXjLFZQ6OI1g
MBZK_LPVzqhb4TV4mMRTJg PBtmpl0000000000000088
);

    for my $assetId ( @assetIds ) {
        my $asset = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        next unless $asset;
        my $data = {};
        if( $asset->get('isPackage') ) {
            $data->{isPackage} = 0;
        }
        if( $asset->isa('WebGUI::Asset::Template') ) {
            $data->{isDefault} = 1;
        }
        if (scalar keys %{ $data }) {
            print "\n\t\tUpdating ".$asset->getTitle." ... ";
            $asset->update($data);
        }
    }

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub removeOldITransactTables {
    my $session = shift;
    print "\tRemoving tables leftover from the old 7.5 ITransact Plugin... " unless $quiet;
    $session->db->write('DROP TABLE IF EXISTS ITransact_recurringStatus');
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
        foreach my $attachment (@{ $wikiPage->getLineage(['children'])}) {
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
        $defaultNotificationGroup = $firstGateway->get('saleNotificationGroupId');
        $defaultTemplate          = $firstGateway->get('receiptEmailTemplateId' );
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

# Describe what our function does
sub removeImportCruft {
    my $session = shift;
    print "\tRemoving cruft from the import node... " unless $quiet;
    my $propFolder = WebGUI::Asset->newByDynamicClass($session, '2c4RcwsUfQMup_WNujoTGg');
    if ($propFolder) {
        $propFolder->purge;
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub removeAdminFromVisitorGroup {
    my $session = shift;
    print "\tRemoving Admin group from Visitor group... " unless $quiet;
    $session->db->write("delete from groupGroupings where groupId='3' and inGroup='1'");
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
