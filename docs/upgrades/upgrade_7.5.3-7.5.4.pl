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


my $toVersion = '7.5.4';
my $quiet; # this line required


my $session = start(); # this line required

addIndexesToSQLForms($session);

finish($session); # this line required


#-------------------------------------------------
sub addIndexesToSQLForms {
    my $session = shift;
    print "\tAdding extra indexes to SQL Forms.\n" unless ($quiet);
    my $sqlForms = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], {
        statusToInclude => [qw(pending approved archived)],
        statesToInclude => [qw(published trash trash-limbo clipboard clipboard-limbo)],
        returnObjects => 1,
        includeOnlyClasses => ['WebGUI::Asset::Wobject::SQLForm'],
    });
    for my $sqlForm (@$sqlForms) {
        my $dbLink = WebGUI::DatabaseLink->new($session, $sqlForm->getValue('databaseLinkId'))->db;
        my $dbh = $dbLink->dbh;
        $dbh->{PrintError} = 0;
        eval {
            # We don't care about failure
            $dbh->do('CREATE INDEX `recordId_archived` ON ' . $dbh->quote_identifier($sqlForm->get('tableName')) . ' (__recordId, __archived)');
        };
        $dbLink->disconnect;
    }
}


##-------------------------------------------------
#sub exampleFunction {
#	my $session = shift;
#	print "\tWe're doing some stuff here that you should know about.\n" unless ($quiet);
#	# and here's our code
#}


# --------------- DO NOT EDIT BELOW THIS LINE --------------------------------

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

