package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use JSON ();
use WebGUI::Storage;

=head1 NAME

Package WebGUI::Asset (AssetPackage)

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all package related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 exportAssetData ( )

Converts all the properties of this asset into a hash reference and then returns the hash reference. This method should be expanded upon by sub classes that have more data than just asset property data. Two nodes will be created: "properties" and "storage". Properties is a hash reference of the asset properties. Storage is an array reference of storage location ids. Storage will initially be empty, but if you have storage locations you want to include in this, then please push their ids onto this list when you override this method.

=cut

sub exportAssetData {
	my $self = shift;
	my %data = %{$self->get};
    delete $data{'session'};
	my %hash = ( properties => \%data, storage=>[] );
	return \%hash;
}

#-------------------------------------------------------------------

=head2 exportPackage ( )

Turns this package into a package file and returns the storage location object of the package file.

=cut

sub exportPackage {
	my $self = shift;
	my $storage = WebGUI::Storage->createTemp($self->session);
        my $assetIter = $self->getLineageIterator(["self","descendants"],{statusToInclude=>['approved', 'archived']});
        while ( 1 ) {
            my $asset;
            eval { $asset = $assetIter->() };
            if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                $self->session->log->error($x->full_message);
                next;
            }
            last unless $asset;
		my $data = $asset->exportAssetData;
		$storage->addFileFromScalar($data->{properties}{lineage}.".json", JSON->new->utf8->pretty->encode($data));
		foreach my $storageId (@{$data->{storage}}) {
			my $assetStorage = WebGUI::Storage->get($self->session, $storageId);
			$assetStorage->tar($storageId.".storage", $storage);
		}
	}
	my $filename = $self->get("url").".wgpkg";
	$filename =~ s/\//_/g;
	return $storage->tar($filename);
}	

#-------------------------------------------------------------------

=head2 WebGUI::Asset::getPackageList ( session )

Returns an array of all assets that the user can view and edit that are packages.  The array
is sorted by the title of the assets.

=cut

sub getPackageList {
    my $session = shift;
    if ( $session->isa( 'WebGUI::Asset' ) ) {
        $session    = $session->session;
    }
    my $db = $session->db;
    my @packageIds = $db->buildArray("select distinct assetId from assetData where isPackage=1");
    my @assets;
    ID: foreach my $id (@packageIds) {
        my $asset = WebGUI::Asset->newById($session, $id);
        next ID unless defined $asset;
        next ID unless $asset->get('isPackage');
        next ID unless ($asset->get('status') eq 'approved' || $asset->get('tagId') eq $session->scratch->get("versionTag"));
        push @assets, [$asset->getTitle, $asset];
    }
    @assets = map { $_->[1] } sort { $a->[0] cmp $b->[0] } @assets;
    return \@assets;

}


#-------------------------------------------------------------------

=head2 importAssetData ( hashRef )

Imports the data exported by the exportAssetData method. If the asset already exists, a new revision will be created with these properties. If it doesn't exist then a child will be added to the current asset. Returns a reference to the created asset.

=head3 hashRef

A hash reference containing the exported data.

=head3 options

A hash reference of options to change how the import works

=head4 inheritPermissions

Forces the all assets in the package to inherit ownerUserId, groupIdView and groupIdEdit
from the asset where it is deployed.

=head4 overwriteLatest

Forces the package to ignore the revisionDate inside it.  This makes the imported package the
latest revision of an asset.

=head4 clearPackageFlag

Clears the isPackage flag on the incoming asset.

=head4 setDefaultTemplate

Set the isDefault flag on the incoming asset.  Really only works on templates.

=cut

sub importAssetData {
    my $self        = shift;
    my $session     = $self->session;
    my $data        = shift;
    my $options     = shift || {};
    my $log       = $session->log;
    my $id          = $data->{properties}{assetId};
    my $class       = $data->{properties}{className};
    my $version     = $options->{overwriteLatest} ? time : $data->{properties}{revisionDate};

    # Load the class
    WebGUI::Asset->loadModule( $class );

    my %properties = %{ $data->{properties} };
    delete $properties{tagId};
    if ($options->{inheritPermissions}) {
        delete $properties{ownerUserId};
        delete $properties{groupIdView};
        delete $properties{groupIdEdit};
    }
    if ($options->{clearPackageFlag}) {
        $properties{isPackage} = 0;
    }
    if ($options->{setDefaultTemplate}) {
        $properties{isDefault} = 1;
    }

    if ($options->{clearPackageFlag}) {
        $properties{isPackage} = 0;
    }
    if ($options->{setDefaultTemplate}) {
        $properties{isDefault} = 1;
    }

    my $asset = eval { $class->new($session, $id, $version); };

    if (! Exception::Class->caught()) { # update an existing revision
        ##If the existing asset is not committed, do not allow the new package data to 
        ##change the version control status.
        if (  $asset->get('status') eq 'pending'
           && $properties{'status'} ne 'pending' ) {
           delete $properties{status};
        }
        $error->info("Updating an existing revision of asset $id");	
        $asset->update(\%properties);
        ##Pending assets are assigned a new version tag
        if ($properties{status} eq 'pending') {
            $session->db->write(
                'update assetData set tagId=? where assetId=? and revisionDate=?',
                [WebGUI::VersionTag->getWorking($session)->getId, $properties{assetId}, $properties{revisionDate},]
            );
        }
    }
    else {
        eval {
            $asset = WebGUI::Asset->newPending($session, $id);
        };
        if (! Exception::Class->caught()) {   # create a new revision of an existing asset
            $log->info("Creating a new revision of asset $id");
            $asset = $asset->addRevision(\%properties, $version, {skipAutoCommitWorkflows => 1});
        }
        else {  # add an entirely new asset
            $log->info("Adding $id that didn't previously exist.");
            $asset = $self->addChild(\%properties, $id, $version, {skipAutoCommitWorkflows => 1});
        }
    }

    # If the asset is in the trash, re-publish it
    if ( $asset->isInTrash ) {
        $asset->publish;
    }

    return $asset;
}

#-------------------------------------------------------------------

=head2 importAssetCollateralData ( data )

Allows you to import collateral data that is exported with your asset. 

=head3 data

Hashref containing the assets exported data.

=cut

sub importAssetCollateralData {
    # This is an interface method only. It is to be overloaded if needed.
}

#-------------------------------------------------------------------

=head2 importPackage ( storageLocation, options )

Imports the data from a webgui package file.

=head3 storageLocation

A reference to a WebGUI::Storage object that contains a webgui package file.

=head3 options

A hashref of options that are passed onto importAssetData.

=cut

sub importPackage {
    my $self            = shift;
    my $storage         = shift;
    my $options         = shift;
    my $decompressed    = $storage->untar($storage->getFiles->[0]);
    return undef
        if $storage->getErrorCount;
    my $package         = undef;            # The asset package
    my $log           = $self->session->log;

    # The debug output for long requests would be too long, and we'd have to
    # keep it all in memory.
    $log->preventDebugOutput();
    $log->info("Importing package.");

    # Your parent is on this stack somewhere because we're going through these
    # assets depth-first.  This way we only have to keep one branch in-memory
    # at a time, and it's always the right branch.
    my @stack;
    my $json = JSON->new->utf8->relaxed(1);

    foreach my $file (sort(@{$decompressed->getFiles})) {
        next unless ($decompressed->getFileExtension($file) eq "json");
        $log->info("Found data file $file");
        my $data = eval {
            $json->decode($decompressed->getFileContentsAsScalar($file))
        };
        if ($@ || $data->{properties}{assetId} eq "" || $data->{properties}{className} eq "" || $data->{properties}{revisionDate} eq "") {
            $log->error("package corruption: ".$@) if ($@);
            return "corrupt";
        }
        $log->info("Data file $file is valid and represents asset ".$data->{properties}{assetId});
        foreach my $storageId (@{$data->{storage}}) {
            my $assetStorage = WebGUI::Storage->get($self->session, $storageId);
            $decompressed->untar($storageId.".storage", $assetStorage);
        }

        my $parentId = $data->{properties}->{parentId};
        my $asset;
        while ($asset = pop(@stack)) {
            if ($asset->getId eq $parentId) {
                push(@stack, $asset);
                last;
            }
        }
        $asset ||= $self;

        my $newAsset = $asset->importAssetData($data, $options);
        $newAsset->importAssetCollateralData($data);

        push(@stack, $newAsset);

        # First imported asset must be the "package"
        $package ||= $newAsset;
    }

    return $package || 'corrupt';
}

#-------------------------------------------------------------------

=head2 www_deployPackage ( ) 

Deploys the package referenced by the query parameter 'assetId' as a
new child of the current asset.  Requires edit privileges on the
current asset.

=cut

sub www_deployPackage {
	my $self    = shift;
    my $session = $self->session;
	# Must have edit rights to the asset deploying the package.  Also, must be a Content Manager.
	# This protects against non content managers deploying packages using a post or similar trickery.
	return $session->privilege->insufficient() unless ($self->canEdit && $session->user->isInGroup(4));
	my $packageMasterAssetId = $session->form->param("assetId");
	if (defined $packageMasterAssetId) {
		my $packageMasterAsset = WebGUI::Asset->newById($session, $packageMasterAssetId);
		unless ($packageMasterAsset->get('isPackage')) { #only deploy packages
		 	$session->log->security('deploy an asset as a package which was not set as a package.');
		 	return undef;
		}
		my $masterLineage = $packageMasterAsset->get("lineage");
                if (defined $packageMasterAsset && $packageMasterAsset->canView && $self->get("lineage") !~ /^$masterLineage/) {
			my $deployedTreeMaster = $packageMasterAsset->duplicateBranch;
			$deployedTreeMaster->setParent($self);
			$deployedTreeMaster->update({isPackage=>0, styleTemplateId=>$self->get("styleTemplateId")});
		}
	}
    if (WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        allowComments   => 1,
        returnUrl       => $self->getUrl,
    }) eq 'redirect') {
        return undef;
    };
	if ($session->form->param("proceed") eq "manageAssets") {
		$session->http->setRedirect($self->getManagerUrl);
	} else {
		$session->http->setRedirect($self->getUrl());
	}
	return undef;
}

#-------------------------------------------------------------------

=head2 www_exportPackage ( )

Returns a tarball file for the user to download containing the package data.

=cut

sub www_exportPackage {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $storage = $self->exportPackage;
    my $filename = $storage->getFiles->[0];
    $self->session->http->setRedirect($storage->getUrl($storage->getFiles->[0]));
    return "redirect";
}

#-------------------------------------------------------------------

=head2 www_importPackage ( )

=cut

sub www_importPackage {
	my $self    = shift;
	my $session = $self->session;
	return $session->privilege->insufficient() unless ($self->canEdit && $session->user->isInGroup(4));

	my $form    = $session->form;
	my $storage = WebGUI::Storage->createTemp($session);

	##This is a hack.  It should use the WebGUI::Form::File API to insulate
	##us from future form name changes.
	$storage->addFileFromFormPost("packageFile",1);

	my $error = "";
	if ($storage->getFileExtension($storage->getFiles->[0]) eq "wgpkg") {
		$error = $self->importPackage(
			$storage, {
				inheritPermissions => $form->get('inheritPermissions'),
				clearPackageFlag   => $form->get('clearPackageFlag'),
			}
		);
	}
	if (!blessed $error) {
		my $i18n  = WebGUI::International->new($session, "Asset");
		my $style = $session->style;
		if ($error eq 'corrupt') {
			return $style->userStyle($i18n->get("package corrupt"));
		}
		else {
			return $style->userStyle($i18n->get("package extract error"));
		}
	}
    # Handle autocommit workflows
    if (WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        allowComments   => 1,
        returnUrl       => $self->getUrl,
    }) eq 'redirect') {
        return undef;
    };

    return $self->www_manageAssets();
}

1;

