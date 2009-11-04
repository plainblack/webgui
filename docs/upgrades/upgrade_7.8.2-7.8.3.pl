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
use WebGUI::Utility;
use WebGUI::ProfileField;


my $toVersion = '7.8.3';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
reKeyTemplateAttachments($session);
addSelectPaymentGatewayTemplateToSettings($session);
addClipboardAdminSetting($session);
addTrashAdminSetting($session);
addPickLanguageMacro($session);
installSetLanguage($session);
i18nAbleToBeFriend($session);
addEMSEnhancements($session);
installUPSDriver($session);

finish($session); # this line required

#----------------------------------------------------------------------------
sub addEMSEnhancements {
    my $session = shift;
    print "\tAdding EMS Enhancements, if needed... " unless $quiet;
    my $sth = $session->db->read('describe EventManagementSystem printRemainingTicketsTemplateId');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table EventManagementSystem add column printRemainingTicketsTemplateId char(22) not null default 'hreA_bgxiTX-EzWCSZCZJw' after printTicketTemplateId");
    }
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub installUPSDriver {
    my $session = shift;
    print "\tAdding UPS Shipping Driver... " unless $quiet;
    $session->config->addToArray('shippingDrivers', 'WebGUI::Shop::ShipDriver::UPS');

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub i18nAbleToBeFriend {
    my $session = shift;
    print "\tInternationalize the Able To Be Friend profile field... " unless $quiet;
    my $field = WebGUI::ProfileField->new($session, 'ableToBeFriend');
    if ($field) {
        my $props = $field->get();
        $props->{label} = q{WebGUI::International::get('user profile field friend availability','WebGUI')};
        $field->set($props);
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addClipboardAdminSetting {
    my $session = shift;
    print "\tAdding clipboard admin setting... " unless $quiet;
    $session->setting->add('groupIdAdminClipboard', 3);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTrashAdminSetting {
    my $session = shift;
    print "\tAdding trash admin setting... " unless $quiet;
    $session->setting->add('groupIdAdminTrash', 3);
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Describe what our function does
sub reKeyTemplateAttachments {
    my $session = shift;
    print "\tChanging the key structure for the template attachments table... " unless $quiet;
    my $columnExists = $session->db->dbh->column_info(undef, undef, 'template_attachments', 'attachId')->fetchrow_hashref;
    if (! $columnExists) {
        # and here's our code
        $session->db->write('ALTER TABLE template_attachments ADD COLUMN attachId CHAR(22) BINARY NOT NULL');
        my $rh = $session->db->read('select url, templateId, revisionDate from template_attachments');
        my $wh = $session->db->prepare('update template_attachments set attachId=? where url=? and templateId=? and revisionDate=?');
        while (my @key = $rh->array) {
            $wh->execute([$session->id->generate, @key ]);
        }
        $rh->finish;
        $wh->finish;
        $session->db->write('ALTER TABLE template_attachments DROP PRIMARY KEY');
        $session->db->write('ALTER TABLE template_attachments ADD PRIMARY KEY (attachId)');
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# add default template for selectPaymentGateway
sub addSelectPaymentGatewayTemplateToSettings {
    my $session = shift;
    print "\tAdding select payment gateway template to settings... " unless $quiet;
    $session->setting->add('selectGatewayTemplateId', '2GxjjkRuRkdUg_PccRPjpA') unless $session->setting->has('selectGatewayTemplateId');
    print "Done.\n" unless $quiet;
}

#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#------------------------------------------------------------------------
sub addPickLanguageMacro {
    my $session = shift;
    print "\tAdding Pick Language macro... " unless $quiet;
    $session->config->set('macros/PickLanguage', 'PickLanguage');
    print "Done.\n" unless $quiet;
}

#------------------------------------------------------------------------
sub installSetLanguage {
    my $session = shift;
    print "\tAdding SetLanguage content handler... " unless $quiet;
    ##Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    if (!isIn('WebGUI::Content::SetLanguage', @{ $contentHandlers }) ) {
        my @newHandlers = ();
        foreach my $handler (@{ $contentHandlers }) {
            push @newHandlers, $handler;
            push @newHandlers, 'WebGUI::Content::SetLanguage' if
                $handler eq 'WebGUI::Content::PassiveAnalytics';
        }
        $session->config->set('contentHandlers', \@newHandlers);
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
