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
use WebGUI::Asset::Template;


my $toVersion = "7.6.3"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required
# upgrade functions go here
createLastUpdatedField($session);
createFieldShowOnline($session);
upgradeSyndicatedContentTemplates($session);

finish($session); # this line required

#----------------------------------------------------------------------------
sub createLastUpdatedField {
    my $session = shift;
    print "\tAdding last updated field to all assets... " unless $quiet;
    my $db = $session->db;
    $db->write("alter table assetData add column lastModified bigint");
    $db->write("update assetData set lastModified=revisionDate");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub upgradeSyndicatedContentTemplates {
    my $session = shift;
    print "\tUpgrading syndicated content assets... " unless $quiet;
    my $db = $session->db;
    my $templates = $db->read("select distinct assetId from template where namespace='SyndicatedContent'");
    while (my ($id) = $templates->array) {
        my $asset = WebGUI::Asset::Template->new($session, $id);
        if (defined $asset) {
            if ($asset->getId eq "DPUROtmpl0000000000001") { # this one no longer applies
                $asset->trash;
                next;
            }
            my $template = $asset->get('template');
            $template =~ s{channel.title}{channel_title}xmsi;
            $template =~ s{channel.description}{channel_description}xmsi;
            $template =~ s{channel.link}{channel_link}xmsi;
            $template =~ s{site_link}{channel_link}xmsi;
            $template =~ s{site_title}{channel_title}xmsi;
            $template =~ s{descriptionFull}{description}xmsi;
            $template =~ s{rss.url.0.9}{rss_url}xmsi;
            $template =~ s{rss.url}{rss_url}xmsi;
            $template =~ s{rss.url.0.91}{rss_url}xmsi;
            $template =~ s{rss.url.1.0}{rdf_url}xmsi;
            $template =~ s{rss.url.2.0}{rss_url}xmsi;
            $asset->addRevision({template=>$template});
        }
    }
    $db->write("update SyndicatedContent set templateId='PBtmpl0000000000000065' where templateId='DPUROtmpl0000000000001'");
    $db->write("alter table SyndicatedContent drop column displayMode");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub createFieldShowOnline {
    my $session = shift;
    print "\tCreating an additional profile field 'showOnline' for the UsersOnline macro... " unless $quiet;

    # Define field properties
    my $properties = {
        label => q!WebGUI::International::get('Show when online?','WebGUI')!,
        visible => 1,
        required => 0,
        protected => 1,                 # The UsersOnline macro requires this field for working properly.
        editable => 1,
        fieldType => 'YesNo',
        dataDefault => 0                # Users are not shown by default.
    };
    # Create field in category "preferences"
    my $field = WebGUI::ProfileField->create($session, 'showOnline', $properties, 4);

    # Check for failure
    if ($field == undef) {
        print "Creation of the field 'showOnline' failed, possibly because it does already exist. Note that this may cause the UsersOnline macro not to work properly.\n";
    }
    else {
        print "DONE!\n" unless $quiet;
    }
    
    return;
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
