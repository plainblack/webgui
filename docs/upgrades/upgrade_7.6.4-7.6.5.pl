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
use WebGUI::Asset;


my $toVersion = "7.6.5"; # make this match what version you're going to
my $quiet; # this line required

my $session = start(); # this line required

fixAccountMisspellings(  $session );
removeTemplateHeadBlock( $session );

# upgrade functions go here
finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does

sub updateMatrixListingScores {
    my $session = shift;
    print "\tUpdating score for every MatrixListing asset... " unless $quiet;
    my $matrixListings   = WebGUI::Asset->getRoot($session)->getLineage(['descendants'],
        {
            statesToInclude     => ['published','trash','clipboard','clipboard-limbo','trash-limbo'],
            statusToInclude     => ['pending','approved','deleted','archived'],
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            returnObjects       => 1,
        });

    for my $matrixListing (@{$matrixListings})
    {
        next unless defined $matrixListing;
        my $score = $session->db->quickScalar("select sum(value) from MatrixListing_attribute 
            left join Matrix_attribute using(attributeId) 
            where matrixListingId = ? and fieldType = 'MatrixCompare'",
            [$matrixListing->getId]);
        $matrixListing->update({score => $score});
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------

sub removeTemplateHeadBlock {
    my $session = shift;
    print "\tMerging Template head blocks into the Extra Head Tags field... " unless $quiet;
    my $sth = $session->db->prepare('select assetId, revisionDate, headBlock from template');
    $sth->execute();
    TMPL: while (my $templateData = $sth->hashRef) {
        my $template = WebGUI::Asset->new($session,
            $templateData->{assetId}, 'WebGUI::Asset::Template',
            $templateData->{revisionDate},
        );
        next TMPL unless defined $template;
        if ($template->get('namespace') eq 'style') {
            $template->update({
                extraHeadTags => '',
            });
        }
        else {
            $template->update({
                extraHeadTags => $template->getExtraHeadTags . $templateData->{headBlock},
            });
        }
    }
    $session->db->write('ALTER TABLE template DROP COLUMN headBlock');
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#----------------------------------------------------------------------------
#Describe what our function does
sub fixAccountMisspellings {
    my $session = shift;
    my $setting = $session->setting;
    print "\tFix misspellings in Account settings... " unless $quiet;
    # and here's our code
    $setting->add("profileViewTemplateId",   $setting->get('profileViewTempalteId')  );
    $setting->add("profileErrorTemplateId",  $setting->get('profileErrorTempalteId') );
    $setting->add("inboxLayoutTemplateId",   $setting->get('inboxLayoutTempalteId')  );
    $setting->add("friendsLayoutTemplateId", $setting->get('friendsLayoutTempalteId'));
    $setting->remove("profileViewTemplateId");
    $setting->remove("profileErrorTemplateId");
    $setting->remove("inboxLayoutTemplateId");
    $setting->remove("friendsLayoutTemplateId");
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
