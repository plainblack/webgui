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


my $toVersion = "7.9.0";
my $quiet;


my $session = start();

# upgrade functions go here
removeBadMacroEntries($session);
addFilePumpMacro($session);
fixImportNodeSettings($session);

finish($session);


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#----------------------------------------------------------------------------
# Describe what our function does
sub removeBadMacroEntries {
    my $session = shift;
    print "\tRemove bad macro entries that look like perl memory locations... " unless $quiet;
    my $macros = $session->config->get('macros');
    # and here's our code
    foreach my $macroName (keys %{ $macros }) {
        delete $macros->{$macroName} if $macroName =~ /HASH \( 0x \w+ \)/ox;
    }
    $session->config->set('macros', $macros);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addFilePumpMacro {
    my $session = shift;
    print "\tAdd the FilePump macro... " unless $quiet;
    # and here's our code
    $session->config->addToHash('macros', 'FilePump' => 'FilePump');

# Describe what our function does
sub fixImportNodeSettings {
    my $session = shift;
    print "\tFix settings in the import node... " unless $quiet;
    # and here's our code
    my $db = $session->db;
    $db->write('update template set isDefault=0');
    my @templateIds = qw/
-ANLpoTEP-n4POAdRxCzRw PBtmpl0000000000000092  N716tpSna0iIQTKxS4gTWA VCFhB9WOsDsH2Apj3c6DpQ    
-PkdI8l1idu-8gDX3iOdcw PBtmpl0000000000000093  NBVSVNLp9X_bV7WrCprtCA WVtmpl0000000000000001    
-zxyB-O50W8YnL39Ouoc4Q PBtmpl0000000000000094  OOyMH33plAy6oCj_QWrxtg WeatherDataTmpl0000001    
05FpjceLYhq4csF1Kww1KQ PBtmpl0000000000000097  OkphOEdaSGTXnFGhK4GT5A WikiFrontTmpl000000001    
0EAJ9EYb9ap2XwfrcXfdLQ PBtmpl0000000000000098  OxJWQgnGsgyGohP2L3zJPQ WikiKeyword00000000001    
0X4Q3tBWUb_thsVbsYz9xQ PBtmpl0000000000000099  PBEmsBadgeTemplate0000 WikiMPTmpl000000000001    
0n4HtbXaWa_XJHkFjetnLQ PBtmpl0000000000000101  PBnav00000000000bullet WikiPHTmpl000000000001    
1IzRpX0tgW7iuCfaU2Kk0A PBtmpl0000000000000103  PBnav00000000indentnav WikiPageEditTmpl000001    
1Q4Je3hKCJzeo0ZBB5YB8g PBtmpl0000000000000104  PBnav000000style01lvl2 WikiPageTmpl0000000001    
1Yn_zE_dSiNuaBGNLPbxtw PBtmpl0000000000000107  PBtmpl0000000000000001 WikiRCTmpl000000000001    
1oBRscNIcFOI-pETrCOspA PBtmpl0000000000000108  PBtmpl0000000000000002 WikiSearchTmpl00000001    
2CS-BErrjMmESOtGT90qOg PBtmpl0000000000000109  PBtmpl0000000000000004 XNd7a_g_cTvJVYrVHcx2Mw    
2GxjjkRuRkdUg_PccRPjpA PBtmpl0000000000000111  PBtmpl0000000000000005 XdlKhCDvArs40uqBhvzR3w    
2gtFt7c0qAFNU3BG_uvNvg PBtmpl0000000000000112  PBtmpl0000000000000006 XgcsoDrbC0duVla7N7JAdw    
2rC4ErZ3c77OJzJm7O5s3w PBtmpl0000000000000113  PBtmpl0000000000000010 YP9WaMPJHvCJl-YwrLVcPw    
3QpYtHrq_jmAk1FNutQM5A PBtmpl0000000000000114  PBtmpl0000000000000011 ZipArchiveTMPL00000001    
3rjnBVJRO6ZSkxlFkYh_ug PBtmpl0000000000000115  PBtmpl0000000000000012 _aE16Rr1-bXBf8SIaLZjCg    
3womoo7Teyy2YKFa25-MZg PBtmpl0000000000000116  PBtmpl0000000000000013 aIpCmr9Hi__vgdZnDTz1jw    
4Ekp0kJoJllRRRo_J1Rj6w PBtmpl0000000000000117  PBtmpl0000000000000014 aUDsJ-vB9RgP-AYvPOy8FQ    
5A8Hd9zXvByTDy4x-H28qw PBtmpl0000000000000121  PBtmpl0000000000000015 alraubvBu-YJJ614jAHD5w    
63ix2-hU0FchXGIWkG3tow PBtmpl0000000000000122  PBtmpl0000000000000016 azCqD0IjdQSlM3ar29k5Sg    
64tqS80D53Z0JoAs2cX2VQ PBtmpl0000000000000123  PBtmpl0000000000000020 b1316COmd9xRv4fCI3LLGA    
6X-7Twabn5KKO_AbgK3PEw PBtmpl0000000000000124  PBtmpl0000000000000021 b4n3VyUIsAHyIvT-W-jziA    
6uQEULvXFgCYlRWnYzZsuA PBtmpl0000000000000128  PBtmpl0000000000000024 bPz1yk6Y9uwMDMBcmMsSCg    
75CmQgpcCSkdsL-oawdn3Q PBtmpl0000000000000130  PBtmpl0000000000000026 c8xrwVuu5QE0XtF9DiVzLw    
7F-BuEHi7t9bPi008H8xZQ PBtmpl0000000000000131  PBtmpl0000000000000027 cR0UFm7I1qUI2Wbpj--08Q    
7Ijdd8SW32lVgg2H8R-Aqw PBtmpl0000000000000132  PBtmpl0000000000000029 d8jMMMRddSQ7twP4l1ZSIw    
7JCTAiu1U_bT9ldr655Blw PBtmpl0000000000000133  PBtmpl0000000000000031 default_post_received1    
8tqyQx-LwYUHIWOlKPjJrA PBtmpl0000000000000134  PBtmpl0000000000000032 eqb9sWjFEVq0yHunGV8IGw    
9ThW278DWLV0-Svf68ljFQ PBtmpl0000000000000135  PBtmpl0000000000000033 g8W53Pd71uHB9pxaXhWf_A    
9j0_Z1j3Jd0QBbY2akb6qw PBtmpl0000000000000136  PBtmpl0000000000000036 gfZOwaTWYjbSoVaQtHBBEw    
A16v-YjWAShXWvSACsraeg PBtmpl0000000000000137  PBtmpl0000000000000037 h_T2xtOxGRQ9QJOR6ebLpQ    
AGJBGviWGAwjnwziiPjvDg PBtmpl0000000000000140  PBtmpl0000000000000038 hreA_bgxiTX-EzWCSZCZJw    
AZFU33p0jpPJ-E6qLSWZng PBtmpl0000000000000141  PBtmpl0000000000000039 i9-G00ALhJOr0gMh-vHbKA    
AjhlNO3wZvN5k4i4qioWcg PBtmpl0000000000000200  PBtmpl0000000000000040 ilu5BrM-VGaOsec9Lm7M6Q    
AldPGu0u-jm_5xK13atCSQ PBtmpl0000000000000208  PBtmpl0000000000000041 itransact_credentials1    
BMybD3cEnmXVk2wQ_qEsRQ PBtmpl0000000000000209  PBtmpl0000000000000042 jME5BEDYVDlBZ8jIQA9-jQ    
CalendarDay00000000001 PBtmpl0000000000000210  PBtmpl0000000000000043 kj3b-X3i6zRKnhLb4ZiCLw    
CalendarEvent000000001 PBtmplBlankStyle000001  PBtmpl0000000000000044 ktSvKU8riGimhcsxXwqvPQ    
CalendarEventEdit00001 PBtmplHelp000000000001  PBtmpl0000000000000045 lG2exkH9FeYvn4pA63idNg    
CalendarMonth000000001 ProjectManagerTMPL0001  PBtmpl0000000000000047 limMkk80fMB3fqNZVf162w    
CalendarPrintDay000001 ProjectManagerTMPL0002  PBtmpl0000000000000053 m3IbBavqzuKDd2PGGhKPlA    
CalendarPrintEvent0001 ProjectManagerTMPL0003  PBtmpl0000000000000054 mM3bjP_iG9sv5nQb4S17tQ    
CalendarPrintMonth0001 ProjectManagerTMPL0004  PBtmpl0000000000000055 mRtqRuVikSe82BQsYBlD0A    
CalendarPrintWeek00001 ProjectManagerTMPL0005  PBtmpl0000000000000056 matrixtmpl000000000001    
CalendarSearch00000001 ProjectManagerTMPL0006  PBtmpl0000000000000057 matrixtmpl000000000002    
CalendarWeek0000000001 PsFn7dJt4wMwBa8hiE3hOA  PBtmpl0000000000000059 matrixtmpl000000000003    
CarouselTmpl0000000001 S2_LsvVa95OSqc66ITAoig  PBtmpl0000000000000060 matrixtmpl000000000004    
CarouselTmpl0000000002 S3zpVitAmhy58CAioH359Q  PBtmpl0000000000000061 matrixtmpl000000000005    
CxMpE_UPauZA3p8jdrOABw SQLReportDownload00001  PBtmpl0000000000000062 matrixtmpl000000000006    
D6cJpRcey35aSkh9Q_FPUQ SVIhz68689hwUGgcDM-gWw  PBtmpl0000000000000063 matrixtmpl000000000007    
DUoxlTBXhVS-Zl3CFDpt9g StockDataTMPL000000001  PBtmpl0000000000000065 nFen0xjkZn8WkpM93C9ceQ    
DashboardViewTmpl00001 StockDataTMPL000000002  PBtmpl0000000000000066 nWNVoMLrMo059mDRmfOp9g    
DoVNijm6lMDE0cYrtvEbDQ TEId5V-jEvUULsZA0wuRuA  PBtmpl0000000000000067 newsletter000000000001    
E3tzZjzhmYoNlAyP2VW33Q TKmhv8boP3TD2xwSwUBq0g  PBtmpl0000000000000068 newslettercs0000000001    
EBlxJpZQ9o-8VBOaGQbChA TbDcVLbbznPi0I0rxQf2CQ  PBtmpl0000000000000077 newslettersubscrip0001    
ErEzulFiEKDkaCDVmxUavw ThingyTmpl000000000001  PBtmpl0000000000000078 oHh0UqAJeY7u2n--WD-BAA    
ExpireIncResptmpl00001 ThingyTmpl000000000002  PBtmpl0000000000000079 ohjyzab5i-yW6GOWTeDUHg    
FJbUTvZ2nUTn65LpW6gjsA ThingyTmpl000000000003  PBtmpl0000000000000080 pbtmpl0000000000000220    
G5V6neXIDiFXN05oL-U3AQ ThingyTmpl000000000004  PBtmpl0000000000000081 pbtmpl0000000000000221    
GNvjCFQWjY2AF2uf0aCM8Q TimeTrackingTMPL000001  PBtmpl0000000000000082 q5O62aH4pjUXsrQR3Pq4lw    
GRUNFctldUgop-qRLuo_DA TimeTrackingTMPL000002  PBtmpl0000000000000083 stevecoolmenu000000001    
IOB0000000000000000001 TimeTrackingTMPL000003  PBtmpl0000000000000085 stevenav00000000000001    
IOB0000000000000000002 TuYPpHx7TUyk08639Pc8Bg  PBtmpl0000000000000088 stevestyle000000000001    
K8F0j_cq_jgo8dvWY_26Ag UTNFeV7B_aSCRmmaFCq4Vw  PBtmpl0000000000000091 stevestyle000000000002    
KAMdiUdJykjN02CPHpyZOw UserListTmpl0000000001  wAc4azJViVTpo-2NYOXWvg stevestyle000000000003    
MBmWlA_YEA2I6D29OMGtRg UserListTmpl0000000002  yBwydfooiLvhEFawJb0VTQ u9vfx33XDk5la1-QC5FK7g    
MK4fCNoyrx5SE8eyDfOpxg UserListTmpl0000000003  yxD5ka7XHebPLD-LXBwJqw uRL9qtk7Rb0YRJ41LmHOJw    
MultiSearchTmpl0000001 VBkY05f-E3WJS50WpdKd1Q  zcX-wIUct0S_np14xxOA-A vrKXEtluIhbmAS9xmPukDA    
zrNpGbT3odfIkg6nFSUy8Q 
/;
    my $tmplSth = $db->prepare('update template set isDefault=1 where assetId=?');
    foreach my $templateId (@templateIds) {
        $tmplSth->execute([$templateId]);
    }
    $tmplSth->finish;

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
    my $package = eval {
        my $node = WebGUI::Asset->getImportNode($session);
        my $node->importPackage( $storage, {
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
