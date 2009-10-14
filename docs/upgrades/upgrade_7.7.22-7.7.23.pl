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


my $toVersion = '7.7.23';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
fixBadVarCharColumns ( $session );

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
# Describe what our function does
sub fixBadVarCharColumns {
    my $session = shift;
    print "\tGive all revisionDate columns the correct definition... " unless $quiet;
    my @dataSets = (
        [ 'AdSku',                  'assetId',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'purchaseTemplate',     "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'manageTemplate',       "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'adSpace',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'AdSku',                  'clickDiscounts',       "CHAR(22)  DEFAULT NULL"                            ],
        [ 'AdSku',                  'impressionDiscounts',  "CHAR(22)  DEFAULT NULL"                            ],
        [ 'Collaboration',          'replyRichEditor',      "CHAR(22)  BINARY DEFAULT 'PBrichedit000000000002'" ],
        [ 'Collaboration',          'replyFilterCode',      "CHAR(30)  BINARY DEFAULT 'javascript'"             ],
        [ 'DataForm',               'htmlAreaRichEditor',   "CHAR(22)  BINARY DEFAULT '**Use_Default_Editor**'" ],
        [ 'MapPoint',               'website',              "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'address1',             "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'address2',             "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'city',                 "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'state',                "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'zipCode',              "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'country',              "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'phone',                "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'fax',                  "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'MapPoint',               'email',                "CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'Survey',                 'onSurveyEndWorkflowId',"CHAR(22)  BINARY DEFAULT NULL"                     ],
        [ 'Survey_questionTypes',   'questionType',         "CHAR(56)  NOT NULL"                                ],
        [ 'bucketLog',              'userId',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'bucketLog',              'Bucket',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'deltaLog',               'userId',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'deltaLog',               'assetId',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'deltaLog',               'url',                  "CHAR(255) NOT NULL"                                ],
        [ 'passiveAnalyticsStatus', 'userId',               "CHAR(255) NOT NULL"                                ],
        [ 'passiveLog',             'url',                  "CHAR(255) NOT NULL"                                ],
        [ 'passiveLog',             'userId',               "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'passiveLog',             'assetId',              "CHAR(22)  BINARY NOT NULL"                         ],
        [ 'passiveLog',             'sessionId',            "CHAR(22)  BINARY NOT NULL"                         ],
    );
    foreach my $dataSet (@dataSets) {
        $session->db->write(sprintf "ALTER TABLE `%s` MODIFY COLUMN `%s` %s", @{ $dataSet });
    }
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
