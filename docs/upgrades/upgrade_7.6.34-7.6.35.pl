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


my $toVersion = '7.6.35';
my $quiet; # this line required


my $session = start(); # this line required
fixDefaultSQLReportDownloadGroup($session);

ensureAllFieldsUtf8($session);
# upgrade functions go here

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
sub ensureAllFieldsUtf8 {
    my $session = shift;
    print "\tEnsuring all database fields are UTF-8... " unless $quiet;

    my $dbh = $session->db->dbh;
    my $sth;
    my @tables;
    my @stmts;
    # Get table list
    $sth = $dbh->table_info(undef, undef, '%');
    while (my $row = $sth->fetchrow_hashref) {
        push @tables, $row->{TABLE_NAME};
    }
    $sth->finish;

    for my $table (@tables) {
        my $sth = $dbh->column_info(undef, undef, $table, '%');
        while (my $row = $sth->fetchrow_hashref) {
            if ($row->{TYPE_NAME} =~ /(?:VAR)?CHAR|TEXT/i) {
                push @stmts, sprintf('ALTER TABLE %s MODIFY %s %s %s CHARACTER SET utf8 %s %s',
                    $dbh->quote_identifier($row->{TABLE_NAME}),
                    $dbh->quote_identifier($row->{COLUMN_NAME}),
                    $row->{mysql_type_name},
                    ($row->{COLUMN_SIZE} == 22 ? 'binary' : ''),
                    ($row->{IS_NULLABLE} eq 'NO' ? 'NOT NULL' : ''),
                    (defined $row->{COLUMN_DEF} && $row->{COLUMN_DEF} ne '' ? 'DEFAULT ' . $dbh->quote($row->{COLUMN_DEF}) : ''),
                );
            }
        }
        $sth->finish;
    }


    for my $stmt (@stmts) {
        $dbh->do($stmt);
    }

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub fixDefaultSQLReportDownloadGroup {
    my $session = shift;
    print "\tFix bad default SQL Report Download groups... " unless $quiet;
    $session->db->write(<<EOSQL);
UPDATE SQLReport SET downloadUserGroup='7' WHERE downloadUserGroup="text/html";
EOSQL
    # and here's our code
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
    my $package = eval { WebGUI::Asset->getImportNode($session)->importPackage( $storage ); };

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
