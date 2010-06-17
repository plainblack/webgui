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
use WebGUI::Workflow;
use WebGUI::Utility;

my $toVersion = '7.7.2';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here

recalculateMatrixListingMedianValue( $session );
addRssFeedAspect($session);
addRssFeedAspectToAssets($session);
convertCollaborationToRssAspect($session);
removeRssCapableAsset($session);
addCreationTimeToCart($session);
addCartKillerActivityToConfig($session);
addCartKillerActivityToWorkflow($session);

finish($session); # this line required

#----------------------------------------------------------------------------
sub recalculateMatrixListingMedianValue{
    my $session = shift;
    print "\tRecalculating median value for Matrix Listing ratings... " unless $quiet;
    my $matrices   = WebGUI::Asset->getRoot($session)->getLineage(['descendants'],
        {
            statesToInclude     => ['published','trash','clipboard','clipboard-limbo','trash-limbo'],
            statusToInclude     => ['pending','approved','deleted','archived'],
            includeOnlyClasses  => ['WebGUI::Asset::Wobject::Matrix'],
            returnObjects       => 1,
        });

    for my $matrix (@{$matrices})
    {
        next unless defined $matrix;
    my %categories = keys %{$matrix->getCategories};
    my $listings = $session->db->read("select distinct listingId from MatrixListing_rating where assetId = ?"
        ,[$matrix->getId]);
        while (my $listing= $listings->hashRef){
        foreach my $category (%categories) {
            my $half = $session->db->quickScalar("select round((select count(*) from MatrixListing_rating where
listingId = ? and category = ?)/2)",[$listing->{listingId},$category]);
            my $medianValue = $session->db->quickScalar("select rating from MatrixListing_rating where listingId =?
and category =? order by rating limit $half,1;",[$listing->{listingId},$category]);
            $session->db->write("update MatrixListing_ratingSummary set medianValue = ? where listingId = ? and
category = ?",[$medianValue,$listing->{listingId},$category]);
        }
    }
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRssFeedAspect {
    my $session = shift;
    print "\tAdding RssFeed asset aspect..." unless $quiet;
    $session->db->write(q{create table assetAspectRssFeed (
        assetId char(22) binary not null,
        revisionDate bigint not null,
        itemsPerFeed int(11) default 25,
        feedCopyright text,
        feedTitle text,
        feedDescription mediumtext,
        feedImage char(22) binary,
        feedImageLink text,
        feedImageDescription mediumtext,
        feedHeaderLinks char(32) default 'rss\natom',
        primary key (assetId, revisionDate)
        )});
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRssFeedAspectToAssets {
    my $session = shift;
    my $db = $session->db;
    foreach my $asset_class (qw( WikiMaster SyndicatedContent Gallery GalleryAlbum )) {
        print "\tAdding RssFeed aspect to $asset_class table..." unless $quiet;
        my $pages = $db->read("select assetId,revisionDate from $asset_class");
        while (my ($id, $rev) = $pages->array) {
            $db->write("INSERT INTO assetAspectRssFeed (assetId, revisionDate, itemsPerFeed, feedTitle, feedDescription, feedImage, feedImageLink, feedImageDescription) VALUES (?,?,25,'','',NULL,'','')",[$id,$rev]);
        }
        print "Done.\n" unless $quiet;
    }
}

#----------------------------------------------------------------------------
sub convertCollaborationToRssAspect {
    my $session = shift;
    print "\tAdding RssFeed aspect to Collaboration, (porting rssCapableRssLimit to itemsPerFeed)..." unless $quiet;
    my $db = $session->db;
    my @rssFromParents;
    my $pages = $db->read("SELECT Collaboration.assetId, Collaboration.revisionDate, RSSCapable.rssCapableRssLimit, RSSCapable.rssCapableRssFromParentId, RSSCapable.rssCapableRssEnabled FROM Collaboration INNER JOIN RSSCapable ON Collaboration.assetId=RSSCapable.assetId AND Collaboration.revisionDate=RSSCapable.revisionDate");
    while (my ($id, $rev, $limit, $fromParent, $enabled) = $pages->array) {
        if ($fromParent) {
            push @rssFromParents, $fromParent;
        }
        my $headerLinks = $enabled ? "rss\natom" : q{};
        $db->write("INSERT INTO assetAspectRssFeed (assetId, revisionDate, itemsPerFeed, feedTitle, feedDescription, feedImage, feedImageLink, feedImageDescription, feedHeaderLinks) VALUES (?,?,?,'','',NULL,'','',?)",[$id,$rev,$limit || 25, $headerLinks]);
    }
    for my $assetId (@rssFromParents) {
        my $asset = eval { WebGUI::Asset->newPending($session, $assetId) };
        if ($asset) {
            $asset->purge;
        }
    }
    $db->write("DELETE FROM RSSCapable WHERE assetId IN (SELECT assetId FROM Collaboration GROUP BY assetId)");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeRssCapableAsset {
    my $session = shift;
    print "\tChecking for uses of RSSCapable...\n" unless $quiet;
    my @rssCapableClasses = $session->db->buildArray('SELECT className FROM RSSCapable INNER JOIN asset ON RSSCapable.assetId=asset.assetId GROUP BY className');
    if (@rssCapableClasses) {
        warn "\t\tThis site is using the assets\n\t\t\t" . join(', ', @rssCapableClasses) . "\n\t\twhich use the RSSCapable class!  Support RSSCapable has been dropped and it will no longer be maintained.\n";
    }
    else {
        print "\t\tNot used, removing.\n" unless $quiet;
        $session->db->write(q|DELETE FROM assetData WHERE assetId IN (SELECT assetId FROM asset WHERE className="WebGUI::Asset::RssFromParent")|);
        $session->db->write(q|DELETE FROM asset WHERE className = "WebGUI::Asset::RssFromParent"|);
        $session->db->write("DROP TABLE RSSCapable");
        $session->db->write("DROP TABLE RSSFromParent");
        my $rssCapableTemplates = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], {
            statesToInclude     => [qw(published clipboard clipboard-limbo trash-limbo)],
            statusToInclude     => [qw(approved pending archived)],
            returnObjects       => 1,
            includeOnlyClasses  => ['WebGUI::Asset::Template'],
            joinClass           => 'WebGUI::Asset::Template',
            whereClause         => q{template.namespace = 'RSSCapable/RSS'},
        });
        for my $template (@{$rssCapableTemplates}) {
            $template->trash;
        }
    }
    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCreationTimeToCart {
    my $session = shift;
    print "\tAdding creation time to cart..." unless $quiet;
    $session->db->write("alter table cart add column creationDate int(20)");
    $session->db->write('update cart set creationDate=NOW()');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCartKillerActivityToConfig {
    my $session = shift;
    print "\tAdding Remove Old Carts workflow activity to config files..." unless $quiet;
    my $activities = $session->config->get('workflowActivities');
    my $none = $activities->{'None'};
    if (!isIn('WebGUI::Workflow::Activity::RemoveOldCarts', @{ $none })) {
        push @{ $none }, 'WebGUI::Workflow::Activity::RemoveOldCarts';
    }
    $session->config->set('workflowActivities', $activities);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCartKillerActivityToWorkflow {
    my $session = shift;
    print "\tAdding Remove Old Carts workflow activity to Daily Workflow..." unless $quiet;
    my $workflow = WebGUI::Workflow->new($session, 'pbworkflow000000000001');
    my $removeCarts = $workflow->addActivity('WebGUI::Workflow::Activity::RemoveOldCarts');
    $removeCarts->set('title', 'Remove old carts');
    print "Done.\n" unless $quiet;
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
